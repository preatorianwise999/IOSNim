//
//  LTCreateFlightReport.h
//  LATAM
//
//  Created by Palash on 05/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlightRoaster;

@interface LTCreateFlightReport : NSObject
+(NSDictionary*)getFlightReportForDictionary:(NSMutableDictionary*)flightRoasterDict;
+(NSDictionary*)getFlightReportForViewSummary:(NSMutableDictionary*)flightRoasterDict;
+(NSMutableDictionary*)createReportFlightDictForFlight:(FlightRoaster*)flight;
+(NSMutableArray*)createFlightReportForAllFlightsForStatus:(STATUS)stat;
+(NSMutableDictionary*)getSyschStatus;
+(NSString *)getVersionForType:(NSString*)type;
+(NSMutableDictionary*)getSyschStatusByIdflight:(NSString*)idflights;
//+(NSMutableDictionary*)getSyschStatusByIdflight:(NSString*)idflights;

@end
