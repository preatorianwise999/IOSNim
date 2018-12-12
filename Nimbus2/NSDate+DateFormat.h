//
//  NSDate+DateFormat.h
//  LATAM
//
//  Created by Ankush jain on 4/8/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DateFormat)

- (NSString *)dateFormat:(DATE_FORMAT_TYPE)formatType;
+ (NSDate *)dateFromString:(NSString *)dateStr dateFormatType:(DATE_FORMAT_TYPE)dateFormatType;

@end


