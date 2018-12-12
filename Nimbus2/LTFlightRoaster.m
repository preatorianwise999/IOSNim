    
//
//  LTFlightRoaster.m
//  LATAM
//
//  Created by Palash on 07/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTFlightRoaster.h"
#import "FlightRoaster.h"
#import "Legs.h"
#import "CrewMembers.h"
#import "AppDelegate.h"
#import "User.h"
#import "LTAllDb.h"
#import "LTDeleteOlderFlight.h"
#import "NSMutableDictionary+ChekVal.h"
#import "FlightObject.h"
#import "NSDate+DateFormat.h"


@implementation LTFlightRoaster
//insert flightroaster if it is coming for first time
-(FlightRoaster*)getFlightRoaster:(NSDictionary *)flightDict withManagedObject:(NSManagedObjectContext*)managedObjectContext {
    //inserting if first time
    FlightRoaster *flight;
    if(nil != flightDict) {
        
        flight = [NSEntityDescription insertNewObjectForEntityForName:@"FlightRoaster" inManagedObjectContext:managedObjectContext];
        flight.airlineCode = [flightDict checkNilValueForKey:@"airlineCode"];
        
        flight.company= [flightDict checkNilValueForKey:@"company"];
        flight.flightNumber = [flightDict checkNilValueForKey:@"flightNumber"];
        
        flight.material = [flightDict checkNilValueForKey:@"material"];
        if([[flightDict checkNilValueForKey:@"materialType"] isEqualToString:@""])
        {
            flight.materialType = [self getMaterialType:flight.material BusinessUnit:flight.businessUnit AirlineCode:flight.airlineCode];
        }
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
        flight.flightReport=[NSString stringWithFormat:@"%@%@%d",flight.airlineCode,flight.flightNumber,number];
        
        NSDictionary *linksDict = [flightDict checkNilValueForKey:@"links"];
        Uris *uri = [NSEntityDescription insertNewObjectForEntityForName:@"Uris" inManagedObjectContext:managedObjectContext];
        uri.createFlight = [linksDict checkNilValueForKey:@"uriFlightReport"];
        uri.gad= [linksDict checkNilValueForKey:@"uriGAD"];
        uri.cus = [linksDict checkNilValueForKey:@"uriCUS"];
        flight.flightUri=uri;
        if ([[flightDict checkNilValueForKey:@"legs"] isKindOfClass:[NSArray class]]) {
            NSArray *legsArray = [flightDict checkNilValueForKey:@"legs"];
            for (int j=0; j<[legsArray count]; j++) {
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
                }
                NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
                [dateFormat2 setDateFormat:DATEFORMAT];
                legs.legArrivalLocal = [dateFormat2 dateFromString:[dict checkNilValueForKey:@"legArrivalLocal"]];
                NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
                [dateFormat3 setDateFormat:DATEFORMAT];
                legs.legDepartureUTC = [dateFormat3 dateFromString:[dict checkNilValueForKey:@"legDepartureUTC"]];
                legs.origin = [dict checkNilValueForKey:@"origin"];
                legs.businessUnit = [dict checkNilValueForKey:@"businessUnit"];
                if ([dict valueForKey:@"crewMembers"]!=nil) {
                    NSArray * crewMembersArray = [dict checkNilValueForKey:@"crewMembers"];
                    for (int k =0; k<[crewMembersArray count]; k++) {
                        NSDictionary *crewDict = [crewMembersArray objectAtIndex:k];
                        CrewMembers *crew  = [NSEntityDescription insertNewObjectForEntityForName:@"CrewMembers" inManagedObjectContext:managedObjectContext];
                        crew.activeRank = [crewDict checkNilValueForKey:@"activeRank"];
                        crew.bp = [crewDict checkNilValueForKey:@"bp"];
                        crew.firstName = [crewDict checkNilValueForKey:@"firstName"];
                        crew.lastName = [crewDict checkNilValueForKey:@"lastName"];
                        crew.specialRank = [crewDict checkNilValueForKey:@"specialRank"];
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bp = %@ && firstName==%@ && lastName==%@", [crewDict checkNilValueForKey:@"bp"],[crewDict checkNilValueForKey:@"firstName"],[crewDict checkNilValueForKey:@"lastName"]];
                        
                        NSArray *results = [[flight.flightCrew array] filteredArrayUsingPredicate:predicate];
                        if ([results count]==0) {
                            [flight addFlightCrewObject:crew];
                        }
                        [legs addLegsCrewmemberObject:crew];
                    }
                }
                
                [flight addFlightInfoLegsObject:legs];
            }
        }
        NSError *error ;
        
        if(![managedObjectContext save:&error]) {
            NSLog(@"Failed to save flightroster");
        }
    }
    return flight;  
}
//insert flight roaster details. Check if already existing then update the whole details
-(NSDictionary*)insertOrUpdateFlightRoster:(NSDictionary *)responseDict {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.errorDict = [[NSMutableDictionary alloc] init];
    
    ///Adding current user from username
    LTDeleteOlderFlight *deleteFlight = [[LTDeleteOlderFlight alloc] init];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@",[LTSingleton getSharedSingletonInstance].username];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if([results count]>0) {
        currentUser = [results objectAtIndex:0];
        if ([responseDict valueForKey:@"response"]!=nil) {
            if ([[responseDict valueForKey:@"response"] valueForKey:@"flightActivities"]!=nil) {
                [deleteFlight deleteFlightForType:byflight FlightsArray:[[responseDict checkNilValueForKey:@"response"] valueForKey:@"flightActivities"]];
            }
        }
        
        
    }else {
        [deleteFlight deleteFlightForType:byuser FlightsArray:nil];
        currentUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
        currentUser.firstName=@"FirstName";
        currentUser.lastName=@"LastName";
        currentUser.bp=@"123456";
        currentUser.username=[LTSingleton getSharedSingletonInstance].username;
        [LTSingleton getSharedSingletonInstance].user = [NSString stringWithFormat:@"%@ %@",currentUser.firstName,currentUser.lastName];
        [TempLocalStorageModel saveInUserDefaults:[LTSingleton getSharedSingletonInstance].user withKey:@"user"];
        
    }

    
    
    ////end current user
    
 
    @try {
        if ([responseDict objectForKey:@"response"]!=nil) {
            
            //use existing current user
            
            currentUser.firstName = [[responseDict checkNilValueForKey:@"response"] checkNilValueForKey:@"firstName"];
            currentUser.lastName = [[responseDict checkNilValueForKey:@"response"] checkNilValueForKey:@"lastName"];
            currentUser.bp = [[responseDict checkNilValueForKey:@"response"] checkNilValueForKey:@"bp"];
            currentUser.crewBase = [[responseDict checkNilValueForKey:@"response"] checkNilValueForKey:@"crewBase"];
            
            [LTSingleton getSharedSingletonInstance].user = [NSString stringWithFormat:@"%@ %@",currentUser.firstName,currentUser.lastName];
            [TempLocalStorageModel saveInUserDefaults:[LTSingleton getSharedSingletonInstance].user withKey:@"user"];
            
            if(![managedObjectContext save:&error]) {
                NSLog(@"Failed to save");
            }
            if ([[[responseDict valueForKey:@"response"] objectForKey:@"flightActivities"] isKindOfClass:[NSArray class]]) {
                NSArray *array = [[responseDict objectForKey:@"response"] valueForKey:@"flightActivities"];
                for (int i=0; i<[array count]; i++) {
                    NSDictionary *dict = [array objectAtIndex:i];
                    
                    
                    if([dict objectForKey:@"serviceStatus"]!=nil){
                        //dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *dict2 = [[dict objectForKey:@"serviceStatus"] objectAtIndex:0];
                        if (![[dict2 objectForKey:@"code"] integerValue]==3) {//check if not business unit
                            NSString *pt = [[dict2 objectForKey:@"mapLanguages"] objectForKey:@"pt"];
                            NSString *es = [[dict2 objectForKey:@"mapLanguages"] objectForKey:@"es"];
                            if (appdelegate.currentLanguage==LANG_SPANISH) {
                                [self.errorDict setValue:es forKey:[NSString stringWithFormat:@"%@%@",[dict checkNilValueForKey:@"airlineCode"],[dict checkNilValueForKey:@"flightNumber"]]];
                            }else if (appdelegate.currentLanguage==LANG_PORTUGUESE){
                                [self.errorDict setValue:pt forKey:[NSString stringWithFormat:@"%@%@",[dict checkNilValueForKey:@"airlineCode"],[dict checkNilValueForKey:@"flightNumber"]]];
                            }else{
                                // [AlertUtils showErrorAlertWithTitle:@"Error!" message:@"No new flights found. Showing previously synched flights."];
                            }
                            
                        }
                        
                    }
                    
                    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
                    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
                    [dateFormat3 setDateFormat:DATEFORMAT];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [dateFormat3 dateFromString:[dict checkNilValueForKey:@"flightDate"]],[dict checkNilValueForKey:@"suffix"],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"airlineCode"]];
                    [request setPredicate:predicate];
                    NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
                    if([results count]>0) {
                        FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
                        {
                            if ([flight.status intValue]<1) {
                                flight.company= [dict checkNilValueForKey:@"company"];
                                flight.airlineCode = [dict checkNilValueForKey:@"airlineCode"];
                                flight.flightNumber = [dict checkNilValueForKey:@"flightNumber"];
                                flight.material=[dict checkNilValueForKey:@"material"];
                                Uris *uri = flight.flightUri;
                                NSDictionary *linksDict = [dict checkNilValueForKey:@"links"];
                                
                                uri.createFlight = [linksDict checkNilValueForKey:@"uriFlightReport"];
                                uri.gad= [linksDict checkNilValueForKey:@"uriGAD"];
                                uri.cus = [linksDict checkNilValueForKey:@"uriCUS"];

                                if([[dict checkNilValueForKey:@"materialType"] isEqualToString:@""])
                                {
                                    flight.materialType = [self getMaterialType:flight.material BusinessUnit:flight.businessUnit AirlineCode:flight.airlineCode];
                                }
                                else
                                    flight.materialType = [dict checkNilValueForKey:@"materialType"];
                                
                                flight.suffix = [dict checkNilValueForKey:@"suffix"];
                                flight.tailNumber = [dict checkNilValueForKey:@"tailNumber"];
                                int number = arc4random_uniform(900000) + 100000;
                                flight.flightReport=[NSString stringWithFormat:@"%@%d",flight.airlineCode,number];
                                if (flight.businessUnit==nil) {
                                    flight.businessUnit = [dict checkNilValueForKey:@"businessUnit"];
                                }
                                
                                flight.type=[self getFlightTypeFromMeterial:flight.material BusinessUnit:flight.businessUnit AirlineCode:flight.airlineCode];
                            }
                            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                            [dateFormat setDateFormat:DATEFORMAT];
                            flight.flightDate = [dateFormat dateFromString:[dict checkNilValueForKey:@"flightDate"]];
                            NSDictionary *linksDict = [dict checkNilValueForKey:@"links"];
                            
                            if ([[dict checkNilValueForKey:@"legs"] isKindOfClass:[NSArray class]]) {
                                NSArray *legsArray = [dict checkNilValueForKey:@"legs"];
                                
                                for (int j=0; j<[legsArray count]; j++) {
                                    NSDictionary *legsDict = [legsArray objectAtIndex:j];
                                    NSArray *array = [flight.flightInfoLegs array];
                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"origin = %@ AND destination = %@", [legsDict checkNilValueForKey:@"origin"],[legsDict checkNilValueForKey:@"destination"]];
                                    NSArray *arrarLegs = [array filteredArrayUsingPredicate:predicate];
                                    
                                    Legs *legs;
                                    BOOL isExistsLeg = NO;
                                    if([arrarLegs count]>0) {
                                        isExistsLeg = YES;
                                        legs = [arrarLegs objectAtIndex:0];
                                    }else {
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
                                    }
                                    
                                    
                                    
                                    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
                                    [dateFormat2 setDateFormat:DATEFORMAT];
                                    legs.legArrivalLocal = [dateFormat2 dateFromString:[legsDict checkNilValueForKey:@"legArrivalLocal"]];
                                    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
                                    [dateFormat3 setDateFormat:DATEFORMAT];
                                    legs.legDepartureUTC = [dateFormat3 dateFromString:[legsDict checkNilValueForKey:@"legDepartureUTC"]];
                                    if ([[legsDict checkNilValueForKey:@"crewMembers"] isKindOfClass:[NSArray class]]) {
                                        NSArray * crewMembersArray = [legsDict checkNilValueForKey:@"crewMembers"];
                                        for (int k =0; k<[crewMembersArray count]; k++) {
                                            NSDictionary *crewDict = [crewMembersArray objectAtIndex:k];
                                            NSArray *array = [legs.legsCrewmember array];
                                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bp = %lld && firstName==%@ && lastName==%@", [[crewDict checkNilValueForKey:@"bp"] longLongValue],[crewDict checkNilValueForKey:@"firstName"],[crewDict checkNilValueForKey:@"lastName"]];
                                            NSArray *arrayCrew = [array filteredArrayUsingPredicate:predicate];
                                            NSArray *FlightCrew = [[flight.flightCrew array] filteredArrayUsingPredicate:predicate];
                                            
                                            CrewMembers *crew;
                                            BOOL isExistsCrew = NO;
                                            if([arrayCrew count]>0 || [FlightCrew count]>0) {
                                                isExistsCrew = YES;
                                                crew  = [arrayCrew objectAtIndex:0];
                                                
                                            }else {
                                                crew  = [NSEntityDescription insertNewObjectForEntityForName:@"CrewMembers" inManagedObjectContext:managedObjectContext];
                                            }
                                            crew.activeRank = [crewDict checkNilValueForKey:@"activeRank"];
                                            crew.bp = [crewDict checkNilValueForKey:@"bp"];
                                            crew.firstName = [crewDict checkNilValueForKey:@"firstName"];
                                            crew.lastName = [crewDict checkNilValueForKey:@"lastName"];
                                            crew.specialRank = [crewDict checkNilValueForKey:@"specialRank"];
                                            results = [[flight.flightCrew array] filteredArrayUsingPredicate:predicate];
                                            if ([results count]==0) {
                                                [flight addFlightCrewObject:crew];
                                            }
                                            NSError *error;
                                            if(!isExistsCrew)
                                                [legs addLegsCrewmemberObject:crew];
                                            if(![managedObjectContext save:&error]) {
                                                NSLog(@"Failed to save crew");
                                            }
                                        }
                                    }
                                    
                                    
                                    if(!isExistsLeg)
                                        [flight addFlightInfoLegsObject:legs];
                                    
                                }
  
                            }
                            
                                                        NSError *error ;
                            if(![managedObjectContext save:&error]) {
                                NSLog(@"Failed to save ");
                            }
                        }
                        
                    }else
                    {
                        FlightRoaster *flight =  [self getFlightRoaster:dict withManagedObject:managedObjectContext];
                        [currentUser addFlightRostersObject:flight];
                        if(![managedObjectContext save:&error]) {
                            NSLog(@"Failed to save new FlightRoaster");
                        }
                    }
                }
            }
        
            [deleteFlight deleteFlightForType:bydate FlightsArray:nil];
            return self.errorDict;
        }
       else  if([responseDict objectForKey:@"serviceStatus"]!=nil){
            if ([LTSingleton getSharedSingletonInstance].isUserChanged) {
                LTDeleteOlderFlight *deleteFlight = [[LTDeleteOlderFlight alloc] init];
                [deleteFlight deleteFlightForType:byuser FlightsArray:nil];
            }
                NSDictionary *dict = [[responseDict objectForKey:@"serviceStatus"] objectAtIndex:0];
                NSString *pt = [[dict objectForKey:@"mapLanguages"] objectForKey:@"pt"];
                NSString *es = [[dict objectForKey:@"mapLanguages"] objectForKey:@"es"];
                if (appdelegate.currentLanguage==LANG_SPANISH) {
                    [self.errorDict setValue:es forKey:@"Error!"];
                }else if (appdelegate.currentLanguage==LANG_PORTUGUESE){
                    [self.errorDict setValue:pt forKey:@"Error!"];
                }else{
                    [AlertUtils showErrorAlertWithTitle:[appdelegate copyTextForKey:@"STATUS_ERROR"] message:@"No new flights found. Showing previously synched flights."];
                }
            if(![managedObjectContext save:&error]) {
                NSLog(@"Failed to save new FlightRoaster");
            }
            return self.errorDict;
           // });
        }
    }
    @catch (NSException *exception) {
        DLog(@"no data found");
    }
    return self.errorDict;
}

