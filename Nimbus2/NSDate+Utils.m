//
//  NSDate+Utilities.m
//  Nimbus2
//
//  Created by Diego Cathalifaud on 10/5/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

- (NSDate *) toLocalTime {
    NSTimeZone *tz = [NSTimeZone systemTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

- (NSDate *) toGlobalTime {
    NSTimeZone *tz = [NSTimeZone systemTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

@end
