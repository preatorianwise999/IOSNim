//
//  UserInformationParser.h
//  Nimbus2
//
//  Created by 720368 on 8/7/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "LTSingleton.h"
#import "LTDeleteOlderFlight.h"
#import "AllDb.h"
#import "NSMutableDictionary+ChekVal.h"
#import "TempLocalStorageModel.h"
#import "AlertUtils.h"
#import "NSDate+DateFormat.h"

@interface UserInformationParser : NSObject{
    
}

+(BOOL)saveFlightListFromDict:(NSDictionary*)flightDict;
+(NSString *)getFlightTypeFromMeterial:(NSString*)material BusinessUnit:(NSString*)businessUnit AirlineCode:(NSString*)airlineCode;
+(NSString *)getMaterialType:(NSString*)material;
+(NSArray*)getFlightRoaster;
+(void)updateFlightType:(NSDictionary *)flightRoasterDict;
+(void)markFlightFlownAsTCForFlight:(NSDictionary*)flightRoasterDict andFlag:(BOOL)flag;
+(BOOL)checkFlightExist:(NSMutableDictionary*)newflight;
+(BOOL)addModifyDeleteManualFlight:(NSMutableDictionary*)newflight forFlight:(NSMutableDictionary*)oldFlight forMode:(enum flightAddMode)mode;
+(NSMutableArray*)getAllManualflights;
+(void)updateFlightLink:(NSDictionary *)flightRoasterDict withStatus:(BOOL)flag;
+(void)updateFlightStatus:(NSDictionary*)flightDict status:(enum status)status withUri:(NSString*)imgUri;
+(void)updateFlightStatus:(NSDictionary*)reponseDict withCounter:(int)count;
+(NSDictionary*)getStatusForFlight:(FlightRoaster*)flight;
+(NSMutableArray*)getStatusForAllFlights;
+(void)saveBookingInfo:(NSDictionary*)responseDict forFlight:(NSDictionary*)flightDict;
+(Customer*)getCustomerForFlight:(NSDictionary*)flightDict andCusyomerDict:(NSDictionary*)cusDict forMoc:(NSManagedObjectContext*)localMoc;
+(BOOL)checkKeysSameBetween:(NSMutableDictionary *)fligh1 and:(NSMutableDictionary *)flight2;

+(FlightRoaster *)getFlightObjectFromDict:(NSMutableDictionary*)flightDict forManageObjectContext:(NSManagedObjectContext*)context;
+(void)getStatsForFlight:(NSDictionary*)flightDict;
@end
