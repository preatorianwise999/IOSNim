//
//  LTSaveCUSData.h
//  Nimbus2
//
//  Created by Rajashekar on 08/09/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SaveSeatMap.h"
@class Customer;

@interface LTSaveCUSData : NSObject


+(void)modifyStatus:(int)status forCustomer:(NSDictionary *)customerDict forLeg:(int)legNo forFlight:(NSMutableDictionary *)flightRoster  forReportId:(NSString*)reportId;

+(NSString*) saveCUSReportforFlightLeg:(int)legNumber forCustomer:(NSDictionary *)customerDict forCUSImages:(NSDictionary*)cusImages forCUSDict:(NSDictionary*)flightCUSDict forFlight:(NSDictionary*)flightDict hasSeatMap:(BOOL)doesNotHaveSeatMap forReportid:(NSString*)reportId;

+(void) deleteReportForCustomerDict:(NSDictionary*)customerDict forFlightDict:(NSDictionary*)flightDict forreportId:(NSString*)reportId;




@end
