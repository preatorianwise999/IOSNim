//
//  SaveSeatMap.m
//  Nimbus2
//
//  Created by vishal on 10/20/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "SaveSeatMap.h"
#import "AppDelegate.h"
#import "NSMutableDictionary+ChekVal.h"
#import "AllDb.h"
#import "LTSingleton.h"
#import "SynchronizationController.h"

@implementation SaveSeatMap

+(void)saveSeatMapForFlight:(NSDictionary *)flightDict andSeatMap:(NSDictionary *)seatMapDict {
    
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [flightDict checkNilValueForKey:@"flightDate"],[flightDict checkNilValueForKey:@"suffix"],[flightDict checkNilValueForKey:@"flightNumber"],[flightDict checkNilValueForKey:@"airlineCode"]];
        [request setPredicate:predicate];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count] > 0) {
            FlightRoaster *flight = [results objectAtIndex:0];
            int counter = 0;
            
            NSArray *sectionArray = nil;
            NSDictionary *subSeatMapDict = [seatMapDict objectForKey:@"getSeatMap"];
            if(![subSeatMapDict isEqual:[NSNull null]]) {
                
                NSDictionary *segmentsDict = [subSeatMapDict objectForKey:@"segments"];
                
                if(![segmentsDict isEqual:[NSNull null]]) {
                    
                    sectionArray = [segmentsDict objectForKey:@"segmentInfo"];
                }
            }
            
            if ([[flight.flightSeatMap allObjects] count]>0) {
                
                int Count= (int)[[flight.flightSeatMap allObjects] count] ;
                for (int i=Count-1; i>=0; i--) {
                    SeatMap *seatMap = [[flight.flightSeatMap allObjects] objectAtIndex:i];
                    [flight removeFlightSeatMapObject:seatMap];
                    [flight.managedObjectContext deleteObject:seatMap];
                }
            }
            
            for (int i = 0; i<[sectionArray count]; i++) {
                NSDictionary *sectionDict = [sectionArray objectAtIndex:i];
                NSDictionary *info = [sectionDict objectForKey:@"flightSegment"];
                NSString *classType = [info objectForKey:@"cabinClass"];
                NSDictionary *SeatMapDetails = [sectionDict objectForKey:@"seatMapDetails"];
                NSDictionary *CabinConfiguration = [SeatMapDetails objectForKey:@"cabinConfiguration"];
                int l = 0;
                /*
                 
                 temporary fix: "columns" used to be only one object but now it is an array. We should work with all the objects but for now we are working just with the first one.
                 
                 */
                int count = 0;
                NSArray *Columns = [CabinConfiguration objectForKey:@"columns"];
                
                for (NSDictionary * columnDict in Columns){
                    
                    count++;
                    int noOfRowForType = [[columnDict valueForKey:@"numberOfRows"] intValue];
                    NSDictionary *Rows = [SeatMapDetails objectForKey:@"rows"];
                    
                    NSArray *RowInfoArray = [Rows objectForKey:@"row"];
                    
                    for (int j = l; j< noOfRowForType + l; j++) {
                        if ([RowInfoArray count] > j){
                            
                            NSDictionary *info = [RowInfoArray objectAtIndex:j];
                            NSArray *seatArray = [info objectForKey:@"seat"];
                            NSInteger currentRowNumber = [[info valueForKey:@"rowNumber"] integerValue];
                            
                            for (int k = 0; k < seatArray.count; k++) {
                                
                                counter++;
                                SeatMap *seatMap = [NSEntityDescription insertNewObjectForEntityForName:@"SeatMap" inManagedObjectContext:managedObjectContext];
                                
                                NSDictionary *seat = [seatArray objectAtIndex:k];
                                seatMap.classType = classType;
                                seatMap.state = [seat objectForKey:@"state"];
                                seatMap.rowNumber = [NSNumber numberWithInteger:currentRowNumber];
                                seatMap.columnNum = [seat objectForKey:@"column"];
                                BOOL window = [[seat valueForKey:@"isWindow"] boolValue];
                                seatMap.isWindow = [NSNumber numberWithBool:window];
                                BOOL aisle = [[seat valueForKey:@"isAisle"] boolValue];
                                seatMap.isAisle =[NSNumber numberWithBool:aisle];
                                BOOL emergency = [[info valueForKey:@"emergency"] boolValue];
                                seatMap.isEmergency = [NSNumber numberWithBool:emergency];
                                seatMap.index = [NSNumber numberWithInt:counter];
                                seatMap.columnType = [NSString stringWithFormat:@"%@%@",[NSNumber numberWithInt:count],classType];
                                [flight addFlightSeatMapObject:seatMap];
                            }
                        }
                    }
                    
                    l= l+ noOfRowForType;
                    flight.isFlightSeatMapSynched = [NSNumber numberWithBool:YES];
                }
            }
        }
    }
    
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"not save");
    }
}

