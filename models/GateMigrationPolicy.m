//
//  GateMigrationPolicy.m
//  Nimbus2
//
//  Created by Diego Cathalifaud on 3/31/16.
//  Copyright © 2016 TCS. All rights reserved.
//

#import "GateMigrationPolicy.h"

@implementation GateMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError **)error {
    
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName] inManagedObjectContext:[manager destinationContext]];
    
    // Copy all the values from sInstance into newObject, making sure to apply the conversion for the string to int when appropriate. So you should have one of these for each attribute:
    [newObject setValue:[[sInstance valueForKey:@"gateNumber"] stringValue] forKey:@"gateNumber"];
    
    [manager associateSourceInstance:sInstance withDestinationInstance:newObject forEntityMapping:mapping];
    
    return YES;
}

@end
