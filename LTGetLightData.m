//
//  LTGetLightData.m
//  LATAM
//
//  Created by Palash on 28/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTGetLightData.h"

#import "LTSaveFlightData.h"
#import "Customer.h"
#import "CUSImages.h"
#import "AppDelegate.h"
#import "LTSingleton.h"
#import "LTGetDropDownvalue.h"

@implementation LTGetLightData

//+(NSDictionary*)getFormReportForDictionary:(NSDictionary*)flightRoasterDict{
//    return flightRoasterDict;
//}



//For fetching the save data from local DB
+(NSDictionary*)getFormReportForDictionary:(NSDictionary*)flightRoasterDict forIndex:(int)index {
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
        /////////////////////////////
        NSMutableDictionary *legDict = [[flightRoasterDict objectForKey:@"legs"] objectAtIndex:index];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"origin ==%@ AND destination == %@", [legDict objectForKey:@"origin"],[legDict objectForKey:@"destination"]];
        NSArray *results = [[flight.flightInfoLegs array] filteredArrayUsingPredicate:predicate];
        if ([results count] > 0) {
            Legs *leg = (Legs*)[results objectAtIndex:0];
            /////////////////////////
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
            
            ////////////////
            FlightReports *flightReport;
            NSMutableDictionary *reportDict = [[legDict objectForKey:@"reports"] objectAtIndex:0];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name ==%@",[reportDict objectForKey:@"name"]];
            
            NSArray *result = [[report.flightReportReport array] filteredArrayUsingPredicate:predicate];
            
            if ([result count] > 0) {
                flightReport = (FlightReports*)[result objectAtIndex:0];
            } else {
                return flightRoasterDict;
            }
            //////////////////
            Sections *section;
            NSMutableDictionary *sectionDict = [[reportDict objectForKey:@"sections"] objectAtIndex:0];
            predicate = [NSPredicate predicateWithFormat:@"name ==%@",[sectionDict objectForKey:@"name"]];
            NSArray *results = [[flightReport.reportSection array] filteredArrayUsingPredicate:predicate];
            if ([results count] > 0) {
                section = [results objectAtIndex:0];
            } else {
                return flightRoasterDict;
            }
            
            NSMutableArray *grpArray = [sectionDict objectForKey:@"groups"];
            [grpArray removeAllObjects];//to remove duplicate entry of in roaster
            for (Groups *group in [section.sectionGroup array]) {
                if(nil != group.name ) {
                    NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] init];
                    [grpArray addObject:groupDict];
                    
                    [groupDict setObject:group.name forKey:@"name"];
                    
                    NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] init];
                    NSMutableDictionary *eventDict2 = [[NSMutableDictionary alloc] init];
                    for (Events *event in [group.groupOccourences array]) {
                        
                        if ([event.isMultiple boolValue]) {
                            NSMutableArray *rowArray = [[NSMutableArray alloc] init];
                            for (Row *row in [event.eventsRow array]) {
                                NSMutableDictionary *rowDict = [[NSMutableDictionary alloc] init];
                                for (Contents *content in [row.rowContent array]) {
                                    // DLog(@"%@  %@",content.name,content.selectedValue);
                                    [rowDict setValue:content.selectedValue forKey:content.name];
                                }
                                [rowArray addObject:rowDict];
                            }
                            [eventDict setValue:rowArray forKey:event.name];
                            [groupDict setObject:eventDict forKey:@"multiEvents"];
                        } else {
                            Row *row = [[event.eventsRow array] objectAtIndex:0];
                            for (Contents *content in [row.rowContent array]) {
                                // DLog(@"%@  %@",content.name,content.selectedValue);
                
                                if (content.name!=nil && content.selectedValue != nil) {
                                    [eventDict2 setValue:content.selectedValue forKey:content.name];
                                    if ([content.name isEqualToString: @"Crew Base"]) {
                                        //  DLog(@"%@  %@",content.name,content.selectedValue);
                                        DLog(@"******************************************************");
                                    }
                                }
                            }
                            [groupDict setObject:eventDict2 forKey:@"singleEvents"];
                        }
                        // DLog(@"%@",event.name);
                    }
                }
            }
        }
    }
    return flightRoasterDict;
}

