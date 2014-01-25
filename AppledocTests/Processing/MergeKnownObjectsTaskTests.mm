//
//  MergeKnownObjectsTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 7/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "StoreMocks.h"
#import "MergeKnownObjectsTask.h"
#import "TestCaseBase.hh"

#define GBSections [comment sourceSections]

#pragma mark -

static void runWithTask(id store, id settings, void(^handler)(MergeKnownObjectsTask *task, id store, id settings)) {
	MergeKnownObjectsTask *task = [[MergeKnownObjectsTask alloc] init];
	task.settings = settings ? settings : mock([GBSettings class]);
	task.store = store ? store : mock([Store class]);
	handler(task, task.store, task.settings);
	[task release];
}

static void addGroups(id object, NSDictionary *groups) {
	[StoreMocks add:groups asMethodGroupsOf:object];
	[StoreMocks add:groups asMembersOf:object];
}

static id createMockMember(NSString *selector) {
	return [StoreMocks mockMember:selector block:^(id object) { }];
}

static id createCategory(NSString *name, id extendingClass) {
	return [StoreMocks mockCategory:name onClass:extendingClass block:^(id object) { }];
}

static id createCategory(NSDictionary *info, id extendingClass, NSDictionary *groups) {
	id category = info[@"category"];
	[StoreMocks add:extendingClass asExtendedClassOf:category];
	return category;
}

#define GBGroupsCount(c) \
	extendee.interfaceMethodGroups.count should equal(c)
#define GBGroupMethod(i,j,o) \
	[extendee.interfaceMethodGroups[i] methodGroupMethods][j] should equal(o)
#define GBGroup(i,n,...) do { \
		id methods[] = { __VA_ARGS__ }; \
		NSUInteger count = sizeof(methods) / sizeof(id); \
		[extendee.interfaceMethodGroups[i] nameOfMethodGroup] should equal(n); \
		[[extendee.interfaceMethodGroups[i] methodGroupMethods] count] should equal(count); \
		for (NSUInteger j=0; j<count; j++) { \
			id method = methods[j]; \
			GBGroupMethod(i,j,method); \
		} \
	} while(NO);

#define GBClassMethods() extendee.interfaceClassMethods
#define GBInstanceMethods() extendee.interfaceInstanceMethods
#define GBProperties() extendee.interfaceProperties

#define GBMembersCount(m,c) [m count] should equal(c)
#define GBMember(m,i,o) m[i] should equal(o)
#define GBMembers(m,...) do { \
		id members[] = { __VA_ARGS__ }; \
		NSUInteger count = sizeof(members) / sizeof(id); \
		GBMembersCount(m,count); \
		for (NSUInteger i=0; i<count; i++) { \
			id member = members[i]; \
			GBMember(m,i,member); \
		} \
	} while (NO)

#pragma mark -

TEST_BEGIN(MergeKnownObjectsTaskTests)

