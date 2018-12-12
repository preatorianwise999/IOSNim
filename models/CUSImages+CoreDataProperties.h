//
//  CUSImages+CoreDataProperties.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/25/15.
//  Copyright © 2015 TCS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CUSImages.h"

NS_ASSUME_NONNULL_BEGIN

@interface CUSImages (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *image1;
@property (nullable, nonatomic, retain) NSString *image2;
@property (nullable, nonatomic, retain) NSString *image3;
@property (nullable, nonatomic, retain) NSString *image4;
@property (nullable, nonatomic, retain) NSString *image5;

@end

NS_ASSUME_NONNULL_END
