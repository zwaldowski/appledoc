//
//  GBObjectiveCParser-SectionsParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.9.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBObjectiveCParser.h"

// Note that we use class for invoking parsing of methods. Probably not the best option - i.e. we could isolate method parsing code altogether and only parse relevant stuff here, but it seemed not much would be gained by doing this. Separating unit tests does avoid repetition in top-level objects testing code - we only need to test specific data there.

@interface GBObjectiveCParserMethodSectionsParsingTesting : GBObjectsAssertor
@end

@implementation GBObjectiveCParserMethodSectionsParsingTesting

- (void)testParseObjectsFromString_shouldRegisterMethodsToLastSection {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** @name Section1 */ /** */ -(id)method1; -(id)method2; @end" sourceFile:@"file" toStore:store];
	// verify
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	XCTAssertEqual(sections.count, (NSUInteger)1);
	GBMethodSectionData *section = [sections objectAtIndex:0];
	XCTAssertEqualObjects(section.sectionName, @"Section1");
	XCTAssertEqual([section methods].count, (NSUInteger)2);
	[self assertMethod:[[section methods] objectAtIndex:0] matchesInstanceComponents:@"id", @"method1", nil];
	[self assertMethod:[[section methods] objectAtIndex:1] matchesInstanceComponents:@"id", @"method2", nil];
}

- (void)testParseObjectsFromString_shouldRegisterUncommentedMethodsToLastSection {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** @name Section1 */ /** */ -(id)method1; /** */ -(id)method2; @end" sourceFile:@"file" toStore:store];
	// verify
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	XCTAssertEqual(sections.count, (NSUInteger)1);
	GBMethodSectionData *section = [sections objectAtIndex:0];
	XCTAssertEqualObjects(section.sectionName, @"Section1");
	XCTAssertEqual([section methods].count, (NSUInteger)2);
	[self assertMethod:[[section methods] objectAtIndex:0] matchesInstanceComponents:@"id", @"method1", nil];
	[self assertMethod:[[section methods] objectAtIndex:1] matchesInstanceComponents:@"id", @"method2", nil];
}

- (void)testParseObjectsFromString_shouldDetectLongSectionNames {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** @name Long section name */ /** */ -(id)method1; @end" sourceFile:@"file" toStore:store];
	// verify
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	XCTAssertEqual(sections.count, (NSUInteger)1);
	XCTAssertEqualObjects([[sections objectAtIndex:0] sectionName], @"Long section name");
}

- (void)testParseObjectsFromString_shouldDetectSectionNameOnlyIfAtStartOfComment {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** Some prefix @name Section */ /** */ -(id)method1; @end" sourceFile:@"file" toStore:store];
	// verify - note that we still create default section!
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	XCTAssertEqual(sections.count, (NSUInteger)1);
	XCTAssertNil([[sections objectAtIndex:0] sectionName]);
}

- (void)testParseObjectsFromString_shouldOnlyTakeSectionNameFromTheFirstLineString {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** @name\nSection\n\tspanning   multiple\n\n\n\nlines\rwhoa!    */ /** */ -(id)method1; @end" sourceFile:@"file" toStore:store];
	// verify
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	XCTAssertEqual(sections.count, (NSUInteger)1);
	XCTAssertEqualObjects([[sections objectAtIndex:0] sectionName], @"Section");
}

- (void)testParseObjectsFromString_requiresDetectsSectionEvenIfFollowedByUncommentedMethod {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** @name Section */ -(id)method1; @end" sourceFile:@"file" toStore:store];
	// verify
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	XCTAssertEqual(sections.count, (NSUInteger)1);
	GBMethodSectionData *section = [sections objectAtIndex:0];
	XCTAssertEqualObjects(section.sectionName, @"Section");
	XCTAssertEqual(section.methods.count, (NSUInteger)1);
	XCTAssertNil([[section.methods objectAtIndex:0] comment]);
}

- (void)testParseObjectsFromString_shouldDetectSectionAndCommentForNextCommentedMethod {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass /** @name Section1 */ /* First */ -(id)method1; /** Second */ -(id)method2; @end" sourceFile:@"file" toStore:store];
	// verify
	NSArray *sections = [[[[store classes] anyObject] methods] sections];
	XCTAssertEqual(sections.count, (NSUInteger)1);
	GBMethodSectionData *section = [sections objectAtIndex:0];
	XCTAssertEqualObjects(section.sectionName, @"Section1");
	XCTAssertEqual(section.methods.count, (NSUInteger)2);
	XCTAssertNil([[section.methods objectAtIndex:0] comment]);
	XCTAssertEqualObjects([(GBComment *)[[section.methods objectAtIndex:1] comment] stringValue], @"Second");
}

@end
