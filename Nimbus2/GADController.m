//
//  GADController.m
//  Nimbus2
//
//  Created by 720368 on 8/26/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "GADController.h"
#import "AppDelegate.h"
#import "NSMutableDictionary+ChekVal.h"
#import "AllDb.h"
#import "LTSingleton.h"
#import "UserInformationParser.h"

@implementation GADController

+(void)saveGaDDict:(NSDictionary *)dict {
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [dict checkNilValueForKey:@"flightDate"],[dict checkNilValueForKey:@"suffix"],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count]>0) {
            FlightRoaster *flight = [results objectAtIndex:0];
            predicate=nil;
            NSDictionary *legdict = [dict objectForKey:@"leg"];
            predicate = [NSPredicate predicateWithFormat:@"origin == %@ AND destination == %@",[legdict objectForKey:@"origin"],[legdict objectForKey:@"destination"]];
            request = [[NSFetchRequest alloc]initWithEntityName:@"Legs"];
            results = [[flight.flightInfoLegs array] filteredArrayUsingPredicate:predicate];
            if ([results count]>0) {
                NSDictionary *crewDict = [legdict objectForKey:@"crew"];
                int i = 0;
                for (Legs *leg in [flight.flightInfoLegs array]) {
                    i++;
                    predicate=nil;
                    predicate = [NSPredicate predicateWithFormat:@"bp == %@",[crewDict objectForKey:@"bp"]];
                    results = [[leg.legsCrewmember array] filteredArrayUsingPredicate:predicate];
                    if ([results count]>0) {
                        CrewMembers *crew = [results firstObject];
                        NSArray *gadArr = [legdict objectForKey:@"GAD"];
                        
                        GADComments *gadCom = [NSEntityDescription insertNewObjectForEntityForName:@"GADComments" inManagedObjectContext:managedObjectContext];
                        BOOL isCommentChanged = NO;
                        if ([crew.status integerValue]==0) {
                            crew.status=[NSNumber numberWithInt:draft];
                        }
                        crew.synchDate = [NSDate date];
                        for (int i=0; i<[gadArr count]; i++) {
                            GADCategory *gadCat = [NSEntityDescription insertNewObjectForEntityForName:@"GADCategory" inManagedObjectContext:managedObjectContext];
                            
                            NSDictionary *gadValDic = [gadArr objectAtIndex:i];
                            
                            for (NSString *name in [gadValDic allKeys]) {
                                if ([name isEqualToString:@"ObserverComment"]) {
                                    gadCom.observerComments= [gadValDic objectForKey:name];
                                    isCommentChanged = YES;
                                    continue;
                                } else if([name isEqualToString:@"Signatur_Observer"]) {
                                    gadCom.observerSign = [gadValDic objectForKey:name];
                                    isCommentChanged = YES;
                                    continue;
                                } else if([name isEqualToString:@"TCComment"]) {
                                    gadCom.tcComments = [gadValDic objectForKey:name];
                                    isCommentChanged = YES;
                                    continue;
                                } else if([name isEqualToString:@"Signature_TC"]) {
                                    gadCom.tcSign = [gadValDic objectForKey:name];
                                    isCommentChanged = YES;
                                    
                                    continue;
                                } else {
                                    gadCat.name=name;
                                    [crew addCrewCategoryObject:gadCat];
                                    NSDictionary *valDict = [[gadValDic objectForKey:name] firstObject];
                                    for (NSString *key in [valDict allKeys]) {
                                        GADValue *gadVal = [NSEntityDescription insertNewObjectForEntityForName:@"GADValue" inManagedObjectContext:managedObjectContext];
                                        gadVal.value = key;
                                        gadVal.selectedalue = [valDict objectForKey:key];
                                        [gadCat addCategoryValueObject:gadVal];
                                    }
                                }
                            }
                        }
                        
                        if (isCommentChanged) {
                            [crew setCrewComments:gadCom];
                        }
                    }
                }
            }
            
            NSError *savingError = nil;
            
            if ([managedObjectContext save:&savingError]) {
                NSLog(@"Successfully saved the context.");
                //[self updateCrewMemberStatusFormInterface:draft  uniqueBP:[[legdict objectForKey:@"crew"] objectForKey:@"bp"] forFlight:dict];
            } else {
                NSLog(@"Failed to save the context. Error = %@", savingError);
            }
        }
    }
}

