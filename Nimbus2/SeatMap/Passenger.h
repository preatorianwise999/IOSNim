//
//  Passenger.h
//  SeatMapSample
//
//  Created by Rajashekar on 14/10/15.
//  Copyright (c) 2015 Rajashekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Passenger : NSObject {
    
}
@property (nonatomic, retain) NSString * accountStatus;
@property (nonatomic, retain) NSNumber * attempts;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * dateOfBirth;
@property (nonatomic, retain) NSString * docNumber;
@property (nonatomic, retain) NSString * docType;
@property (nonatomic, retain) NSString * editCodes;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * freqFlyerCategory;
@property (nonatomic, retain) NSString * freqFlyerComp;
@property (nonatomic, retain) NSString * freqFlyerNum;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * haConnection;
@property (nonatomic, retain) NSNumber * hasSpecialMeal;
@property (nonatomic, retain) NSString * imageLoadUrl;
@property (nonatomic, retain) NSNumber * isChild;
@property (nonatomic, retain) NSNumber * isWCH;
@property (nonatomic, retain) NSString * lanPassCategory;
@property (nonatomic, retain) NSString * lanPassKms;
@property (nonatomic, retain) NSNumber * lanPassUpgrade;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * address;

@property (nonatomic, retain) NSString * arrivalDate ;
@property (nonatomic, retain) NSString * departureDate ;
@property (nonatomic, retain) NSString * flightType ;
@property (nonatomic, retain) NSString * flightNum ;
@property (nonatomic , retain) NSString *flightClass;


@property (nonatomic, retain) NSString * seatNumber;
@property (nonatomic, retain) NSString * secondLastName;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * synchDate;
@property (nonatomic, retain) NSString * vipCategory;
@property (nonatomic, retain) NSString * vipRemarks;
@property (nonatomic, retain) NSString * vipSpecialAttentions;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * groupCode;
@property (nonatomic, retain) NSSet *cusGroup;
@property (nonatomic, retain) NSString * customerId;

//@property (nonatomic, retain) CUSImages *cusImages;
//@property (nonatomic, retain) Legs *cusLeg;
@property (nonatomic, retain) NSSet *cusSolicitudes;
@property (nonatomic, retain) NSOrderedSet *specialMeals;
@property (nonatomic, retain) NSOrderedSet *cusConnection;



@end
