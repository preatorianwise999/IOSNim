//
//  FlightDetailsViewController.m
//  Nimbus2
//
//  Created by Priyanka on 7/14/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "FlightDetailsViewController.h"
#import "SynchronizationController.h"

#import "ContingencyTableViewCell.h"
#import "RoadMapTableViewCell.h"
#import "TitleTableViewCell.h"
#import "MealsTableViewCell.h"

#import "RoadMapDetailsViewController.h"

#import "UIImage+Shapes.h"

typedef enum {
    
    sectionFlightDetails,
    sectionPublications,
    sectionLeg
    
} SectionType;

typedef enum {
    
    rowNone,
    rowFlightDetails,
    rowPublication,
    rowContingencyTitle,
    rowContingency,
    rowRoadMapTitle,
    rowRoadMapItem,
    rowMealTitle,
    rowMealItem
    
} RowType;

static NSString *const kSectionTypeKey = @"sectionType";
static NSString *const kRowTypeKey = @"rowType";
static NSString *const kRowsKey = @"rows";
static NSString *const kDataKey = @"data";
RoadMapDetailsViewController *rmdvc;

@interface FlightDetailsViewController ()

@property(nonatomic, strong) NSArray *legNumbers;
@property(nonatomic, strong) NSArray *sectionsInfo;

@property(nonatomic, strong) IBOutlet NSLayoutConstraint *bottomSpace;


@end


@implementation FlightDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    SynchronizationController *synch = [[SynchronizationController alloc] init];
    pubdict = [synch getDetailsForFlight:[LTSingleton getSharedSingletonInstance].flightKeyDict];
    self.legs = [[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"legs"];
    
    [self populateInfoArray];
    [self setFrames];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self orientationChanged:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIApplicationWillChangeStatusBarOrientationNotification  object:nil];
    [UserInformationParser getStatsForFlight:[LTSingleton getSharedSingletonInstance].flightKeyDict];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.view setNeedsUpdateConstraints];
    [self.tableView setNeedsUpdateConstraints];
    [self.tableView layoutSubviews];
    [self.view updateConstraints];
    [self setFrames];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    });
}

-(void)setFrames {
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        if (rmdvc) {
            rmdvc.view.frame = CGRectMake(0, 0, 1024,768);
        }
        _bottomSpace.constant = 0;
    }else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        
        if (rmdvc) {
            rmdvc.view.frame = CGRectMake(0, 0, 768, 1024);
        }
        _bottomSpace.constant = 0;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (IBAction)buttonClicked:(id)sender {
    
}
- (IBAction)leg1buttonClicked:(id)sender {
    //[self.tableView setContentOffset:CGPointMake(0, (4-2)*315) animated:YES];
}
- (IBAction)leg2buttonClicked:(id)sender {
    //[self.tableView setContentOffset:CGPointMake(0, (4-2)*315) animated:YES];
}
- (IBAction)leg3buttonClicked:(id)sender {
    //[self.tableView setContentOffset:CGPointMake(0, (4-2)*315) animated:YES];
}
- (IBAction)leg4buttonClicked:(id)sender {
    //  [self.tableView setContentOffset:CGPointMake(0, (4-2)*315) animated:YES];
}

#pragma mark -- Tableview DataSource Methods --

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.sectionsInfo.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDictionary *sectionInfo = self.sectionsInfo[section];
    return ((NSArray*)sectionInfo[@"rows"]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    SectionType sectionType = [self getSectionTypeForSection:section];
    float h = 0.0;
    
    if(sectionType == sectionPublications || sectionType == sectionLeg) {
        h = 45.0f;
    }
    
    return h;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SectionType sectionType = [self getSectionTypeForSection:section];
    UIView *view = nil;
    
    if(sectionType == sectionPublications || sectionType == sectionLeg) {
        view  = [[[NSBundle mainBundle]loadNibNamed:@"SectionCell"owner:self options:nil]lastObject];
        UILabel *label = (UILabel*)[view viewWithTag:104];
        
        AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        if(sectionType == sectionPublications) {
            label.text = [appDel copyTextForKey:@"FD_PUBLICATIONS_HEADER"];
        }
        else if(sectionType == sectionLeg) {
            
            NSInteger nLeg = 0;
            int i;
            
            int nStart = 0;
            
            while([((NSDictionary*)self.sectionsInfo[nStart])[kSectionTypeKey] intValue] != sectionLeg) {
                nStart++;
            }
            
            for(i = 0; i < self.legs.count; i++) {
                
                if(nLeg == section - nStart) {
                    break;
                }
                nLeg++;
            }
            
            NSString *airport1 = ((NSDictionary*)self.legs[nLeg])[@"origin"];
            NSString *airport2 = ((NSDictionary*)self.legs[nLeg])[@"destination"];
            
            label.text = [NSString stringWithFormat:@"%@ - %@", airport1, airport2];
        }
    }
    
    return view;
}

