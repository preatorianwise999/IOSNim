//
//  User+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *bp;
@property (nullable, nonatomic, retain) NSString *crewBase;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSOrderedSet<FlightRoaster *> *flightRosters;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)insertObject:(FlightRoaster *)value inFlightRostersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFlightRostersAtIndex:(NSUInteger)idx;
- (void)insertFlightRosters:(NSArray<FlightRoaster *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFlightRostersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFlightRostersAtIndex:(NSUInteger)idx withObject:(FlightRoaster *)value;
- (void)replaceFlightRostersAtIndexes:(NSIndexSet *)indexes withFlightRosters:(NSArray<FlightRoaster *> *)values;
- (void)addFlightRostersObject:(FlightRoaster *)value;
- (void)removeFlightRostersObject:(FlightRoaster *)value;
- (void)addFlightRosters:(NSOrderedSet<FlightRoaster *> *)values;
- (void)removeFlightRosters:(NSOrderedSet<FlightRoaster *> *)values;

@end

NS_ASSUME_NONNULL_END
