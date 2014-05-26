//
//  GBTemplateVariablesProvider-CommonTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.10.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBHTMLTemplateVariablesProvider.h"
#import "GBTokenizer.h"

@interface GBTemplateVariablesProviderCommonTesting : XCTestCase
- (NSDateFormatter *)yearFormatterFromSettings:(GBApplicationSettingsProvider *)settings;
- (NSDateFormatter *)yearToDayFormatterFromSettings:(GBApplicationSettingsProvider *)settings;
@end

@implementation GBTemplateVariablesProviderCommonTesting

- (void)testVariablesForClass_shouldPrepareDefaultVariables {
	// setup
	id settings = [GBTestObjectsRegistry realSettingsProvider];
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:settings];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];	
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
	// verify - just basic tests...
	XCTAssertNotNil([vars objectForKey:@"page"]);
	XCTAssertNotNil([vars valueForKeyPath:@"page.title"]);
	XCTAssertNotNil([vars valueForKeyPath:@"page.specifications"]);
	XCTAssertEqualObjects([vars objectForKey:@"object"], class);
}

- (void)testVariableForClass_shouldPrepareFooterVariables {
	// setup
	id settings = [GBTestObjectsRegistry realSettingsProvider];
	GBHTMLTemplateVariablesProvider *provider = [GBHTMLTemplateVariablesProvider providerWithSettingsProvider:settings];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];	
	// execute
	NSDictionary *vars = [provider variablesForClass:class withStore:[GBTestObjectsRegistry store]];
	// verify - just basic tests...
	NSDate *date = [NSDate date];
	NSString *year = [[self yearFormatterFromSettings:settings] stringFromDate:date];
	NSString *day = [[self yearToDayFormatterFromSettings:settings] stringFromDate:date];
	XCTAssertEqualObjects([vars valueForKeyPath:@"page.copyrightDate"], year);
	XCTAssertEqualObjects([vars valueForKeyPath:@"page.lastUpdatedDate"], day);
}

#pragma mark Creation methods

- (NSDateFormatter *)yearFormatterFromSettings:(GBApplicationSettingsProvider *)settings {
	return [settings valueForKey:@"yearDateFormatter"];
}

- (NSDateFormatter *)yearToDayFormatterFromSettings:(GBApplicationSettingsProvider *)settings {
	return [settings valueForKey:@"yearToDayDateFormatter"];
}

@end