+(BOOL)chekReportIsDrafted:(NSDictionary*)reportDict {
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSDictionary *dict = [reportDict objectForKey:@"flightKey"];
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
        if ([flight.status intValue] < 1) {
            return NO;
        } else {
            return YES;
        }
    }
    return TRUE;
}
//For getting prepopulated data for general
+(NSMutableDictionary *)getPrepopulatedDataForGeneral:(NSDictionary*)flightRoasterDict {
    //NSMutableDictionary *flightRoasterDict2 = [[NSMutableDictionary alloc] initWithDictionary:flightRoasterDict copyItems:YES];
    NSMutableDictionary *flightRoasterDict2 = (NSMutableDictionary *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)flightRoasterDict, kCFPropertyListMutableContainers));
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if([results count] > 0) {
        currentUser = [results objectAtIndex:0];
        NSDictionary *dict = [flightRoasterDict2 objectForKey:@"flightKey"];
        //        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
        NSDate *fDate = [dict objectForKey:@"flightDate"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
        NSArray *arr = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if([arr count] > 0){
            FlightRoaster *flight = [arr objectAtIndex:0];
            
            for (int i = 0; i < flight.flightInfoLegs.count; i++) {
                
                Legs *leg = [[flight.flightInfoLegs array] objectAtIndex:i];
                
                NSMutableDictionary *legDict = [[flightRoasterDict2 objectForKey:@"legs"] objectAtIndex:0];
                if(leg.origin)
                    [legDict setObject:leg.origin forKey:@"origin"];
                if(leg.destination)
                    [legDict setObject:leg.destination forKey:@"destination"];
                CrewMembers *crew;
                predicate = [NSPredicate predicateWithFormat:@"specialRank == %@ OR specialRank == %@",@"C",@"c"];
                NSArray *res = [[leg.legsCrewmember array] filteredArrayUsingPredicate:predicate];
                if ([res count] > 0) {
                    crew = (CrewMembers*)[res objectAtIndex:0];
                } else {
                    crew = [NSEntityDescription insertNewObjectForEntityForName:@"CrewMembers" inManagedObjectContext:managedObjectContext];
                    crew.firstName = @"";
                    crew.lastName = @"";
                    crew.bp = @"";
                }
                NSMutableArray *groupArr = [[NSMutableArray alloc]init];
                
                NSMutableDictionary *groupDict;
                AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
                @try {
                    NSMutableDictionary *tramoDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSString alloc] initWithFormat:@"YES"], nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_TRAMO_EJECUTADO"], nil]];
                    
                    NSMutableDictionary *jefeDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:currentUser.firstName,currentUser.lastName,currentUser.bp, nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_NAME"],[appDel copyEnglishTextForKey:@"GENERAL_SURNAME"],[appDel copyEnglishTextForKey:@"GENERAL_BP"], nil]];
                    
                    NSMutableDictionary *captainDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:crew.firstName,crew.lastName, nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_NAME"],[appDel copyEnglishTextForKey:@"GENERAL_SURNAME"], nil]];
                    
                    NSMutableDictionary *flightDataDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:flight.material,flight.tailNumber,currentUser.crewBase==nil?@"":currentUser.crewBase, nil] forKeys:[NSArray arrayWithObjects:[appDel copyEnglishTextForKey:@"GENERAL_MATERIAL"],[appDel copyEnglishTextForKey:@"GENERAL_ENROLLMENT"],[appDel copyEnglishTextForKey:@"GENERAL_CREW_BASE"], nil]];
                    
                    // ----- start formatting material and crew base
                    
                    NSString *flightType = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightReportType"];
                    NSString *report = [[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:i] objectForKey:@"reports"] firstObject] objectForKey:@"name"];
                    
                    NSString *section = [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:i] objectForKey:@"reports"] firstObject] objectForKey:@"sections"] firstObject] objectForKey:@"name"];
                    
                    NSString *group = [appDel copyEnglishTextForKey:@"GENERAL_FLIGHT_DATA"];
                    
                    NSMutableDictionary *retDict = [LTGetDropDownvalue getDictForReportType:flightType FlightReport:report Section:section];
                    
                    NSArray *materialDropdown = [[[retDict objectForKey:group] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_MATERIAL"]] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_MATERIAL"]];
                    NSArray *baseCrewDropdown=  [[[retDict objectForKey:group] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_CREW_BASE"]] objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_CREW_BASE"]];
                    
                    NSMutableString *crewBaseString = [flightDataDict objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_CREW_BASE"]];
                    NSMutableString *materialString = [flightDataDict objectForKey:[appDel copyEnglishTextForKey:@"GENERAL_MATERIAL"]];
                    
                    if([crewBaseString length] != 0 && [[crewBaseString componentsSeparatedByString:@"||"] count] == 1) {
                        if ([baseCrewDropdown indexOfObject:crewBaseString] != NSNotFound) {
                            NSString *value = [baseCrewDropdown objectAtIndex:[baseCrewDropdown indexOfObject:crewBaseString]];
                            [flightDataDict setObject:[NSString stringWithFormat:@"%@||%@",[value accessibilityLabel],crewBaseString] forKey:[appDel copyEnglishTextForKey:@"GENERAL_CREW_BASE"]];
                        }
                    }
                    if([materialString length] != 0 && [[materialString componentsSeparatedByString:@"||"] count] == 1) {
                        if ([materialDropdown indexOfObject:materialString]!=NSNotFound) {
                            NSString *value = [materialDropdown objectAtIndex:[materialDropdown indexOfObject:materialString]];
                            [flightDataDict setObject:[NSString stringWithFormat:@"%@||%@",[value accessibilityLabel],materialString] forKey:[appDel copyEnglishTextForKey:@"GENERAL_MATERIAL"]];
                        }
                    }
                    
                    // ----- end formatting material and crew base
                    
                    groupDict = [[NSMutableDictionary alloc] init];
                    [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_TRAMO_EJECUTADO"] forKey:@"name"];
                    [groupDict setObject:tramoDict forKey:@"singleEvents"];
                    [groupArr addObject:groupDict];
                    
                    groupDict = [[NSMutableDictionary alloc] init];
                    [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_JEFE_DE_SERVICIO"] forKey:@"name"];
                    [groupDict setObject:jefeDict forKey:@"singleEvents"];
                    [groupArr addObject:groupDict];
                    
                    groupDict = [[NSMutableDictionary alloc] init];
                    [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_CAPITAN"] forKey:@"name"];
                    [groupDict setObject:captainDict forKey:@"singleEvents"];
                    [groupArr addObject:groupDict];
                    
                    groupDict = [[NSMutableDictionary alloc] init];
                    [groupDict setObject:[appDel copyEnglishTextForKey:@"GENERAL_FLIGHT_DATA"] forKey:@"name"];
                    [groupDict setObject:flightDataDict forKey:@"singleEvents"];
                    [groupArr addObject:groupDict];
                    
                    
                    NSMutableDictionary *returnDict = [flightRoasterDict2 mutableCopy];
                    [[[[[[[returnDict objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"reports"] objectAtIndex:0] objectForKey:@"sections"] objectAtIndex:0] setObject:groupArr forKey:@"groups"];
                    //Sajjadcommen
                    [LTSaveFlightData saveEventWithFlightRoasterDict:returnDict];
                }
                @catch (NSException *exception) {
                    // DLog(@"exception handled");
                }
            }
        }
    }
    return nil;
}

-(NSArray*)getFlights {
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDel.managedObjectContext reset];
    //NSManagedObject *managedObjectContext = [[NSManagedObject alloc] init];
    //[appDel.managedObjectContext refreshObject:managedObjectContext mergeChanges:NO];
    // Setup the fetch request
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [appDel.managedObjectContext executeFetchRequest:request error:&error1];
    if ([results count]>0) {
        User *currentUser = [results objectAtIndex:0];
        
        // Fetch the records and handle an error
        NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"sortTime" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObjects:desc, nil]];
        NSMutableArray *flightActivitiesArr = [[[currentUser.flightRosters array] sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]] mutableCopy];
        NSMutableArray *refreshArray = [[NSMutableArray alloc] init];
        for (FlightRoaster *flight in flightActivitiesArr) {
            if ([[flight.flightInfoLegs array] count]==0) {
                [currentUser removeFlightRostersObject:flight];
            }else{
                [refreshArray addObject:flight];
            }
        }
        
        return refreshArray;
    }
    return nil;
}

