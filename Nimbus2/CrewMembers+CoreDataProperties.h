//
//  CrewMembers+CoreDataProperties.h
//  Nimbus2
//
//  Created by 720368 on 10/19/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CrewMembers.h"

NS_ASSUME_NONNULL_BEGIN

@interface CrewMembers (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *activeRank;
@property (nullable, nonatomic, retain) NSNumber *attempts;
@property (nullable, nonatomic, retain) NSString *base;
@property (nullable, nonatomic, retain) NSString *bp;
@property (nullable, nonatomic, retain) NSString *category;
@property (nullable, nonatomic, retain) NSNumber *eaAttemts;
@property (nullable, nonatomic, retain) NSNumber *errorAttempts;
@property (nullable, nonatomic, retain) NSNumber *expectedGAD;
@property (nullable, nonatomic, retain) NSNumber *filledGAD;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *imageUrl;
@property (nullable, nonatomic, retain) NSNumber *isManuallyAdded;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSDate *licencceDate;
@property (nullable, nonatomic, retain) NSString *licenceNo;
@property (nullable, nonatomic, retain) NSString *specialRank;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSDate *synchDate;
@property (nullable, nonatomic, retain) NSNumber *realizedGAD;
@property (nullable, nonatomic, retain) NSOrderedSet<GADCategory *> *crewCategory;
@property (nullable, nonatomic, retain) GADComments *crewComments;

@end

@interface CrewMembers (CoreDataGeneratedAccessors)

- (void)insertObject:(GADCategory *)value inCrewCategoryAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCrewCategoryAtIndex:(NSUInteger)idx;
- (void)insertCrewCategory:(NSArray<GADCategory *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCrewCategoryAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCrewCategoryAtIndex:(NSUInteger)idx withObject:(GADCategory *)value;
- (void)replaceCrewCategoryAtIndexes:(NSIndexSet *)indexes withCrewCategory:(NSArray<GADCategory *> *)values;
- (void)addCrewCategoryObject:(GADCategory *)value;
- (void)removeCrewCategoryObject:(GADCategory *)value;
- (void)addCrewCategory:(NSOrderedSet<GADCategory *> *)values;
- (void)removeCrewCategory:(NSOrderedSet<GADCategory *> *)values;

@end

NS_ASSUME_NONNULL_END
