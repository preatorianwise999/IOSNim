//
//  CrewDataViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/20/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "CrewDataViewController.h"
#import "CrewCPTableViewCell.h"
#import "CrewJSBTableViewCell.h"
#import "CrewTCTableViewCell.h"
#import "CrewDataViewController.h"
#import "AppDelegate.h"
#import "LTGetLightData.h"
#import "LTSingleton.h"
#import "LTAddGADViewController.h"
#import "LTSaveFlightData.h"
#import "SavePublicationData.h"
#import "UIImage+Shapes.h"
#import "UserInformationParser.h"

@interface CrewDataViewController () {
    AppDelegate *appDel;
    NSMutableArray *crewMembersArray;
    NSArray * activeRankArray;
    LTAddGADViewController *addGADViewController;
    GADViewController *gadVC;
    BOOL isSuccesfullySaved;
    NSString *bpNumOfNewlyAddedCrew;
    int indexForLeg;
    CAShapeLayer *ringView ;
    BOOL isFirst;
    BOOL isFromSync;
}

@end

@implementation CrewDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.crewDataTable.backgroundColor = [UIColor clearColor];
    self.crewDataTable.dataSource = self;
    self.crewDataTable.delegate = self;
    
    ringView = [CAShapeLayer layer];
    isFirst = YES;
    isFromSync = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollCarousal:) name:@"ContentScroll" object:nil];
    //Sajjad
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAfterSuccess) name:@"UpdateGADList" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:@"SeatButtonClicked" object:nil];
    
    cptCount = 0;
    appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    crewMembersArray = [[NSMutableArray alloc] init];
    captainArr = [[NSMutableArray alloc] init];
    self.legArray =  [[NSMutableArray alloc] init];
    crewMembersArray = (NSMutableArray *)[LTGetLightData getFlightCrewForFlightRoaster:[LTSingleton getSharedSingletonInstance].flightRoasterDict forLeg:indexForLeg];
    [self segregateSpecialRank];
    self.legArray = (NSMutableArray *)[LTGetLightData getFlightLegsForFlightRoaster:[LTSingleton getSharedSingletonInstance].flightRoasterDict];
    
    activeRankArray = [[NSArray alloc] init];
    activeRankArray = [NSArray arrayWithObjects:[self localizedActiveRank:@"TCE"], [self localizedActiveRank:@"TC"], [self localizedActiveRank:@"TCT"], nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList) name:@"PublicationComplete" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged)  name:UIApplicationWillChangeStatusBarOrientationNotification  object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [self.crewDataTable reloadData];
}
- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)orientationChanged {
    [self performSelector:@selector(updatePopupFrame) withObject:nil afterDelay:0.1];
    [self performSelectorOnMainThread:@selector(reloadTableData) withObject:self waitUntilDone:YES];
}

-(void)reloadTableData {
    [self.crewDataTable reloadData];
}

