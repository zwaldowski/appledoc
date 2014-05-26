//
//  GBProtocolDataTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"

@interface GBProtocolDataTesting : XCTestCase
@end

@implementation GBProtocolDataTesting

- (void)testMergeDataFromObject_shouldMergeImplementationDetails {
	// setup - protocols don't merge any data, except they need to send base class merging message!
	GBProtocolData *original = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	GBProtocolData *source = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	[source registerSourceInfo:[GBSourceInfo infoWithFilename:@"file" lineNumber:1]];
	// execute
	[original mergeDataFromObject:source];
	// verify - simple testing here, fully tested in GBModelBaseTesting!
	XCTAssertEqual(original.sourceInfos.count, (NSUInteger)1);
}

- (void)testMergeDataFromObject_shouldMergeAdoptedProtocolsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBAdoptedProtocolsProviderTesting!
	GBProtocolData *original = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[original.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
	GBProtocolData *source = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[source.adoptedProtocols registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
	// execute
	[original mergeDataFromObject:source];
	// verify
	XCTAssertEqual([original.adoptedProtocols protocols].count, (NSUInteger)3);
	XCTAssertEqual([source.adoptedProtocols protocols].count, (NSUInteger)2);
}

- (void)testMergeDataFromObject_shouldMergeMethodsAndPreserveSourceData {
	//setup - only basic handling is done here; details are tested within GBIvarsProviderTesting!
	GBProtocolData *original = [GBProtocolData protocolDataWithName:@"MyProtocol"];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m1", nil]];
	[original.methods registerMethod:[GBTestObjectsRegistry instanceMethodWithNames:@"m2", nil]];
	GBProtocolData *source = [GBProtocolData protocolDataWithName:@"MyProtocol"];
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
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:@"Protocol"];
	// verify
	XCTAssertTrue(protocol.isTopLevelObject);
}

@end
