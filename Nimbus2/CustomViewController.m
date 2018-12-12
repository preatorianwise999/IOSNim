//
//  CustomViewController.m
//  LATAM
//
//  Created by Vishnu on 19/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "CustomViewController.h"
#import "LTSingleton.h"
#import "CustomViewController.h"
#import "AppDelegate.h"
#import "NSDate+DateFormat.h"
#import "LTAllDb.h"
#import <QuartzCore/QuartzCore.h>
#import "SwitchCell.h"
#import "LTDetailCUSReportViewController.h"
#import "OnlyTextViewCell.h"
#import "FTSideMenuViewController.h"
#import "FlightReportViewController.h"

@interface CustomViewController () {
}
@end

@implementation CustomViewController
@synthesize leastIndexPath,tableView,ipArray,_isCustomViewLoadedCompletionHandler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legScrolled) name:@"legScroll" object:nil];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    self.cameraVC = [[TestViewCameraViewController alloc] init];
}

- (void)orientationChanged {
    [self performSelector:@selector(updatePopupFrame) withObject:nil afterDelay:0.1];
}

- (void)updatePopupFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.activeTestView != nil) {
            UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            [self.activeTestView willRotateToOrientation:toInterfaceOrientation];
        }
    });
}

- (void)presentCameraVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        [(FlightReportViewController*)[(FTSideMenuViewController*)self.parentViewController delegate] presentViewController:self.cameraVC animated:YES completion:^{
            AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if ([self.cameraVC.selectedOption isEqualToString:[apDel copyTextForKey:@"TAKE_PHOTO"]]) {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            }
        }];
    });
}

#pragma mark - Popover Delegate Methods

-(void)imageAfterPicking:(UIImage *)pickedImage {
    [self performSelector:@selector(postOrientationNotification) withObject:nil afterDelay:0.2];
    [self performSelector:@selector(showSelectedImage:) withObject:pickedImage afterDelay:0.4];
}

- (void)postOrientationNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    });
}

- (void)showSelectedImage: (UIImage*)selectedImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cameraVC.testView imageAfterPicking:selectedImage];
        self.cameraVC.testView.typeOfDropDown = CameraDropDown;
    });
}

-(void)cancelPickingImage {
    [self performSelector:@selector(postOrientationNotification) withObject:nil afterDelay:0.2];
    [self.cameraVC dismissViewControllerAnimated:YES completion:^{
        self.cameraVC.testView.typeOfDropDown = CameraDropDown;
    }];
}

-(void)legScrolled {
    [LTSingleton getSharedSingletonInstance].enableCells=YES;
    [self cellsForTableView:tableView];
}

-(void)keyboardWillShow {
    isKeyboardUp = YES;
}

-(void)keyboardWillHide {
    isKeyboardUp = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)deleteImage:(NSString*)imageName {
    if([imageName isEqualToString:@""])
        return;
    
    NSString *flightName=[LTSingleton getSharedSingletonInstance].flightName;
    NSString *flightDate=[LTSingleton getSharedSingletonInstance].flightDate;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/FlightReport"];
    NSString *imageFolderName=[flightName stringByAppendingString:flightDate];
    NSString *insideFolderPath=[[dataPath stringByAppendingPathComponent:imageFolderName] stringByAppendingPathComponent:imageName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:insideFolderPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:insideFolderPath error:nil];
    }
}

