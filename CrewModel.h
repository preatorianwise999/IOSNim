//
//  CrewModel.h
//  Nimbus2
//
//  Created by Dreamer on 8/20/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GADCategory, GADComments;

@interface CrewModel : NSObject

@property (nonatomic, retain) NSString * activeRank;
@property (nonatomic, retain) NSNumber * attempts;
@property (nonatomic, retain) NSString * base;
@property (nonatomic, retain) NSString * bp;
@property (nonatomic, retain) NSNumber * eaAttemts;
@property (nonatomic, retain) NSNumber * errorAttempts;
@property (nonatomic, retain) NSNumber * expectedGAD;
@property (nonatomic, retain) NSNumber * filledGAD;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * isManuallyAdded;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSDate * licencceDate;
@property (nonatomic, retain) NSString * licenceNo;
@property (nonatomic, retain) NSString * specialRank;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSOrderedSet *crewCategory;
@property (nonatomic, retain) GADComments *crewComments;

@end
