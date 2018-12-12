//
//  SpecialMealInfoHead+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/27/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SpecialMealInfoHead.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpecialMealInfoHead (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *cabinCode;
@property (nullable, nonatomic, retain) NSString *typeES;
@property (nullable, nonatomic, retain) NSString *typePT;
@property (nullable, nonatomic, retain) NSOrderedSet<SpecialMealInfoDetail *> *mealDetail;

@end

@interface SpecialMealInfoHead (CoreDataGeneratedAccessors)

- (void)insertObject:(SpecialMealInfoDetail *)value inMealDetailAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMealDetailAtIndex:(NSUInteger)idx;
- (void)insertMealDetail:(NSArray<SpecialMealInfoDetail *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMealDetailAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMealDetailAtIndex:(NSUInteger)idx withObject:(SpecialMealInfoDetail *)value;
- (void)replaceMealDetailAtIndexes:(NSIndexSet *)indexes withMealDetail:(NSArray<SpecialMealInfoDetail *> *)values;
- (void)addMealDetailObject:(SpecialMealInfoDetail *)value;
- (void)removeMealDetailObject:(SpecialMealInfoDetail *)value;
- (void)addMealDetail:(NSOrderedSet<SpecialMealInfoDetail *> *)values;
- (void)removeMealDetail:(NSOrderedSet<SpecialMealInfoDetail *> *)values;

@end

NS_ASSUME_NONNULL_END
