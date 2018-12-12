//
//  LTCUSData.m
//  LATAM
//
//  Created by Durga Madamanchi on 7/1/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTCUSData.h"
#import "AppDelegate.h"
#import "User.h"
#import "LTCreateFlightReport.h"
#import "LTGetLightData.h"
#import "CUSImages.h"
#import "LTCUSDropdownData.h"

@implementation LTCUSData
+(NSArray*)createCUSReportForAllFlights:(NSManagedObjectContext*)localMoc{
    
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [localMoc executeFetchRequest:request error:&error1];
    
    User *currentUser;
    if([results count]>0) {
        currentUser = [results objectAtIndex:0];
    }
    NSArray *array = [currentUser.flightRosters array];
    
    return array;
}

+(NSString*)getCUSJsonReportForDict:(NSMutableDictionary *)flightRoasterDict customer:(Customer*)customer forType:(NSString*)type forReportId:(NSString*)reportId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reportId == %@",reportId];
    CusReport *cusReport = (CusReport *)[[[customer.cusCusReport array] filteredArrayUsingPredicate:predicate] firstObject];
    
    NSDictionary *cusDict = [self getFormCUSReportForDictionary:nil CUSReport:cusReport];
    
    NSString *jsonString = [self getJsonDataForCUS:[cusDict objectForKey:@"groups"] forCustomer:customer withReportId:[[flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"reportId"] forCusReport:cusReport];
    
    return jsonString;
}
+(FlightRoaster*)getFlight1:(NSDictionary*)flightKeyDict withContext:(NSManagedObjectContext*)moc{
    
    
    //Deal with success
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [moc executeFetchRequest:request error:&error1];
    
    User *currentUser;
    
    if([results count]>0) {
        currentUser = [results objectAtIndex:0];
    }
    
    NSMutableDictionary *dict = [flightKeyDict objectForKey:@"flightKey"];
    
    NSDate *fDate;
    
    if([[dict objectForKey:@"flightDate"] isKindOfClass:[NSString class]]){
        NSString *fDateString = [dict objectForKey:@"flightDate"];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        
        fDate = [dateFormat3 dateFromString:fDateString];
    }else{
        fDate = [dict objectForKey:@"flightDate"];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    
    NSArray *flightArray = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
    
    FlightRoaster *flight;
    
    if([flightArray count]>0){
        flight = [flightArray objectAtIndex:0];
    }
    return flight;
    
}
+(FlightRoaster*)getFlight:(NSMutableDictionary*)flightKeyDict{
    
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
    }
    
    NSMutableDictionary *dict = [flightKeyDict objectForKey:@"flightKey"];
    
    NSDate *fDate;
    
    if([[dict objectForKey:@"flightDate"] isKindOfClass:[NSString class]]){
        NSString *fDateString = [dict objectForKey:@"flightDate"];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        
        fDate = [dateFormat3 dateFromString:fDateString];
    }else{
        fDate = [dict objectForKey:@"flightDate"];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    
    NSArray *flightArray = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
    
    FlightRoaster *flight;
    
    if([flightArray count]>0){
        flight = [flightArray objectAtIndex:0];
    }
    return flight;
    
}
+(NSMutableDictionary*)getFlightDict:(FlightRoaster*)flightRoster {
    NSMutableDictionary *fkeydict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dict;
    @try {
        [fkeydict setObject:flightRoster.airlineCode forKey:@"airlineCode"];
        [fkeydict setObject:flightRoster.flightDate forKey:@"flightDate"];
        [fkeydict setObject:flightRoster.flightNumber forKey:@"flightNumber"];
        [fkeydict setObject:flightRoster.suffix forKey:@"suffix"];
        if (flightRoster.type) {
            [fkeydict setObject:flightRoster.type forKey:@"flightReportType"];
        }
        
        [fkeydict setObject:[flightRoster.flightInfoLegs array] forKey:@"legs"];
        if(nil != [LTCreateFlightReport getVersionForType:flightRoster.type])
            [fkeydict setObject:[LTCreateFlightReport getVersionForType:flightRoster.type] forKey:@"flightReportVersion"];
        dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:fkeydict,@"flightKey", nil];
    }
    @catch (NSException *exception) {
        
    }
    return dict;
}


