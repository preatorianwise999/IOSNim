//
//  LTGetDropDownvalue.m
//  LATAM
//
//  Created by Palash on 17/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTGetDropDownvalue.h"
#import "AppDelegate.h"

@implementation LTGetDropDownvalue
+(NSMutableDictionary*)getDictForReportType:(NSString*)type FlightReport:(NSString*)flighReporttName Section:(NSString*)sectionName{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
    
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"ReportUpdate"];
    NSError *error;
    NSArray *results = [appDel.managedObjectContext executeFetchRequest:request error:&error];
    ReportUpdate *repoUp;
    if ([results count]>0) {//Rport update exists
        repoUp = (ReportUpdate *)[results objectAtIndex:0];
        ReportType *typeReport;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@",type];
        results = [[repoUp.typeReort array] filteredArrayUsingPredicate:predicate];
        if ([results count]>0) {
            typeReport = (ReportType*)[results objectAtIndex:0];
            
            FlightReports *report;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",flighReporttName];
            
            results = [[typeReport.typeFlightReport array] filteredArrayUsingPredicate:predicate];
            if ([results count]>0) {
                report = (FlightReports*)[results objectAtIndex:0];
                for (Sections *sec in [report.reportSection array]) {
                    DLog(@"sec=%@",sec.name);
                }
                Sections *section;
                predicate = [NSPredicate predicateWithFormat:@"name ==%@",sectionName];
                NSArray *results = [[report.reportSection array] filteredArrayUsingPredicate:predicate];
                if ([results count]>0) {
                    section = [results objectAtIndex:0];
                    //                    Groups *group;
                    //                    predicate = [NSPredicate predicateWithFormat:@"name == %@",groupName];
                    @try {
                        for (Groups *group in [section.sectionGroup array]) {
                            NSMutableDictionary *dropdownDict = [[NSMutableDictionary alloc] init];
                            DLog(@" grp name==%@",group.name);
                            //group = (Groups*)[results objectAtIndex:0];
                            
                            for (Events *event in [group.groupOccourences array]) {
                                DLog(@"name==%@",event.name);
                                Row *row = [[event.eventsRow array] objectAtIndex:0];
                                //NSMutableArray *array = [[NSMutableArray alloc] init];
                                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                for (Contents *content in [row.rowContent array]) {
                                    
                                    NSMutableArray *spArr = [[NSMutableArray alloc] init];
                                    NSMutableArray *ptArr = [[NSMutableArray alloc] init];
                                    for (FeildValues *val in [content.contentField array]) {
                                        if([val.active boolValue]){
                                            NSString *pt=val.valuePT;
                                            NSString *es=val.valueES;
                                            [pt setAccessibilityLabel:val.optionCode];
                                            [es setAccessibilityLabel:val.optionCode];
                                            [spArr addObject:es];
                                            [ptArr addObject:pt];
                                            
                                        }else{
                                            continue;
                                        }
                                    }
                                    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                    NSMutableArray *arr;
                                    
                                    if (del.currentLanguage==LANG_ENGLISH || del.currentLanguage==LANG_SPANISH) {
                                        arr=spArr;
                                    }else if (del.currentLanguage==LANG_PORTUGUESE){
                                        arr=ptArr;
                                    }
                                    
                                    NSSortDescriptor *sortArr = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];
                                    NSArray *srtedAr=[arr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortArr]];
                                    if (content.name!=nil) {
                                        [dict setObject:srtedAr forKey:content.name];
                                        //[dropdownDict setObject:dropdownDict forKey:event.name];
                                    }else{
                                        [dict setObject:srtedAr forKey:@"X"];
                                    }
                                    //[array addObject:dict];
                                }
                                [dropdownDict setObject:dict forKey:event.name];
                            }
                            [returnDict setObject:dropdownDict forKey:group.name];
                        }
                    }
                    @catch (NSException *exception) {
                        DLog(@"exception: %@",exception.description);
                        return [NSMutableDictionary dictionary];
                    }
                    
                    
                    //                    results = [[section.sectionGroup array] filteredArrayUsingPredicate:predicate];
                    //                    if ([results count]>0) {}
                }
            }
        }
    }
    
    
    
    
    return returnDict;
}
@end