//getting material type based on the internal rules.

-(NSString *)getMaterialType:(NSString*)material BusinessUnit:(NSString*)businessUnit AirlineCode:(NSString*)airlineCode{
    NSString *type=@"";
    
    if ([material containsString:@"A318"] || [material containsString:@"A319"] || [material containsString:@"A320"] || [material containsString:@"A321"] || [material containsString:@"B737"] || [material containsString:@"DHC-8"]) {
        type=@"NB";
    }else if ([material containsString:@"A330"] || [material containsString:@"A340"] || [material containsString:@"A350"] || [material containsString:@"B767"] || [material containsString:@"B787"] || [material containsString:@"B777"]){
        type=@"WB";
    }
    
    return type;
}

//getting the type of the flight based on internal rules.
-(NSString *)getFlightTypeFromMeterial:(NSString*)material BusinessUnit:(NSString*)businessUnit AirlineCode:(NSString*)airlineCode{
    NSString *type;
    if ([businessUnit containsString:@"INT"] || [businessUnit containsString:@"REG"]) {
        //Check If it is NB or WB
        if ([material containsString:@"A318"] || [material containsString:@"A319"] || [material containsString:@"A320"] || [material containsString:@"A321"] || [material containsString:@"B737"] || [material containsString:@"DHC-8"]) {
            type=@"NB";
        }else if ([material containsString:@"A330"] || [material containsString:@"A340"] || [material containsString:@"A350"] || [material containsString:@"B767"] || [material containsString:@"B787"] || [material containsString:@"B777"]){
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

//updating the flight type
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
        flight.businessUnit = [flightRoasterDict objectForKey:@"businessUnit"];
    }
    
    if(![managedObjectContext save:&error]) {
        NSLog(@"Failed to save flightroster");
    }
    
}
//update the flight details with status and uri for image
-(void)updateFlightStatus: (NSDictionary*)flightDict status:(enum status)status withUri:(NSString*)imgUri{
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
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BackViewRefresh" object:nil];

    }
   
}


