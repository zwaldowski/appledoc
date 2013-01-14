//
//  StoreMocks.m
//  appledoc
//
//  Created by Tomaz Kragelj on 11.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#import "Objects.h"
#import "StoreMocks.h"

@implementation StoreMocks

#pragma mark - Common objects

+ (ObjectLinkInfo *)link:(id)nameOrObject {
	ObjectLinkInfo *result = [[ObjectLinkInfo alloc] init];
	if ([nameOrObject isKindOfClass:[NSString class]])
		result.nameOfObject = nameOrObject;
	else
		result.linkToObject = nameOrObject;
	return result;
}

#pragma mark - Real interfaces

+ (InterfaceInfoBase *)createInterface:(void(^)(InterfaceInfoBase *object))handler {
	InterfaceInfoBase *result = [[InterfaceInfoBase alloc] init];
	handler(result);
	return result;
}

+ (ClassInfo *)createClass:(void(^)(ClassInfo *object))handler {
	ClassInfo *result = [[ClassInfo alloc] init];
	handler(result);
	return result;
}

+ (CategoryInfo *)createCategory:(void(^)(CategoryInfo *object))handler {
	CategoryInfo *result = [[CategoryInfo alloc] init];
	handler(result);
	return result;
}

+ (ProtocolInfo *)createProtocol:(void(^)(ProtocolInfo *object))handler {
	ProtocolInfo *result = [[ProtocolInfo alloc] init];
	handler(result);
	return result;
}

#pragma mark - Real members

+ (MethodInfo *)createMethod:(NSString *)uniqueID block:(void(^)(MethodInfo *object))handler {
	MethodInfo *result = [[MethodInfo alloc] init];
	NSRange range = NSMakeRange(1, uniqueID.length - 1);
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^:]+)(:?)" options:0 error:nil];
	[regex enumerateMatchesInString:uniqueID options:0 range:range usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
		NSString *selector = [match gb_stringAtIndex:1 in:uniqueID];
		NSString *colon = [match gb_stringAtIndex:2 in:uniqueID];
		MethodArgumentInfo *argument = [[MethodArgumentInfo alloc] init];
		argument.argumentSelector = selector;
		argument.argumentVariable = (colon.length > 0) ? selector : nil;
		[result.methodArguments addObject:argument];
	}];
	result.methodType = ([uniqueID characterAtIndex:0] == '+') ? GBStoreTypes.classMethod : GBStoreTypes.instanceMethod;
	handler(result);
	return result;
}

+ (PropertyInfo *)createProperty:(NSString *)uniqueID block:(void(^)(PropertyInfo *object))handler {
	PropertyInfo *result = [[PropertyInfo alloc] init];
	result.propertyName = uniqueID;
	handler(result);
	return result;
}

+ (MethodGroupInfo *)createMethodGroup:(NSString *)name block:(void(^)(MethodGroupInfo *object))handler {
	MethodGroupInfo *result = [[MethodGroupInfo alloc] init];
	result.nameOfMethodGroup = name;
	handler(result);
	return result;
}

#pragma mark - Mock interfaces

+ (id)mockClass:(NSString *)name block:(GBCreateObjectBlock)handler {
	id result = mock([ClassInfo class]);
	[given([result nameOfClass]) willReturn:name];
	handler(result);
	return result;
}

+ (id)mockCategory:(NSString *)name onClass:(id)classNameOrObject block:(GBCreateObjectBlock)handler {
	id result = mock([CategoryInfo class]);
	[given([result nameOfCategory]) willReturn:name];
	[self add:classNameOrObject asExtendedClassOf:result];
	handler(result);
	return result;
}

+ (id)mockProtocol:(NSString *)name block:(GBCreateObjectBlock)handler {
	id result = mock([ProtocolInfo class]);
	[given([result nameOfProtocol]) willReturn:name];
	handler(result);
	return result;
}

#pragma mark - Mock members

