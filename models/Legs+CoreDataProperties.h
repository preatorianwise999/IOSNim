//
//  Legs+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 1/14/16.
//  Copyright © 2016 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Legs.h"

NS_ASSUME_NONNULL_BEGIN

@interface Legs (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *businessUnit;
@property (nullable, nonatomic, retain) NSString *destination;
@property (nullable, nonatomic, retain) NSDate *legArrivalLocal;
@property (nullable, nonatomic, retain) NSDate *legArrivalUTC;
@property (nullable, nonatomic, retain) NSDate *legDepartureLocal;
@property (nullable, nonatomic, retain) NSDate *legDepartureUTC;
@property (nullable, nonatomic, retain) NSString *origin;
@property (nullable, nonatomic, retain) NSOrderedSet<ClassType *> *legClass;
@property (nullable, nonatomic, retain) NSOrderedSet<Customer *> *legCustomer;
@property (nullable, nonatomic, retain) Report *legFlightReport;
@property (nullable, nonatomic, retain) NSOrderedSet<NoticeHead *> *legHeading;
@property (nullable, nonatomic, retain) NSOrderedSet<CrewMembers *> *legsCrewmember;
@property (nullable, nonatomic, retain) NSOrderedSet<SpecialCases *> *legSpecialCase;
@property (nullable, nonatomic, retain) Stats *legStats;
@property (nullable, nonatomic, retain) NSOrderedSet<UtilityType *> *legUtility;
@property (nullable, nonatomic, retain) NSOrderedSet<SpecialMealInfoHead *> *specialMealInfoHead;

@end

@interface Legs (CoreDataGeneratedAccessors)

- (void)insertObject:(ClassType *)value inLegClassAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLegClassAtIndex:(NSUInteger)idx;
- (void)insertLegClass:(NSArray<ClassType *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLegClassAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLegClassAtIndex:(NSUInteger)idx withObject:(ClassType *)value;
- (void)replaceLegClassAtIndexes:(NSIndexSet *)indexes withLegClass:(NSArray<ClassType *> *)values;
- (void)addLegClassObject:(ClassType *)value;
- (void)removeLegClassObject:(ClassType *)value;
- (void)addLegClass:(NSOrderedSet<ClassType *> *)values;
- (void)removeLegClass:(NSOrderedSet<ClassType *> *)values;

- (void)insertObject:(Customer *)value inLegCustomerAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLegCustomerAtIndex:(NSUInteger)idx;
- (void)insertLegCustomer:(NSArray<Customer *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLegCustomerAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLegCustomerAtIndex:(NSUInteger)idx withObject:(Customer *)value;
- (void)replaceLegCustomerAtIndexes:(NSIndexSet *)indexes withLegCustomer:(NSArray<Customer *> *)values;
- (void)addLegCustomerObject:(Customer *)value;
- (void)removeLegCustomerObject:(Customer *)value;
- (void)addLegCustomer:(NSOrderedSet<Customer *> *)values;
- (void)removeLegCustomer:(NSOrderedSet<Customer *> *)values;

- (void)insertObject:(NoticeHead *)value inLegHeadingAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLegHeadingAtIndex:(NSUInteger)idx;
- (void)insertLegHeading:(NSArray<NoticeHead *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLegHeadingAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLegHeadingAtIndex:(NSUInteger)idx withObject:(NoticeHead *)value;
- (void)replaceLegHeadingAtIndexes:(NSIndexSet *)indexes withLegHeading:(NSArray<NoticeHead *> *)values;
- (void)addLegHeadingObject:(NoticeHead *)value;
- (void)removeLegHeadingObject:(NoticeHead *)value;
- (void)addLegHeading:(NSOrderedSet<NoticeHead *> *)values;
- (void)removeLegHeading:(NSOrderedSet<NoticeHead *> *)values;

- (void)insertObject:(CrewMembers *)value inLegsCrewmemberAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLegsCrewmemberAtIndex:(NSUInteger)idx;
- (void)insertLegsCrewmember:(NSArray<CrewMembers *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLegsCrewmemberAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLegsCrewmemberAtIndex:(NSUInteger)idx withObject:(CrewMembers *)value;
- (void)replaceLegsCrewmemberAtIndexes:(NSIndexSet *)indexes withLegsCrewmember:(NSArray<CrewMembers *> *)values;
- (void)addLegsCrewmemberObject:(CrewMembers *)value;
- (void)removeLegsCrewmemberObject:(CrewMembers *)value;
- (void)addLegsCrewmember:(NSOrderedSet<CrewMembers *> *)values;
- (void)removeLegsCrewmember:(NSOrderedSet<CrewMembers *> *)values;

- (void)insertObject:(SpecialCases *)value inLegSpecialCaseAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLegSpecialCaseAtIndex:(NSUInteger)idx;
- (void)insertLegSpecialCase:(NSArray<SpecialCases *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLegSpecialCaseAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLegSpecialCaseAtIndex:(NSUInteger)idx withObject:(SpecialCases *)value;
- (void)replaceLegSpecialCaseAtIndexes:(NSIndexSet *)indexes withLegSpecialCase:(NSArray<SpecialCases *> *)values;
- (void)addLegSpecialCaseObject:(SpecialCases *)value;
- (void)removeLegSpecialCaseObject:(SpecialCases *)value;
- (void)addLegSpecialCase:(NSOrderedSet<SpecialCases *> *)values;
- (void)removeLegSpecialCase:(NSOrderedSet<SpecialCases *> *)values;

- (void)insertObject:(UtilityType *)value inLegUtilityAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLegUtilityAtIndex:(NSUInteger)idx;
- (void)insertLegUtility:(NSArray<UtilityType *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLegUtilityAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLegUtilityAtIndex:(NSUInteger)idx withObject:(UtilityType *)value;
- (void)replaceLegUtilityAtIndexes:(NSIndexSet *)indexes withLegUtility:(NSArray<UtilityType *> *)values;
- (void)addLegUtilityObject:(UtilityType *)value;
- (void)removeLegUtilityObject:(UtilityType *)value;
- (void)addLegUtility:(NSOrderedSet<UtilityType *> *)values;
- (void)removeLegUtility:(NSOrderedSet<UtilityType *> *)values;

- (void)insertObject:(SpecialMealInfoHead *)value inSpecialMealInfoHeadAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSpecialMealInfoHeadAtIndex:(NSUInteger)idx;
- (void)insertSpecialMealInfoHead:(NSArray<SpecialMealInfoHead *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSpecialMealInfoHeadAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSpecialMealInfoHeadAtIndex:(NSUInteger)idx withObject:(SpecialMealInfoHead *)value;
- (void)replaceSpecialMealInfoHeadAtIndexes:(NSIndexSet *)indexes withSpecialMealInfoHead:(NSArray<SpecialMealInfoHead *> *)values;
- (void)addSpecialMealInfoHeadObject:(SpecialMealInfoHead *)value;
- (void)removeSpecialMealInfoHeadObject:(SpecialMealInfoHead *)value;
- (void)addSpecialMealInfoHead:(NSOrderedSet<SpecialMealInfoHead *> *)values;
- (void)removeSpecialMealInfoHead:(NSOrderedSet<SpecialMealInfoHead *> *)values;

@end

NS_ASSUME_NONNULL_END
