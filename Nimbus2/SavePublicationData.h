//
//  SavePublicationData.h
//  Nimbus2
//
//  Created by 720368 on 8/22/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AllDb.h"
#import "AppDelegate.h"
#import "NSMutableDictionary+ChekVal.h"
#import "NSDate+DateFormat.h"
#import "LTSingleton.h"
@interface SavePublicationData : NSObject

+ (void)savePublicationDetailsFromDict:(NSDictionary*)publicationDict;
+ (NSMutableDictionary*)getDetailsForFlight:(NSDictionary*)flightDict;

+ (void)saveCrewForleg:(Legs*)leg fromDicr:(NSDictionary*)crewDict;
+ (void)saveManualCrewFromDict:(NSMutableDictionary*)crewDict;
@end
