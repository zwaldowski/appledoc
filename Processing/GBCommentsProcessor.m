//
//  GBCommentsProcessor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "RegexKitLite.h"
#import "GBApplicationSettingsProvider.h"
#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessor ()

- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)range;
- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)range;

- (BOOL)registerWarningBlockFromlines:(NSArray *)lines;
- (BOOL)registerBugBlockFromLines:(NSArray *)lines;
- (BOOL)registerExampleBlockFromLines:(NSArray *)lines;
- (void)registerTextItemsFromStringToCurrentParagraph:(NSString *)string;
- (void)registerTextAndLinkItemsFromString:(NSString *)string toObject:(id)object;
- (id)remoteMemberLinkItemFromString:(NSString *)string range:(NSRange *)range;
- (id)localMemberLinkFromString:(NSString *)string range:(NSRange *)range;
- (id)classLinkFromString:(NSString *)string range:(NSRange *)range;
- (id)categoryLinkFromString:(NSString *)string range:(NSRange *)range;
- (id)protocolLinkFromString:(NSString *)string range:(NSRange *)range;
- (id)urlLinkItemFromString:(NSString *)string range:(NSRange *)range;

- (void)registerParagraphItemToCurrentParagraph:(GBParagraphItem *)item;

@property (retain) NSMutableArray *paragraphsStack;
@property (retain) GBComment *currentComment;
@property (retain) id currentContext;

@property (retain) GBStore *store;
@property (retain) GBApplicationSettingsProvider *settings;
@property (readonly) GBCommentComponentsProvider *components;

@property (readonly) NSString *sourceFileInfo;
@property (assign) NSUInteger currentStartLine;

@end

#pragma mark -

@implementation GBCommentsProcessor

#pragma mark Initialization & disposal

+ (id)processorWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	GBLogDebug(@"Initializing comments processor with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Processing handling

- (void)processComment:(GBComment *)comment withStore:(id)store {
	[self processComment:comment withContext:nil store:store];
}

- (void)processComment:(GBComment *)comment withContext:(id<GBObjectDataProviding>)context store:(id)store {
	NSParameterAssert(comment != nil);
	NSParameterAssert(store != nil);
	GBLogDebug(@"Processing %@ found in %@...", comment, comment.sourceInfo.filename);
	self.paragraphsStack = [NSMutableArray array];
	self.currentComment = comment;
	self.currentContext = context;
	self.store = store;	
	NSArray *lines = [comment.stringValue arrayOfLines];
	NSUInteger line = comment.sourceInfo.lineNumber;
	NSRange range = NSMakeRange(0, 0);
	GBLogDebug(@"- Comment has %lu lines.", [lines count]);
	while ([self findCommentBlockInLines:lines blockRange:&range]) {
		GBLogDebug(@"- Found comment block in lines %lu..%lu...", line + range.location, line + range.location + range.length);
		[self processCommentBlockInLines:lines blockRange:range];
		range.location += range.length;
	}
}

- (BOOL)findCommentBlockInLines:(NSArray *)lines blockRange:(NSRange *)range {
	// Searches the given array of lines for the index of ending line of the block starting at the given index. Effectively this groups all lines that belong to a single block where block is a paragraph text or one of it's items delimited by empty line. The index returned is the index of the last line of the block, so may be the same as the start index, the method takes care to skip empty starting lines if needed and updates start index to point to first block line (but properly detects empty lines belonging to example block). Note that the code is straightforward except for the fact that we need to handle example blocks properly (i.e. can't just trim all whitespace of a line to determine if it's empty or not, instead we need to validate the line is not part of example block).
	NSParameterAssert(range != NULL);
	
	// First skip all starting empty lines.
	NSUInteger start = range->location;
	while (start < [lines count]) {
		NSString *line = [lines objectAtIndex:start];
		if ([line length] > 0) break;
		start++;
	}
	
	// Find the end of block.
	NSUInteger end = start;
	if (start < [lines count]) {
		while (end < [lines count]) {
			NSString *line = [lines objectAtIndex:end];
			if ([line length] == 0) break;
			end++;
		}
	}
	
	// Pass results back to client through parameters.
	range->location = start;
	range->length = end - start;
	return (start < [lines count]);
}

- (void)processCommentBlockInLines:(NSArray *)lines blockRange:(NSRange)range {
	// The given range is guaranteed to point to actual block within the lines array, so we only need to determine the kind of block and how to handle it.
	NSArray *block = [lines subarrayWithRange:range];
	self.currentStartLine = self.currentComment.sourceInfo.lineNumber + range.location;
	if ([self registerExampleBlockFromLines:block]) return;
	if ([self registerBugBlockFromLines:block]) return;
	if ([self registerWarningBlockFromlines:block]) return;
}

#pragma mark Comment blocks processing

- (BOOL)registerWarningBlockFromlines:(NSArray *)lines {
	// Warning block is a GBParagraphSpecialItem containing one or more GBParagraph items.
	if (![[lines firstObject] isMatchedByRegex:self.components.bugSectionRegex]) return NO;
	
	// Get the description and warn if empty text was found (we still return YES as the block was properly detected as @warning.
	NSString *string = [NSString stringByCombiningLines:lines delimitWith:@"\n"];
	NSString *description = [string stringByMatching:self.components.bugSectionRegex capture:1];
	if ([description length] == 0) {
 		GBLogWarn(@"Empty @warning block found in %@!", self.sourceFileInfo);
		return YES;
	}
	
	// Prepare paragraph item by setting up it's description paragraph, split the string into items and register all items to paragraph. Note that this code effectively ends block paragraph here, so any subsequent block will be added to current paragraph instead. This allows @bug blocks being written anywhere in the documentation, but prevents having more than one paragraph within.
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeWarning stringValue:description];
	[self.paragraphsStack push:[GBCommentParagraph paragraph]];	
	[self registerTextItemsFromStringToCurrentParagraph:string];
	[item registerParagraph:[self.paragraphsStack peek]];
	[self.paragraphsStack pop];
	
	// Register block item to current paragraph; create new one if necessary.
	[self registerParagraphItemToCurrentParagraph:item];
	return YES;
}

