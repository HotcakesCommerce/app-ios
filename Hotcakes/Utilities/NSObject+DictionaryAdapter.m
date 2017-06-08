/*
   Hotcakes Commerce - https://hotcakes.org
   Copyright (c) 2017
   by Hotcakes Commerce, LLC
   
   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
   documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
   the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and 
   to permit persons to whom the Software is furnished to do so, subject to the following conditions:
   
   The above copyright notice and this permission notice shall be included in all copies or substantial portions 
   of the Software.
   
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
   TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
   THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
   CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
   DEALINGS IN THE SOFTWARE.
*/

#import "NSObject+DictionaryAdapter.h"
#include <objc/runtime.h>

@implementation NSObject (DictionaryAdapter)

+ (id)objectWithDictionary:(NSDictionary*)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        for (NSString *property in [self propertyNames])
        {
            id dictionaryValue = [self getDictionaryValueForClassProperty:property fromDictionary:dictionary];
            if(dictionaryValue)
                [self setValue:[self coerceValue:dictionaryValue toTypeofObjectProperty:property] forKey:property];
        }
    }
    return self;
}

- (id)getDictionaryValueForClassProperty:(NSString *)property fromDictionary:(NSDictionary *)dictionary
{
    NSArray *tests = @[
    ^(NSString *property){ return property; }, // camelCase (default)
    ^(NSString *property){ return [[[property substringToIndex:1] uppercaseString] stringByAppendingString:[property substringFromIndex:1]]; } // PascalCase
    ];
    for (NSString * (^getKey)(NSString *) in tests)
    {
        id result = [dictionary valueForKey: getKey(property)];
        if (result)
            return result;
    }
    return nil;
}

- (id)coerceValue:(id)value toTypeofObjectProperty:(NSString*)property
{
    // Type Coercion reference: http://stackoverflow.com/a/3497822
    NSString * typeString = [NSString stringWithUTF8String: property_getAttributes(class_getProperty([self class], [property cStringUsingEncoding:NSUTF8StringEncoding]))];
    NSArray * attributes = [typeString componentsSeparatedByString:@","];
    NSString * typeAttribute = [attributes objectAtIndex:0];
    
    if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 1)
    {
        NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  //turns @"NSDate" into NSDate
        Class typeClass = NSClassFromString(typeClassName);
        if (typeClass != nil)
            return [self convertValue:value toType:typeClass];
    }
    return value;
}

- (id)convertValue:(id)value toType:(Class)type
{
    if (type == [NSDate class])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        NSDate *result = [dateFormatter dateFromString:value];
        return result;
    }
    return value;
}

- (NSMutableArray *)propertyNames
{
    // Reflection reference: http://stackoverflow.com/questions/3001441/
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i)
    {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    return propertyNames;
}

@end
