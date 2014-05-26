//
//  GBCategoryDataTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"

@interface GBCategoryDataTesting : XCTestCase
@end

@implementation GBCategoryDataTesting

#pragma mark Derived members testing

- (void)testCategoryID_shouldReturnProperValue {
	// setup
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:@"Class"];
	// execute & verify
	XCTAssertEqualObjects(category.idOfCategory, @"Class(Category)");
	XCTAssertEqualObjects(extension.idOfCategory, @"Class()");
}

#pragma mark Base data merging

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
	// setup
	GBCategoryData *original = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
	GBCategoryData *source = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
	[source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file" lineNumber:1]];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, fully tested in GBModelBaseTesting!
	XCTAssertEqual(original.sourceInfos.count, (NSUInteger)1);
}

#pragma mark Category components merging

- (void)testMergeDataFromObject_categoryShouldMergeAdoptedProtocolsAndPreserveSourceData {
	// setup - only basic handling is done here; details are tested within GBAdoptedProtocolsProviderTesting!
	GBCategoryData *original = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
	GBCategoryData *source = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqual([original.adoptedProtocols protocols].count, (NSUInteger)3);
	XCTAssertEqual([source.adoptedProtocols protocols].count, (NSUInteger)2);
}

- (void)testMergeDataFromObject_categoryShouldMergeMethodsAndPreserveSourceData {
	// setup - only basic handling is done here; details are tested within GBIvarsProviderTesting!
	GBCategoryData *original = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	GBCategoryData *source = [GBCategoryData categoryDataWithName:@"MyCategory" className:@"MyClass"];
	[source.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[source.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m3", nil]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqual([original.methods methods].count, (NSUInteger)3);
	XCTAssertEqual([source.methods methods].count, (NSUInteger)2);
}

#pragma mark Extension components merging

- (void)testMergeDataFromObject_extensionShouldMergeAdoptedProtocolsAndPreserveSourceData {
	// setup - only basic handling is done here; details are tested within GBAdoptedProtocolsProviderTesting!
	GBCategoryData *original = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
	GBCategoryData *source = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqual([original.adoptedProtocols protocols].count, (NSUInteger)3);
	XCTAssertEqual([source.adoptedProtocols protocols].count, (NSUInteger)2);
}

- (void)testMergeDataFromObject_extensionShouldMergeMethodsAndPreserveSourceData {
	// setup - only basic handling is done here; details are tested within GBIvarsProviderTesting!
	GBCategoryData *original = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	GBCategoryData *source = [GBCategoryData categoryDataWithName:nil className:@"MyClass"];
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
	GBCategoryData *category = [GBCategoryData categoryDataWithName:@"Category" className:@"Class"];
	// verify
	XCTAssertTrue(category.isTopLevelObject);
}

@end
