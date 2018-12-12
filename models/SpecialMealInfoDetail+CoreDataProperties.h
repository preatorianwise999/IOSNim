//
//  SpecialMealInfoDetail+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/27/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SpecialMealInfoDetail.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpecialMealInfoDetail (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *number;
@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *itemDescription;

@end

NS_ASSUME_NONNULL_END
