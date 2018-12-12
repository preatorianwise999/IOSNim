//
//  Stats+CoreDataProperties.h
//  Nimbus2
//
//  Created by 720368 on 1/14/16.
//  Copyright © 2016 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Stats.h"

NS_ASSUME_NONNULL_BEGIN

@interface Stats (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *numpj;
@property (nullable, nonatomic, retain) NSNumber *numpy;
@property (nullable, nonatomic, retain) NSNumber *umnr;
@property (nullable, nonatomic, retain) NSNumber *wchc;
@property (nullable, nonatomic, retain) NSNumber *wchr;
@property (nullable, nonatomic, retain) NSNumber *wchs;

@end

NS_ASSUME_NONNULL_END
