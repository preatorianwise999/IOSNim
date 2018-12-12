//
//  DatabaseOperations.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/23/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTAllDb.h"
@interface LTSaveFlightData : NSObject
+(void)saveEventWithFlightRoasterDict:(NSMutableDictionary*)flightRoasterDict;
+(void) saveCUSReportForCustomer:(Customer*)customer withDict:(NSDictionary*)dict;
+(BOOL)saveCrewmemberWithFirstName:(NSString *)firstName amdLastName:(NSString *)lastName andbpNumber:(NSString *)bpNumber rankValue:(NSString *)rank forFlight:(NSDictionary*)flightDict;
+(void)saveGADReportForGADDictionary:(NSDictionary *)gadDict forFlight:(NSDictionary*)flightDict;
+(void)updateCrewMemberStatus:(STATUS)status andImageUri:(NSString*)uriString uniqueBP:(NSString *)bpNumber forFlight:(NSDictionary *)flightDict;
+(void)updateCrewMemberStatusToZero:(STATUS)status uniqueBP:(NSString *)bpNumber forFlight:(NSDictionary *)flightDict;
+(void)updateCrewMemberStatusFormInterface:(STATUS)status andImageUri:(NSString*)uriString uniqueBP:(NSString *)bpNumber forFlight:(NSDictionary *)flightDict;
//+(void) saveCUSReportForCustomer1:(Customer*)customer withDict:(NSDictionary*)dict withMoc:(NSManagedObjectContext*)localMoc;
@end
