    //
//  SavePublicationData.m
//  Nimbus2
//
//  Created by 720368 on 8/22/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "SavePublicationData.h"

#import "NSDate+Utils.h"

@implementation SavePublicationData

+(void)savePublicationDetailsFromDict:(NSDictionary*)publicationDict {
    
    NSDictionary *dict = [publicationDict objectForKey:@"flightRosterBeanType"];//briefingInformation

    NSDictionary *breifingDict = [dict objectForKey:@"briefingData"];
    
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [dateFormat3 dateFromString:[dict checkNilValueForKey:@"flightDate"]],[dict checkNilValueForKey:@"suffix"],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"airlineCode"]];
        [request setPredicate:predicate];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count]>0) {
            FlightRoaster *flight = [results objectAtIndex:0];
            NSLog(@">>>>>>%@%@", flight.airlineCode, flight.flightNumber);
            flight.lastSynchTime = [[NSDate date] toLocalTime];
            
            NSArray *publicationArray = [breifingDict objectForKey:@"publications"];
            if ([[flight.flightPublication array] count]>0) {

                NSInteger Count=[[flight.flightPublication array] count];
                for (NSInteger i=Count-1; i>=0; i--) {
                    Publication *pub = [[flight.flightPublication array] objectAtIndex:i];
                    [flight removeFlightPublicationObject:pub];
                    [flight.managedObjectContext deleteObject:pub];
                }
            }
            for (int i = 0; i<[publicationArray count]; i++) {
                NSDictionary *pubDict = [publicationArray objectAtIndex:i];
                Publication *pub = [NSEntityDescription insertNewObjectForEntityForName:@"Publication" inManagedObjectContext:managedObjectContext];
                pub.heading = [pubDict objectForKey:@"title"];
                pub.details = [pubDict objectForKey:@"content"];
                [flight addFlightPublicationObject:pub];
            }
            
            NSDictionary *gnattDict = [breifingDict objectForKey:@"ganttData"];
            if ([[gnattDict allKeys] count] > 0) {
                flight.briefingStartTime = [NSDate dateFromString:[gnattDict objectForKey:@"briefingShowUp"]dateFormatType:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss];
                flight.briefingEndTime = [NSDate dateFromString:[gnattDict objectForKey:@"briefingEnd"] dateFormatType:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss];
                flight.crewEntryTime = [NSDate dateFromString:[gnattDict objectForKey:@"crewBoarding"] dateFormatType:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss];
                flight.passengerEntryTime = [NSDate dateFromString:[gnattDict objectForKey:@"passengerBoarding"] dateFormatType:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss];
                flight.lastSynchTime = [[NSDate date] toLocalTime];
            }
            
            flight.isPublicationSynched = @(YES);
            
            NSError *error;
            if (![managedObjectContext save:&error]) {
                NSLog(@"not save");
            }
            
            if ([[dict checkNilValueForKey:@"legs"] isKindOfClass:[NSArray class]]) {
                NSArray *legsArray = [dict checkNilValueForKey:@"legs"];
                for (int j = 0; j < [legsArray count]; j++) {
                    NSDictionary *legsDict = [legsArray objectAtIndex:j];
                    NSArray *array = [flight.flightInfoLegs array];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"origin = %@ AND destination = %@", [legsDict checkNilValueForKey:@"origin"],[legsDict checkNilValueForKey:@"destination"]];
                    NSArray *arrarLegs = [array filteredArrayUsingPredicate:predicate];
                    if([arrarLegs count]>0) {
                        Legs *leg = [arrarLegs objectAtIndex:0];
                        if ([[legsDict checkNilValueForKey:@"crewMembers"] isKindOfClass:[NSArray class]]) {
                            
                            // crew
                            NSArray *crewMembersArray = legsDict[@"crewMembers"];
                            if(crewMembersArray && ![crewMembersArray isEqual:[NSNull null]])
                                [self addCrewForLeg:leg fromArray:crewMembersArray];
                            
                            // contingency
                            NSDictionary *contingency = legsDict[@"contingency"];
                            if(contingency && ![contingency isEqual:[NSNull null]])
                                [self processContingencyForLeg:leg fromDictionary:contingency];
                            
                            // flight phases
                            NSArray *phases = legsDict[@"phaseFlights"];
                            if(phases && ![phases isEqual:[NSNull null]])
                                [self processFlightPhasesForLeg:leg fromArray:phases];
                            
                            // meals
                            NSArray *meals = legsDict[@"serviceInformations"];
                            if(meals && ![meals isEqual:[NSNull null]])
                                [self processMealsForLeg:leg fromArray:meals];
                        }
                    }
                    
                }
            }
        }
    }
    
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"not save");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PublicationComplete" object:nil];
}

