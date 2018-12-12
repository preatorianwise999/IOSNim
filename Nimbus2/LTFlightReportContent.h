//
//  LTFlightReportContent.h
//  LATAM
//
//  Created by Palash on 07/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TempLocalStorageModel.h"

@interface LTFlightReportContent : NSObject
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)insertReportFromDict:(NSDictionary*)reportDict;

@end
