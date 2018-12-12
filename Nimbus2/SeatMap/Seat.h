//
//  Seat.h
//  SeatMapSample
//
//  Created by Rajashekar on 12/10/15.
//  Copyright (c) 2015 Rajashekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Passenger.h"

@interface Seat : NSObject {

}

@property(nonatomic, retain)  NSString *rowName;
@property(nonatomic, retain)  NSString *columnName;
@property(nonatomic, retain)  NSString *state;
@property(nonatomic) BOOL isWindow;
@property(nonatomic) BOOL isAisle;
@property(nonatomic) BOOL isEmergency;
@property(nonatomic) enum seatState seatStatus;
@property(nonatomic, retain) Passenger *seatPassenger;
@property(nonatomic, retain) NSMutableArray *accessories;
@property(nonatomic) BOOL isHighlighted;




@end
