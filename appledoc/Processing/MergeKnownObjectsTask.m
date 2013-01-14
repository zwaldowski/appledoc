//
//  MergeKnownObjectsTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "MergeKnownObjectsTask.h"

@implementation MergeKnownObjectsTask

- (NSInteger)runTask {
	LogDebug(@"Merging known objects...");
	[self handleExtensionsFromStore:self.store];
	[self handleCategoriesFromStore:self.store];
	return GBResultOk;
}

#pragma mark - Extensions & categories handling

- (void)handleExtensionsFromStore:(Store *)store {
	LogDebug(@"Handling extensions...");
	[self mergeMembersFromInterfaces:store.storeExtensions];
}

- (void)handleCategoriesFromStore:(Store *)store {
	LogDebug(@"Handling categories...");
	[self mergeMembersFromInterfaces:store.storeCategories];
}

#pragma mark - Merging handling

- (void)mergeMembersFromInterfaces:(NSMutableArray *)interfaces {
	__weak MergeKnownObjectsTask *bself = self;
	NSMutableArray *mergedInterfaces = [@[] mutableCopy];
	[interfaces enumerateObjectsUsingBlock:^(CategoryInfo *category, NSUInteger idx, BOOL *stop) {
		ClassInfo *extendedClass = category.categoryClass.linkToObject;
		if (!extendedClass) return;
		LogVerbose(@"Merging members of %@...", category);
		[category.interfaceMethodGroups enumerateObjectsUsingBlock:^(MethodGroupInfo *group, NSUInteger gidx, BOOL *gstop) {
			LogDebug(@"Merging group %@...", group);
			[extendedClass.interfaceMethodGroups addObject:group];
			[group.methodGroupMethods enumerateObjectsUsingBlock:^(MemberInfoBase *member, NSUInteger midx, BOOL *mstop) {
				if (member.isClassMethod)
					[extendedClass.interfaceClassMethods addObject:member];
				else if (member.isInstanceMethod)
					[extendedClass.interfaceInstanceMethods addObject:member];
				else
					[extendedClass.interfaceProperties addObject:member];
			}];
		}];
		[mergedInterfaces addObject:category];
	}];
	
	LogDebug(@"Removing merged objects...");
	[interfaces removeObjectsInArray:mergedInterfaces];
}

@end