+(NSString *)getJsonDataForCUS:(NSArray*)array forCustomer:(Customer*)customer  withReportId:(NSString *)reportId forCusReport:(CusReport*)cusReport {
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSMutableDictionary *finalDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *finalRequirementDict=[[NSMutableDictionary alloc] init];
    
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:@"name"] isEqualToString:[appdelegate copyEnglishTextForKey:@"ADD_PASSENGER_TITLE"]]) {
            NSDictionary *passingersDict = [dict objectForKey:@"multiEvents"];
            NSArray *passingersArray = [passingersDict objectForKey:[appdelegate copyEnglishTextForKey:@"ADD_ASSOCIATED_PASSENGER"]];
            NSMutableArray *finalpassingersArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in passingersArray) {
                if([dict objectForKey:[appdelegate copyEnglishTextForKey:@"FIRST_NAME"]]){
                    
//                    NSString *testViewValue = [dict objectForKey:[appdelegate copyEnglishTextForKey:@"DOCUMENT_TYPE"]];
                    NSString *value = @"0";
                    
                    NSDictionary *passinger = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [dict objectForKey:[appdelegate copyEnglishTextForKey:@"FIRST_NAME"]],@"firstName",
                                               [dict objectForKey:[appdelegate copyEnglishTextForKey:@"LAST_NAME"]], @"lastName",
                                               [dict objectForKey:[appdelegate copyEnglishTextForKey:@"SECOND_LAST_NAME"]]?[dict objectForKey:[appdelegate copyEnglishTextForKey:@"SECOND_LAST_NAME"]]:@"",@"secondLastName",
                                               [dict objectForKey:[appdelegate copyEnglishTextForKey:@"DOCUMENT_NUMBER"]],@"documentNumber",
                                               value, @"documentType",nil];
                    [finalpassingersArray addObject:passinger];
                }
                [finalDict setObject:finalpassingersArray forKey:@"relatedPassengers"];
            }
            
        }
        
        else if([[dict objectForKey:@"name"] isEqualToString:[appdelegate copyEnglishTextForKey:@"ASSOCIATED_LEG"]]) {
            
            NSString *leg = [[dict objectForKey:@"singleEvents"] objectForKey:[appdelegate copyEnglishTextForKey:@"SELECT_LEG"]];
            
            NSArray *array = [leg componentsSeparatedByString:@"-"];
            
            [finalDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:[array objectAtIndex:0],@"origin",[array objectAtIndex:1],@"destination",nil] forKey:@"leg"];
        }
        else if([[dict objectForKey:@"name"] isEqualToString:[appdelegate copyEnglishTextForKey:@"REPORT"]]) {
            
            NSDictionary *actionTaken = [dict objectForKey:@"multiEvents"];
            
            NSMutableArray *actionTakenArray1 = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dict in [actionTaken objectForKey:[appdelegate copyEnglishTextForKey:@"ACTION_TAKEN_ON_BOARD"]]) {
                
                if([dict objectForKey:[appdelegate copyEnglishTextForKey:@"ACTION_TAKEN_ON_BOARD"]]) {
                    NSString *testViewValue = [dict objectForKey:[appdelegate copyEnglishTextForKey:@"ACTION_TAKEN_ON_BOARD"]];
                    NSString *value;
                    
                    if([testViewValue containsString:@"-1"]) {
                        
                        value = [[testViewValue componentsSeparatedByString:@"||"] firstObject];
                        
                    }else {
                        value = [[testViewValue componentsSeparatedByString:@"||"] firstObject];
                    }
                    
                    [actionTakenArray1 addObject:[NSDictionary dictionaryWithObjectsAndKeys:value,@"value",@"",@"observation",nil]];
                }
            }
            
            NSMutableArray *actionTakenArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dict in [actionTaken objectForKey:[appdelegate copyEnglishTextForKey:@"SEAT_MAINTENANCE"]]) {
                
                if([dict objectForKey:[appdelegate copyEnglishTextForKey:@"SEAT_MAINTENANCE"]]) {
                    
                    NSString *testViewValue =  [dict objectForKey:[appdelegate copyEnglishTextForKey:@"SEAT_MAINTENANCE"]];
                    NSString *value;
                    
                    if([testViewValue containsString:@"-1"]){
                        
                        NSString *other = [testViewValue substringFromIndex:3];
                        
                        value = [[other componentsSeparatedByString:@"||"] firstObject];
                        
                    } else {
                        value = [[testViewValue componentsSeparatedByString:@"||"] firstObject];
                    }
                    
                    [actionTakenArray addObject:value];
                }
                
            }
            
            NSDictionary *medicalAssistence = [dict objectForKey:@"singleEvents"];
            
            NSDictionary *medicalAssistanceNew = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [medicalAssistence objectForKey:[appdelegate copyEnglishTextForKey:@"DOCTOR_FULL_NAME"]], @"doctorsFullName",
                                                  [medicalAssistence objectForKey:[appdelegate copyEnglishTextForKey:@"LICENSE_NUMBER"]], @"licenseNumber",
                                                  [medicalAssistence objectForKey:[appdelegate copyEnglishTextForKey:@"DIAGNOSE"]], @"diagnose",
                                                  [medicalAssistence objectForKey:[appdelegate copyEnglishTextForKey:@"EMAIL"]], @"email",
                                                  [medicalAssistence objectForKey:[appdelegate copyEnglishTextForKey:@"PHONE_NUMBER"]], @"phoneNumber",
                                                  [medicalAssistence objectForKey:[appdelegate copyEnglishTextForKey:@"ADDRESS"]], @"address",
                                                  nil];
            
            [finalRequirementDict addEntriesFromDictionary:
                                        @{
                                          @"actionTakens" : actionTakenArray1,
                                          @"seatMaintenances" : actionTakenArray,
                                          @"medicalAssitance" : medicalAssistanceNew,
                                          @"reportDetail" : [medicalAssistence objectForKey:[appdelegate copyEnglishTextForKey:@"REPORT_DETAILS"]]}];
            
            NSString *testViewValue =  [medicalAssistence objectForKey:[appdelegate copyEnglishTextForKey:@"REASON_FOR_REPORT"]];
            NSString *value = @"";
            
            if([testViewValue containsString:@"-1"]){
                
                NSString *other = [testViewValue substringFromIndex:3];
                
                value = [[other componentsSeparatedByString:@"||"] firstObject];
                
            } else {
                value = [[testViewValue componentsSeparatedByString:@"||"] firstObject];
            }
            
            [finalRequirementDict setObject:value==nil?@"":value forKey:@"reasonCode"];
        }
        else if([[dict objectForKey:@"name"] isEqualToString:[appdelegate copyEnglishTextForKey:@"PASSENGER_INFORMATION"]]) {
            
            NSDictionary *cusDict = [dict objectForKey:@"singleEvents"];
            
            NSString *testViewValue =  [cusDict objectForKey:[appdelegate copyEnglishTextForKey:@"LANGUAGE"]];
            NSString *value;
            NSString *selectedValue = [cusDict objectForKey:[appdelegate copyEnglishTextForKey:@"PASSENGER_MAKES_CLAIM"]];
            int index1 = [[[selectedValue componentsSeparatedByString:@"|"] firstObject] intValue];
            
            [finalRequirementDict setObject:[NSNumber numberWithInt:1 + index1] forKey:@"requirmentTypeCode"];
            
            [finalDict setObject:reportId forKey:@"requestID"];
            
            if([testViewValue containsString:@"-1"]){
                
                NSString *other = [testViewValue substringFromIndex:3];
                
                value = [[other componentsSeparatedByString:@"||"] firstObject];
                
            } else {
                value = [[testViewValue componentsSeparatedByString:@"||"] firstObject];
            }
            
            NSString *countryOfResidence =  [cusDict objectForKey:[appdelegate copyEnglishTextForKey:@"COUNTRY_OF_RESIDENCE"]];
            NSString *residenceValue;
            
            if([testViewValue containsString:@"-1"]){
                
                NSString *other1 = [testViewValue substringFromIndex:3];
                
                residenceValue = [[other1 componentsSeparatedByString:@"||"] firstObject];
                
            }else {
                residenceValue = [[countryOfResidence componentsSeparatedByString:@"||"] firstObject];
            }
            
            NSString *documentType = customer.docType;
            
            NSString *doctype;
            NSString *index;
            if([documentType containsString:@"-1"]){
                
                NSString *other1 = [documentType substringFromIndex:3];
                
                doctype = [[other1 componentsSeparatedByString:@"||"] firstObject];
                index = [LTCUSDropdownData getIndexValue:[appdelegate copyEnglishTextForKey:@"DOCUMENT_TYPE"] atIndex:[doctype integerValue] forDocType:@"LAN"];
                
                
            } else {
                doctype = [[documentType componentsSeparatedByString:@"||"] firstObject];
                index = [LTCUSDropdownData getIndexValue:[appdelegate copyEnglishTextForKey:@"DOCUMENT_TYPE"] atIndex:[doctype integerValue] forDocType:@"LAN"];
            }
            
            NSString * loyaltyCard = [cusDict objectForKey:[appdelegate copyEnglishTextForKey:@"LANPASS"]];
            
            if([loyaltyCard isEqualToString:@"YES"]) {
                loyaltyCard = @"SI";
            } else {
                loyaltyCard = @"NO";
            }
            
            NSString *docNumber = customer.docNumber;
            if(docNumber == nil || [docNumber isEqualToString:@""]) {
                docNumber = customer.freqFlyerNum;
            }
            
            NSMutableDictionary *contactInfo = [[NSMutableDictionary alloc]init];
            [contactInfo setObject:customer.firstName forKey:@"firstName"];
            [contactInfo setObject:customer.lastName forKey:@"lastName"];
            [contactInfo setObject:customer.secondLastName != nil ? customer.secondLastName:@"" forKey:@"secondLastName"];
            [contactInfo setObject:docNumber != nil ? docNumber:@"" forKey:@"documentNumber"];
            [contactInfo setObject:@"0" forKey:@"documentType"];
            [contactInfo setObject:value forKey:@"isoLanguageCode"];
            [contactInfo setObject:[cusDict objectForKey:[appdelegate copyEnglishTextForKey:@"ADDRESS"]] forKey:@"addres"];
            [contactInfo setObject:[cusDict objectForKey:[appdelegate copyEnglishTextForKey:@"EMAIL"]] != nil ? [cusDict objectForKey:[appdelegate copyEnglishTextForKey:@"EMAIL"]]:@"" forKey:@"email"];
            [contactInfo setObject:[cusDict objectForKey:[appdelegate copyEnglishTextForKey:@"PHONE_NUMBER"]] != nil ?[cusDict objectForKey:[appdelegate copyEnglishTextForKey:@"PHONE_NUMBER"]]:@"0" forKey:@"phoneNumber"];
            [contactInfo setObject:residenceValue forKey:@"isoCoutryCode"];
            [contactInfo setObject:loyaltyCard forKey:@"fidelity"];
            [finalDict setObject:contactInfo forKey:@"customerInformation"];
            
            NSDictionary *seatDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [cusDict objectForKey:[appdelegate copyEnglishTextForKey:@"SEAT_LETTER"]], @"column",
                                      [cusDict objectForKey:[appdelegate copyEnglishTextForKey:@"SEAT_ROW"]], @"row", nil];
            [finalDict setObject:seatDict forKey:@"seat"];
        }
    }
    
    [finalDict setObject:finalRequirementDict forKey:@"requirementIdentification"];
    
    CUSImages *cusImages = cusReport.reportCusImages;
    
    NSMutableDictionary *imagesDict = [NSMutableDictionary dictionary];
    
    if(nil != cusImages.image1 && [cusImages.image1 length] > 0) {
        [imagesDict setObject:cusImages.image1 forKey:@"fileName1"];
    }
    if((nil != cusImages.image2 && [cusImages.image2 length] > 0)) {
        [imagesDict setObject:cusImages.image2 forKey:@"fileName2"];
    }
    if(nil != cusImages.image3 && [cusImages.image3 length] > 0) {
        [imagesDict setObject:cusImages.image3 forKey:@"fileName3"];
    }
    if([[imagesDict allKeys] count] > 0) {
        [finalDict setObject:[NSNumber numberWithInt:1] forKey:@"withAttachment"];
    } else {
        [finalDict setObject:[NSNumber numberWithInt:0] forKey:@"withAttachment"];
    }
    
    int languageString = [appdelegate currentLanguage];
    if(languageString == 3)
        [finalDict setObject:@"pt" forKey:@"tabletLanguage"];
    else
        [finalDict setObject:@"es" forKey:@"tabletLanguage"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalDict options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    return jsonString;
}