+ (id)mockMethod:(NSString *)uniqueID block:(void(^)(id object))handler {
	BOOL isClassMethod = [uniqueID hasPrefix:@"+"];
	id result = mock([MethodInfo class]);
	[given([result methodType]) willReturn:(isClassMethod ? GBStoreTypes.classMethod : GBStoreTypes.instanceMethod)];
	[given([result isClassMethod]) willReturnBool:isClassMethod];
	[given([result isInstanceMethod]) willReturnBool:!isClassMethod];
	[given([result isProperty]) willReturnBool:NO];
	[given([result uniqueObjectID]) willReturn:uniqueID];
	handler(result);
	return result;
}

+ (id)mockProperty:(NSString *)uniqueID block:(void(^)(id object))handler {
	id result = mock([PropertyInfo class]);
	[given([result isClassMethod]) willReturnBool:NO];
	[given([result isInstanceMethod]) willReturnBool:NO];
	[given([result isProperty]) willReturnBool:YES];
	[given([result uniqueObjectID]) willReturn:uniqueID];
	handler(result);
	return result;
}

+ (id)mockMethodGroup:(NSString *)name block:(GBCreateObjectBlock)handler {
	id result = mock([MethodGroupInfo class]);
	[given([result nameOfMethodGroup]) willReturn:name];
	handler(result);
	return result;
}

#pragma mark - Common stuff

+ (void)addMockCommentTo:(id)objectOrMock {
	id comment = mock([CommentInfo class]);
	if ([self isMock:objectOrMock])
		[given([objectOrMock comment]) willReturn:comment];
	else
		[objectOrMock setComment:comment];
}

+ (void)add:(id)classOrName asExtendedClassOf:(id)categoryOrMock {
	if (!classOrName) return;
	if ([self isMock:categoryOrMock]) {
		if ([classOrName isKindOfClass:[NSString class]]) [given([categoryOrMock nameOfClass]) willReturn:classOrName];
		[given([categoryOrMock categoryClass]) willReturn:[self link:classOrName]];
	} else {
		[categoryOrMock extend:classOrName];
	}
}

+ (void)add:(id)classOrMock asDerivedClassFrom:(id)baseOrMock {
	ObjectLinkInfo *link = [self link:baseOrMock];
	if ([self isMock:classOrMock])
		[given([classOrMock classSuperClass]) willReturn:link];
	else
		[classOrMock setClassSuperClass:link];
}

+ (void)add:(id)objectOrMock asAdopting:(id)protocolOrMock {
	ObjectLinkInfo *link = [self link:protocolOrMock];
	if ([self isMock:objectOrMock])
		[given([objectOrMock interfaceAdoptedProtocols]) willReturn:@[ link ]];
	else
		[[objectOrMock interfaceAdoptedProtocols] addObject:link];
}

+ (void)add:(id)methodOrMock asClassMethodOf:(id)interfaceOrMock {
	if ([self isMock:interfaceOrMock])
		[given([interfaceOrMock interfaceClassMethods]) willReturn:@[ methodOrMock ]];
	else
		[[interfaceOrMock interfaceClassMethods] addObject:methodOrMock];
}

+ (void)add:(id)methodOrMock asInstanceMethodOf:(id)interfaceOrMock {
	if ([self isMock:interfaceOrMock])
		[given([interfaceOrMock interfaceInstanceMethods]) willReturn:@[ methodOrMock ]];
	else
		[[interfaceOrMock interfaceInstanceMethods] addObject:methodOrMock];
}

+ (void)add:(id)propertyOrMock asPropertyOf:(id)interfaceOrMock {
	if ([self isMock:interfaceOrMock])
		[given([interfaceOrMock interfaceProperties]) willReturn:@[ propertyOrMock ]];
	else
		[[interfaceOrMock interfaceProperties] addObject:propertyOrMock];
}