+(NSMutableDictionary *)getGADforCrew:(NSDictionary *)crewDict forFlight:(NSDictionary *)flightDic {
    
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
        NSDictionary *dict = [flightDic objectForKey:@"flightKey"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [dict checkNilValueForKey:@"flightDate"],[dict checkNilValueForKey:@"suffix"],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count]>0) {
            FlightRoaster *flight = [results objectAtIndex:0];
            int i = 0;
            for (Legs *leg in [flight.flightInfoLegs array]) {
                i++;
                predicate=nil;
                predicate = [NSPredicate predicateWithFormat:@"bp == %@",[crewDict objectForKey:@"bp"]];
                results = [[leg.legsCrewmember array] filteredArrayUsingPredicate:predicate];
                if ([results count]>0) {
                    CrewMembers *crew = [results firstObject];
                    NSMutableDictionary * gadDict  = [[NSMutableDictionary alloc]init];
                    NSMutableDictionary *crewMemberDict  = [[NSMutableDictionary alloc]init];
                    [crewMemberDict setObject:crew.bp forKey:@"bp"];
                    [crewMemberDict setObject:crew.firstName forKey:@"firstName"];
                    [crewMemberDict setObject:crew.lastName forKey:@"lastName"];
                    [crewMemberDict setObject:crew.activeRank forKey:@"activeRank"];
                    [crewMemberDict setObject:crew.status forKey:@"status"];
                    
                    //                    if([crew.status integerValue]==0 && i!=[[flight.flightInfoLegs array] count]){
                    //                        continue;
                    //                    }
                    [gadDict setObject:crewMemberDict forKey:@"crewMember"];
                    
                    NSArray * gadArray = [crew.crewCategory array];
                    Boolean stado = false;
                    if ([gadArray count]>0){
                        
                        
                        for (int i=0 ; i< [gadArray count];i++){
                            GADCategory *gadCat = [gadArray objectAtIndex:i];
                            
                            [gadDict setObject:gadCat.name forKey:gadCat.name];
                            NSDictionary * gadValueDict= [[NSMutableDictionary alloc]init];
                            
                            NSArray * gadValueArray = [gadCat.categoryValue array];
                            for (GADValue * value in gadValueArray ) {
                                [gadValueDict setValue:value.selectedalue forKey:value.value];
                                //[gadValueDict setValue:value.value forKey:@"value"];
                                stado = true;
                            }
                            [gadDict setObject:gadValueDict forKey:gadCat.name];
                            
                        }
                    }
                    if (!stado){
                        return  nil;
                    }
                    GADComments * gadComments = crew.crewComments;
                    if (gadComments .observerComments){
                        [gadDict setObject:gadComments.observerComments forKey:@"ObserverComment"];
                    }
                    if (gadComments.tcComments){
                        [gadDict setObject:gadComments.tcComments forKey:@"TCComment"];
                    }
                    if (gadComments.observerSign){
                        [gadDict setObject:gadComments.observerSign forKey:@"Signatur_Observer"];
                    }
                    if (gadComments.tcSign){
                        [gadDict setObject:gadComments.tcSign forKey:@"Signature_TC"];
                    }
                    
                    return gadDict;
                }
            }
            //Legs * leg   = [flight.flightInfoLegs objectAtIndex:[[crewDict valueForKey:@"legIndex"] intValue]];
            
            
        }
    }
    
    return nil;
}

