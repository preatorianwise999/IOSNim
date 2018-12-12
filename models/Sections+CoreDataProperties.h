//
//  Sections+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Sections.h"

NS_ASSUME_NONNULL_BEGIN

@interface Sections (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSOrderedSet<Groups *> *sectionGroup;

@end

@interface Sections (CoreDataGeneratedAccessors)

- (void)insertObject:(Groups *)value inSectionGroupAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSectionGroupAtIndex:(NSUInteger)idx;
- (void)insertSectionGroup:(NSArray<Groups *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSectionGroupAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSectionGroupAtIndex:(NSUInteger)idx withObject:(Groups *)value;
- (void)replaceSectionGroupAtIndexes:(NSIndexSet *)indexes withSectionGroup:(NSArray<Groups *> *)values;
- (void)addSectionGroupObject:(Groups *)value;
- (void)removeSectionGroupObject:(Groups *)value;
- (void)addSectionGroup:(NSOrderedSet<Groups *> *)values;
- (void)removeSectionGroup:(NSOrderedSet<Groups *> *)values;

@end

NS_ASSUME_NONNULL_END