//updating flight status based on counter inf counter is more than 3 we make it as success.
-(void)updateFlightStatus:(NSDictionary*)reponseDict withCounter:(int)count{
    
    //update the roaster as WF==EA and wait for next synch
    NSMutableArray *arr = [[reponseDict objectForKey:@"response"] objectForKey:@"flights"];
    for (NSDictionary *dict in arr) {
        NSArray *statusArr = [dict objectForKey:@"status"];
        for (NSDictionary *statusDict in statusArr) {
            if ([[statusDict objectForKey:@"reportName"] isEqualToString:@"IV"]) {
                
                ////
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
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND flightNumber == %@ AND airlineCode == %@", [dateFormat3 dateFromString:[dict valueForKey:@"flightDate"]],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"flightOperator"]];
                [request setPredicate:predicate];
                results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
                if ([results count]>0) {
                    FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
                    if ([[statusDict objectForKey:@"status"] isEqualToString:@"OK"]) {
                        flight.status = [NSNumber numberWithInt:received];
                        
                    }else if (([[statusDict objectForKey:@"status"] isEqualToString:@"WF"] || [[statusDict objectForKey:@"status"] isEqualToString:@"EA"]) && count==1){
                        flight.status = [NSNumber numberWithInt:wf];
                        int c = [flight.counter intValue];
                        if (c==3) {
                            flight.status = [NSNumber numberWithInt:received];
                        }else{
                            c++;
                            flight.counter = [NSNumber numberWithInt:c];
                        }
                        
                    }
                    else if ([[statusDict objectForKey:@"status"] isEqualToString:@"NOT_SENT"] || [[statusDict objectForKey:@"status"] isEqualToString:@"ER"]){
                        if (count<2) {
                            flight.status=[NSNumber numberWithInt:inqueue];
                        }else{
                            flight.status=[NSNumber numberWithInt:eror];
                        }
                        
                    }
                }
                
                if(![managedObjectContext save:&error]) {
                    
                    NSLog(@"Failed to save flightroster");
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackViewRefresh" object:nil];
                }
            }
            
        }
        
    }
}
//adding manually added flight
-(BOOL)addManualFlight:(FlightRoaster*)flight{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [appdelegate.managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if([results count]>0) {
        currentUser = [results objectAtIndex:0];
    }
    
    
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:DATEFORMAT];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", flight.flightDate,flight.suffix,flight.flightNumber,flight.airlineCode];
    [request setPredicate:predicate];
    results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
    if ([results count]==0) {
        [currentUser addFlightRostersObject:flight];
        
    }else{
        FlightRoaster *flightObj = (FlightRoaster*)[results objectAtIndex:0];
        if ([flightObj.isManualyEntered intValue]!=notManualFlight && flightObj.isManualyEntered!=flight.isManualyEntered) {
                flightObj.isManualyEntered=flight.isManualyEntered;
            }
    }
    if([appdelegate.managedObjectContext save:&error]) {
        return YES;
    }else{
        return NO;
    }
}
//updating content of an existing flight with new flight's content
-(BOOL)updateFlight:(FlightRoaster*)oldFlight withNewFlight:(FlightRoaster*)newFlight{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    LTDeleteOlderFlight *Dflight = [[LTDeleteOlderFlight alloc] init];
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [appdelegate.managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if([results count]>0) {
        currentUser = [results objectAtIndex:0];
    }
    
    
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:DATEFORMAT];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", oldFlight.flightDate,oldFlight.suffix,oldFlight.flightNumber,oldFlight.airlineCode];
    [request setPredicate:predicate];
    results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
    if ([results count]==0) {
       // [currentUser addFlightRostersObject:flight];
        
    }else{
        
        FlightRoaster *flightObj = (FlightRoaster*)[results objectAtIndex:0];
        if ([flightObj.airlineCode isEqualToString:newFlight.airlineCode] && [flightObj.flightNumber isEqualToString:newFlight.flightNumber]&& flightObj.flightDate==newFlight.flightDate) {
            ///matches
            flightObj.material=newFlight.material;
            flightObj.tailNumber=newFlight.tailNumber;
            flightObj.company=newFlight.company;
            flightObj.materialType=newFlight.materialType;
            flightObj.suffix=@"_";
            flightObj.type = newFlight.type;
            flightObj.isManualyEntered=[NSNumber numberWithInt:manuFlightAdded];
            for (Legs *leg in flightObj.flightInfoLegs) {
                BOOL legExist=FALSE;
                for (Legs *leg2 in newFlight.flightInfoLegs) {
                    if ([leg.origin isEqualToString:leg2.origin] && [leg.destination isEqualToString:leg2.destination]) {
                        legExist=TRUE;
                        //check time
                        leg.legArrivalLocal=leg2.legArrivalLocal;
                        leg.legDepartureLocal=leg2.legDepartureLocal;
                        leg.legsCrewmember=leg2.legsCrewmember;
                    }
                }
                if (!legExist) {
                    [Dflight deleteLegFromFlight:leg];
                }
            }
            for (Legs *leg in newFlight.flightInfoLegs) {
                for (Legs *leg2 in flightObj.flightInfoLegs) {
                    if ([leg.origin isEqualToString:leg2.origin] && [leg.destination isEqualToString:leg2.destination]) {
                        //check time
                    }else{
                        [flightObj addFlightInfoLegsObject:leg];
                    }
                }
            }
            [Dflight deleteFromLegForFlight:newFlight];
            [currentUser removeFlightRostersObject:newFlight];
            [currentUser.managedObjectContext delete:newFlight];
            
        }else{
            //not maches
            if ([self addManualFlight:newFlight]) {
                
                [Dflight deleteFromLegForFlight:flightObj];
                [currentUser removeFlightRostersObject:flightObj];
                [currentUser.managedObjectContext delete:flightObj];
            }
            
            
        }
        
    }
    if([appdelegate.managedObjectContext save:&error]) {
        return YES;
    }else{
        return NO;
    }
}

