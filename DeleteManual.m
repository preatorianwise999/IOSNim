//
//  DeleteManual.m
//  Nimbus2
//
//  Created by Sravani Nagunuri on 04/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "DeleteManual.h"
#import "AppDelegate.h"
#import "ManualLinks.h"
#import "Manuals.h"
#import "StoreManuals.h"

@implementation DeleteManual

//delete given manual from DB

- (void)deleteManual: (NSDictionary*)manual {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Manuals" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: entityDescription];
    NSString *filePath = [[manual objectForKey:kManualPath] stringByStandardizingPath];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"filePath == %@", filePath];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        
        //delete manuallinks & manuals
        Manuals *manual = [results objectAtIndex:0];
        NSOrderedSet *manualLinks = [manual linkManual];
        for (ManualLinks *manualLink in manualLinks) {
            [managedObjectContext deleteObject: manualLink];
        }
        [managedObjectContext deleteObject: manual];
    }
    
    if(![managedObjectContext save:&error]) {
        NSLog(@"error in saving Customer%@",[error description]);
    }
}

@end
