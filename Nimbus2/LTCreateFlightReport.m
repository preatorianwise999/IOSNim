//
//  LTCreateFlightReport.m
//  LATAM
//
//  Created by Palash on 05/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTCreateFlightReport.h"
#import "LTAllDb.h"
#import "AppDelegate.h"
#import "DictionaryParser.h"
#import "NSMutableDictionary+ChekVal.h"
#import "Customer.h"
#import "LTGetLightData.h"

@implementation LTCreateFlightReport


+(NSDictionary*)getFlightReportForDictionary:(NSMutableDictionary*)flightRoasterDict {
    NSMutableDictionary *flightRDict = [[NSMutableDictionary alloc] initWithDictionary:flightRoasterDict copyItems:YES];
    NSString *EXELEG=@"YES";
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSDictionary *langDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EnglishKey" ofType:@"plist"]];
    
    NSMutableDictionary *dict = [[flightRDict objectForKey:@"flightKey"] mutableCopy];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    [dict setValue:[dateFormat3 stringFromDate:fDate] forKey:@"flightDate"];
    DLog(@"%@",dict);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        Uris *uri = flight.flightUri;
        [flightRDict setAccessibilityValue:uri.createFlight];
        [flightRDict setObject:flight.flightReport forKey:@"reportId"];
        /////////////legs////////////////
        NSMutableArray *legArray = [[NSMutableArray alloc] init];
        [flightRDict setObject:legArray forKey:@"legs"];
        if ([[flight.flightInfoLegs array] count]>0) {
            for (Legs *leg in [flight.flightInfoLegs array]) {
                NSMutableDictionary *legDict = [[NSMutableDictionary alloc] init];
                [legArray addObject:legDict];
                
                //Added nil checking
                if(nil != leg.origin)
                    
                    [legDict setObject:leg.origin forKey:@"origin"];
                else
                    [legDict setObject:@"" forKey:@"origin"];
                
                
                //Added nil checking
                if(nil != leg.destination)
                    [legDict setObject:leg.destination forKey:@"destination"];
                else
                    [legDict setObject:@"" forKey:@"destination"];
                NSMutableArray *reportArray = [[NSMutableArray alloc] init];
                [legDict setObject:reportArray forKey:@"reports"];
                //////////report///////////////
                
                Report *report;
                if ([leg.legFlightReport.reportName isEqualToString:@"FlightReport"]) {
                    report = (Report*)leg.legFlightReport;
                }
                
                /////////flight reports///////
                
                for (FlightReports *flightReport in report.flightReportReport) {
                    
                    NSMutableDictionary *reportDict = [[NSMutableDictionary alloc] init];
                    [reportArray addObject:reportDict];
                    [reportDict setObject:[langDict keyForValue:flightReport.name] forKey:@"name"];
                    NSMutableArray *sectionArray = [[NSMutableArray alloc] init];
                    [reportDict setObject:sectionArray forKey:@"sections"];
                    //////////sections//////////
                    for (Sections *section in [flightReport.reportSection array]) {
                        NSMutableDictionary *sectionDict = [[NSMutableDictionary alloc] init];
                        [sectionArray addObject:sectionDict];
                        [sectionDict setObject:[langDict keyForValue:section.name] forKey:@"name"];
                        NSMutableArray *grpArray = [[NSMutableArray alloc] init];
                        [sectionDict setObject:grpArray forKey:@"groups"];
                        for (Groups *group in [section.sectionGroup array]) {
                            NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] init];
                            
                            if(![[langDict keyForValue:group.name] isEqualToString:@"EXELEG"]) {
                                [groupDict setObject:[langDict keyForValue:group.name] forKey:@"name"];
                                [grpArray addObject:groupDict];
                            }
                            
                            NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] init];
                            NSMutableDictionary *eventDict2 = [[NSMutableDictionary alloc] init];
                            for (Events *event in [group.groupOccourences array]){
                                
                                if ([event.isMultiple boolValue]) {
                                    NSMutableArray *rowArray = [[NSMutableArray alloc] init];
                                    for (Row *row in [event.eventsRow array]) {
                                        NSMutableDictionary *rowDict = [[NSMutableDictionary alloc] init];
                                        for (Contents *content in [row.rowContent array]) {
                                            DLog(@"%@  %@",content.name,content.selectedValue);
                                            if (![content.selectedValue isEqualToString:@""] ) {
                                                [rowDict setValue:[[content.selectedValue componentsSeparatedByString:@"||"] firstObject] forKey:[langDict keyForValue:content.name]];
                                            }
                                        }
                                        if ([[rowDict allKeys] count]>0) {
                                            [rowArray addObject:rowDict];
                                        }
                                    }
                                    
                                    if ([rowArray count]>0) {
                                        [eventDict setValue:rowArray forKey:[langDict keyForValue:event.name]];
                                        [groupDict setObject:eventDict forKey:@"multiEvents"];
                                    }
                                } else {
                                    Row *row = [[event.eventsRow array] objectAtIndex:0];
                                    for (Contents *content in [row.rowContent array]) {
                                        DLog(@"%@  %@",content.name,content.selectedValue);
                                        if ([content.name isEqualToString:@"Leg Executed"]) {
                                            EXELEG = content.selectedValue;
                                        }
                                        if ([EXELEG isEqualToString:@"YES"]) {
                                            if ([content.name isEqualToString:@"Minimum Time for TC Boarding"]) {
                                                [eventDict2 setValue:EXELEG forKey:@"EXELEG"];
                                            }
                                            if (![content.selectedValue isEqualToString:@""]) {
                                                [eventDict2 setValue:[[content.selectedValue componentsSeparatedByString:@"||"] firstObject] forKey:[langDict keyForValue:content.name]];
                                            }
                                        }
                                    }
                                    
                                    if ([[eventDict2 allKeys] count] > 0) {
                                        [groupDict setObject:eventDict2 forKey:@"singleEvents"];
                                    }
                                }
                                
                                DLog(@"%@",[langDict keyForValue:event.name]);
                            }
                        }
                    }
                    
                    if ([EXELEG isEqualToString:@"NO"]) {//change to check if leg executed is in GEN section only
                        //if leg executed is no
                        if ([[reportDict objectForKey:@"name"] isEqualToString:@"GEN"]) {
                            [sectionArray removeAllObjects];
                            NSMutableDictionary *secDict = [[NSMutableDictionary alloc] init];
                            [sectionArray addObject:secDict];
                            [secDict setObject:@"SHIPMN" forKey:@"name"];
                            NSMutableArray *grpArray = [[NSMutableArray alloc] init];
                            [secDict setObject:grpArray forKey:@"groups"];
                            NSMutableDictionary *grpDict = [[NSMutableDictionary alloc] init];
                            [grpArray addObject:grpDict];
                            [grpDict setObject:@"SHPINF" forKey:@"name"];
                            NSMutableDictionary *singleEventDict = [[NSMutableDictionary alloc] init];
                            [grpDict setObject:singleEventDict forKey:@"singleEvents"];
                            [singleEventDict setObject:EXELEG forKey:@"EXELEG"];
                        }
                    }
                }
            }
        }
    }
    
    return flightRDict;
}

