//
//  GBCommentTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"

@interface GBCommentTesting : XCTestCase
@end
	
@implementation GBCommentTesting

#pragma mark Initialization & disposal

- (void)testInit_shouldSetupDefaultComponents {
	// setup & execute
	GBComment *comment = [GBComment commentWithStringValue:@""];
	// verify
	XCTAssertNotNil(comment.longDescription);
	XCTAssertNotNil(comment.relatedItems);
	XCTAssertNotNil(comment.methodParameters);
	XCTAssertNotNil(comment.methodExceptions);
	XCTAssertNotNil(comment.methodResult);
	XCTAssertNotNil(comment.availability);
}

#pragma mark Comment components testing

- (void)testHtmlString_shouldUseAssignedSettings {
	// setup
	GBCommentComponent *component = [GBCommentComponent componentWithStringValue:@"source"];
	component.markdownValue = @"markdown";
	OCMockObject *settings = [GBTestObjectsRegistry mockSettingsProvider];
	component.settings = settings;
	[[settings expect] stringByConvertingMarkdownToHTML:component.markdownValue];
	// execute
    (void)component.htmlValue;
	// verify
	[settings verify];

}

- (void)testTextString_shouldUseAssignedSettings {
	// setup
	GBCommentComponent *component = [GBCommentComponent componentWithStringValue:@"source"];
	component.markdownValue = @"markdown";
	OCMockObject *settings = [GBTestObjectsRegistry mockSettingsProvider];
	component.settings = settings;
	[[settings expect] stringByConvertingMarkdownToText:component.markdownValue];
	// execute
	(void)component.textValue;
	// verify
	[settings verify];
}

@end