+(void)updateCrewMemberStatusFormInterface:(STATUS)status  uniqueBP:(NSString *)bpNumber forFlight:(NSDictionary *)flightDict {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    User *currentUser;
    
    BOOL shouldPostGADNotif = NO;
    
    if([results count] > 0) {
        currentUser = [results objectAtIndex:0];
        NSDictionary *dict = [[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"flightKey"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [dict checkNilValueForKey:@"flightDate"], [dict checkNilValueForKey:@"suffix"], [dict checkNilValueForKey:@"flightNumber"], [dict checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        
        if ([results count] > 0) {
            FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
            predicate = nil;
            NSArray *legdictArr = [[flightDict valueForKey:@"gadDetail" ] objectForKey:@"legs"];
            
            NSDictionary *legDict = [legdictArr objectAtIndex:0];
            predicate = [NSPredicate predicateWithFormat:@"origin == %@ AND destination == %@",[legDict objectForKey:@"origin"],[legDict objectForKey:@"destination"]];
            results = [[flight.flightInfoLegs array] filteredArrayUsingPredicate:predicate];
            if ([results count] > 0) {
                int i=0;
                for (Legs *leg in [flight.flightInfoLegs array]) {
                    i++;
                    predicate = nil;
                    predicate = [NSPredicate predicateWithFormat:@"bp == %@",bpNumber];
                    results = [[leg.legsCrewmember array] filteredArrayUsingPredicate:predicate];
                    if ([results count] > 0) {
                        CrewMembers *crew = [results objectAtIndex:0];
                        
                        if (status) {
                            crew.synchDate = [NSDate date];
                            [crew setStatus:[NSNumber numberWithInt:status]];
                            if (status == inqueue || status == received || status == ok) {
                                shouldPostGADNotif = YES;
                            }
                            if (status == wf) {
                                int attempts = [crew.attempts intValue];
                                [crew setAttempts:[NSNumber numberWithInt:++attempts]];
                            }
                            else if(status == eror) {
                                int attempts = [crew.errorAttempts intValue];
                                [crew setErrorAttempts:[NSNumber numberWithInt:++attempts]];
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    NSError * error;
    if (![managedObjectContext save:&error]) {
        DLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
    
    if(shouldPostGADNotif) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGADList" object:nil];
    }
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
        
        if (![managedObjectContext save:&error]) {
            DLog(@"Failed to save - error: %@", [error localizedDescription]);
            return NO;
        }
    }
    else {
        return NO;
    }
    return YES;
}

+(int)getCrewmemberAttemptsCount:(NSString *)bpNumber forflight:(NSDictionary *)flightReportDict
{
    int attemptValue = 0;
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    User *currentUser;
    if([results count]>0) {
        currentUser = [results objectAtIndex:0];
        NSDictionary *dict = [[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"flightKey"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [dict checkNilValueForKey:@"flightDate"],[dict checkNilValueForKey:@"suffix"],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        
        
        if ([results count]>0) {
            FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
            predicate=nil;
            NSArray *legdictArr = [[flightReportDict valueForKey:@"gadDetail" ] objectForKey:@"legs"];
            
            NSDictionary * legDict = [legdictArr objectAtIndex:0];
            predicate = [NSPredicate predicateWithFormat:@"origin == %@ AND destination == %@",[legDict objectForKey:@"origin"],[legDict objectForKey:@"destination"]];
            //request = [[NSFetchRequest alloc]initWithEntityName:@"Legs"];
            results = [[flight.flightInfoLegs array] filteredArrayUsingPredicate:predicate];
            if ([results count]>0) {
                //NSDictionary *crewDictArr = [legdict objectForKey:@"crew"];
                
                Legs *leg = [results objectAtIndex:0];
                predicate=nil;
                predicate = [NSPredicate predicateWithFormat:@"bp == %@",bpNumber];
                results = [[leg.legsCrewmember array] filteredArrayUsingPredicate:predicate];
                if ([results count]>0) {
                    CrewMembers *crew = [results objectAtIndex:0];
                    
                    return [crew.attempts intValue];
                }
            }
        }
    }
    
    return attemptValue;
}
+(NSString *)getCrewMemberURI:(NSString *)bpNumber
{
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

+(NSArray*)getFlightLegsForFlightRoaster:(NSDictionary*)flightRoasterDict{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
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

+(NSDictionary *)getGADFormReportForCrewMemberForSynch:(CrewMembers *)crew1 forFlight:(NSDictionary *)flightDict
{
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
                if (comments.tcSign)     [crewMemberDict setObject:comments.tcSign forKey:@"Signature_TC"];
            }
            [crewMemberDict setObject:[crew1.crewCategory array] forKey:@"GadCategoryFeedback"];
        }
        
        
        
    }
    [crewMemberDict setObject:crew1 forKey:@"CrewMember"];
    return crewMemberDict;
}


+(NSString *)getAspectCodeValue:(NSString *)string {
    NSArray *valueKeyArray = [string componentsSeparatedByString: @"="];
    NSString *value = [valueKeyArray objectAtIndex:0];
    NSArray *valueKeyArray1 = [value componentsSeparatedByString: @"||"];
    NSString *aspectCode = [valueKeyArray1 objectAtIndex: 1];
    aspectCode = [aspectCode stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [aspectCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
+(NSMutableDictionary *)getBtnValueDict{
    NSMutableDictionary * btnTagValueDict = [[NSMutableDictionary alloc]init];
    [btnTagValueDict setValue:@"BE" forKey:@"101"];
    [btnTagValueDict setValue:@"PE" forKey:@"102"];
    [btnTagValueDict setValue:@"ES" forKey:@"103"];
    [btnTagValueDict setValue:@"SE" forKey:@"104"];
    [btnTagValueDict setValue:@"EX" forKey:@"105"];
    [btnTagValueDict setValue:@"NO" forKey:@"106"];
    [btnTagValueDict setValue:@"AE" forKey:@"107"];
    [btnTagValueDict setValue:@"BE" forKey:@"201"];
    [btnTagValueDict setValue:@"PE" forKey:@"202"];
    [btnTagValueDict setValue:@"ES" forKey:@"203"];
    [btnTagValueDict setValue:@"SE" forKey:@"204"];
    [btnTagValueDict setValue:@"EX" forKey:@"205"];
    [btnTagValueDict setValue:@"NO" forKey:@"206"];
    [btnTagValueDict setValue:@"AE" forKey:@"207"];
    [btnTagValueDict setValue:@"BE" forKey:@"301"];
    [btnTagValueDict setValue:@"PE" forKey:@"302"];
    [btnTagValueDict setValue:@"ES" forKey:@"303"];
    [btnTagValueDict setValue:@"SE" forKey:@"304"];
    [btnTagValueDict setValue:@"EX" forKey:@"305"];
    [btnTagValueDict setValue:@"NO" forKey:@"306"];
    [btnTagValueDict setValue:@"AE" forKey:@"307"];
    [btnTagValueDict setValue:@"BE" forKey:@"401"];
    [btnTagValueDict setValue:@"PE" forKey:@"402"];
    [btnTagValueDict setValue:@"ES" forKey:@"403"];
    [btnTagValueDict setValue:@"SE" forKey:@"404"];
    [btnTagValueDict setValue:@"EX" forKey:@"405"];
    [btnTagValueDict setValue:@"NO" forKey:@"406"];
    [btnTagValueDict setValue:@"AE" forKey:@"407"];
    [btnTagValueDict setValue:@"BE" forKey:@"501"];
    [btnTagValueDict setValue:@"PE" forKey:@"502"];
    [btnTagValueDict setValue:@"ES" forKey:@"503"];
    [btnTagValueDict setValue:@"SE" forKey:@"504"];
    [btnTagValueDict setValue:@"EX" forKey:@"505"];
    [btnTagValueDict setValue:@"NO" forKey:@"506"];
    [btnTagValueDict setValue:@"AE" forKey:@"507"];
    return btnTagValueDict;
}


+(NSString *)getScoreCodeValue:(NSString *)string
{
    
    NSArray* valueKeyArray = [string componentsSeparatedByString: @"="];
    int  valueCode= [[valueKeyArray objectAtIndex:1] intValue];
    NSString * finalCode = [NSString stringWithFormat:@"%d",valueCode];
    NSString* scoreCode = [[self getBtnValueDict] valueForKey:finalCode] ;
    return scoreCode;
}

+(NSMutableDictionary *)formatJSON_WithGadReport:(NSDictionary *)dict forFlight:(NSDictionary*)flightDict {
    NSMutableDictionary * gadDetailDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary * jsonFormatDictionary =[[NSMutableDictionary alloc]init];
    NSArray * catKeyArray = [[NSArray alloc]init];
    catKeyArray = [self getKeyArrayForGad];
    NSString *jsbCommets = [dict  valueForKey:@"ObserverComment"];
    NSString *commentsTC = [dict  valueForKey:@"TCComment"];
    jsbCommets = [jsbCommets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    commentsTC = [commentsTC stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *materialType1=[LTSingleton getSharedSingletonInstance].materialType;
    
    if (materialType1) {
        [gadDetailDict setObject:materialType1 forKey:@"guideTypeCode"];
    }
    
    if (jsbCommets) {
        [gadDetailDict setObject:jsbCommets forKey:@"jsbComments"];
    }
    
    if (commentsTC) {
        [gadDetailDict setObject:commentsTC forKey:@"tcComments"];
    }
    
    NSMutableArray *evaluationArray = [[NSMutableArray alloc]init];
    NSArray * keyArrayForCategory = [dict allKeys];
    int i=0;
    for (NSString * key in catKeyArray) {
        i++;
        for (NSString * keys in keyArrayForCategory) {
            
            if ([key isEqualToString:keys]){
                NSMutableDictionary *evalutionDict = [[NSMutableDictionary alloc] init];
                
                if (i == 6 || [materialType1 isEqualToString:@"WB"]) {
                    
                    NSDictionary * valueDict= [dict valueForKey:keys];
                    NSArray * valueArray = [valueDict allValues];
                    NSArray * keyArrays = [valueDict allKeys];
                    for (int j = 0; j < valueArray.count; j++) {
                        
                        NSMutableDictionary *evalutionDict1 = [[NSMutableDictionary alloc] init];
                        
                        [evalutionDict1 setObject:[self getAspectCodeValue:[keyArrays objectAtIndex:j]] forKey:@"aspectCode"];
                        NSString * finalCode = [NSString stringWithFormat:@"%@",[valueArray objectAtIndex:j]];
                        
                        NSString *val = [[self getBtnValueDict] valueForKey:finalCode];
                        if(!val) {
                            val = @"NO";
                        }
                        
                        [evalutionDict1 setObject:val forKey:@"scoreCode"];
                        [evaluationArray addObject:evalutionDict1];
                    }
                    
                } else {
                    NSString * valueDic = [[dict valueForKey:keys] description];
                    [evalutionDict setObject:[self getAspectCodeValue:valueDic] forKey:@"aspectCode"];
                    [evalutionDict setObject:[self getScoreCodeValue:valueDic] forKey:@"scoreCode"];
                    [evaluationArray addObject:evalutionDict];
                    break;
                }
            }
        }
    }
    
    [gadDetailDict setObject:evaluationArray forKey:@"evaluation"];
    NSMutableDictionary *signatureFileDict = [[NSMutableDictionary alloc]init];
    if ([dict objectForKey:@"Signatur_Observer"] != nil) {
        NSString *string =[dict objectForKey:@"Signatur_Observer"];
        NSArray* valueKeyArray = [string componentsSeparatedByString: @"/"];
        //        DLog(@"valueKeyArray %@",valueKeyArray);
        NSString* imageName = [valueKeyArray objectAtIndex: 3];
        [signatureFileDict setObject:imageName forKey:@"signatureFileJSB"];
    }
    if ([dict objectForKey:@"Signature_TC"] != nil) {
        NSString *string =[dict objectForKey:@"Signature_TC"];
        NSArray* valueKeyArray = [string componentsSeparatedByString: @"/"];
        //  DLog(@"valueKeyArray %@",valueKeyArray);
        NSString* imageName = [valueKeyArray objectAtIndex: 3];
        [signatureFileDict setObject:imageName forKey:@"signatureFileTC"];
    }
    [gadDetailDict setObject:signatureFileDict forKey:@"signatureFile"];
    //    NSMutableDictionary * flightDict = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    NSDictionary * tempFlightDict = [[NSMutableDictionary alloc]init];
    tempFlightDict = [flightDict valueForKey:@"flightKey"];
    if (dict!=nil) {
        NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
        [dateFormate setDateFormat:@"ddMM"];
        NSString *flightDateStr = [dateFormate stringFromDate:[tempFlightDict valueForKey:@"flightDate"]];
        NSString *reportIdFormation = @"";
        reportIdFormation = [reportIdFormation stringByAppendingString:flightDateStr];
        reportIdFormation = [reportIdFormation stringByAppendingString:[tempFlightDict valueForKey:@"airlineCode"]];
        reportIdFormation = [reportIdFormation stringByAppendingString:[[dict valueForKey:@"crewMember" ] valueForKey:@"bp"]];
        reportIdFormation = [reportIdFormation stringByAppendingString:[self generateRandomString]];
        // DLog(@"Unique report Id Formation %@",reportIdFormation);
        [gadDetailDict setObject:reportIdFormation forKey:@"reportId"];
    }
    
    [gadDetailDict setObject:[dict objectForKey:@"crewMember"] forKey:@"crewMember"];
    [gadDetailDict setObject:[dict objectForKey:@"legs"] forKey:@"legs"];
    [jsonFormatDictionary setObject:gadDetailDict forKey:@"gadDetail"];
    if (jsonFormatDictionary) {
        return jsonFormatDictionary;
    } else {
        return nil;
    }
}

+(NSArray *)getKeyArrayForGad {
    NSArray * GADtextArray = [[NSMutableArray alloc]init];
    AppDelegate * appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    int language = LANG_SPANISH;
    NSDictionary *fKey = [LTSingleton getSharedSingletonInstance].flightKeyDict;
    NSString *materialType = [UserInformationParser getMaterialType:fKey[@"material"]];
    NSString *airlineCode = [UserInformationParser getMaterialType:fKey[@"airline"]];
    if(materialType == nil || [materialType isEqualToString:@""]) {
        materialType = ((NSDictionary*)fKey[@"flightKey"])[@"materialType"];
        airlineCode = ((NSDictionary*)fKey[@"flightKey"])[@"airlineCode"];
    }
    
    NSDictionary *dict=[[NSDictionary alloc] init];
    if ( [materialType isEqualToString:@"NB"] && language == LANG_SPANISH) {
        dict = [appDel getDictionayofType:@"NB" selectedLang:language getDictionayofType:airlineCode];
    }
    else if ([materialType isEqualToString:@"WB"] && language == LANG_SPANISH) {
        dict = [appDel getDictionayofType:@"WB" selectedLang:language getDictionayofType:airlineCode];
    }
    else if ([materialType isEqualToString:@"NB"] && language == LANG_PORTUGUESE) {
        
        dict = [appDel getDictionayofType:@"NB" selectedLang:language getDictionayofType:airlineCode];
    }
    else if ([materialType isEqualToString:@"WB"] && language == LANG_PORTUGUESE) {
        
        dict = [appDel getDictionayofType:@"WB" selectedLang:language getDictionayofType:airlineCode];
    }
    
    GADtextArray = [dict objectForKey:@"Value"];
    NSMutableArray * keysArray = [[NSMutableArray alloc]init];
    
    for (int i =0;i<[GADtextArray count];i++){
        NSString * key =  [[[GADtextArray objectAtIndex:i] allKeys] objectAtIndex:0];
        [keysArray addObject:key];
    }
    
    return keysArray;
}

+(void)deleteGADForCrewBp:(NSString*)crewBP ForFlight:(NSDictionary*)dict {
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [dict checkNilValueForKey:@"flightDate"],[dict checkNilValueForKey:@"suffix"],[dict checkNilValueForKey:@"flightNumber"],[dict checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        if ([results count] > 0) {
            FlightRoaster *flight = [results objectAtIndex:0];
            predicate = nil;
            NSArray *legsArray = [[flight.flightInfoLegs array] copy];
            for (Legs *leg in legsArray) {
                predicate = nil;
                predicate = [NSPredicate predicateWithFormat:@"bp == %@",crewBP];
                results = [[leg.legsCrewmember array] filteredArrayUsingPredicate:predicate];
                if ([results count] > 0) {
                    CrewMembers *crew = [results firstObject];
                    
                    int p = 0;
                    
                    if (crew != nil) {
                        NSArray *crewCategoryArray = [[crew.crewCategory array] copy];
                        for (GADCategory *gCat in crewCategoryArray) {
                            p++;
                            if (gCat!=nil) {
                                NSArray *categoryValueArray = [[gCat.categoryValue array] copy];
                                for (GADValue *val in categoryValueArray) {
                                    p++;
                                    [gCat removeCategoryValueObject:val];
                                    [gCat.managedObjectContext deleteObject:val];
                                }
                                [crew removeCrewCategoryObject:gCat];
                                [crew.managedObjectContext deleteObject:gCat];
                            }
                        }
                        
                        GADComments *gadComments = crew.crewComments;
                        crew.crewComments = nil;
                        if(gadComments) {
                            [crew.managedObjectContext deleteObject:gadComments];
                        }
                    }
                    
                    crew.status = [NSNumber numberWithInt:0];
                }
            }
        }
    }
    
    if (![managedObjectContext save:&error1]) {
        NSLog(@"not saved");
    }
}

+(NSString *)generateRandomString
{
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:5];
    
    for (int i = 0; i < 5; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
    
}
@end