+(NSDictionary*)getFormCUSReportForDictionary:(NSMutableDictionary*)flightRoasterDict CUSReport:(CusReport*)report {
    
    NSArray *results = [report.reportGroup array];
    
    if ([results count]>0) {
        NSMutableArray *grpArray = [NSMutableArray array];
        for (Groups *group in [report.reportGroup array]) {
            if(nil != group.name ) {
                NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] init];
                [grpArray addObject:groupDict];
                
                [groupDict setObject:group.name forKey:@"name"];
                
                NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *eventDict2 = [[NSMutableDictionary alloc] init];
                
                for (Events *event in [group.groupOccourences array])
                {
                    
                    if ([event.isMultiple boolValue]) {
                        NSMutableArray *rowArray = [[NSMutableArray alloc] init];
                        for (Row *row in [event.eventsRow array]) {
                            NSMutableDictionary *rowDict = [[NSMutableDictionary alloc] init];
                            for (Contents *content in [row.rowContent array]) {
                                //DLog(@"%@  %@",content.name,content.selectedValue);
                                [rowDict setValue:content.selectedValue forKey:content.name];
                            }
                            [rowArray addObject:rowDict];
                            
                        }
                        [eventDict setValue:rowArray forKey:event.name];
                        [groupDict setObject:eventDict forKey:@"multiEvents"];
                    }else{
                        Row *row = [[event.eventsRow array] objectAtIndex:0];
                        for (Contents *content in [row.rowContent array]) {
                            [eventDict2 setValue:content.selectedValue forKey:content.name];
                        }
                        [groupDict setObject:eventDict2 forKey:@"singleEvents"];
                    }
                    
                    
                    
                    // DLog(@"%@",event.name);
                    
                }
            }
        }
        
        if(nil == flightRoasterDict){
            flightRoasterDict = [[NSMutableDictionary alloc] init];
        }
        [flightRoasterDict setObject:grpArray forKey:@"groups"];
        
    }
    
    return flightRoasterDict;
}

