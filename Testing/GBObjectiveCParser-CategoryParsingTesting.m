//
//  GBObjectiveCParser-CategoryParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBObjectiveCParser.h"

// Note that we're only testing category specific stuff here - i.e. all common parsing modules (adopted protocols, methods...) are tested separately to avoid repetition.

@interface GBObjectiveCParserCategoryParsingTesting : GBObjectsAssertor
@end

@implementation GBObjectiveCParserCategoryParsingTesting

#pragma mark Categories definition data parsing testing

- (void)testParseObjectsFromString_shouldRegisterCategoryDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass (MyCategory) @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *categories = [store categoriesSortedByName];
	XCTAssertEqual(categories.count, (NSUInteger)1);
	XCTAssertEqualObjects([[categories objectAtIndex:0] nameOfClass], @"MyClass");
	XCTAssertEqualObjects([[categories objectAtIndex:0] nameOfCategory], @"MyCategory");
}

- (void)testParseObjectsFromString_shouldRegisterCategoryDefinitionSourceFileAndLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory) @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store categoriesSortedByName] objectAtIndex:0] sourceInfos];
	XCTAssertEqual(files.count, (NSUInteger)1);
	XCTAssertEqualObjects([[files anyObject] filename], @"filename.h");
	XCTAssertEqual([[files anyObject] lineNumber], (NSInteger)1);
}

- (void)testParseObjectsFromString_shouldRegisterCategoryDefinitionProperSourceLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"\n// cmt\n\n#define DEBUG\n\n/// hello\n@interface MyClass(MyCategory) @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store categoriesSortedByName] objectAtIndex:0] sourceInfos];
	XCTAssertEqual([[files anyObject] lineNumber], (NSInteger)7);
}

- (void)testParseObjectsFromString_shouldRegisterAllCategoryDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory1) @end   @interface MyClass(MyCategory2) @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *categories = [store categoriesSortedByName];
	XCTAssertEqual(categories.count, (NSUInteger)2);
	XCTAssertEqualObjects([[categories objectAtIndex:0] nameOfCategory], @"MyCategory1");
	XCTAssertEqualObjects([[categories objectAtIndex:1] nameOfCategory], @"MyCategory2");
}

#pragma mark Categories declaration data parsing testing

- (void)testParseObjectsFromString_shouldRegisterCategoryDeclaration {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass (MyCategory) @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *categories = [store categoriesSortedByName];
	XCTAssertEqual(categories.count, (NSUInteger)1);
	XCTAssertEqualObjects([[categories objectAtIndex:0] nameOfClass], @"MyClass");
	XCTAssertEqualObjects([[categories objectAtIndex:0] nameOfCategory], @"MyCategory");
}

- (void)testParseObjectsFromString_shouldRegisterCategoryDeclarationSourceFileAndLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass(MyCategory) @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store categoriesSortedByName] objectAtIndex:0] sourceInfos];
	XCTAssertEqual(files.count, (NSUInteger)1);
	XCTAssertEqualObjects([[files anyObject] filename], @"filename.h");
	XCTAssertEqual([[files anyObject] lineNumber], (NSInteger)1);
}

- (void)testParseObjectsFromString_shouldRegisterCategoryDeclarationProperSourceLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"\n// cmt\n\n#define DEBUG\n\n/// hello\n@implementation MyClass(MyCategory) @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store categoriesSortedByName] objectAtIndex:0] sourceInfos];
	XCTAssertEqual([[files anyObject] lineNumber], (NSInteger)7);
}

- (void)testParseObjectsFromString_shouldRegisterAllCategoryDeclaration {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass(MyCategory1) @end   @implementation MyClass(MyCategory2) @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *categories = [store categoriesSortedByName];
	XCTAssertEqual(categories.count, (NSUInteger)2);
	XCTAssertEqualObjects([[categories objectAtIndex:0] nameOfCategory], @"MyCategory1");
	XCTAssertEqualObjects([[categories objectAtIndex:1] nameOfCategory], @"MyCategory2");
}

#pragma mark Extensions common data parsing testing