- (BOOL)registerBugBlockFromLines:(NSArray *)lines {
	// Bug block is a GBParagraphSpecialItem containing one or more GBParagraph items.
	if (![[lines firstObject] isMatchedByRegex:self.components.bugSectionRegex]) return NO;
	
	// Get the description and warn if empty text was found (we still return YES as the block was properly detected as @bug.
	NSString *string = [NSString stringByCombiningLines:lines delimitWith:@"\n"];
	NSString *description = [string stringByMatching:self.components.bugSectionRegex capture:1];
	if ([description length] == 0) {
 		GBLogWarn(@"Empty @bug block found in %@!", self.sourceFileInfo);
		return YES;
	}
	
	// Prepare paragraph item by setting up it's description paragraph, split the string into items and register all items to paragraph. Note that this code effectively ends block paragraph here, so any subsequent block will be added to current paragraph instead. This allows @bug blocks being written anywhere in the documentation, but prevents having more than one paragraph within.
	GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeBug stringValue:description];
	[self.paragraphsStack push:[GBCommentParagraph paragraph]];	
	[self registerTextItemsFromStringToCurrentParagraph:string];
	[item registerParagraph:[self.paragraphsStack peek]];
	[self.paragraphsStack pop];
	
	// Register block item to current paragraph; create new one if necessary.
	[self registerParagraphItemToCurrentParagraph:item];
	return YES;
}

