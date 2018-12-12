//
//  UserInformationParser.m
//  Nimbus2
//
//  Created by 720368 on 8/7/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "UserInformationParser.h"

#import "NSDate+Utils.h"

@implementation UserInformationParser



+(FlightRoaster*)getFlightRoaster:(NSDictionary *)flightDict withManagedObject:(NSManagedObjectContext*)managedObjectContext {
    //inserting if first time
    FlightRoaster *flight;
    if(nil != flightDict) {
        
        flight = [NSEntityDescription insertNewObjectForEntityForName:@"FlightRoaster" inManagedObjectContext:managedObjectContext];
        flight.airlineCode = [flightDict checkNilValueForKey:@"airlineCode"];
        
        flight.lastSynchTime = [[NSDate date] toLocalTime];
        
        flight.company= [flightDict checkNilValueForKey:@"company"];
        flight.flightNumber = [flightDict checkNilValueForKey:@"flightNumber"];
        
        if(![[flightDict checkNilValueForKey:@"material"] isEqualToString:@""])
            flight.material = [flightDict checkNilValueForKey:@"material"];
        if([[flightDict checkNilValueForKey:@"materialType"] isEqualToString:@""])
            flight.materialType = [self getMaterialType:flight.material];
        else
            flight.materialType = [flightDict checkNilValueForKey:@"materialType"];
        
        flight.suffix = [flightDict checkNilValueForKey:@"suffix"];
        flight.tailNumber = [flightDict checkNilValueForKey:@"tailNumber"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:DATEFORMAT];
        flight.flightDate = [dateFormat dateFromString:[flightDict checkNilValueForKey:@"flightDate"]];
        flight.businessUnit = [flightDict checkNilValueForKey:@"businessUnit"];
        flight.type=[self getFlightTypeFromMeterial:flight.material BusinessUnit:flight.businessUnit AirlineCode:flight.airlineCode];
        int number = arc4random_uniform(900000000) + 100000000;
        flight.flightReport=[NSString stringWithFormat:@"%@%@%d", flight.airlineCode, flight.flightNumber,number];
        
        NSDictionary *linksDict = [flightDict checkNilValueForKey:@"links"];
        Uris *uri = [NSEntityDescription insertNewObjectForEntityForName:@"Uris" inManagedObjectContext:managedObjectContext];
        uri.createFlight = [linksDict checkNilValueForKey:@"uriFlightReport"];
        uri.gad= [linksDict checkNilValueForKey:@"uriGAD"];
        uri.cus = [linksDict checkNilValueForKey:@"uriCUS"];
        flight.flightUri=uri;
        if ([[flightDict checkNilValueForKey:@"legs"] isKindOfClass:[NSArray class]]) {
            NSArray *legsArray = [flightDict checkNilValueForKey:@"legs"];
            for (int j = 0; j < [legsArray count]; j++) {
                NSDictionary *dict = [legsArray objectAtIndex:j];
                Legs *legs = [NSEntityDescription insertNewObjectForEntityForName:@"Legs" inManagedObjectContext:managedObjectContext];
                
                legs.destination = [dict checkNilValueForKey:@"destination"];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:DATEFORMAT];
                
                NSDate *date = [dateFormat dateFromString:[NSString stringWithFormat:@"%@",[dict checkNilValueForKey:@"legArrivalUTC"]]];
                legs.legArrivalUTC=date;
                NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
                [dateFormat1 setDateFormat:DATEFORMAT];
                
                legs.legDepartureLocal = [dateFormat1 dateFromString:[dict checkNilValueForKey:@"legDepartureLocal"]];
                if (j==0) {
                    flight.sortTime =  legs.legDepartureLocal;
                    if (![[dict checkNilValueForKey:@"gateNumber"] isEqualToString:@"-"]) {
                        flight.gateNumber = [dict checkNilValueForKey:@"gateNumber"];
                    }
                    
                }
                NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
                [dateFormat2 setDateFormat:DATEFORMAT];
                legs.legArrivalLocal = [dateFormat2 dateFromString:[dict checkNilValueForKey:@"legArrivalLocal"]];
                NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
                [dateFormat3 setDateFormat:DATEFORMAT];
                legs.legDepartureUTC = [dateFormat3 dateFromString:[dict checkNilValueForKey:@"legDepartureUTC"]];
                legs.origin = [dict checkNilValueForKey:@"origin"];
                if ([[dict checkNilValueForKey:@"businessUnit"] isEqualToString:@"<null>"]) {
                    legs.businessUnit = @"";
                } else
                    legs.businessUnit = [dict checkNilValueForKey:@"businessUnit"];
                [flight addFlightInfoLegsObject:legs];
                //inserting cabin
                NSArray *cabinArray = [dict objectForKey:@"cabinsOccupancies"];
                if ([cabinArray isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *cabinDict in cabinArray) {
                        
                        if(cabinDict[@"type"] && ![cabinDict[@"type"] isEqual:[NSNull null]] && ![cabinDict[@"type"] isEqualToString:@"<null>"]) {
                        
                            ClassType *ctype = [NSEntityDescription insertNewObjectForEntityForName:@"ClassType" inManagedObjectContext:managedObjectContext];
                            ctype.name = [cabinDict objectForKey:@"type"];
                            ctype.availablepassenger = [[cabinDict objectForKey:@"booking"] objectForKey:@"booked"];
                            ctype.capacity = [[cabinDict objectForKey:@"booking"] objectForKey:@"authorized"];
                            [legs addLegClassObject:ctype];
                        }
                    }
                }
            }
        }
        NSError *error ;
        
        if(![managedObjectContext save:&error]) {
            NSLog(@"Failed to save flightroster");
        }
    }
    return flight;
}

