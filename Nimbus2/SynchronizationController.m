//
//  SynchronizationController.m
//  Nimbus2
//
//  Created by 720368 on 8/4/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "SynchronizationController.h"
#import "SynchStatusViewController.h"
#import "AppDelegate.h"
#import "UserInformationParser.h"
#import  "ConnectionLibrary.h"
#import "GADController.h"
#import "LTCUSData.h"
#import "Constants.h"
#import "NSDate+Utils.h"
#import "LTSaveCUSData.h"
#import "LTCreateFlightReport.h"

NSUInteger *countItemsToSend=0;
NSString *kNotifSyncFinished = @"kNotifSyncFinished";
NSString *kNotifBriefingDownloaded = @"kNotifBriefingDownloaded";
NSString * kNotifSeatMap = @"seatMapActualized";

@implementation SynchronizationController
-(BOOL) checkForInternetAvailability {
    //    return NO;
    Reachability *reachabilityObject=[Reachability reachabilityWithHostName:REACHABILITY_HOST];
    NetworkStatus netStatus = [reachabilityObject currentReachabilityStatus];
    DLog(@"######--------------------checkForInternetAvailability %ld",(long)netStatus);
    if (netStatus==NotReachable) {
        return NO;
    }
    else {
        return YES;
    }
}

-(BOOL) checkForWifiAvailability {
    Reachability *reachabilityObject=[Reachability reachabilityWithHostName:REACHABILITY_HOST];
    NetworkStatus netStatus = [reachabilityObject currentReachabilityStatus];
    DLog(@"######--------------------checkForInternetAvailability %ld",(long)netStatus);
    if (netStatus == ReachableViaWiFi) {
        return YES;
    }
    else {
        return NO;
    }
}

-(BOOL)validateResponseDict:(NSDictionary*)dict {
    
    if(!dict) {
        return NO;
    }
    
    if ([dict objectForKey:@"code"] != nil) {
        return NO;
    } else {
        return YES;
    }
}

-(void)saveCredentials {
    if ([[TempLocalStorageModel getDataFromKeyChainWrapperForKey:CuserName withDecrypted:YES] isEqualToString:singleton.username]) {
        singleton.isUserChanged=NO;
    }else{
        singleton.isUserChanged=YES;
        DLog(@"Different user logged in");
        //[self deleteHighlightPlist];
    }
    [TempLocalStorageModel setDataInKeyChainWrapper:singleton.username withKey:CuserName withEncryption:YES];
    [TempLocalStorageModel setDataInKeyChainWrapper:singleton.password withKey:CpassWord withEncryption:YES];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    DLog(@"%@",dateString);
    singleton.lastSynchDate = dateString;
    [TempLocalStorageModel saveInUserDefaults:dateString withKey:@"synchdate"];
}

-(NSString *)getHost {
    if([PORT isEqualToString:@"80"])
        return [NSString stringWithFormat:@"%@",HOSTNAME];
    else
        return [NSString stringWithFormat:@"%@:%@",HOSTNAME,PORT];
}

