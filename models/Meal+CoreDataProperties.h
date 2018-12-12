//
//  Meal+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Meal.h"

NS_ASSUME_NONNULL_BEGIN

@interface Meal (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *amount;
@property (nullable, nonatomic, retain) NSString *mealType;
@property (nullable, nonatomic, retain) NSNumber *orderId;

@end

NS_ASSUME_NONNULL_END
