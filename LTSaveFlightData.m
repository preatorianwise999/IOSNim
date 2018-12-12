//
//  DatabaseOperations.m
//  LATAM
//
//  Created by Durga Madamanchi on 4/23/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTSaveFlightData.h"
#import "AppDelegate.h"
#import "Customer.h"
#import "LTAllDb.h"
#import "NSMutableDictionary+ChekVal.h"
#import "Constants.h"
#import "LTSingleton.h"
@implementation LTSaveFlightData


+(void)saveEventWithFlightRoasterDict:(NSMutableDictionary*)flightRoasterDict {
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSDictionary *dict = [flightRoasterDict objectForKey:@"flightKey"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        
        NSMutableDictionary *legDict = [[flightRoasterDict objectForKey:@"legs"] objectAtIndex:0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"origin ==%@ AND destination == %@", [legDict objectForKey:@"origin"],[legDict objectForKey:@"destination"]];
        NSArray *results = [[flight.flightInfoLegs array] filteredArrayUsingPredicate:predicate];
        if ([results count] > 0) {
            Legs *leg = (Legs*)[results objectAtIndex:0];
            
            Report *report;
            if ([leg.legFlightReport.reportName isEqualToString:@"FlightReport"]) {
                report = (Report*)leg.legFlightReport;
            } else {
                report = [NSEntityDescription insertNewObjectForEntityForName:@"Report" inManagedObjectContext:managedObjectContext];
                report.reportName = @"FlightReport";
                [leg setLegFlightReport:report];
            }
            
            report.version=[NSNumber numberWithFloat:[[flightRoasterDict objectForKey:@"flightReportVersion"] floatValue]];
            report.flightType = [flightRoasterDict objectForKey:@"flightReportType"];
            
            FlightReports *flightReport;
            NSMutableDictionary *reportDict = [[legDict objectForKey:@"reports"] objectAtIndex:0];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name ==%@",[reportDict objectForKey:@"name"]];
            
            NSArray *result = [[report.flightReportReport array] filteredArrayUsingPredicate:predicate];
            
            if ([result count]>0) {
                flightReport = (FlightReports*)[result objectAtIndex:0];
            } else {
                flightReport = [NSEntityDescription insertNewObjectForEntityForName:@"FlightReports" inManagedObjectContext:managedObjectContext];
                [report addFlightReportReportObject:flightReport];
            }
            flightReport.name = [reportDict objectForKey:@"name"];
            
            Sections *section;
            NSMutableDictionary *sectionDict = [[reportDict objectForKey:@"sections"] objectAtIndex:0];
            predicate = [NSPredicate predicateWithFormat:@"name ==%@",[sectionDict objectForKey:@"name"]];
            NSArray *results = [[flightReport.reportSection array] filteredArrayUsingPredicate:predicate];
            if ([results count] > 0) {
                section = [results objectAtIndex:0];
            }else {
                section= [NSEntityDescription insertNewObjectForEntityForName:@"Sections" inManagedObjectContext:managedObjectContext];
                [flightReport addReportSectionObject:section];
            }
            section.name = [sectionDict objectForKey:@"name"];
            
            NSMutableArray *grpArray = [sectionDict objectForKey:@"groups"];
            for (int i = 0; i < [grpArray count]; i++) {
                NSDictionary *grpDict = [grpArray objectAtIndex:i];
                Groups *group;
                predicate = [NSPredicate predicateWithFormat:@"name ==%@",[grpDict objectForKey:@"name"]];
                results = [[section.sectionGroup array] filteredArrayUsingPredicate:predicate];
                if ([results count]>0) {
                    group = (Groups*)[results objectAtIndex:0];
                    for (Events *event in [group.groupOccourences array]) {
                        for (int j=0; j<[[event.eventsRow array] count];j++ ) {
                            Row *row = [[event.eventsRow array] objectAtIndex:j];
                            for (Contents *content in [row.rowContent array]) {
                                [row removeRowContentObject:content];
                                [row.managedObjectContext deleteObject:content];
                            }
                            [event removeEventsRowObject:row];
                            [event.managedObjectContext deleteObject:row];
                        }
                        [group removeGroupOccourencesObject:event];
                        [group.managedObjectContext deleteObject:event];
                    }
                    
                    [section removeSectionGroupObject:group];
                    [section.managedObjectContext deleteObject:group];
                }
                
                group = [NSEntityDescription insertNewObjectForEntityForName:@"Groups" inManagedObjectContext:managedObjectContext];

                group.name=[grpDict objectForKey:@"name"];
                [section addSectionGroupObject:group];
                NSDictionary *eventDict;
                BOOL Flag;
                if ([grpDict objectForKey:@"multiEvents"]!=nil) {
                    eventDict = [grpDict objectForKey:@"multiEvents"];
                    Flag = TRUE;
                    
                    for (NSString *eventName in [eventDict allKeys]) {
                        
                        Events *event = [NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:managedObjectContext];
                        event.name=eventName;
                        [group addGroupOccourencesObject:event];
                        NSArray *eventArray = [eventDict objectForKey:eventName];
                        for (int i = 0; i < [eventArray count]; i++) {
                            NSMutableDictionary *contentDict = [eventArray objectAtIndex:i];
                            Row *row = [NSEntityDescription insertNewObjectForEntityForName:@"Row" inManagedObjectContext:managedObjectContext];
                            row.rowNumber = [NSNumber numberWithInt:i];
                            
                            for (NSString *contentName in [contentDict allKeys]) {
                                Contents *content = [NSEntityDescription insertNewObjectForEntityForName:@"Contents" inManagedObjectContext:managedObjectContext];
                                if ((flight.status==[NSNumber numberWithInt:draft] || flight.status == [NSNumber numberWithInt:0]) && [LTSingleton getSharedSingletonInstance].isDataChanged) {
                                    flight.status = [NSNumber numberWithInt:draft];
                                }
                                
                                content.name = contentName;
                                content.selectedValue = [contentDict objectForKey:contentName];
                                
                                [row addRowContentObject:content];
                            }
                            
                            [event addEventsRowObject:row];
                        }
                        
                        event.isMultiple = [NSNumber numberWithBool:Flag];
                    }
                }
                
                if([grpDict objectForKey:@"singleEvents"] != nil) {
                    NSDictionary *contentDict = [grpDict objectForKey:@"singleEvents"];
                    Flag=FALSE;
                    Events *event = [NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:managedObjectContext];
                    event.name=@"singleEvent";
                    [group addGroupOccourencesObject:event];
                    Row *row = [NSEntityDescription insertNewObjectForEntityForName:@"Row" inManagedObjectContext:managedObjectContext];
                    row.rowNumber = [NSNumber numberWithInt:0];
                    [event addEventsRowObject:row];
                    for (NSString *contentName in [contentDict allKeys]) {
                        if ((flight.status==[NSNumber numberWithInt:draft] || flight.status == [NSNumber numberWithInt:0]) && [LTSingleton getSharedSingletonInstance].isDataChanged) {
                            flight.status = [NSNumber numberWithInt:draft];
                        }
                        Contents *content = [NSEntityDescription insertNewObjectForEntityForName:@"Contents" inManagedObjectContext:managedObjectContext];
                        if ([contentName isEqualToString:@"Leg Executed"]) {
                            if ( [LTSingleton getSharedSingletonInstance].legExecutedDict) {
                                [[LTSingleton getSharedSingletonInstance].legExecutedDict setObject:[contentDict objectForKey:contentName] forKey:[NSString stringWithFormat:@"%@-%@",leg.origin,leg.destination]];
                            } else {
                                [LTSingleton getSharedSingletonInstance].legExecutedDict = [[NSMutableDictionary alloc] init];
                                [[LTSingleton getSharedSingletonInstance].legExecutedDict setObject:[contentDict objectForKey:contentName] forKey:[NSString stringWithFormat:@"%@-%@",leg.origin,leg.destination]];
                            }
                            
                                                        
                        }
                        content.name=contentName;
                        content.selectedValue=[contentDict objectForKey:contentName];
                        [row addRowContentObject:content];
                    }
                    
                    event.isMultiple=[NSNumber numberWithBool:Flag];
                }
            }
            
            flight.isDataSaved=[NSNumber numberWithBool:YES];
            
            NSError *error;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
        }
    }
}