+(FlightRoaster*)getFlightForParticularFlightReportId:(NSString*)flightReportId {
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appDel.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSError *error;
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    
    // Fetch the records and handle an error
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightReport == %@",flightReportId];
    [request setPredicate:predicate];
    NSArray *results = [appDel.managedObjectContext executeFetchRequest:request error:&error];
    NSArray *result = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        FlightRoaster *flight2 = (FlightRoaster*)[result objectAtIndex:0];
        
        flight.status = flight2.status;
        return flight;
    }
    
    return nil;
}

+(NSArray*)getFlightCrewForFlightRoaster:(NSDictionary*)flightRoasterDict forLeg:(int)index {
    
    NSDictionary *dict = [flightRoasterDict objectForKey:@"flightKey"];
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    User *currentUser;
    if([results count] > 0) {
        currentUser = [results objectAtIndex:0];
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        NSDate *fDate = [dict objectForKey:@"flightDate"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
        [request setPredicate:predicate];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count] > 0) {
            FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
            if (index<[[flight.flightInfoLegs array] count]) {
                NSArray *crewAray =  [[[[flight.flightInfoLegs array] objectAtIndex:index] legsCrewmember] array];
                NSMutableArray *retArray = [[NSMutableArray alloc] init];
                for (int i = 0; i < [crewAray count]; i++) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    CrewMembers * crewObj = [crewAray objectAtIndex:i];
                    [dict setObject:crewObj.bp forKey:@"bp"];
                    if(crewObj.crewID) {
                        [dict setObject:crewObj.crewID forKey:@"crewID"];
                    }
                    else {
                        [dict setObject:@"-" forKey:@"crewID"];
                    }
                    [dict setObject:crewObj.activeRank forKey:@"activeRank"];
                    [dict setObject:crewObj.filledGAD !=nil?[crewObj.filledGAD stringValue]:@"0"  forKey:@"filledGAD"];
                    [dict setObject:crewObj.realizedGAD !=nil?[crewObj.realizedGAD stringValue]:@"0"  forKey:@"realizedGAD"];
                    [dict setObject:crewObj.firstName forKey:@"firstName"];
                    [dict setObject:crewObj.category!=nil?crewObj.category:@"--" forKey:@"category"];
                    [dict setObject:crewObj.lastName forKey:@"lastName"];
                    [dict setObject:crewObj.licencceDate !=nil?crewObj.licencceDate:@"--"  forKey:@"licencceDate"];
                    [dict setObject:crewObj.licenceNo !=nil?crewObj.licenceNo:@"--"  forKey:@"licenceNo"];
                    [dict setObject:crewObj.status !=nil?crewObj.status:@"" forKey:@"status"];
                    [dict setObject:crewObj.specialRank !=nil?crewObj.specialRank:@"" forKey:@"specialRank"];
                    [dict setObject:crewObj.expectedGAD !=nil?[crewObj.expectedGAD stringValue]:@"0"  forKey:@"expected"];
                    
                    [retArray addObject:dict];
                }
                return retArray;
            }
            
        }
    }
    return nil;
}

