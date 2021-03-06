//
//  GBAdoptedProtocolsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBProtocolData.h"
#import "GBAdoptedProtocolsProvider.h"

@interface GBAdoptedProtocolsProviderTesting : XCTestCase
@end

@implementation GBAdoptedProtocolsProviderTesting

#pragma mark Protocol registration testing

- (void)testRegisterProtocol_shouldAddProtocolToList {
	// setup
	GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	GBProtocolData *protocol = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	// execute
	[provider registerProtocol:protocol];
	// verify
	XCTAssertTrue([provider.protocols containsObject:protocol]);
	XCTAssertEqual([provider.protocols allObjects].count, (NSUInteger)1);
	XCTAssertEqualObjects([[provider.protocols allObjects] objectAtIndex:0], protocol);
}

- (void)testRegisterProtocol_shouldIgnoreSameInstance {
	// setup
	GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	GBProtocolData *protocol = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	// execute
	[provider registerProtocol:protocol];
	[provider registerProtocol:protocol];
	// verify
	XCTAssertEqual([provider.protocols allObjects].count, (NSUInteger)1);
}

- (void)testRegisterProtocol_shouldMergeDifferentInstanceWithSameName {
	// setup
	GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	GBProtocolData *source = [[GBProtocolData alloc] initWithName:@"MyProtocol"];
	OCMockObject *original = [OCMockObject niceMockForClass:[GBProtocolData class]];
	[[[original stub] andReturn:@"MyProtocol"] nameOfProtocol];
	[[original expect] mergeDataFromObject:source];
	[provider registerProtocol:(GBProtocolData *)original];
	// execute
	[provider registerProtocol:source];
	// verify
	[original verify];
}

#pragma mark Protocol merging handling

- (void)testMergeDataFromProtocolProvider_shouldMergeAllDifferentProtocols {
	// setup
	GBAdoptedProtocolsProvider *original = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	[original registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[original registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
	GBAdoptedProtocolsProvider *source = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	[source registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[source registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
	// execute
	[original mergeDataFromProtocolsProvider:source];
	// verify - only basic verification here, details within GBProtocolDataTesting!
	NSArray *protocols = [original protocolsSortedByName];
	XCTAssertEqual(protocols.count, (NSUInteger)3);
	XCTAssertEqualObjects([[protocols objectAtIndex:0] nameOfProtocol], @"P1");
	XCTAssertEqualObjects([[protocols objectAtIndex:1] nameOfProtocol], @"P2");
	XCTAssertEqualObjects([[protocols objectAtIndex:2] nameOfProtocol], @"P3");
}

- (void)testMergeDataFromProtocolProvider_shouldPreserveSourceData {
	// setup
	GBAdoptedProtocolsProvider *original = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	[original registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[original registerProtocol:[GBProtocolData protocolDataWithName:@"P2"]];
	GBAdoptedProtocolsProvider *source = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	[source registerProtocol:[GBProtocolData protocolDataWithName:@"P1"]];
	[source registerProtocol:[GBProtocolData protocolDataWithName:@"P3"]];
	// execute
	[original mergeDataFromProtocolsProvider:source];
	// verify - only basic verification here, details within GBProtocolDataTesting!
	NSArray *protocols = [source protocolsSortedByName];
	XCTAssertEqual(protocols.count, (NSUInteger)2);
	XCTAssertEqualObjects([[protocols objectAtIndex:0] nameOfProtocol], @"P1");
	XCTAssertEqualObjects([[protocols objectAtIndex:1] nameOfProtocol], @"P3");
}

#pragma mark Protocols replacing handling

- (void)testReplaceProtocolWithProtocol_shouldReplaceObjects {
	// setup
	GBAdoptedProtocolsProvider *provider = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
	GBProtocolData *protocol1 = [GBProtocolData protocolDataWithName:@"P1"];
	GBProtocolData *protocol2 = [GBProtocolData protocolDataWithName:@"P2"];
	GBProtocolData *protocol3 = [GBProtocolData protocolDataWithName:@"P3"];
	[provider registerProtocol:protocol1];
	[provider registerProtocol:protocol2];
	// execute
	[provider replaceProtocol:protocol1 withProtocol:protocol3];
	// verify
	NSArray *protocols = [provider protocolsSortedByName];
	XCTAssertEqual(protocols.count, (NSUInteger)2);
	XCTAssertEqualObjects([[protocols objectAtIndex:0] nameOfProtocol], @"P2");
	XCTAssertEqualObjects([[protocols objectAtIndex:1] nameOfProtocol], @"P3");
}

@end