+(void)addCrewForLeg:(Legs*)leg fromArray:(NSArray*)crewMembersArray {
    
    BOOL (^crewMemberHasReport) (CrewMembers*) = ^BOOL (CrewMembers *crew) {
        
        return (crew.status.intValue == draft ||
                crew.status.intValue == inqueue ||
                crew.status.intValue == sent ||
                crew.status.intValue == received ||
                crew.status.intValue == eror ||
                crew.status.intValue == ok ||
                crew.status.intValue == ea ||
                crew.status.intValue == ee ||
                crew.status.intValue == wf);
    };
    
    @try {
        int cct = (int)[[leg.legsCrewmember array] count];
        for (int i = cct - 1; i >= 0; i--) {
            CrewMembers *crew = [[leg.legsCrewmember array] objectAtIndex:i];
            if (crew!=nil) {
                NSInteger bp = [crew.bp integerValue];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bp contains[c] %@",[NSString stringWithFormat:@"%ld",bp]];
                NSArray *result2 = [crewMembersArray filteredArrayUsingPredicate:predicate];
                
                if (result2.count == 0 && crew.isManuallyAdded.boolValue == NO && crewMemberHasReport(crew) == NO) {
                    
                    // delete crew member
                    
                    for (GADCategory *gCat in [crew.crewCategory array]) {
                        if (gCat!=nil) {
                            [crew removeCrewCategoryObject:gCat];
                            [crew.managedObjectContext deleteObject:gCat];
                        }
                        
                    }
                    crew.crewComments=nil;
                    [crew setCrewCategory:nil];
                    [leg removeLegsCrewmemberObject:crew];
                    [leg.managedObjectContext deleteObject:crew];
                }
            }
        }
        
        NSError *error;
        if (![leg.managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Handle exception %@",exception.description);
    }
    
    for (int i=0; i<[crewMembersArray count]; i++) {
        NSDictionary *crewDict = [crewMembersArray objectAtIndex:i];
        [self saveCrewForleg:leg fromDicr:crewDict];
    }
}

+(void)saveCrewForleg:(Legs*)leg fromDicr:(NSDictionary*)crewDict{
    
    NSArray *array = [leg.legsCrewmember array];
    long long bp=[[crewDict checkNilValueForKey:@"bp"] longLongValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bp == %@ OR bp==%@", [NSString stringWithFormat:@"%lld",bp],[crewDict checkNilValueForKey:@"bp"]];
    NSArray *arrayCrew = [array filteredArrayUsingPredicate:predicate];
    
    CrewMembers *crew;
    BOOL isExistsCrew = NO;
    // Modified by Palash
    if([arrayCrew count]>0) {
        isExistsCrew = YES;
        crew=[arrayCrew objectAtIndex:0];
        
    }else {
        crew  = [NSEntityDescription insertNewObjectForEntityForName:@"CrewMembers" inManagedObjectContext:leg.managedObjectContext];
    }
    
    [leg.managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    crew.activeRank = [crewDict objectForKey:@"activeRank"];
    crew.bp = [crewDict objectForKey:@"bp"];
    crew.crewID = [crewDict objectForKey:@"id"];
    crew.firstName = [crewDict objectForKey:@"firstName"];
    crew.lastName = [crewDict objectForKey:@"lastName"];
    
    if ([crewDict objectForKey:@"licenseNumber"] !=nil && ![[crewDict objectForKey:@"licenseNumber"] isEqual:[NSNull null]]){
        crew.licenceNo = [crewDict objectForKey:@"licenseNumber"];
    }
    crew.category = [crewDict objectForKey:@"category"];
    if ([crewDict objectForKey:@"specialRank"] !=nil && ![[crewDict objectForKey:@"specialRank"] isEqual:[NSNull null]]){

        crew.specialRank = [crewDict objectForKey:@"specialRank"];
    }
    if ([crewDict objectForKey:@"licenseExpDate"] !=nil && ![[crewDict objectForKey:@"licenseExpDate"] isEqual:[NSNull null]]){
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"dd-MM-yyyy";
        crew.licencceDate = [df dateFromString:[crewDict objectForKey:@"licenseExpDate"]];
    }
    
    NSDictionary *gadinfo = [crewDict objectForKey:@"gadInformation"];
    crew.expectedGAD = [gadinfo objectForKey:@"goal"];
    crew.filledGAD = [gadinfo objectForKey:@"received"];
    crew.realizedGAD = [gadinfo objectForKey:@"realized"];
    
    [leg addLegsCrewmemberObject:crew];
    
    NSError * error;
    if (![leg.managedObjectContext save:&error]) {
        NSLog(@"Error is saving crew %@",[error localizedDescription]);
    }
}

+ (void)saveManualCrewFromDict:(NSMutableDictionary*)crewDict{
    
    NSMutableDictionary *dict = [[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"flightKey"];
    
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
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [dict valueForKey:@"flightDate"],[dict checkNilValueForKey:@"suffix"],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"airlineCode"]];
        [request setPredicate:predicate];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count]>0) {
            FlightRoaster *flight = [results objectAtIndex:0];
            for (Legs *leg in [flight.flightInfoLegs array]) {
                NSArray *array = [leg.legsCrewmember array];
                long long bp=[[crewDict checkNilValueForKey:@"bp"] longLongValue];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bp == %@ OR bp==%@", [NSString stringWithFormat:@"%lld",bp],[crewDict checkNilValueForKey:@"bp"]];
                NSArray *arrayCrew = [array filteredArrayUsingPredicate:predicate];
                
                CrewMembers *crew;
                BOOL isExistsCrew = NO;
                // Modified by Palash
                if([arrayCrew count]>0) {
                    isExistsCrew = YES;
                    crew=[arrayCrew objectAtIndex:0];
                    
                }else {
                    crew  = [NSEntityDescription insertNewObjectForEntityForName:@"CrewMembers" inManagedObjectContext:leg.managedObjectContext];
                }
                
                [leg.managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                
                crew.activeRank = [crewDict objectForKey:@"activeRank"];
                crew.bp = [crewDict objectForKey:@"bp"];
                crew.crewID = [crewDict objectForKey:@"id"];
                crew.firstName = [crewDict objectForKey:@"firstName"];
                crew.lastName = [crewDict objectForKey:@"lastName"];
                crew.isManuallyAdded  = [NSNumber numberWithBool:YES];
                
                if ([crewDict objectForKey:@"licenseNumber"] !=nil && ![[crewDict objectForKey:@"licenseNumber"] isEqual:[NSNull null]]){
                    crew.licenceNo = [crewDict objectForKey:@"licenseNumber"];
                }
                crew.category = [crewDict objectForKey:@"category"];
                if ([crewDict objectForKey:@"specialRank"] !=nil && ![[crewDict objectForKey:@"specialRank"] isEqual:[NSNull null]]){
                    
                    crew.specialRank = [crewDict objectForKey:@"specialRank"];
                }
                if ([crewDict objectForKey:@"licenseExpDate"] !=nil && ![[crewDict objectForKey:@"licenseExpDate"] isEqual:[NSNull null]]){
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    df.dateFormat = @"dd-MM-yyyy";
                    crew.licencceDate = [df dateFromString:[crewDict objectForKey:@"licenseExpDate"]];
                }
                NSDictionary *gadinfo = [crewDict objectForKey:@"gadInformation"];
                crew.expectedGAD = [gadinfo objectForKey:@"goal"];
                crew.filledGAD = [gadinfo objectForKey:@"received"];
                crew.realizedGAD = [gadinfo objectForKey:@"realized"];
                
                [leg addLegsCrewmemberObject:crew];
            }
        }
    
    }
    
    NSError * error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error is saving crew %@",[error localizedDescription]);
    }

}