+(NSDictionary*)getFlightReportForViewSummary:(NSMutableDictionary*)flightRoasterDict {
    
    NSMutableDictionary *flightRDict = [[NSMutableDictionary alloc] initWithDictionary:flightRoasterDict copyItems:YES];
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    NSMutableDictionary *dict = [[flightRDict objectForKey:@"flightKey"] mutableCopy];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    [dict setValue:[dateFormat3 stringFromDate:fDate] forKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        [flightRDict setObject:flight.sortTime forKey:@"sortTime"];
        /////////////legs////////////////
        NSMutableArray *legArray = [[NSMutableArray alloc] init];
        [flightRDict setObject:legArray forKey:@"legs"];
        
        for (Legs *leg in [flight.flightInfoLegs array]) {
            NSMutableDictionary *legDict = [[NSMutableDictionary alloc] init];
            [legArray addObject:legDict];
            [legDict setObject:leg.origin forKey:@"origin"];
            [legDict setObject:leg.destination forKey:@"destination"];
            NSMutableArray *reportArray = [[NSMutableArray alloc] init];
            [legDict setObject:reportArray forKey:@"reports"];
            //////////report///////////////
            
            Report *report;
            if ([leg.legFlightReport.reportName isEqualToString:@"FlightReport"]) {
                report = (Report*)leg.legFlightReport;
            }
            
            /////////flight reports///////
            
            for (FlightReports *flightReport in report.flightReportReport) {
                
                NSMutableDictionary *reportDict = [[NSMutableDictionary alloc] init];
                [reportArray addObject:reportDict];
                [reportDict setObject:flightReport.name forKey:@"name"];
                NSMutableArray *sectionArray = [[NSMutableArray alloc] init];
                [reportDict setObject:sectionArray forKey:@"sections"];
                //////////sections//////////
                for (Sections *section in [flightReport.reportSection array]) {
                    BOOL isEventDataPresent = NO;
                    NSMutableDictionary *sectionDict = [[NSMutableDictionary alloc] init];
                    NSMutableArray *grpArray = [[NSMutableArray alloc] init];
                    [sectionDict setObject:grpArray forKey:@"groups"];
                    for (Groups *group in [section.sectionGroup array]) {
                        BOOL isGroupDataPresent = NO;
                        NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] init];
                        NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] init];
                        NSMutableDictionary *eventDict2 = [[NSMutableDictionary alloc] init];
                        for (Events *event in [group.groupOccourences array]) {
                            if([[event.eventsRow array] count] != 0) {
                                isEventDataPresent = YES;
                                isGroupDataPresent = YES;
                                if ([event.isMultiple boolValue]) {
                                    NSMutableArray *rowArray = [[NSMutableArray alloc] init];
                                    for (Row *row in [event.eventsRow array]) {
                                        NSMutableDictionary *rowDict = [[NSMutableDictionary alloc] init];
                                        for (Contents *content in [row.rowContent array]) {
                                            DLog(@"%@  %@",content.name,content.selectedValue);
                                            if([content.name isEqualToString:@"CAMERA"]||[content.name isEqualToString:@"AMOUNT"]) {
                                                [rowDict setValue:content.selectedValue forKey:content.name];
                                            }
                                            else {
                                                [rowDict setValue:[[content.selectedValue componentsSeparatedByString:@"||"] lastObject] forKey:content.name];
                                            }
                                        }
                                        
                                        [rowArray addObject:rowDict];
                                    }
                                    
                                    [eventDict setValue:rowArray forKey:event.name];
                                    [groupDict setObject:eventDict forKey:@"multiEvents"];
                                }
                                
                                else{
                                    Row *row = [[event.eventsRow array] objectAtIndex:0];
                                    for (Contents *content in [row.rowContent array]) {
                                        DLog(@"%@  %@",content.name,content.selectedValue);
                                        if([content.name isEqualToString:@"CAMERA"]||[content.name isEqualToString:@"AMOUNT"])
                                        {
                                            [eventDict2 setValue:content.selectedValue forKey:content.name];
                                        }
                                        else
                                        {
                                            [eventDict2 setValue:[[content.selectedValue componentsSeparatedByString:@"||"] lastObject] forKey:content.name];
                                        }
                                    }
                                    [groupDict setObject:eventDict2 forKey:@"singleEvents"];
                                }
                            }
                            
                            DLog(@"%@",event.name);
                            
                        }
                        if(isGroupDataPresent)
                        {
                            [groupDict setObject:group.name forKey:@"name"];
                            [grpArray addObject:groupDict];
                        }
                    }
                    if(isEventDataPresent) {
                        [sectionDict setObject:section.name forKey:@"name"];
                        [sectionArray addObject:sectionDict];
                    }
                }
            }
        }
    }
    return flightRDict;
}