+ (void)add:(id)memberOrArray asMembersOfGroup:(id)groupOrMock {
	NSArray *array = [memberOrArray isKindOfClass:[NSArray class]] ? memberOrArray : @[ memberOrArray ];
	if ([self isMock:groupOrMock])
		[given([groupOrMock methodGroupMethods]) willReturn:array];
	else
		[[groupOrMock methodGroupMethods] addObjectsFromArray:array];
}

+ (void)add:(NSDictionary *)groups asMethodGroupsOf:(id)interfaceOrMock {
	BOOL createMocks = [self isMock:interfaceOrMock];
	NSMutableArray *groupsArray = [@[] mutableCopy];
	
	[groups enumerateKeysAndObjectsUsingBlock:^(NSString *groupName, NSArray *groupMembers, BOOL *stop) {
		id group = nil;
		if (createMocks)
			group = [self mockMethodGroup:groupName block:^(id object) { }];
		else
			group = [self createMethodGroup:groupName block:^(MethodGroupInfo *object) { }];
		[self add:groupMembers asMembersOfGroup:group];
		[groupsArray addObject:group];
	}];
	
	if (createMocks)
		[given([interfaceOrMock interfaceMethodGroups]) willReturn:groupsArray];
	else
		[[interfaceOrMock interfaceMethodGroups] addObjectsFromArray:groupsArray];
}

+ (void)add:(NSDictionary *)groups asMembersOf:(id)interfaceOrMock {
	NSMutableArray *classMethods = [@[] mutableCopy];
	NSMutableArray *instanceMethods = [@[] mutableCopy];
	NSMutableArray *properties = [@[] mutableCopy];
	[groups enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSArray *members, BOOL *stop) {
		[members enumerateObjectsUsingBlock:^(id member, NSUInteger idx, BOOL *stop) {
			NSString *selector = [member uniqueObjectID];
			if ([selector hasPrefix:@"+"])
				[classMethods addObject:member];
			else if ([selector hasPrefix:@"-"])
				[instanceMethods addObject:member];
			else
				[properties addObject:member];
		}];
	}];
	
	if ([self isMock:interfaceOrMock]) {
		[given([interfaceOrMock interfaceClassMethods]) willReturn:classMethods];
		[given([interfaceOrMock interfaceInstanceMethods]) willReturn:instanceMethods];
		[given([interfaceOrMock interfaceProperties]) willReturn:properties];
	} else {
		[[interfaceOrMock interfaceClassMethods] addObjectsFromArray:classMethods];
		[[interfaceOrMock interfaceInstanceMethods] addObjectsFromArray:instanceMethods];
		[[interfaceOrMock interfaceProperties] addObjectsFromArray:properties];
	}
}

#pragma mark - Helper methods

+ (BOOL)isMock:(id)objectOrMock {
	if ([objectOrMock isKindOfClass:[ObjectInfoBase class]]) return NO;
	if ([objectOrMock isKindOfClass:[MethodGroupInfo class]]) return NO;
	return YES;
}

@end

#pragma mark - 

@implementation InterfaceInfoBase (UnitTestsMocks)

- (void)adopt:(NSString *)first, ... {
	va_list args;
	va_start(args, first);
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString *)) {
		ObjectLinkInfo *link = [[ObjectLinkInfo alloc] init];
		link.nameOfObject = arg;
		[self.interfaceAdoptedProtocols addObject:link];
	}
	va_end(args);
}

@end

#pragma mark -

@implementation CategoryInfo (UnitTestsMocks)

- (void)extend:(id)nameOrClass {
	if ([nameOrClass isKindOfClass:[NSString class]]) {
		self.categoryClass.nameOfObject = nameOrClass;
	} else {
		self.categoryClass.nameOfObject = [nameOrClass nameOfCategory];
		self.categoryClass.linkToObject = nameOrClass;
	}
}

@end

#pragma mark -

@implementation ClassInfo (UnitTestsMocks)

- (void)derive:(NSString *)name {
	self.classSuperClass.nameOfObject = name;
}

@end