//check if keeys of the flights are same or not
-(BOOL)checkKeysSameBetween:(NSMutableDictionary *)fligh1 and:(NSMutableDictionary *)flight2{
    BOOL check=TRUE;
    if (![((NSString*)[fligh1 objectForKey:@"airlineCode"]) isEqualToString:((NSString*)[flight2 objectForKey:@"airlineCode"])]) {
        check=FALSE;
        return check;
    }
    if(![((NSString*)[fligh1 objectForKey:@"flightNumber"]) isEqualToString:((NSString*)[flight2 objectForKey:@"flightNumber"])]){
        
        check=FALSE;
        return check;
        
    }
    NSDate *date1 = [fligh1 objectForKey:@"flightDate"];
    NSDate *date2 = [flight2 objectForKey:@"flightDate"];
    if ([date1 timeIntervalSinceDate:date2]!=0) {
        check=FALSE;
        return check;
    }
        return check;
}
//converting flight dictionary to flight object

-(FlightRoaster *)getFlightObjectFromDict:(NSMutableDictionary*)flightDict forManageObjectContext:(NSManagedObjectContext*)context{
    FlightRoaster *flightObj = [NSEntityDescription insertNewObjectForEntityForName:@"FlightRoaster" inManagedObjectContext:context];
    flightObj.airlineCode = [flightDict objectForKey:@"airlineCode"];
    flightObj.flightDate = [flightDict objectForKey:@"flightDate"];
    flightObj.flightNumber = [flightDict objectForKey:@"flightNumber"];
    flightObj.flightReport = [flightDict objectForKey:@"flightReport"];
    flightObj.isManualyEntered = [flightDict objectForKey:@"isManualyEntered"];
    flightObj.material = [flightDict objectForKey:@"material"];
    flightObj.materialType=[flightDict objectForKey:@"materialType"];
    flightObj.sortTime = [flightDict objectForKey:@"sortTime"];
    flightObj.suffix = [flightDict objectForKey:@"suffix"];
    flightObj.tailNumber = [flightDict objectForKey:@"tailNumber"];
    flightObj.company = [flightDict objectForKey:@"company"];
    flightObj.type = [flightDict objectForKey:@"type"];
    for (NSMutableDictionary *legDict in [flightDict objectForKey:@"legs"]) {
        Legs *leg = [NSEntityDescription insertNewObjectForEntityForName:@"Legs" inManagedObjectContext:context];
        leg.destination = [legDict objectForKey:@"Destination"];
        leg.origin = [legDict objectForKey:@"Origin"];
        leg.legArrivalLocal = [legDict objectForKey:@"legArrivalLocal"];
        leg.legDepartureLocal = [legDict objectForKey:@"legDepartureLocal"];
        for (NSMutableDictionary *crewDict in [legDict objectForKey:@"crew"]) {
            CrewMembers *crew = [NSEntityDescription insertNewObjectForEntityForName:@"CrewMembers" inManagedObjectContext:context];
            crew.activeRank = [crewDict objectForKey:@"activeRank"];
            crew.firstName = [crewDict objectForKey:@"firstName"];
            crew.lastName = [crewDict objectForKey:@"lastName"];
            crew.specialRank = [crewDict objectForKey:@"specialRank"];
            [leg addLegsCrewmemberObject:crew];
        }
        if ([flightDict objectForKey:@"links"]!=nil) {
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
//converting flight object to flight dictionary

-(NSMutableDictionary *)getFlightDictFromRoaster:(FlightRoaster*)flightObj{
    NSMutableDictionary *flightDict = [[NSMutableDictionary alloc] init];
    [flightDict setObject:flightObj.airlineCode forKey:@"airlineCode"];
    [flightDict setObject:flightObj.flightDate forKey:@"flightDate"];
    [flightDict setObject:flightObj.flightNumber forKey:@"flightNumber"];
    [flightDict setObject:flightObj.flightReport forKey:@"flightReport"];
    [flightDict setObject:flightObj.isManualyEntered forKey:@"isManualyEntered"];
    [flightDict setObject:flightObj.material forKey:@"material"];
    [flightDict setObject:flightObj.materialType forKey:@"materialType"];
    [flightDict setObject:flightObj.sortTime forKey:@"sortTime"];
    [flightDict setObject:flightObj.suffix forKey:@"suffix"];
    [flightDict setObject:flightObj.tailNumber forKey:@"tailNumber"];
    [flightDict setObject:flightObj.type forKey:@"type"];
    [flightDict setObject:flightObj.company forKey:@"company"];
    NSMutableArray *legArray = [[NSMutableArray alloc] init];
    for (Legs *leg in [flightObj.flightInfoLegs array]) {
        NSMutableDictionary *legDict = [[NSMutableDictionary alloc] init];
        [legDict setObject:leg.destination forKey:@"Destination"];
        [legDict setObject:leg.origin forKey:@"Origin"];
        [legDict setObject:leg.legArrivalLocal forKey:@"legArrivalLocal"];
        [legDict setObject:leg.legDepartureLocal forKey:@"legDepartureLocal"];
        NSMutableArray *crewarray = [[NSMutableArray alloc] init];
        for (CrewMembers *crew in [leg.legsCrewmember array]) {
            NSMutableDictionary *crewDict = [[NSMutableDictionary alloc] init];
            [crewDict setObject:crew.activeRank forKey:@"activeRank"];
            [crewDict setObject:crew.firstName forKey:@"firstName"];
            [crewDict setObject:crew.lastName forKey:@"lastName"];
            [crewDict setObject:crew.specialRank forKey:@"specialRank"];
            [crewarray addObject:crewDict];
        }
        [legDict setObject:crewarray forKey:@"crew"];
        [legArray addObject:legDict];
    }
    
    [flightDict setObject:legArray forKey:@"legs"];
    
    return flightDict;
}
//check if flight exists based on the keys of a flight
-(BOOL)checkFlightExist:(NSMutableDictionary*)newflight{
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [newflight objectForKey:@"flightDate"],[newflight objectForKey:@"suffix"],[newflight objectForKey:@"flightNumber"],[newflight objectForKey:@"airlineCode"]];
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
//add or modifying manually added flight
-(BOOL)addModifyDeleteManualFlight:(NSMutableDictionary*)newflight forFlight:(NSMutableDictionary*)oldFlight forMode:(enum flightAddMode)mode{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    User *currentUser;
    if (results>0) {
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
            [currentUser addFlightRostersObject:flight];
            
        }
    }else if(mode==Modify){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [oldFlight objectForKey:@"flightDate"],[oldFlight objectForKey:@"suffix"],[oldFlight objectForKey:@"flightNumber"],[oldFlight objectForKey:@"airlineCode"]];
        results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        FlightRoaster *oldObj = [results objectAtIndex:0];
        if ([self checkKeysSameBetween:newflight and:oldFlight]) {//check if both flights are same
            //update existing flightobj
            oldObj.flightReport = [newflight objectForKey:@"flightReport"];
            oldObj.isManualyEntered = [newflight objectForKey:@"isManualyEntered"];
            oldObj.material = [newflight objectForKey:@"material"];
            oldObj.materialType=[newflight objectForKey:@"materialType"];
            oldObj.sortTime = [newflight objectForKey:@"sortTime"];
            oldObj.suffix = [newflight objectForKey:@"suffix"];
            oldObj.tailNumber = [newflight objectForKey:@"tailNumber"];
            
            NSMutableArray *legArr = [newflight objectForKey:@"legs"];
            
            for (Legs *leg in [oldObj.flightInfoLegs array]) {
                predicate = [NSPredicate predicateWithFormat:@"Origin==%@ AND Destination==%@",leg.origin,leg.destination];
                
                NSArray *results = [legArr filteredArrayUsingPredicate:predicate];
                if ([results count]==0) {
                    //deleting leg if it does not exist
                    [del deleteLegFromFlight:leg];
                    [oldObj removeFlightInfoLegsObject:leg];
                    [oldObj.managedObjectContext deleteObject:leg];
                    if (![managedObjectContext save:&error]) {
                        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                    }
                }else if ([results count]>0){//if leg found
                    //update leg timimngs
                    NSMutableDictionary *legDict = [results objectAtIndex:0];
                    leg.legArrivalLocal = [legDict objectForKey:@"legArrivalLocal"];
                    leg.legDepartureLocal = [legDict objectForKey:@"legDepartureLocal"];
                    //update the leg crew menber details
                    
                    CrewMembers *crew = [[leg.legsCrewmember array] objectAtIndex:0];
                    crew.firstName = [[[[results objectAtIndex:0] objectForKey:@"crew"] objectAtIndex:0] objectForKey:@"firstName"];
                    crew.lastName = [[[[results objectAtIndex:0] objectForKey:@"crew"] objectAtIndex:0] objectForKey:@"lastName"];
                    crew.activeRank = [[[[results objectAtIndex:0] objectForKey:@"crew"] objectAtIndex:0] objectForKey:@"activeRank"];
                    //deleting the same leg from dict also as it exists
                    [legArr removeObject:[results objectAtIndex:0]];
                }
            }
            
            if ([legArr count]>0) {//checking if any legs exist in new flight
                //if exist add new leg to old object
                for (NSMutableDictionary *legDict in legArr) {
                    Legs *leg = [NSEntityDescription insertNewObjectForEntityForName:@"Legs" inManagedObjectContext:managedObjectContext];
                    leg.destination = [legDict objectForKey:@"Destination"];
                    leg.origin = [legDict objectForKey:@"Origin"];
                    leg.legArrivalLocal = [legDict objectForKey:@"legArrivalLocal"];
                    leg.legDepartureLocal = [legDict objectForKey:@"legDepartureLocal"];
                    for (NSMutableDictionary *crewDict in [legDict objectForKey:@"crew"]) {
                        CrewMembers *crew = [NSEntityDescription insertNewObjectForEntityForName:@"CrewMembers" inManagedObjectContext:managedObjectContext];
                        crew.activeRank = [crewDict objectForKey:@"activeRank"];
                        crew.firstName = [crewDict objectForKey:@"firstName"];
                        crew.lastName = [crewDict objectForKey:@"lastName"];
                        crew.specialRank = [crewDict objectForKey:@"specialRank"];
                        [leg addLegsCrewmemberObject:crew];
                    }
                    
                    [oldObj addFlightInfoLegsObject:leg];
                }
            }
            
            
        }else{//keys differ
            //delete old flight
           
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [newflight objectForKey:@"flightDate"],[newflight objectForKey:@"suffix"],[newflight objectForKey:@"flightNumber"],[newflight objectForKey:@"airlineCode"]];
            results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
            if ([results count]>0) {
                return NO;
            }else{
                [del deleteFromLegForFlight:oldObj];
                [currentUser removeFlightRostersObject:oldObj];
                [currentUser.managedObjectContext deleteObject:oldObj];
                FlightRoaster *flight = [self getFlightObjectFromDict:newflight forManageObjectContext:managedObjectContext];
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
    }else if (mode==Delete){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [newflight objectForKey:@"flightDate"],[newflight objectForKey:@"suffix"],[newflight objectForKey:@"flightNumber"],[newflight objectForKey:@"airlineCode"]];
        results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count]>0) {
            FlightRoaster *flightObj = [results objectAtIndex:0];
            [del deleteFromLegForFlight:flightObj];
            [currentUser removeFlightRostersObject:flightObj];
            [currentUser.managedObjectContext deleteObject:flightObj];
        }
        
    }
    
    
    if ([managedObjectContext save:&error]) {
        return YES;
    }else{
        return NO;
    }
}



@end
