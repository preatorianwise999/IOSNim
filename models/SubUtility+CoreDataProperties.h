//
//  SubUtility+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SubUtility.h"

NS_ASSUME_NONNULL_BEGIN

@interface SubUtility (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<UtilityDetails *> *subToDetail;

@end

@interface SubUtility (CoreDataGeneratedAccessors)

- (void)addSubToDetailObject:(UtilityDetails *)value;
- (void)removeSubToDetailObject:(UtilityDetails *)value;
- (void)addSubToDetail:(NSSet<UtilityDetails *> *)values;
- (void)removeSubToDetail:(NSSet<UtilityDetails *> *)values;

@end

NS_ASSUME_NONNULL_END