- (BOOL)registerExampleBlockFromLines:(NSArray *)lines {
	// Example block is a GBParagraphSpecialItem containing one or more GBParagraph items. The block is only considered as example if each line is prefixed with a single tab or 4 spaces. That leading whitespace is removed from each line in registered data. Note that we allow having mixed lines where one starts with tab and another with spaces!
	
	// Validate all lines match required prefix. Note that we first used dictionaryByMatchingRegex:withKeysAndCaptures: but it ended with EXC_BAD_ACCESS and I couldn't figure it out, so reverted to captureComponentsMatchedByRegex:
	NSString *regex = self.components.exampleSectionRegex;
	NSMutableArray *linesOfCaptures = [NSMutableArray arrayWithCapacity:[lines count]];
	for (NSString *line in lines) {
		NSArray *match = [line captureComponentsMatchedByRegex:regex];
		if ([match count] == 0) return NO;
		[linesOfCaptures addObject:match];
	}
	
	// So all lines are indeed prefixed with required example whitespace, let's create the item. First prepare string value containing only text without prefix. Note that capture index 0 contains full text, index 1 just the prefix and index 2 just the text.
	NSMutableString *stringValue = [NSMutableString string];
	[linesOfCaptures enumerateObjectsUsingBlock:^(NSArray *captures, NSUInteger idx, BOOL *stop) {
		if ([stringValue length] > 0) [stringValue appendString:@"\n"];
		NSString *lineText = [captures objectAtIndex:2];
		[stringValue appendString:lineText];
	}];
	
    // Prepare paragraph item. Note that we don't use paragraphs stack as currently we don't process the text for cross refs!
    GBParagraphSpecialItem *item = [GBParagraphSpecialItem specialItemWithType:GBSpecialItemTypeExample stringValue:stringValue];
	GBCommentParagraph *paragraph = [GBCommentParagraph paragraph];
    [paragraph registerItem:[GBParagraphTextItem paragraphItemWithStringValue:stringValue]];
	[item registerParagraph:paragraph];
	
    // Register special item to paragraph.
    [self registerParagraphItemToCurrentParagraph:item];
	return YES;
}

#pragma mark Comment text processing

- (void)registerTextItemsFromStringToCurrentParagraph:(NSString *)string {
	// Registers the text from the given string to last paragraph. Text is converted to an array of GBParagraphTextItem, GBParagraphLinkItem and GBParagraphDecoratorItem objects. This is the main entry point for text processing, this is the only message that should be used for processing text from higher level methods. WARNING: The client is responsible for adding proper paragraph to the stack!
	NSString *simplified = [string stringByReplacingOccurrencesOfRegex:@"(\\*_|_\\*)" withString:@"=!="];
	NSArray *components = [simplified arrayOfDictionariesByMatchingRegex:@"(?s:(\\*|_|=!=|`)(.*?)\\1)" withKeysAndCaptures:@"type", 1, @"value", 2, nil];
	GBCommentParagraph *paragraph = [self.paragraphsStack peek];
	__block NSRange search = NSMakeRange(0, [simplified length]);
	[components enumerateObjectsUsingBlock:^(NSDictionary *component, NSUInteger idx, BOOL *stop) {
		// Get range of next formatted section. If not found, exit (we'll deal with remaining text after the loop).
		NSString *type = [component objectForKey:@"type"];
		NSRange range = [simplified rangeOfString:type options:0 range:search];
		if (range.location == NSNotFound) return;
		
		// If we skipped some text, add it before handling formatted part!
		if (range.location > search.location) {
			NSRange skippedRange = NSMakeRange(search.location, range.location - search.location);
			NSString *skippedText = [simplified substringWithRange:skippedRange];
			GBLogDebug(@"  - Found '%@' text at %@, processing for cross refs...", skippedText, self.sourceFileInfo);
			[self registerTextAndLinkItemsFromString:skippedText toObject:paragraph];
		}

		// Get formatted text and prepare properly decorated component. Note that we warn the user if we find unknown decorator type (this probably just means we changed some decorator value by forgot to change this part, so it's some sort of "exception" catching).
		NSString *text = [component valueForKey:@"value"];
		if ([text length] > 0) {
			GBParagraphDecoratorItem *decorator = [GBParagraphDecoratorItem paragraphItemWithStringValue:text];
			if ([type isEqualToString:@"*"]) {
				GBLogDebug(@"  - Found '%@' formatted as bold at %@, processing for cross refs...", [text normalizedDescription], self.sourceFileInfo);
				decorator.decorationType = GBDecorationTypeBold;
			} else if ([type isEqualToString:@"_"]) {
				GBLogDebug(@"  - Found '%@' formatted as italics at %@, processing for cross refs...", [text normalizedDescription], self.sourceFileInfo);
				decorator.decorationType = GBDecorationTypeItalics;
			} else if ([type isEqualToString:@"`"]) {
				GBLogDebug(@"  - Found '%@' formatted as code at %@, processing for cross refs...", [text normalizedDescription], self.sourceFileInfo);
				decorator.decorationType = GBDecorationTypeCode;
			} else if ([type isEqualToString:@"=!="]) {
				GBLogDebug(@"  - Found '%@' formatted as bold-italics at %@, processing for cross refs...", [text normalizedDescription], self.sourceFileInfo);
				GBParagraphDecoratorItem *inner = [GBParagraphDecoratorItem paragraphItemWithStringValue:text];
				decorator.decorationType = GBDecorationTypeBold;
				[decorator registerItem:inner];
				inner.decorationType = GBDecorationTypeItalics;
				decorator = inner;
			} else {
				GBLogWarn(@"Unknown text decorator type %@ detected at %@!", type, self.sourceFileInfo);
				decorator = nil;
			}
			
			if (decorator) {
				[self registerTextAndLinkItemsFromString:text toObject:decorator];
				[paragraph registerItem:decorator];
			}
		}

		// Prepare next search range.
		NSUInteger location = range.location + range.length * 2 + [text length];
		search = NSMakeRange(location, [simplified length] - location);
	}];

	// If we have some remaining text, append it now.
	if ([simplified length] > search.location) {
		NSString *remainingText = [simplified substringWithRange:search];
		GBLogDebug(@"  - Found '%@' text at %@, processing for cross refs...", [remainingText normalizedDescription], self.sourceFileInfo);
		[self registerTextAndLinkItemsFromString:remainingText toObject:paragraph];
	}
}