+(BOOL)saveFlightListFromDict:(NSDictionary*)responseDict {
    NSMutableDictionary *errorDict = [[NSMutableDictionary alloc] init];
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    ///Adding current user from username
    LTDeleteOlderFlight *deleteFlight = [[LTDeleteOlderFlight alloc] init];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", [LTSingleton getSharedSingletonInstance].username];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if([results count] > 0) {
        currentUser = [results objectAtIndex:0];
        if ([responseDict valueForKey:@"user"]!=nil) {
            if ([[responseDict valueForKey:@"user"] valueForKey:@"flightActivities"] != nil) {
                [deleteFlight deleteFlightForType:byflight FlightsArray:[[responseDict checkNilValueForKey:@"user"] valueForKey:@"flightActivities"]];
            }
        }
    } else {
        [deleteFlight deleteFlightForType:byuser FlightsArray:nil];
        currentUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
        currentUser.firstName = @"FirstName";
        currentUser.lastName = @"LastName";
        currentUser.bp = @"123456";
        currentUser.username = [LTSingleton getSharedSingletonInstance].username;
        [LTSingleton getSharedSingletonInstance].user = [NSString stringWithFormat:@"%@ %@",currentUser.firstName,currentUser.lastName];
        [TempLocalStorageModel saveInUserDefaults:[LTSingleton getSharedSingletonInstance].user withKey:@"user"];
        
    }
    
    if ([responseDict objectForKey:@"user"] != nil) {
            
        @try {
        
            //use existing current user
            
            currentUser.firstName = [[responseDict checkNilValueForKey:@"user"] checkNilValueForKey:@"firstName"];
            currentUser.lastName = [[responseDict checkNilValueForKey:@"user"] checkNilValueForKey:@"lastName"];
            currentUser.bp = [[responseDict checkNilValueForKey:@"user"] checkNilValueForKey:@"bp"];
            currentUser.crewBase = [[responseDict checkNilValueForKey:@"user"] checkNilValueForKey:@"crewBase"];
            
            [LTSingleton getSharedSingletonInstance].user = [NSString stringWithFormat:@"%@ %@",currentUser.firstName,currentUser.lastName];
            [TempLocalStorageModel saveInUserDefaults:[LTSingleton getSharedSingletonInstance].user withKey:@"user"];
        }
        
        @catch (NSException *exception) {
            DLog(@"no data found");
        }
            
        if ([[[responseDict valueForKey:@"user"] objectForKey:@"flightActivities"] isKindOfClass:[NSArray class]]) {
            NSArray *array = [[responseDict objectForKey:@"user"] valueForKey:@"flightActivities"];
            for (int i = 0; i<[array count]; i++) {
                
                @try {
                
                    NSDictionary *dict = [array objectAtIndex:i];
                    
                    if([dict objectForKey:@"serviceStatus"] != nil && [[dict objectForKey:@"serviceStatus"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dict2 = [[dict objectForKey:@"serviceStatus"] objectAtIndex:0];
                        if ([[dict2 objectForKey:@"code"] integerValue] != 3) {//check if not business unit
                            NSString *pt = [[dict2 objectForKey:@"mapLanguages"] objectForKey:@"pt"];
                            NSString *es = [[dict2 objectForKey:@"mapLanguages"] objectForKey:@"es"];
                            if (appdelegate.currentLanguage==LANG_SPANISH) {
                                [errorDict setValue:es forKey:[NSString stringWithFormat:@"%@%@",[dict checkNilValueForKey:@"airlineCode"],[dict checkNilValueForKey:@"flightNumber"]]];
                            } else if (appdelegate.currentLanguage==LANG_PORTUGUESE) {
                                [errorDict setValue:pt forKey:[NSString stringWithFormat:@"%@%@",[dict checkNilValueForKey:@"airlineCode"],[dict checkNilValueForKey:@"flightNumber"]]];
                            } else {
                            
                            }
                        }
                    }
                    
                    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
                    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
                    [dateFormat3 setDateFormat:DATEFORMAT];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [dateFormat3 dateFromString:[dict checkNilValueForKey:@"flightDate"]],[dict checkNilValueForKey:@"suffix"],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"airlineCode"]];
                    [request setPredicate:predicate];
                    NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate]    ;
                    if([results count] > 0) {
                        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
                        if ([flight.isManualyEntered intValue]==manuFlightAdded) {
                            continue;
                        }
                        {
                            if ([flight.status intValue] < 1) {
                                flight.lastSynchTime = [[NSDate date] toLocalTime];
                                flight.company= [dict checkNilValueForKey:@"company"];
                                flight.airlineCode = [dict checkNilValueForKey:@"airlineCode"];
                                flight.flightNumber = [dict checkNilValueForKey:@"flightNumber"];
                                if(![[dict checkNilValueForKey:@"material"] isEqualToString:@""])
                                    flight.material=[dict checkNilValueForKey:@"material"];
                                Uris *uri = flight.flightUri;
                                NSDictionary *linksDict = [dict checkNilValueForKey:@"links"];
                                
                                uri.createFlight = [linksDict checkNilValueForKey:@"uriFlightReport"];
                                uri.gad= [linksDict checkNilValueForKey:@"uriGAD"];
                                uri.cus = [linksDict checkNilValueForKey:@"uriCUS"];
                                
                                if([[dict checkNilValueForKey:@"materialType"] isEqualToString:@""])
                                {
                                    flight.materialType = [self getMaterialType:flight.material];
                                }
                                else
                                    flight.materialType = [dict checkNilValueForKey:@"materialType"];
                                
                                flight.suffix = [dict checkNilValueForKey:@"suffix"];
                                
                                if (![flight.tailNumber isEqualToString:[dict checkNilValueForKey:@"tailNumber"]]) {
                                    flight.tailNumber = [dict checkNilValueForKey:@"tailNumber"];
                                    flight.isFlightSeatMapSynched=FALSE;
                                }
                                int number = arc4random_uniform(900000000) + 100000000;
                                flight.flightReport=[NSString stringWithFormat:@"%@%d",flight.airlineCode,number];
                                if (flight.businessUnit==nil) {
                                    flight.businessUnit = [dict checkNilValueForKey:@"businessUnit"];
                                }
                                
                                flight.type=[self getFlightTypeFromMeterial:flight.material BusinessUnit:flight.businessUnit AirlineCode:flight.airlineCode];
                                //}
                                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                [dateFormat setDateFormat:DATEFORMAT];
                                flight.flightDate = [dateFormat dateFromString:[dict checkNilValueForKey:@"flightDate"]];
                                //linksDict = [dict checkNilValueForKey:@"links"];
                                
                                if ([[dict checkNilValueForKey:@"legs"] isKindOfClass:[NSArray class]]) {
                                    NSArray *legsArray = [dict checkNilValueForKey:@"legs"];
                                    
                                    for (int j=0; j<[legsArray count]; j++) {
                                        NSDictionary *legsDict = [legsArray objectAtIndex:j];
                                        NSArray *array = [flight.flightInfoLegs array];
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"origin = %@ AND destination = %@", [legsDict checkNilValueForKey:@"origin"],[legsDict checkNilValueForKey:@"destination"]];
                                        NSArray *arrarLegs = [array filteredArrayUsingPredicate:predicate];
                                        
                                        Legs *legs;
                                        BOOL isExistsLeg = NO;
                                        if([arrarLegs count] > 0) {
                                            isExistsLeg = YES;
                                            legs = [arrarLegs objectAtIndex:0];
                                        } else {
                                            legs = [NSEntityDescription insertNewObjectForEntityForName:@"Legs" inManagedObjectContext:managedObjectContext];
                                        }
                                        if (![flight.isDataSaved boolValue]) {
                                            legs.destination = [legsDict checkNilValueForKey:@"destination"];
                                            legs.businessUnit = [legsDict checkNilValueForKey:@"businessUnit"];
                                            legs.origin = [legsDict checkNilValueForKey:@"origin"];
                                        }
                                        
                                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                        [dateFormat setDateFormat:DATEFORMAT];
                                        NSDate *date = [dateFormat dateFromString:[legsDict checkNilValueForKey:@"legArrivalUTC"]];
                                        legs.legArrivalUTC = date;
                                        legs.legArrivalUTC = date;
                                        NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
                                        [dateFormat1 setDateFormat:DATEFORMAT];
                                        
                                        
                                        legs.legDepartureLocal = [dateFormat1 dateFromString:[legsDict checkNilValueForKey:@"legDepartureLocal"]];
                                        if (j==0) {
                                            flight.sortTime =  legs.legDepartureLocal;
                                            if (![[legsDict checkNilValueForKey:@"gateNumber"] isEqualToString:@"-"]) {
                                                flight.gateNumber = [legsDict checkNilValueForKey:@"gateNumber"];
                                            }
                                            
                                        }
                                        
                                        NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
                                        [dateFormat2 setDateFormat:DATEFORMAT];
                                        legs.legArrivalLocal = [dateFormat2 dateFromString:[legsDict checkNilValueForKey:@"legArrivalLocal"]];
                                        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
                                        [dateFormat3 setDateFormat:DATEFORMAT];
                                        legs.legDepartureUTC = [dateFormat3 dateFromString:[legsDict checkNilValueForKey:@"legDepartureUTC"]];
                                        
                                        if(!isExistsLeg) {
                                            NSArray *cabinArray = [dict objectForKey:@"cabinsOccupancies"];
                                            if ([cabinArray isKindOfClass:[NSArray class]]) {
                                                for (NSDictionary *cabinDict in cabinArray) {
                                                    ClassType *ctype = [NSEntityDescription insertNewObjectForEntityForName:@"ClassType" inManagedObjectContext:managedObjectContext];
                                                    ctype.name = [cabinDict objectForKey:@"type"];
                                                    ctype.availablepassenger = [[cabinDict objectForKey:@"booking"] objectForKey:@"booked"];
                                                    ctype.capacity = [[cabinDict objectForKey:@"booking"] objectForKey:@"authorized"];
                                                    [legs addLegClassObject:ctype];
                                                }
                                            }
                                            
                                            [flight addFlightInfoLegsObject:legs];
                                        }
                                        else {
                                            NSArray *cabinArray = [legsDict objectForKey:@"cabinsOccupancies"];
                                            for(ClassType *ctype in legs.legClass) {
                                                for (NSDictionary *cabinDict in cabinArray) {
                                                    if([ctype.name isEqualToString:cabinDict[@"type"]]) {
                                                        ctype.availablepassenger = [[cabinDict objectForKey:@"booking"] objectForKey:@"booked"];
                                                        ctype.capacity = [[cabinDict objectForKey:@"booking"] objectForKey:@"authorized"];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    } else {
                        FlightRoaster *flight =  [self getFlightRoaster:dict withManagedObject:managedObjectContext];
                        [currentUser addFlightRostersObject:flight];
                    }
                }

                @catch (NSException *exception) {
                    DLog(@"problem loadin flight");
                }
            }
        }
        
        if (![managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
        
        [deleteFlight deleteFlightForType:bydate FlightsArray:nil];
        return YES;
    }
    else  if([responseDict objectForKey:@"serviceStatus"] != nil) {
        if ([LTSingleton getSharedSingletonInstance].isUserChanged) {
            LTDeleteOlderFlight *deleteFlight = [[LTDeleteOlderFlight alloc] init];
            [deleteFlight deleteFlightForType:byuser FlightsArray:nil];
        }
        NSDictionary *dict = [[responseDict objectForKey:@"serviceStatus"] objectAtIndex:0];
        NSString *pt = [[dict objectForKey:@"mapLanguages"] objectForKey:@"pt"];
        NSString *es = [[dict objectForKey:@"mapLanguages"] objectForKey:@"es"];
        if (appdelegate.currentLanguage==LANG_SPANISH) {
            [errorDict setValue:es forKey:@"Error!"];
        } else if (appdelegate.currentLanguage==LANG_PORTUGUESE){
            [errorDict setValue:pt forKey:@"Error!"];
        } else{
            [AlertUtils showErrorAlertWithTitle:[appdelegate copyTextForKey:@"STATUS_ERROR"] message:@"No new flights found. Showing previously synched flights."];
        }
        
        return YES;
    }
    
    error = nil;
    if(![managedObjectContext save:&error]) {
        NSLog(@"Failed to save ");
    }
    
    return YES;
}

+(NSString *)getMaterialType:(NSString*)material {
    NSString *type=@"";
    
    if ([material containsString:@"A318"] || [material containsString:@"A319"] || [material containsString:@"A320"] || [material containsString:@"A321"] || [material containsString:@"B737"] || [material containsString:@"DHC-8"]) {
        type=@"NB";
    }else if ([material containsString:@"A330"] || [material containsString:@"A340"] || [material containsString:@"A350"] || [material containsString:@"B767"] || [material containsString:@"B787"] || [material containsString:@"B777"] || [material containsString:@"B789"]){
        type=@"WB";
    }
    
    return type;
}

//getting the type of the flight based on internal rules.
+(NSString *)getFlightTypeFromMeterial:(NSString*)material BusinessUnit:(NSString*)businessUnit AirlineCode:(NSString*)airlineCode{
    NSString *type;
    if ([businessUnit containsString:@"INT"] || [businessUnit containsString:@"REG"]) {
        //Check If it is NB or WB
        if ([material containsString:@"A318"] || [material containsString:@"A319"] || [material containsString:@"A320"] || [material containsString:@"A321"] || [material containsString:@"B737"] || [material containsString:@"DHC-8"]) {
            type=@"NB";
        }else if ([material containsString:@"A330"] || [material containsString:@"A340"] || [material containsString:@"A350"] || [material containsString:@"B767"] || [material containsString:@"B787"] || [material containsString:@"B789"] || [material containsString:@"B777"]){
            type=@"WB";
        }
    }else if ([businessUnit containsString:@"DOM"]){
        type=@"DM";
    }
    if ([airlineCode containsString:@"LA"] || [airlineCode containsString:@"LU"] || [airlineCode containsString:@"LP"] || [airlineCode containsString:@"4M"] || [airlineCode containsString:@"4C"] || [airlineCode containsString:@"XL"]) {
        type = [type stringByAppendingString:@"LAN"];
    }else if ([airlineCode containsString:@"JJ"] || [airlineCode containsString:@"PZ"]){
        type = [type stringByAppendingString:@"TAM"];
    }
    return type;
}


+(NSArray*)getFlightRoaster {
    //NSMutableArray *allFlightArray = [[NSMutableArray alloc] init];
    
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
    if([results count]>0) {
        currentUser = [results objectAtIndex:0];
        NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"sortTime" ascending:YES];
        NSMutableArray *flightActivitiesArr = [[[currentUser.flightRosters array] sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]] mutableCopy];
        for (FlightRoaster *flight in flightActivitiesArr) {
            NSMutableDictionary *fkeydict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *flightdict = [[NSMutableDictionary alloc]init];
            
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
            if (flight.flightReport) {
                [fkeydict setObject:flight.flightReport forKey:@"reportId"];
            }
            if (flight.type) {
                [flightdict setObject:flight.type forKey:@"flightReportType"];
            }
            if (flight.material) {
                [flightdict setObject:flight.material forKey:@"material"];
            }
            if (flight.materialType) {
                [flightdict setObject:flight.materialType forKey:@"materialType"];
            }
            if (flight.tailNumber) {
                [flightdict setObject:flight.tailNumber forKey:@"tailNumber"];
            }
            if (flight.sortTime) {
                [flightdict setObject:flight.sortTime forKey:@"sortTime"];
            }
            if (flight.isManualyEntered) {
                [flightdict setObject:flight.isManualyEntered forKey:@"isManualyEntered"];
            }
            if (flight.status) {
                [flightdict setObject:flight.status forKey:@"status"];
            }
            if (flight.isDataSaved) {
                [flightdict setObject:flight.isDataSaved forKey:@"isDataSaved"];
            }
            if (flight.businessUnit) {
                [flightdict setObject:flight.businessUnit forKey:@"businessUnit"];
            }
            if (flight.isFlownAsJSB) {
                [flightdict setObject:flight.isFlownAsJSB forKey:@"isFlownAsJSB"];
            }
            if (flight.isPublicationSynched) {
                [flightdict setObject:flight.isPublicationSynched forKey:@"isPublicationSynched"];
            }
            if (flight.isFlightSeatMapSynched) {
                [flightdict setObject:flight.isFlightSeatMapSynched forKey:@"isFlightSeatMapSynched"];
            }
            if (flight.lastSynchTime) {
                [flightdict setObject:flight.lastSynchTime forKey:@"lastSynchTime"];
            }
            
            [flightdict setObject:@"1.0" forKey:@"flightReportVersion"];
            [flightdict setObject:fkeydict forKey:@"flightKey"];
            
            if ([[flight.flightInfoLegs array] count]==0) {
                continue;
            }else{
                NSMutableArray *legArray = [[NSMutableArray alloc] init];
                for (Legs *leg  in [flight.flightInfoLegs array]){
                    NSMutableDictionary *legDict = [[NSMutableDictionary alloc] init];
                    if(leg.legArrivalLocal)
                        [legDict setObject:leg.legArrivalLocal forKey:@"arrivalLocal"];
                    if(leg.legArrivalUTC)
                        [legDict setObject:leg.legArrivalUTC forKey:@"arrivalUTC"];
                    if(leg.legDepartureUTC)
                        [legDict setObject:leg.legDepartureUTC forKey:@"departureUTC"];
                    if(leg.legDepartureLocal)
                        [legDict setObject:leg.legDepartureLocal forKey:@"departureLocal"];
                    if(leg.destination)
                        [legDict setObject:leg.destination forKey:@"destination"];
                    if(leg.origin)
                        [legDict setObject:leg.origin forKey:@"origin"];
                    
                    [legArray addObject:legDict];
                    
                    BOOL bcExists = NO;
                    BOOL jcExists = NO;
                    
                    NSMutableArray *classArray = [[NSMutableArray alloc] init];
                    [legDict setObject:classArray forKey:@"seat"];
                    
                    if ([[leg.legClass array] count] > 0) {
                        for (ClassType *cls in [leg.legClass array]) {
                            NSMutableDictionary *classDict = [[NSMutableDictionary alloc] init];
                            if (cls.name) {
                                if([cls.name isEqualToString:@"JC"]) {
                                    jcExists = YES;
                                }
                                else if([cls.name isEqualToString:@"BC"]) {
                                    bcExists = YES;
                                }
                                [classDict setObject:cls.name forKey:@"name"];
                            }
                            if (cls.availablepassenger) {
                                [classDict setObject:cls.availablepassenger forKey:@"availibility"];
                            }
                            if (cls.capacity) {
                                [classDict setObject:cls.capacity forKey:@"capacity"];
                            }
                            
                            [classArray addObject:classDict];
                        }
                    }
                    
                    if(bcExists == NO) {
                        NSMutableDictionary *classDict = [[NSMutableDictionary alloc] init];
                        [classDict setObject:@"BC" forKey:@"name"];
                        [classDict setObject:@(0) forKey:@"availibility"];
                        [classDict setObject:@(1) forKey:@"capacity"];
                        [classArray addObject:classDict];
                    }
                    
                    if(jcExists == NO) {
                        NSMutableDictionary *classDict = [[NSMutableDictionary alloc] init];
                        [classDict setObject:@"JC" forKey:@"name"];
                        [classDict setObject:@(0) forKey:@"availibility"];
                        [classDict setObject:@(1) forKey:@"capacity"];
                        [classArray addObject:classDict];
                    }
                    
                    //NOTE(diego_cath): LAN requested that booking info be overriden with info from passengerList WS
                    for(NSMutableDictionary *classDict in classArray) {
                        if([classDict[@"name"] isEqualToString:@"JC"] && leg.legStats.numpj) {
                            [classDict setObject:leg.legStats.numpy forKey:@"availibility"];
                        }
                        else if([classDict[@"name"] isEqualToString:@"BC"] && leg.legStats.numpy) {
                            [classDict setObject:leg.legStats.numpj forKey:@"availibility"];
                        }
                    }
                }
                
                [flightdict setObject:legArray forKey:@"legs"];
            }
            
            [allFlightArray addObject:flightdict];
        }
        
    }
    
    return allFlightArray;
}


+(void)updateFlightType:(NSDictionary *)flightRoasterDict{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSDictionary *dict = [flightRoasterDict objectForKey:@"flightKey"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        flight.type=[flightRoasterDict objectForKey:@"flightReportType"];
        flight.material=[flightRoasterDict objectForKey:@"material"];
        flight.materialType=[flightRoasterDict objectForKey:@"materialType"];
        flight.businessUnit = [flightRoasterDict objectForKey:@"businessUnit"];
    }
    
    if(![managedObjectContext save:&error]) {
        NSLog(@"Failed to save flightroster");
    }
}

+(void)updateFlightStatus: (NSDictionary*)flightDict status:(enum status)status withUri:(NSString*)imgUri{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if([results count]>0) {
        currentUser = [results objectAtIndex:0];
    }
    
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:DATEFORMAT];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightReport == %@",[flightDict checkNilValueForKey:@"reportId"]];
    [request setPredicate:predicate];
    results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
    if ([results count]>0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        if (flight.isManualyEntered==[NSNumber numberWithInt:manuFlightErrored]) {
            flight.status= [NSNumber numberWithInt:draft];
        }else{
            flight.status= [NSNumber numberWithInt:status];
        }
        
        if (imgUri!=nil) {
            Uris *uri = flight.flightUri;
            uri.flightImage = imgUri;
        }
    }
    if(![managedObjectContext save:&error]) {
        NSLog(@"Failed to save flightroster");
    }
}


+(void)markFlightFlownAsTCForFlight:(NSDictionary*)flightRoasterDict andFlag:(BOOL)flag{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSDictionary *dict = [flightRoasterDict objectForKey:@"flightKey"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count]>0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        flight.isFlownAsJSB=[NSNumber numberWithBool:flag];
    }
    
    if(![managedObjectContext save:&error]) {
        NSLog(@"Failed to save flightroster");
    }
}


//check if keeys of the flights are same or not
+(BOOL)checkKeysSameBetween:(NSMutableDictionary *)fligh1 and:(NSMutableDictionary *)flight2{
    BOOL check=TRUE;
    if (![((NSString*)[fligh1 objectForKey:@"airlineCode"]) isEqualToString:((NSString*)[[flight2 objectForKey:@"flightKey"] objectForKey:@"airlineCode"])]) {
        check=FALSE;
        return check;
    }
    if(![((NSString*)[fligh1 objectForKey:@"flightNumber"]) isEqualToString:((NSString*)[[flight2 objectForKey:@"flightKey"] objectForKey:@"flightNumber"])]){
        
        check=FALSE;
        return check;
        
    }
    NSDate *date1 = [fligh1 objectForKey:@"flightDate"];
    NSDate *date2 = [[flight2 objectForKey:@"flightKey"] objectForKey:@"flightDate"];
    if ([date1 timeIntervalSinceDate:date2]!=0) {
        check=FALSE;
        return check;
    }
    return check;
}
//converting flight dictionary to flight object

+(FlightRoaster *)getFlightObjectFromDict:(NSMutableDictionary*)flightDict forManageObjectContext:(NSManagedObjectContext*)context {
    FlightRoaster *flightObj = [NSEntityDescription insertNewObjectForEntityForName:@"FlightRoaster" inManagedObjectContext:context];
    flightObj.airlineCode = [flightDict objectForKey:@"airlineCode"];
    flightObj.flightDate = [flightDict objectForKey:@"flightDate"];
    flightObj.flightNumber = [flightDict objectForKey:@"flightNumber"];
    int number = arc4random_uniform(900000000) + 100000000;
    flightObj.flightReport=[NSString stringWithFormat:@"%@%@%d",flightObj.airlineCode,flightObj.flightNumber,number];
    flightObj.isManualyEntered = [NSNumber numberWithInt:manuFlightAdded];
    flightObj.material = [flightDict objectForKey:@"materialType"];
    flightObj.suffix = @"_";
    flightObj.tailNumber = [flightDict objectForKey:@"matricularText"];
    
    for (int j=0;j<[[flightDict objectForKey:@"legs"] count];j++) {
        NSMutableDictionary *legDict = [[flightDict objectForKey:@"legs"] objectAtIndex:j];
        Legs *leg = [NSEntityDescription insertNewObjectForEntityForName:@"Legs" inManagedObjectContext:context];
        leg.destination = [legDict objectForKey:@"destination"];
        leg.origin = [legDict objectForKey:@"origin"];
        leg.legArrivalLocal = [legDict objectForKey:@"legArrivalLocal"];
        leg.legDepartureLocal = [legDict objectForKey:@"legDepartureLocal"];
        if (j==0) {
            flightObj.sortTime = leg.legArrivalLocal;
        }
        for (NSMutableDictionary *crewDict in [legDict objectForKey:@"crew"]) {
            CrewMembers *crew = [NSEntityDescription insertNewObjectForEntityForName:@"CrewMembers" inManagedObjectContext:context];
            crew.activeRank = [crewDict objectForKey:@"activeRank"];
            crew.firstName = [crewDict objectForKey:@"firstName"];
            crew.lastName = [crewDict objectForKey:@"lastName"];
            crew.specialRank = [crewDict objectForKey:@"specialRank"];
            [leg addLegsCrewmemberObject:crew];
        }
        if ([flightDict objectForKey:@"links"]!=nil) {
            flightObj.isManualyEntered=[NSNumber numberWithInt:manuFlightSynched];
            Uris *uri = [NSEntityDescription insertNewObjectForEntityForName:@"Uris" inManagedObjectContext:context];
            uri.createFlight= [[flightDict objectForKey:@"links"] objectForKey:@"uriFlightReport"];
            uri.cus = [[flightDict objectForKey:@"links"] objectForKey:@"uriCUS"];
            uri.gad = [[flightDict objectForKey:@"links"] objectForKey:@"uriGAD"];
            flightObj.flightUri=uri;
        }
        [flightObj addFlightInfoLegsObject:leg];
    }
    
    return flightObj;
}

+(NSMutableDictionary *)getFlightDictFromRoaster:(FlightRoaster*)flightObj{
    NSMutableDictionary *flightDict = [[NSMutableDictionary alloc] init];
    [flightDict setObject:flightObj.airlineCode forKey:@"airlineCode"];
    [flightDict setObject:flightObj.flightDate forKey:@"flightDate"];
    [flightDict setObject:flightObj.flightNumber forKey:@"flightNumber"];
    [flightDict setObject:flightObj.flightReport forKey:@"flightReport"];
    [flightDict setObject:flightObj.isManualyEntered forKey:@"isManualyEntered"];
    [flightDict setObject:flightObj.material forKey:@"material"];
    if(flightObj.materialType!=nil)
        [flightDict setObject:flightObj.materialType forKey:@"materialType"];
    [flightDict setObject:flightObj.sortTime forKey:@"sortTime"];
    [flightDict setObject:flightObj.suffix forKey:@"suffix"];
    [flightDict setObject:flightObj.tailNumber forKey:@"tailNumber"];
    if (flightObj.type!=nil)
        [flightDict setObject:flightObj.type forKey:@"type"];
    if(flightObj.company!=nil)
        [flightDict setObject:flightObj.company forKey:@"company"];
    NSMutableArray *legArray = [[NSMutableArray alloc] init];
    for (Legs *leg in [flightObj.flightInfoLegs array]) {
        NSMutableDictionary *legDict = [[NSMutableDictionary alloc] init];
        [legDict setObject:leg.destination forKey:@"destination"];
        [legDict setObject:leg.origin forKey:@"origin"];
        [legDict setObject:leg.legArrivalLocal forKey:@"legArrivalLocal"];
        [legDict setObject:leg.legDepartureLocal forKey:@"legDepartureLocal"];
        [legArray addObject:legDict];
    }
    
    [flightDict setObject:legArray forKey:@"legs"];
    
    return flightDict;
}


- (NSString*)validateIfEmpty:(NSString*)value{
    
    if ([value length] > 0 && value != nil ) {
        return value;
    }else
        return @"";
}

+(BOOL)addModifyDeleteManualFlight:(NSMutableDictionary*)newflight forFlight:(NSMutableDictionary*)oldFlight forMode:(enum flightAddMode)mode{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if ([results count]>0) {
        currentUser = [results objectAtIndex:0];
    }
    LTDeleteOlderFlight *del = [[LTDeleteOlderFlight alloc] init];
    if (mode==Add) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [newflight objectForKey:@"flightDate"],[newflight objectForKey:@"suffix"],[newflight objectForKey:@"flightNumber"],[newflight objectForKey:@"airlineCode"]];
        results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count]>0) {
            return NO;
        }else{
            FlightRoaster *flight = [self getFlightObjectFromDict:newflight forManageObjectContext:managedObjectContext];
            flight.lastSynchTime = [[NSDate date] toLocalTime];
            [currentUser addFlightRostersObject:flight];
        }
    }else if(mode==Modify){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [[oldFlight objectForKey:@"flightKey"] objectForKey:@"flightDate"],[[oldFlight objectForKey:@"flightKey"] objectForKey:@"suffix"],[[oldFlight objectForKey:@"flightKey"] objectForKey:@"flightNumber"],[[oldFlight objectForKey:@"flightKey"] objectForKey:@"airlineCode"]];
        results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        FlightRoaster *oldObj = [results objectAtIndex:0];
        if ([self checkKeysSameBetween:newflight and:oldFlight]) {//check if both flights are same
            //update existing flightobj
            oldObj.material = [newflight objectForKey:@"materialType"];
            oldObj.tailNumber = [newflight objectForKey:@"matricularText"];
            
            NSMutableArray *legArr = [newflight objectForKey:@"legs"];
            oldObj.sortTime=[[legArr objectAtIndex:0] objectForKey:@"legDepartureLocal"];
            oldObj.lastSynchTime = [[NSDate date] toLocalTime];
            
            for (Legs *leg in [oldObj.flightInfoLegs array]) {
                ;
                predicate = [NSPredicate predicateWithFormat:@"origin==%@ AND destination==%@",leg.origin,leg.destination];
                
                NSArray *results = [legArr filteredArrayUsingPredicate:predicate];
                if ([results count]==0) {
                    //deleting leg if it does not exist
                    [del deleteLegFromFlight:leg];
                    [oldObj removeFlightInfoLegsObject:leg];
                    [oldObj.managedObjectContext deleteObject:leg];
                } else if ([results count]>0){//if leg found
                    //update leg timimngs
                    NSMutableDictionary *legDict = [results objectAtIndex:0];
                    leg.legArrivalLocal = [legDict objectForKey:@"legArrivalLocal"];
                    leg.legDepartureLocal = [legDict objectForKey:@"legDepartureLocal"];
                    
                    [legArr removeObject:[results objectAtIndex:0]];
                }
            }
            
            if ([legArr count]>0) {//checking if any legs exist in new flight
                //if exist add new leg to old object
                for (NSMutableDictionary *legDict in legArr) {
                    Legs *leg = [NSEntityDescription insertNewObjectForEntityForName:@"Legs" inManagedObjectContext:managedObjectContext];
                    leg.destination = [legDict objectForKey:@"destination"];
                    leg.origin = [legDict objectForKey:@"origin"];
                    leg.legArrivalLocal = [legDict objectForKey:@"legArrivalLocal"];
                    leg.legDepartureLocal = [legDict objectForKey:@"legDepartureLocal"];
                    
                    [oldObj addFlightInfoLegsObject:leg];
                }
            }
        } else {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [newflight objectForKey:@"flightDate"],[newflight objectForKey:@"suffix"],[newflight objectForKey:@"flightNumber"],[newflight objectForKey:@"airlineCode"]];
            results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
            if ([results count] > 0) {
                return NO;
            }else{
                [del deleteFromLegForFlight:oldObj];
                [currentUser removeFlightRostersObject:oldObj];
                [currentUser.managedObjectContext deleteObject:oldObj];
                FlightRoaster *flight = [self getFlightObjectFromDict:newflight forManageObjectContext:managedObjectContext];
                flight.lastSynchTime = [[NSDate date] toLocalTime];
                [currentUser addFlightRostersObject:flight];
            }
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"Highlight.plist"];
            
            NSMutableDictionary *highlightingDict = [NSMutableDictionary dictionaryWithContentsOfFile:appFile];
            
            NSString *fdate = [[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightDate"] dateFormat:DATE_FORMAT_yyyy_MM_dd_HH_mm_ss];
            NSString *flightKey = [[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"] stringByAppendingString:[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]] stringByAppendingString:fdate];
            
            if(flightKey!=nil)
                [highlightingDict removeObjectForKey:flightKey];
            [highlightingDict writeToFile:appFile atomically:YES];
            
        }
    } else if (mode == Delete) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND flightNumber == %@ AND airlineCode == %@", [newflight objectForKey:@"flightDate"],[newflight objectForKey:@"flightNumber"],[newflight objectForKey:@"airlineCode"]];
        results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count] > 0) {
            FlightRoaster *flightObj = [results objectAtIndex:0];
            [del deleteFromLegForFlight:flightObj];
            [currentUser removeFlightRostersObject:flightObj];
            [currentUser.managedObjectContext deleteObject:flightObj];
        }
    }
    
    if (![managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        return YES;
    } else {
        return NO;
    }
}