+ (void)processContingencyForLeg:(Legs*)leg fromDictionary:(NSDictionary*)dict {
    
    if ([[dict objectForKey:@"services"] count]==0 || [dict objectForKey:@"type"]==[NSNull null]) {
        return;
    }
    
    while(leg.legUtility.count > 0) {
        UtilityType *utility = [leg.legUtility firstObject];
        [leg removeLegUtilityObject:utility];
        [leg.managedObjectContext deleteObject:utility];
    }
    
    UtilityType *utility = [NSEntityDescription insertNewObjectForEntityForName:@"UtilityType" inManagedObjectContext:leg.managedObjectContext];
    utility.name = @"contingency";
    
    SubUtility *sUtility = [NSEntityDescription insertNewObjectForEntityForName:@"SubUtility" inManagedObjectContext:leg.managedObjectContext];
    sUtility.name = dict[@"type"];
    
    NSArray *services = dict[@"services"];
    
    for(NSDictionary *serviceDict in services) {
        
        UtilityDetails *uDetails = [NSEntityDescription insertNewObjectForEntityForName:@"UtilityDetails" inManagedObjectContext:leg.managedObjectContext];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        uDetails.time = [df dateFromString:serviceDict[@"date"]];
        uDetails.desc = serviceDict[@"cause"];
        
        NSArray *items = @[@"phoneCard", @"snack", @"meal", @"transfer", @"hotel"];
        
        for(NSString *itemName in items) {
            
            UtilityItems *uItem = [NSEntityDescription insertNewObjectForEntityForName:@"UtilityItems" inManagedObjectContext:leg.managedObjectContext];
            uItem.itemType = itemName;
            uItem.itemValue = serviceDict[itemName];
            
            [uDetails addUtilItemObject:uItem];
        }
        
        [sUtility addSubToDetailObject:uDetails];
    }
    
    [utility addUtilSubUtilObject:sUtility];
    
    [leg addLegUtilityObject:utility];
}

