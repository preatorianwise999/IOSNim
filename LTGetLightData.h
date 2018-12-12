//
//  LTGetLightData.h
//  LATAM
//
//  Created by Palash on 28/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AllDb.h"
#import "AppDelegate.h"
#import "LTSaveFlightData.h"

@interface LTGetLightData : NSObject
-(NSArray*)getFlights;
+(NSDictionary*)getFormReportForDictionary:(NSDictionary*)flightRoasterDict  forIndex:(int)index;
+(NSDictionary*)getFormReportForDictionary:(NSDictionary*)flightRoasterDict;

+(NSMutableDictionary *)getPrepopulatedDataForGeneral:(NSDictionary*)flightRoasterDict;
+(NSArray*)getFlightCrewForFlightRoaster:(NSDictionary*)flightRoasterDict forLeg:(int)index;
+(NSDictionary *)getGADFormReportForCrewMember:(CrewMembers *)crewObj forFlight:(NSDictionary *)flightDict;
+(NSArray *)getAllManuallyAddedFlights;

+(int)getCrewmemberErrorAttemptsCount:(NSString *)bpNumber;
+(int)getCrewmemberAttemptsCount:(NSString *)bpNumber;
+(NSString *)getCrewMemberURI:(NSString *)bpNumber;
+(NSString*)getUriForType:(enum reportType)report forDict:(NSDictionary*)flightDict;
+(NSArray*)getAllFlights;
+(NSArray*)getFlightLegsForFlightRoaster:(NSDictionary*)flightRoasterDict;
+(NSArray*)getFlightsByIDFlight:(NSString*)idflights;

+(FlightRoaster*)getFlightForParticularFlightReportId:(NSString*)flightReportId;
+(NSArray *)getCrewMemberRanks;
+(NSDictionary *)getGADFormReportForCrewMemberForSynch:(CrewMembers *)crew1 forFlight:(NSDictionary *)flightDict;
+(int)getCrewmemberEAAttemptsCount:(NSString *)bpNumber;
+(CrewMembers *)getCrewmember:(NSString *)bpNumber;
+(BOOL)chekReportIsDrafted:(NSDictionary*)reportDict;
@end