+(void)removeCustomer:(Customer *)cust forLeg:(Legs *)leg forFlight:(FlightRoaster *)flight {
    
    NSPredicate * predicate;
    NSArray * results;
    
    NSArray * splMealarray =  [cust.specialMeals array];
    
    for (SpecialMeal * meal in splMealarray){
        [cust removeSpecialMealsObject:meal];
        [cust.managedObjectContext deleteObject:meal];
    }
    NSArray * connArray = [cust.cusConnection array];
    for (Connection * conn in connArray){
        [cust removeCusConnectionObject:conn];
        [cust.managedObjectContext deleteObject:conn];
        
    }
    if (cust.seatNumber !=nil && ![cust.seatNumber isEqualToString:@""]){
        int  seatRow = [[cust.seatNumber substringToIndex:cust.seatNumber.length -1] intValue];
        
        
        NSString *seatColumn = [cust.seatNumber substringFromIndex:[cust.seatNumber length] - 1];
        predicate = [NSPredicate predicateWithFormat:@"rowNumber == %d AND columnNum == %@",seatRow,seatColumn];
        results = [[flight.flightSeatMap allObjects] filteredArrayUsingPredicate:predicate];
        
        if ([results count]>0){
            SeatMap * seatmap = [results objectAtIndex:0];
            [seatmap removeSeatCustomer:[NSSet setWithObject:cust]];
        }
    }
    
    [leg removeLegCustomerObject:cust];
    [leg.managedObjectContext deleteObject:cust];
    
    for (Connection * conn in connArray) {
        [cust removeCusConnectionObject:conn];
        [cust.managedObjectContext deleteObject:conn];
        
    }
    if (cust.seatNumber != nil && ![cust.seatNumber isEqualToString:@""]) {
        int seatRow = [[cust.seatNumber substringToIndex:cust.seatNumber.length - 1] intValue];
        
        NSString *seatColumn = [cust.seatNumber substringFromIndex:[cust.seatNumber length] - 1];
        predicate = [NSPredicate predicateWithFormat:@"rowNumber == %d AND columnNum == %@",seatRow,seatColumn];
        results = [[flight.flightSeatMap allObjects] filteredArrayUsingPredicate:predicate];
        
        if ([results count] > 0) {
            SeatMap * seatmap = [results objectAtIndex:0];
            [seatmap removeSeatCustomer:[NSSet setWithObject:cust]];
        }
    }
    
    [leg removeLegCustomerObject:cust];
    [leg.managedObjectContext deleteObject:cust];
}