-(UITableViewCell *)tableView:(UITableViewCell*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    RowType rowType = [self getRowTypeForIndexPath:indexPath];
    SectionType sectionType = [self getSectionTypeForSection:indexPath.section];
    NSObject *rowData = [self getRowDataForIndexPath:indexPath];
    
    NSString * cellIdentifier = [self getCellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil) {
        
        NSString *nibName = [self getCellNibNameForIndexPath:indexPath];
        cell = [[[NSBundle mainBundle]loadNibNamed:nibName owner:self options:nil]lastObject];
    }
    
    UIView *view = nil;
    
    if(sectionType == sectionFlightDetails) {
        
        if (rowType == rowFlightDetails) {
            UIButton * leg1btn = nil;
            UIButton * leg4btn = nil;

            UILabel  * leg1lbb1 = nil;
            UILabel  * leg4lbb1 = nil;
            
            UILabel * Flightnamelbl    = nil;
            UILabel * toplbl1          = nil;
            UILabel * toplbl2          = nil;
            UILabel * iniciobreifinglbl= nil;
            UILabel * finbriefingLbl   = nil;
            UILabel * gateLbl          = nil;
            UILabel * EmbrqTlbl        = nil;
            UILabel * EmbrqPLbl        = nil;
            
            UILabel * Timelbl1 = nil;
            UILabel * Timelbl2 = nil;
            
            UILabel * placelbl1 = nil;
            UILabel * placelbl2 = nil;
            
            view = (UIView *)[cell viewWithTag:200];
//            view.tag=indexPath.row+100;
            view.layer.cornerRadius = 15.0;
            view.clipsToBounds = YES;
            view.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.2];
            Flightnamelbl    = (UILabel *)[cell viewWithTag:400];
            toplbl1          = (UILabel *)[cell viewWithTag:401];
            toplbl2          = (UILabel *)[cell viewWithTag:402];
            iniciobreifinglbl= (UILabel *)[cell viewWithTag:403];
            finbriefingLbl   = (UILabel *)[cell viewWithTag:404];
            gateLbl          = (UILabel *)[cell viewWithTag:405];
            EmbrqTlbl        = (UILabel *)[cell viewWithTag:406];
            EmbrqPLbl        = (UILabel *)[cell viewWithTag:407];
            
            UILabel *briefingStartLb        = (UILabel *)[cell viewWithTag:801];
            UILabel *briefingEndLb          = (UILabel *)[cell viewWithTag:802];
            UILabel *gateLb                 = (UILabel *)[cell viewWithTag:803];
            UILabel *crewBoardingLb         = (UILabel *)[cell viewWithTag:804];
            UILabel *passengersBoardingLb   = (UILabel *)[cell viewWithTag:805];
            
            briefingStartLb.text = [appDel copyTextForKey:@"FD_BRIEFING_START"];
            briefingEndLb.text = [appDel copyTextForKey:@"FD_BRIEFING_END"];
            gateLb.text = [appDel copyTextForKey:@"FD_GATE"];
            crewBoardingLb.text = [appDel copyTextForKey:@"FD_CREW_BOARDING"];
            passengersBoardingLb.text = [appDel copyTextForKey:@"FD_PASS_BOARDING"];
            
            NSDictionary *flightDict = [LTSingleton getSharedSingletonInstance].flightKeyDict;
            NSDictionary *fkey = (NSDictionary*)rowData;
            
            Flightnamelbl.text    = [NSString stringWithFormat:@"%@%@",[fkey objectForKey:@"airlineCode"],[fkey objectForKey:@"flightNumber"]];
            toplbl1.text          = [flightDict objectForKey:@"tailNumber"];
            toplbl2.text          = [flightDict objectForKey:@"material"];
            
            if ([[pubdict allKeys] count] > 0) {
                NSDictionary *legdict = [self.legs firstObject];
                NSDate *dep = [legdict objectForKey:@"departureLocal"];
                NSDate *date = [pubdict objectForKey:@"startTime"];
                if (date == nil) {
                    iniciobreifinglbl.text = @"N/D";
                }
                else if ([[date  dateFormat:DATE_FORMAT_HH_mm] isEqualToString:[dep dateFormat:DATE_FORMAT_HH_mm]]) {
                    iniciobreifinglbl.text = @"-";
                }
                else {
                    iniciobreifinglbl.text = [date dateFormat:DATE_FORMAT_HH_mm];
                }
                
                date = [pubdict objectForKey:@"endTime"];
                if (date == nil) {
                    finbriefingLbl.text = @"N/D";
                }
                else if ([[date  dateFormat:DATE_FORMAT_HH_mm] isEqualToString:[dep dateFormat:DATE_FORMAT_HH_mm]]) {
                    finbriefingLbl.text = @"-";
                }
                else {
                    finbriefingLbl.text = [date dateFormat:DATE_FORMAT_HH_mm];
                }
                
                if([pubdict objectForKey:@"gate"] == nil || [[pubdict objectForKey:@"gate"] isEqualToString:@""]) {
                    gateLbl.text = @"N/D";
                }
                else {
                    gateLbl.text = [pubdict objectForKey:@"gate"];
                }
                
                date = [pubdict objectForKey:@"crewEntryTime"];
                if(date == nil) {
                    EmbrqTlbl.text = @"N/D";
                }
                else if ([[date  dateFormat:DATE_FORMAT_HH_mm] isEqualToString:[dep dateFormat:DATE_FORMAT_HH_mm]]) {
                    EmbrqTlbl.text = @"-";
                }
                else {
                    EmbrqTlbl.text = [date dateFormat:DATE_FORMAT_HH_mm];
                }
                
                date = [pubdict objectForKey:@"passengerEntryTime"];
                if(date == nil) {
                    EmbrqPLbl.text = @"N/D";
                }
                else if ([[date  dateFormat:DATE_FORMAT_HH_mm] isEqualToString:[dep dateFormat:DATE_FORMAT_HH_mm]]) {
                    EmbrqPLbl.text = @"-";
                }
                else {
                    EmbrqPLbl.text = [date dateFormat:DATE_FORMAT_HH_mm];
                }
            }
            
            leg1btn=(UIButton *)[cell viewWithTag:301];
            leg4btn=(UIButton *)[cell viewWithTag:304];
            
            leg1lbb1=(UILabel *)[cell viewWithTag:201];
            leg4lbb1=(UILabel *)[cell viewWithTag:205];
            
            Timelbl1=(UILabel *)[cell viewWithTag:500];
            Timelbl2=(UILabel *)[cell viewWithTag:501];
            
            placelbl1=(UILabel *)[cell viewWithTag:600];
            placelbl2=(UILabel *)[cell viewWithTag:601];
            
            if([self.legs count] == 1) {
                
                NSDictionary *legdict = [self.legs objectAtIndex:0];
                NSDate *dep = [legdict objectForKey:@"departureLocal"];
                NSDate *arr = [legdict objectForKey:@"arrivalLocal"];
                leg1lbb1.text=[legdict objectForKey:@"origin"];
                leg4lbb1.text=[legdict objectForKey:@"destination"];
                Timelbl1.text= [dep dateFormat:DATE_FORMAT_HH_mm];//@"22:00";
                Timelbl2.text=[arr dateFormat:DATE_FORMAT_HH_mm];//@"4:15";
                
                placelbl1.text=[dep dateFormat:DATE_FORMAT_EEE_DD_MMM];
                placelbl2.text=[arr dateFormat:DATE_FORMAT_EEE_DD_MMM];
                
                UIView *legView = (UIView*)[view viewWithTag:1000];
                if (legView!=nil) {
                    [legView removeFromSuperview];
                    legView = nil;
                }
                
                CellDetailsViewController *cellDetails = [[CellDetailsViewController alloc] initWithNibName:@"CellDetailsViewController" bundle:nil];
                
                cellDetails.view.backgroundColor = [UIColor clearColor];
                cellDetails.legs=self.legs;
                cellDetails.view.center=view.center;
                cellDetails.view.tag = 1000;
                CGRect frame = cellDetails.view.frame;
                frame.origin.y = 149.0;
                cellDetails.view.frame=frame;
                [view addSubview:cellDetails.view];
                
                NSArray *seatsArray = legdict[@"seat"];
                
                for(NSDictionary *seatDict in seatsArray) {
                    
                    if([seatDict[@"name"] isEqualToString:@"JC"]) {
                        cellDetails.YCDetailslbl.text = [seatDict[@"availibility"] stringValue];
                    }
                    else if([seatDict[@"name"] isEqualToString:@"BC"]) {
                        cellDetails.BCDetailslbl.text = [seatDict[@"availibility"] stringValue];
                    }
                }
            }
            
            if([self.legs count] >= 2) {
                
                NSDictionary *legdict = [self.legs objectAtIndex:0];
                NSDate *dep = [legdict objectForKey:@"departureLocal"];
                leg1lbb1.text=[legdict objectForKey:@"origin"];
                Timelbl1.text= [dep dateFormat:DATE_FORMAT_HH_mm];//@"22:00";
                placelbl1.text=[dep dateFormat:DATE_FORMAT_EEE_DD_MMM];
                
                NSDictionary *legdict2 = [self.legs objectAtIndex:([self.legs count]-1)];
                NSDate *arr = [legdict2 objectForKey:@"arrivalLocal"];
                leg4lbb1.text=[legdict2 objectForKey:@"destination"];
                Timelbl2.text=[arr dateFormat:DATE_FORMAT_HH_mm];//@"4:15";
                placelbl2.text=[arr dateFormat:DATE_FORMAT_EEE_DD_MMM];
                
                
                float width = view.frame.size.width/([self.legs count]);
                
                for (int j=0; j < [self.legs count] - 1; j++) {
                    
                    UIView *middleLegView = (UIView*)[view viewWithTag:(2000+j)];
                    if (middleLegView!=nil) {
                        [middleLegView removeFromSuperview];
                        middleLegView = nil;
                    }
                    
                    CellDetailsViewController *cellLegDetails = [[CellDetailsViewController alloc] initWithNibName:@"CellMiddleLegDetails" bundle:nil];
                    
                    cellLegDetails.view.backgroundColor = [UIColor clearColor];
                    cellLegDetails.legs=self.legs;
                    cellLegDetails.index=j;
                    cellLegDetails.view.center=CGPointMake((j+1)*width, 100);
                    CGRect frame = cellLegDetails.view.frame;
                    frame.origin.y = 48.0;
                    cellLegDetails.view.frame=frame;
                    cellLegDetails.view.tag = 2000+j;
                    [view addSubview:cellLegDetails.view];
                }

                for (int i = 0; i<[self.legs count]; i++) {
                    
                    UIView *legView = (UIView*)[view viewWithTag:(1000+i)];
                    if (legView!=nil) {
                        [legView removeFromSuperview];
                        legView = nil;
                    }
                    
                    CellDetailsViewController *cellDetails = [[CellDetailsViewController alloc] initWithNibName:@"CellDetailsViewController" bundle:nil];
                    
                    cellDetails.view.backgroundColor = [UIColor clearColor];
                    cellDetails.legs=self.legs;
                    cellDetails.index=i;
                    cellDetails.view.center=CGPointMake((i+0.5)*width, 100);
                    
                    NSArray *seatsArray = legdict[@"seat"];
                    
                    for(NSDictionary *seatDict in seatsArray) {
                        
                        if([seatDict[@"name"] isEqualToString:@"JC"]) {
                            cellDetails.YCDetailslbl.text = [seatDict[@"availibility"] stringValue];
                        }
                        else if([seatDict[@"name"] isEqualToString:@"BC"]) {
                            cellDetails.BCDetailslbl.text = [seatDict[@"availibility"] stringValue];
                        }
                    }

                    CGRect frame = cellDetails.view.frame;
                    cellDetails.view.tag = 1000+i;
                    frame.origin.y = 149.0;
                    cellDetails.view.frame=frame;
                    [view addSubview:cellDetails.view];
                }
            }
        }
    }
    
    else if(sectionType == sectionPublications) {
        
        if (rowType == rowPublication) {
            
            UILabel * publicacionesUnderLabel1 =nil;
            UILabel * publicacionesUnderLabel2 =nil;
            UILabel * separator = nil;
            UIImageView *sep = nil;
            
            publicacionesUnderLabel1 = (UILabel *)[cell viewWithTag:101];
            publicacionesUnderLabel2 = (UILabel *)[cell viewWithTag:102];
            sep                      = (UIImageView*)[cell viewWithTag:888];
            separator                = (UILabel *)[cell viewWithTag:889];
            
            if(indexPath.row == 0 && [[pubdict objectForKey:@"Publication"] count] == 0) {
                publicacionesUnderLabel1.text = @"";
                publicacionesUnderLabel2.text = [appDel copyTextForKey:@"FD_NO_PUBLICATIONS"];
            } else {
                NSDictionary *publicationDict = (NSDictionary*)rowData;
                publicacionesUnderLabel1.text = [publicationDict objectForKey:@"heading"];
                publicacionesUnderLabel2.text = [publicationDict objectForKey:@"details"];
            }
            
            if (indexPath.row < [[pubdict objectForKey:@"Publication"] count] - 1 && [[pubdict objectForKey:@"Publication"] count] > 0) {
                [sep setHidden:YES];
                [separator setHidden:NO];
            } else {
                [separator setHidden:YES];
                [sep setHidden:NO];
            }
            
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
    }
    
    else if(sectionType == sectionLeg) {
        
        int w = self.tableView.bounds.size.width;
        
        if(rowType == rowContingencyTitle) {
            
            NSString *contingencyName = (NSString*)rowData;
            
            TitleTableViewCell *titleCell = ((TitleTableViewCell*)cell);
            titleCell.titleLabel.text = contingencyName;
            
            UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage fillRectWithTopRoundCornersWithWidth:w - 40 height:titleCell.bounds.size.height radius:15.0 fillColor:[UIColor colorWithWhite:1.0 alpha:.2]]];
            CGRect frame = bgImage.frame;
            frame.origin.x = 25;
            bgImage.frame = frame;
            
            titleCell.backgroundView = [[UIView alloc] init];
            [titleCell.backgroundView addSubview:bgImage];
        }
        
        else if(rowType == rowContingency) {
            
            NSDictionary *infoDict = (NSDictionary*)rowData;
            
            ContingencyTableViewCell *contCell = ((ContingencyTableViewCell*)cell);
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"HH:mm:ss dd-MM-yyyy";
            
            contCell.dateLb.text    = [df stringFromDate:infoDict[@"date"]];
            contCell.descLb.text    = infoDict[@"cause"];
            contCell.phoneLb.text   = [infoDict[@"phoneCard"] stringValue];
            contCell.snackLb.text   = [infoDict[@"snack"] stringValue];
            contCell.mealLb.text    = [infoDict[@"meal"] stringValue];
            contCell.busLb.text     = [infoDict[@"transfer"] stringValue];
            contCell.hotelLb.text   = [infoDict[@"hotel"] stringValue];
            
            NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            RowType nextRowType = [self getRowTypeForIndexPath:nextIndex];
            BOOL isLast = (nextRowType != rowContingency);
            
            UIView *bgView;
            if(isLast) {
                bgView = [[UIImageView alloc] initWithImage:[UIImage fillRectWithBottomRoundCornersWithWidth:w - 40 height:contCell.bounds.size.height radius:15.0 fillColor:[UIColor colorWithWhite:1.0 alpha:.2]]];
                CGRect frame = bgView.frame;
                frame.origin.x = 25;
                bgView.frame = frame;
            }
            else {
                bgView = [[UIView alloc] initWithFrame:CGRectMake(25, 0, w - 40, contCell.bounds.size.height)];
                bgView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.2];
            }
            
            contCell.backgroundView = [[UIView alloc] init];
            [contCell.backgroundView addSubview:bgView];
        }
        
        else if(rowType == rowRoadMapTitle) {
            
            NSString *phaseName = (NSString*)rowData;
            
            TitleTableViewCell *titleCell = ((TitleTableViewCell*)cell);
            titleCell.titleLabel.text = phaseName;
            titleCell.backgroundView = nil;
        }
        
        else if(rowType == rowRoadMapItem) {
            
            NSDictionary *rmDict = (NSDictionary*)rowData;
            
            RoadMapTableViewCell *rmCell = ((RoadMapTableViewCell*)cell);
            
            rmCell.typeLabel.text = rmDict[@"category"];
            rmCell.descriptionLabel.text = rmDict[@"title"];
            
            CGSize lbSize = rmCell.typeLabel.bounds.size;
            rmCell.typeLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage fillRoundRectWithWidth:lbSize.width height:lbSize.height radius:lbSize.height/2 fillColor:[UIColor colorWithWhite:1.0 alpha:.8]]];
            
            if(((NSString*)rmDict[@"content"]).length == 0) {
                rmCell.infoButton.enabled = NO;
            }
            rmCell.infoButton.tag = [rmDict[@"rmIndex"] intValue];
            [rmCell.infoButton addTarget:self action:@selector(infoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        else if(rowType == rowMealTitle) {
            
            NSString *title = (NSString*)rowData;
            
            TitleTableViewCell *titleCell = ((TitleTableViewCell*)cell);
            titleCell.titleLabel.text = title;
            titleCell.backgroundView = nil;
        }
        
        else if(rowType == rowMealItem) {
            
            NSDictionary *mealDict = (NSDictionary*)rowData;
            
            MealsTableViewCell *mealCell = ((MealsTableViewCell*)cell);
            
            mealCell.cabinClassLabel.text = mealDict[@"cabinCode"];
            NSString *description = @"";
            if([mealDict[@"typeES"] compare:@"O" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                description = [appDel copyTextForKey:@"FD_MEALS_ORIGIN"];
            }
            else if([mealDict[@"typeES"] compare:@"C" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                description = [appDel copyTextForKey:@"FD_MEALS_CENTRALIZED"];
            }
            mealCell.descLabel.text = description;
            mealCell.mealsTextView.text = @"";
            mealCell.amountsTextView.text = @"";
            
            NSArray *services = mealDict[@"services"];
            for(NSDictionary *serviceDict in services) {
                mealCell.mealsTextView.text = [mealCell.mealsTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@ - %@\n", serviceDict[@"code"], serviceDict[@"description"]]];
                mealCell.amountsTextView.text = [mealCell.amountsTextView.text stringByAppendingString:[NSString stringWithFormat:@"%d\n", [serviceDict[@"count"] intValue]]];
            }
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(CGFloat)tableView :(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RowType rowType = [self getRowTypeForIndexPath:indexPath];
    float h = 0.0;
    
    if(rowType == rowFlightDetails) {
        h = 345.0;
    }
    else if(rowType == rowPublication) {
        h = 100.0;
    }
    else if(rowType == rowContingencyTitle) {
        h = 44.0;
    }
    else if(rowType == rowContingency) {
        h = 140.0;
    }
    else if(rowType == rowRoadMapTitle) {
        h = 44.0;
    }
    else if(rowType == rowRoadMapItem) {
        h = 44.0;
    }
    else if(rowType == rowMealTitle) {
        h = 44.0;
    }
    else if(rowType == rowMealItem) {
        NSDictionary *mealsRow = (NSDictionary*)[self getRowDataForIndexPath:indexPath];
        NSArray *services = mealsRow[@"services"];
        h = 30 + 20*services.count;
    }
    
    return h;
}

- (void)infoButtonTouched:(id)sender {
    
    UIButton *infoButton = (UIButton*)sender;
    
    rmdvc = [[RoadMapDetailsViewController alloc] initWithNibName:@"RoadMapDetailsViewController" bundle:nil];
    
    // find html
    
    NSDictionary *(^getInfo)(NSInteger) = ^NSDictionary*(NSInteger index) {
        
        int currentIndex = 0;
        NSArray *legsArray = pubdict[@"legs"];
        for(NSDictionary *legDict in legsArray) {
            
            NSArray *phasesArray = legDict[@"flightPhases"];
            for(NSDictionary *phaseDict in phasesArray) {
                
                NSArray *roadMapInfos = phaseDict[@"details"];
                
                for(NSDictionary *roadMapInfo in roadMapInfos) {
                    
                    if(currentIndex == index) {
                        return roadMapInfo;
                    }
                    currentIndex++;
                }
            }
        }
        
        return nil;
    };
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSDictionary *info = getInfo(infoButton.tag);
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    rmdvc.html = info[@"content"];
    rmdvc.titleStr = info[@"title"];
    rmdvc.subtitleStr = [NSString stringWithFormat:@"%@ %@ %@ %@", [appDel copyTextForKey:@"RM_INFO_FROM"], [df stringFromDate:info[@"startDate"]], [appDel copyTextForKey:@"RM_INFO_TO"], [df stringFromDate:info[@"endDate"]]];
    
    UIViewController *vc= self.navigationController.topViewController;
    [vc addChildViewController:rmdvc];
    [self.navigationController.topViewController.view addSubview:rmdvc.view];
    [rmdvc didMoveToParentViewController:vc];
    [self setFrames];

//    CGRect frame = rmdvc.view.frame;
//    frame.origin = CGPointApplyAffineTransform(vc.view.center, CGAffineTransformTranslate(CGAffineTransformIdentity, -rmdvc.view.bounds.size.width/2, -rmdvc.view.bounds.size.height/2));
//    rmdvc.view.frame = frame;
}

- (void)populateInfoArray {
    
    NSMutableArray *sectionsInfo = [[NSMutableArray alloc] init];
    
    NSMutableArray *rows;
    
    // briefing
    NSDictionary *flightDict = [LTSingleton getSharedSingletonInstance].flightKeyDict;
    NSDictionary *flightKey = [flightDict objectForKey:@"flightKey"];
    if(flightKey) {
        [sectionsInfo addObject:@{kSectionTypeKey : @(sectionFlightDetails), kRowsKey : @[@{kRowTypeKey : @(rowFlightDetails), kDataKey : flightKey}]}];
    }
    
    // publications
    NSArray *publications = [pubdict objectForKey:@"Publication"];
    if(publications.count > 0) {
        rows = [[NSMutableArray alloc] init];
        [sectionsInfo addObject:@{kSectionTypeKey : @(sectionPublications), kRowsKey : rows}];
        for(NSDictionary *publicationDict in publications) {
            [rows addObject:@{kRowTypeKey : @(rowPublication), kDataKey : publicationDict}];
        }
    }
    
    // legs
    NSArray *legsArray = pubdict[@"legs"];
    int rmIndex = 0;
    for(NSDictionary *legDict in legsArray) {
        
        NSMutableArray *legRows = [[NSMutableArray alloc] init];
        BOOL shouldAddRows = NO;
        
        // contingencies
        NSDictionary *contingencyDict = legDict[@"contingency"];
        if(contingencyDict[@"type"]) {
            [legRows addObject:@{kRowTypeKey : @(rowContingencyTitle), kDataKey : contingencyDict[@"type"]}];
            NSArray *contingenciesArray = contingencyDict[@"services"];
            for(NSDictionary *contingencyInfo in contingenciesArray) {
                [legRows addObject:@{kRowTypeKey : @(rowContingency), kDataKey : contingencyInfo}];
            }
            
            shouldAddRows = YES;
        }
        
        // road maps
        NSArray *phasesArray = legDict[@"flightPhases"];
        if(phasesArray.count > 0) {
            shouldAddRows = YES;
        }
        for(NSDictionary *phaseDict in phasesArray) {
            [legRows addObject:@{kRowTypeKey : @(rowRoadMapTitle), kDataKey : phaseDict[@"phase"]}];
            NSArray *roadMapInfos = phaseDict[@"details"];
            for(NSDictionary *roadMapInfo in roadMapInfos) {
                NSMutableDictionary *dataDict = [roadMapInfo mutableCopy];
                dataDict[@"rmIndex"] = @(rmIndex++);
                [legRows addObject:@{kRowTypeKey : @(rowRoadMapItem), kDataKey : dataDict}];
            }
        }
        
        // meals
        NSArray *mealsArray = legDict[@"mealsInfo"];
        if(mealsArray.count > 0) {
            AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [legRows addObject:@{kRowTypeKey : @(rowMealTitle), kDataKey : [appDel copyTextForKey:@"FLIGHT_DETAILS_MEALS"]}];
            shouldAddRows = YES;
        }
        for(NSDictionary *mealDict in mealsArray) {
            [legRows addObject:@{kRowTypeKey : @(rowMealItem), kDataKey : mealDict}];
        }
        
        if(shouldAddRows) {
            [sectionsInfo addObject:@{kSectionTypeKey : @(sectionLeg), kRowsKey : legRows}];
        }
    }
    
    self.sectionsInfo = sectionsInfo;
}

- (NSObject*)getRowDataForIndexPath:(NSIndexPath*)indexPath {
    
    NSDictionary *sectionInfo = self.sectionsInfo[indexPath.section];
    NSDictionary *rowInfo = (sectionInfo[kRowsKey])[indexPath.row];
    
    return rowInfo[kDataKey];
}

- (SectionType)getSectionTypeForSection:(NSInteger)section {
    
    NSDictionary *sectionInfo = self.sectionsInfo[section];
    
    return [sectionInfo[kSectionTypeKey] intValue];
}

- (RowType)getRowTypeForIndexPath:(NSIndexPath*)indexPath {
    
    if(indexPath.section >= self.sectionsInfo.count) {
        return rowNone;
    }
    NSDictionary *sectionInfo = self.sectionsInfo[indexPath.section];
    
    if(indexPath.row >= ((NSArray*)sectionInfo[kRowsKey]).count) {
        return rowNone;
    }
    NSDictionary *rowInfo = (sectionInfo[@"rows"])[indexPath.row];
    
    return [rowInfo[kRowTypeKey] intValue];
}

- (NSString*)getCellIdentifierForIndexPath:(NSIndexPath*)indexPath {

    NSString *cellIdentifier;
    RowType rowType = [self getRowTypeForIndexPath:indexPath];

    if (rowType == rowFlightDetails) {
        cellIdentifier = @"TextViewIdentifier";
    }
    else if (rowType == rowPublication) {
        cellIdentifier = @"TextFieldIdentifier";
    }
    else if (rowType == rowContingencyTitle) {
        cellIdentifier = @"TitleIdentifier";
    }
    else if (rowType == rowContingency) {
        cellIdentifier = @"ContingencyIdentifier";
    }
    else if (rowType == rowRoadMapTitle) {
        cellIdentifier = @"TitleCellIdentifier";
    }
    else if (rowType == rowRoadMapItem) {
        cellIdentifier = @"RoadMapCellIdentifier";
    }
    else if (rowType == rowMealTitle) {
        cellIdentifier = @"TitleCellIdentifier";
    }
    else if (rowType == rowMealItem) {
        cellIdentifier = @"MealsCellIdentifier";
    }

    return cellIdentifier;
}

- (NSString*)getCellNibNameForIndexPath:(NSIndexPath*)indexPath {

    NSString *nibName;
    RowType rowType = [self getRowTypeForIndexPath:indexPath];

    if (rowType == rowFlightDetails) {
        nibName = @"FlightDetailsCell";
    }
    else if (rowType == rowPublication) {
        nibName = @"PublicationsCell";
    }
    else if (rowType == rowContingencyTitle) {
        nibName = @"TitleTableViewCell";
    }
    else if (rowType == rowContingency) {
        nibName = @"ContingencyTableViewCell";
    }
    else if (rowType == rowRoadMapTitle) {
        nibName = @"TitleTableViewCell";
    }
    else if (rowType == rowRoadMapItem) {
        nibName = @"RoadMapTableViewCell";
    }
    else if (rowType == rowMealTitle) {
        nibName = @"TitleTableViewCell";
    }
    else if (rowType == rowMealItem) {
        nibName = @"MealsTableViewCell";
    }

    return nibName;
}

@end