-(void)synchManuallyAddedFlight {
    //[acview changelabelStatusTo:[apDel copyTextForKey:@"SYNC_FLIGHT_DETAIL"]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *manualFlightarray = [UserInformationParser getAllManualflights];
        for (int i = 0; i < [manualFlightarray count]; i++) {
            NSMutableDictionary *newflightDict = [manualFlightarray objectAtIndex:i];
            NSMutableDictionary *responseDict = [self sendManualflightForChecking:newflightDict];
            [UserInformationParser updateFlightLink:responseDict withStatus:ShouldAdd];
            [self getBookingInfo:newflightDict];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self showFlightRoaster];
        });
    });
}
-(void)synchAllPassengerDataOnCompleteById:(NSString *)idflight :(void (^)(void))onComplete {
   // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray * allFlightArray = [self getFlightroaster];
        
        for (NSDictionary * flightDict in allFlightArray)
        {
            if([[[flightDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"] isEqualToString:(NSString *)idflight])
            {
                AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
                NSDictionary *lastLeg = [[flightDict objectForKey:@"legs"] lastObject];
                int diff = [appDel compareDate:[NSDate date] :[lastLeg[@"departureLocal"] toGlobalTime]];
                
                BOOL flightIsInSyncRange = (diff >= 0 && diff <= 60*60*24);
                
                if(!flightIsInSyncRange || ![self shouldSyncSeatmapAndPassengerListForFlight:flightDict leg:-1]) {
                    continue;
                }
                
                NSDictionary * fligtKeyDict = [flightDict valueForKey:@"flightKey"];
                NSString *flightNumber= [fligtKeyDict  objectForKey:@"flightNumber"];
                NSString *airLineCode= [fligtKeyDict objectForKey:@"airlineCode"];
                NSDate *fDate= [fligtKeyDict objectForKey:@"flightDate"];
                NSString * departureStation = [[[flightDict objectForKey:@"legs"] objectAtIndex:0 ]valueForKey:@"origin"];
                NSMutableDictionary *flightDictInput = [[NSMutableDictionary alloc] init];
                if (flightNumber) {
                    [flightDictInput setObject:flightNumber forKey:@"flightNumber"];
                }
                else {
                    DLog(@"flight number is not available");
                }
                [flightDictInput setObject:airLineCode forKey:@"airlineCode"];
                NSMutableDictionary * dateDict = [[NSMutableDictionary alloc]init];
                NSDateFormatter *fr = [[NSDateFormatter alloc] init];
                [fr setDateFormat:DATEFORMAT1];
                NSString *date = [fr stringFromDate:fDate];
                [dateDict setObject:date forKey:@"departureDate"];
                
                [flightDictInput setObject:dateDict forKey:@"flightDate"];
                [flightDictInput setObject:departureStation forKey:@"departureIATACode"];
                
                NSString *jsonString = [DictionaryParser jsonStringFromDictionary:[NSDictionary dictionaryWithDictionary:flightDictInput]];
                ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
                RequestObject *requset= [[RequestObject alloc] init] ;
                NSString * passengerUri = @"getPassengerList";
                requset.url = [NSString stringWithFormat:@"%@%@",BASEURL,passengerUri];requset.language = @"en_ES";requset.tag = 1;requset.type=@"POST";
                requset.param = jsonString;requset.priority=normal;
                NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
                if (data!=nil  && [data length] > 0) {
                    NSDictionary *responseDict =[DictionaryParser dictionaryFromData:data];
                    if ([responseDict valueForKey:@"passengerListResponse"] !=nil)
                        [SaveSeatMap savePassengerForFlight:fligtKeyDict andPassengerDict:responseDict];
                }
            }
        }
        
        onComplete();
   // });

    
}
-(void)synchAllPassengerDataOnComplete:(void (^)(void))onComplete {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray * allFlightArray = [self getFlightroaster];
        
        for (NSDictionary * flightDict in allFlightArray) {
            
            AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSDictionary *lastLeg = [[flightDict objectForKey:@"legs"] lastObject];
            int diff = [appDel compareDate:[NSDate date] :[lastLeg[@"departureLocal"] toGlobalTime]];
            
            BOOL flightIsInSyncRange = (diff >= 0 && diff <= 60*60*24);
            
            if(!flightIsInSyncRange || ![self shouldSyncSeatmapAndPassengerListForFlight:flightDict leg:-1]) {
                continue;
            }
            
            NSDictionary * fligtKeyDict = [flightDict valueForKey:@"flightKey"];
            NSString *flightNumber= [fligtKeyDict  objectForKey:@"flightNumber"];
            NSString *airLineCode= [fligtKeyDict objectForKey:@"airlineCode"];
            NSDate *fDate= [fligtKeyDict objectForKey:@"flightDate"];
            NSString * departureStation = [[[flightDict objectForKey:@"legs"] objectAtIndex:0 ]valueForKey:@"origin"];
            NSMutableDictionary *flightDictInput = [[NSMutableDictionary alloc] init];
            if (flightNumber) {
                [flightDictInput setObject:flightNumber forKey:@"flightNumber"];
            }
            else {
                DLog(@"flight number is not available");
            }
            [flightDictInput setObject:airLineCode forKey:@"airlineCode"];
            NSMutableDictionary * dateDict = [[NSMutableDictionary alloc]init];
            NSDateFormatter *fr = [[NSDateFormatter alloc] init];
            [fr setDateFormat:DATEFORMAT1];
            NSString *date = [fr stringFromDate:fDate];
            [dateDict setObject:date forKey:@"departureDate"];
            
            [flightDictInput setObject:dateDict forKey:@"flightDate"];
            [flightDictInput setObject:departureStation forKey:@"departureIATACode"];
            
            NSString *jsonString = [DictionaryParser jsonStringFromDictionary:[NSDictionary dictionaryWithDictionary:flightDictInput]];
            ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
            RequestObject *requset= [[RequestObject alloc] init] ;
            NSString * passengerUri = @"getPassengerList";
            requset.url = [NSString stringWithFormat:@"%@%@",BASEURL,passengerUri];requset.language = @"en_ES";requset.tag = 1;requset.type=@"POST";
            requset.param = jsonString;requset.priority=normal;
            NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
            if (data!=nil  && [data length] > 0) {
                NSDictionary *responseDict =[DictionaryParser dictionaryFromData:data];
                if ([responseDict valueForKey:@"passengerListResponse"] !=nil)
                    [SaveSeatMap savePassengerForFlight:fligtKeyDict andPassengerDict:responseDict];
            }
        }
        
        onComplete();
    });
}
-(void)synchFlightSeatMapOnCompleteByIdFlight:(NSString *) idflights :(void (^)(void))onComplete{
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray * allFlightArray = [self getFlightroaster];
        
        for (NSDictionary * flightDict in allFlightArray) {
           
          if([[[flightDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"] isEqualToString:(NSString *)idflights])
          {
              AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
              NSDictionary *lastLeg = [[flightDict objectForKey:@"legs"] lastObject];
              int diff = [appDel compareDate:[NSDate date] :[lastLeg[@"departureLocal"] toGlobalTime]];
              
              BOOL flightIsInSyncRange = (diff >= 0 && diff <= 60*60*24);
              BOOL isSeatMapSynched = [[flightDict valueForKey:@"isFlightSeatMapSynched"] boolValue];
              
              if (!flightIsInSyncRange || isSeatMapSynched || ![self shouldSyncSeatmapAndPassengerListForFlight:flightDict leg:-1]) {
                  continue;
              }
              
              NSDictionary *fligtKeyDict = [flightDict valueForKey:@"flightKey"];
              NSString *flightNumber= [fligtKeyDict  objectForKey:@"flightNumber"];
              NSString *airLineCode= [fligtKeyDict objectForKey:@"airlineCode"];
              NSDate *fDate= [fligtKeyDict objectForKey:@"flightDate"];
              NSString *departureStation = [[[flightDict objectForKey:@"legs"] objectAtIndex:0 ]valueForKey:@"origin"];
              NSMutableDictionary *flightDictInput = [[NSMutableDictionary alloc] init];
              if (flightNumber) {
                  [flightDictInput setObject:flightNumber forKey:@"flightNumber"];
              }
              else {
                  DLog(@"flight number is not available");
              }
              
              [flightDictInput setObject:airLineCode forKey:@"airlineCode"];
              NSMutableDictionary * dateDict = [[NSMutableDictionary alloc]init];
              NSDateFormatter *fr = [[NSDateFormatter alloc] init];
              [fr setDateFormat:DATEFORMAT1];
              NSString *date = [fr stringFromDate:fDate];
              [dateDict setObject:date forKey:@"departureDate"];
              
              [flightDictInput setObject:dateDict forKey:@"flightDate"];
              [flightDictInput setObject:departureStation forKey:@"departureIATACode"];
              
              NSString *jsonString = [DictionaryParser jsonStringFromDictionary:[NSDictionary dictionaryWithDictionary:flightDictInput]];
              ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
              RequestObject *requset= [[RequestObject alloc] init] ;
              NSString * passengerUri = @"getSeatMap";
              requset.url = [NSString stringWithFormat:@"%@%@",BASEURL,passengerUri];requset.language = @"en_ES";requset.tag = 1; requset.type=@"POST";
              requset.param = jsonString;requset.priority=normal;
              NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
              if (data != nil && [data length] > 0) {
                  NSDictionary *responseDict =[DictionaryParser dictionaryFromData:data];
                  if ([responseDict objectForKey:@"getSeatMap"] != nil || ![[responseDict objectForKey:@"getSeatMap"] isEqualToString:@""])
                      [SaveSeatMap saveSeatMapForFlight:fligtKeyDict andSeatMap:responseDict];
                  
              }

            
          }
        }
        
        onComplete();
    //});
    
}
-(void)synchFlightSeatMapOnComplete:(void (^)(void))onComplete {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray * allFlightArray = [self getFlightroaster];
        
        for (NSDictionary * flightDict in allFlightArray) {
            
            AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSDictionary *lastLeg = [[flightDict objectForKey:@"legs"] lastObject];
            int diff = [appDel compareDate:[NSDate date] :[lastLeg[@"departureLocal"] toGlobalTime]];
            
            BOOL flightIsInSyncRange = (diff >= 0 && diff <= 60*60*24);
            BOOL isSeatMapSynched = [[flightDict valueForKey:@"isFlightSeatMapSynched"] boolValue];
            
            if (!flightIsInSyncRange || isSeatMapSynched || ![self shouldSyncSeatmapAndPassengerListForFlight:flightDict leg:-1]) {
                continue;
            }
            
            NSDictionary *fligtKeyDict = [flightDict valueForKey:@"flightKey"];
            NSString *flightNumber= [fligtKeyDict  objectForKey:@"flightNumber"];
            NSString *airLineCode= [fligtKeyDict objectForKey:@"airlineCode"];
            NSDate *fDate= [fligtKeyDict objectForKey:@"flightDate"];
            NSString *departureStation = [[[flightDict objectForKey:@"legs"] objectAtIndex:0 ]valueForKey:@"origin"];
            NSMutableDictionary *flightDictInput = [[NSMutableDictionary alloc] init];
            if (flightNumber) {
                [flightDictInput setObject:flightNumber forKey:@"flightNumber"];
            }
            else {
                DLog(@"flight number is not available");
            }
            
            [flightDictInput setObject:airLineCode forKey:@"airlineCode"];
            NSMutableDictionary * dateDict = [[NSMutableDictionary alloc]init];
            NSDateFormatter *fr = [[NSDateFormatter alloc] init];
            [fr setDateFormat:DATEFORMAT1];
            NSString *date = [fr stringFromDate:fDate];
            [dateDict setObject:date forKey:@"departureDate"];
            
            [flightDictInput setObject:dateDict forKey:@"flightDate"];
            [flightDictInput setObject:departureStation forKey:@"departureIATACode"];
            
            NSString *jsonString = [DictionaryParser jsonStringFromDictionary:[NSDictionary dictionaryWithDictionary:flightDictInput]];
            ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
            RequestObject *requset= [[RequestObject alloc] init] ;
            NSString * passengerUri = @"getSeatMap";
            requset.url = [NSString stringWithFormat:@"%@%@",BASEURL,passengerUri];requset.language = @"en_ES";requset.tag = 1; requset.type=@"POST";
            requset.param = jsonString;requset.priority=normal;
            NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
            if (data != nil && [data length] > 0) {
                NSDictionary *responseDict =[DictionaryParser dictionaryFromData:data];
                if ([responseDict objectForKey:@"getSeatMap"] != nil || ![[responseDict objectForKey:@"getSeatMap"] isEqualToString:@""])
                    [SaveSeatMap saveSeatMapForFlight:fligtKeyDict andSeatMap:responseDict];
                
            }
        }
        
        onComplete();
    });
}

-(void)getBookingInfo:(NSMutableDictionary*)newflightDict {
    NSLog(@"flight`dict==%@",newflightDict);
    NSMutableDictionary *reqDict = [[NSMutableDictionary alloc] init];
    [reqDict setObject:[newflightDict objectForKey:@"airlineCode"] forKey:@"airlineCode"];
    [reqDict setObject:[newflightDict objectForKey:@"flightNumber"] forKey:@"flightNumber"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATEFORMAT];
    [reqDict setObject:[formatter stringFromDate:[newflightDict objectForKey:@"flightDate"]] forKey:@"flightDate"];
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    singleton=[LTSingleton getSharedSingletonInstance];
    [connection loginCredentials:singleton.username :singleton.password];
    RequestObject *requset= [[RequestObject alloc] init];
    requset.url = [NSString stringWithFormat:@"%@getBookingInformation",BASEURL];requset.language = @"en_ES";requset.tag = 1;requset.type=@"POST"; requset.param = [DictionaryParser jsonStringFromDictionary:reqDict];
    NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
    if (data!=nil) {
        NSDictionary *responseDic = [DictionaryParser dictionaryFromData:data];
        
        if([[[responseDic objectForKey:@"getBookingInformation"] objectForKey:@"response"] isKindOfClass:[NSDictionary class]]){
            [UserInformationParser saveBookingInfo:responseDic forFlight:newflightDict];
        }
    }
}

-(NSMutableDictionary*)sendManualflightForChecking:(NSMutableDictionary *)newflightDict {
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *flightDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *flight = [[NSMutableDictionary alloc] init];
    [flightDic setObject:flight forKey:@"flight"];
    [flight setObject:[newflightDict objectForKey:@"airlineCode"] forKey:@"airlineCode"];
    [flight setObject:[newflightDict objectForKey:@"flightNumber"] forKey:@"flightNumber"];
    [flight setObject:@"_" forKey:@"suffix"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATEFORMAT];
    [flight setObject:[formatter stringFromDate:[newflightDict objectForKey:@"flightDate"]] forKey:@"flightDate"];
    NSMutableArray *legArray = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *legDic in [newflightDict objectForKey:@"legs"]) {
        NSMutableDictionary *legDict = [[NSMutableDictionary alloc] init];
        [legDict setObject:[legDic objectForKey:@"origin"] forKey:@"origin"];
        [legDict setObject:[legDic objectForKey:@"destination"] forKey:@"destination"];
        [legDict setObject:[formatter stringFromDate:[legDic objectForKey:@"legArrivalLocal"]] forKey:@"legArrivalLocal"];
        [legDict setObject:[formatter stringFromDate:[legDic objectForKey:@"legDepartureLocal"]] forKey:@"legDepartureLocal"];
        [legArray addObject:legDict];
    }
    [flight setObject:legArray forKey:@"legs"];
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    singleton = [LTSingleton getSharedSingletonInstance];
    [connection loginCredentials:singleton.username :singleton.password];
    RequestObject *requset = [[RequestObject alloc] init];
    requset.url = [NSString stringWithFormat:@"%@manualFlights",BASEURL];requset.language = @"en_ES";requset.tag = 1; requset.type = @"POST"; requset.param = [DictionaryParser jsonStringFromDictionary:flightDic];
    
    NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
    if (data != nil) {
        NSDictionary *responseDic = [DictionaryParser dictionaryFromData:data];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseDic objectForKey:@"manualFlightResource"] copyItems:YES];
        responseDic = nil;
        if(![[dict objectForKey:@"response"] isKindOfClass:[NSDictionary class]]) {
            ShouldAdd = NO;
        }
        else if ([[dict objectForKey:@"response"] objectForKey:@"links"] != nil) {
            
            [newflightDict setObject:[[dict objectForKey:@"response"] objectForKey:@"links"] forKey:@"links"];
            [newflightDict setObject:[NSNumber numberWithInt:manuFlightSynched] forKey:@"isManualyEntered"];
            ShouldAdd = YES;
        } else {
            ShouldAdd = NO;
            NSArray *statusArr=[dict objectForKey:@"serviceStatus"];
            
            NSString *msg = @"";
            if ([statusArr count] > 0) {
                
                if (appDel.currentLanguage == LANG_SPANISH) {
                    msg = [[[statusArr objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"es"];
                } else if (appDel.currentLanguage == LANG_PORTUGUESE) {
                    msg = [[[statusArr objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"pt"];
                }
                if ([LTSingleton getSharedSingletonInstance].synchStatus) {
                    [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"STATUS_ERROR"] message:msg];
                    
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"STATUS_ERROR"] message:msg delegate:nil cancelButtonTitle:KOkButtonTitle otherButtonTitles: nil];
                    [alert show];
                }
                
            }
        }
    } else {
        ShouldAdd = YES;
    }
    return newflightDict;
}

+(NSMutableDictionary*)getFlightDictByIdFlight:(FlightRoaster*)flightRoster:(NSString*)idFlight {
    NSMutableDictionary *fkeydict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dict;
    
    NSArray *DataArray;
    for (NSMutableDictionary *fkeydict in DataArray) {
        if([[[fkeydict objectForKey:@"flightKey"] objectForKey:@"flightNumber"] isEqualToString:(NSString *)idFlight])
        {
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
                dict=NULL;
            }
            
        }
    }
    return dict;
}

-(void)syncCusReportsForFlightRosterIndividualCUS:(FlightRoaster*)flight:(NSString*)idflight:(NSString*)idReport:(NSString*)idCustomer{
    
    Uris *uris = flight.flightUri ;
    
    
    NSString *url = [NSString stringWithFormat:@"%@%@",URI,uris.cus];
    
   // NSMutableDictionary *fkeydict = [[NSMutableDictionary alloc] init];

    NSMutableDictionary *fKeyDict = [LTCUSData getFlightDict:flight];
    
     NSArray *statArray = [UserInformationParser getStatusForAllFlights];
    BOOL allDoneNow = NO;
    for(NSDictionary *flightDict in statArray) {
        if([[flightDict objectForKey:@"flightNumber"] isEqualToString:(NSString *)idflight])
        {
            for(NSDictionary *cusReportDict in flightDict[@"CUS"]) {
                
                NSString *idReporte = [cusReportDict objectForKey:@"reportId"];
                 NSString *idCustomers =[cusReportDict objectForKey:@"customerId"];
                
                if([idReporte isEqualToString:(NSString*)idReport])
                {
                    if([idCustomers isEqualToString:(NSString*)idCustomer])
                    {
                        if([[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"] isEqualToString:(NSString *)idflight])
                        {
                            if([[fKeyDict allKeys] count] > 0) {
                                
                                NSArray *legs = [[fKeyDict objectForKey:@"flightKey"] objectForKey:@"legs"];
                                
                                NSMutableArray *array = [[NSMutableArray alloc] init];
                                
                                for (int i = 0; i < legs.count; i++) {
                                    Legs *leg = (Legs *) [legs objectAtIndex:i];
                                    NSArray *customerArray = [[leg legCustomer] array];
                                    [array addObjectsFromArray:customerArray];
                                }
                                
                                if([array count] > 0) {
                                    
                                 for (Customer *customer in array)
                                 {
                                        
                                    if([customer.customerId isEqualToString:(NSString *)idCustomer])
                                    {
                                        for (CusReport *report in [customer.cusCusReport array])
                                        {
                                            
                                            if([report.reportId isEqualToString:(NSString *)idReport])
                                            {
                                                
                                                NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
                                                [dateFormate setDateFormat:@"ddMM"];
                                                NSString *flightDateStr = [dateFormate stringFromDate:[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightDate"]];
                                                
                                                NSString *reportIdFormation = @"";
                                                if(nil != flightDateStr)
                                                    reportIdFormation = [reportIdFormation stringByAppendingString:flightDateStr];
                                                else
                                                    break;
                                                if(nil != [fKeyDict objectForKey:@"flightKey"])
                                                    reportIdFormation = [reportIdFormation stringByAppendingString:[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]];
                                                
                                                else
                                                    break;
                                                //reportIdFormation = @"";
                                                if(nil != customer.docNumber)
                                                    reportIdFormation = [reportIdFormation stringByAppendingString:customer.docNumber];
                                                else
                                                    break;
                                                reportIdFormation = [reportIdFormation stringByAppendingString:report.reportId];
                                                [[fKeyDict objectForKey:@"flightKey"] setObject:reportIdFormation forKey:@"reportId"];
                                                
                                                // NOTE(diego_cath): LAN requested that if doc number is missing, we should use frequent flyer number instead. May 23rd 2016
                                                
                                                if(customer.docNumber != nil && [customer.docNumber isEqualToString:@""] == NO) {
                                                    [[fKeyDict objectForKey:@"flightKey"] setObject:customer.docNumber forKey:@"docNumber"];
                                                }
                                                else if(customer.freqFlyerNum != nil && [customer.freqFlyerNum isEqualToString:@""] == NO) {
                                                    [[fKeyDict objectForKey:@"flightKey"] setObject:customer.freqFlyerNum forKey:@"docNumber"];
                                                }
                                                
                                                [[fKeyDict objectForKey:@"flightKey"] setObject:customer.customerId forKey:@"customerId"];
                                                // if([report.status intValue] == inqueue) {
                                                
                                                NSString *type;
                                                if([flight.type containsString:@"TAM"]) {
                                                    type = @"TAM";
                                                } else {
                                                    type = @"LAN";
                                                }
                                                
                                                CUSImages *cusImages = report.reportCusImages;
                                                BOOL hasAttachments = NO;
                                                
                                                if((nil != cusImages.image1 && [cusImages.image1 length] > 0) ||
                                                   (nil != cusImages.image2 && [cusImages.image2 length] > 0) ||
                                                   (nil != cusImages.image3 && [cusImages.image3 length] > 0) ||
                                                   (nil != cusImages.image4 && [cusImages.image4 length] > 0) ||
                                                   (nil != cusImages.image5 && [cusImages.image5 length] > 0)
                                                   )
                                                    hasAttachments = YES;
                                                
                                                
                                                if ([self checkCUSStatusBool:fKeyDict withUploadURL:report.imageLoadUrl isFromSunc:YES forReportId:report.reportId]){
                                                    
                                                    allDoneNow = YES;
                                                    break;
                                                }

                                                
                                                NSString *cusString = [LTCUSData getCUSJsonReportForDict:fKeyDict customer:(Customer*)customer forType:type forReportId:report.reportId];
                                                singleton=[LTSingleton getSharedSingletonInstance];
                                                DLog(@"CUS json:%@", cusString);
                                                DLog(@"CUS url:%@", url);
                                                
                                                RequestObject *requset = [[RequestObject alloc] init] ;
                                                requset.url = url;
                                                requset.language = @"en_ES";
                                                requset.tag = 1;
                                                requset.type = @"POST";
                                                requset.param = cusString;
                                                requset.priority = normal;
                                                
                                                ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
                                                
                                                NSData *jsonData=[connection sendSynchronousCallWithUrl:requset error:nil];
                                                
                                                NSDictionary *responseDict;
                                                
                                                if (jsonData != nil) {
                                                    NSString *statusCode;
                                                    responseDict =[DictionaryParser dictionaryFromData:jsonData];
                                                    
//                                                    if ([self checkCUSStatusBool:fKeyDict withUploadURL:report.imageLoadUrl isFromSunc:YES forReportId:report.reportId]){
//    
//                                                        allDoneNow = YES;
//                                                        break;
//                                                    }
                                                    
                                                    NSLog(@"CUS response : %@",responseDict);
                                                    
                                                    if(hasAttachments){
                                                        
                                                        statusCode = [[responseDict objectForKey:@"CreateReport"] objectForKey:@"status"];
                                                    }else {
                                                        statusCode = [[responseDict objectForKey:@"CreateReport"] objectForKey:@"status"];
                                                    }
                                                    
                                                    if(nil != statusCode && [statusCode integerValue] == 1) {
                                                        
                                                        if(hasAttachments) {
                                                            
                                                            if ([[responseDict objectForKey:@"CreateReport"] objectForKey:@"links"]!=nil){
                                                                if([[[responseDict objectForKey:@"CreateReport"] objectForKey:@"links"] objectForKey:@"uriUploadImages"])
                                                                {
                                                                    [LTCUSData updateCUSStatusIndividual:responseDict status:sent flightDict:fKeyDict forReportId:report.reportId];
                                                                    
                                                                    NSString *uri = [[[responseDict objectForKey:@"CreateReport"] objectForKey:@"links"] objectForKey:@"uriUploadImages"];
                                                                    
                                                                    [LTCUSData updateCUSimageURL:uri withFlightInfo:[fKeyDict objectForKey:@"flightKey"] forReportid:report.reportId];
                                                                    
                                                                    [self sendImagesZipFor:CUS forFlight:fKeyDict onURI:uri withCheckStatus:YES];
                                                                    [self checkCUSStatus:fKeyDict withUploadURL:nil isFromSunc:YES forReportId:report.reportId];
                                                                }
                                                                else {
                                                                    [LTCUSData updateCUSStatusIndividual:responseDict status:eror flightDict:fKeyDict forReportId:report.reportId];
                                                                }
                                                            }
                                                        } else {
                                                            [LTCUSData updateCUSStatusIndividual:responseDict status:sent flightDict:fKeyDict forReportId:report.reportId];
                                                            [self checkCUSStatus:fKeyDict withUploadURL:nil isFromSunc:YES forReportId:report.reportId];
                                                            
                                                            allDoneNow = YES;
                                                            break;
                                                        }
                                                    }
                                                    else {
                                                        NSArray *statusArray=[responseDict objectForKey:@"serviceStatus"];
                                                        if([statusArray count]>0) {
                                                            NSString *msg;
                                                            AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                                            if(appdel.currentLanguage==LANG_SPANISH) {
                                                                msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"es"];
                                                            } else {
                                                                msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"pt"];
                                                            }
                                                            [errorDict setValue:msg forKey:[NSString stringWithFormat:@"Vuelo/Vôo: %@%@\nMódulo: CUS\nID: %@\n",[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"airlineCode" ],[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"],
                                                                                            [[fKeyDict objectForKey:@"flightKey"] objectForKey:@"docNumber"]
                                                                                            ]];
                                                            [LTCUSData updateCUSStatusIndividual:responseDict status:eror flightDict:fKeyDict forReportId:report.reportId];
                                                        }
                                                    }
                                                    
                                                }
                                                else if([report.status intValue] == ee || [report.status intValue] == ea || [report.status intValue] == eror ||[report.status intValue] == sent) {
                                                    [self checkCUSStatus:fKeyDict withUploadURL:report.imageLoadUrl isFromSunc:YES forReportId:report.reportId];
                                                    
                                                    allDoneNow = YES;
                                                    break;
                                                }
                                                [self checkCUSStatus:fKeyDict withUploadURL:report.imageLoadUrl isFromSunc:YES forReportId:report.reportId];
                                            }
  
                                        }//Fin For Report
                                     }
                                 } //Fin For Customers
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
               if (allDoneNow) break;
            }
            
        }
        
    }
   
    
}
-(void)syncCusReportsForFlightRoster:(FlightRoaster*)flight {
    
    Uris *uris = flight.flightUri ;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",URI,uris.cus];
    
    NSMutableDictionary *fKeyDict = [LTCUSData getFlightDict:flight];
    
    if([[fKeyDict allKeys] count] > 0) {
        
        NSArray *legs = [[fKeyDict objectForKey:@"flightKey"] objectForKey:@"legs"];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < legs.count; i++) {
            Legs *leg = (Legs *) [legs objectAtIndex:i];
            NSArray *customerArray = [[leg legCustomer] array];
            [array addObjectsFromArray:customerArray];
        }
        
        if([array count] > 0) {
            
            for (Customer *customer in array) {
                for (CusReport *report in [customer.cusCusReport array]) {
                    
                    NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
                    [dateFormate setDateFormat:@"ddMM"];
                    NSString *flightDateStr = [dateFormate stringFromDate:[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightDate"]];
                    
                    NSString *reportIdFormation = @"";
                    if(nil != flightDateStr)
                        reportIdFormation = [reportIdFormation stringByAppendingString:flightDateStr];
                    else
                        break;
                    if(nil != [fKeyDict objectForKey:@"flightKey"])
                        reportIdFormation = [reportIdFormation stringByAppendingString:[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]];
                    else
                        break;
                    
                    if(nil != customer.docNumber)
                        reportIdFormation = [reportIdFormation stringByAppendingString:customer.docNumber];
                    else
                        break;
                    reportIdFormation = [reportIdFormation stringByAppendingString:report.reportId];
                    [[fKeyDict objectForKey:@"flightKey"] setObject:reportIdFormation forKey:@"reportId"];
                    
                    // NOTE(diego_cath): LAN requested that if doc number is missing, we should use frequent flyer number instead. May 23rd 2016
                    
                    if(customer.docNumber != nil && [customer.docNumber isEqualToString:@""] == NO) {
                        [[fKeyDict objectForKey:@"flightKey"] setObject:customer.docNumber forKey:@"docNumber"];
                    }
                    else if(customer.freqFlyerNum != nil && [customer.freqFlyerNum isEqualToString:@""] == NO) {
                        [[fKeyDict objectForKey:@"flightKey"] setObject:customer.freqFlyerNum forKey:@"docNumber"];
                    }
                    
                    [[fKeyDict objectForKey:@"flightKey"] setObject:customer.customerId forKey:@"customerId"];
                    if([report.status intValue] == inqueue) {
                        
                        NSString *type;
                        if([flight.type containsString:@"TAM"]) {
                            type = @"TAM";
                        } else {
                            type = @"LAN";
                        }
                        
                        CUSImages *cusImages = report.reportCusImages;
                        BOOL hasAttachments = NO;
                        
                        if((nil != cusImages.image1 && [cusImages.image1 length] > 0) ||
                           (nil != cusImages.image2 && [cusImages.image2 length] > 0) ||
                           (nil != cusImages.image3 && [cusImages.image3 length] > 0) ||
                           (nil != cusImages.image4 && [cusImages.image4 length] > 0) ||
                           (nil != cusImages.image5 && [cusImages.image5 length] > 0)
                           )
                            hasAttachments = YES;
                        
                        NSString *cusString = [LTCUSData getCUSJsonReportForDict:fKeyDict customer:(Customer*)customer forType:type forReportId:report.reportId];
                        singleton=[LTSingleton getSharedSingletonInstance];
                        DLog(@"CUS json:%@", cusString);
                        DLog(@"CUS url:%@", url);
                        
                        RequestObject *requset = [[RequestObject alloc] init] ;
                        requset.url = url;
                        requset.language = @"en_ES";
                        requset.tag = 1;
                        requset.type = @"POST";
                        requset.param = cusString;
                        requset.priority = normal;
                        
                        ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
                        
                        NSData *jsonData=[connection sendSynchronousCallWithUrl:requset error:nil];
                        
                        NSDictionary *responseDict;
                        
                        if (jsonData != nil) {
                            NSString *statusCode;
                            responseDict =[DictionaryParser dictionaryFromData:jsonData];
                            
                            NSLog(@"CUS response : %@",responseDict);
                            
                            if(hasAttachments){
                                
                                statusCode = [[responseDict objectForKey:@"CreateReport"] objectForKey:@"status"];
                            }
                            else {
                                statusCode = [[responseDict objectForKey:@"CreateReport"] objectForKey:@"status"];
                            }
                            
                            if(nil != statusCode && [statusCode integerValue] == 1) {
                                if(hasAttachments) {
                                    
                                    if ([[responseDict objectForKey:@"CreateReport"] objectForKey:@"links"]!=nil){
                                        if([[[responseDict objectForKey:@"CreateReport"] objectForKey:@"links"] objectForKey:@"uriUploadImages"])
                                        {
                                            [LTCUSData updateCUSStatus:responseDict status:sent flightDict:fKeyDict forReportId:report.reportId];
                                            
                                            NSString *uri = [[[responseDict objectForKey:@"CreateReport"] objectForKey:@"links"] objectForKey:@"uriUploadImages"];
                                            
                                            [LTCUSData updateCUSimageURL:uri withFlightInfo:[fKeyDict objectForKey:@"flightKey"] forReportid:report.reportId];
                                            
                                            [self sendImagesZipFor:CUS forFlight:fKeyDict onURI:uri withCheckStatus:YES];
                                            [self checkCUSStatus:fKeyDict withUploadURL:nil isFromSunc:YES forReportId:report.reportId];
                                        }
                                        else {
                                            [LTCUSData updateCUSStatus:responseDict status:eror flightDict:fKeyDict forReportId:report.reportId];
                                        }
                                    }
                                } else {
                                    [LTCUSData updateCUSStatus:responseDict status:sent flightDict:fKeyDict forReportId:report.reportId];
                                    [self checkCUSStatus:fKeyDict withUploadURL:nil isFromSunc:YES forReportId:report.reportId];
                                }
                            }
                            else {
                                NSArray *statusArray=[responseDict objectForKey:@"serviceStatus"];
                                if([statusArray count]>0) {
                                    NSString *msg;
                                    AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                    if(appdel.currentLanguage==LANG_SPANISH) {
                                        msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"es"];
                                    } else {
                                        msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"pt"];
                                    }
                                    [errorDict setValue:msg forKey:[NSString stringWithFormat:@"Vuelo/Vôo: %@%@\nMódulo: CUS\nID: %@\n",[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"airlineCode" ],[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"],
                                                                    [[fKeyDict objectForKey:@"flightKey"] objectForKey:@"docNumber"]
                                                                    ]];
                                    [LTCUSData updateCUSStatus:responseDict status:eror flightDict:fKeyDict forReportId:report.reportId];
                                }
                            }
                        }
                    } else if([report.status intValue] == ee || [report.status intValue] == ea || [report.status intValue] == eror ||[report.status intValue] == sent) {
                        [self checkCUSStatus:fKeyDict withUploadURL:report.imageLoadUrl isFromSunc:YES forReportId:report.reportId];
                    }
                }
            }
        }
    }
}

-(void)syncCusReportWithCompletionHandlerByIdflight:(NSString*)dateflight:(NSString*)idflight:(NSString*)idReport:(NSString*)idCustomer:(void (^)(void))block {
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
        [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        NSArray *arra = [LTCUSData createCUSReportForAllFlights:managedObjectContext];
       BOOL allDoneNow = NO;
        for (FlightRoaster *flight in arra)
        {
           if ([flight.flightNumber isEqualToString:(NSString *)idflight])
           {
                NSData *fecha = flight.flightDate;
                NSString *fechaFnl = @"";
               @try {

                   if (fecha != nil){
                       
                       NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                       [dateformate setDateFormat:@"yyyy-MM-dd"]; // Date formater
                       fechaFnl = [dateformate stringFromDate:fecha];
                   }
                   
               }
               @catch (NSException *exception) {
                   DLog(@"exception handled==%@",exception.description);
               }

               if ([fechaFnl isEqualToString:(NSString *)dateflight])
               {
                   NSArray *statArray = [UserInformationParser getStatusForAllFlights];
                   for(NSDictionary *flightDict in statArray)
                   {
                       for(NSDictionary *cusReportDict in flightDict[@"CUS"])
                       {
                           NSString *idReporte =[cusReportDict objectForKey:@"reportId"];
                           NSString *idCustomers =[cusReportDict objectForKey:@"customerId"];
                           
                           if([idReporte isEqualToString:(NSString*)idReport])
                           {
                               if([idCustomers isEqualToString:(NSString*)idCustomer])
                               {
                                   [self syncCusReportsForFlightRosterIndividualCUS:flight:(NSString*)idflight:(NSString*)idReport:(NSString*)idCustomer];
                                   allDoneNow = YES;
                                   break;
                               }
                           }
                           
                       }
                       if (allDoneNow) break;
                   }

                   
               }
                          }
            if (allDoneNow) break;
        }
        
        block();
   // });
}

-(void)syncCusReportWithCompletionHandler:(void (^)(void))block {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
        [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        NSArray *arra = [LTCUSData createCUSReportForAllFlights:managedObjectContext];
        for (FlightRoaster *flight in arra) {
            
            [self syncCusReportsForFlightRoster:flight];
        }
        
        block();
    });
}

-(void)sendCUSReportforCustomer:(NSDictionary *)customerdict forFlight:(NSMutableDictionary *)flightKeyDict forleg:(int)legNo forReportId:(NSString*)reportId fromSync:(BOOL)isfromSync {
    DLog(@"SendCUS");
    if([self checkForInternetAvailability]) {
        ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
        
        singleton = [LTSingleton getSharedSingletonInstance];
        
        [connection loginCredentials:singleton.username: singleton.password];
        
        connection.serviceTags = kCUSREPORT;
        connection.delegate = self;
        
        AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        
        [managedObjectContext setPersistentStoreCoordinator:appDel.persistentStoreCoordinator];
        
        [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        FlightRoaster *flight = [LTCUSData getFlight1:flightKeyDict withContext:managedObjectContext];
        
        Uris *uris = flight.flightUri;
        
        NSString *url = [NSString stringWithFormat:@"%@%@",URI,uris.cus];
        
        NSMutableDictionary *fKeyDict = [[LTCUSData getFlightDict:flight] copy];
        
        if(nil != flight) {
            
            Legs *leg = [[flight.flightInfoLegs array] objectAtIndex:legNo];
            
            NSString *customerId = [customerdict objectForKey:@"CUSTOMERID"];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerId ==%@", customerId];
            
            NSArray *results = [[leg.legCustomer array] filteredArrayUsingPredicate:predicate];
            if([results count]>0){
                
                Customer *customer = [results objectAtIndex:0];
                predicate = [NSPredicate predicateWithFormat:@"reportId == %@",reportId];
                CusReport *cusReport = (CusReport *)[[[customer.cusCusReport array] filteredArrayUsingPredicate:predicate] firstObject];
                
                NSLog(@"customer status is %@",cusReport.status);
                
                if(flight.isManualyEntered == [NSNumber numberWithInt:manuFlightErrored]){
                    
                    NSDictionary *customerDictwithId = [NSDictionary dictionaryWithObjectsAndKeys:customer.customerId,@"", nil];
                    
                    [LTSaveCUSData modifyStatus:draft forCustomer:customerDictwithId forLeg:legNo forFlight:flightKeyDict forReportId:reportId];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_FLIGHTLIST object:nil userInfo:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCUSTable" object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"BackViewRefresh" object:nil];
                    });
                    
                } else if([cusReport.status intValue] == inqueue)   {
                    
                    NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
                    
                    [dateFormate setDateFormat:@"ddMM"];
                    NSString *flightDateStr = [dateFormate stringFromDate:[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightDate"]];
                    
                    NSString *reportIdFormation = @"";
                    if(nil != flightDateStr)
                        reportIdFormation = [reportIdFormation stringByAppendingString:flightDateStr];
                    else
                        return;
                    if(nil != [[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"])
                        reportIdFormation = [reportIdFormation stringByAppendingString:[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]];
                    else
                        return;
                    if(nil != customer.docNumber)
                        reportIdFormation = [reportIdFormation stringByAppendingString:customer.docNumber];
                    
                    else
                        return;
                    reportIdFormation = [reportIdFormation stringByAppendingString:reportId];
                    
                    [[fKeyDict objectForKey:@"flightKey"] setObject:reportIdFormation forKey:@"reportId"];
                    
                    // NOTE(diego_cath): LAN requested that if doc number is missing, we should use frequent flyer number instead. May 23rd 2016
                    
                    if(customer.docNumber != nil && [customer.docNumber isEqualToString:@""] == NO) {
                        [[fKeyDict objectForKey:@"flightKey"] setObject:customer.docNumber forKey:@"docNumber"];
                    }
                    else if(customer.freqFlyerNum != nil && [customer.freqFlyerNum isEqualToString:@""] == NO) {
                        [[fKeyDict objectForKey:@"flightKey"] setObject:customer.freqFlyerNum forKey:@"docNumber"];
                    }
                    
                    [[fKeyDict objectForKey:@"flightKey"] setObject:customer.customerId forKey:@"customerId"];
                    
                    
                    NSString *type;
                    if([flight.type containsString:@"TAM"]) {
                        type = @"TAM";
                    } else {
                        type = @"LAN";
                    }
                    
                    CUSImages *cusImages = cusReport.reportCusImages;
                    BOOL hasAttachments = NO;
                    
                    if((nil != cusImages.image1 && [cusImages.image1 length]>0) ||
                       (nil != cusImages.image2 && [cusImages.image2 length]>0) ||
                       (nil != cusImages.image3 && [cusImages.image3 length]>0) ||
                       (nil != cusImages.image4 && [cusImages.image4 length]>0) ||
                       (nil != cusImages.image5 && [cusImages.image5 length]>0)
                       )
                        hasAttachments = YES;
                    
                    NSString *cusString = [LTCUSData getCUSJsonReportForDict:fKeyDict customer:(Customer*)customer forType:type forReportId:reportId];
                    DLog(@"CUS url:%@",url);
                    DLog(@"CUS json:%@",cusString);
                    
                    
                    RequestObject *requset = [[RequestObject alloc] init] ;
                    requset.url = url;
                    requset.language = @"en_ES";
                    requset.tag = 1;
                    requset.type = @"POST";
                    requset.param = cusString;
                    requset.priority = normal;
                    
                    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
                    
                    NSData *jsonData=[connection sendSynchronousCallWithUrl:requset error:nil];
                    
                    NSDictionary *responseDict;
                    if (jsonData != nil) {
                        
                        responseDict =[DictionaryParser dictionaryFromData:jsonData];
                        
                        DLog(@"CUS Response:%@",responseDict);
                        
                        NSString *statusCode;
                        
                        if(hasAttachments) {
                            
                            statusCode = [[responseDict objectForKey:@"CreateReport"] objectForKey:@"status"];
                        }
                        else {
                            statusCode = [[responseDict objectForKey:@"CreateReport"] objectForKey:@"status"];
                        }
                        
                        if(nil != statusCode && [statusCode integerValue] == 1) {
                            if(hasAttachments) {
                                
                                if ([[responseDict objectForKey:@"CreateReport"] objectForKey:@"links"]!=nil){
                                    if([[[responseDict objectForKey:@"CreateReport"] objectForKey:@"links"] objectForKey:@"uriUploadImages"]) {
                                        [LTCUSData updateCUSStatus:responseDict status:sent flightDict:fKeyDict forReportId:reportId];
                                        
                                        NSString *uri = [[[responseDict objectForKey:@"CreateReport"] objectForKey:@"links"] objectForKey:@"uriUploadImages"];
                                        
                                        [LTCUSData updateCUSimageURL:uri withFlightInfo:[fKeyDict objectForKey:@"flightKey"] forReportid:reportId ];
                                        
                                        [self sendImagesZipFor:CUS forFlight:fKeyDict onURI:uri withCheckStatus:YES];
                                        [self checkCUSStatus:fKeyDict withUploadURL:nil isFromSunc:isfromSync forReportId:reportId];
                                        
                                    }
                                    else {
                                        [LTCUSData updateCUSStatus:responseDict status:eror flightDict:fKeyDict forReportId:reportId];
                                    }
                                }
                            } else {
                                [LTCUSData updateCUSStatus:responseDict status:sent flightDict:fKeyDict forReportId:reportId];
                                // [self checkCUSStatus:fKeyDict withUploadURL:nil isFromSunc:isfromSync];
                            }
                            
                        }
                        else if(!isfromSync) {
                            
                            NSArray *statusArray=[responseDict objectForKey:@"serviceStatus"];
                            
                            if([statusArray count] > 0) {
                                NSString *msg;
                                AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                if (appdel.currentLanguage==LANG_SPANISH) {
                                    msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"es"];
                                } else {
                                    msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"pt"];
                                }
                                [errorDict setValue:msg forKey:[NSString stringWithFormat:@"Vuelo/Vôo: %@%@\nMódulo: CUS\nID: %@\n",[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"airlineCode" ],[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"],
                                                                [[fKeyDict objectForKey:@"flightKey"] objectForKey:@"docNumber"]
                                                                ]];
                                
                                NSString *str= [NSString stringWithFormat:@"%@\n%@\n",[NSString stringWithFormat:@"Vuelo/Vôo: %@%@\nMódulo: CUS\nID: %@\n",[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"airlineCode" ],[[fKeyDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"],
                                                                                       [[fKeyDict objectForKey:@"flightKey"] objectForKey:@"docNumber"]
                                                                                       ],msg];
                                
                                [LTCUSData updateCUSStatus:responseDict status:eror flightDict:fKeyDict forReportId:reportId];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                    
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appdel copyTextForKey:@"ERROR_LABEL"] message:str
                                                                                       delegate:nil
                                                                              cancelButtonTitle:KOkButtonTitle
                                                                              otherButtonTitles:nil];
                                    [alertView show];
                                });
                            }
                        }
                    }
                }
            }
        }
    }
}
-(BOOL)checkCUSStatusBool :(NSMutableDictionary*)flightDict withUploadURL:(NSString*)imageLoadUrl isFromSunc:(BOOL)fromSync forReportId:(NSString*)cusreportId {
    
    BOOL transstatus=false;
    
    NSMutableDictionary *statusDict = [LTCUSData getCusFlightDict:flightDict forReportId:cusreportId];
    /* ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
     singleton=[LTSingleton getSharedSingletonInstance];
     [connection loginCredentials:singleton.username :singleton.password];
     connection.serviceTags = kCHECKSTATUS;
     connection.delegate = self; */
    NSString *url = [NSString stringWithFormat:@"%@%@",BASEURL,CHECKSTATUS_URI];
    NSString *postJson = [DictionaryParser jsonStringFromDictionary:statusDict];
    
    DLog(@"CUS status json:%@",postJson);
    DLog(@"CUS status url:%@",url);
    
    RequestObject *requset = [[RequestObject alloc] init] ;
    requset.url = url;
    requset.language = @"en_ES";
    requset.tag = 1;
    requset.type = @"POST";
    requset.param = postJson;
    requset.priority = normal;
    
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    
    NSMutableData *jsonData = [connection sendSynchronousCallWithUrl:requset error:nil];
    
    NSDictionary *responseDict = [DictionaryParser dictionaryFromData:jsonData];
    
    if([[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"]) {
        NSDictionary *dict = [[[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"] objectAtIndex:0];
        NSString *status = [[[dict objectForKey:@"status"] objectAtIndex:0]objectForKey:@"status"];
        DLog(@"CUS status response:%@",responseDict);
        
        if([status isEqualToString:@"OK"]) {
            [LTCUSData updateCUSStatus:dict status:ok flightDict:flightDict forReportId:cusreportId];
            transstatus=true;
        }
        else if([status isEqualToString:@"ER"] || [status isEqualToString:@"NOT_SENT"]) {
            int attmpts = [LTCUSData updateCUSStatus:dict status:inqueue flightDict:flightDict forReportId:cusreportId];
            [LTCUSData updateCUSStatus:dict status:eror flightDict:flightDict forReportId:cusreportId];
            transstatus=true;
        }
        else if([status isEqualToString:@"EE"]) {
            [LTCUSData updateCUSStatus:dict status:ee flightDict:flightDict forReportId:cusreportId];
            transstatus=true;
        }
        else if ([status isEqualToString:@"EA"]) {
            int attempts = [LTCUSData updateCUSStatus:dict status:ea flightDict:flightDict forReportId:cusreportId];
            transstatus=true;
            if(attempts == 0) {
                [self sendImagesZipFor:CUS forFlight:flightDict onURI:imageLoadUrl withCheckStatus:YES];
            } else {
                [LTCUSData updateCUSStatus:dict status:ok flightDict:flightDict forReportId:cusreportId];
            }
        }
        else if([status isEqualToString:@"WF"]) {
            int attempts = [LTCUSData updateCUSStatus:dict status:wf flightDict:flightDict forReportId:cusreportId];
            [LTCUSData updateCUSStatus:dict status:ok flightDict:flightDict forReportId:cusreportId];
            transstatus=true;
        }
    }
    
    return transstatus;
}

-(void)checkCUSStatus :(NSMutableDictionary*)flightDict withUploadURL:(NSString*)imageLoadUrl isFromSunc:(BOOL)fromSync forReportId:(NSString*)cusreportId {
    
    NSMutableDictionary *statusDict = [LTCUSData getCusFlightDict:flightDict forReportId:cusreportId];
    /* ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
     singleton=[LTSingleton getSharedSingletonInstance];
     [connection loginCredentials:singleton.username :singleton.password];
     connection.serviceTags = kCHECKSTATUS;
     connection.delegate = self; */
    NSString *url = [NSString stringWithFormat:@"%@%@",BASEURL,CHECKSTATUS_URI];
    NSString *postJson = [DictionaryParser jsonStringFromDictionary:statusDict];
    
    DLog(@"CUS status json:%@",postJson);
    DLog(@"CUS status url:%@",url);
    
    RequestObject *requset = [[RequestObject alloc] init] ;
    requset.url = url;
    requset.language = @"en_ES";
    requset.tag = 1;
    requset.type = @"POST";
    requset.param = postJson;
    requset.priority = normal;
    
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    
    NSMutableData *jsonData = [connection sendSynchronousCallWithUrl:requset error:nil];
    
    NSDictionary *responseDict = [DictionaryParser dictionaryFromData:jsonData];
    
    if([[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"]) {
        NSDictionary *dict = [[[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"] objectAtIndex:0];
        NSString *status = [[[dict objectForKey:@"status"] objectAtIndex:0]objectForKey:@"status"];
        DLog(@"CUS status response:%@",responseDict);
        
        if([status isEqualToString:@"OK"]) {
            [LTCUSData updateCUSStatus:dict status:ok flightDict:flightDict forReportId:cusreportId];
        }
        else if([status isEqualToString:@"ER"] || [status isEqualToString:@"NOT_SENT"]) {
            int attmpts = [LTCUSData updateCUSStatus:dict status:inqueue flightDict:flightDict forReportId:cusreportId];
            [LTCUSData updateCUSStatus:dict status:eror flightDict:flightDict forReportId:cusreportId];
        }
        else if([status isEqualToString:@"EE"]) {
            [LTCUSData updateCUSStatus:dict status:ee flightDict:flightDict forReportId:cusreportId];
        }
        else if ([status isEqualToString:@"EA"]) {
            int attempts = [LTCUSData updateCUSStatus:dict status:ea flightDict:flightDict forReportId:cusreportId];
            if(attempts == 0) {
                [self sendImagesZipFor:CUS forFlight:flightDict onURI:imageLoadUrl withCheckStatus:YES];
            } else {
                [LTCUSData updateCUSStatus:dict status:ok flightDict:flightDict forReportId:cusreportId];
            }
        }
        else if([status isEqualToString:@"WF"]) {
            int attempts = [LTCUSData updateCUSStatus:dict status:wf flightDict:flightDict forReportId:cusreportId];
            [LTCUSData updateCUSStatus:dict status:ok flightDict:flightDict forReportId:cusreportId];
        }
    }
}

-(void)addSingleManualFlight:(NSMutableDictionary*)newflightDict withOldFlight:(NSMutableDictionary*)oldFlightDict forMode:(enum flightAddMode)mode Oncomplete:(void (^)(void))onComplete{
    
    if (mode==Delete) {
        [UserInformationParser addModifyDeleteManualFlight:newflightDict forFlight:oldFlightDict forMode:mode];
        onComplete();
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if ([self checkForInternetAvailability]) {
            [self sendManualflightForChecking:newflightDict];
        } else{
            ShouldAdd=YES;
        }
        
        if (ShouldAdd) {
            [UserInformationParser addModifyDeleteManualFlight:newflightDict forFlight:oldFlightDict forMode:mode];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if ([self checkForInternetAvailability]) {
                    [self getBookingInfo:newflightDict];
                }
                onComplete();
            });
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ERROR_LABEL"] message:[appDel copyTextForKey:@"NOT_VALID_FLIGHT"]];
                ActivityIndicatorView *ac = [ActivityIndicatorView getSharedActivityIndicatorViewInstance];
                [ac stopAnimation];
                //onComplete();
            });
        }
    });
}


-(NSDictionary *)fetchFlightInformation:(NSMutableDictionary*)flightDict {
    
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    singleton = [LTSingleton getSharedSingletonInstance];
    [connection loginCredentials:singleton.username :singleton.password];
    RequestObject *requset = [[RequestObject alloc] init];
    requset.url = [NSString stringWithFormat:@"%@ginfo",BASEURL];requset.language = @"en_ES";requset.tag = 1;requset.type=@"POST"; requset.param = [DictionaryParser jsonStringFromDictionary:flightDict];
    
    NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
    if (data != nil) {
        NSDictionary *responseDic = [DictionaryParser dictionaryFromData:data];
        return responseDic;
    } else {
        return nil;
    }
}

-(void)getNimbusURL {
    
    if ([self checkForInternetAvailability]) {
        //        AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        //[acview changelabelStatusTo:[apDel copyTextForKey:@"SYNC_FLIGHTS"]];
        ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
        singleton=[LTSingleton getSharedSingletonInstance];
        //[connection loginCredentials:singleton.username :singleton.password];
        
        RequestObject *requset= [[RequestObject alloc] init];
        requset.url = [NSString stringWithFormat:@"%@api-docs",BASEURL];
        requset.language = @"en_ES";
        requset.tag = 1;
        requset.type = @"GET";
        requset.param = @"";
        requset.priority = normal;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSError *error = nil;
            NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:&error];
            //            NSString *reqString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (data == nil || error) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if(!singleton.isLoggingIn) {
                        [self.delegate synchFailedWithError:kReachabilityFailed];
                    } else if(error && error.code == NSURLErrorTimedOut) {
                        [self.delegate synchFailedWithError:kTimeOut];
                    } else {
                        [self localLogin];
                    }
                });
                
            } else {
                
                NSDictionary *responseDic = [DictionaryParser dictionaryFromData:data];
                
                if ([self validateResponseDict:responseDic]) {
                    singleton.urlDict = [[NSDictionary alloc] initWithDictionary:responseDic copyItems:YES];
                    
                    NSLog(@"url dict: %@",singleton.urlDict);
                    ///add synch flight data with the response
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self synchFlightRoaster];
                    });
                    
                } else {
                    //show alert for message.
                    NSLog(@"issue 1");
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kServerSynchStop object:nil];
                        if ([self.delegate respondsToSelector:@selector(synchFailedWithError:)]) {
                            [self.delegate synchFailedWithError:kAuthenticationFailed];
                        }
                    });
                }
            }
        });
    }
    else {
        if ([self.delegate respondsToSelector:@selector(synchFailedWithError:)]) {
            [self.delegate synchFailedWithError:kReachabilityFailed];
        }
    }
}

-(void)synchFlightRoaster {
    if ([self checkForInternetAvailability]) {
        //[acview changelabelStatusTo:[apDel copyTextForKey:@"SYNC_FLIGHTS"]];
        ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
        singleton = [LTSingleton getSharedSingletonInstance];
        RequestObject *requset = [[RequestObject alloc] init] ;
        requset.url = [NSString stringWithFormat:@"%@userInformation",BASEURL];requset.language = @"en_ES";requset.tag = 1;requset.type=@"GET";
        requset.param=@"";requset.priority=normal;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSError *error = nil;
            NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:&error];
            if (data == nil || error) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if(singleton.isLoggingIn == NO) {
                        [self.delegate synchFailedWithError:kReachabilityFailed];
                    } else if(error && error.code == NSURLErrorTimedOut) {
                        [self.delegate synchFailedWithError:kTimeOut];
                    } else {
                        [self localLogin];
                    }
                });
                
            } else {
                NSDictionary *responseDic = [DictionaryParser dictionaryFromData:data];
                
                BOOL noFlightList = ([[[responseDic[@"serviceStatus"] firstObject] objectForKey:@"code"] intValue] < 0);
                
                if (!noFlightList && [self validateResponseDict:responseDic]) {
                    __unused BOOL done = [UserInformationParser saveFlightListFromDict:responseDic];
                    responseDic = nil;
                    [self saveCredentials];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        ActivityIndicatorView *acview = [ActivityIndicatorView getSharedActivityIndicatorViewInstance];
                        [acview changelabelStatusTo:@"Descargando Información"];
                        [self synchContentByVersion];
                    });
                } else {
                    //show alert for message.
                    NSLog(@"issue 2");
                    if ([self.delegate respondsToSelector:@selector(synchFailedWithError:)]) {
                        [self.delegate synchFailedWithError:kAccessForbidden];
                    }
                }
            }
        });
    } else {
        if ([self.delegate respondsToSelector:@selector(synchFailedWithError:)]) {
            [self.delegate synchFailedWithError:kReachabilityFailed];
        }
    }
}

