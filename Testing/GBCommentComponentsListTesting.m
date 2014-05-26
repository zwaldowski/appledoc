//
//  GBCommentComponentsListTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.2.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"

@interface GBCommentComponentsListTesting : XCTestCase
@end
	
@implementation GBCommentComponentsListTesting

#pragma mark Initialization & disposal

- (void)testInit_shouldInitializeEmptyList {
	// setup & execute
	GBCommentComponentsList *list = [[GBCommentComponentsList alloc] init];
	// verify
	XCTAssertNotNil(list.components);
	XCTAssertEqual(list.components.count, (NSUInteger)0);
}

#pragma mark Registration testing

- (void)testRegisterComponent_shouldAddComponentToComponentsArray {
	// setup
	GBCommentComponentsList *list = [[GBCommentComponentsList alloc] init];
	// execute
	[list registerComponent:[GBCommentComponent componentWithStringValue:@"a"]];
	// verify
	XCTAssertEqual(list.components.count, (NSUInteger)1);
	XCTAssertEqualObjects([[list.components objectAtIndex:0] stringValue], @"a");
}

- (void)testRegisterComponent_shouldAddComponentsToArrayInOrder {
	// setup
	GBCommentComponentsList *list = [[GBCommentComponentsList alloc] init];
	// execute
	[list registerComponent:[GBCommentComponent componentWithStringValue:@"a"]];
	[list registerComponent:[GBCommentComponent componentWithStringValue:@"b"]];
	[list registerComponent:[GBCommentComponent componentWithStringValue:@"c"]];
	// verify
	XCTAssertEqual(list.components.count, (NSUInteger)3);
	XCTAssertEqualObjects([[list.components objectAtIndex:0] stringValue], @"a");
	XCTAssertEqualObjects([[list.components objectAtIndex:1] stringValue], @"b");
	XCTAssertEqualObjects([[list.components objectAtIndex:2] stringValue], @"c");
}

@end
