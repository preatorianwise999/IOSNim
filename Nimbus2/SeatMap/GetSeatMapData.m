//
//  GetSeatMapData.m
//  Nimbus2
//
//  Created by vishal on 10/19/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "GetSeatMapData.h"
#import "LTSingleton.h"
#import "AppDelegate.h"
#import "User.h"
#import "NSMutableDictionary+ChekVal.h"
//#import "NSDictionary+ChekVal.h"
#import "AllDb.h"





@implementation GetSeatMapData {
    
}

+(NSMutableDictionary *)getSeatMapDataForLegIndex:(int)index{
    NSMutableDictionary * seatMapDict = [[NSMutableDictionary alloc]init];
    NSString * businessColumnType = @"1J";
    NSString * economyColumnType = @"1Y";
    
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
            FlightRoaster *flight = [results objectAtIndex:0];
            NSSortDescriptor *sortDescriptorClass =
            [NSSortDescriptor sortDescriptorWithKey:@"columnType" ascending:YES];
            
            NSSortDescriptor *sortDescriptorColumn =
            [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
            
            NSArray  * seatMapArray = [[flight.flightSeatMap allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorClass,sortDescriptorColumn,nil]];
            
            NSOrderedSet * legInfo = flight.flightInfoLegs;
            
            NSArray * customerArray = [[[legInfo objectAtIndex:index] legCustomer] array];
            NSMutableArray * businessClassTypeArray = [[NSMutableArray alloc]init];
            NSMutableArray * economyClassTypeArray = [[NSMutableArray alloc]init];
            
            for (int i =0;i<seatMapArray.count ; i++){
                
                SeatMap * seatMap = [seatMapArray objectAtIndex:i];
                NSMutableDictionary * seatDict = [[NSMutableDictionary alloc]init];
                [seatDict setValue:seatMap.classType forKey:@"classType"];
                [seatDict setValue:seatMap.state forKey:@"state"];
                [seatDict setValue:seatMap.rowNumber forKey:@"rowNumber"];
                [seatDict setValue:seatMap.columnNum forKey:@"columnNumber"];
                [seatDict setValue:seatMap.isAisle forKey:@"isAisle"];
                [seatDict setValue:seatMap.columnType forKey:@"columnType"];
                [seatDict setValue:seatMap.isWindow forKey:@"isWindow"];
                [seatDict setValue:seatMap.isEmergency forKey:@"isEmergency"];
                NSString * seatNo = [NSString stringWithFormat:@"%@%@",seatMap.rowNumber,seatMap.columnNum];
                
                
                // if ([[seatMap.seatCustomer allObjects] count] >0){
                //Customer * cus;
                for (Customer * cus in customerArray) {
                    if ([cus.seatNumber isEqualToString:seatNo]){
                        NSMutableDictionary * cusDict = [[NSMutableDictionary alloc]init];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"dd MMMM yyyy"];
                        [cusDict setValue:cus.firstName forKey:@"firstName"];
                        [cusDict setValue:cus.lastName forKey:@"lastName"];
                        if (cus.secondLastName != nil)
                            [cusDict setValue:cus.secondLastName forKey:@"secondLastName"];
                        
                        [cusDict setValue:cus.customerId forKey:@"customerId"];
                        
                        [cusDict setValue:cus.seatNumber forKey:@"seatNumber"];
                        [cusDict setValue:cus.docNumber forKey:@"docNumber"];
                        [cusDict setValue:cus.docType forKey:@"docType"];
                        [cusDict setValue:cus.freqFlyerComp forKey:@"freqFlyerComp"];
                        [cusDict setValue:cus.freqFlyerNum forKey:@"freqFlyerNum"];
                        [cusDict setValue:cus.freqFlyerCategory forKey:@"freqFlyerCategory"];
                        [cusDict setValue:cus.groupCode forKey:@"groupCode"];
                        [cusDict setValue:cus.dateOfBirth forKey:@"dateOfBirth"];
                        [cusDict setValue:cus.status forKey:@"status"];
                        
                        [cusDict setValue:[dateFormatter stringFromDate:cus.dateOfBirth] forKey:@"dateOfBirth"];
                        if (cus.address!=nil) {
                            [cusDict setValue:cus.address forKey:@"address"];
                        }
                        
                        [cusDict setValue:cus.language forKey:@"language"];
                        [cusDict setValue:cus.email forKey:@"email"];
                        
                        [cusDict setValue:cus.gender forKey:@"gender"];
                        [cusDict setValue:cus.editCodes forKey:@"editCodes"];
                        [cusDict setValue:cus.isWCH forKey:@"isWCH"];
                        [cusDict setValue:cus.isChild forKey:@"isChild"];
                        [cusDict setValue:cus.lanPassKms forKey:@"lanPassKms"];
                        [cusDict setValue:cus.lanPassCategory forKey:@"lanPassCategory"];
                        [cusDict setValue:cus.lanPassUpgrade forKey:@"lanPassUpgrade"];
                        [cusDict setValue:cus.vipCategory forKey:@"vipCategory"];
                        [cusDict setValue:cus.vipRemarks forKey:@"vipRemarks"];
                        [cusDict setValue:cus.vipSpecialAttentions forKey:@"vipSpecialAttentions"];
                        
                        
                        
                        NSArray * splMealArray = [cus.specialMeals array];
                        NSMutableArray * splMealArrayObject = [[NSMutableArray alloc]init];
                        for (int j = 0; j < splMealArray.count; j++) {
                            NSMutableDictionary *splMealDict = [[NSMutableDictionary alloc]init];
                            SpecialMeal *splMeal = [splMealArray objectAtIndex:j];
                            
                            [splMealDict setValue:splMeal.option forKey:@"option"];
                            [splMealDict setValue:splMeal.serviceCode forKey:@"serviceCode"];
                            [splMealArrayObject addObject:splMealDict];
                            
                        }
                        
                        NSArray *connectionArray = [cus.cusConnection array];
                        NSMutableArray *connectionArrayObject = [[NSMutableArray alloc]init];
                        for (int j =0 ; j<connectionArray.count ; j++){
                            NSMutableDictionary *connectionDict = [[NSMutableDictionary alloc]init];
                            Connection *connection = [connectionArray objectAtIndex:j];
                            
                            AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"dd MMMM yyyy, HH:mm"];
                            [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
                            [connectionDict setValue:[dateFormatter stringFromDate:connection.arrivalDate] forKey:@"arrivalDate"];
                            [connectionDict setValue:[dateFormatter stringFromDate:connection.departureDate] forKey:@"departureDate"];
                            [connectionDict setValue:connection.arrivalAP forKey:@"arrivalAP"];
                            [connectionDict setValue:connection.departureAP forKey:@"departureAP"];
                            [connectionDict setValue:connection.flightType forKey:@"airlineCode"];
                            [connectionDict setValue:connection.flightNum forKey:@"flightNumber"];
                            [ connectionArrayObject addObject:connectionDict];
                            
                        }
                        [cusDict setValue:splMealArrayObject forKey:@"splMeal"];
                        [cusDict setValue:connectionArrayObject forKey:@"connection"];
                        
                        [seatDict setObject:cusDict forKey:@"seatCustomer"];
                    }else{
                        continue;
                    }
                    
                }
               
                if ([seatMap.classType isEqualToString:@"J"]){
                    if ([seatMap.columnType isEqualToString:businessColumnType]){
                        [businessClassTypeArray addObject:seatDict];
                    }else{
                        [seatMapDict setObject:businessClassTypeArray forKey:businessColumnType];
                        businessColumnType = seatMap.columnType;
                        businessClassTypeArray = nil;
                        businessClassTypeArray = [[NSMutableArray alloc]init];
                        [businessClassTypeArray addObject:seatDict];
                        
                    }
                }else {
                    if ([seatMap.columnType isEqualToString:economyColumnType]){
                        [economyClassTypeArray addObject:seatDict];
                    }else{
                        [seatMapDict setObject:economyClassTypeArray forKey:economyColumnType];
                        economyColumnType = seatMap.columnType;
                        economyClassTypeArray = nil;
                        economyClassTypeArray = [[NSMutableArray alloc]init];
                        [economyClassTypeArray addObject:seatDict];
                        
                    }
                    
                }
                
            }
            if (seatMapArray.count == 0){
                [seatMapDict setObject:businessClassTypeArray forKey:@"1M"];
                
            }
            [seatMapDict setObject:businessClassTypeArray forKey:businessColumnType];
            [seatMapDict setObject:economyClassTypeArray forKey:economyColumnType];
            
        }
        
    }
    return seatMapDict;
}

