//
//  FlightReports+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FlightReports.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlightReports (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSOrderedSet<Sections *> *reportSection;

@end

@interface FlightReports (CoreDataGeneratedAccessors)

- (void)insertObject:(Sections *)value inReportSectionAtIndex:(NSUInteger)idx;
- (void)removeObjectFromReportSectionAtIndex:(NSUInteger)idx;
- (void)insertReportSection:(NSArray<Sections *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeReportSectionAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInReportSectionAtIndex:(NSUInteger)idx withObject:(Sections *)value;
- (void)replaceReportSectionAtIndexes:(NSIndexSet *)indexes withReportSection:(NSArray<Sections *> *)values;
- (void)addReportSectionObject:(Sections *)value;
- (void)removeReportSectionObject:(Sections *)value;
- (void)addReportSection:(NSOrderedSet<Sections *> *)values;
- (void)removeReportSection:(NSOrderedSet<Sections *> *)values;

@end

NS_ASSUME_NONNULL_END
