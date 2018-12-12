//
//  UtilityDetails+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UtilityDetails.h"

NS_ASSUME_NONNULL_BEGIN

@interface UtilityDetails (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSString *heading;
@property (nullable, nonatomic, retain) NSNumber *rating;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSSet<UtilityItems *> *utilItem;

@end

@interface UtilityDetails (CoreDataGeneratedAccessors)

- (void)addUtilItemObject:(UtilityItems *)value;
- (void)removeUtilItemObject:(UtilityItems *)value;
- (void)addUtilItem:(NSSet<UtilityItems *> *)values;
- (void)removeUtilItem:(NSSet<UtilityItems *> *)values;

@end

NS_ASSUME_NONNULL_END
