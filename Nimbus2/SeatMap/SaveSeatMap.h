//
//  SaveSeatMap.h
//  Nimbus2
//
//  Created by vishal on 10/20/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
@interface SaveSeatMap : NSObject

+(void)saveSeatMapForFlight:(NSDictionary *)flight andSeatMap:(NSDictionary *)seatMapDict;
+(void)savePassengerForFlight:(NSDictionary *)flightDict andPassengerDict:(NSDictionary *)passengerDict;
+(void)saveCustomerForFlight:(NSDictionary *)flightDict andCustomerDict:(NSDictionary *)customerDict legNumber:(int)legindex;
+(void)updateCustomerForFlight:(NSDictionary *)flightDict andCustomerDict:(NSDictionary *)customerDict legNumber:(int)legindex;
+(NSString *)generateRandomString;
+(NSString *)customerExists:(NSDictionary *)flightDict andCustomerDict:(NSDictionary *)customerDict legNumber:(int)legindex;
+(NSString *)CreateDefaultIdGeneratedReport:(NSString*)idflight:(NSString*)idOperador;
@end