-(void)synchContentByVersion {
    if ([self checkForInternetAvailability]) {
        //[acview changelabelStatusTo:[apDel copyTextForKey:@"SYNC_FLIGHT_DETAIL"]];
        ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
        singleton=[LTSingleton getSharedSingletonInstance];
        RequestObject *requset= [[RequestObject alloc] init];
        //configure request
        requset.url = [NSString stringWithFormat:@"%@/%@", URI, [TempLocalStorageModel getUserDefaultsData:kContentByVersionUri]   ];requset.language = @"en_ES";requset.tag = 1;requset.type=@"GET";
        requset.param=@"";requset.priority=normal;
        
        //[connection loginCredentials:singleton.username :singleton.password];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
            if (data == nil) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if(!singleton.isLoggingIn) {
                        [self.delegate synchFailedWithError:kReachabilityFailed];
                    } else {
                        [self localLogin];
                    }
                });
                
            } else {
                NSDictionary *responseDic = [DictionaryParser dictionaryFromData:data];
                ///add synch flight data with the response
                if ([self validateResponseDict:responseDic]) {
                    LTFlightReportContent *report = [[LTFlightReportContent alloc] init];
                    [report insertReportFromDict:responseDic];
                    responseDic = nil;
                } else {
                    //show alert for message.
                    NSLog(@"issue 3");responseDic=nil;
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self synchManuallyAddedFlight];
                });
            }
        });
    } else {
        if ([self.delegate respondsToSelector:@selector(synchFailedWithError:)]) {
            [self.delegate synchFailedWithError:kReachabilityFailed];
        }
    }
}

