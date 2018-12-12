//
//  LTSaveCUSData.m
//  Nimbus2
//
//  Created by Rajashekar on 08/09/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "LTSaveCUSData.h"
#import "AllDb.h"
#import "AppDelegate.h"
#import "Customer.h"
#import "NSMutableDictionary+ChekVal.h"
#import "Constants.h"
#import "LTSingleton.h"
#import "CUSImages.h"

@implementation LTSaveCUSData



+(void)modifyStatus:(int)status forCustomer:(NSDictionary *)customerDict forLeg:(int)legNo forFlight:(NSMutableDictionary *)flightRoster forReportId:(NSString*)reportId {
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSDictionary *dict = [flightRoster objectForKey:@"flightKey"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    
    if ([results count] > 0) {
        FlightRoaster *flight = [results firstObject];
        Legs *leg = [[flight.flightInfoLegs array] objectAtIndex:legNo];
        NSLog(@"lef information is %@-%@",leg.origin, leg.destination);
        for (int x=0; x<[leg.legCustomer array].count; x++) {
            Customer *temp = [[leg.legCustomer array] objectAtIndex:x];
            NSLog(@"firstname %@ lastname %@",temp.firstName,temp.lastName);
        }

        NSString *customerId = [customerDict objectForKey:@"CUSTOMERID"];

        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerId == %@", customerId];
        [request setPredicate:predicate];
        [request setReturnsObjectsAsFaults:NO];
        
        NSError *error;
        NSArray *results = [[leg.legCustomer array] filteredArrayUsingPredicate:predicate];
        Customer *temp;
        if ([results count]>0) {
            temp = (Customer *)[results objectAtIndex:0];
            CusReport *cusreport = [[[temp.cusCusReport array] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"reportId==%@",reportId]] firstObject];
            cusreport.synchDate = [NSDate date];
            //if (status>[cusreport.status integerValue]) {
                cusreport.status = [NSNumber numberWithInt:status];
            //}
            
        }
        
        if (![managedObjectContext save:&error]) {
            DLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
    }
}



+(NSString*) saveCUSReportforFlightLeg:(int)legNumber forCustomer:(NSDictionary *)customerDict forCUSImages:(NSDictionary*)cusImages forCUSDict:(NSDictionary*)flightCUSDict forFlight:(NSDictionary*)flightDict hasSeatMap:(BOOL)doesNotHaveSeatMap forReportid:(NSString*)reportId {
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];

    NSString *customerId = [customerDict objectForKey:@"CUSTOMERID"];
    NSString *idflights =[[flightDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"];
    NSString *airlineCode=[[flightDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"];
    
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
        FlightRoaster *flight = [results firstObject];
        if (doesNotHaveSeatMap) {
        flight.isFlightSeatMapSynched = [NSNumber numberWithBool:YES];
        }
        Legs *leg = [[flight.flightInfoLegs array] objectAtIndex:legNumber];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerId == %@", customerId];
        [request setPredicate:predicate];
        [request setReturnsObjectsAsFaults:NO];

        
        for (int x=0; x<[leg.legCustomer array].count; x++) {
            Customer *temp = [[leg.legCustomer array] objectAtIndex:x];
            NSLog(@"firstname %@ lastname %@",temp.firstName,temp.lastName);
        }
        
        NSError *error;
        NSArray *results = [[leg.legCustomer array] filteredArrayUsingPredicate:predicate];
        Customer *temp;
        CusReport *cusreport;
        
        
        
        if ([results count]>0) {
            NSArray *groups = [[LTSingleton getSharedSingletonInstance].flightCUSDict objectForKey:@"groups"];
            NSDictionary *PassengerDict = [[groups objectAtIndex:1] objectForKey:@"singleEvents"];
            temp = (Customer *)[results objectAtIndex:0];
            if (reportId==nil) {
                cusreport=[NSEntityDescription insertNewObjectForEntityForName:@"CusReport" inManagedObjectContext:managedObjectContext];
            }else{
                cusreport = [[[temp.cusCusReport array] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"reportId==%@",reportId]] firstObject];
            }
            ///altering for multiple cus
            [temp addCusCusReportObject:cusreport];
            
            NSString * newidreport =@"";
            
         
            NSString *idflighttempo=[NSString stringWithFormat:@"%@%@",airlineCode,idflights];
            newidreport =[SaveSeatMap CreateDefaultIdGeneratedReport:idflighttempo:customerId];//Nueva Funcion que retorna por ejem : LA500xfhts20169141625 como nuevo codigo reportid

            
            cusreport.reportId = [SaveSeatMap generateRandomString]; //newidreport ;//Variable con nuevo codigo de reportid
            cusreport.synchDate=[NSDate date];
            temp.email = [PassengerDict objectForKey:@"Email"];
            temp.address = [PassengerDict objectForKey:@"Address"];
            temp.language = [PassengerDict objectForKey:@"Language"];
            
            
            if (!([cusreport.status integerValue] >= inqueue)) {
                cusreport.status = [NSNumber numberWithInt:draft];
            }
            if (cusreport.reportCusImages ==nil) {
                CUSImages *Image = [NSEntityDescription insertNewObjectForEntityForName:@"CUSImages" inManagedObjectContext:managedObjectContext];
                Image.image1 = [cusImages objectForKey:@"image1"];
                Image.image2 = [cusImages objectForKey:@"image2"];
                Image.image3 = [cusImages objectForKey:@"image3"];
                Image.image4 = [cusImages objectForKey:@"image4"];
                Image.image5 = [cusImages objectForKey:@"image5"];
                
                cusreport.reportCusImages = Image;
            }
            else {
                cusreport.reportCusImages.image1 = [cusImages objectForKey:@"image1"];
                cusreport.reportCusImages.image2 = [cusImages objectForKey:@"image2"];
                cusreport.reportCusImages.image3 = [cusImages objectForKey:@"image3"];
                cusreport.reportCusImages.image4 = [cusImages objectForKey:@"image4"];
                cusreport.reportCusImages.image5 = [cusImages objectForKey:@"image5"];
            }
            
            
            ////alter ends
            

            
        }
        if (![managedObjectContext save:&error]) {
            DLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
        [self saveCUSReportForCUSReport:cusreport withDict:flightCUSDict withMoc:managedObjectContext];
        //[self saveCUSReportForCustomer:temp withDict:flightCUSDict withMoc:managedObjectContext];
        return cusreport.reportId;
    }
   
    return nil;
}

+(void) deleteReportForCustomerDict:(NSDictionary*)customerDict forFlightDict:(NSDictionary*)flightDict forreportId:(NSString*)reportId{
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    

  NSDictionary *flightDictionary =   [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    
    NSDictionary *dict = [flightDictionary objectForKey:@"flightKey"];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
    [dateFormat3 setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    NSDate *fDate = [dict objectForKey:@"flightDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    
    if ([results count] > 0) {
        FlightRoaster *flight = [results firstObject];
        Legs *leg = [[flight.flightInfoLegs array] objectAtIndex:[LTSingleton getSharedSingletonInstance].legNumber];
        NSString *customerId = [customerDict objectForKey:@"CUSTOMERID"];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerId ==%@", customerId];
        [request setPredicate:predicate];
        [request setReturnsObjectsAsFaults:NO];

        
        NSError *error;
        NSArray *results = [[leg.legCustomer array] filteredArrayUsingPredicate:predicate];
        
        NSMutableArray *grpArray = [flightDict objectForKey:@"groups"];

        if ([results count] > 0) {
            // need to delete report instead
            
            Customer *customer = [results firstObject];
            CusReport *cusReport = [[[customer.cusCusReport array] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"reportId==%@",reportId]] firstObject];
            for (int i=0; i<[grpArray count];i++) {
                NSArray *results1;
                Groups *group;
                NSDictionary *grpDict = [grpArray objectAtIndex:i];
                predicate = [NSPredicate predicateWithFormat:@"name ==%@",[grpDict objectForKey:@"name"]];
                results1 = [[cusReport.reportGroup array] filteredArrayUsingPredicate:predicate];
                if ([results1 count]>0) {
                    group = (Groups*)[results1 objectAtIndex:0];
                    for (Events *event in [group.groupOccourences array]) {
                        for (Row *row in [event.eventsRow array]) {
                            for (Contents *content in [row.rowContent array]) {
                                [row removeRowContentObject:content];
                                [row.managedObjectContext deleteObject:content];
                            }
                            [event removeEventsRowObject:row];
                            [event.managedObjectContext deleteObject:row];
                        }
                        [group removeGroupOccourencesObject:event];
                        [group.managedObjectContext deleteObject:event];
                    }
                    
                    [cusReport removeReportGroupObject:group];
                    [cusReport.managedObjectContext deleteObject:group];
                }
            }
            
            cusReport.status = [NSNumber numberWithInt:0];
            CUSImages *images = cusReport.reportCusImages;
            images.image1 = nil;
            images.image2 = nil;
            images.image3 = nil;
            images.image4 = nil;
            images.image4 = nil;
            if(cusReport != nil) {
                [customer removeCusCusReportObject:cusReport];
                [customer.managedObjectContext deleteObject:cusReport];
            }
            
            if (![managedObjectContext save:&error]) {
                DLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
        }
    }
}

+(void) saveCUSReportForCUSReport:(CusReport*)report withDict:(NSDictionary*)dict withMoc:(NSManagedObjectContext*)localMoc{
    
    if(nil != dict) {
        
        NSManagedObjectContext *managedObjectContext = localMoc;
        [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        NSPredicate *predicate;
        
        /////////////////////////////////////////
        NSMutableArray *grpArray = [dict objectForKey:@"groups"];
        for (int i=0; i<[grpArray count];i++) {
            NSDictionary *grpDict = [grpArray objectAtIndex:i];
            NSArray *results;
            Groups *group;
            predicate = [NSPredicate predicateWithFormat:@"name ==%@",[grpDict objectForKey:@"name"]];
            results = [[report.reportGroup array] filteredArrayUsingPredicate:predicate];
            if ([results count]>0) {
                group = (Groups*)[results objectAtIndex:0];
                for (Events *event in [group.groupOccourences array]) {
                    for (Row *row in [event.eventsRow array]) {
                        for (Contents *content in [row.rowContent array]) {
                            [row removeRowContentObject:content];
                            [row.managedObjectContext deleteObject:content];
                        }
                        [event removeEventsRowObject:row];
                        [event.managedObjectContext deleteObject:row];
                    }
                    [group removeGroupOccourencesObject:event];
                    [group.managedObjectContext deleteObject:event];
                }
                
                [report removeReportGroupObject:group];
                [report.managedObjectContext deleteObject:group];
            }
            
            group = [NSEntityDescription insertNewObjectForEntityForName:@"Groups" inManagedObjectContext:managedObjectContext];
            
            group.name=[grpDict objectForKey:@"name"];
            [report addReportGroupObject:group];
            NSDictionary *eventDict;
            BOOL Flag;
            if ([grpDict objectForKey:@"multiEvents"] != nil) {
                eventDict = [grpDict objectForKey:@"multiEvents"];
                Flag = TRUE;
                
                for (NSString *eventName in [eventDict allKeys]) {
                    //if ([[eventDict objectForKey:eventName] count]>0) {
                    Events *event = [NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:managedObjectContext];
                    event.name=eventName;
                    [group addGroupOccourencesObject:event];
                    NSArray *eventArray = [eventDict objectForKey:eventName];
                    for (int i=0; i<[eventArray count]; i++) {
                        NSMutableDictionary *contentDict = [eventArray objectAtIndex:i];
                        Row *row = [NSEntityDescription insertNewObjectForEntityForName:@"Row" inManagedObjectContext:managedObjectContext];
                        row.rowNumber = [NSNumber numberWithInt:i];
                        [event addEventsRowObject:row];
                        for (NSString *contentName in [contentDict allKeys]) {
                            Contents *content = [NSEntityDescription insertNewObjectForEntityForName:@"Contents" inManagedObjectContext:managedObjectContext];
                            content.name=contentName;
                            content.selectedValue=[contentDict objectForKey:contentName];
                            [row addRowContentObject:content];
                        }
                    }
                    event.isMultiple=[NSNumber numberWithBool:Flag];
                }
            }
            
            if([grpDict objectForKey:@"singleEvents"]!=nil){
                NSDictionary *contentDict = [grpDict objectForKey:@"singleEvents"];
                Flag=FALSE;
                Events *event = [NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:managedObjectContext];
                event.name=@"singleEvent";
                [group addGroupOccourencesObject:event];
                Row *row = [NSEntityDescription insertNewObjectForEntityForName:@"Row" inManagedObjectContext:managedObjectContext];
                row.rowNumber = [NSNumber numberWithInt:0];
                [event addEventsRowObject:row];
                for (NSString *contentName in [contentDict allKeys]) {
                    Contents *content = [NSEntityDescription insertNewObjectForEntityForName:@"Contents" inManagedObjectContext:managedObjectContext];
                    content.name=contentName;
                    content.selectedValue=[contentDict objectForKey:contentName];
                    [row addRowContentObject:content];
                }
                event.isMultiple=[NSNumber numberWithBool:Flag];
            }
            [report addReportGroupObject:group];
        }
        
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
    }
}

@end