- (void)testParseObjectsFromString_shouldRegisterExtensionDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass () @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *categories = [store categoriesSortedByName];
	XCTAssertEqual(categories.count, (NSUInteger)1);
	XCTAssertEqualObjects([[categories objectAtIndex:0] nameOfClass], @"MyClass");
	XCTAssertNil([[categories objectAtIndex:0] nameOfCategory]);
}

- (void)testParseObjectsFromString_shouldRegisterExtensionSourceFileAndLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass() @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store categoriesSortedByName] objectAtIndex:0] sourceInfos];
	XCTAssertEqual(files.count, (NSUInteger)1);
	XCTAssertEqualObjects([[files anyObject] filename], @"filename.h");
	XCTAssertEqual([[files anyObject] lineNumber], (NSInteger)1);
}

- (void)testParseObjectsFromString_shouldRegisterExtensionProperSourceLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"\n// cmt\n\n#define DEBUG\n\n/// hello\n@interface MyClass() @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSSet *files = [[[store categoriesSortedByName] objectAtIndex:0] sourceInfos];
	XCTAssertEqual([[files anyObject] lineNumber], (NSInteger)7);
}

- (void)testParseObjectsFromString_shouldRegisterAllExtensionDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass1() @end   @interface MyClass2() @end" sourceFile:@"filename.h" toStore:store];
	// verify
	NSArray *categories = [store categoriesSortedByName];
	XCTAssertEqual(categories.count, (NSUInteger)2);
	XCTAssertEqualObjects([[categories objectAtIndex:0] nameOfClass], @"MyClass1");
	XCTAssertEqualObjects([[categories objectAtIndex:1] nameOfClass], @"MyClass2");
}

#pragma mark Category comments parsing testing

- (void)testParseObjectsFromString_shouldRegisterCategoryDefinitionComment {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/** Comment */ @interface MyClass(MyCategory) @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBCategoryData *category = [[store categories] anyObject];
	XCTAssertEqualObjects(category.comment.stringValue, @"Comment");
}

- (void)testParseObjectsFromString_shouldRegisterCategoryDeclarationComment {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/** Comment */ @implementation MyClass(MyCategory) @end" sourceFile:@"filename.m" toStore:store];
	// verify
	GBCategoryData *category = [[store categories] anyObject];
	XCTAssertEqualObjects(category.comment.stringValue, @"Comment");
}

- (void)testParseObjectsFromString_shouldRegisterExtensionDefinitionComment {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/** Comment */ @interface MyClass() @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBCategoryData *category = [[store categories] anyObject];
	XCTAssertEqualObjects(category.comment.stringValue, @"Comment");
}

- (void)testParseObjectsFromString_shouldRegisterCategoryDefinitionCommentSourceFileAndLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n/** comment */ @interface MyClass(MyCategory) @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *category = [[store categories] anyObject];
	XCTAssertEqualObjects(category.comment.sourceInfo.filename, @"filename.h");
	XCTAssertEqual(category.comment.sourceInfo.lineNumber, (NSInteger)5);
}

- (void)testParseObjectsFromString_shouldRegisterCategoryDeclarationCommentProperSourceLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n/** comment */ @implementation MyClass(MyCategory) @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *category = [[store categories] anyObject];
	XCTAssertEqualObjects(category.comment.sourceInfo.filename, @"filename.h");
	XCTAssertEqual(category.comment.sourceInfo.lineNumber, (NSInteger)5);
}

- (void)testParseObjectsFromString_shouldRegisterExtensionDefinitionCommentSourceFileAndLineNumber {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/// comment\n\n#define SOMETHING\n\n/** comment */ @interface MyClass() @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBClassData *category = [[store categories] anyObject];
	XCTAssertEqualObjects(category.comment.sourceInfo.filename, @"filename.h");
	XCTAssertEqual(category.comment.sourceInfo.lineNumber, (NSInteger)5);
}

- (void)testParseObjectsFromString_shouldRegisterCategoryDefinitionCommentForComplexDeclarations {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:
	 @"/** Comment */\n"
	 @"#ifdef SOMETHING\n"
	 @"@interface MyClass (MyCategory)\n"
	 @"#else\n"
	 @"@interface MyClass (MyCategory1)\n"
	 @"#endif\n"
	 @"@end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBCategoryData *category = [store.categories anyObject];
	XCTAssertEqualObjects(category.nameOfClass, @"MyClass");
	XCTAssertEqualObjects(category.nameOfCategory, @"MyCategory");
	XCTAssertEqualObjects(category.comment.stringValue, @"Comment");
}