-(void)showFlightRoaster {
    if ([self.delegate respondsToSelector:@selector(synchCompletedWithSuccess)]){
        [self.delegate synchCompletedWithSuccess];
    }
}

-(NSArray *)getFlightroaster {
    return [UserInformationParser getFlightRoaster];
}

-(BOOL)localValidate {
    
    NSString *savedUsername = [TempLocalStorageModel getDataFromKeyChainWrapperForKey:CuserName withDecrypted:YES];
    NSString *savedPassword = [TempLocalStorageModel getDataFromKeyChainWrapperForKey:CpassWord withDecrypted:YES];
    
    if ([savedUsername isEqualToString:singleton.username]) {
        if ([savedPassword isEqualToString:singleton.password]) {
            [LTSingleton getSharedSingletonInstance].user = [TempLocalStorageModel getUserDefaultsData:@"user"];
            return TRUE;
        } else {
            if ([self.delegate respondsToSelector:@selector(synchFailedWithError:)]) {
                [self.delegate synchFailedWithError:kInvalidPassword];
            }
            return NO;
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(synchFailedWithError:)]) {
            [self.delegate synchFailedWithError:kDifferentUser];
        }
        return NO;
    }
    return YES;
}

-(void)initiateSynchronization {
    singleton = [LTSingleton getSharedSingletonInstance];
    singleton.synchStatus = TRUE;
    
    if ([self checkForInternetAvailability]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kServerSynchStart object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kServerSynchStop object:nil];
        if([self localValidate]) {
            if ([self.delegate respondsToSelector:@selector(synchCompletedWithSuccess)]) {
                singleton = [LTSingleton getSharedSingletonInstance];
                singleton.synchStatus = FALSE;
                [self.delegate synchCompletedWithSuccess];
                return;
            }
        } else {
            return;
        }
    }
    if(errorDict == nil) {
        errorDict = [[NSMutableDictionary alloc] init];
    } else {
        [errorDict removeAllObjects];
    }
    [self getNimbusURL];
}

