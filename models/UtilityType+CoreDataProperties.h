//
//  UtilityType+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UtilityType.h"

NS_ASSUME_NONNULL_BEGIN

@interface UtilityType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<SubUtility *> *utilSubUtil;

@end

@interface UtilityType (CoreDataGeneratedAccessors)

- (void)addUtilSubUtilObject:(SubUtility *)value;
- (void)removeUtilSubUtilObject:(SubUtility *)value;
- (void)addUtilSubUtil:(NSSet<SubUtility *> *)values;
- (void)removeUtilSubUtil:(NSSet<SubUtility *> *)values;

@end

NS_ASSUME_NONNULL_END