- (void)testParseObjectsFromString_shouldProperlyResetComments { 
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"/** Comment */ @interface MyClass(MyCategory) -(void)method; @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBCategoryData *category = [store.categories anyObject];
	GBMethodData *method = [category.methods.methods lastObject];
	XCTAssertNil(method.comment);
}

#pragma mark Category definition components parsing testing

- (void)testParseObjectsFromString_shouldRegisterCategoryAdoptedProtocols {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory) <Protocol> @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBCategoryData *category = [[store categories] anyObject];
	NSArray *protocols = [category.adoptedProtocols protocolsSortedByName];
	XCTAssertEqual(protocols.count, (NSUInteger)1);
	XCTAssertEqualObjects([[protocols objectAtIndex:0] nameOfProtocol], @"Protocol");
}

- (void)testParseObjectsFromString_shouldRegisterCategoryMethods {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory) -(void)method; @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBCategoryData *category = [[store categories] anyObject];
	NSArray *methods = [category.methods methods];
	XCTAssertEqual(methods.count, (NSUInteger)1);
	XCTAssertEqualObjects([[methods objectAtIndex:0] methodSelector], @"method");
}

- (void)testParseObjectsFromString_shouldRegisterCategoryProperties {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory) @property (readonly) int name; @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBCategoryData *category = [[store categories] anyObject];
	NSArray *methods = [category.methods methods];
	XCTAssertEqual(methods.count, (NSUInteger)1);
	XCTAssertEqualObjects([[methods objectAtIndex:0] methodSelector], @"name");
}

#pragma mark Extension definition components parsing testing

- (void)testParseObjectsFromString_shouldRegisterExtensionAdoptedProtocols {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory) <Protocol> @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBCategoryData *extension = [[store categories] anyObject];
	NSArray *protocols = [extension.adoptedProtocols protocolsSortedByName];
	XCTAssertEqual(protocols.count, (NSUInteger)1);
	XCTAssertEqualObjects([[protocols objectAtIndex:0] nameOfProtocol], @"Protocol");
}

- (void)testParseObjectsFromString_shouldRegisterExtensionMethods {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory) -(void)method; @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBCategoryData *extension = [[store categories] anyObject];
	NSArray *methods = [extension.methods methods];
	XCTAssertEqual(methods.count, (NSUInteger)1);
	XCTAssertEqualObjects([[methods objectAtIndex:0] methodSelector], @"method");
}

- (void)testParseObjectsFromString_shouldRegisterExtensionProperties {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory) @property (readonly) int name; @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBCategoryData *extension = [[store categories] anyObject];
	NSArray *methods = [extension.methods methods];
	XCTAssertEqual(methods.count, (NSUInteger)1);
	XCTAssertEqualObjects([[methods objectAtIndex:0] methodSelector], @"name");
}

#pragma mark Category declaration components parsing testing

- (void)testParseObjectsFromString_shouldRegisterCategoryMethodDeclarations {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass(MyCategory) -(void)method { } @end" sourceFile:@"filename.h" toStore:store];
	// verify
	GBCategoryData *category = [[store categories] anyObject];
	NSArray *methods = [category.methods methods];
	XCTAssertEqual(methods.count, (NSUInteger)1);
	XCTAssertEqualObjects([[methods objectAtIndex:0] methodSelector], @"method");
}

#pragma mark Category merging testing

- (void)testParseObjectsFromString_shouldMergeCategoryDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory) -(void)method1; @end" sourceFile:@"filename1.h" toStore:store];
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory) -(void)method2; @end" sourceFile:@"filename2.h" toStore:store];
	// verify - simple testing here, details within GBModelBaseTesting!
	XCTAssertEqual([store categories].count, (NSUInteger)1);
	GBClassData *category = [[store categories] anyObject];
	NSArray *methods = [category.methods methods];
	XCTAssertEqual(methods.count, (NSUInteger)2);
	XCTAssertEqualObjects([[methods objectAtIndex:0] methodSelector], @"method1");
	XCTAssertEqualObjects([[methods objectAtIndex:1] methodSelector], @"method2");
}