+(NSMutableArray *)getcusCustomersStatus1 :(FlightRoaster*)flightRoster{
    NSMutableArray *array = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:999],[NSNumber numberWithInt:999],[NSNumber numberWithInt:999],[NSNumber numberWithInt:999], nil];
    
    if([array containsObject:[NSNumber numberWithInt:999]]){
        [array removeObject:[NSNumber numberWithInt:999]];
    }
    return array;
}

+(NSMutableArray *)getcusCustomersStatus :(FlightRoaster*)flightRoster{
    NSMutableArray *array = [NSMutableArray arrayWithObjects:[NSMutableString stringWithString:@""],[NSMutableString stringWithString:@""],[NSMutableString stringWithString:@""],[NSMutableString stringWithString:@""], nil];
    
    return array;
}

+(NSMutableDictionary *)getCusFlightDict :(NSDictionary*)flightKeyDict forReportId:(NSString*)cusreportId{
    NSMutableDictionary *statusDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *statusArray = [[NSMutableArray alloc] init];
    [statusDict setObject:statusArray forKey:@"status"];
    [statusDict setObject:[[flightKeyDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"] forKey:@"flightNumber"];
    NSDateFormatter *fr = [[NSDateFormatter alloc] init];
    [fr setDateFormat:DATEFORMAT];
    NSString *date;
    
    if([[[flightKeyDict objectForKey:@"flightKey"] objectForKey:@"flightDate"] isKindOfClass:[NSString class]]){
        date = [[flightKeyDict objectForKey:@"flightKey"] objectForKey:@"flightDate"];
    }else {
        date = [fr stringFromDate:[[flightKeyDict objectForKey:@"flightKey"] objectForKey:@"flightDate"]];
    }
    [statusDict setObject:date forKey:@"flightDate"];
    //[statusDict setObject:[[flightKeyDict objectForKey:@"flightKey"] objectForKey:@"suffix"] forKey:@"suffix"];
    [statusDict setObject:[[flightKeyDict objectForKey:@"flightKey"] objectForKey:@"suffix"] forKey:@"suffix"];
    [statusDict setObject:[[flightKeyDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"] forKey:@"flightOperator"];
    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
    [dict1 setObject:@"CUS" forKey:@"reportName"];
    [dict1 setObject:[[flightKeyDict objectForKey:@"flightKey"] objectForKey:@"reportId"] forKey:@"reportId"];
    [statusArray addObject:dict1];
    NSMutableDictionary *finalDict = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObject:statusDict] forKey:@"flights"];
    return finalDict;
}
#pragma mark CUS DB Updations
+(void)updateCUSimageURL: (NSString*)imageUri withFlightInfo:(NSDictionary *)dict forReportid:(NSString*)reportId {
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    
    NSDate *fDate;
    
    if([[dict objectForKey:@"flightDate"] isKindOfClass:[NSString class]]){
        NSString *fDateString = [dict objectForKey:@"flightDate"];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        
        fDate = [dateFormat3 dateFromString:fDateString];
    }else{
        fDate = [dict objectForKey:@"flightDate"];
        
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    
    if([results count]>0){
        FlightRoaster *flightRoster = [results objectAtIndex:0];
        NSString *reportId = [dict objectForKey:@"customerId"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerId == %@",reportId];
        
        NSArray *legsArray = [flightRoster.flightInfoLegs array];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];// = [[flightRoster.customerInfo allObjects] filteredArrayUsingPredicate:predicate];
        
        for (int i=0; i<legsArray.count; i++) {
            Legs *leg = (Legs *) [legsArray objectAtIndex:i];
            NSArray *customerArray = [[leg legCustomer] array];
            [array addObjectsFromArray:customerArray];
        }
        
        NSArray *finalCustomerArray = [array filteredArrayUsingPredicate:predicate];
        
        if([finalCustomerArray count]>0){
            Customer *customer = [finalCustomerArray objectAtIndex:0];
            predicate= [NSPredicate predicateWithFormat:@"reportId==%@",reportId];
            CusReport *report = [[[customer.cusCusReport array] filteredArrayUsingPredicate:predicate] firstObject];

            [report setImageLoadUrl:imageUri];
            //[report setStatus:[NSNumber numberWithInt:inqueue]];
            [managedObjectContext save:nil];
        }
    }
}
+(int)updateCUSStatus: (NSDictionary*)cusResponce status:(enum status)status flightDict:(NSDictionary*)flightKeyDict forReportId:(NSString*)CUSreportId {
    int numOfAttempts =0;
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSDictionary *dict = [flightKeyDict objectForKey:@"flightKey"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    
    NSDate *fDate;
    if([[dict objectForKey:@"flightDate"] isKindOfClass:[NSString class]]){
        NSString *fDateString = [dict objectForKey:@"flightDate"];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        
        fDate = [dateFormat3 dateFromString:fDateString];
    }else{
        fDate = [dict objectForKey:@"flightDate"];
        
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    
    request = nil;
    
    if([results count]>0){
        NSString *reportId = [dict objectForKey:@"customerId"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerId == %@",reportId];
        FlightRoaster *flightRoster = [results objectAtIndex:0];
        
        NSArray *legsArray = [flightRoster.flightInfoLegs array];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];// =
        
        for (int i=0; i<legsArray.count; i++) {
            Legs *leg = (Legs *) [legsArray objectAtIndex:i];
            NSArray *customerArray = [[leg legCustomer] array];
            [array addObjectsFromArray:customerArray];
        }
        
        NSArray *finalCustomerArray = [array filteredArrayUsingPredicate:predicate];
        
        if([finalCustomerArray count]>0){
            
            Customer *customer = [finalCustomerArray objectAtIndex:0];
            predicate= [NSPredicate predicateWithFormat:@"reportId==%@",CUSreportId];
            CusReport *report = [[[customer.cusCusReport array] filteredArrayUsingPredicate:predicate] firstObject];
            if(status == eror ||status == wf||status == inqueue)
            {
                int attempts = [report.attempts intValue];
                
                [report setAttempts:[NSNumber numberWithInt:++attempts]];
                numOfAttempts = [report.attempts intValue];
            }
            [report setStatus:[NSNumber numberWithInt:status]];
            NSLog(@"CUS STATUS UPDATED TO : %d",status);
            if(![managedObjectContext save:&error1]) {
            
            }
            
            if(status == eror|| status == ok) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_FLIGHTLIST object:nil userInfo:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCUSTable" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackViewRefresh" object:nil];
                //});
            }
        }
    }
    
    return numOfAttempts;
}
+(int)updateCUSStatusIndividual: (NSDictionary*)cusResponce status:(enum status)status flightDict:(NSDictionary*)flightKeyDict forReportId:(NSString*)CUSreportId {
    int numOfAttempts =0;
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSDictionary *dict = [flightKeyDict objectForKey:@"flightKey"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    
    NSDate *fDate;
    if([[dict objectForKey:@"flightDate"] isKindOfClass:[NSString class]]){
        NSString *fDateString = [dict objectForKey:@"flightDate"];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        
        fDate = [dateFormat3 dateFromString:fDateString];
    }else{
        fDate = [dict objectForKey:@"flightDate"];
        
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    
    request = nil;
    
    if([results count]>0){
        NSString *reportId = [dict objectForKey:@"customerId"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerId == %@",reportId];
        FlightRoaster *flightRoster = [results objectAtIndex:0];
        
        NSArray *legsArray = [flightRoster.flightInfoLegs array];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];// =
        
        for (int i=0; i<legsArray.count; i++) {
            Legs *leg = (Legs *) [legsArray objectAtIndex:i];
            NSArray *customerArray = [[leg legCustomer] array];
            [array addObjectsFromArray:customerArray];
        }
        
        NSArray *finalCustomerArray = [array filteredArrayUsingPredicate:predicate];
        
        if([finalCustomerArray count]>0){
            
            Customer *customer = [finalCustomerArray objectAtIndex:0];
            predicate= [NSPredicate predicateWithFormat:@"reportId==%@",CUSreportId];
            CusReport *report = [[[customer.cusCusReport array] filteredArrayUsingPredicate:predicate] firstObject];
            if(status == eror ||status == wf||status == inqueue)
            {
                int attempts = [report.attempts intValue];
                
                [report setAttempts:[NSNumber numberWithInt:++attempts]];
                numOfAttempts = [report.attempts intValue];
            }
            [report setStatus:[NSNumber numberWithInt:status]];
            NSLog(@"CUS STATUS UPDATED TO : %d",status);
            if(![managedObjectContext save:&error1]) {
                
            }
            
            if(status == eror|| status == ok) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_FLIGHTLIST object:nil userInfo:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCUSTable" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackViewRefresh" object:nil];
                //});
            }
        }
    }
    
    return numOfAttempts;
}

@end
