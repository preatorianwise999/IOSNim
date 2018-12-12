//
//  GADController.h
//  Nimbus2
//
//  Created by 720368 on 8/26/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GADController : NSObject{
    int legIndex;
   
   
}


+(void)saveGaDDict:(NSDictionary *)dict;
+(NSMutableDictionary *)getGADforCrew:(NSDictionary *)crewDict forFlight:(NSDictionary *)flightDic;
+(void)updateCrewMemberStatusFormInterface:(STATUS)status  uniqueBP:(NSString *)bpNumber forFlight:(NSDictionary *)flightDict;
+(int)getCrewmemberAttemptsCount:(NSString *)bpNumber forflight:(NSDictionary *)flightReportDict;
+(NSString *)getCrewMemberURI:(NSString *)bpNumber;
+(BOOL)saveCrewmemberWithFirstName:(NSString *)firstName amdLastName:(NSString *)lastName andbpNumber:(NSString *)bpNumber rankValue:(NSString *)rank forFlight:(NSDictionary*)flightDict;

+(NSArray*)getFlightCrewForFlightLeg:(NSDictionary*)flightLegDict :(NSDictionary *)flightDict;
+(void)deleteGADForCrewBp:(NSString*)crewBP ForFlight:(NSDictionary*)dict;
+(NSArray*)getFlightLegsForFlightRoaster:(NSDictionary*)flightRoasterDict;
+(NSMutableDictionary *)formatJSON_WithGadReport:(NSDictionary *)dict forFlight:(NSDictionary*)flightDict;
@end