+(void)savePassengerForFlight:(NSDictionary *)flightDict andPassengerDict:(NSDictionary *)passengerDict {
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    User *currentUser;
    if([results count] > 0) {
        
        currentUser = [results objectAtIndex:0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [flightDict checkNilValueForKey:@"flightDate"],[flightDict checkNilValueForKey:@"suffix"],[flightDict checkNilValueForKey:@"flightNumber"],[flightDict checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        
        if ([results count] > 0) {
            
            FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
            
            predicate = nil;
            
            NSArray *legArray = [[passengerDict objectForKey:@"passengerListResponse"] objectForKey:@"legs"];
            
            for (int i = 0; i < legArray.count; i++) {
                SynchronizationController *synch = [[SynchronizationController alloc] init];
                if([synch shouldSyncSeatmapAndPassengerListForFlight:@{@"flightKey" : flightDict} leg:i] == NO) {
                    continue;
                }
                
                NSDictionary *legsDict = [legArray objectAtIndex:i];
                predicate = [NSPredicate predicateWithFormat:@"origin == %@ AND destination == %@",[[legArray objectAtIndex:i] valueForKey:@"origin"] ,[[legArray objectAtIndex:i] valueForKey:@"destination"]];
                results = [[flight.flightInfoLegs array] filteredArrayUsingPredicate:predicate];
                
                if ([results count] > 0) {
                    Legs * leg =  [results objectAtIndex:0];
                    // Removing old customer
                    //continue;
                    
                    NSDictionary *statDict = [legsDict objectForKey:@"stats"];
                    if ([[statDict allKeys] count]>0) {
                        Stats *stat;
                        if (leg.legStats==nil) {
                            stat = [NSEntityDescription insertNewObjectForEntityForName:@"Stats" inManagedObjectContext:managedObjectContext];
                            [leg setLegStats:stat];
                        } else {
                            stat=leg.legStats;
                        }
                        stat.numpy = [NSNumber numberWithInteger:[[statDict objectForKey:@"NUMPY"] integerValue]];
                        stat.numpj = [NSNumber numberWithInteger:[[statDict objectForKey:@"NUMPJ"] integerValue]];
                        stat.umnr = [NSNumber numberWithInteger:[[statDict objectForKey:@"UMNR"] integerValue]];
                        stat.wchc = [NSNumber numberWithInteger:[[statDict objectForKey:@"UMNR"] integerValue]];
                        stat.wchr = [NSNumber numberWithInteger:[[statDict objectForKey:@"WCHR"] integerValue]];
                        stat.wchs = [NSNumber numberWithInteger:[[statDict objectForKey:@"WCHS"] integerValue]];
                    }
                    
                    NSArray *customerArray = [legsDict checkNilValueForKey:@"passengerList"];
                    
                    int cct = (int)[[leg.legCustomer array] count];
                    if (cct > 0) {
                        for (int i = cct - 1; i >= 0; i--) {
                            Customer *cust = [[leg.legCustomer array] objectAtIndex:i];
                            [self removeCustomer:cust forLeg:leg forFlight:flight];
                        }
                    }
                    
                    for (int i = 0; i < customerArray.count; i++) {
                        NSDictionary *customerDict = [customerArray objectAtIndex:i];
                        
                        // NOTE(diego_cath): Cristobal from LAN requested that only passengers with status "Embarcado", "Chequeado", "BED" or "NBD" be saved in the local database - April 22, 2016
                        NSString *status = customerDict[@"status"];
                        if(status == nil || (![status isEqualToString:@"Embarcado"] && ![status isEqualToString:@"BED"] && ![status isEqualToString:@"Chequeado"] && ![status isEqualToString:@"NBD"])) {
                            continue;
                        }
                        
                        // NOTE(diego_cath): LAN requested that passengers without seat number not be saved - May 20 2016
                        if([customerDict valueForKey:@"seatNumber"] == nil || [[customerDict valueForKey:@"seatNumber"] isEqualToString:@""]) {
                            continue;
                        }
                        
                        Customer *customer = [NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:leg.managedObjectContext];
                        
                        customer.firstName = [customerDict valueForKey:@"firstName"];
                        customer.lastName = [customerDict valueForKey:@"lastName"];
                        
                        if ([customerDict valueForKey:@"secondLastName"] != nil) {
                            customer.secondLastName = [customerDict valueForKey:@"secondLastName"];
                        }
                        
                        customer.customerId = [self generateRandomString];
                        customer.seatNumber = [customerDict valueForKey:@"seatNumber"];
                        customer.accountStatus = [customerDict valueForKey:@"status"];
                        customer.docNumber = [customerDict valueForKey:@"documentNumber"];
                        customer.docType = [customerDict valueForKey:@"documentType"];
                        
                        customer.freqFlyerNum = [customerDict valueForKey:@"frequentNumber"];
                        if([customerDict valueForKey:@"frequentAirlineCode"] && ![[customerDict valueForKey:@"frequentAirlineCode"] isEqual:[NSNull null]]) {
                            customer.freqFlyerComp = [customerDict valueForKey:@"frequentAirlineCode"];
                        }
                        else {
                            customer.freqFlyerComp = @"";
                        }
                        customer.freqFlyerCategory = [customerDict valueForKey:@"frequentCategory"];
                        customer.groupCode = [customerDict valueForKey:@"groupCode"];
                        if ([customerDict valueForKey:@"address"]!=nil) {
                            customer.address = [customerDict valueForKey:@"address"];
                        }
                        
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        df.dateFormat = @"dd-MM-yyyy";
                        
                        customer.dateOfBirth = [df dateFromString:[customerDict valueForKey:@"dateBirth"]];
                        customer.email = [customerDict valueForKey:@"email"];
                        customer.language = [customerDict valueForKey:@"language"];
                        customer.gender = [customerDict valueForKey:@"gender"];
                        customer.editCodes = [customerDict valueForKey:@"editCodes"];
                        customer.isWCH = [customerDict valueForKey:@"wch"];
                        customer.isChild = [customerDict valueForKey:@"isChild"];
                        if ([customerDict objectForKey:@"lanPass"] != [NSNull null]) {
                            
                            customer.lanPassKms = [NSString stringWithFormat:@"%@",[[customerDict objectForKey:@"lanPass"] valueForKey:@"kilometers"]] ;
                            customer.lanPassCategory =[[customerDict objectForKey:@"lanPass"] valueForKey:@"category"];
                            customer.lanPassUpgrade =[[customerDict objectForKey:@"lanPass"] valueForKey:@"upgrade"];
                        }
                        
                        customer.vipCategory = [[customerDict objectForKey:@"vipData"] valueForKey:@"category"];
                        customer.vipRemarks = [[customerDict objectForKey:@"vipData"] valueForKey:@"remarks"];
                        customer.vipSpecialAttentions =[[customerDict objectForKey:@"vipData"] valueForKey:@"specialAttentions"];
                        
                        NSArray * splMealsArray = [customerDict objectForKey:@"specialMeals"];
                        
                        for (int j = 0 ; j<splMealsArray.count;j++) {
                            NSDictionary *splMealDict = [splMealsArray objectAtIndex:j];
                            
                            SpecialMeal *splMeal  = [NSEntityDescription insertNewObjectForEntityForName:@"SpecialMeal" inManagedObjectContext:managedObjectContext];
                            
                            splMeal.option = [splMealDict valueForKey:@"option"];
                            splMeal.serviceCode = [splMealDict valueForKey:@"serviceCode"];
                            
                            [customer addSpecialMealsObject:splMeal];
                        }
                        
                        NSArray *connectionArray = [customerDict objectForKey:@"connection"];
                        for (int j = 0 ; j<connectionArray.count;j++) {
                            NSDictionary *connDict = [connectionArray objectAtIndex:j];
                            Connection *connection = [NSEntityDescription insertNewObjectForEntityForName:@"Connection" inManagedObjectContext:managedObjectContext];
                            
                            connection.arrivalAP = [connDict valueForKey:@"arrival"];
                            connection.departureAP = [connDict valueForKey:@"departure"];
                            NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
                            df1.dateFormat = @"dd-MM-yyyy HH:mm";
                            NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
                            df2.dateFormat = @"dd-MM-yyyy";
                            NSDate *depDate = (NSDate *)[df1 dateFromString:[connDict valueForKey:@"departureDate"]];
                            if(!depDate) {
                                depDate = (NSDate *)[df2 dateFromString:[connDict valueForKey:@"departureDate"]];
                            }
                            NSDate *arrDate = (NSDate *)[df1 dateFromString:[connDict valueForKey:@"arrivalDate"]];
                            if(!arrDate) {
                                arrDate = (NSDate *)[df2 dateFromString:[connDict valueForKey:@"arrivalDate"]];
                            }
                            
                            connection.departureDate = depDate;
                            connection.arrivalDate = arrDate;
                            connection.flightNum = [connDict valueForKey:@"flightNumber"];
                            connection.flightType =[connDict valueForKey:@"airlineCode"];
                            [customer addCusConnectionObject:connection];
                        }
                        
                        NSString *seatNumber = [customerDict valueForKey:@"seatNumber"];
                        
                        if (seatNumber !=nil && ![seatNumber isEqualToString:@""]) {
                            int seatRow = [[seatNumber substringToIndex:seatNumber.length -1] intValue];
                            
                            NSString *seatColumn = [[customerDict valueForKey:@"seatNumber"] substringFromIndex:[[customerDict valueForKey:@"seatNumber"] length] - 1];
                            predicate = [NSPredicate predicateWithFormat:@"rowNumber == %d AND columnNum == %@",seatRow,seatColumn];
                            results = [[flight.flightSeatMap allObjects] filteredArrayUsingPredicate:predicate];
                            
                            if ([results count]>0) {
                                SeatMap * seatmap = [results objectAtIndex:0];
                                [seatmap setSeatCustomer:[NSSet setWithObject:customer]];
                            }
                        }
                        
                        NSLog(@"Customer added seat %@ ------------------???", customer.seatNumber);
                        
                        [customer setCusLeg:leg];
                        [leg addLegCustomerObject:customer];
                    }
                }
            }
        }
    }
    
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"not save");
    }
}