+(NSArray*)getFlightLegsForFlightRoaster:(NSDictionary*)flightRoasterDict {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //[appdelegate.managedObjectContext reset];
    NSDictionary *dict = [flightRoasterDict objectForKey:@"flightKey"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:DATEFORMAT];
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [appdelegate.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        return [flight.flightInfoLegs array];
    }
    return nil;
}
+(NSArray*)getFlightsByIDFlight:(NSString*)idflights
{
    
 NSMutableArray *FlightArraybyId = [[NSMutableArray alloc] init];
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    User *currentUser;
    if([results count] > 0) {
        currentUser = [results objectAtIndex:0];
        for (FlightRoaster *flight in [currentUser.flightRosters array]) {
            NSMutableDictionary *fkeydict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *flightdict = [[NSMutableDictionary alloc]init];
            
            if ([flight.flightNumber isEqualToString:(NSString *)idflights]) {
                if ([[flight.flightInfoLegs array] count]==0) {
                    continue;
                }
                if (flight.airlineCode) {
                    [fkeydict setObject:flight.airlineCode forKey:@"airlineCode"];
                }
                if (flight.flightDate) {
                    [fkeydict setObject:flight.flightDate forKey:@"flightDate"];
                }
                if (flight.flightNumber) {
                    [fkeydict setObject:flight.flightNumber forKey:@"flightNumber"];
                }
                if (flight.suffix) {
                    [fkeydict setObject:flight.suffix forKey:@"suffix"];
                }
                if (flight.type) {
                    [fkeydict setObject:flight.type forKey:@"flightReportType"];
                }
                if (flight.materialType) {
                    [fkeydict setObject:flight.materialType forKey:@"materialType"];
                }
                if (flight.flightReport) {
                    [fkeydict setObject:flight.flightReport forKey:@"flightReport"];
                }
                [flightdict setObject:fkeydict forKey:@"flightKey"];
                [FlightArraybyId addObject:flightdict];
            }
        }
    }
    
 return FlightArraybyId;
}

