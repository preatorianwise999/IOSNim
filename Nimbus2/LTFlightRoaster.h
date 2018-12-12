//
//  LTFlightRoaster.h
//  LATAM
//
//  Created by Palash on 07/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdlib.h>
#import "NSString+Validation.h"
#import "LTSingleton.h"
#import "TempLocalStorageModel.h"
#import "AlertUtils.h"
#import "FlightRoaster.h"
#import "SynchronizationController.h"
@interface LTFlightRoaster : NSObject
-(BOOL)addManualFlight:(FlightRoaster*)flight;
-(NSDictionary*)insertOrUpdateFlightRoster:(NSDictionary *)responseDict;
-(void)updateFlightStatus:(NSDictionary*)reponseDict  withCounter:(int)count;
-(void)updateFlightStatus: (NSDictionary*)flightDict status:(enum status)status withUri:(NSString*)imgUri;
+(void)updateFlightType:(NSDictionary *)flightRoasterDict;
-(NSString *)getFlightTypeFromMeterial:(NSString*)material BusinessUnit:(NSString*)businessUnit AirlineCode:(NSString*)airlineCode;
-(BOOL)updateFlight:(FlightRoaster*)oldFlight withNewFlight:(FlightRoaster*)newFlight;
-(BOOL)addModifyDeleteManualFlight:(NSMutableDictionary*)newflight forFlight:(NSMutableDictionary*)oldFlight forMode:(enum flightAddMode)mode;
-(NSMutableDictionary *)getFlightDictFromRoaster:(FlightRoaster*)flightObj;
-(NSString *)getMaterialType:(NSString*)material BusinessUnit:(NSString*)businessUnit AirlineCode:(NSString*)airlineCode;
-(BOOL)checkFlightExist:(NSMutableDictionary*)newflight;
-(BOOL)checkKeysSameBetween:(NSMutableDictionary *)fligh1 and:(NSMutableDictionary *)flight2;
@property(nonatomic,strong) NSMutableDictionary *errorDict;
@end