+(BOOL)checkFlightExist:(NSMutableDictionary*)newflight{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if ([results count]>0) {
        currentUser = [results objectAtIndex:0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND flightNumber == %@ AND airlineCode == %@", [newflight objectForKey:@"flightDate"],[newflight objectForKey:@"flightNumber"],[newflight objectForKey:@"airlineCode"]];
        results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count]>0) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

+(NSMutableArray*)getAllManualflights {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if ([results count]>0) {
        currentUser = [results objectAtIndex:0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isManualyEntered == %d",manuFlightAdded];
        NSArray *arr = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        for (int j=0; j<[arr count]; j++) {
            FlightRoaster *flight = [arr objectAtIndex:j];
            NSMutableDictionary *flightDict = [self getFlightDictFromRoaster:flight];
            [array addObject:flightDict];
        }
    }
    return array;
}

+(void)updateFlightLink:(NSDictionary *)flightRoasterDict withStatus:(BOOL)flag {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSDate *fDate = [flightRoasterDict objectForKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[flightRoasterDict objectForKey:@"suffix"],[flightRoasterDict objectForKey:@"flightNumber"],[flightRoasterDict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
        if (flag) {
            flight.isManualyEntered= [NSNumber numberWithInt:manuFlightSynched];
            Uris *uri = [NSEntityDescription insertNewObjectForEntityForName:@"Uris" inManagedObjectContext:managedObjectContext];
            uri.gad = [[flightRoasterDict objectForKey:@"links"] objectForKey:@"uriGAD"];
            uri.createFlight = [[flightRoasterDict objectForKey:@"links"] objectForKey:@"uriFlightReport"];
            uri.cus = [[flightRoasterDict objectForKey:@"links"] objectForKey:@"uriCUS"];
            flight.flightUri = uri;
        } else {
            flight.isManualyEntered= [NSNumber numberWithInt:manuFlightErrored];
        }
    }
    
    if(![managedObjectContext save:&error]) {
        NSLog(@"Failed to save flightroster");
    }
}

//updating flight status based on counter inf counter is more than 3 we make it as success.
+(void)updateFlightStatus:(NSDictionary*)reponseDict withCounter:(int)count{
   
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
    }
    
    //update the roaster as WF==EA and wait for next synch
    NSMutableArray *arr = [[reponseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"];
    for (NSDictionary *dict in arr) {
        NSArray *statusArr = [dict objectForKey:@"status"];
        for (NSDictionary *statusDict in statusArr) {
            if ([[statusDict objectForKey:@"reportName"] isEqualToString:@"IV"]) {
                
                NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
                [dateFormat3 setDateFormat:DATEFORMAT];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND flightNumber == %@ AND airlineCode == %@", [dateFormat3 dateFromString:[dict valueForKey:@"flightDate"]],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"flightOperator"]];
                [request setPredicate:predicate];
                results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
                if ([results count] > 0) {
                    FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
                    if ([[statusDict objectForKey:@"status"] isEqualToString:@"OK"]) {
                        flight.status = [NSNumber numberWithInt:received];
                        
                    } else if (([[statusDict objectForKey:@"status"] isEqualToString:@"WF"] || [[statusDict objectForKey:@"status"] isEqualToString:@"EA"]) && count == 1) {
                        flight.status = [NSNumber numberWithInt:wf];
                        int c = [flight.counter intValue];
                        if (c == 3) {
                            flight.status = [NSNumber numberWithInt:received];
                        } else{
                            c++;
                            flight.counter = [NSNumber numberWithInt:c];
                        }
                        
                    }
                    else if ([[statusDict objectForKey:@"status"] isEqualToString:@"NOT_SENT"] || [[statusDict objectForKey:@"status"] isEqualToString:@"ER"]) {
                        if (count < 2) {
                            flight.status=[NSNumber numberWithInt:inqueue];
                        } else {
                            flight.status=[NSNumber numberWithInt:eror];
                        }
                    }
                }
            }
        }
    }
    
    if(![managedObjectContext save:&error]) {
        NSLog(@"Failed to save flightroster");
    }
}

+(NSDictionary*)getStatusForFlight:(FlightRoaster*)flight {
    
    NSMutableDictionary *statusDict = [[NSMutableDictionary alloc] init];
    
    if(flight.status)
        [statusDict setObject:flight.status forKey:@"flightStatus"];
    if(flight.airlineCode)
        [statusDict setObject:flight.airlineCode forKey:@"airlineCode"];
    if(flight.flightNumber)
        [statusDict setObject:flight.flightNumber forKey:@"flightNumber"];
    if(flight.flightDate)
        [statusDict setObject:flight.flightDate forKey:@"flightDate"];
    if (flight.lastSynchTime==nil) {
        [statusDict setObject:[[NSDate date] toLocalTime] forKey:@"synchTime"];
    } else {
        [statusDict setObject:flight.lastSynchTime forKey:@"synchTime"];
    }
    
    NSMutableArray *GADarray = [[NSMutableArray alloc] init];
    NSMutableArray *Custarray = [[NSMutableArray alloc] init];
    for (int j = 0; j < [[flight.flightInfoLegs array] count]; j++) {
        Legs *leg = (Legs*)[[flight.flightInfoLegs array] objectAtIndex:j];
        for (int k=0; k<[[leg.legsCrewmember array] count]; k++) {
            CrewMembers *crew = [[leg.legsCrewmember array] objectAtIndex:k];
            
            if([crew.status integerValue] > 0) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bp == %@",crew.bp];
                NSArray *result = [GADarray filteredArrayUsingPredicate:predicate];
                if ([result count] > 0) {
                    continue;
                }
                
                NSMutableDictionary *CrewDict = [[NSMutableDictionary alloc] init];
                if(crew.firstName != nil)
                    [CrewDict setObject:crew.firstName forKey:@"firstName"];
                if(crew.lastName != nil)
                    [CrewDict setObject:crew.lastName forKey:@"lastName"];
                if(crew.status != nil)
                    [CrewDict setObject:crew.status forKey:@"status"];
                if(crew.synchDate != nil)
                    [CrewDict setObject:crew.synchDate forKey:@"synchDate"];
                if(crew.bp != nil)
                    [CrewDict setObject:crew.bp forKey:@"bp"];
                [CrewDict setObject:leg.origin forKey:@"legOrigin"];
                [CrewDict setObject:leg.destination forKey:@"legDestination"];
                [CrewDict setObject:leg.legArrivalLocal forKey:@"legArrivalLocal"];
                [CrewDict setObject:leg.legDepartureLocal forKey:@"legDepartureLocal"];
                [CrewDict setObject:[NSNumber numberWithInt:j] forKey:@"legNumber"];
                if(crew.specialRank!=nil)
                    [CrewDict setObject:crew.specialRank forKey:@"specialRank"];
                if(crew.activeRank!=nil)
                    [CrewDict setObject:crew.activeRank forKey:@"activeRank"];
                
                if ([[CrewDict allKeys] count] > 0) {
                    [GADarray addObject:CrewDict];
                }
            } else {
                continue;
            }
        }
        [statusDict setObject:GADarray forKey:@"GAD"];
    }
    
    for(Legs *leg in flight.flightInfoLegs) {
        if(leg != nil) {
            NSArray *legCustomerArray = [[leg.legCustomer array] copy];
            for (int k = 0; k < legCustomerArray.count; k++) {
                Customer *cust = [legCustomerArray objectAtIndex:k];
                if(cust.isDeleted || !cust.managedObjectContext) {
                    NSLog(@"this customer has been deleted from the DB");
                    continue;
                }
                if([[cust.cusCusReport array] count] > 0) {
                    for (CusReport *report in cust.cusCusReport) {
                        
                        NSMutableDictionary *custDict = [[NSMutableDictionary alloc] init];
                        if(cust.firstName != nil)
                            [custDict setObject:cust.firstName forKey:@"firstName"];
                        if(cust.lastName != nil)
                            [custDict setObject:cust.lastName forKey:@"lastName"];
                        if(report.status != nil)
                            [custDict setObject:report.status forKey:@"status"];
                        if(report.synchDate != nil)
                            [custDict setObject:report.synchDate forKey:@"synchDate"];
                        if(cust.customerId != nil)
                            [custDict setObject:cust.customerId forKey:@"customerId"];
                        if(report.reportId != nil)
                            [custDict setObject:report.reportId forKey:@"reportId"];
                        Legs *leg = cust.cusLeg;
                        [custDict setObject:leg.origin forKey:@"legOrigin"];
                        [custDict setObject:leg.destination forKey:@"legDestination"];
                        if(cust.docNumber!=nil)
                            [custDict setObject:cust.docNumber forKey:@"docNumber"];
                        
                        if ([[custDict allKeys] count] > 0) {
                            [Custarray addObject:custDict];
                        }
                    }
                } else {
                    continue;
                }
            }
        }
    }
    
    [statusDict setObject:Custarray forKey:@"CUS"];
    
    if (([Custarray count] == 0) && ([GADarray count] == 0) && ([flight.status integerValue] == 0)) {
        return nil;
    }
    
    return statusDict;
}

+(NSMutableArray*)getStatusForAllFlights {
    NSMutableArray *allStatus = [[NSMutableArray alloc] init];
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
        if ([[currentUser.flightRosters array] count]>0) {
            for (int i = 0; i < [[currentUser.flightRosters array] count]; i++) {
                
                FlightRoaster *flight = (FlightRoaster *)[[currentUser.flightRosters array] objectAtIndex:i];
                
                NSDictionary *statusDict = [self getStatusForFlight:flight];
                if(statusDict) {
                    [allStatus addObject:statusDict];
                }
            }
        }
    }
    
    return allStatus;
}


+(void)saveBookingInfo:(NSDictionary*)responseDict forFlight:(NSDictionary*)flightDict {
    if ([[[[responseDict objectForKey:@"getBookingInformation"] objectForKey:@"response"] objectForKey:@"flightActivities"] count] > 0) {
        NSDictionary * responseFlightDict = [[[[responseDict objectForKey:@"getBookingInformation"] objectForKey:@"response"] objectForKey:@"flightActivities"] objectAtIndex:0];
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
        
        [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        //Deal with success
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
        NSError *error;
        NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
        User *currentUser;
        if([results count]>0) {
            currentUser = [results objectAtIndex:0];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND flightNumber == %@ AND airlineCode == %@", [flightDict valueForKey:@"flightDate"],[flightDict checkNilValueForKey:@"flightNumber"],[flightDict checkNilValueForKey:@"airlineCode"]];
            [request setPredicate:predicate];
            results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
            if ([results count]>0) {
                FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
                //                @TODO - this works fine but if uncommented, some manual flights will crash on flight report
                //                if(![[responseFlightDict objectForKey:@"businessUnit"] isEqual:[NSNull null]]) {
                //                    flight.businessUnit = [responseFlightDict objectForKey:@"businessUnit"];
                //                }
                flight.lastSynchTime=[[NSDate date] toLocalTime];
                NSArray *legArr = [responseFlightDict objectForKey:@"legs"];
                for (int i=0; i<[legArr count]; i++) {
                    NSDictionary *legsDict = [legArr objectAtIndex:i];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"origin = %@ AND destination = %@", [legsDict checkNilValueForKey:@"origin"],[legsDict checkNilValueForKey:@"destination"]];
                    NSArray *arrarLegs = [[flight.flightInfoLegs array] filteredArrayUsingPredicate:predicate];
                    
                    if(i == 0) {
                        flight.gateNumber = legsDict[@"gateNumber"];
                    }
                    
                    if ([arrarLegs count]>0) {
                        Legs *legs = (Legs*)[arrarLegs objectAtIndex:0];
                        NSArray *cabinArray = [legsDict objectForKey:@"cabinsOccupancies"];
                        if ([cabinArray isKindOfClass:[NSArray class]]) {
                            for (NSDictionary *cabinDict in cabinArray) {
                                ClassType *ctype = [NSEntityDescription insertNewObjectForEntityForName:@"ClassType" inManagedObjectContext:managedObjectContext];
                                if ([cabinDict objectForKey:@"type"] != [NSNull null]) {
                                    ctype.name = [cabinDict objectForKey:@"type"];
                                    ctype.availablepassenger = [[cabinDict objectForKey:@"booking"] objectForKey:@"booked"];
                                    ctype.capacity = [[cabinDict objectForKey:@"booking"] objectForKey:@"authorized"];
                                    [legs addLegClassObject:ctype];
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        if(![managedObjectContext save:&error]) {
            NSLog(@"Failed to save flightroster");
        }
    }
}

+(Customer*)getCustomerForFlight:(NSDictionary*)flightDict andCusyomerDict:(NSDictionary*)cusDict forMoc:(NSManagedObjectContext*)localMoc{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [localMoc executeFetchRequest:request error:&error];
    User *currentUser;
    if ([results count]>0) {
        currentUser = [results objectAtIndex:0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"airlineCode == %@ AND flightDate==%@ AND flightNumber==%@",[flightDict objectForKey:@"airlineCode"],[flightDict objectForKey:@"flightDate"],[flightDict objectForKey:@"flightNumber"]];
        NSArray *result = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([result count]>0) {
            FlightRoaster *flight = [result firstObject];
            predicate = [NSPredicate predicateWithFormat:@"origin == %@ AND destination == %@",[cusDict objectForKey:@"legOrigin"],[cusDict objectForKey:@"legDestination"]];
            result = [[flight.flightInfoLegs array] filteredArrayUsingPredicate:predicate];
            if([result count]>0){
                Legs *leg = [result firstObject];
                predicate  = [NSPredicate predicateWithFormat:@"customerId == %@", [cusDict objectForKey:@"customerId"]];
                result = [[leg.legCustomer array] filteredArrayUsingPredicate:predicate];
                if ([result count]>0) {
                    Customer *cus = [result firstObject];
                    return cus;
                }
            }
        }
    }
    return nil;
}

+(void)getStatsForFlight:(NSDictionary*)flightDict {
    
    NSLog(@"flightDict: %@",flightDict);
    NSDictionary *dict = [flightDict objectForKey:@"flightKey"];
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
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [dict checkNilValueForKey:@"flightDate"],[dict checkNilValueForKey:@"suffix"],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count] > 0) {
            FlightRoaster *flight = [results objectAtIndex:0];
            
            NSMutableArray *legarr = [[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"legs"];
            NSOrderedSet *legs = flight.flightInfoLegs;
            for(Legs *leg in legs) {
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"origin==%@ AND destination==%@",leg.origin,leg.destination];
                Stats *stat = leg.legStats;
                if(stat) {
                    NSArray *result = [legarr filteredArrayUsingPredicate:pred];
                    if ([results count] > 0) {
                        NSMutableDictionary *legDict = [result firstObject];
                        
                        [legDict setObject:stat.wchc forKey:@"wchc"];
                        [legDict setObject:stat.wchr forKey:@"wchr"];
                        [legDict setObject:stat.wchs forKey:@"wchs"];
                        [legDict setObject:stat.numpj forKey:@"numpj"];
                        [legDict setObject:stat.numpy forKey:@"numpy"];
                        [legDict setObject:stat.umnr forKey:@"umnr"];
                        
                    }
                }
            }
        }
    }
}

@end