-(void)startReportSynch {
    [self synchflightReport];
}

-(void)startDownloadData {
    //actualizerdata
}

-(void)localLogin {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kServerSynchStop object:nil];
    
    if([self localValidate]) {
        if ([self.delegate respondsToSelector:@selector(synchCompletedWithSuccess)]) {
            
            if ([self.delegate respondsToSelector:@selector(synchFailedWithError:)]) {
                [self.delegate synchFailedWithError:kReachabilityFailed];
            }
            
            singleton = [LTSingleton getSharedSingletonInstance];
            singleton.synchStatus = FALSE;
            [self.delegate synchCompletedWithSuccess];
            return;
        }
    } else {
        [self.delegate synchFailedWithError:kReachabilityFailed];
        return;
    }
}

-(void)synchflightReport {
    
}

-(void)synchNotFlownAsJSB {
    
    NSArray * allFlightArray = [self getFlightroaster];
    
    for (NSDictionary * flightDict in allFlightArray) {
        if([flightDict[@"isFlownAsJSB"] boolValue] == NO) {
            [self notFlowanAsJSB:flightDict completion:^{
                
            }];
        }
    }
}
-(void)synchBasicInfosByIDFlight:(NSArray*)allFutureFlights forIndex:(int)i Oncomplete:(void (^)(void))onComplete {
    
    if ([self checkForInternetAvailability]) {
         // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                for (int j = 0; j < [allFutureFlights count]; j++) {
                    NSDictionary *flightDict = [allFutureFlights objectAtIndex:j];
                    [self actualizeDataForFlight:flightDict Oncomplete:^(BOOL success) {
                       // dispatch_sync(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifBriefingDownloaded object:self userInfo:flightDict[@"flightKey"]];
                       // });
                    }];
                }
                
                onComplete();
          //  });
    } else {
        onComplete();
        if ([self.delegate respondsToSelector:@selector(synchFailedWithError:)]) {
            [self.delegate synchFailedWithError:kReachabilityFailed];
        }
    }
}
-(void)synchBasicInfos:(NSArray*)allFutureFlights forIndex:(int)i Oncomplete:(void (^)(void))onComplete {
    
    if ([self checkForInternetAvailability]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (int j = 0; j < [allFutureFlights count]; j++) {
                NSDictionary *flightDict = [allFutureFlights objectAtIndex:j];
                [self actualizeDataForFlight:flightDict Oncomplete:^(BOOL success) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifBriefingDownloaded object:self userInfo:flightDict[@"flightKey"]];
                    });
                }];
            }
            
            onComplete();
        });
    } else {
        onComplete();
        if ([self.delegate respondsToSelector:@selector(synchFailedWithError:)]) {
            [self.delegate synchFailedWithError:kReachabilityFailed];
        }
    }
}

-(void)actualizeDataForFlight:(NSDictionary*)flightDict Oncomplete:(void (^)(BOOL))onComplete {
    
    if([self shouldSyncFlight:flightDict]) {
        [self getPublicaionData:flightDict Oncomplete:^(BOOL success) {
            onComplete(success);
        }];
    }
    else {
        onComplete(YES);
    }
}

-(void)actualizeDataForFlightSeat:(NSDictionary*)flightDict Oncomplete:(void (^)(BOOL))onComplete {
    
    if([self shouldSyncSeatmapAndPassengerListForFlight:flightDict leg:-1]) {
        [self getFlightSeatMap:flightDict OnComplete:^(BOOL success){
            onComplete(success);
        }];
    }
    else {
        onComplete(YES);
    }
}

-(void)actualizeDataForFlightPassenger:(NSDictionary*)flightDict Oncomplete:(void (^)(BOOL))onComplete {
    
    if([self shouldSyncSeatmapAndPassengerListForFlight:flightDict leg:-1]) {
        [self getAllPassengerData:flightDict OnComplete:^(BOOL success) {
            onComplete(success);
        }];
    }
    else {
        onComplete(YES);
    }
}

-(void)getFlightSeatMap:(NSDictionary *)flightKeyDict OnComplete:(void (^)(BOOL))onComplete {
    
    NSDictionary * flightDict = [flightKeyDict objectForKey:@"flightKey"];
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *lastLeg = [[flightDict objectForKey:@"legs"] lastObject];
    int diff = [appDel compareDate:[NSDate date] :[lastLeg[@"departureLocal"] toGlobalTime]];
    
    BOOL flightIsInSyncRange = (diff >= 0 && diff <= 60*60*24);
    BOOL isSeatMapSynched = [[flightDict valueForKey:@"isFlightSeatMapSynched"] boolValue];
    
    if(!flightIsInSyncRange ||isSeatMapSynched || ![self shouldSyncSeatmapAndPassengerListForFlight:flightDict leg:-1]) {
        return;
    }
    
    NSString *flightNumber = [flightDict  objectForKey:@"flightNumber"];
    NSString *airLineCode = [flightDict objectForKey:@"airlineCode"];
    NSDate *fDate = [flightDict objectForKey:@"flightDate"];
    
    NSString * departureStation = [[[flightKeyDict objectForKey:@"legs"] objectAtIndex:0 ]valueForKey:@"origin"];
    NSMutableDictionary *flightDictInput = [[NSMutableDictionary alloc] init];
    if (flightNumber) {
        [flightDictInput setObject:flightNumber forKey:@"flightNumber"];
    }
    else  {
        DLog(@"flight number is not available");
    }
    [flightDictInput setObject:airLineCode forKey:@"airlineCode"];
    NSMutableDictionary * dateDict = [[NSMutableDictionary alloc]init];
    NSDateFormatter *fr = [[NSDateFormatter alloc] init];
    [fr setDateFormat:DATEFORMAT1];
    NSString *date = [fr stringFromDate:fDate];
    [dateDict setObject:date forKey:@"departureDate"];
    
    [flightDictInput setObject:dateDict forKey:@"flightDate"];
    [flightDictInput setObject:departureStation forKey:@"departureIATACode"];
    
    NSString *jsonString = [DictionaryParser jsonStringFromDictionary:[NSDictionary dictionaryWithDictionary:flightDictInput]];
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    RequestObject *requset = [[RequestObject alloc] init] ;
    NSString * passengerUri = @"getSeatMap";
    requset.url = [NSString stringWithFormat:@"%@%@",BASEURL,passengerUri];requset.language = @"en_ES";requset.tag = 1;requset.type=@"POST";
    requset.param = jsonString;requset.priority=normal;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
        BOOL succesFlag=FALSE;
        if (data!=nil && [data length] >0)
        {
            NSDictionary *responseDict =[DictionaryParser dictionaryFromData:data];
            
            if (responseDict != nil){
                [SaveSeatMap saveSeatMapForFlight:flightDict andSeatMap:responseDict];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifSeatMap object:nil];
                onComplete(YES);
                
            } else {
                onComplete(NO);
                
            }
            
        }
    });
}

-(void)getAllPassengerData:(NSDictionary *)flightKeyDict OnComplete:(void (^)(BOOL))onComplete {
    
    NSDictionary * flightDict = [flightKeyDict objectForKey:@"flightKey"];
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *lastLeg = [[flightDict objectForKey:@"legs"] lastObject];
    int diff = [appDel compareDate:[NSDate date] :[lastLeg[@"departureLocal"] toGlobalTime]];
    
    BOOL flightIsInSyncRange = (diff >= 0 && diff <= 60*60*24);
    
    if(!flightIsInSyncRange || ![self shouldSyncSeatmapAndPassengerListForFlight:flightDict leg:-1]) {
        return;
    }
    
    NSString *flightNumber = [flightDict  objectForKey:@"flightNumber"];
    NSString *airLineCode = [flightDict objectForKey:@"airlineCode"];
    NSDate *fDate = [flightDict objectForKey:@"flightDate"];
    NSString * departureStation = [[[flightKeyDict objectForKey:@"legs"] objectAtIndex:0 ]valueForKey:@"origin"];
    NSMutableDictionary *flightDictInput = [[NSMutableDictionary alloc] init];
    if (flightNumber) {
        [flightDictInput setObject:flightNumber forKey:@"flightNumber"];
    }
    else {
        DLog(@"flight number is not available");
    }
    [flightDictInput setObject:airLineCode forKey:@"airlineCode"];
    NSMutableDictionary *dateDict = [[NSMutableDictionary alloc]init];
    NSDateFormatter *fr = [[NSDateFormatter alloc] init];
    [fr setDateFormat:DATEFORMAT1];
    NSString *date = [fr stringFromDate:fDate];
    [dateDict setObject:date forKey:@"departureDate"];
    
    [flightDictInput setObject:dateDict forKey:@"flightDate"];
    [flightDictInput setObject:departureStation forKey:@"departureIATACode"];
    
    NSString *jsonString = [DictionaryParser jsonStringFromDictionary:[NSDictionary dictionaryWithDictionary:flightDictInput]];
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    RequestObject *requset= [[RequestObject alloc] init] ;
    NSString * passengerUri = @"getPassengerList";
    requset.url = [NSString stringWithFormat:@"%@%@",BASEURL,passengerUri];requset.language = @"en_ES";requset.tag = 1;requset.type=@"POST";
    requset.param = jsonString;requset.priority=normal;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
        if (data != nil && [data length] > 0) {
            NSDictionary *responseDict =[DictionaryParser dictionaryFromData:data];
            if ([responseDict valueForKey:@"passengerListResponse"] != nil)
                [SaveSeatMap savePassengerForFlight:flightDict andPassengerDict:responseDict];
            onComplete(YES);
        } else {
            onComplete(NO);
        }
    });
}

