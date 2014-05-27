//
//  GBDocumentDataTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 10.2.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBApplicationSettingsProvider.h"

@interface GBDocumentDataTesting : XCTestCase
@end

@implementation GBDocumentDataTesting

#pragma mark Initializers testing

- (void)testInitWithContentsData_shouldCreateCommentWithContentsAsStringValue {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
	// verify
	XCTAssertNotNil(document.comment);
	XCTAssertEqualObjects(document.comment.stringValue, @"contents");
}

- (void)testInitWithContentsData_shouldCreateSourceInfoUsingThePathAsFilename {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path/to/document.ext"];
	// verify
	XCTAssertEqual(document.sourceInfos.count, (NSUInteger)1);
	XCTAssertEqual([[document.sourceInfos anyObject] lineNumber], (NSInteger)1);
	XCTAssertEqualObjects([[document.sourceInfos anyObject] filename], @"document.ext");
}

- (void)testInitWithContentsData_shouldAssignNameOfDocument {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path/document.extension"];
	// verify
	XCTAssertEqualObjects(document.nameOfDocument, @"document.extension");
}

- (void)testInitWithContentsData_shouldAssignPathOfDocument {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path/document.extension"];
	// verify
	XCTAssertEqualObjects(document.pathOfDocument, @"path/document.extension");
}

#pragma mark Convenience methods testing

- (void)testSubpathOfDocument_shouldReturnProperValue {
	// setup & execute
	GBDocumentData *document1 = [GBDocumentData documentDataWithContents:@"c" path:@"document.ext" basePath:@""];
	GBDocumentData *document2 = [GBDocumentData documentDataWithContents:@"c" path:@"path/sub/document.ext" basePath:@""];
	GBDocumentData *document3 = [GBDocumentData documentDataWithContents:@"c" path:@"path/document.ext" basePath:@"path"];
	GBDocumentData *document4 = [GBDocumentData documentDataWithContents:@"c" path:@"path/sub/document.ext" basePath:@"path"];
	GBDocumentData *document5 = [GBDocumentData documentDataWithContents:@"c" path:@"path/sub/document.ext" basePath:@"path/sub"];
	// verify
	XCTAssertEqualObjects(document1.subpathOfDocument, @"document.ext");
	XCTAssertEqualObjects(document2.subpathOfDocument, @"path/sub/document.ext");
	XCTAssertEqualObjects(document3.subpathOfDocument, @"document.ext");
	XCTAssertEqualObjects(document4.subpathOfDocument, @"sub/document.ext");
	XCTAssertEqualObjects(document5.subpathOfDocument, @"document.ext");
}

#pragma mark Overriden methods

- (void)testIsStaticDocument_shouldReturnYES {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
	// verify
	XCTAssertTrue(document.isStaticDocument);
}

- (void)testIsTopLevelObject_shouldReturnNO {
	// setup & execute
	GBDocumentData *document = [GBDocumentData documentDataWithContents:@"contents" path:@"path"];
	// verify
	XCTAssertFalse(document.isTopLevelObject);
}

@end
