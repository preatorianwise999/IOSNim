//
//  FeildValues+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FeildValues.h"

NS_ASSUME_NONNULL_BEGIN

@interface FeildValues (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *active;
@property (nullable, nonatomic, retain) NSString *optionCode;
@property (nullable, nonatomic, retain) NSString *valueES;
@property (nullable, nonatomic, retain) NSString *valuePT;

@end

NS_ASSUME_NONNULL_END
