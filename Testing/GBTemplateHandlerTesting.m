//
//  GBTemplateHandlerTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 17.11.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GRMustache.h"
#import "GBTemplateHandler.h"

@interface GBTemplateHandler (TestingAPI)
@property (readonly) NSDictionary *templateSections;
@property (readonly) GRMustacheTemplate *template;
@end

@implementation GBTemplateHandler (TestingAPI)

- (NSDictionary *)templateSections { return [self valueForKey:@"_templateSections"]; }
- (GRMustacheTemplate *)template { return [self valueForKey:@"_template"]; }
@end

#pragma mark -

@interface GBTemplateHandlerTesting : XCTestCase
@end

@implementation GBTemplateHandlerTesting

#pragma mark Empty templates

- (void)testParseTemplate_empty_shouldIndicateSuccess {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	// execute
	BOOL result = [loader parseTemplate:@"" error:nil];
	// verify
	XCTAssertTrue(result);
	XCTAssertEqual(loader.templateSections.count, (NSUInteger)0);
	XCTAssertEqualObjects(loader.templateString, @"");
}

- (void)testParseTemplate_empty_shouldClearBeforeReading {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"Something Section name text EndSection" error:nil];
	// execute
	BOOL result = [loader parseTemplate:@"" error:nil];
	// verify
	XCTAssertTrue(result);
	XCTAssertEqualObjects(loader.templateString, @"");
	XCTAssertEqual(loader.templateSections.count, (NSUInteger)0);
}

#pragma mark Template sections

- (void)testParseTemplate_sections_shouldReadSimpleTemplateSection {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Section name text EndSection";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	XCTAssertTrue(result);
	XCTAssertEqual(loader.templateSections.count, (NSUInteger)1);
	XCTAssertEqualObjects([loader.templateSections objectForKey:@"name"], @"text");
}

- (void)testParseTemplateError_sections_shouldReadAllTemplateSections {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Prefix \n Section name1 text1 EndSection \n Intermediate \n Section name2 text2 EndSection \n Suffix";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	XCTAssertTrue(result);
	XCTAssertEqual(loader.templateSections.count, (NSUInteger)2);
	XCTAssertEqualObjects([loader.templateSections objectForKey:@"name1"], @"text1");
	XCTAssertEqualObjects([loader.templateSections objectForKey:@"name2"], @"text2");
}

- (void)testParseTemplate_sections_shouldReadComplexTemplateSectionValue {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Section name \nfirst line\nsecond line\nEndSection";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	XCTAssertTrue(result);
	XCTAssertEqual(loader.templateSections.count, (NSUInteger)1);
	XCTAssertEqualObjects([loader.templateSections objectForKey:@"name"], @"first line\nsecond line");
}

- (void)testParseTemplate_sections_shouldClearBeforeReading {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"Section name1 text1 EndSection" error:nil];
	// execute
	BOOL result = [loader parseTemplate:@"Section name2 text2 EndSection" error:nil];
	// verify
	XCTAssertTrue(result);
	XCTAssertEqual(loader.templateSections.count, (NSUInteger)1);
	XCTAssertNil([loader.templateSections objectForKey:@"name1"]);
	XCTAssertNotNil([loader.templateSections objectForKey:@"name2"]);
}

#pragma mark Template string

- (void)testParseTemplate_string_shouldCopyWholeTextIfNoTemplateSectionFound {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"This is template text";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	XCTAssertTrue(result);
	XCTAssertEqualObjects(loader.templateString, @"This is template text");
	XCTAssertEqual(loader.templateSections.count, (NSUInteger)0);
}

- (void)testParseTemplate_string_shouldTrimStringBeforeTemplateSections {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"This is template text Section name text EndSection";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	XCTAssertTrue(result);
	XCTAssertEqualObjects(loader.templateString, @"This is template text");
}

