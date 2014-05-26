// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRBoolean.h"

@implementation GRYes

+ (GRYes *)yes {
	static dispatch_once_t onceToken;
	static GRYes *yes = nil;
	dispatch_once(&onceToken, ^{
		yes = [[super allocWithZone:NULL] init];
	});
	return yes;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self yes];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)valueForKey:(NSString *)key {
	return nil;
}

- (BOOL)boolValue {
	return YES;
}

- (NSString *)description {
	return @"(yes)";
}

@end



@implementation GRNo

+ (GRNo *)no {
	static dispatch_once_t onceToken;
	static GRNo *no = nil;
	dispatch_once(&onceToken, ^{
		no = [[super allocWithZone:NULL] init];
	});
	return no;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self no];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)valueForKey:(NSString *)key {
	return nil;
}

- (BOOL)boolValue {
	return NO;
}

- (NSString *)description {
	return @"(no)";
}

@end
