//
//  ReportUpdate+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ReportUpdate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReportUpdate (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *isFull;
@property (nullable, nonatomic, retain) NSString *uriChanges;
@property (nullable, nonatomic, retain) NSOrderedSet<ReportType *> *typeReort;

@end

@interface ReportUpdate (CoreDataGeneratedAccessors)

- (void)insertObject:(ReportType *)value inTypeReortAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTypeReortAtIndex:(NSUInteger)idx;
- (void)insertTypeReort:(NSArray<ReportType *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTypeReortAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTypeReortAtIndex:(NSUInteger)idx withObject:(ReportType *)value;
- (void)replaceTypeReortAtIndexes:(NSIndexSet *)indexes withTypeReort:(NSArray<ReportType *> *)values;
- (void)addTypeReortObject:(ReportType *)value;
- (void)removeTypeReortObject:(ReportType *)value;
- (void)addTypeReort:(NSOrderedSet<ReportType *> *)values;
- (void)removeTypeReort:(NSOrderedSet<ReportType *> *)values;

@end

NS_ASSUME_NONNULL_END
