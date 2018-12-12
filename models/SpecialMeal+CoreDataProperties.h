//
//  SpecialMeal+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SpecialMeal.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpecialMeal (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *option;
@property (nullable, nonatomic, retain) NSString *serviceCode;

@end

NS_ASSUME_NONNULL_END