-(void)getPublicaionData:(NSDictionary*)flightDict Oncomplete:(void (^)(BOOL))onComplete {
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *lastLeg = [[flightDict objectForKey:@"legs"] lastObject];
    int diff = [appDel compareDate:[NSDate date] :[lastLeg[@"arrivalLocal"] toGlobalTime]];
    if (diff <= 0) {
        onComplete(NO);
        return;
    }
    
    NSMutableDictionary *flightKeyDict = [[NSMutableDictionary alloc] initWithDictionary:[flightDict objectForKey:@"flightKey"]];
    [flightKeyDict removeObjectForKey:@"reportId"];
    NSDate *date = [flightKeyDict objectForKey:@"flightDate"];
    NSString *fdate = [date dateFormat:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss];
    [flightKeyDict setObject:fdate forKey:@"flightDate"];
    NSString *jsonString = [DictionaryParser jsonStringFromDictionary:[NSDictionary dictionaryWithDictionary:flightKeyDict]];
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    RequestObject *requset= [[RequestObject alloc] init] ;
    requset.url = [NSString stringWithFormat:@"%@getBriefingInformation",BASEURL];requset.language = @"en_ES";requset.tag = 1;requset.type=@"POST";
    requset.param=jsonString;requset.priority=normal;
    
    NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
    NSDictionary *responseDic = [DictionaryParser dictionaryFromData:data];
    
    if ([self validateResponseDict:responseDic]) {
        [SavePublicationData savePublicationDetailsFromDict:responseDic];
        onComplete(YES);
    } else {
        
        onComplete(NO);
    }
}

-(void)updateFlightCardForPublication:(NSDictionary*)flightDict {
    
    if ([self.delegate respondsToSelector:@selector(updateFlightCardForPublication:)] && ![LTSingleton getSharedSingletonInstance].synchStatus) {
        [self.delegate updateFlightCardForPublication:flightDict];
    }
}

-(void)notFlowanAsJSB:(NSDictionary*)flightDict completion:(void (^)(void))completionBlock {
    
    [UserInformationParser markFlightFlownAsTCForFlight:flightDict andFlag:FALSE];
    
    if ([self checkForInternetAvailability]) {
        NSMutableDictionary *flightKeyDict = [[NSMutableDictionary alloc] initWithDictionary:[flightDict objectForKey:@"flightKey"]];
        [flightKeyDict removeObjectForKey:@"reportId"];
        NSDate *date = [flightKeyDict objectForKey:@"flightDate"];
        NSString *fdate = [date dateFormat:DATE_FORMAT_dd_MM_yyyy];
        [flightKeyDict setObject:fdate forKey:@"flightDate"];
        NSString *jsonString = [DictionaryParser jsonStringFromDictionary:[NSDictionary dictionaryWithDictionary:flightKeyDict]];
        ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
        RequestObject *requset = [[RequestObject alloc] init] ;
        requset.url = [NSString stringWithFormat:@"%@markFlownAsTc",BASEURL];requset.language = @"en_ES";requset.tag = 1; requset.type=@"POST";
        requset.param = jsonString;requset.priority = normal;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [connection sendSynchronousCallWithUrl:requset error:nil];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        });
    } else {
        if ([self.delegate respondsToSelector:@selector(synchFailedWithError:)]) {
            [self.delegate synchFailedWithError:kReachabilityFailed];
        }
    }
}

-(NSData *)dataFromHexString:(NSString *)string {
    
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

-(void)sendFeedbackGadReport:(NSDictionary *)flightReportDict {
    // isAllSyncGAD= NO;
    
    bpNumber = [[[flightReportDict objectForKey:@"gadDetail"] objectForKey:@"crewMember"] objectForKey:@"bp"];
    
    if ([self checkForInternetAvailability]) {
        NSString *gadUri =[LTGetLightData getUriForType:GADReport forDict:[LTSingleton getSharedSingletonInstance].flightKeyDict];
        if (gadUri == nil) {
            return;
        }
        
        NSString *jsonString = [DictionaryParser jsonStringFromDictionary:[NSDictionary dictionaryWithDictionary:flightReportDict]];
        ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
        RequestObject *requset = [[RequestObject alloc] init] ;
        requset.url = [NSString stringWithFormat:@"%@%@", URI, gadUri]; requset.language = @"en_ES"; requset.tag = 1; requset.type = @"POST";
        requset.param = jsonString;requset.priority = normal;
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableData *data = [connection sendSynchronousCallWithUrl:requset error:nil];
        BOOL succesFlag = FALSE;
        if (data != nil) {
            NSDictionary *responseDict = [DictionaryParser dictionaryFromData:data];
            
            NSInteger code = 1;
            NSArray *statusArray = [[responseDict objectForKey:@"supportGuideResource"] valueForKey:@"serviceStatus"];
            if ( [[statusArray objectAtIndex:0] objectForKey:@"code"] != nil) {
                code = [[[statusArray objectAtIndex:0] objectForKey:@"code"] integerValue];
            }
            else {
                statusArray = [responseDict valueForKey:@"serviceStatus"];
                if ([[statusArray objectAtIndex:0] objectForKey:@"code"] != nil)
                    code = [[[statusArray objectAtIndex:0] objectForKey:@"code"] integerValue];
            }
            
            if (code == 0) {
                gadImageUri = [[[[responseDict objectForKey:@"supportGuideResource"] objectForKey:@"response"] objectForKey:@"links"] objectForKey:@"uriUploadImages"];
                [self sendImagesZipFor:GADReport forFlight:[LTSingleton getSharedSingletonInstance].flightKeyDict onURI:gadImageUri withCheckStatus:NO];
                succesFlag = TRUE;
                [GADController updateCrewMemberStatusFormInterface:sent uniqueBP:bpNumber forFlight:flightReportDict];
                succesFlag = TRUE;
            }
            
            else {
                AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
                NSString *msg;
                
                if (appDel.currentLanguage == LANG_SPANISH) {
                    msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"es"];
                } else {
                    msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"pt"];
                }
                if(msg == nil)//check if msg is nil or not ====Palash
                    msg= [appDel copyTextForKey:@"ALERT_UNABLETOCONNECT"];
                [GADController updateCrewMemberStatusFormInterface:eror  uniqueBP:bpNumber forFlight:flightReportDict];
                if (!singleton.synchStatus) {
                    
                    [errorDict setValue:msg forKey:@"error"];
                }
            }
        }
        if (succesFlag) {
            [self gadCheckStatusReport:flightReportDict];
        }
    }
}