- (void)registerTextAndLinkItemsFromString:(NSString *)string toObject:(id)object {
	// Scans the given string for possible links and converts the text to an array of GBParagraphTextItem and GBParagraphLinkItem objects which are ultimately registered to the given object. NOTE: This message is intended to be sent from registerTextItemsFromStringToCurrentParagraph: and should not be used otherwise! WARNING: The given object must respond to registerItem: message!
#define registerTextItemFromString(theString) \
	if ([theString length] > 0) { \
		GBLogDebug(@"    - Found text '%@'...", [theString normalizedDescription]); \
		GBParagraphTextItem *textItem = [GBParagraphTextItem paragraphItemWithStringValue:theString]; \
		[object registerItem:textItem]; \
		[theString setString:@""]; \
	}
#define registerLinkItem(theItem, theType) { \
	GBLogDebug(@"    - Found %@ %@. cross ref..", theType, theItem.stringValue); \
	[object registerItem:theItem]; \
}
#define skipTextFromString(theString) { \
	if (theString) { \
		[text appendString:theString]; \
		string = [string substringFromIndex:[theString length]]; \
	} \
}
	// Progressively chip away the string and test if it starts with any known cross reference. If so, register link item, otherwise consider the text as normal text item, so skip to the next word.
	NSMutableString *text = [NSMutableString stringWithCapacity:[string length]];
	NSRange range = NSMakeRange(0, 0);
	GBParagraphLinkItem *linkItem;
	while ([string length] > 0) {
		// If the string starts with any recognized cross reference, add the link item. Note that the order of testing is somewhat important (for example we should test for category before class or protocol to avoid text up to open parenthesis being recognized as a class where in fact it's category).
		if ((linkItem = [self categoryLinkFromString:string range:&range])) {
			registerTextItemFromString(text);
			registerLinkItem(linkItem, @"category");
		} else if ((linkItem = [self classLinkFromString:string range:&range])) {
			registerTextItemFromString(text);
			registerLinkItem(linkItem, @"class");
		} else if ((linkItem = [self protocolLinkFromString:string range:&range])) {
			registerTextItemFromString(text);
			registerLinkItem(linkItem, @"protocol");
		} else if ((linkItem = [self remoteMemberLinkItemFromString:string range:&range])) {
			registerTextItemFromString(text);
			registerLinkItem(linkItem, @"remote member");
		} else if ((linkItem = [self localMemberLinkFromString:string range:&range])) {
			registerTextItemFromString(text);
			registerLinkItem(linkItem, @"local member");
		} else if ((linkItem = [self urlLinkItemFromString:string range:&range])) {
			registerTextItemFromString(text);
			registerLinkItem(linkItem, @"url");
		}
		
		// If we found a cross reference, skip it's text, otherwise mark the word until next whitespace as text item.
		if (linkItem)
			string = [string substringFromIndex:range.location + range.length];
		else
			skipTextFromString([string stringByMatching:@"^\\S+"]);
		
		// Skip any leading whitespace until the next word and mark it as text item.
		skipTextFromString([string stringByMatching:@"^\\s+"]);
	}
	
	// Append any remaining text 
	registerTextItemFromString(text);
}

