 //
//  NSMutableDictionary+ChekVal.m
//  LATAM
//
//  Created by Palash on 20/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "NSMutableDictionary+ChekVal.h"

@implementation NSMutableDictionary (ChekVal)
-(id)checkNilValueForKey:(NSString*)key{
    if([self objectForKey:key]==nil || [[self objectForKey:key] isEqual:[NSNull null]]) {
        return @"";
    }else{
        return [self objectForKey:key];
    }
}
-(NSString*)keyForValue:(NSString*)val {
    NSInteger index = [[self allValues] indexOfObject:val];
    if (index != NSNotFound) {
        return [[[self allKeys] objectAtIndex:index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }else{
        return val;
    }
}
@end

@implementation NSDictionary (ChekVal)
-(id)checkNilValueForKey:(NSString*)key{
    if([self objectForKey:key]==nil || [[self objectForKey:key] isEqual:[NSNull null]]){
        return @"";
    }else{
        return [self objectForKey:key];
    }
}
-(NSString*)keyForValue:(NSString*)val{
    int index = [[self allValues] indexOfObject:val];
    if (index!=NSNotFound) {
        return [[[self allKeys] objectAtIndex:index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }else{
        return val;
    }
}
@end