-(void)updateDiskFile {
    
    if(!self.isCus) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"Highlight.plist"];
        NSMutableDictionary *highlightingDict = [[NSDictionary dictionaryWithContentsOfFile:appFile] mutableCopy];
        
        
        NSString *fdate = [[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightDate"] dateFormat:DATE_FORMAT_yyyy_MM_dd_HH_mm_ss];
        NSString *flightKey = [[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"] stringByAppendingString:[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]] stringByAppendingString:fdate];
        
        if(nil != [LTSingleton getSharedSingletonInstance].reportDictionary) {
            [highlightingDict setObject:[LTSingleton getSharedSingletonInstance].reportDictionary forKey:flightKey];
            [highlightingDict writeToFile:appFile atomically:YES];
        }
        
        BOOL nonEmpty = NO;
        for(NSString *key in [LTSingleton getSharedSingletonInstance].reportDictionary) {
            for(NSString *subKey in [[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:key]) {
                if([[[[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:key] objectForKey:subKey] count] != 0){
                    nonEmpty = YES;
                    break;
                }
            }
        }
        
        if([LTSingleton getSharedSingletonInstance].sendReport) {
            NSNotification *notification = [NSNotification notificationWithName:@"MandatoryFields" object:nil userInfo:@{@"Hidden":[NSNumber numberWithBool:nonEmpty]}];
            
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
    else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"CUSHighlight.plist"];
        NSMutableDictionary *highlightingDict = [[NSDictionary dictionaryWithContentsOfFile:appFile] mutableCopy];
        
        NSString *flightKey ;
        
        if(nil != [LTSingleton getSharedSingletonInstance].flightRoasterDict) {
            if(nil != [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"])
                flightKey = [[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"] stringByAppendingString:[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]];
        }
        
        if(nil != [LTSingleton getSharedSingletonInstance].cusReportDictionary && nil != flightKey) {
            [highlightingDict setObject:[[LTSingleton getSharedSingletonInstance].cusReportDictionary objectForKey:flightKey] forKey:flightKey];
            [highlightingDict writeToFile:appFile atomically:YES];
        }
        //  BOOL nonEmpty = NO;
        for(NSString *key in [LTSingleton getSharedSingletonInstance].cusReportDictionary) {
            if([[[LTSingleton getSharedSingletonInstance].cusReportDictionary objectForKey:key] count] != 0) {
                // nonEmpty = YES;
                break;
            }
        }
    }
}

-(void)initializeIndexPathArray {
    
    if(!self.isCus)
        self.tableView.frame = CGRectMake(0, kTablePadding, 578, 10000);
    else {
        self.tableView.frame = CGRectMake(0, 0, 732, 465);
        self.tableView.layer.cornerRadius = 0.0;
    }
    
    [self.tableView reloadData];
    
    //[self cellsForTableView:self.tableView];
    [self.tableView layoutIfNeeded];
    
    self.leastIndexPath = [[LTSingleton getSharedSingletonInstance] updateLeastIndexPath:ipArray withTable:self.tableView];
    
    if(self.isCus) {
        self.tableView.frame = CGRectMake(0, 0, 732, 465);
        self.tableView.layer.cornerRadius = 0.0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(!self.isCus) {
            self.tableView.frame = CGRectMake(0, kTablePadding, 578, 600);
            
            if(![[LTSingleton getSharedSingletonInstance] mandatoryCellContainsData:(OffsetCustomCell *)[(id < UITableViewDataSource>)(self) tableView:self.tableView cellForRowAtIndexPath:self.leastIndexPath]] && [LTSingleton getSharedSingletonInstance].sendReport) {
                [self.tableView scrollToRowAtIndexPath:self.leastIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
            
            NSString *sectionString = [[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"name"];
            NSString *subSectionString = [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"sections"] firstObject] objectForKey:@"name"];
            
            AppDelegate *appdel = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if([subSectionString isEqualToString:[appdel copyEnglishTextForKey:@"Overview"]]) {
                subSectionString = @"Overview";
            }
            
            if([[LTSingleton getSharedSingletonInstance] mandatoryCellContainsData:(OffsetCustomCell *)[(id<UITableViewDataSource>)(self) tableView:self.tableView cellForRowAtIndexPath:self.leastIndexPath]]){
                
                int legToBeRemoved = [LTSingleton getSharedSingletonInstance].legNumber + 1;
                NSMutableArray *array = [[[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:sectionString] objectForKey:subSectionString];
                int cout = (int)[array count];
                for (int i = cout - 1; i >= 0; i--) {
                    NSNumber *num = [array objectAtIndex:i];
                    if ([num intValue]==legToBeRemoved) {
                        [array removeObject:num];
                    }
                    
                }
                if (array==nil) {
                    array=[NSMutableArray array];
                }
                [[[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:sectionString] setObject:array forKey:subSectionString];
                
                [self updateDiskFile];
                
            }
            else {
                int legToBeRemoved = [LTSingleton getSharedSingletonInstance].legNumber + 1;
                if([[[[[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:sectionString] objectForKey:subSectionString] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"intValue == %d",legToBeRemoved]] count] == 0) {
                    
                    [[[[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:sectionString] objectForKey:subSectionString] addObject:[NSNumber numberWithInt:legToBeRemoved]];
                    [self updateDiskFile];
                }
            }
        } else {
            
            NSString *flightReportId;
            
            if(nil != [LTSingleton getSharedSingletonInstance].flightRoasterDict) {
                if(nil != [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"])
                    flightReportId = [[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"] stringByAppendingString:[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]];
            }
            
            NSString *subSectionString = [LTSingleton getSharedSingletonInstance].currentCustomer.docNumber;
            if(nil != flightReportId) {
                if([[LTSingleton getSharedSingletonInstance] cusmandatoryCellContainsData:(OffsetCustomCell *)[(id<UITableViewDataSource>)(self) tableView:self.tableView cellForRowAtIndexPath:self.leastIndexPath]]){
                    
                    [[[LTSingleton getSharedSingletonInstance].cusReportDictionary objectForKey:flightReportId] removeObject:subSectionString];
                    [self updateDiskFile];
                    
                }
                else{
                    if([[[[LTSingleton getSharedSingletonInstance].cusReportDictionary objectForKey:flightReportId] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self == %@",subSectionString]] count] == 0) {
                        
                        [[[LTSingleton getSharedSingletonInstance].cusReportDictionary objectForKey:flightReportId] addObject:subSectionString];
                        [self updateDiskFile];
                    }
                }
            }
        }
    });
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *legdict = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:[LTSingleton getSharedSingletonInstance].legNumber];
    NSString *key = [NSString stringWithFormat:@"%@-%@",[legdict objectForKey:@"origin"],[legdict objectForKey:@"destination"] ];
    NSInteger status = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"status"] integerValue];
    
    NSNumber *numJSB = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"isFlownAsJSB"];
    if(!numJSB) {
        numJSB = @YES;
    }
    
    AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (([numJSB boolValue] == NO || status == 2 || status == 3 || status == 4 || status == ok || status == ea || status == ee || status == wf) && ![self isKindOfClass:[LTDetailCUSReportViewController class]]) {
        
        [cell setAlpha:0.6f];
        cell.userInteractionEnabled = NO;
        [LTSingleton getSharedSingletonInstance].enableCells = NO;
    }
    
    else if ([cell isKindOfClass:[SwitchCell class]] && [((SwitchCell *)cell).leftLabel.text isEqualToString:[[appdel copyTextForKey:@"GENERAL_TRAMO_EJECUTADO"] stringByAppendingString:@"*"]]) {
        
        [cell setAlpha:1.0f];
        cell.userInteractionEnabled = YES;
    }
        
    else if([[[LTSingleton getSharedSingletonInstance].legExecutedDict objectForKey:key] isEqualToString:@"NO"] && ![self isKindOfClass:[LTDetailCUSReportViewController class]]) {

        [cell setAlpha:0.6f];
        cell.userInteractionEnabled = NO;
    }
    
    else {
        [cell setAlpha:1.0f];
        cell.userInteractionEnabled = YES;
        [LTSingleton getSharedSingletonInstance].enableCells = YES;
    }
}

-(void)cellsForTableView:(UITableView *)tableView {
    
    NSInteger sections = tableView.numberOfSections;
    for (int section = 0; section < sections; section++) {
        NSInteger rows = [tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];//**here, for those cells not in current screen, cell is nil**
            NSDictionary *legdict = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:[LTSingleton getSharedSingletonInstance].legNumber];
            NSString *key = [NSString stringWithFormat:@"%@-%@",[legdict objectForKey:@"origin"],[legdict objectForKey:@"destination"] ];
            NSInteger status = [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"status"] integerValue];
            
            NSNumber *numJSB = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"isFlownAsJSB"];
            if(!numJSB) {
                numJSB = @YES;
            }
            
            AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
            
            if (([numJSB boolValue] == NO || status == 2 || status == 3 || status == 4 || status == ok || status == ea || status == ee || status==wf) && ![self isKindOfClass:[LTDetailCUSReportViewController class]]) {
                
                [cell setAlpha:0.6f];
                cell.userInteractionEnabled = NO;
                [LTSingleton getSharedSingletonInstance].enableCells = NO;
            }
            
            else if ([cell isKindOfClass:[SwitchCell class]] && [((SwitchCell *)cell).leftLabel.text isEqualToString:[[appdel copyTextForKey:@"GENERAL_TRAMO_EJECUTADO"] stringByAppendingString:@"*"]]) {
                
                [cell setAlpha:1.0f];
                cell.userInteractionEnabled = YES;
            }
            
            else if([[[LTSingleton getSharedSingletonInstance].legExecutedDict objectForKey:key] isEqualToString:@"NO"] && ![self isKindOfClass:[LTDetailCUSReportViewController class]]) {
                
                [cell setAlpha:0.6f];
                cell.userInteractionEnabled = NO;
            }
            
            //not required now
            else {
                [cell setAlpha:1.0f];
                cell.userInteractionEnabled = YES;
                [LTSingleton getSharedSingletonInstance].enableCells = YES;
            }
        }
    }
}

-(NSMutableArray *)getGeneralInfoData {
    NSMutableDictionary *generalLegInfoDict = [[NSMutableDictionary alloc] init];
    int legNumber = 0;
    AppDelegate *appdel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc]init];
    [managedObjectContext setPersistentStoreCoordinator:appdel.persistentStoreCoordinator];
    [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FlightRoaster"];
    NSMutableDictionary *dict =[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"];
    NSDate *fDate;
    //flightDate
    if([[dict objectForKey:@"flightDate"] isKindOfClass:[NSString class]]){
        NSString *fDateString = [dict objectForKey:@"flightDate"];
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:DATEFORMAT];
        
        fDate = [dateFormat3 dateFromString:fDateString];
    } else {
        fDate = [dict objectForKey:@"flightDate"];
        
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"flightDate ==%@ AND suffix == %@ AND flightNumber == %@ AND airlineCode == %@", fDate,[dict objectForKey:@"suffix"],[dict objectForKey:@"flightNumber"],[dict objectForKey:@"airlineCode"]];
    [request setPredicate:predicate];
    NSError *error1;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error1];
    
    if([results count] > 0) {
        FlightRoaster *flightRoster = [results objectAtIndex:0];
        
        for(Legs *leg in [flightRoster.flightInfoLegs array]) {
            legNumber++;
            BOOL infoFilled = YES;
            DLog(@"getGeneralInfoData___ Leg %@",leg);
            Report *report = leg.legFlightReport;
            for(FlightReports *flightReport in [report.flightReportReport array]) {
                if(![flightReport.name isEqualToString:@"GENERAL"]) {
                    continue;
                }
                BOOL legExecuted = YES;
                DLog(@"Flight report %@",flightReport.name);
                for(Sections *section in [flightReport.reportSection array]) {
                    DLog(@"Flight section %@",section.name);
                    
                    if(![section.name isEqualToString:@"General Information"])
                        continue;
                    for(Groups *group in [section.sectionGroup array]) {
                        DLog(@"Group %@",group.name);
                        for(Events *event in [group.groupOccourences array]) {
                            DLog(@"event %@",event.name);
                            for(Row *row in [event.eventsRow array]) {
                                DLog(@"row %@",row.rowContent);
                                for(int i = 0; i < [[row.rowContent array] count];i++) {
                                    Contents *content  = [[row.rowContent array] objectAtIndex:i];
                                    if([content.name isEqualToString:@"Leg Executed"]) {

                                        NSString *str = [content.selectedValue boolValue]==YES?@"YES":@"NO";
                                        
                                        if ( [LTSingleton getSharedSingletonInstance].legExecutedDict) {
                                            [[LTSingleton getSharedSingletonInstance].legExecutedDict setObject:str forKey:[NSString stringWithFormat:@"%@-%@",leg.origin,leg.destination]];
                                        } else {
                                            [LTSingleton getSharedSingletonInstance].legExecutedDict = [[NSMutableDictionary alloc] init];
                                            [[LTSingleton getSharedSingletonInstance].legExecutedDict setObject:str forKey:[NSString stringWithFormat:@"%@-%@",leg.origin,leg.destination]];
                                        }
                                        legExecuted = [content.selectedValue boolValue];
                                        continue;
                                    }

                                    if(content.selectedValue == nil||[content.selectedValue isEqualToString:@""] || content.selectedValue == NULL || [content.name isEqualToString:@"Enrollment"]) {
                                        if(legExecuted) {
                                            
                                            if ([content.name isEqualToString:@"Enrollment"]) {
                                                
                                                if ([content.selectedValue length] < 6) {
                                                    infoFilled = NO;
                                                    [generalLegInfoDict setObject:[NSNumber numberWithBool:infoFilled] forKey:[NSString stringWithFormat:@"%d",legNumber]];
                                                }

                                            } else if([content.name isEqualToString:@"Crew Base"]) {
                                                if ([content.selectedValue length] < 1) {
                                                    infoFilled = NO;
                                                    [generalLegInfoDict setObject:[NSNumber numberWithBool:infoFilled] forKey:[NSString stringWithFormat:@"%d",legNumber]];
                                                }
                                            }
                                            else {
                                                infoFilled = NO;
                                                [generalLegInfoDict setObject:[NSNumber numberWithBool:infoFilled] forKey:[NSString stringWithFormat:@"%d",legNumber]];
                                            }

                                        } else {
                                            
                                        infoFilled = YES;
                                        int legToBeRemoved = [LTSingleton getSharedSingletonInstance].legNumber+1;
                                            for (NSString *key in [LTSingleton getSharedSingletonInstance].reportDictionary) {
                                                for (NSString *key2 in [[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:key]) {
                                                    [[[[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:key] objectForKey:key2] removeObjectIdenticalTo:[NSNumber numberWithInt:legToBeRemoved]];
                                                }
                                            }
                                        }
                                        
                                        if(infoFilled == NO) {
                                            break;
                                        }
                                    }
                                }
                                
                                if(infoFilled == NO) {
                                    break;
                                }
                            }
                            if(infoFilled == NO) {
                                break;
                            }
                        }
                        if(infoFilled == NO) {
                            break;
                        }
                    }
                }
            }
            if(infoFilled == YES) {
                [generalLegInfoDict setObject:[NSNumber numberWithBool:infoFilled] forKey:[NSString stringWithFormat:@"%d",legNumber]];
            }
        }
    }
    NSMutableArray *legNotFilledNumbers = [[NSMutableArray alloc] init];
    
    for(NSString *legKey in [generalLegInfoDict allKeys]) {
        if([generalLegInfoDict objectForKey:legKey] == [NSNumber numberWithBool:NO])
            [legNotFilledNumbers addObject:legKey];
    }
    DLog(@"generalLegInfoDict %@",generalLegInfoDict);
    return legNotFilledNumbers;
}

-(void)updateHighlightPlist {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"Highlight.plist"];
    NSMutableDictionary *highlightingDict = [NSMutableDictionary dictionaryWithContentsOfFile:appFile];
    DLog(@"**** Previous highlightingDict : %@",highlightingDict);
    NSString *fdate = [[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightDate"] dateFormat:DATE_FORMAT_yyyy_MM_dd_HH_mm_ss];
   
    NSString *flightKey = [[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"] stringByAppendingString:[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]] stringByAppendingString:fdate];
    
    if([LTSingleton getSharedSingletonInstance].reportDictionary != nil ) {
        
        /********
        Placing General Information Highlight
         **********/
        [[[highlightingDict objectForKey:flightKey] objectForKey:@"GENERAL"] setObject:[self getGeneralInfoData] forKey:@"General Information"];
        
        [highlightingDict writeToFile:appFile atomically:YES];
        DLog(@"%@", [[[highlightingDict objectForKey:flightKey] objectForKey:@"GENERAL"] objectForKey:@"General Information"]);
    }
    
    if([highlightingDict objectForKey:flightKey]){
        [LTSingleton getSharedSingletonInstance].reportDictionary = [NSMutableDictionary dictionaryWithDictionary:[highlightingDict objectForKey:flightKey]];
    }
}

-(void)updateReportDictionary {
    
    self.leastIndexPath = [[LTSingleton getSharedSingletonInstance] updateLeastIndexPath:ipArray withTable:self.tableView];
    DLog(@"self.leastIndexPath %@",self.leastIndexPath);
    
    NSString *sectionString = [[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"name"];
    
    NSString *subSectionString = [[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"sections"] firstObject] objectForKey:@"name"];
    
    AppDelegate *appdel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if([subSectionString isEqualToString:[appdel copyEnglishTextForKey:@"Overview"]]){
        subSectionString = @"Overview";
    }
    
    [self updateHighlightPlist];
    
    if([[LTSingleton getSharedSingletonInstance]
        mandatoryCellContainsData:(OffsetCustomCell *)[(id<UITableViewDataSource>)(self)
        tableView:self.tableView
        cellForRowAtIndexPath:self.leastIndexPath]]) {
        //Checking does it have 6 char in format xy-abd
        if([subSectionString isEqualToString:[appdel copyEnglishTextForKey:@"General Information"]]) {
            subSectionString = @"General Information";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] %@",@"Flight Details"];
            
            if ([[[[[[[[[[[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"legs"] objectAtIndex:kCurrentLegNumber] objectForKey:@"reports"] firstObject] objectForKey:@"sections"] firstObject] objectForKey:@"groups"] filteredArrayUsingPredicate:predicate] firstObject] objectForKey:@"singleEvents"] objectForKey:@"Enrollment"] length] < 6) {
                return;
            }
        }
        
        int legToBeRemoved = [LTSingleton getSharedSingletonInstance].legNumber+1;
        
        NSMutableArray *array = [[[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:sectionString] objectForKey:subSectionString];
        int cout = [array count];
        for (int i = cout - 1; i >= 0; i--) {
            NSNumber *num = [array objectAtIndex:i];
            if ([num intValue] == legToBeRemoved) {
                [array removeObject:num];
            }
        }
            
        if(array!=nil)
            [[[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:sectionString] setObject:array forKey:subSectionString];
        
        [self updateDiskFile];
    }
    
    else {
        
        int legToBeRemoved = [LTSingleton getSharedSingletonInstance].legNumber+1;
        if([[[[[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:sectionString] objectForKey:subSectionString] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"intValue == %d",legToBeRemoved]] count] == 0){
            
            [[[[LTSingleton getSharedSingletonInstance].reportDictionary objectForKey:sectionString] objectForKey:subSectionString] addObject:[NSNumber numberWithInt:legToBeRemoved]];
            
            [self updateDiskFile];
        }
    }
}

-(void)updateCusReportDictionary {
    
    self.leastIndexPath = [[LTSingleton getSharedSingletonInstance] upcusdateLeastIndexPath:ipArray withTable:self.tableView];
    
    if([LTSingleton getSharedSingletonInstance].sendCusReport) {
        
        if(self.leastIndexPath.row == 0 && self.leastIndexPath.section == 0) {
            
            if(![[LTSingleton getSharedSingletonInstance] cusmandatoryCellContainsData:(OffsetCustomCell *)[(id<UITableViewDataSource>)(self) tableView:self.tableView cellForRowAtIndexPath:self.leastIndexPath]]) {
                
                [self.tableView scrollToRowAtIndexPath:self.leastIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        } else {
            [self.tableView scrollToRowAtIndexPath:self.leastIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
    
    NSString *flightReportId;
    
    if(nil != [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]){
        flightReportId = [[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"] stringByAppendingString:[[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]];
    }
    NSString *subSectionString = [LTSingleton getSharedSingletonInstance].currentCustomer.docNumber;
    
    if(nil != flightReportId) {
        if([[LTSingleton getSharedSingletonInstance] cusmandatoryCellContainsData:(OffsetCustomCell *)[(id<UITableViewDataSource>)(self) tableView:self.tableView cellForRowAtIndexPath:self.leastIndexPath]]) {
            
            [[[LTSingleton getSharedSingletonInstance].cusReportDictionary objectForKey:flightReportId] removeObject:subSectionString];
            [self updateDiskFile];
        }
        else {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",subSectionString];
            if([[[[LTSingleton getSharedSingletonInstance].cusReportDictionary objectForKey:flightReportId] filteredArrayUsingPredicate:predicate] count] == 0){
                
                [[[LTSingleton getSharedSingletonInstance].cusReportDictionary objectForKey:flightReportId] addObject:subSectionString];
                [self updateDiskFile];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    UIView *view = (UIView *) [[[UIApplication sharedApplication] keyWindow] performSelector:@selector(firstResponder)];
    if([view isFirstResponder]){
        [UIView animateWithDuration:0.2 animations:^{
            [view resignFirstResponder];
        }];
    }
}

@end
