//
//  CusReport+CoreDataProperties.h
//  Nimbus2
//
//  Created by 720368 on 1/13/16.
//  Copyright © 2016 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CusReport.h"

NS_ASSUME_NONNULL_BEGIN

@interface CusReport (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *reportId;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSDate *synchDate;
@property (nullable, nonatomic, retain) NSNumber *attempts;
@property (nullable, nonatomic, retain) NSString *imageLoadUrl;
@property (nullable, nonatomic, retain) CUSImages *reportCusImages;
@property (nullable, nonatomic, retain) NSOrderedSet<Groups *> *reportGroup;

@end

@interface CusReport (CoreDataGeneratedAccessors)

- (void)insertObject:(Groups *)value inReportGroupAtIndex:(NSUInteger)idx;
- (void)removeObjectFromReportGroupAtIndex:(NSUInteger)idx;
- (void)insertReportGroup:(NSArray<Groups *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeReportGroupAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInReportGroupAtIndex:(NSUInteger)idx withObject:(Groups *)value;
- (void)replaceReportGroupAtIndexes:(NSIndexSet *)indexes withReportGroup:(NSArray<Groups *> *)values;
- (void)addReportGroupObject:(Groups *)value;
- (void)removeReportGroupObject:(Groups *)value;
- (void)addReportGroup:(NSOrderedSet<Groups *> *)values;
- (void)removeReportGroup:(NSOrderedSet<Groups *> *)values;

@end

NS_ASSUME_NONNULL_END