+(void)deleteGroupWithCascadeFromGroup:(Groups*)group withMangeObjectContext:(NSManagedObjectContext*)manageObject{
    for (Events *event in [group.groupOccourences array]) {
        for (Row *row in [event.eventsRow array]) {
            for (Contents *content in [row.rowContent array]) {
                [manageObject deleteObject:content];
            }
            [manageObject deleteObject:row];
        }
        [manageObject deleteObject:event];
    }
}

+(NSArray*)checkIfExistReturnCheckString:(NSString*)check Value:(NSString*)value forEntity:(NSString*)entity inArray:(NSArray*)aray{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ ==%@",check,value];
    
    NSArray *results = [aray filteredArrayUsingPredicate:predicate];
    return results;
    
}

+(BOOL)saveCrewmemberWithFirstName:(NSString *)firstName amdLastName:(NSString *)lastName andbpNumber:(NSString *)bpNumber rankValue:(NSString *)rank forFlight:(NSDictionary*)flightDict {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.managedObjectContext;
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSDictionary *dict = [flightDict objectForKey:@"flightKey"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];

        if (![managedObjectContext save:&error]) {
            DLog(@"Failed to save - error: %@", [error localizedDescription]);
            return NO;
        }
            
    }
    else{
        return NO;
    }
    return YES;
}
@end

