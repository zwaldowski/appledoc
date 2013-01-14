//
//  StoreMocks.h
//  appledoc
//
//  Created by Tomaz Kragelj on 11.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"

typedef void(^GBCreateObjectBlock)(id object);

@interface StoreMocks : NSObject

+ (ObjectLinkInfo *)link:(id)nameOrObject;

+ (InterfaceInfoBase *)createInterface:(void(^)(InterfaceInfoBase *object))handler;
+ (ClassInfo *)createClass:(void(^)(ClassInfo *object))handler;
+ (CategoryInfo *)createCategory:(void(^)(CategoryInfo *object))handler;
+ (ProtocolInfo *)createProtocol:(void(^)(ProtocolInfo *object))handler;

+ (MethodInfo *)createMethod:(NSString *)uniqueID block:(void(^)(MethodInfo *object))handler;
+ (PropertyInfo *)createProperty:(NSString *)uniqueID block:(void(^)(PropertyInfo *object))handler;
+ (MethodGroupInfo *)createMethodGroup:(NSString *)name block:(void(^)(MethodGroupInfo *object))handler;

+ (id)mockClass:(NSString *)name block:(GBCreateObjectBlock)handler;
+ (id)mockCategory:(NSString *)name onClass:(id)classNameOrObject block:(GBCreateObjectBlock)handler;
+ (id)mockProtocol:(NSString *)name block:(GBCreateObjectBlock)handler;

+ (id)mockMethod:(NSString *)uniqueID block:(GBCreateObjectBlock)handler;
+ (id)mockProperty:(NSString *)uniqueID block:(GBCreateObjectBlock)handler;
+ (id)mockMethodGroup:(NSString *)name block:(GBCreateObjectBlock)handler;

+ (void)addMockCommentTo:(id)objectOrMock;
+ (void)add:(id)classOrName asExtendedClassOf:(id)categoryOrMock;
+ (void)add:(id)classOrMock asDerivedClassFrom:(id)baseOrMock;
+ (void)add:(id)objectOrMock asAdopting:(id)protocolOrMock;
+ (void)add:(id)methodOrMock asClassMethodOf:(id)interfaceOrMock;
+ (void)add:(id)methodOrMock asInstanceMethodOf:(id)interfaceOrMock;
+ (void)add:(id)propertyOrMock asPropertyOf:(id)interfaceOrMock;
+ (void)add:(id)memberOrArray asMembersOfGroup:(id)groupOrMock;
+ (void)add:(NSDictionary *)groups asMethodGroupsOf:(id)interfaceOrMock;
+ (void)add:(NSDictionary *)groups asMembersOf:(id)interfaceOrMock;

@end

#pragma mark - 

@interface InterfaceInfoBase (UnitTestsMocks)
- (void)adopt:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;
@end

#pragma mark -

@interface CategoryInfo (UnitTestsMocks)
- (void)extend:(id)nameOrClass;
@end

#pragma mark - 

@interface ClassInfo (UnitTestsMocks)
- (void)derive:(NSString *)name;
@end
