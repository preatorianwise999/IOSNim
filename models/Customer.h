//
//  Customer.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 1/13/16.
//  Copyright © 2016 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Accompany, Connection, CusReport, Legs, Solicitudes, SpecialMeal;

NS_ASSUME_NONNULL_BEGIN

@interface Customer : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Customer+CoreDataProperties.h"