+(NSNumber *)absoluteValue:(NSNumber *)input {
    return [NSNumber numberWithDouble:fabs([input doubleValue])];
}
+(NSMutableArray *)getPassengerDataLegIndex:(int)index{
    NSMutableArray * custArray =  [[NSMutableArray alloc]init];
    
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
        NSDictionary *flightDict = [[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"flightKey"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", [flightDict checkNilValueForKey:@"flightDate"],[flightDict checkNilValueForKey:@"suffix"],[flightDict checkNilValueForKey:@"flightNumber"],[flightDict checkNilValueForKey:@"airlineCode"]];
        NSArray *results = [[currentUser.flightRosters array] filteredArrayUsingPredicate:predicate];
        
        
        if ([results count]>0) {
            FlightRoaster *flight = (FlightRoaster*)[results objectAtIndex:0];
            predicate=nil;
            NSOrderedSet * legInfo = flight.flightInfoLegs;
            
            NSArray * customerArray = [[[legInfo objectAtIndex:index] legCustomer] array];
            for (int i =0;i< [customerArray count];i++){
                
                Customer * cus = [customerArray objectAtIndex:i];
                
                if (cus.seatNumber == nil || [cus.seatNumber isEqualToString:@""]) {
                    NSMutableDictionary * cusDict = [[NSMutableDictionary alloc]init];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"dd MMMM yyyy"];
                    [cusDict setValue:cus.firstName forKey:@"firstName"];
                    [cusDict setValue:cus.lastName forKey:@"lastName"];
                    if (cus.secondLastName != nil)
                        [cusDict setValue:cus.secondLastName forKey:@"secondLastName"];
                    
                    [cusDict setValue:cus.seatNumber forKey:@"seatNumber"];
                    [cusDict setValue:cus.docNumber forKey:@"docNumber"];
                    [cusDict setValue:cus.docType forKey:@"docType"];
                    [cusDict setValue:cus.freqFlyerComp forKey:@"freqFlyerComp"];
                    [cusDict setValue:cus.freqFlyerNum forKey:@"freqFlyerNum"];
                    [cusDict setValue:cus.freqFlyerCategory forKey:@"freqFlyerCategory"];
                    [cusDict setValue:cus.groupCode forKey:@"groupCode"];
                    [cusDict setValue:cus.dateOfBirth forKey:@"dateOfBirth"];
                    [cusDict setValue:[dateFormatter stringFromDate:cus.dateOfBirth] forKey:@"dateOfBirth"];
                    if (cus.address!=nil) {
                        [cusDict setValue:cus.address forKey:@"address"];
                    }
                        [cusDict setValue:cus.customerId forKey:@"customerId"];

                    [cusDict setValue:cus.language forKey:@"language"];
                    [cusDict setValue:cus.email forKey:@"email"];
                    [cusDict setValue:cus.gender forKey:@"gender"];
                    [cusDict setValue:cus.editCodes forKey:@"editCodes"];
                    [cusDict setValue:cus.isWCH forKey:@"isWCH"];
                    [cusDict setValue:cus.isChild forKey:@"isChild"];
                    [cusDict setValue:cus.lanPassKms forKey:@"lanPassKms"];
                    [cusDict setValue:cus.lanPassCategory forKey:@"lanPassCategory"];
                    [cusDict setValue:cus.lanPassUpgrade forKey:@"lanPassUpgrade"];
                    [cusDict setValue:cus.vipCategory forKey:@"vipCategory"];
                    [cusDict setValue:cus.vipRemarks forKey:@"vipRemarks"];
                    [cusDict setValue:cus.vipSpecialAttentions forKey:@"vipSpecialAttentions"];
                    
                    
                    
                    NSArray * splMealArray = [cus.specialMeals array];
                    NSMutableArray * splMealArrayObject = [[NSMutableArray alloc]init];
                    for (int j = 0; j < splMealArray.count; j++) {
                        NSMutableDictionary * splMealDict = [[NSMutableDictionary alloc]init];
                        SpecialMeal* splMeal = [splMealArray objectAtIndex:j];
                        
                        [splMealDict setValue:splMeal.option forKey:@"option"];
                        [splMealDict setValue:splMeal.serviceCode forKey:@"serviceCode"];
                        [splMealArrayObject addObject:splMealDict];
                    }
                    
                    NSArray * connectionArray = [cus.cusConnection array];
                    NSMutableArray * connectionArrayObject = [[NSMutableArray alloc]init];
                    for (int j = 0; j < connectionArray.count; j++) {
                        NSMutableDictionary *connectionDict = [[NSMutableDictionary alloc]init];
                        Connection *connection = [connectionArray objectAtIndex:j];
                        
                        AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"dd MMMM yyyy, HH:mm"];
                        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
                        [connectionDict setValue:[dateFormatter stringFromDate:connection.arrivalDate] forKey:@"arrivalDate"];
                        [connectionDict setValue:[dateFormatter stringFromDate:connection.departureDate] forKey:@"departureDate"];
                        [connectionDict setValue:connection.arrivalAP forKey:@"arrivalAP"];
                        [connectionDict setValue:connection.departureAP forKey:@"departureAP"];
                        [connectionDict setValue:connection.flightType forKey:@"airlineCode"];
                        [connectionDict setValue:connection.flightNum forKey:@"flightNumber"];
                        [connectionArrayObject addObject:connectionDict];
                        
                    }
                    [cusDict setValue:splMealArrayObject forKey:@"splMeal"];
                    [cusDict setValue:connectionArrayObject forKey:@"connection"];
                    
                    [custArray addObject:cusDict];
                }
            }
            return custArray;
        }
    }
    return custArray;
}


@end