+(NSArray*)getAllFlights {
    
    NSMutableArray *allFlightArray = [[NSMutableArray alloc] init];
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    User *currentUser;
    if([results count] > 0) {
        currentUser = [results objectAtIndex:0];
        
        for (FlightRoaster *flight in [currentUser.flightRosters array]) {
            NSMutableDictionary *fkeydict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *flightdict = [[NSMutableDictionary alloc]init];
            
            if ([[flight.flightInfoLegs array] count]==0) {
                continue;
            }
            
            if (flight.airlineCode) {
                [fkeydict setObject:flight.airlineCode forKey:@"airlineCode"];
            }
            
            if (flight.flightDate) {
                [fkeydict setObject:flight.flightDate forKey:@"flightDate"];
            }
            if (flight.flightNumber) {
                [fkeydict setObject:flight.flightNumber forKey:@"flightNumber"];
            }
            if (flight.suffix) {
                [fkeydict setObject:flight.suffix forKey:@"suffix"];
            }
            if (flight.type) {
                [fkeydict setObject:flight.type forKey:@"flightReportType"];
            }
            if (flight.materialType) {
                [fkeydict setObject:flight.materialType forKey:@"materialType"];
            }
            if (flight.flightReport) {
                [fkeydict setObject:flight.flightReport forKey:@"flightReport"];
            }
            
            [flightdict setObject:fkeydict forKey:@"flightKey"];
            
            [allFlightArray addObject:flightdict];
        }
    }
    
    return allFlightArray;
}

