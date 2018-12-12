//
//  Groups+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Groups.h"

NS_ASSUME_NONNULL_BEGIN

@interface Groups (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSOrderedSet<Events *> *groupOccourences;

@end

@interface Groups (CoreDataGeneratedAccessors)

- (void)insertObject:(Events *)value inGroupOccourencesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromGroupOccourencesAtIndex:(NSUInteger)idx;
- (void)insertGroupOccourences:(NSArray<Events *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeGroupOccourencesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInGroupOccourencesAtIndex:(NSUInteger)idx withObject:(Events *)value;
- (void)replaceGroupOccourencesAtIndexes:(NSIndexSet *)indexes withGroupOccourences:(NSArray<Events *> *)values;
- (void)addGroupOccourencesObject:(Events *)value;
- (void)removeGroupOccourencesObject:(Events *)value;
- (void)addGroupOccourences:(NSOrderedSet<Events *> *)values;
- (void)removeGroupOccourences:(NSOrderedSet<Events *> *)values;

@end

NS_ASSUME_NONNULL_END