-(void)sendCreatedFlightReport {
    
    __block NSInteger code=0;
    
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"isManualyEntered"] intValue]==manuFlightErrored) {
        [AlertUtils showErrorAlertWithTitle:[apDel copyTextForKey:@"WARNING"] message:[apDel copyTextForKey:@"ALERT_SENDERRORREPORT"]];
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict = [LTCreateFlightReport getFlightReportForDictionary:[LTSingleton getSharedSingletonInstance].flightRoasterDict];
        
        NSMutableDictionary *mutableFlightDict = [dict mutableCopy];
        [mutableFlightDict removeObjectForKey:@"flightKey"];
        [mutableFlightDict removeObjectForKey:@"material"];
        AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [mutableFlightDict removeObjectForKey:@"isManualyEntered"];
        [mutableFlightDict removeObjectForKey:@"isDataSaved"];
        [mutableFlightDict removeObjectForKey:@"isPublicationSynched"];
        [mutableFlightDict removeObjectForKey:@"status"];
        [mutableFlightDict removeObjectForKey:@"sortTime"];
        [mutableFlightDict removeObjectForKey:@"tailNumber"];
        [mutableFlightDict removeObjectForKey:@"materialType"];
        [mutableFlightDict removeObjectForKey:@"isFlownAsJSB"];
        [mutableFlightDict removeObjectForKey:@"lastSynchTime"];
        [mutableFlightDict removeObjectForKey:@"isFlightSeatMapSynched"];
        
        BOOL succesFlag = NO;
        STATUS stat = draft;
        [UserInformationParser updateFlightStatus:mutableFlightDict status:inqueue withUri:nil];
        if(![self checkForInternetAvailability]) {
            [[LTSingleton getSharedSingletonInstance].flightRoasterDict setObject:[NSNumber numberWithInt:inqueue] forKey:@"status"];
            [[LTSingleton getSharedSingletonInstance].flightKeyDict setObject:[NSNumber numberWithInt:inqueue] forKey:@"status"];
            stat = inqueue;
        }
        else if([self checkForInternetAvailability]) {
            ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
            singleton = [LTSingleton getSharedSingletonInstance];
            //connection.delegate=self;
            NSArray *flightDetails = [dict.accessibilityValue componentsSeparatedByString:@"/"];
            
            NSString *url = [NSString stringWithFormat:@"%@%@",URI,dict.accessibilityValue];
            NSString *postJson = [DictionaryParser jsonStringFromDictionary:mutableFlightDict];
            DLog(@"json==%@",postJson);
            
            RequestObject *requset = [[RequestObject alloc] init] ;
            requset.url = url;
            requset.language = @"en_ES";
            requset.tag = 1;
            requset.param = postJson;
            requset.type = @"post";
            requset.priority = normal;
            
            NSData *jsonData=[connection sendSynchronousCallWithUrl:requset error:nil];
            NSDictionary *responseDict = [DictionaryParser dictionaryFromData:jsonData];
            
            DLog(@"response=%@",responseDict);
            if ([[responseDict objectForKey:@"response"] objectForKey:@"links"] != nil) {
                
                NSString *uri = [[[responseDict objectForKey:@"response"] objectForKey:@"links"] objectForKey:@"uriUploadImages"];
                [UserInformationParser updateFlightStatus:mutableFlightDict status:sent withUri:uri];
                if(uri != nil) {
                    [self sendImagesZipFor:IV forFlight:[LTSingleton getSharedSingletonInstance].flightRoasterDict onURI:uri withCheckStatus:NO];
                } else {
                    if ([postJson rangeOfString:@"IMG"].location != NSNotFound) {
                        DLog(@"In image uri not found");
                        //not to error--after dicussion with Cristobal
                        //[flightRoster updateFlightStatus:mutableFlightDict status:eror withUri:uri];
                    }
                }
                
                DLog(@"nothing to do");
                succesFlag = YES;
                stat = sent;
            } else {
                
                NSString *msg;
                NSArray *statusArray=[responseDict objectForKey:@"serviceStatus"];
                if ([statusArray count] > 0) {
                    [errorDict removeAllObjects];
                    if (errorDict == nil) {
                        errorDict = [[NSMutableDictionary alloc] init];
                        [LTSingleton getSharedSingletonInstance].errorDict = errorDict;
                    }
                    code = [[[statusArray objectAtIndex:0] objectForKey:@"code"] integerValue];
                    if (code != -13 && code != -15) {
                        if (appdel.currentLanguage == LANG_SPANISH) {
                            msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"es"];
                        } else {
                            msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"pt"];
                        }
                        if ([flightDetails objectAtIndex:4] != nil) {
                            [errorDict setValue:msg forKey:[NSString stringWithFormat:@"Vuelo/Vôo: %@%@\nMódulo: IV\n",[flightDetails objectAtIndex:5],[flightDetails objectAtIndex:4]]];
                        }
                    }
                    //Adding message base on
                }
                
                if (code < 0 ) {
                    if (code == -13 || code == -15) {
                        [UserInformationParser updateFlightStatus:mutableFlightDict status:ok withUri:@""];
                        stat=ok;
                    } else {
                        [UserInformationParser updateFlightStatus:mutableFlightDict status:eror withUri:nil];
                        stat=eror;
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSNotification *noti = [NSNotification notificationWithName:kStatusChanged object:nil userInfo:@{@"status":[NSNumber numberWithInt:stat]}];
            [[NSNotificationCenter defaultCenter] postNotification:noti];
            if (errorDict!=nil && code != -13 && code != -15 && [[errorDict allKeys] count]>0) {
                NSString *str =@"";
                for (NSString *key in [errorDict allKeys]) {
                    str= [str stringByAppendingString:[NSString stringWithFormat:@"ID: %@\n%@\n",key,[errorDict objectForKey:key]]];
                }
                [AlertUtils showErrorAlertWithTitle:[appdel copyTextForKey:@"ERROR_LABEL"] message:str];
            }
            if(succesFlag) {
                [self synchCheckStatusOncomplete:^{
                    
                }];
            }
        });
    });
}
-(void)synchCheckStatusCUSOncompleteByIfFlight:(NSString *)idflights:(NSString *)idReport:(void (^)(void))onComplete {
    DLog(@"in check status");
    NSMutableDictionary *statusDict = [LTCreateFlightReport getSyschStatusByIdflight:idflights];
    NSString *postJson = [DictionaryParser jsonStringFromDictionary:statusDict];
    NSString *url = [NSString stringWithFormat:@"%@checkReportStatus",BASEURL];
    RequestObject *requset= [[RequestObject alloc] init] ;
    requset.url = url;requset.language = @"en_ES";requset.tag = 1;
    requset.param=postJson;requset.priority=normal;requset.type=@"post";
    ConnectionLibrary *con = [[ConnectionLibrary alloc] init];
    NSData *jsonData=[con sendSynchronousCallWithUrl:requset error:nil];
    NSDictionary *responseDict = [DictionaryParser dictionaryFromData:jsonData];
    int counter=0;
    DLog(@"check status %@",responseDict);
    ///Check status is updated with EA==WF and it will update the counter in database. Once counter is 3 it will make it as send. =====Palash
    if (responseDict!=nil) {
        //if([[[responseDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"] isEqualToString:(NSString *)idflights])
        // {
        if ([responseDict objectForKey:@"checkReportStatus"] !=nil) {
            if ([[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"]!=nil) {
                if ([[[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"] count]==0) {
                    counter = 3;
                } else {
                    [UserInformationParser updateFlightStatus:responseDict withCounter:counter];
                }
            }
        }
        // }
    }
    
    self.counter++;
    if (counter < 3) {
        if (counter == 1) {
            [self uploadImageForFlightForstatus:wf];
        }
    }
    else {
        [self uploadImageForFlightForstatus:wf];
    }
    
    onComplete();

}
-(void)synchCheckStatusOncompleteByIfFlight:(NSString *)idflights:(void (^)(void))onComplete {
    DLog(@"in check status");
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *statusDict = [LTCreateFlightReport getSyschStatusByIdflight:idflights];
        NSString *postJson = [DictionaryParser jsonStringFromDictionary:statusDict];
        NSString *url = [NSString stringWithFormat:@"%@checkReportStatus",BASEURL];
        RequestObject *requset= [[RequestObject alloc] init] ;
        requset.url = url;requset.language = @"en_ES";requset.tag = 1;
        requset.param=postJson;requset.priority=normal;requset.type=@"post";
        ConnectionLibrary *con = [[ConnectionLibrary alloc] init];
        NSData *jsonData=[con sendSynchronousCallWithUrl:requset error:nil];
        NSDictionary *responseDict = [DictionaryParser dictionaryFromData:jsonData];
        int counter=0;
        DLog(@"check status %@",responseDict);
        ///Check status is updated with EA==WF and it will update the counter in database. Once counter is 3 it will make it as send. =====Palash
        if (responseDict!=nil) {
            //if([[[responseDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"] isEqualToString:(NSString *)idflights])
           // {
               if ([responseDict objectForKey:@"checkReportStatus"] !=nil) {
                 if ([[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"]!=nil) {
                     if ([[[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"] count]==0) {
                        counter = 3;
                     } else {
                        [UserInformationParser updateFlightStatus:responseDict withCounter:counter];
                     }
                 }
               }
           // }
        }
        
        self.counter++;
        if (counter < 3) {
            if (counter == 1) {
                [self uploadImageForFlightForstatus:wf];
            }
        }
        else {
            [self uploadImageForFlightForstatus:wf];
        }
        
        onComplete();
    //});

}

-(void)synchCheckStatusOncomplete:(void (^)(void))onComplete {
    DLog(@"in check status");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *statusDict = [LTCreateFlightReport getSyschStatus];
        NSString *postJson = [DictionaryParser jsonStringFromDictionary:statusDict];
        NSString *url = [NSString stringWithFormat:@"%@checkReportStatus",BASEURL];
        RequestObject *requset= [[RequestObject alloc] init] ;
        requset.url = url;requset.language = @"en_ES";requset.tag = 1;
        requset.param=postJson;requset.priority=normal;requset.type=@"post";
        ConnectionLibrary *con = [[ConnectionLibrary alloc] init];
        NSData *jsonData=[con sendSynchronousCallWithUrl:requset error:nil];
        NSDictionary *responseDict = [DictionaryParser dictionaryFromData:jsonData];
        int counter=0;
        DLog(@"check status %@",responseDict);
        ///Check status is updated with EA==WF and it will update the counter in database. Once counter is 3 it will make it as send. =====Palash
        if (responseDict!=nil) {
            if ([responseDict objectForKey:@"checkReportStatus"] !=nil) {
                if ([[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"]!=nil) {
                    if ([[[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"] count]==0) {
                        counter = 3;
                    } else {
                        [UserInformationParser updateFlightStatus:responseDict withCounter:counter];
                    }
                }
            }
            
        }
        
        self.counter++;
        if (counter < 3) {
            if (counter == 1) {
                [self uploadImageForFlightForstatus:wf];
            }
        }
        else {
            [self uploadImageForFlightForstatus:wf];
        }
        
        onComplete();
    });
}

-(void)syncFlightReportForFlightDict:(NSDictionary*)flightDict {
    NSMutableDictionary *flightDataDict = (NSMutableDictionary *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)flightDict, kCFPropertyListMutableContainers));
    [flightDataDict removeObjectForKey:@"flightKey"];
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    singleton=[LTSingleton getSharedSingletonInstance];
    [connection loginCredentials:singleton.username :singleton.password];
    connection.serviceTags = kCREATEFLIGHTCOMPLT;
    connection.delegate = self;
    NSString *url = [NSString stringWithFormat:@"%@%@",URI,flightDict.accessibilityValue];
    NSArray *flightDetails = [flightDict.accessibilityValue componentsSeparatedByString:@"/"];
    NSString *postJson = [DictionaryParser jsonStringFromDictionary:flightDataDict];
    DLog(@"json==%@",postJson);
    RequestObject *requset = [[RequestObject alloc] init];
    requset.url = url;requset.language = @"en_ES";requset.tag = 1;
    requset.param = postJson; requset.priority = normal; requset.type = @"post";
    NSData *jsonData = [connection sendSynchronousCallWithUrl:requset error:nil];
    NSDictionary *responseDict;
    if (jsonData != nil) {
        responseDict =[DictionaryParser dictionaryFromData:jsonData];
        if ([[responseDict objectForKey:@"response"] objectForKey:@"links"] != nil) {
            NSString *uri = [[[responseDict objectForKey:@"response"] objectForKey:@"links"] objectForKey:@"uriUploadImages"];
            [UserInformationParser updateFlightStatus:flightDict status:sent withUri:uri];
            [self sendImagesZipFor:IV forFlight:flightDict onURI:uri withCheckStatus:NO];
        } else {
            NSInteger code = 0;
            NSArray *statusArray=[responseDict objectForKey:@"serviceStatus"];
            NSString *msg;
            if ([statusArray count] > 0) {
                code = [[[statusArray objectAtIndex:0] objectForKey:@"code"] integerValue];
                if (code != -13 && code != -15) {
                    AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    if (appdel.currentLanguage == LANG_SPANISH) {
                        msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"es"];
                    } else {
                        msg = [[[statusArray objectAtIndex:0] objectForKey:@"mapLanguages"] objectForKey:@"pt"];
                    }
                    if ([flightDetails objectAtIndex:4] != nil) {
                        [errorDict setValue:msg forKey:[NSString stringWithFormat:@"Vuelo/Vôo: %@%@\nMódulo: IV\n", [flightDetails objectAtIndex:5], [flightDetails objectAtIndex:4]]];
                    }
                }
            }
            
            if (code < 0) {
                if (code == -13 || code == -15) {
                    [UserInformationParser updateFlightStatus:flightDict status:ok withUri:@""];
                } else {
                    [UserInformationParser updateFlightStatus:flightDict status:eror withUri:nil];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_FLIGHTLIST object:nil userInfo:nil];
        }
    }
}

-(void)synchCreateFlightForStatus:(STATUS)stat Oncomplete:(void (^)(void))onComplete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *arra = [LTCreateFlightReport createFlightReportForAllFlightsForStatus:stat];
        for (NSMutableDictionary *flightDict in arra) {
            [self syncFlightReportForFlightDict:flightDict];
        }
        
        onComplete();
    });
}

-(void)uploadImageForFlightForstatus:(enum status)stat {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *arra = [LTCreateFlightReport createFlightReportForAllFlightsForStatus:stat];
        if ([arra count] == 0 && stat == wf) {
            return;
        }
        for (NSDictionary *flightDict in arra) {
            NSString *uri = [LTGetLightData getUriForType:Image forDict:flightDict];
            [self sendImagesZipFor:IV forFlight:flightDict onURI:uri withCheckStatus:NO];
        }
    });
}

-(void)sendImagesZipFor:(enum reportType)type forFlight:(NSDictionary *)flightRoaster onURI:(NSString*)uri withCheckStatus:(BOOL)checkStatus {
    NSMutableDictionary *flightKeyDict=[flightRoaster objectForKey:@"flightKey"];
    NSString *flightName;
    
    flightName=[NSString stringWithFormat:@"%@%@",[flightKeyDict objectForKey:@"airlineCode"],[flightKeyDict objectForKey:@"flightNumber"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *flightDate;
    if([[flightKeyDict objectForKey:@"flightDate"] isKindOfClass:[NSString class]]) {
        NSDate *date = [dateFormatter dateFromString:[flightKeyDict objectForKey:@"flightDate"]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        flightDate=[dateFormatter stringFromDate:date];
    }
    else {
        
        flightDate=[dateFormatter stringFromDate:[flightKeyDict objectForKey:@"flightDate"]];
    }
    
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    singleton=[LTSingleton getSharedSingletonInstance];
    [connection loginCredentials:singleton.username :singleton.password];
    connection.delegate=self;
    NSString *url = [NSString stringWithFormat:@"%@%@", URI, uri];
    NSString *imageFolderName;
    if(nil != flightDate){
        imageFolderName =[flightName stringByAppendingString:flightDate];
    }
    NSString *filePath;
    if (type==CUS) {
        connection.serviceTags = kCUSREPORT;
        filePath = [[LTSingleton getSharedSingletonInstance] zipFolder:@"CUS" andWithImageFolder:imageFolderName withFlodername:[flightKeyDict objectForKey:@"docNumber"]];
    } else if (type==IV) {
        filePath = [[LTSingleton getSharedSingletonInstance] zipFolder:@"FlightReport" andWithImageFolder:imageFolderName withFlodername:nil];
    } else if(type ==GADReport) {
        connection.serviceTags = kGADREPORT;
        filePath = [[LTSingleton getSharedSingletonInstance] zipFolder:@"GadReport" andWithImageFolder:imageFolderName withFlodername:[NSString stringWithFormat:@"%@%@%@",[flightKeyDict objectForKey:@"airlineCode"],[flightKeyDict objectForKey:@"flightNumber"],bpNumber]];
    }
    NSString *jsonData=[connection uploadFileToServer:@"flightReports_attachment" filePath:filePath urlString:url];
    DLog(@"status===%@",jsonData);
    
}

-(NSMutableDictionary *)getGadCheckReportStatusDict:(NSDictionary *)flightReportDict {
    
    NSDictionary * flightdic = [LTSingleton getSharedSingletonInstance].flightKeyDict;
    
    NSString *flightNumber= [[flightdic objectForKey:@"flightKey"] objectForKey:@"flightNumber"];
    NSString *airLineCode= [[flightdic objectForKey:@"flightKey"] objectForKey:@"airlineCode"];
    NSDate *fDate= [[flightdic objectForKey:@"flightKey"] objectForKey:@"flightDate"];
    NSString *suffix = [[flightdic objectForKey:@"flightKey"] objectForKey:@"suffix"];
    
    NSString *reportId = [[flightReportDict objectForKey:@"gadDetail" ]objectForKey:@"reportId"];
    
    NSMutableDictionary *statusDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *flightDict = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *flightArray = [[NSMutableArray alloc]init];
    
    
    if (flightNumber) {
        [flightDict setObject:flightNumber forKey:@"flightNumber"];
    }
    else{
        DLog(@"flight number is not available");
    }
    
    NSDateFormatter *fr = [[NSDateFormatter alloc] init];
    [fr setDateFormat:DATEFORMAT];
    NSString *date = [fr stringFromDate:fDate];
    [flightDict setObject:date forKey:@"flightDate"];
    [flightDict setObject:airLineCode forKey:@"flightOperator"];
    [flightDict setObject:suffix forKey:@"suffix"];
    
    
    NSMutableArray *statusArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *status = [[NSMutableDictionary alloc] init];
    
    [status setObject:@"GAD"forKey:@"reportName"];
    [status setObject:reportId forKey:@"reportId"];
    [statusArray addObject:status];
    
    [flightDict setObject:statusArray forKey:@"status"];
    
    [flightArray addObject:flightDict];
    
    [statusDict setObject:flightArray forKey:@"flights"];
    
    return statusDict;
}

-(void)gadCheckStatusReport:(NSDictionary *)flightReportDict {
    
    NSMutableDictionary *statusDict = [self getGadCheckReportStatusDict:flightReportDict];
    
    NSString *postJson = [DictionaryParser jsonStringFromDictionary:statusDict];
    DLog(@"postJson  after parse ======%@",postJson);
    
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    RequestObject *requset= [[RequestObject alloc] init] ;
    requset.url = [NSString stringWithFormat:@"%@checkReportStatus",BASEURL];
    requset.language = @"en_ES";requset.tag = 1;requset.type=@"POST";
    requset.param=postJson;requset.priority=normal;
    
    NSMutableData *jsonData = [connection sendSynchronousCallWithUrl:requset error:nil];
    BOOL isSuccess = NO;
    BOOL isError = NO;
    if (jsonData != nil) {
        NSDictionary *responseDict = [DictionaryParser dictionaryFromData:jsonData];
        DLog(@"responseDict%@",responseDict);
        NSDictionary *dict = [[[responseDict objectForKey:@"checkReportStatus"]objectForKey:@"flights" ]objectAtIndex:0];
        NSString *status = [[[dict objectForKey:@"status"] objectAtIndex:0]objectForKey:@"status"];
        
        if([status isEqualToString:@"OK"] || [status isEqualToString:@"EE"]) {
            [GADController updateCrewMemberStatusFormInterface:received uniqueBP:bpNumber forFlight:flightReportDict];
            isSuccess = YES;
        }
        else if([status isEqualToString:@"ERROR"] || [status isEqualToString:@"ER"] || [status isEqualToString:@"NOT_SENT"]) {
            [GADController updateCrewMemberStatusFormInterface:eror  uniqueBP:bpNumber forFlight:flightReportDict];
            isError = YES;
        }
        else if([status isEqualToString:@"EE"]) {
            [GADController updateCrewMemberStatusFormInterface:sent  uniqueBP:bpNumber forFlight:flightReportDict];
        }
        else if([status isEqualToString:@"WF"] || [status isEqualToString:@"EA"]) {
            int attempts = [GADController getCrewmemberAttemptsCount:bpNumber forflight:flightReportDict];
            if (attempts <= 2) {
                [GADController updateCrewMemberStatusFormInterface:wf  uniqueBP:bpNumber forFlight:flightReportDict];
                
                // NSString *uri  = [GADController getCrewMemberURI:bpNumber];
                [self sendImagesZipFor:GADReport forFlight:[LTSingleton getSharedSingletonInstance].flightRoasterDict onURI:gadImageUri withCheckStatus:NO];
                
                [self gadCheckStatusReport:flightReportDict];
            }
            else {
                [GADController updateCrewMemberStatusFormInterface:received  uniqueBP:bpNumber forFlight:flightReportDict];
            }
        }
    }
    else {
        if (isError) {
            int attempts = [GADController getCrewmemberAttemptsCount:bpNumber forflight:flightReportDict];
            if (attempts < 3) {
                [GADController updateCrewMemberStatusFormInterface:inqueue  uniqueBP:bpNumber forFlight:flightReportDict];
                
                [self sendFeedbackGadReport:flightReportDict];
            }
            else {
                [GADController updateCrewMemberStatusFormInterface:eror  uniqueBP:bpNumber forFlight:flightReportDict];
            }
        }
    }
}
-(void)syncGADReportsFlorFlightDictIndividuals:(NSString*)idGad:(NSDictionary*)flightDict onlySyncInQueue:(BOOL)onlyInQueue {
    
    NSArray *flightLegArray = [GADController getFlightLegsForFlightRoaster:flightDict];
    int index = 0;
    for (Legs * leg in flightLegArray) {
        NSArray * crewMembersArray = (NSMutableArray *)[LTGetLightData getFlightCrewForFlightRoaster:flightDict forLeg:index];
        
        for (NSMutableDictionary *crewDict in crewMembersArray) {
            if([[crewDict valueForKey:@"bp"] isEqualToString:idGad])
            {
            
            if (([[crewDict valueForKey:@"status"] intValue] == inqueue && onlyInQueue) ||
                ([[crewDict valueForKey:@"status"] intValue] == inqueue ||
                 [[crewDict valueForKey:@"status"] intValue] == sent ||
                 [[crewDict valueForKey:@"status"] intValue] == ea ||
                 [[crewDict valueForKey:@"status"] intValue] == wf)) {
                    
                    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                    NSMutableArray *aLegArray = [[NSMutableArray alloc]init];
                    
                        [dic setValue:[crewDict valueForKey:@"bp"] forKey:@"bp"];
                        [dic setValue:[crewDict valueForKey:@"firstName"] forKey:@"firstName"];
                        [dic setValue:[crewDict valueForKey:@"lastName"] forKey:@"lastName"];
                        [dic setValue:[crewDict valueForKey:@"activeRank"] forKey:@"activeRank"];
                        
                        NSMutableDictionary *feedbackdict = [self getGADforCrew:dic forFlight:flightDict];
                        
                        [feedbackdict setObject:dic forKey:@"crewMember"];
                        
                        NSMutableDictionary *legDict = [[NSMutableDictionary alloc]init];
                        [legDict setObject:leg.origin forKey:@"origin"];
                        [legDict setObject:leg.destination forKey:@"destination"];
                        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                        [outputFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                        NSDateFormatter *outputFormatter2 = [[NSDateFormatter alloc] init];
                        [outputFormatter2 setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                        [legDict setObject: [leg.legDepartureLocal dateFormat:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss] forKey:@"legDepartureLocal"];
                        [legDict setObject:  [leg.legArrivalLocal dateFormat:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss] forKey:@"legArrivalLocal"];
                        [aLegArray addObject:legDict];
                        
                        [feedbackdict setObject:aLegArray forKey:@"legs"];
                        [LTSingleton getSharedSingletonInstance].materialType = [[flightDict valueForKey:@"flightKey"] valueForKey:@"materialType"];
                        [LTSingleton getSharedSingletonInstance].flightKeyDict = [flightDict mutableCopy];
                        NSMutableDictionary *jsonDict = [GADController formatJSON_WithGadReport:feedbackdict forFlight:flightDict];
                        isAllSyncGAD = YES;
                        [self sendFeedbackGadReport:jsonDict];
                }else{
                   
                    
                    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                    NSMutableArray *aLegArray = [[NSMutableArray alloc]init];
                    
                    [dic setValue:[crewDict valueForKey:@"bp"] forKey:@"bp"];
                    [dic setValue:[crewDict valueForKey:@"firstName"] forKey:@"firstName"];
                    [dic setValue:[crewDict valueForKey:@"lastName"] forKey:@"lastName"];
                    [dic setValue:[crewDict valueForKey:@"activeRank"] forKey:@"activeRank"];
                    
                    NSMutableDictionary *feedbackdict = [self getGADforCrew:dic forFlight:flightDict];
                    
                    [feedbackdict setObject:dic forKey:@"crewMember"];
                    
                    NSMutableDictionary *legDict = [[NSMutableDictionary alloc]init];
                    [legDict setObject:leg.origin forKey:@"origin"];
                    [legDict setObject:leg.destination forKey:@"destination"];
                    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                    [outputFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                    NSDateFormatter *outputFormatter2 = [[NSDateFormatter alloc] init];
                    [outputFormatter2 setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                    [legDict setObject: [leg.legDepartureLocal dateFormat:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss] forKey:@"legDepartureLocal"];
                    [legDict setObject:  [leg.legArrivalLocal dateFormat:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss] forKey:@"legArrivalLocal"];
                    [aLegArray addObject:legDict];
                    
                    [feedbackdict setObject:aLegArray forKey:@"legs"];
                    [LTSingleton getSharedSingletonInstance].materialType = [[flightDict valueForKey:@"flightKey"] valueForKey:@"materialType"];
                    [LTSingleton getSharedSingletonInstance].flightKeyDict = [flightDict mutableCopy];
                    NSMutableDictionary *jsonDict = [GADController formatJSON_WithGadReport:feedbackdict forFlight:flightDict];
                    isAllSyncGAD = YES;

                    [self gadCheckStatusReport:jsonDict];
                
                }
                
                }
        }
        
        index++;
    }
}

-(void)syncGADReportsFlorFlightDict:(NSDictionary*)flightDict onlySyncInQueue:(BOOL)onlyInQueue {
    
    NSArray *flightLegArray = [GADController getFlightLegsForFlightRoaster:flightDict];
    int index = 0;
    for (Legs * leg in flightLegArray) {
        NSArray * crewMembersArray = (NSMutableArray *)[LTGetLightData getFlightCrewForFlightRoaster:flightDict forLeg:index];
        
        for (NSMutableDictionary *crewDict in crewMembersArray) {
            if (([[crewDict valueForKey:@"status"] intValue] == inqueue && onlyInQueue) ||
                ([[crewDict valueForKey:@"status"] intValue] == inqueue ||
                [[crewDict valueForKey:@"status"] intValue] == sent ||
                [[crewDict valueForKey:@"status"] intValue] == ea ||
                [[crewDict valueForKey:@"status"] intValue] == wf)) {
                
                NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                NSMutableArray *aLegArray = [[NSMutableArray alloc]init];
                
                [dic setValue:[crewDict valueForKey:@"bp"] forKey:@"bp"];
                [dic setValue:[crewDict valueForKey:@"firstName"] forKey:@"firstName"];
                [dic setValue:[crewDict valueForKey:@"lastName"] forKey:@"lastName"];
                [dic setValue:[crewDict valueForKey:@"activeRank"] forKey:@"activeRank"];
                
                NSMutableDictionary *feedbackdict = [self getGADforCrew:dic forFlight:flightDict];
                
                [feedbackdict setObject:dic forKey:@"crewMember"];
                
                NSMutableDictionary *legDict = [[NSMutableDictionary alloc]init];
                [legDict setObject:leg.origin forKey:@"origin"];
                [legDict setObject:leg.destination forKey:@"destination"];
                NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                [outputFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                NSDateFormatter *outputFormatter2 = [[NSDateFormatter alloc] init];
                [outputFormatter2 setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                [legDict setObject: [leg.legDepartureLocal dateFormat:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss] forKey:@"legDepartureLocal"];
                [legDict setObject:  [leg.legArrivalLocal dateFormat:DATE_FORMAT_dd_MM_yyyy_HH_mm_ss] forKey:@"legArrivalLocal"];
                [aLegArray addObject:legDict];
                
                [feedbackdict setObject:aLegArray forKey:@"legs"];
                [LTSingleton getSharedSingletonInstance].materialType = [[flightDict valueForKey:@"flightKey"] valueForKey:@"materialType"];
                [LTSingleton getSharedSingletonInstance].flightKeyDict = [flightDict mutableCopy];
                NSMutableDictionary *jsonDict = [GADController formatJSON_WithGadReport:feedbackdict forFlight:flightDict];
                isAllSyncGAD = YES;
                [self sendFeedbackGadReport:jsonDict];
            }
        }
        
        index++;
    }
}
-(BOOL)syncAllGadReportsOncompleteByIdFlightBool:(NSString *)idFlight {
   
    NSArray *allFlightArray = [LTGetLightData getFlightsByIDFlight:idFlight];
    
    for (NSDictionary *flightDict in allFlightArray) {
        if([[[flightDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"] isEqualToString:(NSString *)idFlight])
        {
            [self syncGADReportsFlorFlightDict:flightDict onlySyncInQueue:NO];
        }
    }

    DLog(@"Gad syn completed");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGADList" object:nil];

    return true;
}

-(void)syncAllGadReportsOncompleteByIdFlight:(NSString*)dateflight:(NSString*)idGAD:(NSString *)idFlight:(void (^)(void))onComplete
{
        NSArray *allFlightArray = [LTGetLightData getFlightsByIDFlight:idFlight];
    
        for (NSDictionary *flightDict in allFlightArray) {
            if([[[flightDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"] isEqualToString:(NSString *)idFlight])
            {
                NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
                [dateFormate setDateFormat:@"YYYY-MM-dd"];
                NSString *flightDateStr = [dateFormate stringFromDate:[[flightDict objectForKey:@"flightKey"] objectForKey:@"flightDate"]];
                               
                //[self syncGADReportsFlorFlightDict:flightDict onlySyncInQueue:NO];
                [self  syncGADReportsFlorFlightDictIndividuals :(NSString*)idGAD:flightDict onlySyncInQueue:NO];
                
            }
        }
        onComplete();
            DLog(@"Gad syn completed");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGADList" object:nil];
}

-(void)syncAllGadReportsOncomplete:(void (^)(void))onComplete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *allFlightArray = [LTGetLightData getAllFlights];
        
        for (NSDictionary *flightDict in allFlightArray) {
            [self syncGADReportsFlorFlightDict:flightDict onlySyncInQueue:NO];
        }
        
        onComplete();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DLog(@"Gad syn completed");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGADList" object:nil];
        });
    });
    
    isAllSyncGAD = NO;
}

-(NSMutableDictionary*)getDetailsForFlight:(NSDictionary*)flightDict {
    return [SavePublicationData getDetailsForFlight:flightDict];
}

-(void)savePublicationDetailsFromDict:(NSDictionary*)publicationDict {
    return [SavePublicationData savePublicationDetailsFromDict:publicationDict];
}

-(void)deleteGADForCrewBp:(NSString*)crewBP ForFlight:(NSDictionary*)dict {
    [GADController deleteGADForCrewBp:crewBP ForFlight:dict];
}

-(void)deleteCUSForPassportType:(NSString*)passType passportNumber:(NSString*)passNum forFlight:(NSDictionary*)dict {
    
}

-(void)saveGaDDict:(NSDictionary *)dict {
    return [GADController saveGaDDict:dict];
}

-(NSMutableDictionary *)getGADforCrew:(NSDictionary *)crewDict forFlight:(NSDictionary *)flightDic {
    return [GADController getGADforCrew:crewDict forFlight:flightDic];
}

-(void) connectionDidReceiveResponceWithData:(NSMutableData *)data {
    
}

-(void) succeededConnectionWithData:(NSData *)jsonData withTag:(enum ServiceTags)serviceTag {
    
}

-(void) loginFailed {
    
}

-(void) loginFailedDueToForbiddenAccess {
    
}

-(void)restServicefailwithError : (NSError *)error {
    
}

//@param leg: if -1 is passed, all legs are checked
- (BOOL)shouldSyncSeatmapAndPassengerListForFlight:(NSDictionary*)flightDictionary leg:(int)leg {
    
    NSDictionary *fKey = flightDictionary[@"flightKey"];
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FlightRoaster"];
    
    NSDate *fDate;
    if([[fKey objectForKey:@"flightDate"] isKindOfClass:[NSString class]]) {
        NSString *fDateString = [fKey objectForKey:@"flightDate"];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        
        fDate = [dateFormat3 dateFromString:fDateString];
    }
    else {
        fDate = [fKey objectForKey:@"flightDate"];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[fKey objectForKey:@"suffix"], [fKey objectForKey:@"flightNumber"], [fKey objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    
    if([results count] > 0) {
        
        FlightRoaster *flight = [results firstObject];
        
        BOOL (^legContainsCUS)(int) = ^BOOL(int legIndex) {
            Legs *legObj = flight.flightInfoLegs[legIndex];
            if(legObj != nil) {
                NSArray *legCustomerArray = [[legObj.legCustomer array] copy];
                for (int k = 0; k < legCustomerArray.count; k++) {
                    Customer *cust = [legCustomerArray objectAtIndex:k];
                    if(cust.isDeleted || !cust.managedObjectContext) {
                        NSLog(@"this customer has been deleted from the DB");
                        continue;
                    }
                    if([[cust.cusCusReport array] count] > 0) {
                        return YES;
                    }
                }
            }
            
            return NO;
        };
        
        if(leg < 0) {
            for(int i = 0; i < flight.flightInfoLegs.count; i++) {
                if(legContainsCUS(i) == NO) {
                    return YES;
                }
            }
            
            return NO;
        }
        
        else if(legContainsCUS(leg)) {
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)shouldSyncFlight:(NSDictionary*)flightDictionary {
    
    NSDictionary *fKey = flightDictionary[@"flightKey"];
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:appdelegate.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FlightRoaster"];
    
    NSDate *fDate;
    if([[fKey objectForKey:@"flightDate"] isKindOfClass:[NSString class]]) {
        NSString *fDateString = [fKey objectForKey:@"flightDate"];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        
        fDate = [dateFormat3 dateFromString:fDateString];
    }
    else {
        fDate = [fKey objectForKey:@"flightDate"];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[fKey objectForKey:@"suffix"], [fKey objectForKey:@"flightNumber"], [fKey objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    
    if([results count] > 0) {
        
        FlightRoaster *flight = [results firstObject];
        NSDictionary *statusDictionary = [UserInformationParser getStatusForFlight:flight];
        
        NSInteger stat = [[statusDictionary objectForKey:@"flightStatus"] integerValue];
        
        if (stat > 0) {
            return NO;
        }
        
        else if([[statusDictionary objectForKey:@"GAD"] count] > 0) {
            return NO;
        }
        
        else if([[statusDictionary objectForKey:@"CUS"] count] > 0) {
            
            return NO;
        }
    }
    
    return YES;
}

@end