- (void)testParseObjectsFromString_shouldMergeCategoryDeclarations {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@implementation MyClass(MyCategory) -(void)method1{} @end" sourceFile:@"filename1.m" toStore:store];
	[parser parseObjectsFromString:@"@implementation MyClass(MyCategory) -(void)method2{} @end" sourceFile:@"filename2.m" toStore:store];
	// verify - simple testing here, details within GBModelBaseTesting!
	XCTAssertEqual([store categories].count, (NSUInteger)1);
	GBClassData *category = [[store categories] anyObject];
	NSArray *methods = [category.methods methods];
	XCTAssertEqual(methods.count, (NSUInteger)2);
	XCTAssertEqualObjects([[methods objectAtIndex:0] methodSelector], @"method1");
	XCTAssertEqualObjects([[methods objectAtIndex:1] methodSelector], @"method2");
}

- (void)testParseObjectsFromString_shouldMergeCategoryDefinitionAndDeclaration {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass(MyCategory) -(void)method1; @end" sourceFile:@"filename.h" toStore:store];
	[parser parseObjectsFromString:@"@implementation MyClass(MyCategory) -(void)method2{} @end" sourceFile:@"filename.m" toStore:store];
	// verify - simple testing here, details within GBModelBaseTesting!
	XCTAssertEqual([store categories].count, (NSUInteger)1);
	GBClassData *category = [[store categories] anyObject];
	NSArray *methods = [category.methods methods];
	XCTAssertEqual(methods.count, (NSUInteger)2);
	XCTAssertEqualObjects([[methods objectAtIndex:0] methodSelector], @"method1");
	XCTAssertEqualObjects([[methods objectAtIndex:1] methodSelector], @"method2");
}

#pragma mark Extension merging testing

- (void)testParseObjectsFromString_shouldMergeExtensionDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass() -(void)method1; @end" sourceFile:@"filename1.h" toStore:store];
	[parser parseObjectsFromString:@"@interface MyClass() -(void)method2; @end" sourceFile:@"filename2.h" toStore:store];
	// verify - simple testing here, details within GBModelBaseTesting!
	XCTAssertEqual([store categories].count, (NSUInteger)1);
	GBCategoryData *category = [[store categories] anyObject];
	NSArray *methods = [category.methods methods];
	XCTAssertEqual(methods.count, (NSUInteger)2);
	XCTAssertEqualObjects([[methods objectAtIndex:0] methodSelector], @"method1");
	XCTAssertEqualObjects([[methods objectAtIndex:1] methodSelector], @"method2");
}

#pragma mark Complex parsing testing

- (void)testParseObjectsFromString_shouldRegisterCategoryAndExtensionFromRealLifeHeaderInput {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:[GBRealLifeDataProvider headerWithClassCategoryAndProtocol] sourceFile:@"filename.h" toStore:store];
	// verify - we're not going into details here, just checking that top-level objects were properly parsed!
	NSArray *categories = [store categoriesSortedByName];
	XCTAssertEqual(categories.count, (NSUInteger)2);
	XCTAssertEqualObjects([[categories objectAtIndex:0] nameOfClass], @"GBCalculator");
	XCTAssertNil([[categories objectAtIndex:0] nameOfCategory]);
	XCTAssertEqualObjects([[categories objectAtIndex:1] nameOfClass], @"GBCalculator");
	XCTAssertEqualObjects([[categories objectAtIndex:1] nameOfCategory], @"Multiplication");
}

- (void)testParseObjectsFromString_shouldRegisterCategoryFromRealLifeCodeInput {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:[GBRealLifeDataProvider codeWithClassAndCategory] sourceFile:@"filename.m" toStore:store];
	// verify - we're not going into details here, just checking that top-level objects were properly parsed!
	XCTAssertEqual([store categories].count, (NSUInteger)1);
	GBCategoryData *category = [[store categories] anyObject];
	XCTAssertEqualObjects([category nameOfClass], @"GBCalculator");
	XCTAssertEqualObjects([category nameOfCategory], @"Multiplication");
	XCTAssertEqual(category.methods.methods.count, (NSUInteger)1);
}

@end
