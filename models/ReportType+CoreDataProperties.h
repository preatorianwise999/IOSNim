//
//  ReportType+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ReportType.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReportType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *version;
@property (nullable, nonatomic, retain) NSOrderedSet<FlightReports *> *typeFlightReport;

@end

@interface ReportType (CoreDataGeneratedAccessors)

- (void)insertObject:(FlightReports *)value inTypeFlightReportAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTypeFlightReportAtIndex:(NSUInteger)idx;
- (void)insertTypeFlightReport:(NSArray<FlightReports *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTypeFlightReportAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTypeFlightReportAtIndex:(NSUInteger)idx withObject:(FlightReports *)value;
- (void)replaceTypeFlightReportAtIndexes:(NSIndexSet *)indexes withTypeFlightReport:(NSArray<FlightReports *> *)values;
- (void)addTypeFlightReportObject:(FlightReports *)value;
- (void)removeTypeFlightReportObject:(FlightReports *)value;
- (void)addTypeFlightReport:(NSOrderedSet<FlightReports *> *)values;
- (void)removeTypeFlightReport:(NSOrderedSet<FlightReports *> *)values;

@end

NS_ASSUME_NONNULL_END
