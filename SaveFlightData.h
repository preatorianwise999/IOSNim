//
//  SaveFlightData.h
//  Nimbus2
//
//  Created by 720368 on 8/20/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SaveFlightData : NSObject
+(void)saveEventWithFlightRoasterDict:(NSMutableDictionary*)flightRoasterDict forLeg:(NSDictionary*)legDict;
@end