+(NSMutableDictionary*)createReportFlightDictForFlight:(FlightRoaster*)flight {
    
    NSMutableDictionary *flightDict = [[NSMutableDictionary alloc] init];
    
    @try {
        NSMutableDictionary *fkeydict = [[NSMutableDictionary alloc] init];
        [fkeydict setObject:flight.airlineCode forKey:@"airlineCode"];
        [fkeydict setObject:flight.flightDate forKey:@"flightDate"];
        [fkeydict setObject:flight.flightNumber forKey:@"flightNumber"];
        [fkeydict setObject:flight.suffix forKey:@"suffix"];
        [flightDict setObject:fkeydict forKey:@"flightKey"];
        [flightDict setObject:flight.type forKey:@"flightReportType"];
        [flightDict setObject:[self getVersionForType:flight.type] forKey:@"flightReportVersion"];
    }
    @catch (NSException *exception) {
        DLog(@"xceptionHandeled");
    }
    
    flightDict = [[self getFlightReportForDictionary:flightDict] mutableCopy];
    Uris *uri = flight.flightUri;
    [flightDict setAccessibilityValue:uri.createFlight];
    
    return flightDict;
}

//Create flight list for all flights
+(NSMutableArray*)createFlightReportForAllFlightsForStatus:(STATUS)stat {
    
    NSMutableArray *allFlightArray = [[NSMutableArray alloc] init];
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if([results count] > 0) {
        for(int i = 0; i < [results count]; i++) {
            FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:i];
            
            NSMutableDictionary *flightDict = [[NSMutableDictionary alloc] init];
            
            if ([flight.status intValue] == stat) {
                flightDict = [self createReportFlightDictForFlight:flight];
            }
            
            if ([[flightDict allKeys] count] > 0) {
                DLog(@"dict==%@",flightDict);
                [allFlightArray addObject:flightDict];
            }
        }
    }
    
    return allFlightArray;
}

