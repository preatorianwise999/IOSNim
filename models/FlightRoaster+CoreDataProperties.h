//
//  FlightRoaster+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 3/31/16.
//  Copyright © 2016 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FlightRoaster.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlightRoaster (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *airlineCode;
@property (nullable, nonatomic, retain) NSDate *briefingEndTime;
@property (nullable, nonatomic, retain) NSDate *briefingStartTime;
@property (nullable, nonatomic, retain) NSString *businessUnit;
@property (nullable, nonatomic, retain) NSString *company;
@property (nullable, nonatomic, retain) NSNumber *counter;
@property (nullable, nonatomic, retain) NSDate *crewEntryTime;
@property (nullable, nonatomic, retain) NSDate *flightDate;
@property (nullable, nonatomic, retain) NSString *flightNumber;
@property (nullable, nonatomic, retain) NSString *flightReport;
@property (nullable, nonatomic, retain) NSNumber *flightReportSynched;
@property (nullable, nonatomic, retain) NSString *gateNumber;
@property (nullable, nonatomic, retain) NSNumber *isDataSaved;
@property (nullable, nonatomic, retain) NSNumber *isFlightSeatMapSynched;
@property (nullable, nonatomic, retain) NSNumber *isFlownAsJSB;
@property (nullable, nonatomic, retain) NSNumber *isManualyEntered;
@property (nullable, nonatomic, retain) NSNumber *isPassengerDetailsAvailable;
@property (nullable, nonatomic, retain) NSNumber *isPassengerListAvailable;
@property (nullable, nonatomic, retain) NSNumber *isPublicationSynched;
@property (nullable, nonatomic, retain) NSDate *lastSynchTime;
@property (nullable, nonatomic, retain) NSNumber *manulaCrewAdded;
@property (nullable, nonatomic, retain) NSString *material;
@property (nullable, nonatomic, retain) NSString *materialType;
@property (nullable, nonatomic, retain) NSDate *passengerEntryTime;
@property (nullable, nonatomic, retain) NSDate *sortTime;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *suffix;
@property (nullable, nonatomic, retain) NSString *tailNumber;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSOrderedSet<Legs *> *flightInfoLegs;
@property (nullable, nonatomic, retain) NSOrderedSet<Publication *> *flightPublication;
@property (nullable, nonatomic, retain) NSSet<SeatMap *> *flightSeatMap;
@property (nullable, nonatomic, retain) Uris *flightUri;
@property (nullable, nonatomic, retain) User *userFlifghtInfo;

@end

@interface FlightRoaster (CoreDataGeneratedAccessors)

- (void)insertObject:(Legs *)value inFlightInfoLegsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFlightInfoLegsAtIndex:(NSUInteger)idx;
- (void)insertFlightInfoLegs:(NSArray<Legs *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFlightInfoLegsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFlightInfoLegsAtIndex:(NSUInteger)idx withObject:(Legs *)value;
- (void)replaceFlightInfoLegsAtIndexes:(NSIndexSet *)indexes withFlightInfoLegs:(NSArray<Legs *> *)values;
- (void)addFlightInfoLegsObject:(Legs *)value;
- (void)removeFlightInfoLegsObject:(Legs *)value;
- (void)addFlightInfoLegs:(NSOrderedSet<Legs *> *)values;
- (void)removeFlightInfoLegs:(NSOrderedSet<Legs *> *)values;

- (void)insertObject:(Publication *)value inFlightPublicationAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFlightPublicationAtIndex:(NSUInteger)idx;
- (void)insertFlightPublication:(NSArray<Publication *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFlightPublicationAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFlightPublicationAtIndex:(NSUInteger)idx withObject:(Publication *)value;
- (void)replaceFlightPublicationAtIndexes:(NSIndexSet *)indexes withFlightPublication:(NSArray<Publication *> *)values;
- (void)addFlightPublicationObject:(Publication *)value;
- (void)removeFlightPublicationObject:(Publication *)value;
- (void)addFlightPublication:(NSOrderedSet<Publication *> *)values;
- (void)removeFlightPublication:(NSOrderedSet<Publication *> *)values;

- (void)addFlightSeatMapObject:(SeatMap *)value;
- (void)removeFlightSeatMapObject:(SeatMap *)value;
- (void)addFlightSeatMap:(NSSet<SeatMap *> *)values;
- (void)removeFlightSeatMap:(NSSet<SeatMap *> *)values;

@end

NS_ASSUME_NONNULL_END
