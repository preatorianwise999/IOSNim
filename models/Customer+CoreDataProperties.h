//
//  Customer+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 1/13/16.
//  Copyright © 2016 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Customer.h"

NS_ASSUME_NONNULL_BEGIN

@interface Customer (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *accountStatus;
@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSNumber *attempts;
@property (nullable, nonatomic, retain) NSString *customerId;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSDate *dateOfBirth;
@property (nullable, nonatomic, retain) NSString *docNumber;
@property (nullable, nonatomic, retain) NSString *docType;
@property (nullable, nonatomic, retain) NSString *editCodes;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *freqFlyerCategory;
@property (nullable, nonatomic, retain) NSString *freqFlyerComp;
@property (nullable, nonatomic, retain) NSString *freqFlyerNum;
@property (nullable, nonatomic, retain) NSString *gender;
@property (nullable, nonatomic, retain) NSString *groupCode;
@property (nullable, nonatomic, retain) NSNumber *haConnection;
@property (nullable, nonatomic, retain) NSNumber *hasSpecialMeal;
@property (nullable, nonatomic, retain) NSNumber *isChild;
@property (nullable, nonatomic, retain) NSNumber *isWCH;
@property (nullable, nonatomic, retain) NSString *language;
@property (nullable, nonatomic, retain) NSString *lanPassCategory;
@property (nullable, nonatomic, retain) NSString *lanPassKms;
@property (nullable, nonatomic, retain) NSNumber *lanPassUpgrade;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSNumber *manuallyAdded;
@property (nullable, nonatomic, retain) NSString *seatNumber;
@property (nullable, nonatomic, retain) NSString *secondLastName;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSDate *synchDate;
@property (nullable, nonatomic, retain) NSString *vipCategory;
@property (nullable, nonatomic, retain) NSString *vipRemarks;
@property (nullable, nonatomic, retain) NSString *vipSpecialAttentions;
@property (nullable, nonatomic, retain) NSSet<Accompany *> *cusAccompany;
@property (nullable, nonatomic, retain) NSOrderedSet<Connection *> *cusConnection;
@property (nullable, nonatomic, retain) NSOrderedSet<CusReport *> *cusCusReport;
@property (nullable, nonatomic, retain) Legs *cusLeg;
@property (nullable, nonatomic, retain) NSSet<Solicitudes *> *cusSolicitudes;
@property (nullable, nonatomic, retain) NSOrderedSet<SpecialMeal *> *specialMeals;

@end

@interface Customer (CoreDataGeneratedAccessors)

- (void)addCusAccompanyObject:(Accompany *)value;
- (void)removeCusAccompanyObject:(Accompany *)value;
- (void)addCusAccompany:(NSSet<Accompany *> *)values;
- (void)removeCusAccompany:(NSSet<Accompany *> *)values;

- (void)insertObject:(Connection *)value inCusConnectionAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCusConnectionAtIndex:(NSUInteger)idx;
- (void)insertCusConnection:(NSArray<Connection *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCusConnectionAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCusConnectionAtIndex:(NSUInteger)idx withObject:(Connection *)value;
- (void)replaceCusConnectionAtIndexes:(NSIndexSet *)indexes withCusConnection:(NSArray<Connection *> *)values;
- (void)addCusConnectionObject:(Connection *)value;
- (void)removeCusConnectionObject:(Connection *)value;
- (void)addCusConnection:(NSOrderedSet<Connection *> *)values;
- (void)removeCusConnection:(NSOrderedSet<Connection *> *)values;

- (void)insertObject:(CusReport *)value inCusCusReportAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCusCusReportAtIndex:(NSUInteger)idx;
- (void)insertCusCusReport:(NSArray<CusReport *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCusCusReportAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCusCusReportAtIndex:(NSUInteger)idx withObject:(CusReport *)value;
- (void)replaceCusCusReportAtIndexes:(NSIndexSet *)indexes withCusCusReport:(NSArray<CusReport *> *)values;
- (void)addCusCusReportObject:(CusReport *)value;
- (void)removeCusCusReportObject:(CusReport *)value;
- (void)addCusCusReport:(NSOrderedSet<CusReport *> *)values;
- (void)removeCusCusReport:(NSOrderedSet<CusReport *> *)values;

- (void)addCusSolicitudesObject:(Solicitudes *)value;
- (void)removeCusSolicitudesObject:(Solicitudes *)value;
- (void)addCusSolicitudes:(NSSet<Solicitudes *> *)values;
- (void)removeCusSolicitudes:(NSSet<Solicitudes *> *)values;

- (void)insertObject:(SpecialMeal *)value inSpecialMealsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSpecialMealsAtIndex:(NSUInteger)idx;
- (void)insertSpecialMeals:(NSArray<SpecialMeal *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSpecialMealsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSpecialMealsAtIndex:(NSUInteger)idx withObject:(SpecialMeal *)value;
- (void)replaceSpecialMealsAtIndexes:(NSIndexSet *)indexes withSpecialMeals:(NSArray<SpecialMeal *> *)values;
- (void)addSpecialMealsObject:(SpecialMeal *)value;
- (void)removeSpecialMealsObject:(SpecialMeal *)value;
- (void)addSpecialMeals:(NSOrderedSet<SpecialMeal *> *)values;
- (void)removeSpecialMeals:(NSOrderedSet<SpecialMeal *> *)values;

@end

NS_ASSUME_NONNULL_END