+(NSString *)getVersionForType:(NSString*)type {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"ReportType"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@",type];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        ReportType *repType = (ReportType*)[results objectAtIndex:0];
        return repType.version;
    } else {
        return @"1.0";
    }
}

+(NSMutableDictionary*)getSyschStatus {
    NSMutableDictionary *allFlightDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *allFlightArray = [[NSMutableArray alloc] init];
    [allFlightDict setObject:allFlightArray forKey:@"flights"];
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if([results count] > 0) {
        currentUser = [results objectAtIndex:0];
        for (FlightRoaster *flight in [currentUser.flightRosters array]) {
            if ([flight.status intValue] == sent || [flight.status intValue] == wf || [flight.status intValue] == ea) {//[flight.isDataSaved intValue]==inqueue
                
                NSMutableDictionary *statusDict = [[NSMutableDictionary alloc] init];
                NSMutableArray *statusArray = [[NSMutableArray alloc] init];
                [statusDict setObject:statusArray forKey:@"status"];
                [statusDict setObject:flight.flightNumber forKey:@"flightNumber"];
                NSDateFormatter *fr = [[NSDateFormatter alloc] init];
                [fr setDateFormat:DATEFORMAT];
                NSString *date = [fr stringFromDate:flight.flightDate];
                [statusDict setObject:date forKey:@"flightDate"];
                [statusDict setObject:flight.suffix forKey:@"suffix"];
                [statusDict setObject:flight.airlineCode forKey:@"flightOperator"];
                [allFlightArray addObject:statusDict];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:@"IV" forKey:@"reportName"];
                [dict setObject:flight.flightReport forKey:@"reportId"];
                [statusArray addObject:dict];
            }
        }
    }
    
    return allFlightDict;
}
+(NSMutableDictionary*)getSyschStatusByIdflight:(NSString*)idflights{
    NSMutableDictionary *allFlightDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *allFlightArray = [[NSMutableArray alloc] init];
    [allFlightDict setObject:allFlightArray forKey:@"flights" ];
    
   // [[[allFlightDict objectForKey:@"flightKey"] objectForKey:@"flightNumber" ] isEqualToString :(NSString *)idflights];
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if([results count] > 0) {
        currentUser = [results objectAtIndex:0];
        for (FlightRoaster *flight in [currentUser.flightRosters array]) {
            if ([flight.flightNumber isEqualToString:(NSString *)idflights]) {//[flight.isDataSaved intValue]==inqueue
                
                NSMutableDictionary *statusDict = [[NSMutableDictionary alloc] init];
                NSMutableArray *statusArray = [[NSMutableArray alloc] init];
                [statusDict setObject:statusArray forKey:@"status"];
                [statusDict setObject:flight.flightNumber forKey:@"flightNumber"];
                NSDateFormatter *fr = [[NSDateFormatter alloc] init];
                [fr setDateFormat:DATEFORMAT];
                NSString *date = [fr stringFromDate:flight.flightDate];
                [statusDict setObject:date forKey:@"flightDate"];
                [statusDict setObject:flight.suffix forKey:@"suffix"];
                [statusDict setObject:flight.airlineCode forKey:@"flightOperator"];
                [allFlightArray addObject:statusDict];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:@"IV" forKey:@"reportName"];
                [dict setObject:flight.flightReport forKey:@"reportId"];
                [statusArray addObject:dict];
            }
        }
    }
    
    return allFlightDict;
}

@end
