//
//  LegsModel.h
//  Nimbus2
//
//  Created by Palash on 20/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LegsModel : NSMutableDictionary
@property (nonatomic, retain) NSString * businessUnit;
@property (nonatomic, retain) NSString * destination;
@property (nonatomic, retain) NSDate * legArrivalLocal;
@property (nonatomic, retain) NSDate * legArrivalUTC;
@property (nonatomic, retain) NSDate * legDepartureLocal;
@property (nonatomic, retain) NSDate * legDepartureUTC;
@property (nonatomic, retain) NSString * origin;
//@property (nonatomic, retain) Report *legFlightReport;
@property (nonatomic, retain) NSOrderedSet *legsCrewmember;
@end