- (void)updatePopupFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIViewController *vc= self.navigationController.topViewController;
        if (addGADViewController !=nil) {
            addGADViewController.view.frame = vc.view.frame;
        }
        if (gadVC != nil) {
            gadVC.view.frame = vc.view.frame;
            [gadVC updateFrames];
            [gadVC.view layoutSubviews];
        }
        [self.view layoutSubviews];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollCarousal:(NSNotification*)notification{
    NSDictionary *dic = notification.userInfo;
    indexForLeg = [[dic objectForKey:@"index"] integerValue];
    [self refreshList];
    crewMembersArray = (NSMutableArray *)[LTGetLightData getFlightCrewForFlightRoaster:[LTSingleton getSharedSingletonInstance].flightRoasterDict forLeg:indexForLeg];
    [self segregateSpecialRank];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    if (self.crewDataTable.contentSize.height < self.crewDataTable.frame.size.height) {
    //        self.crewDataTable.scrollEnabled = NO;
    //    }
    //    else {
    //        self.crewDataTable.scrollEnabled = YES;
    //    }
}
#pragma mark - Table View datasource and Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (crewMembersArray.count == 0)
        return 1;
    else {
        if ([captainArr count] > 0) {
            return crewMembersArray.count + 2;
        } else
            return crewMembersArray.count + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (crewMembersArray.count == 0 || indexPath.row == crewMembersArray.count+cptCount){
        return 115.0f;
    } else {
        if (captainArr.count > 0 && indexPath.row==0){
            return 80.0f;
        } else if(indexPath.row==1 && [[crewMembersArray[indexPath.row-cptCount] valueForKey:@"specialRank"] isEqualToString:@"JSB"]) {
            return 90.0f;
        } else {
            return 115.0f;
        }
    }
}

-(void)segregateSpecialRank {
    for (NSInteger i = [crewMembersArray count] - 1; i >= 0; i--) {
        if ([[crewMembersArray[i] valueForKey:@"specialRank"] isEqualToString:@"CP"] || [[crewMembersArray[i] valueForKey:@"specialRank"] isEqualToString:@"C"]|| [[crewMembersArray[i] valueForKey:@"specialRank"] isEqualToString:@"FO"]) {
            NSDictionary *crewDict = crewMembersArray[i];
            [captainArr insertObject:crewDict atIndex:0];
            [crewMembersArray removeObjectAtIndex:i];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (crewMembersArray.count == 0 || indexPath.row == crewMembersArray.count + cptCount) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
            
            cell.textLabel.text = [appDel copyTextForKey:@"CREW_ADD_BTN"];
            cell.textLabel.font = KRobotoFontSize18;
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else {
        
        if (captainArr.count > 0 && indexPath.row == 0) {
            CrewCPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cpcell"];
            if (cell == nil) {
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CrewCPTableViewCell" owner:self options:nil];
                // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
                cell = [topLevelObjects objectAtIndex:0];
                cell.backgroundColor = [UIColor clearColor];
                cell.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
                [cell.contentView.layer setCornerRadius:30.0];
                [cell.dataView.layer setCornerRadius:30.0];
                tableView.separatorColor=[UIColor clearColor];
                
                for (int i = 0; i < captainArr.count; i++) {
                    NSString * name = [[[captainArr objectAtIndex:i]valueForKey:@"firstName"] stringByAppendingString:[NSString stringWithFormat:@"  %@",[[captainArr objectAtIndex:i]  valueForKey:@"lastName"]]];
                    NSString *bpID =  [NSString stringWithFormat:@"BP : %@", [[captainArr objectAtIndex:i] valueForKey:@"bp"] ];
                    NSString * designationLabel = [[captainArr objectAtIndex:i]  valueForKey:@"activeRank"];
                    if (i == 0) {
                        cell.cptBPIdLabel.text = bpID;
                        cell.cptNameLabel.text = name;
                        cell.designationLabel.text = designationLabel;
                        cell.cptImageView.hidden=FALSE;
                    } else if (i == 1) {
                        cell.cptSecondBPId.text = bpID;
                        cell.cptSecondNameLabel.text = name;
                        cell.designationSecondLabel.text=designationLabel;
                        cell.cptSecondImageView.hidden=FALSE;
                    } else if (i == 2) {
                        cell.cptthreeBPId.text = bpID;
                        cell.cptThreeNameLabel.text = name;
                        cell.designationThreeLabel.text = designationLabel;
                        cell.cptThreeImageView.hidden=FALSE;
                    } else {
                        break;
                    }
                }
            }
            
            cptCount = 1;
            cell.userInteractionEnabled = FALSE;
            return cell;
            //(indexPath.row-cptCount==1) && (indexPath.row-cptCount) < crewMembersArray.count &&
        } else if([[crewMembersArray[indexPath.row-cptCount] valueForKey:@"specialRank"] isEqualToString:@"JSB"]) {
            CrewJSBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"jsbcell"];
            if (cell == nil) {
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CrewJSBTableViewCell" owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
                cell.backgroundColor = [UIColor clearColor];
                cell.contentView.backgroundColor = [UIColor clearColor];
                [cell.contentView.layer setCornerRadius:30.0];
                cell.gadLabel.layer.borderWidth = 1.5f;
                cell.gadLabel.layer.borderColor = [UIColor whiteColor].CGColor;
                [cell.gadLabel.layer setCornerRadius:25];
                
                NSString * name = [[[crewMembersArray objectAtIndex:indexPath.row-cptCount]valueForKey:@"firstName"] stringByAppendingString:[NSString stringWithFormat:@"  %@",[[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"lastName"]]];
                cell.nameLabel.text = name;
                cell.licenceLabel.text = [NSString stringWithFormat:@"Licencia  %@",[[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"licenceNo"]];
                
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"dd-MM-yyyy";
                NSString *dateStr = [df stringFromDate:[[crewMembersArray objectAtIndex:indexPath.row - cptCount] valueForKey:@"licencceDate"]];
                if(dateStr) {
                    cell.validityLabel.text = [NSString stringWithFormat:@"Venc. %@", dateStr];
                }
                else {
                    cell.validityLabel.text = @"Venc. --";
                }
                
                cell.BPLabel.text = [NSString stringWithFormat:@"BP : %@", [[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"bp"] ];
                cell.IDLabel.text = [@"ID: " stringByAppendingString:[[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"crewID"]];
                cell.postLabel.text = [self localizedActiveRank:[[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"activeRank"]];
                cell.designationLabel.text = [[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"specialRank"];
            }
            
            NSString * gadFilled = [[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"realizedGAD"];
            NSString * expected = [[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"expected"] ;
            cell.gadLabel.text = [NSString stringWithFormat:@"%@ \nGAD",gadFilled ];
            //                [cell.gadLabel createArcPathForCrewFromstart:[gadFilled integerValue] end:[expected integerValue] withDistance:1];
            double delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [self createArcPathForCrewFromstart:[gadFilled integerValue] end:[expected integerValue] withDistance:1 forLabel:cell.gadLabel];
            });
            
            cell.userInteractionEnabled = FALSE;
            
            return cell;
        }
        
        else {
            
            CrewTCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tccell"];
            if (cell == nil) {
                // Load the top-level objects from the custom cell XIB.
                cell = [[[NSBundle mainBundle]loadNibNamed:@"CrewTCTableViewCell" owner:self options:nil]lastObject];
            }
            
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            [cell.contentView.layer setCornerRadius:30.0];
            
            UIColor *gadFillColor = [UIColor clearColor];
            UIColor *gadLabelColor = [UIColor whiteColor];
            
            if([[[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"status"] intValue] >= 2) {
                gadFillColor = [UIColor whiteColor];
                gadLabelColor = [UIColor lightGrayColor];
            }
            
            int d = cell.gadLabel.bounds.size.width;
            cell.gadLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage drawCircleWithWidth:d height:d thickness:2 fillColor:gadFillColor borderColor:[UIColor whiteColor]]];
            cell.gadLabel.textColor = gadLabelColor;
            cell.gadLabel.textAlignment = NSTextAlignmentCenter;
            
            NSString *gadFilled = [[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"filledGAD"];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nGAD", gadFilled]];
            NSRange gadRange = NSMakeRange([text.string rangeOfString:@"\n"].location + 1, 3);
            [text addAttribute:NSFontAttributeName
                         value:KRobotoFontSize12
                         range:gadRange];
            cell.gadLabel.attributedText = text;
            
            NSString *name = [[[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"firstName"] stringByAppendingString:[NSString stringWithFormat:@"  %@",[[crewMembersArray objectAtIndex:indexPath.row-cptCount]  valueForKey:@"lastName"]]];
            cell.nameLabel.text = name;
            
            cell.BPLabel.text = [NSString stringWithFormat:@"BP : %@",[[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"bp"]];
            cell.designationLabel.text = [[crewMembersArray objectAtIndex:indexPath.row-cptCount]  valueForKey:@"specialRank"];
            cell.IDLabel.text = [@"ID: " stringByAppendingString:[[crewMembersArray objectAtIndex:indexPath.row-cptCount]  valueForKey:@"crewID"]];
            cell.postLabel.text = [self localizedActiveRank:[[crewMembersArray objectAtIndex:indexPath.row-cptCount]  valueForKey:@"activeRank"]];
            cell.licenceLabel.text = [NSString stringWithFormat:@"Licencia  %@",[[crewMembersArray objectAtIndex:indexPath.row - cptCount]  valueForKey:@"licenceNo"]];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"dd-MM-yyyy";
            NSString *dateStr = [df stringFromDate:[[crewMembersArray objectAtIndex:indexPath.row-cptCount]  valueForKey:@"licencceDate"]];
            if(dateStr) {
                cell.validityLabel.text=[NSString stringWithFormat:@"Venc. %@", dateStr];
            }
            else {
                cell.validityLabel.text=@"Venc. --";
            }
            
            return cell;
        }
    }
}

-(void)createArcPathForCrewFromstart:(int)from end:(int)end withDistance:(int)dist forLabel:(UILabel *)gadTempLabel {
    if (!isFromSync) {
        
        if (ringView && !isFirst) {
            gadTempLabel.layer.sublayers = nil;
            [ringView removeFromSuperlayer];
        }
        isFirst = NO;
        
        ringView.lineWidth   = 6;
        
        double angle = (double)(360 * from/end)+270;
        //gadTempLabel.text=[@(from) stringValue];
        // gadTempLabel.text = [NSString stringWithFormat:@"%d\nGAD",from];
        ringView.rasterizationScale = [[UIScreen mainScreen] scale]; // to define retina or not
        ringView.shouldRasterize = YES;
        ringView.path = [UIBezierPath bezierPathWithArcCenter:gadTempLabel.center
                                                       radius:(gadTempLabel.frame.size.width/2+dist)
                                                   startAngle:DEGREES_TO_RADIANS(270)
                                                     endAngle:DEGREES_TO_RADIANS(angle)
                                                    clockwise:YES].CGPath;
        ringView.strokeColor=[UIColor colorWithRed:143.0f green:163.0f blue:183.0f alpha:0.6f].CGColor;
        ringView.fillColor = [UIColor clearColor].CGColor;
        
        [gadTempLabel.superview.layer addSublayer:ringView];
    } else {
        isFromSync = NO ;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (crewMembersArray.count == 0 || indexPath.row == crewMembersArray.count + cptCount) {
        [self addButtonClicked:self];
    }
    
    else {
        
        NSDictionary *fDict = [LTSingleton getSharedSingletonInstance].flightKeyDict;
        NSDictionary *fKey = fDict[@"flightKey"];
        NSString *airlineCode = fKey[@"airlineCode"];
        
        int gadStatus = [[[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"status"] intValue];
        
        NSString *materialType = [UserInformationParser getMaterialType:fDict[@"material"]];
        
        if(([airlineCode isEqualToString:@"JJ"] || [airlineCode isEqualToString:@"PZ"])&& ![materialType isEqualToString:@"WB"]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"ALERT_MSG"] message:[appDel copyTextForKey:@"GAD_CANT_SEND"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
     //   else if([airlineCode isEqualToString:@"PZ"]) {
            
       //     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"ALERT_MSG"] message:[appDel copyTextForKey:@"GAD_CANT_SEND"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //    [alert show];
        //}
        
        else if(gadStatus > 1 && gadStatus != eror) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"ALERT_MSG"] message:[appDel copyTextForKey:@"GAD_SENT_MSG"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        
        else if(materialType == nil || (![materialType isEqualToString:@"NB"] && ![materialType isEqualToString:@"WB"])) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"ALERT_MSG"] message:[appDel copyTextForKey:@"RELOAD_FLIGHT_ALERT"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        
        else {
            
            gadVC = [[GADViewController alloc] initWithNibName:@"GADViewController" bundle:nil];
            
            NSString * name = [[[crewMembersArray objectAtIndex:indexPath.row-cptCount]valueForKey:@"firstName"] stringByAppendingString:[NSString stringWithFormat:@"  %@",[[crewMembersArray objectAtIndex:indexPath.row-cptCount]  valueForKey:@"lastName"]]];
            gadVC.bpIDforCrew =[[crewMembersArray objectAtIndex:indexPath.row-cptCount]valueForKey:@"bp"];
            
            gadVC.isForReport = NO;
            UIViewController *vc= self.navigationController.topViewController;
            [vc addChildViewController:gadVC];
            
            [self.navigationController.topViewController.view addSubview:gadVC.view];
            [gadVC didMoveToParentViewController:vc];
            gadVC.crewNameLabel.text = name;//[firstName stringByAppendingString:lastName];
            gadVC.designationLabel.text = [[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"activeRank"];
            gadVC.crewNumberLabel.text = [[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"specialRank"];
            gadVC.bpIdLabel.text = [NSString stringWithFormat:@"BP  %@",[[crewMembersArray objectAtIndex:indexPath.row-cptCount]valueForKey:@"bp"]];
            gadVC.indexForLeg = indexForLeg;
            gadVC.legArray = self.legArray;
            gadVC.crewFirstName =[[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"firstName"];
            gadVC.crewLastName = [[crewMembersArray objectAtIndex:indexPath.row-cptCount] valueForKey:@"lastName"];
            
            [self updatePopupFrame];
        }
    }
}

-(NSArray *)getSortedMembersForRank:(NSString *)rank forMembers:(NSArray *)membersArray {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"activeRank == %@",rank];
    NSArray *normalArray = [membersArray filteredArrayUsingPredicate:predicate];
    NSArray *sortedArray = [normalArray sortedArrayUsingComparator:^NSComparisonResult(CrewMembers *first,CrewMembers *second) {
        return [first.lastName compare:second.lastName];
    }];
    
    return sortedArray;
}

-(IBAction)addButtonClicked:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:[activeRankArray firstObject] forKey:@"rankValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    DLog(@"activeRankArray %@",activeRankArray);
    addGADViewController=[[LTAddGADViewController alloc] initWithNibName:@"LTAddGADViewController" bundle:nil];
    addGADViewController.activeArray=activeRankArray;
    addGADViewController.currentLeg = indexForLeg;
    
    addGADViewController.delegate = self;
    UIViewController *vc= self.navigationController.topViewController;
    addGADViewController.view.frame = vc.view.frame;
    [vc addChildViewController:addGADViewController];
    [self.navigationController.topViewController.view addSubview:addGADViewController.view];
    [addGADViewController didMoveToParentViewController:vc];
}

-(BOOL)flightCrewFirstName:(NSString *)firstName amdLastName:(NSString *)lastName andbpNumber:(NSString *)bpNumber rankValue:(NSString *)rank {
    NSMutableDictionary * addCrewDict = [[NSMutableDictionary alloc]init];
    
    [addCrewDict setObject:firstName forKey:@"firstName"];
    [addCrewDict setObject:@"-" forKey:@"id"];
    [addCrewDict setObject:lastName forKey:@"lastName"];
    [addCrewDict setObject:bpNumber forKey:@"bp"];
    [addCrewDict setObject:rank forKey:@"activeRank"];
    [addCrewDict setObject:@"" forKey:@"licencseExpDate"];
    [addCrewDict setObject:@"" forKey:@"licenseNumber"];
    [addCrewDict setObject:@"" forKey:@"category"];
    [addCrewDict setObject:[NSNumber numberWithBool:YES] forKey:@"ManuallyEeterd"];
    
    [SavePublicationData saveManualCrewFromDict:addCrewDict];
    [self refreshList];
    
    return YES;
}

-(void)loadMasterTableData {
    
    [self.crewDataTable reloadData];
}

- (NSString*)localizedActiveRank:(NSString*)activeRank {
    
    if([[appDel getLocalLanguageCode] isEqualToString:@"pt_BR"]) {
        
        if([activeRank isEqualToString:@"TCE"]) {
            return @"CF";
        }
        else if([activeRank isEqualToString:@"TC"]) {
            return @"CE";
        }
        else if([activeRank isEqualToString:@"TCT"]) {
            return @"CM";
        }
    }
    
    return activeRank;
}

-(void)saveDraft {
    DLog(@"flightRoasterDict %@",[LTSingleton getSharedSingletonInstance].flightRoasterDict);
    [[NSNotificationCenter defaultCenter] postNotificationName:SET_GADDICTIONARY object:nil];
}

-(void)updateAfterSuccess {
    [self refreshList];
    
}
-(void)refreshList {
    
    NSMutableArray *crewArray = [[LTGetLightData getFlightCrewForFlightRoaster:[LTSingleton getSharedSingletonInstance].flightRoasterDict forLeg:indexForLeg] mutableCopy];
    
    crewMembersArray = crewArray;
    captainArr = [[NSMutableArray alloc] init];
    [self segregateSpecialRank];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        isFromSync = YES;
        [self.crewDataTable reloadData];
    });
}

@end