- (void)testParseTemplate_string_shouldTrimStringBetweenTemplateSections {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Section name1 text EndSection This is text in the middle Section name2 text EndSection";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	XCTAssertTrue(result);
	XCTAssertEqualObjects(loader.templateString, @"This is text in the middle");
}

- (void)testParseTemplate_string_shouldTrimStringAfterTemplateSections {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Section name text EndSection This is template text";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	XCTAssertTrue(result);
	XCTAssertEqualObjects(loader.templateString, @"This is template text");
}

#pragma mark Complex examples

- (void)testParseTemplate_complex_shouldHandleComplexStrings {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = 
		@"Some text\nin multiple lines\n\n"
		@"Section name1 text\nline2\n\nEndSection\n\n"
		@"Followed\nby middle\ntext\n\n"
		@"Section name2 text2\n\tline2 EndSection\n\n"
		@"And by some\n\tprefix\n\n\n";
	// execute
	BOOL result = [loader parseTemplate:template error:nil];
	// verify
	XCTAssertTrue(result);
	XCTAssertEqualObjects(loader.templateString, @"Some text\nin multiple lines\nFollowed\nby middle\ntext\nAnd by some\n\tprefix");
	XCTAssertEqual(loader.templateSections.count, (NSUInteger)2);
	XCTAssertEqualObjects([loader.templateSections objectForKey:@"name1"], @"text\nline2");
	XCTAssertEqualObjects([loader.templateSections objectForKey:@"name2"], @"text2\n\tline2");
}

#pragma mark Template handling

- (void)testParsetTemplate_template_shouldCreateTemplateInstance {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	NSString *template = @"Something Section name text EndSection";
	// execute
	[loader parseTemplate:template error:nil];
	// verify
	XCTAssertNotNil(loader.template);
}

- (void)testParseTemplate_template_shouldSetEmptyTemplateIfEmptyTemplateIsGiven {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	// execute
	[loader parseTemplate:@"" error:nil];
	// verify
	XCTAssertNil(loader.template);
}

- (void)testParseTemplate_template_shouldResetTemplateInstanceIfEmptyTemplateIsGiven {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"Something" error:nil];
	// execute
	[loader parseTemplate:@"" error:nil];
	// verify
	XCTAssertNil(loader.template);
}

#pragma mark Rendering handling (just simple testing, we rely on GRMustache for correct behavior!)

- (void)testRenderObject_shouldRenderSimpleTemplate {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"prefix {{var1}}---{{var2}} suffix" error:nil];
	// execute
	NSString *result = [loader renderObject:[NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"var1", @"value2", @"var2", nil]];
	// verify
	XCTAssertEqualObjects(result, @"prefix value1---value2 suffix");
}

- (void)testRenderObject_shouldRenderSectionIfCalled {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"prefix {{>name}}! Section name text EndSection" error:nil];
	// execute
	NSString *result = [loader renderObject:nil];
	// verify
	XCTAssertEqualObjects(result, @"prefix text!");
}

- (void)testRenderObject_shouldNotRenderSectionIfNotCalled {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"prefix Section name text EndSection" error:nil];
	// execute
	NSString *result = [loader renderObject:nil];
	// verify
	XCTAssertEqualObjects(result, @"prefix");
}

- (void)testRenderObject_shouldPassProperObjectToSections {
	// setup
	GBTemplateHandler *loader = [GBTemplateHandler handler];
	[loader parseTemplate:@"prefix {{#var1}}{{>name}}{{/var1}}! {{#var2}}{{>name}}{{/var2}}? Section name {{value}} EndSection" error:nil];
	NSDictionary *var1 = [NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"value", nil];
	NSDictionary *var2 = [NSDictionary dictionaryWithObjectsAndKeys:@"value2", @"value", nil];
	// execute
	NSString *result = [loader renderObject:[NSDictionary dictionaryWithObjectsAndKeys:var1, @"var1", var2, @"var2", nil]];
	// verify
	XCTAssertEqualObjects(result, @"prefix value1! value2?");
}

@end
