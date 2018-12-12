//
//  Report+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Report.h"

NS_ASSUME_NONNULL_BEGIN

@interface Report (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *flightType;
@property (nullable, nonatomic, retain) NSString *reportName;
@property (nullable, nonatomic, retain) NSDate *sentDate;
@property (nullable, nonatomic, retain) NSNumber *version;
@property (nullable, nonatomic, retain) NSOrderedSet<FlightReports *> *flightReportReport;

@end

@interface Report (CoreDataGeneratedAccessors)

- (void)insertObject:(FlightReports *)value inFlightReportReportAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFlightReportReportAtIndex:(NSUInteger)idx;
- (void)insertFlightReportReport:(NSArray<FlightReports *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFlightReportReportAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFlightReportReportAtIndex:(NSUInteger)idx withObject:(FlightReports *)value;
- (void)replaceFlightReportReportAtIndexes:(NSIndexSet *)indexes withFlightReportReport:(NSArray<FlightReports *> *)values;
- (void)addFlightReportReportObject:(FlightReports *)value;
- (void)removeFlightReportReportObject:(FlightReports *)value;
- (void)addFlightReportReport:(NSOrderedSet<FlightReports *> *)values;
- (void)removeFlightReportReport:(NSOrderedSet<FlightReports *> *)values;

@end

NS_ASSUME_NONNULL_END
