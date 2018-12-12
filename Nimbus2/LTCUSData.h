//
//  LTCUSData.h
//  LATAM
//
//  Created by Durga Madamanchi on 7/1/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlightRoaster.h"
#import "Customer.h"

@interface LTCUSData : NSObject

+(NSArray*)createCUSReportForAllFlights:(NSManagedObjectContext*)localMoc;
+(NSDictionary*)getFormCUSReportForDictionary:(NSMutableDictionary*)flightRoasterDict CUSReport:(CusReport*)report;
+(NSMutableArray *)getcusCustomersStatus :(FlightRoaster*)flightRoster;
+(NSMutableDictionary *)getCusFlightDict :(NSDictionary*)flightKeyDict forReportId:(NSString*)cusreportId;
+(NSMutableDictionary*)getFlightDict:(FlightRoaster*)flightRoster;
+(FlightRoaster*)getFlight:(NSMutableDictionary*)flightKeyDict;
//CUS DB updations
+(void)updateCUSimageURL: (NSString*)imageUri withFlightInfo:(NSDictionary *)dict forReportid:(NSString*)reportId ;
+(int)updateCUSStatus: (NSDictionary*)cusResponce status:(enum status)status flightDict:(NSDictionary*)flightKeyDict forReportId:(NSString*)CUSreportId;
+(int)updateCUSStatusIndividual: (NSDictionary*)cusResponce status:(enum status)status flightDict:(NSDictionary*)flightKeyDict forReportId:(NSString*)CUSreportId;
+(NSMutableArray *)getcusCustomersStatus1 :(FlightRoaster*)flightRoster;
+(NSString*)getCUSJsonReportForDict:(NSMutableDictionary *)flightRoasterDict customer:(Customer*)customer forType:(NSString*)type forReportId:(NSString*)reportId;
+(FlightRoaster*)getFlight1:(NSDictionary*)flightKeyDict withContext:(NSManagedObjectContext*)moc;
@end
