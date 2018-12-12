//
//  SeatMap+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 1/19/16.
//  Copyright © 2016 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SeatMap.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeatMap (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *classType;
@property (nullable, nonatomic, retain) NSString *columnNum;
@property (nullable, nonatomic, retain) NSString *columnType;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSNumber *isAisle;
@property (nullable, nonatomic, retain) NSNumber *isEmergency;
@property (nullable, nonatomic, retain) NSNumber *isWindow;
@property (nullable, nonatomic, retain) NSNumber *rowNumber;
@property (nullable, nonatomic, retain) NSString *state;
@property (nullable, nonatomic, retain) NSSet<Customer *> *seatCustomer;

@end

@interface SeatMap (CoreDataGeneratedAccessors)

- (void)addSeatCustomerObject:(Customer *)value;
- (void)removeSeatCustomerObject:(Customer *)value;
- (void)addSeatCustomer:(NSSet<Customer *> *)values;
- (void)removeSeatCustomer:(NSSet<Customer *> *)values;

@end

NS_ASSUME_NONNULL_END