+ (void)processFlightPhasesForLeg:(Legs*)leg fromArray:(NSArray*)array {
    
    while(leg.legHeading.count > 0) {
        NoticeHead *phase = [leg.legHeading firstObject];
        [leg removeLegHeadingObject:phase];
        [leg.managedObjectContext deleteObject:phase];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    for(NSDictionary *phaseDict in array) {

        NoticeHead *phase = [NSEntityDescription insertNewObjectForEntityForName:@"NoticeHead" inManagedObjectContext:leg.managedObjectContext];
        phase.noticeHeading = phaseDict[@"name"];
        
        NSArray *roadMaps = phaseDict[@"roadMaps"];
        
        for(NSDictionary *rmDict in roadMaps) {
            
            Notice *road = [NSEntityDescription insertNewObjectForEntityForName:@"Notice" inManagedObjectContext:leg.managedObjectContext];
            road.heading = rmDict[@"category"];
            road.shortDesc = rmDict[@"title"];
            road.content = rmDict[@"content"];
            if(![rmDict[@"startDate"] isEqual:[NSNull null]])
                road.startDate = [df dateFromString:rmDict[@"startDate"]];
            if(![rmDict[@"finishDate"] isEqual:[NSNull null]])
                road.endDate = [df dateFromString:rmDict[@"finishDate"]];
            
            [phase addHeadNoticeObject:road];
        }
        
        [leg addLegHeadingObject:phase];
    }
}

+ (void)processMealsForLeg:(Legs*)leg fromArray:(NSArray*)array {
    
    // @NOTE(diego_cath): as per LAN's request, this will remain hidden until further instructions. April 7th 2016
    
    return;
    
    while(leg.specialMealInfoHead.count > 0) {
        SpecialMealInfoHead *head = [leg.specialMealInfoHead firstObject];
        [leg removeSpecialMealInfoHeadObject:head];
        [leg.managedObjectContext deleteObject:head];
    }
    
    for(NSDictionary *dict in array) {
        SpecialMealInfoHead *head = [NSEntityDescription insertNewObjectForEntityForName:@"SpecialMealInfoHead" inManagedObjectContext:leg.managedObjectContext];
        [leg addSpecialMealInfoHeadObject:head];
        
        head.cabinCode = dict[@"cabinCode"];
        if(![dict[@"typeES"] isEqual:[NSNull null]]) {
            head.typeES = dict[@"typeES"];
        }
        if(![dict[@"typePT"] isEqual:[NSNull null]]) {
            head.typeES = dict[@"typePT"];
        }
        
        for(NSDictionary *detailDict in dict[@"services"]) {
            SpecialMealInfoDetail *detail = [NSEntityDescription insertNewObjectForEntityForName:@"SpecialMealInfoDetail" inManagedObjectContext:leg.managedObjectContext];
            [head addMealDetailObject:detail];
            
            detail.number = @([detailDict[@"count"] intValue]);
            detail.code = detailDict[@"code"];
            detail.itemDescription = detailDict[@"description"];
        }
    }
}

+(NSMutableDictionary*)getDetailsForFlight:(NSDictionary*)flightDict {
    NSLog(@"flightDict: %@",flightDict);
    NSMutableDictionary *detailsDict = [[NSMutableDictionary alloc] init];
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
    if([results count]>0) {
        currentUser = [results objectAtIndex:0];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [dict checkNilValueForKey:@"flightDate"],[dict checkNilValueForKey:@"suffix"],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count]>0) {
            FlightRoaster *flight = [results objectAtIndex:0];
            if ([flight.isPublicationSynched boolValue]) {
            
                // flight details
                
                if(flight.briefingStartTime)
                    [detailsDict setObject:flight.briefingStartTime forKey:@"startTime"];
                if(flight.briefingEndTime)
                    [detailsDict setObject:flight.briefingEndTime forKey:@"endTime"];
                if(flight.crewEntryTime)
                    [detailsDict setObject:flight.crewEntryTime forKey:@"crewEntryTime"];
                if(flight.passengerEntryTime)
                    [detailsDict setObject:flight.passengerEntryTime forKey:@"passengerEntryTime"];
            }
            
            if(flight.gateNumber) {
                [detailsDict setObject:flight.gateNumber forKey:@"gate"];
            }
            
            // publications
            NSMutableArray *publicationsArray = [[NSMutableArray alloc] init];
            [detailsDict setObject:publicationsArray forKey:@"Publication"];
            if ([[flight.flightPublication array] count]>0) {
                for (int i=0; i<[[flight.flightPublication array] count]; i++) {
                    Publication *pub = [[flight.flightPublication array] objectAtIndex:i];
                    NSMutableDictionary *pubdict = [[NSMutableDictionary alloc] init];
                    [pubdict setObject:pub.heading forKey:@"heading"];
                    [pubdict setObject:pub.details forKey:@"details"];
                    [publicationsArray addObject:pubdict];
                }
            }
            
            // legs
            
            NSMutableArray *legsArray = [[NSMutableArray alloc] init];
            [detailsDict setObject:legsArray forKey:@"legs"];
            
            NSOrderedSet *legs = flight.flightInfoLegs;
            for(Legs *leg in legs) {
                NSMutableDictionary *legDict = [[NSMutableDictionary alloc] init];
                [legsArray addObject:legDict];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"contingency"];
                UtilityType *contingencies = [[leg.legUtility filteredOrderedSetUsingPredicate:predicate] firstObject];
                SubUtility *contingencyDetails = [contingencies.utilSubUtil anyObject];
                
                // contingency
                
                if(contingencyDetails) {
                    NSMutableArray *servicesArray = [[NSMutableArray alloc] init];
                    NSDictionary *contingencyDict = @{@"type" : contingencyDetails.name, @"services" : servicesArray};
                    [legDict setObject:contingencyDict forKey:@"contingency"];
                    
                    for(UtilityDetails *details in contingencyDetails.subToDetail) {
                        
                        NSMutableDictionary *serviceDict = [[NSMutableDictionary alloc] init];
                        [servicesArray addObject:serviceDict];
                        
                        if(details.time) {
                            [serviceDict setObject:details.time forKey:@"date"];
                        }
                        if(details.desc) {
                            [serviceDict setObject:details.desc forKey:@"cause"];
                        }
                        
                        for(UtilityItems *item in details.utilItem) {
                            [serviceDict setObject:item.itemValue forKey:item.itemType];
                        }
                    }
                }
                
                // road maps
                
                NSMutableArray *phasesArray = [[NSMutableArray alloc] init];
                [legDict setObject:phasesArray forKey:@"flightPhases"];
                
                for(NoticeHead *noticeHead in leg.legHeading) {
                    
                    NSMutableArray *details = [[NSMutableArray alloc] init];
                    NSDictionary *phaseDict = @{@"phase" : noticeHead.noticeHeading, @"details" : details};
                    [phasesArray addObject:phaseDict];
                    
                    for(Notice *notice in noticeHead.headNotice) {
                        
                        [details addObject:@{@"category" : notice.heading, @"title" : notice.shortDesc, @"content" : notice.content, @"startDate" : notice.startDate, @"endDate" : notice.endDate}];
                    }
                }
                
                // meals
                
                NSMutableArray *mealsArray = [[NSMutableArray alloc] init];
                [legDict setObject:mealsArray forKey:@"mealsInfo"];
                
                for(SpecialMealInfoHead *head in leg.specialMealInfoHead) {
                    
                    NSMutableDictionary *headDict = [[NSMutableDictionary alloc] init];
                    [mealsArray addObject:headDict];
                    headDict[@"cabinCode"] = head.cabinCode;
                    headDict[@"typeES"] = head.typeES;
                    headDict[@"typePT"] = head.typePT;
                    NSMutableArray *details = [[NSMutableArray alloc] init];
                    headDict[@"services"] = details;
                    
                    for(SpecialMealInfoDetail *info in head.mealDetail) {
                        
                        NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
                        [details addObject:infoDict];
                        infoDict[@"description"] = info.itemDescription;
                        infoDict[@"code"] = info.code;
                        infoDict[@"count"] = info.number;
                    }
                }
            }
        }
    }
    
    return detailsDict;
}




@end
