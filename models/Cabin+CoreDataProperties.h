//
//  Cabin+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Cabin.h"

NS_ASSUME_NONNULL_BEGIN

@interface Cabin (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *cabinType;
@property (nullable, nonatomic, retain) NSString *details;
@property (nullable, nonatomic, retain) NSNumber *orderId;
@property (nullable, nonatomic, retain) NSSet<Meal *> *cabinMeal;

@end

@interface Cabin (CoreDataGeneratedAccessors)

- (void)addCabinMealObject:(Meal *)value;
- (void)removeCabinMealObject:(Meal *)value;
- (void)addCabinMeal:(NSSet<Meal *> *)values;
- (void)removeCabinMeal:(NSSet<Meal *> *)values;

@end

NS_ASSUME_NONNULL_END
