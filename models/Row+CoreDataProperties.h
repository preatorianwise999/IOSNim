//
//  Row+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Row.h"

NS_ASSUME_NONNULL_BEGIN

@interface Row (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *rowNumber;
@property (nullable, nonatomic, retain) NSOrderedSet<Contents *> *rowContent;

@end

@interface Row (CoreDataGeneratedAccessors)

- (void)insertObject:(Contents *)value inRowContentAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRowContentAtIndex:(NSUInteger)idx;
- (void)insertRowContent:(NSArray<Contents *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRowContentAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRowContentAtIndex:(NSUInteger)idx withObject:(Contents *)value;
- (void)replaceRowContentAtIndexes:(NSIndexSet *)indexes withRowContent:(NSArray<Contents *> *)values;
- (void)addRowContentObject:(Contents *)value;
- (void)removeRowContentObject:(Contents *)value;
- (void)addRowContent:(NSOrderedSet<Contents *> *)values;
- (void)removeRowContent:(NSOrderedSet<Contents *> *)values;

@end

NS_ASSUME_NONNULL_END
