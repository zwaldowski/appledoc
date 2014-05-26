//
//  GBIvarsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBIvarsProvider.h"

@interface GBIvarsProviderTesting : XCTestCase
@end

@implementation GBIvarsProviderTesting

#pragma mark Ivar registration testing

- (void)testRegisterIvar_shouldAddIvarToList {
	// setup
	GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
	GBIvarData *ivar = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"NSUInteger", @"_name", nil]];
	// execute
	[provider registerIvar:ivar];
	// verify
	XCTAssertTrue([provider.ivars containsObject:ivar]);
	XCTAssertEqual(provider.ivars.count, (NSUInteger)1);
	XCTAssertEqualObjects([provider.ivars objectAtIndex:0], ivar);
}

- (void)testRegisterIvar_shouldSetParentObject {
	// setup
	GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
	GBIvarData *ivar = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"NSUInteger", @"_name", nil]];
	// execute
	[provider registerIvar:ivar];
	// verify
	XCTAssertEqualObjects(ivar.parentObject, self);
}

- (void)testRegisterIvar_shouldIgnoreSameInstance {
	// setup
	GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
	GBIvarData *ivar = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"NSUInteger", @"_name", nil]];
	// execute
	[provider registerIvar:ivar];
	[provider registerIvar:ivar];
	// verify
	XCTAssertEqual(provider.ivars.count, (NSUInteger)1);
}

- (void)testRegisterIvar_shouldMergeDifferentInstanceWithSameName {
	// setup
	GBIvarsProvider *provider = [[GBIvarsProvider alloc] initWithParentObject:self];
	GBIvarData *source = [GBIvarData ivarDataWithComponents:[NSArray arrayWithObjects:@"int", @"_index", nil]];
	OCMockObject *destination = [OCMockObject niceMockForClass:[GBIvarData class]];
	[[[destination stub] andReturn:@"_index"] nameOfIvar];
	[[destination expect] mergeDataFromObject:source];
	[provider registerIvar:(GBIvarData *)destination];
	// execute
	[provider registerIvar:source];
	// verify
	[destination verify];
}

#pragma mark Merging testing

- (void)testMergeDataFromIvarsProvider_shouldMergeAllDifferentIvars {
	// setup
	GBIvarsProvider *original = [[GBIvarsProvider alloc] initWithParentObject:self];
	[original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i2", nil]];
	GBIvarsProvider *source = [[GBIvarsProvider alloc] initWithParentObject:self];
	[source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i3", nil]];
	// execute
	[original mergeDataFromIvarsProvider:source];
	// verify - only basic testing here, details at GBIvarDataTesting!
	NSArray *ivars = [original ivars];
	XCTAssertEqual(ivars.count, (NSUInteger)3);
	XCTAssertEqualObjects([[ivars objectAtIndex:0] nameOfIvar], @"_i1");
	XCTAssertEqualObjects([[ivars objectAtIndex:1] nameOfIvar], @"_i2");
	XCTAssertEqualObjects([[ivars objectAtIndex:2] nameOfIvar], @"_i3");
}

- (void)testMergeDataFromIvarsProvider_shouldPreserveSourceData {
	// setup
	GBIvarsProvider *original = [[GBIvarsProvider alloc] initWithParentObject:self];
	[original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[original registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i2", nil]];
	GBIvarsProvider *source = [[GBIvarsProvider alloc] initWithParentObject:self];
	[source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i1", nil]];
	[source registerIvar:[GBTestObjectsRegistry ivarWithComponents:@"int", @"_i3", nil]];
	// execute
	[original mergeDataFromIvarsProvider:source];
	// verify - only basic testing here, details at GBIvarDataTesting!
	NSArray *ivars = [source ivars];
	XCTAssertEqual(ivars.count, (NSUInteger)2);
	XCTAssertEqualObjects([[ivars objectAtIndex:0] nameOfIvar], @"_i1");
	XCTAssertEqualObjects([[ivars objectAtIndex:1] nameOfIvar], @"_i3");
}

@end
