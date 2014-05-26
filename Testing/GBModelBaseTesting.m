//
//  GBModelBaseTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"

@interface GBModelBaseTesting : XCTestCase
@end

@implementation GBModelBaseTesting

#pragma mark Common merging testing

- (void)testMergeDataFromObject_shouldMergeDeclaredFiles {
	// setup
	GBModelBase *original = [[GBModelBase alloc] init];
	[original registerSourceInfo:[GBSourceInfo infoWithFilename:@"f1" lineNumber:1]];
	[original registerSourceInfo:[GBSourceInfo infoWithFilename:@"f2" lineNumber:2]];
	GBModelBase *source = [[GBModelBase alloc] init];
	[source registerSourceInfo:[GBSourceInfo infoWithFilename:@"f1" lineNumber:3]];
	[source registerSourceInfo:[GBSourceInfo infoWithFilename:@"f3" lineNumber:4]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	NSArray *files = [original sourceInfosSortedByName];
	XCTAssertEqual(files.count, (NSUInteger)3);
	XCTAssertEqualObjects([[files objectAtIndex:0] filename], @"f1");
	XCTAssertEqualObjects([[files objectAtIndex:1] filename], @"f2");
	XCTAssertEqualObjects([[files objectAtIndex:2] filename], @"f3");
	XCTAssertEqual([[files objectAtIndex:0] lineNumber], (NSInteger)3);
	XCTAssertEqual([[files objectAtIndex:1] lineNumber], (NSInteger)2);
	XCTAssertEqual([[files objectAtIndex:2] lineNumber], (NSInteger)4);
}

- (void)testMergeDataFromObject_shouldPreserveSourceDeclaredFiles {
	// setup
	GBModelBase *original = [[GBModelBase alloc] init];
	[original registerSourceInfo:[GBSourceInfo infoWithFilename:@"f1" lineNumber:4]];
	 [original registerSourceInfo:[GBSourceInfo infoWithFilename:@"f2" lineNumber:3]];
	GBModelBase *source = [[GBModelBase alloc] init];
	 [source registerSourceInfo:[GBSourceInfo infoWithFilename:@"f1" lineNumber:2]];
	 [source registerSourceInfo:[GBSourceInfo infoWithFilename:@"f3" lineNumber:1]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	NSArray *files = [source sourceInfosSortedByName];
	XCTAssertEqual(files.count, (NSUInteger)2);
	XCTAssertEqualObjects([[files objectAtIndex:0] filename], @"f1");
	XCTAssertEqualObjects([[files objectAtIndex:1] filename], @"f3");
	XCTAssertEqual([[files objectAtIndex:0] lineNumber], (NSInteger)2);
	XCTAssertEqual([[files objectAtIndex:1] lineNumber], (NSInteger)1);
}

#pragma mark Comments merging handling

- (void)testMergeDataFromObject_shouldUseOriginalCommentIfSourceIsNotGiven {
	// setup
	GBModelBase *original = [[GBModelBase alloc] init];
	original.comment = [GBComment commentWithStringValue:@"Comment"];
	GBModelBase *source = [[GBModelBase alloc] init];
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqualObjects(original.comment.stringValue, @"Comment");
	XCTAssertNil(source.comment.stringValue);
}

- (void)testMergeDataFromObject_shouldUseSourceCommentIfOriginalIsNotGiven {
	// setup
	GBModelBase *original = [[GBModelBase alloc] init];
	GBModelBase *source = [[GBModelBase alloc] init];
	source.comment = [GBComment commentWithStringValue:@"Comment"];
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqualObjects(original.comment.stringValue, @"Comment");
	XCTAssertEqualObjects(source.comment.stringValue, @"Comment");
}

- (void)testMergeDataFromObject_shouldKeepOriginalCommentIfBothObjectsHaveComments {
	// setup
	GBModelBase *original = [[GBModelBase alloc] init];
	original.comment = [GBComment commentWithStringValue:@"Comment1"];
	GBModelBase *source = [[GBModelBase alloc] init];
	source.comment = [GBComment commentWithStringValue:@"Comment2"];
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqualObjects(original.comment.stringValue, @"Comment1");
	XCTAssertEqualObjects(source.comment.stringValue, @"Comment2");
}

#pragma mark Source information testing

- (void)testPrefferedSourceInfo_shouldReturnSourceInfoFromComment {
	// setup
	GBModelBase *object = [[GBModelBase alloc] init];
	object.comment = [GBComment commentWithStringValue:@"comment"];
	object.comment.sourceInfo = [GBSourceInfo infoWithFilename:@"file1" lineNumber:1];
	[object registerSourceInfo:[GBSourceInfo infoWithFilename:@"file.h" lineNumber:1]];
	// execute & verify
	XCTAssertEqualObjects(object.prefferedSourceInfo, object.comment.sourceInfo);
}

- (void)testPrefferedSourceInfo_shouldReturnHeaderFileSourceInfoIfCommentNotGiven {
	// setup
	GBModelBase *object = [[GBModelBase alloc] init];
	[object registerSourceInfo:[GBSourceInfo infoWithFilename:@"a.m" lineNumber:1]];
	[object registerSourceInfo:[GBSourceInfo infoWithFilename:@"b.h" lineNumber:1]];
	// execute & verify
	XCTAssertEqualObjects(object.prefferedSourceInfo.filename, @"b.h");
}
			   
- (void)testPrefferedSourceInfo_shouldReturnHeaderFileSourceInfoIfCommentDoesntHaveSourceInfo {
	// setup
	GBModelBase *object = [[GBModelBase alloc] init];
	object.comment = [GBComment commentWithStringValue:@"comment"];
	[object registerSourceInfo:[GBSourceInfo infoWithFilename:@"a.m" lineNumber:1]];
	[object registerSourceInfo:[GBSourceInfo infoWithFilename:@"b.h" lineNumber:1]];
	// execute & verify
	XCTAssertEqualObjects(object.prefferedSourceInfo.filename, @"b.h");
}

- (void)testPrefferedSourceInfo_shouldReturnSingleSourceInfo {
	// setup
	GBModelBase *object = [[GBModelBase alloc] init];
	[object registerSourceInfo:[GBSourceInfo infoWithFilename:@"a.m" lineNumber:1]];
	// execute & verify
	XCTAssertEqualObjects(object.prefferedSourceInfo.filename, @"a.m");
}

- (void)testPrefferedSourceInfo_shouldReturnNilIfNoSourceInfoAvailable {
	// setup
	GBModelBase *object = [[GBModelBase alloc] init];
	// execute & verify
	XCTAssertNil(object.prefferedSourceInfo);
}

@end
