//
//  CreateManuals.m
//  Nimbus2
//
//  Created by Sravani Nagunuri on 05/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "CreateManuals.h"
#import "AppDelegate.h"
#import "Manuals.h"
#import "ManualLinks.h"
#import "StoreManuals.h"
//#import "TempLocalStorageModel.h"

@implementation CreateManuals

//adding given manual to DB
- (void)addManualFromDict: (NSDictionary*)manualDict {
    //Synch Manuals based on the response
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    Manuals *manual = (Manuals*)[NSEntityDescription insertNewObjectForEntityForName:@"Manuals"
                                                              inManagedObjectContext:managedObjectContext];
    [manual setFilePath: [manualDict objectForKey: kManualPath]];
    [manual setSize: [manualDict objectForKey: kManualSize]];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDate *date = [dateFormater dateFromString: [manualDict objectForKey:kManualDate]];
    [manual setDate: date];
    [manual setDownloadStatus: DOWNLOAD_STATUS_FAIL];
    [manual setStatusMessage: DOWNLOAD_STATUS_MESSAGE];
    
    ManualLinks *manualLinks = (ManualLinks*)[NSEntityDescription insertNewObjectForEntityForName:@"ManualLinks"  inManagedObjectContext:managedObjectContext];
    NSString *uri= [manualDict objectForKey: kManualURI];
    uri=[uri stringByReplacingOccurrencesOfString:@" |" withString:@"/"];
    [manualLinks setUriManual:uri];
    [manual addLinkManualObject: manualLinks];
    
    NSError *error = nil;
    if(![managedObjectContext save:&error]) {
        DLog(@"error in saving Customer%@",[error description]);
    }
}

//updating manual download status

- (void)updateManual:(NSDictionary *)manualDict forFilePath:(NSString *)filePath{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Manuals" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filePath == %@",filePath];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        Manuals *manual = [results objectAtIndex: 0];
        [manual setDownloadStatus: DOWNLOAD_STATUS_FAIL];//[manualDict objectForKey:@"DownloadStatus"]];
        [manual setStatusMessage:DOWNLOAD_STATUS_FAIL];//[manualDict objectForKey:@"StatusMessage"]];
        [manual setDate:[manualDict objectForKey:kManualDate]];
    }
    if(![managedObjectContext save:&error]) {
        DLog(@"error in saving Customer%@",[error description]);
    }
}


-(void)updateFile:(NSDictionary*)manualDict path:(NSString*)predicateStr
{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Manuals" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: entityDescription];
    
    if (predicateStr) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateStr];
        [request setPredicate:predicate];
    }
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        Manuals *manual = [results objectAtIndex: 0];
        [manual setDownloadStatus: DOWNLOAD_STATUS_SUCCESS];
        [manual setStatusMessage:DOWNLOAD_STATUS_SUCCESS];
        // [manual setDate:[manualDict objectForKey:kManualDate]];
        // NSString *filePath= [[manual filePath] stringByReplacingOccurrencesOfString:@"_new" withString:@""];
        NSString *filePath= [[manual filePath] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%@",[appdelegate copyTextForKey:@"NEW"]] withString:@""];
        [manual setFilePath:filePath];
    }
    if(![managedObjectContext save:&error]) {
        DLog(@"error in saving Customer%@",[error description]);
    }
}

- (void)updateSuccessDownloadForManualWithPredicate: (NSString*)predicateStr {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Manuals" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: entityDescription];
    if (predicateStr) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateStr];
        [request setPredicate:predicate];
    }
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        Manuals *manual = [results objectAtIndex: 0];
        [manual setDownloadStatus: DOWNLOAD_STATUS_SUCCESS];
        [manual setStatusMessage:DOWNLOAD_STATUS_SUCCESS];
    }
    
    if(![managedObjectContext save:&error]) {
        DLog(@"error in saving Customer%@",[error description]);
    }
}

-(void)updateFail:(NSString*)predicateStr {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Manuals" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: entityDescription];
    if (predicateStr) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateStr];
        [request setPredicate:predicate];
    }
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        Manuals *manual = [results objectAtIndex: 0];
        [manual setDownloadStatus: DOWNLOAD_STATUS_FAIL];
        [manual setStatusMessage:DOWNLOAD_STATUS_FAIL];
    }
    if(![managedObjectContext save:&error]) {
        DLog(@"error in saving Customer%@",[error description]);
    }
}

@end
