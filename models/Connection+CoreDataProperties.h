//
//  Connection+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Connection.h"

NS_ASSUME_NONNULL_BEGIN

@interface Connection (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *arrivalAP;
@property (nullable, nonatomic, retain) NSDate *arrivalDate;
@property (nullable, nonatomic, retain) NSString *departureAP;
@property (nullable, nonatomic, retain) NSDate *departureDate;
@property (nullable, nonatomic, retain) NSString *flightNum;
@property (nullable, nonatomic, retain) NSString *flightType;

@end

NS_ASSUME_NONNULL_END
