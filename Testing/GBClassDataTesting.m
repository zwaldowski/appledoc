//
//  GBClassDataTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"

@interface GBClassDataTesting : XCTestCase
@end

@implementation GBClassDataTesting

#pragma mark Base data merging

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
	//setup
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	[source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file" lineNumber:1]];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, fully tested in GBModelBaseTesting!
	XCTAssertEqual(original.sourceInfos.count, (NSUInteger)1);
}

#pragma mark Superclass data merging

- (void)testMergeDataFromObject_shouldMergeSuperclass {
	//setup
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	source.nameOfSuperclass = @"NSObject";
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqualObjects(original.nameOfSuperclass, @"NSObject");
	XCTAssertEqualObjects(source.nameOfSuperclass, @"NSObject");
}

- (void)testMergeDataFromObject_shouldPreserveSourceSuperclass {
	//setup
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	source.nameOfSuperclass = @"NSObject";
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqualObjects(source.nameOfSuperclass, @"NSObject");
}

- (void)testMergeDataFromObject_shouldLeaveOriginalSuperclassIfDifferent {
	//setup
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	original.nameOfSuperclass = @"C1";
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	source.nameOfSuperclass = @"C2";
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqualObjects(original.nameOfSuperclass, @"C1");
	XCTAssertEqualObjects(source.nameOfSuperclass, @"C2");
}

#pragma mark Components merging

- (void)testMergeDataFromObject_shouldMergeAdoptedProtocolsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBAdoptedProtocolsProviderTesting!
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqual([original.adoptedProtocols protocols].count, (NSUInteger)3);
	XCTAssertEqual([source.adoptedProtocols protocols].count, (NSUInteger)2);
}

- (void)testMergeDataFromObject_shouldMergeIvarsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBIvarsProviderTesting!
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	[original.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[original.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i2", nil]];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	[source.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[source.ivars registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i3", nil]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqual([original.ivars ivars].count, (NSUInteger)3);
	XCTAssertEqual([source.ivars ivars].count, (NSUInteger)2);
}

- (void)testMergeDataFromObject_shouldMergeMethodsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBIvarsProviderTesting!
	GBClassData *original = [GBClassData classDataWithName:@"MyClass"];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	GBClassData *source = [GBClassData classDataWithName:@"MyClass"];
	[source.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[source.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqual([original.methods methods].count, (NSUInteger)3);
	XCTAssertEqual([source.methods methods].count, (NSUInteger)2);
}

#pragma mark Helper methods

- (void)testIsTopLevelObject_shouldReturnYES {
	// setup & execute
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	// verify
	XCTAssertTrue(class.isTopLevelObject);
}

@end