+(NSDictionary *)getGADFormReportForCrewMemberForSynch:(CrewMembers *)crew1 forFlight:(NSDictionary *)flightDict {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdelegate.managedObjectContext updatedObjects];
    [appdelegate.managedObjectContext refreshObject:crew1 mergeChanges:NO];
    
    NSManagedObjectContext *managedObjectContext = appdelegate.managedObjectContext;
    NSMutableDictionary *crewMemberDict = [[NSMutableDictionary alloc]init];
    
    NSDictionary *dict = [flightDict objectForKey:@"flightKey"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        
        NSMutableDictionary *flightObjs = [[NSMutableDictionary alloc]init];
        [flightObjs setObject:flight.airlineCode forKey:@"airlineCode"];
        [flightObjs setObject:flight.flightDate forKey:@"flightDate"];
        [flightObjs setObject:flight.flightNumber forKey:@"flightNumber"];
        [flightObjs setObject:flight.suffix forKey:@"suffix"];
        
        NSMutableDictionary *flightDict = [[NSMutableDictionary alloc]init];
        [flightDict setObject:flightObjs forKey:@"flightkey"];
        [flightDict setObject:flight.flightReport  forKey:@"flightReportType"];
        //bp should be unique while saving the crew
        
        /* predicate = [NSPredicate predicateWithFormat:@"firstName==%@ AND lastName==%@ AND bp==%@",crew1.firstName,crew1.lastName,crew1.bp];
         */
        predicate = [NSPredicate predicateWithFormat:@"bp==%@",crew1.bp];
        //Sajjad  results = [[flight.flightCrew array] filteredArrayUsingPredicate:predicate];
        if ([results count]>0) {
            CrewMembers *crew =(CrewMembers*)[results objectAtIndex:0];
            GADComments *comments = (GADComments*)crew.crewComments;
            if (comments != nil) {
                if (comments.observerComments)[crewMemberDict setObject:comments.observerComments forKey:@"Feedback_Observer"];
                if (comments.observerSign)[crewMemberDict setObject:comments.observerSign forKey:@"Signatur_Observer"];
                if (comments.tcComments ) [crewMemberDict setObject:comments.tcComments forKey:@"Comments_TC"];
                if (comments.tcSign) [crewMemberDict setObject:comments.tcSign forKey:@"Signature_TC"];
            }
            [crewMemberDict setObject:[crew1.crewCategory array] forKey:@"GadCategoryFeedback"];
        }
    }
    
    [crewMemberDict setObject:crew1 forKey:@"CrewMember"];
    return crewMemberDict;
}

+(NSDictionary *)getGADFormReportForCrewMember:(CrewMembers *)crew1 forFlight:(NSDictionary *)flightDict {
    
    //NSMutableDictionary *gadDict = [[NSMutableDictionary alloc] init];
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdelegate.managedObjectContext updatedObjects];
    [appdelegate.managedObjectContext refreshObject:crew1 mergeChanges:NO];
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    //[appdelegate.managedObjectContext refreshObject:<#(NSManagedObject *)#> mergeChanges:<#(BOOL)#>];
    NSMutableDictionary *crewMemberDict = [[NSMutableDictionary alloc]init];
    
    
    
    NSDictionary *dict = [flightDict objectForKey:@"flightKey"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        
        NSMutableDictionary *flightObjs = [[NSMutableDictionary alloc]init];
        [flightObjs setObject:flight.airlineCode forKey:@"airlineCode"];
        [flightObjs setObject:flight.flightDate forKey:@"flightDate"];
        [flightObjs setObject:flight.flightNumber forKey:@"flightNumber"];
        [flightObjs setObject:flight.suffix forKey:@"suffix"];
        
        NSMutableDictionary *flightDict = [[NSMutableDictionary alloc]init];
        [flightDict setObject:flightObjs forKey:@"flightkey"];
        [flightDict setObject:flight.flightReport  forKey:@"flightReportType"];
        //bp should be unique while saving the crew
        
        /* predicate = [NSPredicate predicateWithFormat:@"firstName==%@ AND lastName==%@ AND bp==%@",crew1.firstName,crew1.lastName,crew1.bp];
         */
        predicate = [NSPredicate predicateWithFormat:@"bp==%@",crew1.bp];
        // results = [[flight.flightCrew array] filteredArrayUsingPredicate:predicate];
        if ([results count]>0) {
            CrewMembers *crew =(CrewMembers*)[results objectAtIndex:0];
            GADComments *comments = (GADComments*)crew.crewComments;
            if (comments != nil) {
                if (comments.observerComments)[crewMemberDict setObject:comments.observerComments forKey:@"Feedback_Observer"];
                if (comments.observerSign)[crewMemberDict setObject:comments.observerSign forKey:@"Signatur_Observer"];
                if (comments.tcComments ) [crewMemberDict setObject:comments.tcComments forKey:@"Comments_TC"];
                if (comments.tcSign)     [crewMemberDict setObject:comments.tcSign forKey:@"Signature_TC"];
            }
            [crewMemberDict setObject:[crew1.crewCategory array] forKey:@"GadCategoryFeedback"];
        }
        
        
        
    }
    [crewMemberDict setObject:crew1 forKey:@"CrewMember"];
    return crewMemberDict;
}

