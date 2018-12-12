//
//  LTDeleteOlderFlight.m
//  LATAM
//
//  Created by Palash on 08/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTDeleteOlderFlight.h"
#import "AppDelegate.h"
#import "LTSingleton.h"
#import "SynchronizationController.h"
#import "UserInformationParser.h"

@implementation LTDeleteOlderFlight
//delete old flight based on date or type or user
-(void)deleteFlightForType:(enum deleteType)type FlightsArray:(NSArray*)flightArr {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        User *user = (User*)[results objectAtIndex:0];
        switch (type) {
            case bydate: {
                int counter = [[user.flightRosters array] count];
                for (int j = counter - 1; j >= 0; j--) {
                    FlightRoaster *flight = [[user.flightRosters array] objectAtIndex:j];
                    NSTimeInterval secondsBetween = [flight.flightDate timeIntervalSinceNow];
                    int diff = secondsBetween;
                    
                    BOOL isFlightEmpty = YES;
                    NSDictionary *statusDictionary = [UserInformationParser getStatusForFlight:flight];
                    NSInteger stat = [[statusDictionary objectForKey:@"flightStatus"] integerValue];
                    if (stat > 0) {
                        isFlightEmpty = NO;
                    }
                    else if([[statusDictionary objectForKey:@"GAD"] count] > 0) {
                        isFlightEmpty = NO;
                    }
                    else if([[statusDictionary objectForKey:@"CUS"] count] > 0) {
                        isFlightEmpty = NO;
                    }
                    
                    int secondsInDay = 60 * 60 * 24;
                    if (diff < -(secondsInDay*15) || (diff < -(secondsInDay*7) && isFlightEmpty) || diff > secondsInDay*3) {
                        if (nil != flight) {
                            [self deleteFromLegForFlight:flight];
                            [user removeFlightRostersObject:flight];
                            [user.managedObjectContext deleteObject:flight];
                            
                            
                            NSDate *flightDate =[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightDate"];
                            NSString *airlineCode = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"];
                            NSString *flightNumber = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"];
                            if([flightDate timeIntervalSinceDate:flight.flightDate] == 0 && [airlineCode isEqualToString:flight.airlineCode] && [flightNumber isEqualToString:flight.flightNumber]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                });
                            }
                        }
                    }
                }
                
                break;
            }
                
            case byflight: {
                NSPredicate *predicate;
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:DATEFORMAT];
                int counter = [[user.flightRosters array] count];
                NSArray *flightArray = [[user flightRosters] array];
                for (int j = counter - 1; j >= 0; j--) {
                    FlightRoaster *flight = [flightArray objectAtIndex:j];
                    predicate = [NSPredicate predicateWithFormat:@"airlineCode==%@ AND flightNumber=%@ AND flightDate=%@ AND suffix=%@",flight.airlineCode,flight.flightNumber,[format stringFromDate:flight.flightDate],flight.suffix];
                    NSArray *result=[flightArr filteredArrayUsingPredicate:predicate];//checking if the flight is existing in the array
                    if ([result count] == 0 && ![flight.isDataSaved boolValue] && [flight.isManualyEntered intValue]==notManualFlight && ![flight.manulaCrewAdded boolValue]) {
                        if (flight!=nil) {
                            [self deleteFromLegForFlight:flight];
                            [user removeFlightRostersObject:flight];
                            [user.managedObjectContext deleteObject:flight];
                        }
                        
                    } else if([result count] > 0) {//flight found
                        for (Legs *leg in [flight.flightInfoLegs array]) {
                            predicate = [NSPredicate predicateWithFormat:@"origin==%@",leg.origin];
                            NSArray *legArr = [[result objectAtIndex:0] objectForKey:@"legs"];
                            NSArray *results = [legArr filteredArrayUsingPredicate:predicate];
                            if ([results count] == 0) {
                                if (leg != nil) {//legnot found
                                    [self deleteLegFromFlight:leg];
                                    [flight removeFlightInfoLegsObject:leg];
                                    [flight.managedObjectContext deleteObject:leg];
                                }
                            } else if ([results count] > 0) {//if leg found
                                //migrating leg origin and destination one by one
                                
                                // Modified by Palash
                                for (int i = 0; i < [results count]; i++) {
                                    if([flight.status intValue] < 1) {
                                        NSMutableDictionary *dict = [results objectAtIndex:i];
                                        if ([[dict objectForKey:@"origin"] isEqualToString:leg.origin]) {
                                            leg.destination=[dict objectForKey:@"destination"];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                break;
            }
            case byuser: {
                NSLog(@"flight roaster array=%@",[user.flightRosters array]);
                int counter = [[user.flightRosters array] count];
                for (int j=counter-1; j >= 0; j--) {
                    FlightRoaster *flight = [[user.flightRosters array] objectAtIndex:j];
                    if (flight!=nil) {
                        [self deleteFromLegForFlight:flight];
                        [user removeFlightRostersObject:flight];
                        [user.managedObjectContext deleteObject:flight];
                    }
                    
                }
                if (user!=nil) {
                    [managedObjectContext deleteObject:user];
                }
                
                break;
            }
                
            default:
                break;
        }
    }
    
    if (![managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
}

-(void)deleteFromLegForFlight:(FlightRoaster*)flight{
    
    if (flight != nil) {
        [self deleteImagesForFlightDict:flight];
        NSArray *legsArray = [[flight.flightInfoLegs array] copy];
        for (Legs *leg in legsArray) {
            if (leg != nil) {
                
                NSInteger counter = [[leg.legsCrewmember array] count];
                for(NSInteger i = counter - 1; i>= 0; i--) {
                    CrewMembers *crew = [leg.legsCrewmember objectAtIndex:i];
                    if (crew != nil) {
                        NSArray *crewCategoryArray = [[crew.crewCategory array] copy];
                        for (GADCategory *gCat in crewCategoryArray) {
                            if (gCat != nil) {
                                NSArray *categoryValueArray = [[gCat.categoryValue array] copy];
                                for (GADValue *val in categoryValueArray) {
                                    [gCat removeCategoryValueObject:val];
                                    [gCat.managedObjectContext deleteObject:val];
                                }
                                [crew removeCrewCategoryObject:gCat];
                                [crew.managedObjectContext deleteObject:gCat];
                            }
                        }
                        [leg removeLegsCrewmemberObject:crew];
                        [leg.managedObjectContext deleteObject:crew];
                        
                        
                    }
                }
                
                NSInteger counter2 = [[leg.legCustomer array] count];
                for(NSInteger i = counter2 - 1; i >= 0; i--) {
                    Customer *cust = [[leg.legCustomer array] objectAtIndex:i];
                    if (cust!=nil) {
                        NSInteger counter3 = [[cust.cusCusReport array] count];
                        for (NSInteger m=counter3-1; m>=0; m--) {
                            CusReport *cusReport = [[cust.cusCusReport array] objectAtIndex:m];
                            if (cusReport!=nil) {
                                NSArray *cusGroupArray = [cusReport.reportGroup array];
                                for (Groups *group in cusGroupArray) {
                                    NSArray *groupOccurrencesArray = [[group.groupOccourences array] copy];
                                    for (Events *event in groupOccurrencesArray) {
                                        NSInteger count3 = [[event.eventsRow array] count];
                                        for (NSInteger j=count3-1;j>=0;j-- ) {
                                            Row *row = [[event.eventsRow array] objectAtIndex:j];
                                            NSArray *rowContentArray = [[row.rowContent array] copy];
                                            for (Contents *content in rowContentArray) {
                                                if (content!=nil) {
                                                    [row removeRowContentObject:content];
                                                    [row.managedObjectContext deleteObject:content];
                                                }
                                                
                                            }
                                            if (row!=nil) {
                                                [event removeEventsRowObject:row];
                                                [event.managedObjectContext deleteObject:row];
                                            }
                                            
                                        }
                                        if (event!=nil) {
                                            [group removeGroupOccourencesObject:event];
                                            [group.managedObjectContext deleteObject:event];
                                        }
                                        
                                    }
                                    if (group!=nil) {
                                        [cusReport removeReportGroupObject:group];
                                        [cusReport.managedObjectContext deleteObject:group];
                                    }
                                    [cust removeCusCusReportObject:cusReport];
                                    [cust.managedObjectContext deleteObject:cusReport];
                                }
                                [leg removeLegCustomerObject:cust];
                                [leg.managedObjectContext deleteObject:cust];
                            }
                        }
                    }
                }
                
                [self deleteLegFromFlight:leg];
                [flight removeFlightInfoLegsObject:leg];
                [flight.managedObjectContext deleteObject:leg];
            }
        }
        
        Uris *uri = flight.flightUri;
        if (uri!=nil) {
            [flight.managedObjectContext deleteObject:uri];
        }
    }
    
    NSError *error;
    if (![flight.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
}

-(void)deleteLegFromFlight:(Legs*)leg{
    @try {
        for (int i=0; i<[[leg.legsCrewmember array] count]; i++) {
            if ([[[leg.legsCrewmember array] objectAtIndex:i] isKindOfClass:[CrewMembers class]]) {
                CrewMembers *crew =[[leg.legsCrewmember array] objectAtIndex:i];
                if (crew!=nil) {
                    
                    
                    for (GADCategory *gCat in [crew.crewCategory array]) {
                        if (gCat!=nil) {
                            for (GADValue *val in [gCat.categoryValue array]) {
                                [gCat removeCategoryValueObject:val];
                                [gCat.managedObjectContext deleteObject:val];
                            }
                            [crew removeCrewCategoryObject:gCat];
                            [crew.managedObjectContext deleteObject:gCat];
                        }
                    }
                    [leg removeLegsCrewmemberObject:crew];
                    [leg.managedObjectContext deleteObject:crew];
                    
                }
                
            }
        }
        
        Report *report = leg.legFlightReport;
        if (report!=nil) {
            for (FlightReports *fReport in report.flightReportReport) {
                for (Sections *section in [fReport.reportSection array]) {
                    for (Groups *group in [section.sectionGroup array]) {
                        for (Events *event in [group.groupOccourences array]) {
                            NSInteger count3 = [[event.eventsRow array] count];
                            for (NSInteger j=count3-1;j>=0;j-- ){
                                Row *row = [[event.eventsRow array] objectAtIndex:j];
                                
                                for (Contents *content in [row.rowContent array]) {
                                    if (content!=nil) {
                                        [row removeRowContentObject:content];
                                        [row.managedObjectContext deleteObject:content];
                                    }
                                }
                                if (row!=nil) {
                                    [event removeEventsRowObject:row];
                                    [event.managedObjectContext deleteObject:row];
                                }
                            }
                            if (event!=nil) {
                                [group removeGroupOccourencesObject:event];
                                [group.managedObjectContext deleteObject:event];
                            }
                        }
                        if (group!=nil) {
                            [section removeSectionGroupObject:group];
                            [section.managedObjectContext deleteObject:group];
                        }
                    }
                    if (section!=nil) {
                        [fReport removeReportSectionObject:section];
                        [fReport.managedObjectContext deleteObject:section];
                    }
                }
                if (fReport!=nil) {
                    [report removeFlightReportReportObject:fReport];
                    [report.managedObjectContext deleteObject:fReport];
                }
            }
            
            [leg.managedObjectContext deleteObject:report];
        }
    }
    @catch (NSException *exception) {
        DLog(@"ec=%@",exception.description);
    }
}

-(void)deleteImagesForFlightDict:(FlightRoaster *)flightobj {
    NSString *date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    date = [dateFormatter stringFromDate:flightobj.flightDate];
    NSArray *array = @[@"FlightReport",@"CUS",@"GadReport"];
    for (NSString *folderName in array) {
        NSMutableString *flightName=[NSMutableString stringWithFormat:@"%@%@%@",flightobj.airlineCode,flightobj.flightNumber,date];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",folderName]];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",dataPath,flightName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        NSString *zipFilePath = [filePath stringByAppendingPathExtension:@"zip"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
        }
    }
}

@end
