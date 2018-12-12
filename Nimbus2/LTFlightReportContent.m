//
//  LTFlightReportContent.m
//  LATAM
//
//  Created by Palash on 07/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTFlightReportContent.h"
#import "AllDb.h"
#import "AppDelegate.h"
@implementation LTFlightReportContent

-(void)insertReportFromDict:(NSDictionary*)reportDict {
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSPersistentStoreCoordinator *coordinator = [appDel persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    NSDictionary *langDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EnglishKey" ofType:@"plist"]];
    
    NSMutableDictionary *updateDict = [reportDict valueForKey:@"fligthReportContentByVersion"];
    //check if report update object exist
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"ReportUpdate"];
    NSError *error;
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
    ReportUpdate *repoUp;
    if ([results count] > 0) { //Rport update exists
        repoUp = (ReportUpdate *)[results objectAtIndex:0];
    }else{//Report Update does not exist
        repoUp = (ReportUpdate*)[NSEntityDescription insertNewObjectForEntityForName:@"ReportUpdate" inManagedObjectContext:self.managedObjectContext];
    }
    if ([updateDict objectForKey:@"uriChanges"]!=nil) {
        repoUp.uriChanges = [updateDict objectForKey:@"uriChanges"];
        [TempLocalStorageModel saveInUserDefaults:[updateDict objectForKey:@"uriChanges"] withKey:kContentByVersionUri];
    }
    
    if ([updateDict valueForKey:@"flag"]) {
        [repoUp setIsFull:[NSNumber numberWithBool:TRUE]];
    }else{
        [repoUp setIsFull:[NSNumber numberWithBool:FALSE]];
    }
    
    NSArray *reportTypeArr = [updateDict valueForKey:@"typeReports"];
    
    for (NSDictionary *typeDict in reportTypeArr) {
        ReportType *typeReport;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@",[typeDict objectForKey:@"name"]];
        NSArray *results = [[repoUp.typeReort array] filteredArrayUsingPredicate:predicate];
        if ([results count] > 0) {
            typeReport = (ReportType*)[results objectAtIndex:0];
        } else {
            typeReport = [NSEntityDescription insertNewObjectForEntityForName:@"ReportType" inManagedObjectContext:_managedObjectContext];
        }
        
        //typeReport.version = [typeDict objectForKey:@"version"];
        typeReport.type = [typeDict objectForKey:@"name"];
        [repoUp addTypeReortObject:typeReport];
        NSArray *arr = [typeDict objectForKey:@"reports"];
        for (NSDictionary *dict in arr) {
            ///check if Flight Report of same name exists or not
            FlightReports *report;
            predicate = [NSPredicate predicateWithFormat:@"name == %@",[langDict objectForKey:[dict objectForKey:@"name"]]];
            
            NSArray *results = [[typeReport.typeFlightReport array] filteredArrayUsingPredicate:predicate];
            if ([results count] > 0) {
                report = (FlightReports*)[results objectAtIndex:0];
            } else {
                report = [NSEntityDescription insertNewObjectForEntityForName:@"FlightReports" inManagedObjectContext:self.managedObjectContext];
            }
            
            [typeReport addTypeFlightReportObject:report];
            report.name = [langDict objectForKey:[dict valueForKey:@"name"]];
            NSMutableArray *sectionArr = [dict valueForKey:@"sections"];
            for (NSDictionary *sectionDict in sectionArr) {
                Sections *section;
                predicate = [NSPredicate predicateWithFormat:@"name ==%@",[langDict objectForKey:[sectionDict objectForKey:@"name"]]];
                NSArray *results = [[report.reportSection array] filteredArrayUsingPredicate:predicate];
                if ([results count] > 0) {
                    section = [results objectAtIndex:0];
                } else {
                    section = [NSEntityDescription insertNewObjectForEntityForName:@"Sections" inManagedObjectContext:_managedObjectContext];
                    [report addReportSectionObject:section];
                }
                
                section.name = [langDict objectForKey:[sectionDict objectForKey:@"name"]];
                NSArray *groupArr = [sectionDict objectForKey:@"groups"];
                for (NSDictionary *grpDict in groupArr) {
                    Groups *group;
                    predicate = [NSPredicate predicateWithFormat:@"name == %@",[langDict objectForKey:[grpDict objectForKey:@"name"]]];
                    results = [[section.sectionGroup array] filteredArrayUsingPredicate:predicate];
                    if ([results count]>0) {
                        group = (Groups*)[results objectAtIndex:0];
                    } else {
                        group = [NSEntityDescription insertNewObjectForEntityForName:@"Groups" inManagedObjectContext:_managedObjectContext];
                        [section addSectionGroupObject:group];
                    }
                    group.name = [langDict objectForKey:[grpDict objectForKey:@"name"]];
                    
                    NSArray *eventArr = [grpDict objectForKey:@"events"];
                    for (NSDictionary *eventDict in eventArr) {
                        Events *event;
                        predicate = [NSPredicate predicateWithFormat:@"name == %@",[langDict objectForKey:[eventDict objectForKey:@"name"]]];
                        results = [[group.groupOccourences array] filteredArrayUsingPredicate:predicate];
                        if ([results count]>0) {
                            event = (Events*)[results objectAtIndex:0];
                        } else {
                            event = [NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:self.managedObjectContext];
                            [group addGroupOccourencesObject:event];
                        }
                        event.name=[langDict objectForKey:[eventDict valueForKey:@"name"]];
                        
                        Row *row;
                        if ([[event.eventsRow array] count]>0) {
                            row = (Row*)[[event.eventsRow array] objectAtIndex:0];
                        } else {
                            row = [NSEntityDescription insertNewObjectForEntityForName:@"Row" inManagedObjectContext:self.managedObjectContext];
                            [event addEventsRowObject:row];
                        }
                        row.rowNumber=[NSNumber numberWithInt:0];
                        
                        NSMutableArray *contentArr = [eventDict valueForKey:@"contents"];
                        for (NSDictionary *contentDict in contentArr) {
                            DLog(@"content name==%@",[contentDict valueForKey:@"name"]);
                            Contents *content;
                            predicate = [NSPredicate predicateWithFormat:@"name == %@",[langDict objectForKey:[contentDict objectForKey:@"name"]]];
                            results = [[row.rowContent array] filteredArrayUsingPredicate:predicate];
                            if ([results count]>0) {
                                content = (Contents*)[results objectAtIndex:0];
                            } else {
                                content = [NSEntityDescription insertNewObjectForEntityForName:@"Contents" inManagedObjectContext:self.managedObjectContext];
                                [row addRowContentObject:content];
                            }
                            content.name=[langDict objectForKey:[contentDict valueForKey:@"name"]];
                            content.title = [contentDict valueForKey:@"title"];
                            content.type=@"ComboBox";
                            if ([contentDict valueForKey:@"otherOption"]) {
                                content.isOther = [NSNumber numberWithBool:TRUE];
                            }else{
                                content.isOther=[NSNumber numberWithBool:FALSE];
                            }
                            
                            NSDictionary *fieldDict = [contentDict objectForKey:@"optionCombos"];
                            for (int i= 0; i<[[fieldDict allKeys] count]; i++) {
                                NSDictionary *Vdict = [fieldDict valueForKey:[[fieldDict allKeys] objectAtIndex:i]];
                                if (Vdict!=nil) {
                                    FeildValues *field;
                                    predicate = [NSPredicate predicateWithFormat:@"valueES == %@ AND valuePT = %@",[Vdict objectForKey:@"valueEs"],[Vdict objectForKey:@"valuePt"]];
                                    results = [[content.contentField array] filteredArrayUsingPredicate:predicate];
                                    if ([results count]>0) {
                                        field = (FeildValues*)[results objectAtIndex:0];
                                    } else {
                                        field = [NSEntityDescription insertNewObjectForEntityForName:@"FeildValues" inManagedObjectContext:self.managedObjectContext];
                                        [content addContentFieldObject:field];
                                    }
                                    field.optionCode = [[fieldDict allKeys] objectAtIndex:i];
                                    field.valueES = [Vdict objectForKey:@"valueEs"];
                                    field.valuePT = [Vdict objectForKey:@"valuePt"];
                                    field.active = [NSNumber numberWithBool:[[Vdict objectForKey:@"active"] boolValue]];
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
    
}



@end