describe(@"method groups:", ^{
	__block id store;
	__block id settings;
	
	beforeEach(^{
		settings = mock([GBSettings class]);
		store = mock([Store class]);
	});

	sharedExamplesFor(@"examples", ^(NSDictionary *info) {
		__block id classMethod;
		__block id instanceMethod;
		__block id property;
		
		beforeEach(^{
			classMethod = createMockMember(@"+method");
			instanceMethod = createMockMember(@"-method");
			property = createMockMember(@"property");
		});
		
		it(@"should merge class & instance methods and properties to empty class", ^{
			runWithTask(store, settings, ^(MergeKnownObjectsTask *task, id store, id settings) {
				// setup
				ClassInfo *extendee = [StoreMocks createClass:^(ClassInfo *object) { }];
				id category = createCategory(info, extendee, @{ @"group1":@[ classMethod, instanceMethod, property ] });
				// execute
				[task runTask];
				// verify
				GBGroupsCount(1);
				GBGroup(0, @"group1", classMethod, instanceMethod, property);
				GBMembers(GBClassMethods(), classMethod);
				GBMembers(GBInstanceMethods(), instanceMethod);
				GBMembers(GBProperties(), property);
			});
		});
		
		it(@"should merge class & instance methods and properties to class with methods but without groups", ^{
			runWithTask(store, settings, ^(MergeKnownObjectsTask *task, id store, id settings) {
				// setup
				ClassInfo *extendee = [StoreMocks createClass:^(ClassInfo *object) {
					addGroups(object, @{ @"" : @[ @"+method1", @"-method1", @"property" ] });
				}];
				id categoryClassMethod = createMockMember(@"+method");
				id categoryInstanceMethod = createMockMember(@"-method");
				id categoryProperty = createMockMember(@"property");
				id category = createCategory(info, extendee, @{ @"group1":@[categoryClassMethod,categoryInstanceMethod,categoryProperty] });
				// execute
				[task runTask];
				// verify
				GBGroupsCount(1);
				GBGroup(0, @"group1", categoryClassMethod, categoryInstanceMethod, categoryProperty);
				GBMembers(GBClassMethods(), extendee.interfaceClassMethods[0], categoryClassMethod);
				GBMembers(GBInstanceMethods(), extendee.interfaceInstanceMethods[0], categoryInstanceMethod);
				GBMembers(GBProperties(), extendee.interfaceProperties[0], categoryProperty);
			});
		});
		
		it(@"should merge class & instance methods and properties to class with methods and groups", ^{
			runWithTask(store, settings, ^(MergeKnownObjectsTask *task, id store, id settings) {
				// setup
				ClassInfo *extendee = [StoreMocks createClass:^(ClassInfo *object) {
					addGroups(object, @{
						@"group1" : @[
							[StoreMocks createMethod:@"+method1" block:^(MethodInfo *object) { }],
							[StoreMocks createMethod:@"-method1" block:^(MethodInfo *object) { }],
							[StoreMocks mockMember:@"property1" block:^(PropertyInfo *object) { }]
						]
					});
				}];
				id categoryClassMethod = createMockMember(@"+method");
				id categoryInstanceMethod = createMockMember(@"-method");
				id categoryProperty = createMockMember(@"property");
				id category = createCategory(info, extendee, @{ @"group2":@[categoryClassMethod,categoryInstanceMethod,categoryProperty] });
				// execute
				[task runTask];
				// verify
				GBGroupsCount(2);
				GBGroup(0, @"group1", extendee.interfaceClassMethods[0], extendee.interfaceInstanceMethods[0], extendee.interfaceProperties[0]);
				GBGroup(1, @"group2", categoryClassMethod, categoryInstanceMethod, categoryProperty);
				GBMembers(GBClassMethods(), extendee.interfaceClassMethods[0], categoryClassMethod);
				GBMembers(GBInstanceMethods(), extendee.interfaceInstanceMethods[0], categoryInstanceMethod);
				GBMembers(GBProperties(), extendee.interfaceProperties[0], categoryProperty);
			});
		});
		
		it(@"should merge groups ", ^{
			runWithTask(store, settings, ^(MergeKnownObjectsTask *task, id store, id settings) {
				// setup
				ClassInfo *extendee = [StoreMocks createClass:^(ClassInfo *object) {
					addGroups(object, @{
						@"group1" : @[
							[StoreMocks createMethod:@"+method1" block:^(MethodInfo *object) { }],
							[StoreMocks createMethod:@"-method1" block:^(MethodInfo *object) { }],
							[StoreMocks mockMember:@"property1" block:^(PropertyInfo *object) { }]
						]
					});
				}];
				id categoryClassMethod = createMockMember(@"+method");
				id categoryInstanceMethod = createMockMember(@"-method");
				id categoryProperty = createMockMember(@"property");
				id category = createCategory(info, extendee, @{ @"group2":@[categoryClassMethod,categoryInstanceMethod,categoryProperty] });
				// execute
				[task runTask];
				// verify
				GBGroupsCount(2);
				GBGroup(0, @"group1", extendee.interfaceClassMethods[0], extendee.interfaceInstanceMethods[0], extendee.interfaceProperties[0]);
				GBGroup(1, @"group2", categoryClassMethod, categoryInstanceMethod, categoryProperty);
				GBMembers(GBClassMethods(), extendee.interfaceClassMethods[0], categoryClassMethod);
				GBMembers(GBInstanceMethods(), extendee.interfaceInstanceMethods[0], categoryInstanceMethod);
				GBMembers(GBProperties(), extendee.interfaceProperties[0], categoryProperty);
			});
		});
	});
	
	describe(@"extensions:", ^{
		beforeEach(^{
			id extension = createCategory(@"", nil);
			[[SpecHelper specHelper] sharedExampleContext][@"store"] = store;
			[[SpecHelper specHelper] sharedExampleContext][@"category"] = extension;
			[given([store storeExtensions]) willReturn:[@[ extension ] mutableCopy]];
		});
		itShouldBehaveLike(@"examples");
	});
	
	describe(@"categories:", ^{
		beforeEach(^{
			id category = createCategory(@"category", nil);
			[[SpecHelper specHelper] sharedExampleContext][@"store"] = store;
			[[SpecHelper specHelper] sharedExampleContext][@"category"] = category;
			[given([store storeCategories]) willReturn:[@[ category ] mutableCopy]];
		});
		itShouldBehaveLike(@"examples");
	});
});

TEST_END