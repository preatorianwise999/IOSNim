//
//  LTGetDropDownvalue.h
//  LATAM
//
//  Created by Palash on 17/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AllDb.h"
#import "AppDelegate.h"
@interface LTGetDropDownvalue : NSObject
+(NSMutableDictionary*)getDictForReportType:(NSString*)type FlightReport:(NSString*)flighReporttName Section:(NSString*)sectionName;
@end