#pragma mark Cross references detection

- (id)remoteMemberLinkItemFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for remote member cross reference (in the format [Object member]). If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers.
	NSParameterAssert(range != NULL);
	
	// If the string starts with remote link
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.remoteMemberCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 object name, index 2 member name.
	NSString *linkText = [components objectAtIndex:0];
	NSString *objectName = [components objectAtIndex:1];
	NSString *memberName = [components objectAtIndex:2];
	
	// Validate the link to match it to known object. If no known object is matched, warn, update search range and continue with remaining text. This is required so that we treat unknown objects as normal text later on and still catch proper references that may be hiding in the remainder.
	id referencedObject = [self.store classWithName:objectName];
	if (!referencedObject) {
		referencedObject = [self.store categoryWithName:objectName];
		if (!referencedObject) {
			referencedObject = [self.store protocolWithName:objectName];
			if (!referencedObject) {
				if (self.settings.warnOnInvalidCrossReference) GBLogWarn(@"Invalid %@ reference found near %@, unknown object!", linkText, self.sourceFileInfo);
				return nil;
			}
		}
	}
	
	// Ok, so we have found referenced object in store, now search the member. If member isn't recognized, warn, update search range and continue with remaining text. This is required so that we treat unknown members as normal text later on and still catch proper references in remainder.
	id referencedMember = [[referencedObject methods] methodBySelector:memberName];
	if (!referencedMember) {
		if (self.settings.warnOnInvalidCrossReference) GBLogWarn(@"Invalid %@ reference found near %@, unknown method!", linkText, self.sourceFileInfo);
		return nil;
	}
	
	// Right, we have valid reference to known remote member, create the link item, prepare range and return.
	NSString *stringValue = [linkText stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:stringValue];
	result.href = [self.settings htmlReferenceForObject:referencedMember fromSource:self.currentContext];
	result.context = referencedObject;
	result.member = referencedMember;
	result.isLocal = NO;
	*range = [string rangeOfString:linkText];
	return result;
}

- (id)localMemberLinkFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for local member cross reference. If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers. NOTE: Note that we can skip local member cross ref testing if no context (i.e. class, category or protocol) is given!
	NSParameterAssert(range != NULL);
	if (!self.currentContext) return nil;
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.localMemberCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 just the member selector.
	NSString *linkText = [components objectAtIndex:0];
	NSString *selector = [components objectAtIndex:1];
	
	// Validate the selector against the context. If context doesn't implement the method, exit.
	GBMethodData *referencedMethod = [[[self currentContext] methods] methodBySelector:selector];
	if (!referencedMethod) return nil;
	
	// Ok, we have valid method, return the link item.
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:selector];
	result.href = [self.settings htmlReferenceForObject:referencedMethod fromSource:self.currentContext];
	result.context = self.currentContext;
	result.member = referencedMethod;
	result.isLocal = YES;
	*range = [string rangeOfString:linkText];
	return result;
}