+(NSString *)customerExists:(NSDictionary *)flightDict andCustomerDict:(NSDictionary *)customerDict legNumber:(int)legindex {
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.managedObjectContext;
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    User *currentUser;
    if([results count]>0) {
        currentUser = [results objectAtIndex:0];
        
        NSDictionary *flightDict1 = (NSDictionary *)[[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"flightKey"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [flightDict1 checkNilValueForKey:@"flightDate"], [flightDict1 checkNilValueForKey:@"suffix"], [flightDict1 checkNilValueForKey:@"flightNumber"], [flightDict1 checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        
        if ([results count] > 0) {
            FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
            predicate = nil;
            
            NSArray *results1 = [flight.flightInfoLegs array];
            
            if ([results1 count] > 0){
                Legs *leg =  [results1 objectAtIndex:legindex];
                
                NSString *seatNo = [customerDict valueForKey:@"SEAT_NUMBER"];
                predicate = [NSPredicate predicateWithFormat:@"seatNumber == %@",seatNo];
                NSArray *results2 = [[leg.legCustomer array] filteredArrayUsingPredicate:predicate];
                // Removing old customer
                if ([results2 count] > 0 && customerDict !=nil ){
                    Customer *cust = [results2 objectAtIndex:0];
                    
                    return [NSString stringWithFormat:@"%@ %@",cust.firstName,cust.lastName];
                }
            }
        }
    }
    return nil;
}

+(void)saveCustomerForFlight:(NSDictionary *)flightDict andCustomerDict:(NSDictionary *)customerDict legNumber:(int)legindex {
    
    BOOL seatExists = [[customerDict valueForKey:@"SEATMAP_EXIST"] boolValue];
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.managedObjectContext;
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    User *currentUser;
    if([results count] > 0) {
        currentUser = [results objectAtIndex:0];
        
        NSDictionary *flightDict1 = (NSDictionary *)[[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"flightKey"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [flightDict1 checkNilValueForKey:@"flightDate"],[flightDict1 checkNilValueForKey:@"suffix"],[flightDict1 checkNilValueForKey:@"flightNumber"],[flightDict1 checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        
        if ([results count] > 0) {
            FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
            predicate = nil;
            
            NSArray *results1 = [flight.flightInfoLegs array];
            
            if ([results1 count] > 0) {
                Legs * leg =  [results1 objectAtIndex:legindex];
                
                NSString * seatNo = [customerDict valueForKey:@"SEAT_NUMBER"];
                predicate = [NSPredicate predicateWithFormat:@"seatNumber == %@",seatNo];
                NSArray   *results2 = [[leg.legCustomer array] filteredArrayUsingPredicate:predicate];
                // Removing old customer
                if ([results2 count] > 0 && customerDict != nil) {
                    Customer *cust = [results2 objectAtIndex:0];
                    int  seatRow = [[seatNo substringToIndex:seatNo.length -1] intValue];
                    
                    NSString *seatColumn = [[customerDict valueForKey:@"SEAT_NUMBER"] substringFromIndex:[[customerDict valueForKey:@"SEAT_NUMBER"] length] - 1];
                    predicate = [NSPredicate predicateWithFormat:@"rowNumber == %d AND columnNum == %@",seatRow,seatColumn];
                    NSArray *results3 = [[flight.flightSeatMap allObjects] filteredArrayUsingPredicate:predicate];
                    
                    if ([results3 count] > 0) {
                        SeatMap * seatmap = [results3 objectAtIndex:0];
                        [seatmap removeSeatCustomerObject:cust];
                        cust.seatNumber = nil;
                    }
                }
                
                // Start saving customer
                Customer * customer = [NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:managedObjectContext];
                
                customer.firstName = [customerDict valueForKey:@"FIRST_NAME"];
                customer.lastName = [customerDict valueForKey:@"LAST_NAME"];
                
                if([customer.lastName isEqualToString:@"SILVA DELGADO"]) {
                    NSLog(@"breakpoint");
                }
                
                customer.secondLastName = [customerDict valueForKey:@"SECOND_LAST_NAME"];
                customer.customerId = [self generateRandomString];
                customer.seatNumber = [customerDict valueForKey:@"SEAT_NUMBER"];
                customer.docNumber = [customerDict valueForKey:@"DOCUMENT_NUMBER"];
                customer.docType = [customerDict valueForKey:@"DOCUMENT_TYPE"];
                customer.manuallyAdded = [NSNumber numberWithBool:YES];
                NSString * seatNumber = [customerDict valueForKey:@"SEAT_NUMBER"];
                
                int  seatRow = [[seatNumber substringToIndex:seatNumber.length - 1] intValue];
                
                NSString *seatColumn = [[customerDict valueForKey:@"SEAT_NUMBER"] substringFromIndex:[[customerDict valueForKey:@"SEAT_NUMBER"] length] - 1];
                if (seatExists) {
                    predicate = [NSPredicate predicateWithFormat:@"rowNumber == %d AND columnNum == %@",seatRow,seatColumn];
                    results = [[flight.flightSeatMap allObjects] filteredArrayUsingPredicate:predicate];
                    
                    if ([results count] > 0) {
                        SeatMap * seatmap = [results objectAtIndex:0];
                        [seatmap setSeatCustomer:[NSSet setWithObject:customer]];
                    }
                    NSLog(@"Customer added seat %@ ------------------???",customer.seatNumber);
                } else {
                    SeatMap *seatMap = [NSEntityDescription insertNewObjectForEntityForName:@"SeatMap" inManagedObjectContext:managedObjectContext];
                    seatMap.rowNumber = [NSNumber numberWithInt:seatRow];
                    seatMap.columnNum = seatColumn;
                    seatMap.isAisle = [NSNumber numberWithInt:0];
                    seatMap.columnType = @"1M";
                    seatMap.isWindow = [NSNumber numberWithInt:0];
                    seatMap.isEmergency = [NSNumber numberWithInt:0];
                    [seatMap setSeatCustomer:[NSSet setWithObject:customer]];
                    [flight addFlightSeatMapObject:seatMap];
                }
                [customer setCusLeg:leg];
                [leg addLegCustomerObject:customer];
            }
            NSError *error;
            if (![managedObjectContext save:&error]) {
                NSLog(@"not save");
            }
        }
    }
}

+(void)updateCustomerForFlight:(NSDictionary *)flightDict andCustomerDict:(NSDictionary *)customerDict legNumber:(int)legindex {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    User *currentUser;
    if([results count] > 0) {
        currentUser = [results objectAtIndex:0];
        
        NSDictionary *flightDict1 = (NSDictionary *)[[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"flightKey"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [flightDict1 checkNilValueForKey:@"flightDate"],[flightDict1 checkNilValueForKey:@"suffix"],[flightDict1 checkNilValueForKey:@"flightNumber"],[flightDict1 checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        
        if ([results count] > 0) {
            FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
            predicate = nil;
            
            NSArray *results1 = [flight.flightInfoLegs array];
            
            if ([results1 count] > 0) {
                Legs *leg =  [results1 objectAtIndex:legindex];
                
                predicate = [NSPredicate predicateWithFormat:@"customerId == %@",[customerDict valueForKey:@"customerId"]];
                results = [[leg.legCustomer array]filteredArrayUsingPredicate:predicate];
                if ([results count] > 0) {
                    Customer * customer = [results objectAtIndex:0];
                    customer.docNumber = [customerDict valueForKey:@"docNumber"];
                    customer.docType =[customerDict valueForKey:@"docType"];
                    [customer setManuallyAdded:[NSNumber numberWithBool:YES]];
                    
                    NSError *error;
                    
                    if (![managedObjectContext save:&error]) {
                        NSLog(@"not save");
                    }
                }
            }
        }
    }
}

+(NSNumber *)absoluteValue:(NSNumber *)input {
    return [NSNumber numberWithDouble:fabs([input doubleValue])];
}
+(NSString *)CreateDefaultIdGeneratedReport:(NSString*)idflight:(NSString*)idOperador
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitHour| NSCalendarUnitMinute fromDate:[NSDate date]];
    
   NSInteger yearTempo = [dateComponents year];
   NSInteger monthTempo = [dateComponents month];
   NSInteger dayTempo = [dateComponents day];
   NSInteger hourTempo = [dateComponents hour];
   NSInteger minuteTempo = [dateComponents minute];
   //NSInteger secondTempo = [dateComponents second];

    NSString * stString =@"";
    NSString *varStringFlight = idflight;
    NSString *varStringOperator =idOperador;
    //NSString *varStringFecha = [dateFormatter stringFromDate:[NSDate date]];
    
    stString = [NSString stringWithFormat: @"%@%@%@%@%@%@%@", varStringFlight, varStringOperator, [NSString stringWithFormat:@"%i", yearTempo],[NSString stringWithFormat:@"%i", monthTempo],[NSString stringWithFormat:@"%i", dayTempo] ,[NSString stringWithFormat:@"%i", hourTempo],[NSString stringWithFormat:@"%i", minuteTempo]];
 
    return stString;
}
+(NSString *)generateRandomString
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:3];
    
    for (int i = 0; i < 6; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
    
}
@end
