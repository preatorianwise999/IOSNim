//
//  GetSeatMapData.h
//  Nimbus2
//
//  Created by vishal on 10/19/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetSeatMapData : NSObject


+(NSMutableDictionary *)getSeatMapDataForLegIndex:(int)index;
+(NSMutableArray *)getPassengerDataLegIndex:(int)index;

@end
