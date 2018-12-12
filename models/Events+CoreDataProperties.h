//
//  Events+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Events.h"

NS_ASSUME_NONNULL_BEGIN

@interface Events (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *isMultiple;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSOrderedSet<Row *> *eventsRow;

@end

@interface Events (CoreDataGeneratedAccessors)

- (void)insertObject:(Row *)value inEventsRowAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEventsRowAtIndex:(NSUInteger)idx;
- (void)insertEventsRow:(NSArray<Row *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEventsRowAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEventsRowAtIndex:(NSUInteger)idx withObject:(Row *)value;
- (void)replaceEventsRowAtIndexes:(NSIndexSet *)indexes withEventsRow:(NSArray<Row *> *)values;
- (void)addEventsRowObject:(Row *)value;
- (void)removeEventsRowObject:(Row *)value;
- (void)addEventsRow:(NSOrderedSet<Row *> *)values;
- (void)removeEventsRow:(NSOrderedSet<Row *> *)values;

@end

NS_ASSUME_NONNULL_END