- (id)classLinkFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for class cross reference. If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers.
	NSParameterAssert(range != NULL);
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.objectCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 just the object name.
	NSString *linkText = [components objectAtIndex:0];
	NSString *objectName = [components objectAtIndex:1];
	
	// Validate the selector against the context. If context doesn't implement the method, exit.
	GBClassData *referencedObject = [self.store classWithName:objectName];
	if (!referencedObject) return nil;
	
	// Ok, we have valid method, return the link item.
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:objectName];
	result.href = [self.settings htmlReferenceForObject:referencedObject fromSource:self.currentContext];
	result.context = referencedObject;
	result.isLocal = (referencedObject == self.currentContext);
	*range = [string rangeOfString:linkText];
	return result;
}

- (id)categoryLinkFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for category cross reference. If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers.
	NSParameterAssert(range != NULL);
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.objectCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 just the object name.
	NSString *linkText = [components objectAtIndex:0];
	NSString *objectName = [components objectAtIndex:1];
	
	// Validate the selector against the context. If context doesn't implement the method, exit.
	GBCategoryData *referencedObject = [self.store categoryWithName:objectName];
	if (!referencedObject) return nil;
	
	// Ok, we have valid method, return the link item.
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:objectName];
	result.href = [self.settings htmlReferenceForObject:referencedObject fromSource:self.currentContext];
	result.context = referencedObject;
	result.isLocal = (referencedObject == self.currentContext);
	*range = [string rangeOfString:linkText];
	return result;
}

- (id)protocolLinkFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for protocol cross reference. If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers.
	NSParameterAssert(range != NULL);
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.objectCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 just the object name.
	NSString *linkText = [components objectAtIndex:0];
	NSString *objectName = [components objectAtIndex:1];
	
	// Validate the selector against the context. If context doesn't implement the method, exit.
	GBProtocolData *referencedObject = [self.store protocolWithName:objectName];
	if (!referencedObject) return nil;
	
	// Ok, we have valid method, return the link item.
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:objectName];
	result.href = [self.settings htmlReferenceForObject:referencedObject fromSource:self.currentContext];
	result.context = referencedObject;
	result.isLocal = (referencedObject == self.currentContext);
	*range = [string rangeOfString:linkText];
	return result;
}

- (id)urlLinkItemFromString:(NSString *)string range:(NSRange *)range {
	// Matches the beginning of the string for URL cross reference. If found, GBParagraphLinkItem is prepared and returned. NOTE: The range argument is used to return the range of all link text, including optional <> markers.
	NSParameterAssert(range != NULL);
	NSArray *components = [string captureComponentsMatchedByRegex:self.components.urlCrossReferenceRegex];
	if ([components count] == 0) return nil;
	
	// Get link components. Index 0 contains full text, including optional <>, index 1 just the URL address.
	NSString *linkText = [components objectAtIndex:0];
	NSString *address = [components objectAtIndex:1];
	
	// Create link item, prepare range and return.
	GBParagraphLinkItem *result = [GBParagraphLinkItem paragraphItemWithStringValue:address];
	result.href = address;
	*range = [string rangeOfString:linkText];
	return result;
}

#pragma mark Helper methods

- (void)registerParagraphItemToCurrentParagraph:(GBParagraphItem *)item {
	// Registers the given paragraph item to current paragraph. If there is no current paragraph, new one is created.
	if ([self.paragraphsStack isEmpty]) [self.paragraphsStack push:[GBCommentParagraph paragraph]];
	[[self.paragraphsStack peek] registerItem:item];
}

#pragma mark Properties

- (NSString *)sourceFileInfo {
	// Helper method for simplifiying logging of current line and source file information.
	return [NSString stringWithFormat:@"%@@%lu", self.currentComment.sourceInfo.filename, self.currentStartLine];
}

- (GBCommentComponentsProvider *)components {
	return self.settings.commentComponents;
}

@synthesize paragraphsStack;
@synthesize currentStartLine;
@synthesize currentComment;
@synthesize currentContext;
@synthesize settings;
@synthesize store;

@end
