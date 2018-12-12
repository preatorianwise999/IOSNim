//
//  GADCategory+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GADCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface GADCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSOrderedSet<GADValue *> *categoryValue;

@end

@interface GADCategory (CoreDataGeneratedAccessors)

- (void)insertObject:(GADValue *)value inCategoryValueAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCategoryValueAtIndex:(NSUInteger)idx;
- (void)insertCategoryValue:(NSArray<GADValue *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCategoryValueAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCategoryValueAtIndex:(NSUInteger)idx withObject:(GADValue *)value;
- (void)replaceCategoryValueAtIndexes:(NSIndexSet *)indexes withCategoryValue:(NSArray<GADValue *> *)values;
- (void)addCategoryValueObject:(GADValue *)value;
- (void)removeCategoryValueObject:(GADValue *)value;
- (void)addCategoryValue:(NSOrderedSet<GADValue *> *)values;
- (void)removeCategoryValue:(NSOrderedSet<GADValue *> *)values;

@end

NS_ASSUME_NONNULL_END