+(int)getCrewmemberErrorAttemptsCount:(NSString *)bpNumber {
    int attemptValue = 0;
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"CrewMembers"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bp==%@",bpNumber];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        
        CrewMembers *crew =[results objectAtIndex:0];
        return crew.errorAttempts.integerValue;
    }
    
    return attemptValue;
}

+(NSArray *)getAllManuallyAddedFlights {
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isManualyEntered == %d",manuFlightAdded];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [appDel.managedObjectContext executeFetchRequest:request error:&error];
    return results;
}

+(int)getCrewmemberEAAttemptsCount:(NSString *)bpNumber {
    int attemptValue = 0;
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"CrewMembers"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bp==%@",bpNumber];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        
        CrewMembers *crew =[results objectAtIndex:0];
        return crew.eaAttemts.integerValue;
    }
    
    return attemptValue;
}

+(int)getCrewmemberAttemptsCount:(NSString *)bpNumber {
    
    int attemptValue = 0;
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"CrewMembers"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bp==%@",bpNumber];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        
        CrewMembers *crew =[results objectAtIndex:0];
        return [crew.attempts intValue];
    }
    
    return attemptValue;
}

+(NSString *)getCrewMemberURI:(NSString *)bpNumber {
    NSString *imageURI=@"";
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"CrewMembers"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bp==%@",bpNumber];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        
        CrewMembers *crew =[results objectAtIndex:0];
        return crew.imageUrl;
    }
    
    return imageURI;
}

+(NSArray *)getCrewMemberRanks {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CrewMembers" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"CrewMembers"];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = [NSArray arrayWithObjects:[[entity propertiesByName] objectForKey:@"activeRank"],[[entity propertiesByName] objectForKey:@"lastName"],nil];
    request.returnsDistinctResults = YES;
    
    NSSortDescriptor *activeRankSort = [[NSSortDescriptor alloc] initWithKey:@"activeRank" ascending:YES];
    
    NSSortDescriptor *lastNameSort = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:activeRankSort,lastNameSort, nil]];
    
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    return results;
}

//Sajjad
+(NSString*)getUriForType:(enum reportType)report forDict:(NSDictionary*)flightDict {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSDictionary *dict = [flightDict objectForKey:@"flightKey"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@ OR flightReport ==%@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"],[flightDict objectForKey:@"reportId"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        Uris *uri = flight.flightUri;
        
        switch (report) {
            case IV:
                return uri.createFlight;
                break;
            case GADReport:
                return uri.gad;
                break;
            case CUS:
                return uri.cus;
                break;
            case Image:
                return uri.flightImage;
            default:
                break;
        }
    }
    return @"";
}

@end
