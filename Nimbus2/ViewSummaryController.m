//
//  ViewSummaryController.m
//  LATAM
//
//  Created by Ankush Jain on 5/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "ViewSummaryController.h"
#import "LTCreateFlightReport.h"
#import "LTSingleton.h"
#import "Legs.h"
#import "NSDate+DateFormat.h"
#import "AppDelegate.h"
#import "FlightReportViewController.h"


#define kHeaderHeight 30
#define kCellHeight 40
#define kCellWidth 810
#define kXOffset 20
#define kMultiLineHeight 19
#define kLegKeyWidth @"100"
#define kCameraFieldLength @"100"

@interface ViewSummaryController ()
{
    CGFloat yoffset;
    NSMutableDictionary *summaryDict;
    AppDelegate *apDel;
    UIView *contentView;
    CGFloat contentviewYoffset;
    IBOutlet UIView *generalView;
    IBOutlet UIView *borderView;
    NSArray *reportArr;
    NSArray *sectionArr;
    NSArray *groupArr;
    NSArray *eventArr;
    NSArray *contentArr;
    
    __weak IBOutlet UILabel *generalInfoLabel;
    __weak IBOutlet UILabel *flightDataLbl;
    __weak IBOutlet UIButton *closeBtn;
    __weak IBOutlet UILabel *generalReportLbl;
    __weak IBOutlet UILabel *bpTitleLbl;
    __weak IBOutlet UILabel *crewBase;
}
@property (nonatomic,weak) IBOutlet UIScrollView *summaryScrollView;
@property (nonatomic,strong)NSDictionary *flightReportDict;
@property (nonatomic,strong)NSDictionary *generalInfoDict;
@property (nonatomic,strong)NSArray *reportsArray;
@property (nonatomic,strong)NSMutableDictionary *flightReportDictionary;
@property (weak, nonatomic) IBOutlet UILabel *bpLbl;
@property (weak, nonatomic) IBOutlet UILabel *baseLbl;
@property (weak, nonatomic) IBOutlet UILabel *flightNumLbl;
@property (weak, nonatomic) IBOutlet UILabel *flightMonthLbl;
@property (weak, nonatomic) IBOutlet UILabel *flightDayLbl;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (weak, nonatomic) IBOutlet UILabel *jsbHead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *innerViewLeadingSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerViewHeightConstraint;
@end

@implementation ViewSummaryController
@synthesize flightReportDict;
@synthesize flightReportViewCont;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeData];
    
    if([LTSingleton getSharedSingletonInstance].isFromViewSummary) {
        [self.sendBtn setHidden:NO];
    }
    [borderView.layer setBorderColor:[UIColor colorWithRed:45.0/255.0 green:120.0/255.0 blue:153.0/255.0 alpha:1].CGColor];
    [borderView.layer setCornerRadius:10.0];
    [borderView.layer setBorderWidth:1.0];
    generalReportLbl.text = [apDel copyTextForKey:@"GENERAL_REPORT"];
    [self generateReport];
    
    [closeBtn setTitle:[apDel copyTextForKey:@"CLOSE"] forState:UIControlStateNormal];
    [self.sendBtn setTitle:[apDel copyTextForKey:@"SEND_VIEWSUMMARY"] forState:UIControlStateNormal];
    bpTitleLbl.text = [apDel copyTextForKey:@"GENERAL_BP"];
    crewBase.text = [apDel copyTextForKey:@"GENERAL_CREW_BASE"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:isSummaryClicked];
    // [self.summaryScrollView addSubview:[self generateReportofType:@"GENERAL" withYoffset:0]];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIApplicationWillChangeStatusBarOrientationNotification  object:nil];
    
    generalInfoLabel.text = [apDel copyTextForKey:@"General Information"];
    flightDataLbl.text = [apDel copyTextForKey:@"FLIGHT_DATA_TITLE"];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    UIView *popupView = self.sendBtn.superview;
    CGRect frame = self.sendBtn.frame;
    frame.origin.x = popupView.bounds.size.width - 100;
    self.sendBtn.frame = frame;
}

-(void)orientationChanged:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
            self.innerViewLeadingSpaceConstraint.constant=10;
        }else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
            self.innerViewLeadingSpaceConstraint.constant=87;
        }
        
        UIView *popupView = self.sendBtn.superview;
        CGRect frame = self.sendBtn.frame;
        frame.origin.x = popupView.bounds.size.width - 100;
        self.sendBtn.frame = frame;
    });
}

-(NSString *)getJSONForDict:(NSDictionary *)reportDict {
   
    NSString *jsonStr;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:reportDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonStr;
}

- (void)initializeData {
    reportArr = [NSArray arrayWithObjects:@"GENERAL",@"FIRST",@"BUSINESS",@"PREMIUM ECONOMY",@"ECONOMY",nil];
    sectionArr = [NSArray arrayWithObjects:@"General Information",@"Boarding",@"GENERAL",@"Dutyfree",@"Suggestions",@"Airport",@"Conditioning Cab",@"Elements & CAT APV",@"Quality Service CAT",@"Cabin",@"IFE",nil];
    
    groupArr = [NSArray arrayWithObjects:@"Boarding Information",@"Arrears / Contingency ",@"Boarding",@"Flight",@"Landing",@"Documentation",@"Sales",@"Suggestions",@"Assigning Seats",@"Baggage",@"Conditioning Cab",@"Element APV",@"Elementos de Catering",@"Quality Catering Service",@"Impeccability of Cab",@"Failure Seat recovered in Flight",@"Individual Failures",@"Massive Failures",
                nil];
    
    eventArr = [NSArray arrayWithObjects:@"Sales(USD) Information",@"Reason for no duty free sales",@"Boarding",@"Flight",@"Landing",@"Documentation",@"Sales",@"Assigning Seats",@"Baggage",@"Conditioning Cab",@"Element APV",@"Elementos de Catering",@"Quality Catering Service",@"Impeccability of Cab",@"Failure Seat recovered in Flight",@"Massive Failures",
                 nil];
    
    contentArr = [NSArray arrayWithObjects:@"Type of Boarding",@"Shipment Occurrences",@"TC meets senior roles",@"Solicitud Arnes",@"Request WCH",@"Flight Occurrences",@"Desembarque Occurences",@"Type of Landing",@"Documents sent",@"Waste desq",@"Agua desq",@"Waste embr",@"Agua embr",@"Sales(USD)",@"Missing Items",@"Reason for no duty free sales",@"Suggestions and general feedback flight",@"Suggestions and comments First Economy",@"Suggestions and comments cabin Premium Economy",@"Suggestions and comments cabin Business",@"Suggestions and comments cabin Economy",@"Hand luggage sent to warehouse",@"Misallocated Seats",@"Information seats",@"Duplicates Seats (Check Boarding Pass)",@"State Cab conditioning",@"Material APV-CAT",@"Elements of the Cabin",@"Security Elements",@"Elements of Bath",@"Galley elements",@"Drinks",@"Meals",@"Quality of Service",@"Toilets",@"Galley",@"Cabin",@"Temperature",@"Individual failure IFE",@"Faulty Seat recovered in Flight",@"There were massive failures IFE?",@"Initial state of the system",@"Description of Failure",@"Corrective Action",@"Final System Status", @"Especo Occurences", @"Accomp Occurences", @"Special Passenger Occurrences", @"Special Occurrences", @"Ocorrências Médicas", nil];
    apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    generalView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
    
    
    self.flightReportDict = [LTCreateFlightReport getFlightReportForViewSummary:[[LTSingleton getSharedSingletonInstance].flightRoasterDict mutableCopy]];
    self.flightReportDictionary = [[NSMutableDictionary alloc]init];
    DLog(@"%@",self.flightReportDict);
    
    summaryDict = [[NSMutableDictionary alloc] init];
    //Form summary dict - A common dictionary for reports for all the legs(Report->Section->Group->Event->legs array)
    
    for(NSDictionary *legDict in [self.flightReportDict objectForKey:@"legs"]) {
        
        NSDictionary *generalDict = [[[legDict objectForKey:@"reports"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",@"GENERAL"]] objectAtIndex:0];
        
        if([[generalDict objectForKey:@"name"] isEqualToString:@"GENERAL"]) {
            NSDictionary *generalInfoDict = [[[generalDict objectForKey:@"sections"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",@"General Information"]] objectAtIndex:0];
            NSDictionary *legExecutedDict = [[[generalInfoDict objectForKey:@"groups"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",@"Leg Executed"]] objectAtIndex:0];
            if([[[legExecutedDict objectForKey:@"singleEvents"] objectForKey:@"Leg Executed"] isEqualToString:@"NO"])
                
                continue;
        }
        
        for(NSDictionary *reportDict in [legDict objectForKey:@"reports"]) {
            
            if([[summaryDict allKeys] containsObject:[reportDict objectForKey:@"name"]]) {
                for(NSDictionary *sectionDict in [reportDict objectForKey:@"sections"]) {
                    
                    if([[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] allKeys] containsObject:[sectionDict objectForKey:@"name"]]) {
                        for(NSDictionary *groupDict in [sectionDict objectForKey:@"groups"]) {
                            BOOL isArrearsContingencyAdded = NO;
                            if([groupDict objectForKey:@"singleEvents"]) {
                                
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"MASSIVE_FAILURES"]]) {
                                    
                                    if([[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] objectForKey:[apDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]] == nil) {
                                        NSMutableDictionary *eDict = [[NSMutableDictionary alloc]init];
                                        [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict forKey:[apDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]];
                                        
                                        NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                        [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:[apDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]];
                                    }
                                    else {
                                        [[[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] objectForKey:[apDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]] addObject:legDict];
                                    }
                                }
                                else if([[sectionDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"Boarding"]]) {
                                    if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ATRASOS"]]) {
                                        isArrearsContingencyAdded = YES;
                                        if([[[groupDict objectForKey:@"singleEvents"] objectForKey: [apDel copyEnglishTextForKey:@"GENERAL_HUBRO"]] isEqualToString:@"YES"]) {
                                            NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                            if([[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] == nil)
                                                [[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:legArr forKey:[groupDict objectForKey:@"name"]];
                                            else
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] addObject:legDict];
                                        }
                                    }
                                    else
                                        [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] addObject:legDict];
                                }
                                else {
                                    for(NSString *eventKey in [[groupDict objectForKey:@"singleEvents"] allKeys]) {
                                        
                                        if([[[[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] allKeys] containsObject:eventKey]) {
                                            [[[[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] objectForKey:eventKey] addObject:legDict];
                                        }
                                        else {
                                            
                                        }
                                    }
                                }
                            }
                            
                            if(isArrearsContingencyAdded == NO) {
                                if([[[groupDict objectForKey:@"multiEvents"] allKeys] count]>0) {
                                    if([[groupDict objectForKey:@"name"] isEqualToString:@"Flight"]) {
                                        for (NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys]) {
                                            if([[[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey] count] > 0) {
                                                if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_WCH"]]) {
                                                    if([[[[[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey] objectAtIndex:0] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_WCH"]] isEqualToString:@"0"])
                                                        continue;
                                                }
                                                else if ([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_ARNES"]]) {
                                                    if([[[[[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey] objectAtIndex:0] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_ARNES"]] isEqualToString:@"0"])
                                                        continue;
                                                }
                                            }
                                            if(![[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]]) {
                                                NSMutableDictionary *gDict = [[NSMutableDictionary alloc]init];
                                                [[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict forKey:[groupDict objectForKey:@"name"]];
                                            }
                                            if(![[[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] objectForKey:eventKey]) {
                                                NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                            }
                                            else
                                                [[[[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] objectForKey:eventKey] addObject:legDict];
                                        }
                                    }
                                    
                                    else if([[[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] objectForKey:[sectionDict objectForKey:@"name"]] allKeys] containsObject:[groupDict objectForKey:@"name"]]) {
                                        
                                        for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys]) {
                                            
                                            if([[[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] isKindOfClass:[NSArray class]])
                                                continue;
                                            
                                            
                                            if([[[[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] allKeys] containsObject:eventKey]) {
                                                [[[[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] objectForKey:eventKey] addObject:legDict];
                                            }
                                            else {
                                                NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                                
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]]setObject:legArr forKey:eventKey];
                                                
                                            }
                                        }
                                    }
                                    
                                    else {
                                        NSMutableDictionary *gDict = [[NSMutableDictionary alloc]init];
                                        [[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict forKey:[groupDict objectForKey:@"name"]];
                                        for (NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys]) {
                                            NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                            [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                        }
                                    }
                                }
                                else if([groupDict objectForKey:@"multiEvents"]) {
                                    if([[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] allKeys] containsObject:[sectionDict objectForKey:@"name"]]) {
                                        [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"] ] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] addObject:legDict];
                                    }
                                    else {
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    else
                    {
                        NSMutableDictionary *sDict = [[NSMutableDictionary alloc]init];
                        [[summaryDict objectForKey:[reportDict objectForKey:@"name"]] setObject:sDict forKey:[sectionDict objectForKey:@"name"]];
                        for (NSDictionary *groupDict in [sectionDict objectForKey:@"groups"])
                        {
                            if([groupDict objectForKey:@"singleEvents"]){
                                
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"MASSIVE_FAILURES"]])
                                {
                                    //BOOL switchValue = [[[groupDict objectForKey:@"singleEvents"] objectForKey:[apDel           copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]] boolValue];
                                    NSMutableDictionary *gDict1 = [[NSMutableDictionary alloc]init];
                                    
                                    [[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict1 forKey:[groupDict objectForKey:@"name"]];
                                    
                                    NSMutableDictionary *eDict = [[NSMutableDictionary alloc]init];
                                    [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict forKey:[apDel           copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]];
                                    
                                    NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                    [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:[apDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]];
                                }
                                //Arrears
                                
                                else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ATRASOS"]])
                                {
                                    //Skip if NO
                                    if([[[groupDict objectForKey:@"singleEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_HUBRO"]] isEqualToString:@"NO"])
                                        continue;
                                    NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                    
                                    [[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:legArr forKey:[groupDict objectForKey:@"name"]];
                                    
                                }
                                //Boarding Information
                                else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_INFO"]])
                                {
                                    NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                    
                                    [[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:legArr forKey:[groupDict objectForKey:@"name"]];
                                    
                                }
                                //Duty free
                                else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VENTAS"]])
                                {
                                    
                                    NSMutableDictionary *gDict = [[NSMutableDictionary alloc]init];
                                    [[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict forKey:[groupDict objectForKey:@"name"]];
                                    for (NSString *eventKey in [[groupDict objectForKey:@"singleEvents"] allKeys])
                                    {
                                        if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_MONTO_DE_VENTA"]])
                                        {
                                            NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                            [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                            
                                        }
                                        
                                    }
                                }
                                //Suggestions
                                else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"Suggestions"]])
                                {
                                    
                                    BOOL isSuggestionsFilled = NO;
                                    NSMutableDictionary *sugDict = [[NSMutableDictionary alloc] init];
                                    for (NSString *eventKey in [[groupDict objectForKey:@"singleEvents"] allKeys])
                                    {
                                        if(![[[groupDict objectForKey:@"singleEvents"] objectForKey:eventKey] isEqualToString:@""])
                                        {
                                            isSuggestionsFilled = YES;
                                            [sugDict setObject:[NSNumber numberWithBool:isSuggestionsFilled] forKey:eventKey];
                                        }
                                        
                                    }
                                    if(isSuggestionsFilled)
                                    {
                                        NSMutableDictionary *gDict = [[NSMutableDictionary alloc]init];
                                        [[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict forKey:[groupDict objectForKey:@"name"]];
                                        
                                        for (NSString *eventKey in [[groupDict objectForKey:@"singleEvents"] allKeys])
                                        {
                                            if([[sugDict objectForKey:eventKey] boolValue] == YES)
                                            {
                                                NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                            }
                                        }
                                    }
                                    
                                }
                                else {
                                    NSMutableDictionary *gDict = [[NSMutableDictionary alloc]init];
                                    [[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict forKey:[groupDict objectForKey:@"name"]];
                                    for (NSString *eventKey in [[groupDict objectForKey:@"singleEvents"] allKeys])
                                    {
                                        NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                        [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                    }
                                }
                            }
                            
                            if([[[groupDict objectForKey:@"multiEvents"] allKeys] count]>0)
                            {
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ATRASOS"]] ||[[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_INFO"]] )
                                    continue;
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"MASSIVE_FAILURES"]])
                                {
                                    if([[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyTextForKey:@"INDIVIDUAL_FAILURE _IFE"]])
                                    {
                                        NSMutableDictionary *eDict3 = [[NSMutableDictionary alloc]init];
                                        
                                        [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict3 forKey:[apDel copyTextForKey:@"INDIVIDUAL_FAILURE _IFE"]];
                                        
                                        
                                        NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                        
                                        [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[apDel copyTextForKey:@"INDIVIDUAL_FAILURE _IFE"]] setObject:legArr forKey:[apDel copyTextForKey:@"INDIVIDUAL_FAILURE _IFE"]];
                                    }
                                    
                                    BOOL switchValue = [[[groupDict objectForKey:@"singleEvents"] objectForKey:[apDel           copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]] boolValue];
                                    
                                    if(switchValue){
                                        for (NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys])
                                        {
                                            if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"]]){
                                                NSMutableDictionary *eDict3 = [[NSMutableDictionary alloc]init];
                                                
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict3 forKey:[apDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"]];
                                                
                                                NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                                
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[apDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"]] setObject:legArr forKey:eventKey];
                                            }
                                            else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"]])
                                            {
                                                NSMutableDictionary *eDict3 = [[NSMutableDictionary alloc]init];
                                                
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict3 forKey:[apDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"]];
                                                
                                                NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                                
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[apDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"]] setObject:legArr forKey:eventKey];
                                            }
                                            else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"CORRECTIVE_ACTION"]])
                                            {
                                                NSMutableDictionary *eDict3 = [[NSMutableDictionary alloc]init];
                                                
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict3 forKey:[apDel copyEnglishTextForKey:@"CORRECTIVE_ACTION"]];
                                                
                                                NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                                
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[apDel copyTextForKey:@"CORRECTIVE_ACTION"]] setObject:legArr forKey:eventKey];
                                            }
                                            else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"]])
                                            {
                                                NSMutableDictionary *eDict3 = [[NSMutableDictionary alloc]init];
                                                
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict3 forKey:[apDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"]];
                                                
                                                NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                                
                                                [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[apDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"]] setObject:legArr forKey:eventKey];
                                            }
                                            NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                            [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                        }
                                        
                                    }
                                }
                                //Single event already set the groupdict
                                else if ([[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] allKeys] containsObject:[groupDict objectForKey:@"name"]])
                                {
                                    
                                    for (NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys])
                                    {
                                        //SKIP IF "WERE THERE ANY DUTY FREE SALES" IS YES
                                        if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]])
                                        {
                                            if([[[groupDict objectForKey:@"singleEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_VENTAS_DUTYFREE"]] isEqualToString:@"YES"])
                                            {
                                                continue;
                                            }
                                        }
                                        NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                        [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                    }
                                }
                                else {
                                    NSMutableDictionary *gDict = [[NSMutableDictionary alloc]init];
                                    [[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict forKey:[groupDict objectForKey:@"name"]];
                                    for (NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys])
                                    {
                                        NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                        [[[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                    }
                                }
                            }
                            else if([groupDict objectForKey:@"multiEvents"])
                            {
                                NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                [[[summaryDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]]setObject:legArr forKey:[groupDict objectForKey:@"name"]];
                            }
                        }
                        //Remove empty suggestions
                        if([[[[summaryDict objectForKey:@"GENERAL"] objectForKey:@"Suggestions"] allKeys] count] == 0)
                        {
                            [[summaryDict objectForKey:@"GENERAL"] removeObjectForKey:@"Suggestions"];
                        }
                    }
                }
            }
            else
            {
                NSMutableDictionary *rDict = [[NSMutableDictionary alloc]init];
                [rDict setObject:[[NSMutableDictionary alloc]init] forKey:[reportDict objectForKey:@"name"]];
                for (NSDictionary *sectionDict in [reportDict objectForKey:@"sections"])
                {
                    NSMutableDictionary *sDict = [[NSMutableDictionary alloc]init];
                    [[rDict objectForKey:[reportDict objectForKey:@"name"]] setObject:sDict forKey:[sectionDict objectForKey:@"name"]];
                    for (NSDictionary *groupDict in [sectionDict objectForKey:@"groups"])
                    {
                        if([groupDict objectForKey:@"singleEvents"]){
                            
                            if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"MASSIVE_FAILURES"]])
                            {
                                //                                //SKIP IF NO MASSIVE FAILURES
                                //                                if ([[[groupDict objectForKey:@"singleEvents"] objectForKey:[apDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]] isEqualToString:@"NO"]) {
                                //                                    continue;
                                //                                }
                                //BOOL switchValue = [[[groupDict objectForKey:@"singleEvents"] objectForKey:[apDel           copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]] boolValue];
                                NSMutableDictionary *gDict1 = [[NSMutableDictionary alloc]init];
                                
                                [[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict1 forKey:[groupDict objectForKey:@"name"]];
                                
                                NSMutableDictionary *eDict = [[NSMutableDictionary alloc]init];
                                [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict forKey:[apDel           copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]];
                                
                                NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:[apDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]];
                            }
                            //Arrears
                            
                            else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ATRASOS"]])
                            {
                                //Skip if NO
                                if([[[groupDict objectForKey:@"singleEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_HUBRO"]] isEqualToString:@"NO"])
                                    continue;
                                NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                
                                [[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:legArr forKey:[groupDict objectForKey:@"name"]];
                                
                            }
                            //Boarding Information
                            else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_INFO"]])
                            {
                                NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                
                                [[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:legArr forKey:[groupDict objectForKey:@"name"]];
                                
                            }
                            //Duty free
                            else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VENTAS"]])
                            {
                                
                                NSMutableDictionary *gDict = [[NSMutableDictionary alloc]init];
                                [[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict forKey:[groupDict objectForKey:@"name"]];
                                for (NSString *eventKey in [[groupDict objectForKey:@"singleEvents"] allKeys])
                                {
                                    if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_MONTO_DE_VENTA"]])
                                    {
                                        NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                        [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                        
                                    }
                                    
                                }
                            }
                            //Suggestions
                            else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"Suggestions"]])
                            {
                                
                                BOOL isSuggestionsFilled = NO;
                                NSMutableDictionary *sugDict = [[NSMutableDictionary alloc] init];
                                for (NSString *eventKey in [[groupDict objectForKey:@"singleEvents"] allKeys])
                                {
                                    if(![[[groupDict objectForKey:@"singleEvents"] objectForKey:eventKey] isEqualToString:@""])
                                    {
                                        isSuggestionsFilled = YES;
                                        [sugDict setObject:[NSNumber numberWithBool:isSuggestionsFilled] forKey:eventKey];
                                    }
                                    
                                }
                                if(isSuggestionsFilled)
                                {
                                    NSMutableDictionary *gDict = [[NSMutableDictionary alloc]init];
                                    [[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict forKey:[groupDict objectForKey:@"name"]];
                                    for (NSString *eventKey in [[groupDict objectForKey:@"singleEvents"] allKeys])
                                    {
                                        if([[sugDict objectForKey:eventKey] boolValue] == YES)
                                        {
                                            NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                            [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                        }
                                    }
                                }
                                
                            }
                            else {
                                NSMutableDictionary *gDict = [[NSMutableDictionary alloc]init];
                                [[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict forKey:[groupDict objectForKey:@"name"]];
                                for (NSString *eventKey in [[groupDict objectForKey:@"singleEvents"] allKeys])
                                {
                                    NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                    [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                }
                            }
                        }
                        
                        if([[[groupDict objectForKey:@"multiEvents"] allKeys] count]>0)
                        {
                            if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ATRASOS"]] ||[[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_INFO"]] )
                                continue;
                            if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"MASSIVE_FAILURES"]])
                            {
                                if([[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyTextForKey:@"INDIVIDUAL_FAILURE _IFE"]])
                                {
                                    NSMutableDictionary *eDict3 = [[NSMutableDictionary alloc]init];
                                    
                                    [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict3 forKey:[apDel copyTextForKey:@"INDIVIDUAL_FAILURE _IFE"]];
                                    
                                    
                                    NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                    
                                    [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[apDel copyTextForKey:@"INDIVIDUAL_FAILURE _IFE"]] setObject:legArr forKey:[apDel copyTextForKey:@"INDIVIDUAL_FAILURE _IFE"]];
                                }
                                
                                BOOL switchValue = [[[groupDict objectForKey:@"singleEvents"] objectForKey:[apDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]] boolValue];
                                
                                if(switchValue){
                                    for (NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys])
                                    {
                                        if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"]]){
                                            NSMutableDictionary *eDict3 = [[NSMutableDictionary alloc]init];
                                            
                                            [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict3 forKey:[apDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"]];
                                            
                                            NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                            
                                            [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[apDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"]] setObject:legArr forKey:eventKey];
                                        }
                                        else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"]])
                                        {
                                            NSMutableDictionary *eDict3 = [[NSMutableDictionary alloc]init];
                                            
                                            [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict3 forKey:[apDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"]];
                                            
                                            NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                            
                                            [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[apDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"]] setObject:legArr forKey:eventKey];
                                        }
                                        else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"CORRECTIVE_ACTION"]])
                                        {
                                            NSMutableDictionary *eDict3 = [[NSMutableDictionary alloc]init];
                                            
                                            [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict3 forKey:[apDel copyEnglishTextForKey:@"CORRECTIVE_ACTION"]];
                                            
                                            NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                            
                                            [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[apDel copyTextForKey:@"CORRECTIVE_ACTION"]] setObject:legArr forKey:eventKey];
                                        }
                                        else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"]])
                                        {
                                            NSMutableDictionary *eDict3 = [[NSMutableDictionary alloc]init];
                                            
                                            [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:eDict3 forKey:[apDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"]];
                                            
                                            NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                            
                                            [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[apDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"]] setObject:legArr forKey:eventKey];
                                        }
                                        NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                        [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                    }
                                    
                                }
                            }
                            //Single event already set the groupdict
                            else if ([[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] allKeys] containsObject:[groupDict objectForKey:@"name"]])
                            {
                                
                                for (NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys])
                                {
                                    //SKIP IF "WERE THERE ANY DUTY FREE SALES" IS YES
                                    if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]])
                                    {
                                        if([[[groupDict objectForKey:@"singleEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_VENTAS_DUTYFREE"]] isEqualToString:@"YES"])
                                        {
                                            continue;
                                        }
                                    }
                                    NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                    [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                }
                            }
                            //Overview - skip if it is zero
                            else if([[groupDict objectForKey:@"name"] isEqualToString:@"Flight"])
                            {
                                for (NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys])
                                {
                                    if([[[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey] count] > 0)
                                    {
                                        if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_WCH"]])
                                        {
                                            if([[[[[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey] objectAtIndex:0] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_WCH"]] isEqualToString:@"0"])
                                                continue;
                                        }
                                        else if ([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_ARNES"]])
                                        {
                                            if([[[[[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey] objectAtIndex:0] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_ARNES"]] isEqualToString:@"0"])
                                                continue;
                                        }
                                    }
                                    if(![[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]])
                                    {
                                        NSMutableDictionary *gDict = [[NSMutableDictionary alloc]init];
                                        [[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict forKey:[groupDict objectForKey:@"name"]];
                                    }
                                    NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                    [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                }
                            }
                            else {
                                NSMutableDictionary *gDict = [[NSMutableDictionary alloc]init];
                                [[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] setObject:gDict forKey:[groupDict objectForKey:@"name"]];
                                for (NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys])
                                {
                                    NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                                    [[[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]] objectForKey:[groupDict objectForKey:@"name"]] setObject:legArr forKey:eventKey];
                                }
                            }
                        }
                        else if([groupDict objectForKey:@"multiEvents"])
                        {
                            NSMutableArray *legArr = [[NSMutableArray alloc]initWithObjects:legDict, nil];
                            [[[rDict objectForKey:[reportDict objectForKey:@"name"]] objectForKey:[sectionDict objectForKey:@"name"]]setObject:legArr forKey:[groupDict objectForKey:@"name"]];
                        }
                    }
                    
                }
                //Remove empty suggestions
                if([[[[rDict objectForKey:@"GENERAL"] objectForKey:@"Suggestions"] allKeys] count] == 0) {
                    [[rDict objectForKey:@"GENERAL"] removeObjectForKey:@"Suggestions"];
                }
                [summaryDict setObject:[rDict objectForKey:[reportDict objectForKey:@"name"]] forKey:[reportDict objectForKey:@"name"]];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSArray *)getSectionsArrayBasedOnFlightType:(NSString *)flightType {
    NSArray *sectionArray;
    if([flightType isEqualToString:NBLAN]){
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"PREMIUM ECONOMY",@"ECONOMY",nil];
        
    }
    else if([flightType isEqualToString:WBLAN]){
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"BUSINESS",@"ECONOMY",nil];
        
    }
    else if([flightType isEqualToString:DOMLAN]){
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"ECONOMY",nil];
        
    }
    else if([flightType isEqualToString:NBTAM]){
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"BUSINESS",@"ECONOMY",nil];
    }
    else if([flightType isEqualToString:WBTAM]){
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"BUSINESS",@"ECONOMY",nil];
        
    }
    
    else if([flightType isEqualToString:DOMTAM]){
        sectionArray = [[NSMutableArray alloc] initWithObjects:@"GENERAL",@"ECONOMY",nil];
        
    }
    
    return sectionArray;
}

#pragma mark - Internal methods
- (IBAction)closeBtnClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:isSummaryClicked];
    [self.view removeFromSuperview];
}
- (IBAction)sendBtnClicked:(id)sender {
    [flightReportViewCont performSelector:@selector(sendReport) withObject:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:isSummaryClicked];
    [self.view removeFromSuperview];
}

-(void)generateReport {
    
    yoffset = 290;
    
    [self createGeneralInformation];
    NSArray *repoArr;
    if([[summaryDict allKeys] count] == [[self getSectionsArrayBasedOnFlightType:[self.flightReportDict objectForKey:@"flightReportType"]] count]) {
        repoArr = [summaryDict allKeys];
    }
    else {
        repoArr = [self getSectionsArrayBasedOnFlightType:[self.flightReportDict objectForKey:@"flightReportType"]];
    }
    
    NSArray *reorderedArray1 = [self reorderArray:repoArr toArray:reportArr];
    for(NSString *reportName in reorderedArray1) {
        if(![reportName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL"]])
            [self createReportHeaderWithTitle:[apDel valueForEnglishValue:reportName]];
        if([[[summaryDict objectForKey:reportName] allKeys] count] == 0) {
            [self noReportsMadeMessage];
        }
        
        NSArray *reorderedArray2 = [self reorderArray:[[summaryDict objectForKey:reportName] allKeys] toArray:sectionArr];
        for(NSString *sectionName in reorderedArray2) {
            
            if([sectionName isEqualToString:[apDel copyEnglishTextForKey:@"General Information"]]) {
                continue;
            }
            
            [self createSectionHeaderWithTitle:[apDel valueForEnglishValue:sectionName]];
            NSArray *reorderedArray3 = [self reorderArray:[[[summaryDict objectForKey:reportName] objectForKey:sectionName] allKeys] toArray:groupArr];
            for(NSString *groupName in reorderedArray3) {
                
                NSArray *keysArr;
                NSArray *widthsArr;
                
                if([[[[summaryDict objectForKey:reportName] objectForKey:sectionName] objectForKey:groupName] isKindOfClass:[NSArray class]]) {
                    contentView = [[UIView alloc] init];
                    [contentView setBackgroundColor:[UIColor clearColor]];
                    contentView.layer.cornerRadius = 10.0;
                    contentView.layer.borderWidth = 1.0;
                    contentView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
                    contentView.clipsToBounds = YES;
                    contentviewYoffset = kCellHeight;
                    [self createGroupHeaderWithTitle:[apDel valueForEnglishValue:groupName]];
                    //Boarding Information
                    if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_INFO"]]) {
                        keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_HORA_MINIMA"],[apDel copyTextForKey:@"GENERAL_HORA_PUERTAS"] ,nil];
                        widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350", nil];
                    }
                    else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_FIRST_SUGEGSTIONS"]]){
                        
                        keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_FIRST_SUGEGSTIONS"],nil];
                        widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"400",nil];
                        
                    }
                    
                    //Arrears-Contingency
                    if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ATRASOS"]]) {
                        
                        keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_TIEMPO"],[apDel copyTextForKey:@"GENERAL_MOTIVO"],[apDel copyTextForKey:@"GENERAL_ACCIONES"],nil];
                        widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"140",@"275",@"275",nil];
                    }
                    
                    [self createSectionWithLegArr:[[[summaryDict objectForKey:reportName] objectForKey:sectionName] objectForKey:groupName] keyValuesArr:keysArr widthsArr:widthsArr forEvent:@"" forGroup:groupName forSection:sectionName forReport:reportName];
                }
                else {
                    BOOL isArrearsContingencyAdded = NO;
                    
                    NSArray *reorderedArray4 = [self reorderArray:[[[[summaryDict objectForKey:reportName] objectForKey:sectionName] objectForKey:groupName]allKeys] toArray:contentArr];
                    for(NSString *eventName in reorderedArray4) {
                        if(isArrearsContingencyAdded && [groupName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ATRASOS"]]) {
                            continue;
                        }
                        
                        contentView = [[UIView alloc] init];
                        [contentView setBackgroundColor:[UIColor clearColor]];
                        contentView.layer.cornerRadius = 10.0;
                        contentView.layer.borderWidth = 1.0;
                        contentView.clipsToBounds = YES;
                        contentviewYoffset = kCellHeight;
                        contentView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
                        
                        NSString *title = [apDel valueForEnglishValue:eventName];
                        if([title isEqualToString:[apDel copyTextForKey:@"GENERAL_SPECIAL_PASS_OCC"]]) {
                            title = [apDel copyTextForKey:@"GEN_ADD_PASS_SPEC_OCC"];
                        }
                        else if([title isEqualToString:[apDel copyTextForKey:@"GENERAL_ACCOMP_OCC"]]) {
                            title = [apDel copyTextForKey:@"GEN_ADD_ACCOMP_OCC"];
                        }
                        else if([title isEqualToString:[apDel copyTextForKey:@"AGUA_EMBARQUE"]]) {
                         title = [apDel copyTextForKey:@"TITULO_WST_BRQ"];
                        }
                        else if([title isEqualToString:[apDel copyTextForKey:@"AGUA_DESEMBARQUE"]]) {
                         title = [apDel copyTextForKey:@"TITULO_WST_DRQ"];
                        }
                        else if([title isEqualToString:[apDel copyTextForKey:@"WASTE_EMBARQUE"]]) {
                            title = [apDel copyTextForKey:@"TITULO_WTR_BRQ"];
                        }
                        else if([title isEqualToString:[apDel copyTextForKey:@"WASTE_DESEMBARQUE"]]) {
                            title = [apDel copyTextForKey:@"TITULO_WTR_DRQ"];
                        }
                        
                        [self createGroupHeaderWithTitle:[[apDel valueForEnglishValue:groupName] stringByAppendingFormat:@" - %@", title]];
                        
                        //Arrears-Contingency
                        if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ATRASOS"]]) {
                            //Reasons or Actions taken
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_MOTIVO"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_TIEMPO"],[apDel copyTextForKey:@"GENERAL_MOTIVO"],[apDel copyTextForKey:@"GENERAL_ACCIONES"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"230",@"230",@"230",nil];
                                isArrearsContingencyAdded = YES;
                            }
                        }
                        
                        // Dutyfree
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VENTAS"]]) {
                            
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ITEMS_FALTANTES"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"CODIGO_PRODUCTO"],[apDel copyTextForKey:@"AMOUNT"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                                
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REASON"],[apDel copyTextForKey:@"OBSERVATION"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                                
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_MONTO_DE_VENTA"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_VENTAS_DUTYFREE"],[apDel copyTextForKey:@"GENERAL_MONTO_DE_VENTA"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                            }
                        }
                        
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"]]) {
                            
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_OCC"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"OBSERVATION"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                                
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_TIPO_EMBARQUE"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_TIPO_EMBARQUE"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"600",nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SPECIAL_PASS_OCC"]] ||
                                    [eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SPECIAL_OCC"]] ||
                                    [eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ESPECO_OCC"]] ||
                                    [eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ACCOMP_OCC"]]) {
                                
                                NSString *occurrenceTitleKey = @"REPORT@TAM";
                                if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ACCOMP_OCC"]]) {
                                    occurrenceTitleKey = @"QUANT_ACCOMP";
                                }
                                
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:occurrenceTitleKey],[apDel copyTextForKey:@"COMMENTS"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth, @"250", @"500",nil];
                            }
                        }
                        
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VUELO"]]) {
                            
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_OCC"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"OBSERVATION"], nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_WCH"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_WCH"],[apDel copyTextForKey:@"OBSERVATION"], nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_ARNES"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_ARNES"],[apDel copyTextForKey:@"OBSERVATION"], nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_CUMPLE_OCC"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"TC_NOMBRE"],[apDel copyTextForKey:@"TC_BP"], nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ADD_MEDICAS"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REPORT@TAM"],[apDel copyTextForKey:@"COMMENTS"], nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth, @"250", @"500",nil];
                            }
                        }
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"]]) {
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE_OCC"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"OBSERVATION"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"230",@"230",@"230",nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_TIPO_DESEMBARQUE"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_TIPO_DESEMBARQUE"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"600",nil];
                            }
                        }
                        
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_DOCUMENTOS"]]){
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_DOCUMENTOS_OCC"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"AMOUNT"],[apDel copyEnglishTextForKey:@"DOCUMENTO"],[apDel copyTextForKey:@"OBSERVATION"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"230",@"230",@"230",nil];
                            }
                        }
                        //Suggestions
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"Suggestions"]]) {
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"]]){
                                
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"600",nil];
                                
                            }
                            
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"]]){
                                
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"600",nil];
                                
                            }
                            
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_PRE_ECONOMY_SUGEGSTIONS"]]) {
                                
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_PRE_ECONOMY_SUGEGSTIONS"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"600",nil];
                                
                            }
                            
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"]]){
                                
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"600",nil];
                            }
                        }
                        //Assigning seats
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"AIRPORT_ASSIGNSEAT"]]) {
                            //Misallocated Seats
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"AIRPORT_MALASSIGNED"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REASON"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"600",nil];
                            }
                            //Information seat
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"AIRPORT_PROPERTYINFOSEAT"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REPORT"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"600",nil];
                            }
                            //Duplicate seat
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"AIRPORT_DUPLICATESEAT"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"AIRPORT_FULLNAME"] ,nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                            }
                        }
                        //Baggage
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"AIRPORT_BAGGAGE"]]) {
                            if([[self.flightReportDict objectForKey:@"flightReportType"] containsString:@"TAM"]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REASON"],[apDel copyTextForKey:@"AMOUNT"],[apDel copyTextForKey:@"OBSERVATION"],[apDel copyTextForKey:@"CAMERA"] ,nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"260",@"150",@"180",kCameraFieldLength,nil];
                            }
                            else {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REASON"],[apDel copyTextForKey:@"AMOUNT"],[apDel copyTextForKey:@"CAMERA"] ,nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"300",@"290",kCameraFieldLength,nil];
                            }
                        }
                        //State Cab Conditioning
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"CAB_CONDITIONING"]]) {
                            keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"OBSERVATION"],[apDel copyTextForKey:@"CAMERA"],nil];
                            widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"250",kCameraFieldLength,nil];
                        }
                        //Element de Catering
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_CATERING"]]) {
                            //Liquids
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_LIQUIDS"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"ELEMENT"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"AMOUNT"],[apDel copyTextForKey:@"OBSERVATION"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"175",@"175",@"100",@"240",nil];
                            }
                            //Meals
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_MEALS"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"SERVICE"],[apDel copyTextForKey:@"OPTION"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"AMOUNT"],[apDel copyTextForKey:@"OBSERVATION"],[apDel copyTextForKey:@"CAMERA"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"100",@"100",@"100",@"140",@"160",@"100",nil];
                            }
                        }
                        //Element APV
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_APV"]]) {
                            //element apv
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_MATERIAL_APV_CAT"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"ELEMENT"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"AMOUNT"],[apDel copyTextForKey:@"OBSERVATION"],[apDel copyTextForKey:@"CAMERA"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"175",@"175",@"100",@"140",kCameraFieldLength,nil];
                            }
                            //cabin
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_CABIN"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"ELEMENT"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"AMOUNT"],[apDel copyTextForKey:@"OBSERVATION"],[apDel copyTextForKey:@"CAMERA"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"175",@"175",@"100",@"140",kCameraFieldLength,nil];
                            }
                            //security
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_SECURITY"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"ELEMENT"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"AMOUNT"],[apDel copyTextForKey:@"OBSERVATION"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"175",@"175",@"100",@"240",nil];
                            }
                            //bath
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_BATH"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"ELEMENT"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"AMOUNT"],[apDel copyTextForKey:@"OBSERVATION"],[apDel copyTextForKey:@"CAMERA"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"175",@"175",@"100",@"140",kCameraFieldLength,nil];
                            }
                            //galley
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_GALLEY"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"ELEMENT"],[apDel copyTextForKey:@"REPORT"],[apDel copyTextForKey:@"AMOUNT"],[apDel copyTextForKey:@"OBSERVATION"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"175",@"175",@"100",@"240",nil];
                            }
                        }
                        //Cabin
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"IMPECCABILITY_OF_CAB"]]) {
                            
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"TOILETS"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REPORT"],
                                           [apDel copyTextForKey:@"OBSERVATION"],[apDel copyTextForKey:@"CAMERA"],nil];
                                
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"250",kCameraFieldLength,nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GALLEY"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REPORT"],
                                           [apDel copyTextForKey:@"OBSERVATION"],[apDel copyTextForKey:@"CAMERA"],nil];
                                
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"250",kCameraFieldLength,nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"CABIN"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"REPORT"],
                                           [apDel copyTextForKey:@"OBSERVATION"],[apDel copyTextForKey:@"CAMERA"]   ,nil];
                                
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"250",kCameraFieldLength,nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"TEMPERATURE"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"TEMPERATURE"],
                                           [apDel copyTextForKey:@"OBSERVATION"],nil];
                                
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                            }
                        }
                        //Cabin
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"FAILURE_SEAT_RECOVERED_IN_FLIGHT"]]) {
                            
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT"]]){
                                
                                
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyEnglishTextForKey:@"FAILURE"],
                                           [apDel copyTextForKey:@"SEAT_ROW"],
                                           [apDel copyTextForKey:@"SEAT_LETTER"],
                                           [apDel copyTextForKey:@"OBSERVATION"],nil];
                                
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"175",@"175",@"175",@"175",nil];
                            }
                        }
                        //Quality Catering Service
                        else if ([groupName isEqualToString:[apDel copyEnglishTextForKey:@"QUALITY_CATERING_SERVICE"]]) {
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"QUALITY_OF_SERVICE"]]){
                                
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyEnglishTextForKey:@"SERVICE"],
                                           [apDel copyTextForKey:@"OPTION"],
                                           [apDel copyTextForKey:@"REPORT"],
                                           [apDel copyTextForKey:@"AMOUNT"],
                                           [apDel copyTextForKey:@"OBSERVATION"],[apDel copyTextForKey:@"CAMERA"],nil];
                                
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"100",@"100",@"100",@"140",@"160",@"100",nil];
                            }
                        }
                        //IFE
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURES"]]){
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURE _IFE"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"SELECT_REASON"],
                                           [apDel copyTextForKey:@"SEAT_ROW"],
                                           [apDel copyTextForKey:@"SEAT_LETTER"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"230",@"230",@"230",nil];
                                
                            }
                            
                        }
                        else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"MASSIVE_FAILURES"]]) {
                            
                            //                            NSDictionary *dict = [[[[summaryDict objectForKey:reportName] objectForKey:sectionName] objectForKey:groupName] objectForKey:eventName];
                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]])
                            {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:@"400",@"400",nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"]]) {
                                keysArr = [[NSArray alloc] initWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],                                        [apDel copyTextForKey :@"SELECT_STATE"],[apDel copyTextForKey:@"OBSERVATION"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"]] ){
                                
                                keysArr = [[NSArray alloc] initWithObjects:
                                           [apDel copyTextForKey:@"LEG_TEXT"],
                                           [apDel copyTextForKey:@"TIME_OF_FLIGHT"],
                                           [apDel copyTextForKey:@"FAULT_TYPE"],
                                           [apDel copyTextForKey:@"DURATION_OF_FAILURE"],
                                           [apDel copyTextForKey:@"SEATING"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"175",@"175",@"175",@"175",nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"CORRECTIVE_ACTION"]]){
                                keysArr = [[NSArray alloc] initWithObjects:
                                           [apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"AREA_RESET"],
                                           [apDel copyTextForKey:@"NUMBER_OF_RESETS"],nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                            }
                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"]]){
                                keysArr = [[NSArray alloc] initWithObjects:
                                           [apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"SELECT_STATE"],[apDel copyTextForKey:@"OBSERVATION"],
                                           nil];
                                widthsArr = [[NSArray alloc] initWithObjects:kLegKeyWidth,@"350",@"350",nil];
                            }
                        }
                        [self createSectionWithLegArr:[[[[summaryDict objectForKey:reportName] objectForKey:sectionName] objectForKey:groupName] objectForKey:eventName] keyValuesArr:keysArr widthsArr:widthsArr forEvent:eventName forGroup:groupName forSection:sectionName forReport:reportName];
                    }
                }
            }
        }
    }
    
    [self.summaryScrollView setContentSize:CGSizeMake(self.summaryScrollView.frame.size.width, yoffset + 100)];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:isSummaryClicked];
}


-(void)createSectionWithLegArr:(NSArray *)legArr keyValuesArr:(NSArray *)keyValuesArr widthsArr:(NSArray *)widthsArr forEvent:(NSString *)eventName forGroup:(NSString *)groupName forSection:(NSString *)sectionName forReport:(NSString *)reportName {
    
    CGFloat initialYoffset = yoffset - kCellHeight;
    
    [self generateHeaderWithKeyValuesArr:keyValuesArr andWidthArr:widthsArr andHeight:kHeaderHeight];
    NSMutableArray *finalArr = [[NSMutableArray alloc] init];
    NSMutableArray *valuesArr ;//= [[NSMutableArray alloc] init];
    
    for(NSDictionary *legDict in legArr) {
        NSString *legDetail = [NSString stringWithFormat:@"%@ - %@",[legDict objectForKey:@"origin"],[legDict objectForKey:@"destination"]];
        valuesArr = [[NSMutableArray alloc] init];
        [valuesArr addObject:legDetail];
        CGFloat cellHeight = 0;
        for(NSDictionary *reportDict in [legDict objectForKey:@"reports"]) {
            if([[reportDict objectForKey:@"name"] isEqualToString:reportName]) {
                for(NSDictionary *sectionDict in [reportDict objectForKey:@"sections"]) {
                    if([[sectionDict objectForKey:@"name"] isEqualToString:sectionName]) {
                        for(NSDictionary *groupDict in [sectionDict objectForKey:@"groups"]) {
                            if([[groupDict objectForKey:@"name"] isEqualToString:groupName]) {
                                
                                // Dutyfree
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VENTAS"]]){
                                    
                                    if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_MONTO_DE_VENTA"]]) {
                                        valuesArr = [[NSMutableArray alloc] init];
                                        [valuesArr addObject:legDetail];
                                        
                                        NSString *ventas = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_VENTAS_DUTYFREE"]];
                                        [valuesArr addObject:[apDel copyTextForKey:ventas]];
                                        
                                        NSString *sales = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_MONTO_DE_VENTA"]];
                                        [valuesArr addObject:sales];
                                        
                                        [finalArr addObject:valuesArr];
                                    }
                                    
                                    
                                    else if ([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]]) {
                                        
                                        for(NSDictionary *occurences in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_SIN_VENTAS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            NSMutableString *comment ;//= [[NSMutableString alloc] init];
                                            NSMutableString *reason;// = [[NSMutableString alloc] init];
                                            comment = [occurences objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]];
                                            reason = [occurences objectForKey:[apDel copyEnglishTextForKey:@"REASON"]];
                                            [valuesArr addObject:reason];
                                            [valuesArr addObject:comment];
                                            [finalArr addObject:valuesArr];
                                            ////cellHeight += kMultiLineHeight;
                                        }
                                    }
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ITEMS_FALTANTES"]]) {
                                        
                                        for(NSDictionary *missingItem in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_ITEMS_FALTANTES"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            
                                            NSMutableString *amount = [[NSMutableString alloc] init];
                                            NSMutableString *pcode = [[NSMutableString alloc] init];
                                            [amount appendFormat:@"%@\n",[missingItem objectForKey:[apDel copyEnglishTextForKey:@"AMOUNT"]]];
                                            [pcode appendFormat:@"%@\n",[missingItem objectForKey:[apDel copyEnglishTextForKey:@"CODIGO_PRODUCTO"]]];
                                            ////cellHeight += kMultiLineHeight;
                                            
                                            [valuesArr addObject:pcode];
                                            [valuesArr addObject:amount];
                                            [finalArr addObject:valuesArr];
                                        }
                                    }
                                }
                                // Suggestions
                                
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"Suggestions"]]) {
                                    
                                    NSString *type = [[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"flightReportType"];
                                    
                                    if([type isEqualToString:WBLAN] || [type isEqualToString:NBLAN]){
                                        NSDictionary *singleDict = [groupDict objectForKey:@"singleEvents"];
                                        if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_PRE_ECONOMY_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_PRE_ECONOMY_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        
                                        
                                    }
                                    else if([type isEqualToString:DOMLAN]) {
                                        NSDictionary *singleDict = [groupDict objectForKey:@"singleEvents"];
                                        if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        
                                    }
                                    else if([type isEqualToString:NBTAM]) {
                                        NSDictionary *singleDict = [groupDict objectForKey:@"singleEvents"];
                                        if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        
                                    }
                                    else if([type isEqualToString:WBTAM]) {
                                        NSDictionary *singleDict = [groupDict objectForKey:@"singleEvents"];
                                        if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_FIRST_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_FIRST_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_BUSINESS_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        
                                    }
                                    else if([type isEqualToString:DOMTAM]) {
                                        NSDictionary *singleDict = [groupDict objectForKey:@"singleEvents"];
                                        if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[singleDict objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_ECONOMY_SUGEGSTIONS"]]];
                                            [finalArr addObject:valuesArr];
                                        }
                                        
                                    }
                                }
                                
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_FIRST_SUGEGSTIONS"]]){
                                    valuesArr = [[NSMutableArray alloc] init];
                                    [valuesArr addObject:legDetail];
                                    
                                    NSString *content = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_FIRST_SUGEGSTIONS"]];
                                    [valuesArr addObject:content];
                                    [finalArr addObject:valuesArr];
                                }
                                
                                
                                
                                //Shipment - Overview
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_EMBARQUE"]])
                                {
                                    if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_OCC"]])
                                    {
                                        
                                        
                                        for(NSDictionary *occurences in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_OCC"]])
                                        {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            NSMutableString *report = [[NSMutableString alloc] init];
                                            NSMutableString *comments = [[NSMutableString alloc] init];
                                            
                                            [report appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                            [comments appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                            ////cellHeight += kMultiLineHeight;
                                            
                                            [valuesArr addObject:report];
                                            [valuesArr addObject:comments];
                                            
                                            [finalArr addObject:valuesArr];
                                        }
                                        
                                        break;
                                        
                                    }
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_TIPO_EMBARQUE"]])
                                    {
                                        valuesArr = [[NSMutableArray alloc] init];
                                        
                                        //GENERAL_REMOTO
                                        
                                        
                                        [valuesArr addObject:legDetail];
                                        
                                        NSString *type = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_TIPO_EMBARQUE"]];
                                        if([type isEqualToString:@"Remote"])
                                            type = [apDel copyTextForKey:@"GENERAL_REMOTO"];
                                        else if([type isEqualToString:@"Manga"])
                                            type = [apDel copyTextForKey:@"GENERAL_MANGA"];
                                        else if ([type isEqualToString:@"GENERAL_SELECT"])
                                            type=[apDel copyTextForKey:@"GENERAL_SELECT"];
                                        [valuesArr addObject:type];
                                        [finalArr addObject:valuesArr];
                                    }
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"WASTE_EMBARQUE"]])
                                    {
                                        valuesArr = [[NSMutableArray alloc] init];
                                        
                                        //GENERAL_REMOTO
                                        
                                        
                                        [valuesArr addObject:legDetail];
                                        
                                        NSString *type = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"WASTE_EMBARQUE"]];
                                        [valuesArr addObject:type];
                                        [finalArr addObject:valuesArr];
                                    }
                                    
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"AGUA_EMBARQUE"]])
                                    {
                                        valuesArr = [[NSMutableArray alloc] init];
                                        
                                        //GENERAL_REMOTO
                                        
                                        
                                        [valuesArr addObject:legDetail];
                                        
                                        NSString *type = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"AGUA_EMBARQUE"]];
                                        [valuesArr addObject:type];
                                        [finalArr addObject:valuesArr];
                                    }
                                    
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SPECIAL_PASS_OCC"]] ||
                                            [eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SPECIAL_OCC"]] ||
                                            [eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ESPECO_OCC"]] ||
                                            [eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ACCOMP_OCC"]]) {
                                        
                                        for(NSDictionary *occurences in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventName]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            NSString *valueToAdd = @"[error loading string]";
                                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SPECIAL_PASS_OCC"]]) {
                                                valueToAdd = [occurences objectForKey:@"Number Indicated"];
                                            }
                                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SPECIAL_OCC"]]) {
                                                valueToAdd = [occurences objectForKey:@"Report"];
                                            }
                                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ESPECO_OCC"]]) {
                                                valueToAdd = [occurences objectForKey:@"Option"];
                                            }
                                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ACCOMP_OCC"]]) {
                                                valueToAdd = [occurences objectForKey:@"Accompanied Quant"];
                                            }
                                            
                                            NSString *comments = [occurences objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]];
                                            if(comments == nil) {
                                                comments = @"";
                                            }
                                            
                                            ////cellHeight += kMultiLineHeight;
                                            
                                            [valuesArr addObject:valueToAdd];
                                            [valuesArr addObject:comments];
                                            
                                            [finalArr addObject:valuesArr];
                                        }
                                    }
                                    
                                }
                                
                                // Flight - Overview
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VUELO"]]) {
                                    if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_OCC"]]) {
                                        for(NSDictionary *occurences in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_VUELO_OCC"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            NSMutableString *report = [[NSMutableString alloc] init];
                                            NSMutableString *comments = [[NSMutableString alloc] init];
                                            [report appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                            [comments appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                            ////cellHeight += kMultiLineHeight;
                                            
                                            [valuesArr addObject:report];
                                            [valuesArr addObject:comments];
                                            [finalArr addObject:valuesArr];
                                        }
                                    }
                                    
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_WCH"]]) {
                                        
                                        for(NSDictionary *occurences in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_WCH"]]) {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            NSMutableString *sarnes = [[NSMutableString alloc] init];
                                            NSMutableString *comments = [[NSMutableString alloc] init];
                                            [sarnes appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_WCH"]]];
                                            [comments appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                            ////cellHeight += kMultiLineHeight;
                                            
                                            [valuesArr addObject:sarnes];
                                            [valuesArr addObject:comments];
                                            [finalArr addObject:valuesArr];
                                        }
                                        
                                    }
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_ARNES"]])
                                    {
                                        
                                        for(NSDictionary *occurences in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_SOLICITUD_ARNES"]])
                                        {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            NSMutableString *sarnes = [[NSMutableString alloc] init];
                                            NSMutableString *comments = [[NSMutableString alloc] init];
                                            [sarnes appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_ARNES"]]];
                                            [comments appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                            //cellHeight += kMultiLineHeight;
                                            
                                            [valuesArr addObject:sarnes];
                                            [valuesArr addObject:comments];
                                            [finalArr addObject:valuesArr];
                                        }
                                        
                                    }
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_CUMPLE_OCC"]])
                                    {
                                        
                                        for(NSDictionary *occurences in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_CUMPLE_OCC"]])
                                        {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            NSMutableString *bp = [[NSMutableString alloc] init];
                                            NSMutableString *tcname = [[NSMutableString alloc] init];
                                            [bp appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"TC_BP"]]];
                                            [tcname appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"TC_NOMBRE"]]];
                                            //cellHeight += kMultiLineHeight;
                                            [valuesArr addObject:tcname];
                                            [valuesArr addObject:bp];
                                            [finalArr addObject:valuesArr];
                                        }
                                        
                                        
                                    }
                                    
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ADD_MEDICAS"]])
                                    {
                                        
                                        for(NSDictionary *occurences in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_ADD_MEDICAS"]])
                                        {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            NSMutableString *occurrence = [[NSMutableString alloc] init];
                                            NSMutableString *comment = [[NSMutableString alloc] init];
                                            [occurrence appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                            [comment appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                            //cellHeight += kMultiLineHeight;
                                            [valuesArr addObject:occurrence];
                                            [valuesArr addObject:comment];
                                            [finalArr addObject:valuesArr];
                                        }
                                    }
                                }
                                
                                // Landing - Overview
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE"]])
                                {
                                    if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE_OCC"]])
                                    {
                                        
                                        for(NSDictionary *occurences in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_DESEMBARQUE_OCC"]])
                                        {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            NSMutableString *report = [[NSMutableString alloc] init];
                                            NSMutableString *comments = [[NSMutableString alloc] init];
                                            
                                            [report appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                            [comments appendFormat:@"%@\n",[occurences objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                            //cellHeight += kMultiLineHeight;
                                            [valuesArr addObject:report];
                                            [valuesArr addObject:comments];
                                            [finalArr addObject:valuesArr];
                                        }
                                        
                                    }
                                    
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_TIPO_DESEMBARQUE"]])
                                    {
                                        valuesArr = [[NSMutableArray alloc] init];
                                        [valuesArr addObject:legDetail];
                                        
                                        NSString *desembarque = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_TIPO_DESEMBARQUE"]];
                                        if([desembarque isEqualToString:@"Remote"])
                                            desembarque = [apDel copyTextForKey:@"GENERAL_REMOTO"];
                                        else if([desembarque isEqualToString:@"Manga"])
                                            desembarque = [apDel valueForEnglishValue:@"Manga"];
                                        
                                        [valuesArr addObject:desembarque];
                                        [finalArr addObject:valuesArr];
                                    }
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"WASTE_DESEMBARQUE"]])
                                    {
                                        valuesArr = [[NSMutableArray alloc] init];
                                        
                                        //GENERAL_REMOTO
                                        
                                        
                                        [valuesArr addObject:legDetail];
                                        
                                        NSString *type = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"WASTE_DESEMBARQUE"]];
                                        [valuesArr addObject:type];
                                        [finalArr addObject:valuesArr];
                                    }
                                    
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"AGUA_DESEMBARQUE"]])
                                    {
                                        valuesArr = [[NSMutableArray alloc] init];
                                        
                                        //GENERAL_REMOTO
                                        
                                        
                                        [valuesArr addObject:legDetail];
                                        
                                        NSString *type = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"AGUA_DESEMBARQUE"]];
                                        [valuesArr addObject:type];
                                        [finalArr addObject:valuesArr];
                                    }
                                }
                                
                                // Documentation - Overview
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_DOCUMENTOS"]])
                                {
                                    
                                    for(NSDictionary *documentsSent in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_DOCUMENTOS_OCC"]])
                                    {
                                        valuesArr = [[NSMutableArray alloc] init];
                                        [valuesArr addObject:legDetail];
                                        
                                        NSMutableString *amount = [[NSMutableString alloc] init];
                                        NSMutableString *document = [[NSMutableString alloc] init];
                                        NSMutableString *comments = [[NSMutableString alloc] init];
                                        [amount appendFormat:@"%@\n",[documentsSent objectForKey:[apDel copyEnglishTextForKey:@"AMOUNT"]]];
                                        [document appendFormat:@"%@\n",[documentsSent objectForKey:[apDel copyEnglishTextForKey:@"DOCUMENTO"]]];
                                        [comments appendFormat:@"%@\n",[documentsSent objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                        //cellHeight += kMultiLineHeight;
                                        [valuesArr addObject:amount];
                                        [valuesArr addObject:document];
                                        [valuesArr addObject:comments];
                                        [finalArr addObject:valuesArr];
                                    }
                                    
                                    
                                }
                                
                                //Boarding Information
                                if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_EMBARQUE_INFO"]])
                                {
                                    valuesArr = [[NSMutableArray alloc] init];
                                    [valuesArr addObject:legDetail];
                                    
                                    NSString *minTime = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_HORA_MINIMA"]];
                                    [valuesArr addObject:minTime];
                                    
                                    NSString *hour = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_HORA_PUERTAS"]];
                                    [valuesArr addObject:hour];
                                    
                                    [finalArr addObject:valuesArr];
                                }
                                //Arrears-Contingency
                                else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"GENERAL_ATRASOS"]])
                                {
                                    valuesArr = [[NSMutableArray alloc] init];
                                    [valuesArr addObject:legDetail];
                                    NSString *delay = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_TIEMPO"]];
                                    [valuesArr addObject:delay];
                                    
                                    NSMutableString *reasons = [[NSMutableString alloc] init];
                                    for(NSDictionary *reason in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_MOTIVO"]])
                                    {
                                        
                                        [reasons appendFormat:@"%@\n",[reason objectForKey:[apDel copyEnglishTextForKey:@"REASON"]]];
                                        
                                        
                                        
                                        cellHeight += kMultiLineHeight;
                                    }
                                    [valuesArr addObject:reasons];
                                    NSMutableString *actions = [[NSMutableString alloc] init];
                                    for(NSDictionary *action in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"GENERAL_ACCIONES"]])
                                    {
                                        
                                        
                                        
                                        
                                        [actions appendFormat:@"%@\n",[action objectForKey:[apDel copyEnglishTextForKey:@"ACTION"]]];
                                        cellHeight += kMultiLineHeight;
                                        
                                        
                                    }
                                    [valuesArr addObject:actions];
                                    [finalArr addObject:valuesArr];
                                }
                                //Baggage
                                else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"AIRPORT_BAGGAGE"]])
                                {
                                    
                                    
                                    for(NSDictionary *handLuggage in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"AIRPORT_HANDLUGGAGE"]])
                                    {
                                        valuesArr = [[NSMutableArray alloc] init];
                                        [valuesArr addObject:legDetail];
                                        
                                        NSMutableString *reasons = [[NSMutableString alloc] init];
                                        NSMutableString *amounts = [[NSMutableString alloc] init];
                                        NSMutableString *camera = [[NSMutableString alloc] init];
                                        
                                        [reasons appendFormat:@"%@\n",[handLuggage objectForKey:[apDel copyEnglishTextForKey:@"REASON"]]];
                                        [amounts appendFormat:@"%@\n",[handLuggage objectForKey:[apDel copyEnglishTextForKey:@"AMOUNT"]]];
                                        
                                        if([handLuggage objectForKey:[apDel copyEnglishTextForKey:@"CAMERA"]])
                                            [camera appendString:[apDel copyTextForKey:@"YES"]];
                                        else
                                            [camera appendString:[apDel copyTextForKey:@"NO"]];
                                        //cellHeight += kMultiLineHeight;
                                        [valuesArr addObject:reasons];
                                        [valuesArr addObject:amounts];
                                        
                                        if([[self.flightReportDict objectForKey:@"flightReportType"] containsString:@"TAM"])
                                        {
                                            NSMutableString *comments = [[NSMutableString alloc] init];
                                            
                                            [comments appendFormat:@"%@\n",[handLuggage objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                            [valuesArr addObject:comments];
                                        }
                                        
                                        [valuesArr addObject:camera];
                                        [finalArr addObject:valuesArr];
                                    }
                                }
                                //Hand Luggage
                                else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"AIRPORT_ASSIGNSEAT"]])
                                {
                                    for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys])
                                    {
                                        if([eventKey isEqualToString:eventName])
                                        {
                                            if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"AIRPORT_MALASSIGNED"]])
                                            {
                                                
                                                
                                                
                                                for(NSDictionary *reasonDict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *reasons = [[NSMutableString alloc] init];
                                                    [reasons appendFormat:@"%@\n",[reasonDict objectForKey:[apDel copyEnglishTextForKey:@"REASON"]]];
                                                    [valuesArr addObject:reasons];
                                                    [finalArr addObject:valuesArr];
                                                    
                                                    //cellHeight += kMultiLineHeight;
                                                }
                                                // [valuesArr addObject:reasons];
                                                break;
                                                
                                            }
                                            else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"AIRPORT_PROPERTYINFOSEAT"]])
                                            {
                                                
                                                
                                                for(NSDictionary *reportDict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    
                                                    [reports appendFormat:@"%@\n",[reportDict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [valuesArr addObject:reports];
                                                    [finalArr addObject:valuesArr];
                                                    //cellHeight += kMultiLineHeight;
                                                }
                                                //                                                [valuesArr addObject:reports];
                                                break;
                                            }
                                            else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"AIRPORT_DUPLICATESEAT"]])
                                            {
                                                
                                                
                                                for(NSDictionary *reportDict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    NSMutableString *fullNames = [[NSMutableString alloc] init];
                                                    [reports appendFormat:@"%@\n",[reportDict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [fullNames appendFormat:@"%@\n",[reportDict objectForKey:[apDel copyEnglishTextForKey:@"AIRPORT_FULLNAME"]]];
                                                    [valuesArr addObject:reports];
                                                    [valuesArr addObject:fullNames];
                                                    [finalArr addObject:valuesArr];
                                                    //cellHeight += kMultiLineHeight;
                                                }
                                                
                                                break;
                                            }
                                        }
                                        
                                    }
                                }
                                //State Cab Conditioning
                                else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"CAB_CONDITIONING"]])
                                {
                                    
                                    for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"CAB_STATECAB"]])
                                    {
                                        valuesArr = [[NSMutableArray alloc] init];
                                        [valuesArr addObject:legDetail];
                                        
                                        NSMutableString *reports = [[NSMutableString alloc] init];
                                        NSMutableString *comments = [[NSMutableString alloc] init];
                                        NSMutableString *camera = [[NSMutableString alloc] init];
                                        
                                        [reports appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                        [comments appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                        if([dict objectForKey:[apDel copyEnglishTextForKey:@"CAMERA"]])
                                            [camera appendString:[apDel copyTextForKey:@"YES"]];
                                        else
                                            [camera appendString:[apDel copyTextForKey:@"NO"]];
                                        
                                        //cellHeight += kMultiLineHeight;
                                        [valuesArr addObject:reports];
                                        [valuesArr addObject:comments];
                                        [valuesArr addObject:camera];
                                        [finalArr addObject:valuesArr];
                                    }
                                    
                                }
                                //Element de catering
                                else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_CATERING"]])
                                {
                                    for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys])
                                    {
                                        if([eventKey isEqualToString:eventName])
                                        {
                                            if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_LIQUIDS"]])
                                            {
                                                
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *elements = [[NSMutableString alloc] init];
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    NSMutableString *amounts = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    [elements appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"ELEMENT"]]];
                                                    [reports appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [amounts appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"AMOUNT"]]];
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    //cellHeight += kMultiLineHeight;
                                                    [valuesArr addObject:elements];
                                                    [valuesArr addObject:reports];
                                                    [valuesArr addObject:amounts];
                                                    [valuesArr addObject:observations];
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                                
                                            }
                                            else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_MEALS"]])
                                            {
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *services = [[NSMutableString alloc] init];
                                                    NSMutableString *options = [[NSMutableString alloc] init];
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    NSMutableString *amounts = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    NSMutableString *camera = [[NSMutableString alloc] init];
                                                    
                                                    [services appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"SERVICE"]]];
                                                    [options appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OPTION"]]];
                                                    [reports appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [amounts appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"AMOUNT"]]];
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    if([dict objectForKey:[apDel copyEnglishTextForKey:@"CAMERA"]])
                                                        [camera appendString:[apDel copyTextForKey:@"YES"]];
                                                    else
                                                        [camera appendString:[apDel copyTextForKey:@"NO"]];
                                                    
                                                    
                                                    //cellHeight += kMultiLineHeight;
                                                    [valuesArr addObject:services];
                                                    [valuesArr addObject:options];
                                                    [valuesArr addObject:reports];
                                                    [valuesArr addObject:amounts];
                                                    [valuesArr addObject:observations];
                                                    [valuesArr addObject:camera];
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                            }
                                        }
                                        
                                    }
                                }
                                //Element APV
                                else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_APV"]])
                                {
                                    for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys])
                                    {
                                        if([eventKey isEqualToString:eventName])
                                        {
                                            //element apv
                                            if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_MATERIAL_APV_CAT"]])
                                            {
                                                
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *elements = [[NSMutableString alloc] init];
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    NSMutableString *amounts = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    NSMutableString *camera = [[NSMutableString alloc] init];
                                                    
                                                    [elements appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"ELEMENT"]]];
                                                    [reports appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [amounts appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"AMOUNT"]]];
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    if([dict objectForKey:[apDel copyEnglishTextForKey:@"CAMERA"]])
                                                        [camera appendString:[apDel copyTextForKey:@"YES"]];
                                                    else
                                                        [camera appendString:[apDel copyTextForKey:@"NO"]];
                                                    
                                                    //cellHeight += kMultiLineHeight;
                                                    [valuesArr addObject:elements];
                                                    [valuesArr addObject:reports];
                                                    [valuesArr addObject:amounts];
                                                    [valuesArr addObject:observations];
                                                    [valuesArr addObject:camera];
                                                    
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                                
                                            }
                                            //cabin
                                            else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_CABIN"]])
                                            {
                                                
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *elements = [[NSMutableString alloc] init];
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    NSMutableString *amounts = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    NSMutableString *camera = [[NSMutableString alloc] init];
                                                    
                                                    [elements appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"ELEMENT"]]];
                                                    [reports appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [amounts appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"AMOUNT"]]];
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    if([dict objectForKey:[apDel copyEnglishTextForKey:@"CAMERA"]])
                                                        [camera appendString:[apDel copyTextForKey:@"YES"]];
                                                    else
                                                        [camera appendString:[apDel copyTextForKey:@"NO"]];
                                                    
                                                    //cellHeight += kMultiLineHeight;
                                                    [valuesArr addObject:elements];
                                                    [valuesArr addObject:reports];
                                                    [valuesArr addObject:amounts];
                                                    [valuesArr addObject:observations];
                                                    [valuesArr addObject:camera];
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                                
                                            }
                                            //security
                                            else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_SECURITY"]])
                                            {
                                                
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *elements = [[NSMutableString alloc] init];
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    NSMutableString *amounts = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    
                                                    [elements appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"ELEMENT"]]];
                                                    [reports appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [amounts appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"AMOUNT"]]];
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    //cellHeight += kMultiLineHeight;
                                                    [valuesArr addObject:elements];
                                                    [valuesArr addObject:reports];
                                                    [valuesArr addObject:amounts];
                                                    [valuesArr addObject:observations];
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                                
                                            }
                                            //bath
                                            else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_BATH"]])
                                            {
                                                
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *elements = [[NSMutableString alloc] init];
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    NSMutableString *amounts = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    NSMutableString *camera = [[NSMutableString alloc] init];
                                                    
                                                    [elements appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"ELEMENT"]]];
                                                    [reports appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [amounts appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"AMOUNT"]]];
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    if([dict objectForKey:[apDel copyEnglishTextForKey:@"CAMERA"]])
                                                        [camera appendString:[apDel copyTextForKey:@"YES"]];
                                                    else
                                                        [camera appendString:[apDel copyTextForKey:@"NO"]];
                                                    
                                                    //cellHeight += kMultiLineHeight;
                                                    
                                                    [valuesArr addObject:elements];
                                                    [valuesArr addObject:reports];
                                                    [valuesArr addObject:amounts];
                                                    [valuesArr addObject:observations];
                                                    [valuesArr addObject:camera];
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                                
                                            }
                                            //galley
                                            else if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"ELEMENT_GALLEY"]])
                                            {
                                                
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *elements = [[NSMutableString alloc] init];
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    NSMutableString *amounts = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    
                                                    [elements appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"ELEMENT"]]];
                                                    [reports appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [amounts appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"AMOUNT"]]];
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    //cellHeight += kMultiLineHeight;
                                                    
                                                    [valuesArr addObject:elements];
                                                    [valuesArr addObject:reports];
                                                    [valuesArr addObject:amounts];
                                                    [valuesArr addObject:observations];
                                                    
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                //Cabin
                                else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"IMPECCABILITY_OF_CAB"]]) {
                                    for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys]){
                                        
                                        if([eventKey isEqualToString:eventName])
                                        {
                                            if([eventKey isEqualToString:[apDel copyEnglishTextForKey:@"TOILETS"]]){
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    NSMutableString *camera = [[NSMutableString alloc] init];
                                                    
                                                    [reports appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    if([dict objectForKey:[apDel copyEnglishTextForKey:@"CAMERA"]])
                                                        [camera appendString:[apDel copyTextForKey:@"YES"]];
                                                    else
                                                        [camera appendString:[apDel copyTextForKey:@"NO"]];
                                                    
                                                    //cellHeight += kMultiLineHeight;
                                                    [valuesArr addObject:reports];
                                                    [valuesArr addObject:observations];
                                                    [valuesArr addObject:camera];
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                            }
                                            
                                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"GALLEY"]]){
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    NSMutableString *camera = [[NSMutableString alloc] init];
                                                    
                                                    [reports appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    if([dict objectForKey:[apDel copyEnglishTextForKey:@"CAMERA"]])
                                                        [camera appendString:[apDel copyTextForKey:@"YES"]];
                                                    else
                                                        [camera appendString:[apDel copyTextForKey:@"NO"]];
                                                    
                                                    //cellHeight += kMultiLineHeight;
                                                    [valuesArr addObject:reports];
                                                    [valuesArr addObject:observations];
                                                    [valuesArr addObject:camera];
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                            }
                                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"CABIN"]]){
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    
                                                    NSMutableString *reports = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    NSMutableString *camera = [[NSMutableString alloc] init];
                                                    
                                                    [reports appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    if([dict objectForKey:[apDel copyEnglishTextForKey:@"CAMERA"]])
                                                        [camera appendString:[apDel copyTextForKey:@"YES"]];
                                                    else
                                                        [camera appendString:[apDel copyTextForKey:@"NO"]];
                                                    
                                                    //cellHeight += kMultiLineHeight;
                                                    [valuesArr addObject:reports];
                                                    [valuesArr addObject:observations];
                                                    [valuesArr addObject:camera];
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                            }
                                            else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"TEMPERATURE"]])
                                            {
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *temprature = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    
                                                    [temprature appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    //cellHeight += kMultiLineHeight;
                                                    
                                                    [valuesArr addObject:temprature];
                                                    [valuesArr addObject:observations];
                                                    
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                
                                            }
                                        }
                                    }
                                }
                                //Cabin
                                else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"FAILURE_SEAT_RECOVERED_IN_FLIGHT"]]) {
                                    for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys]){
                                        
                                        if([eventKey isEqualToString:eventName])
                                        {
                                            
                                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"FAULTY_SEAT_RECOVERED_IN_FLIGHT"]]){
                                                
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *failure = [[NSMutableString alloc] init];
                                                    NSMutableString *seatRow = [[NSMutableString alloc] init];
                                                    NSMutableString *seatLetter = [[NSMutableString alloc] init];
                                                    NSMutableString *observations = [[NSMutableString alloc] init];
                                                    
                                                    [failure appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"FAILURE"]]];
                                                    [seatRow appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"SEAT_ROW"]]];
                                                    [seatLetter appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"SEAT_LETTER"]]];
                                                    
                                                    
                                                    [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    //cellHeight += kMultiLineHeight;
                                                    
                                                    [valuesArr addObject:failure];
                                                    [valuesArr addObject:seatRow];
                                                    [valuesArr addObject:seatLetter];
                                                    
                                                    [valuesArr addObject:observations];
                                                    
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                                
                                            }
                                        }
                                    }
                                }
                                //Quality catering service
                                else if([[groupDict objectForKey:@"name"] isEqualToString:[apDel copyEnglishTextForKey:@"QUALITY_CATERING_SERVICE"]])
                                {
                                    for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys]){
                                        
                                        if([eventKey isEqualToString:eventName])
                                        {
                                            
                                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"QUALITY_OF_SERVICE"]]){
                                                
                                                
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *service = [[NSMutableString alloc] init];
                                                    NSMutableString *option = [[NSMutableString alloc] init];
                                                    NSMutableString *report = [[NSMutableString alloc] init];
                                                    NSMutableString *amount = [[NSMutableString alloc] init];
                                                    NSMutableString *observation = [[NSMutableString alloc] init];
                                                    NSMutableString *camera = [[NSMutableString alloc] init];
                                                    
                                                    [service appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"SERVICE"]]];
                                                    [option appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OPTION"]]];
                                                    [report appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"REPORT"]]];
                                                    [amount appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"AMOUNT"]]];
                                                    [observation appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                    if([dict objectForKey:[apDel copyEnglishTextForKey:@"CAMERA"]])
                                                        [camera appendString:[apDel copyTextForKey:@"YES"]];
                                                    else
                                                        [camera appendString:[apDel copyTextForKey:@"NO"]];
                                                    
                                                    //cellHeight += kMultiLineHeight;
                                                    
                                                    [valuesArr addObject:service];
                                                    [valuesArr addObject:option];
                                                    [valuesArr addObject:report];
                                                    [valuesArr addObject:amount];
                                                    [valuesArr addObject:observation];
                                                    [valuesArr addObject:camera];
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                break;
                                            }
                                        }
                                    }
                                }
                                //IFE
                                else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURES"]]){
                                    
                                    for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys]){
                                        
                                        if([eventKey isEqualToString:eventName])
                                        {
                                            
                                            if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"INDIVIDUAL_FAILURE _IFE"]]){
                                                
                                                
                                                //                                                NSMutableString *observations = [[NSMutableString alloc] init];
                                                for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                {
                                                    valuesArr = [[NSMutableArray alloc] init];
                                                    [valuesArr addObject:legDetail];
                                                    
                                                    NSMutableString *reason = [[NSMutableString alloc] init];
                                                    NSMutableString *seatRow = [[NSMutableString alloc] init];
                                                    NSMutableString *seatLetter = [[NSMutableString alloc] init];
                                                    
                                                    [reason appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"SELECT_REASON"]]];
                                                    [seatRow appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"SEAT_ROW"]]];
                                                    [seatLetter appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"SEAT_LETTER"]]];
                                                    
                                                    
                                                    //cellHeight += kMultiLineHeight;
                                                    
                                                    [valuesArr addObject:reason];
                                                    [valuesArr addObject:seatRow];
                                                    [valuesArr addObject:seatLetter];
                                                    
                                                    [finalArr addObject:valuesArr];
                                                }
                                                
                                                
                                                break;
                                                
                                            }
                                        }
                                    }
                                }
                                else if([groupName isEqualToString:[apDel copyEnglishTextForKey:@"MASSIVE_FAILURES"]]) {
                                    
                                    if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]])
                                    {
                                        valuesArr = [[NSMutableArray alloc] init];
                                        [valuesArr addObject:legDetail];
                                        
                                        NSString *massiveFailure = [[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"THERE_WERE_MASSIVE_FAILURES_IFE?"]];
                                        [valuesArr addObject:[apDel copyTextForKey:massiveFailure]];
                                        [finalArr addObject:valuesArr];
                                        
                                    }
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"]]){
                                        
                                        for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys]){
                                            
                                            if([eventKey isEqualToString:eventName])
                                            {
                                                if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"INITIAL_STATE_OF_THE_SYSTEM"]]){
                                                    
                                                    
                                                    for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                    {
                                                        valuesArr = [[NSMutableArray alloc] init];
                                                        [valuesArr addObject:legDetail];
                                                        
                                                        NSMutableString *selectState = [[NSMutableString alloc] init];
                                                        
                                                        NSMutableString *observations = [[NSMutableString alloc] init];
                                                        
                                                        [selectState appendFormat:@"%@\n",[dict objectForKey: [apDel copyEnglishTextForKey:@"SELECT_STATE"]]];
                                                        [observations appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                        
                                                        //cellHeight += kMultiLineHeight;
                                                        
                                                        [valuesArr addObject:selectState];
                                                        [valuesArr addObject:observations];
                                                        
                                                        [finalArr addObject:valuesArr];
                                                    }
                                                    
                                                    
                                                    break;
                                                    
                                                }
                                            }
                                        }
                                    }
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"]] ){
                                        if([[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"]]){
                                            
                                            for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys]){
                                                
                                                if([eventKey isEqualToString:eventName])
                                                {
                                                    if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"DESCRIPTION_OF_FAILURE"]]){
                                                        
                                                        
                                                        
                                                        for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                        {
                                                            valuesArr = [[NSMutableArray alloc] init];
                                                            [valuesArr addObject:legDetail];
                                                            
                                                            NSMutableString *timeOfflight = [[NSMutableString alloc] init];
                                                            
                                                            NSMutableString *faultySeats = [[NSMutableString alloc] init];
                                                            
                                                            NSMutableString *duration = [[NSMutableString alloc] init];
                                                            
                                                            NSMutableString *seating = [[NSMutableString alloc] init];
                                                            
                                                            [timeOfflight appendFormat:@"%@\n",[dict objectForKey: [apDel copyEnglishTextForKey:@"TIME_OF_FLIGHT"]]];
                                                            [faultySeats appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"FAULT_TYPE"]]];
                                                            [duration appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"DURATION_OF_FAILURE"]]];
                                                            [seating appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"SEATING"]]];
                                                            
                                                            //cellHeight += kMultiLineHeight;
                                                            
                                                            [valuesArr addObject:timeOfflight];
                                                            [valuesArr addObject:faultySeats];
                                                            [valuesArr addObject:duration];
                                                            [valuesArr addObject:seating];
                                                            
                                                            [finalArr addObject:valuesArr];
                                                        }
                                                        
                                                        break;
                                                        
                                                    }
                                                }
                                            }
                                        }else {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"TIME_OF_FLIGHT"]]];
                                            
                                            [valuesArr addObject:[[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"FAULT_TYPE"]]];
                                            
                                            [valuesArr addObject:[[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"DURATION_OF_FAILURE"]]];
                                            
                                            [valuesArr addObject:[[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"SEATING"]]];
                                            
                                            [finalArr addObject:valuesArr];
                                        }
                                        
                                        
                                    }
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"CORRECTIVE_ACTION"]]){
                                        if([[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"CORRECTIVE_ACTION"]]){
                                            
                                            for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys]){
                                                
                                                if([eventKey isEqualToString:eventName])
                                                {
                                                    if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"CORRECTIVE_ACTION"]]){
                                                        
                                                        
                                                        
                                                        for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                        {
                                                            valuesArr = [[NSMutableArray alloc] init];
                                                            [valuesArr addObject:legDetail];
                                                            
                                                            NSMutableString *timeOfflight = [[NSMutableString alloc] init];
                                                            
                                                            NSMutableString *faultySeats = [[NSMutableString alloc] init];
                                                            
                                                            
                                                            
                                                            [timeOfflight appendFormat:@"%@\n",[dict objectForKey: [apDel copyEnglishTextForKey:@"AREA_RESET"]]];
                                                            [faultySeats appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"NUMBER_OF_RESETS"]]];
                                                            
                                                            //cellHeight += kMultiLineHeight;
                                                            [valuesArr addObject:timeOfflight];
                                                            [valuesArr addObject:faultySeats];
                                                            [finalArr addObject:valuesArr];
                                                        }
                                                        
                                                        
                                                        break;
                                                        
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"AREA_RESET"]]];
                                            
                                            [valuesArr addObject:[[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"NUMBER_OF_RESETS"]]];
                                            
                                            [finalArr addObject:valuesArr];
                                        }
                                    }
                                    else if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"]]){
                                        
                                        if([[groupDict objectForKey:@"multiEvents"] objectForKey:[apDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"]]){
                                            
                                            for(NSString *eventKey in [[groupDict objectForKey:@"multiEvents"] allKeys]){
                                                
                                                if([eventKey isEqualToString:eventName])
                                                {
                                                    if([eventName isEqualToString:[apDel copyEnglishTextForKey:@"FINAL_SYSTEM_STATUS"]]){
                                                        
                                                        
                                                        
                                                        for(NSDictionary *dict in [[groupDict objectForKey:@"multiEvents"] objectForKey:eventKey])
                                                        {
                                                            valuesArr = [[NSMutableArray alloc] init];
                                                            [valuesArr addObject:legDetail];
                                                            
                                                            NSMutableString *timeOfflight = [[NSMutableString alloc] init];
                                                            
                                                            NSMutableString *faultySeats = [[NSMutableString alloc] init];
                                                            
                                                            
                                                            
                                                            [timeOfflight appendFormat:@"%@\n",[dict objectForKey: [apDel copyEnglishTextForKey:@"SELECT_STATE"]]];
                                                            [faultySeats appendFormat:@"%@\n",[dict objectForKey:[apDel copyEnglishTextForKey:@"OBSERVATION"]]];
                                                            
                                                            //cellHeight += kMultiLineHeight;
                                                            
                                                            [valuesArr addObject:timeOfflight];
                                                            [valuesArr addObject:faultySeats];
                                                            
                                                            [finalArr addObject:valuesArr];
                                                        }
                                                        
                                                        
                                                        break;
                                                        
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            valuesArr = [[NSMutableArray alloc] init];
                                            [valuesArr addObject:legDetail];
                                            
                                            [valuesArr addObject:[[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"SELECT_STATE"]]];
                                            
                                            [valuesArr addObject:[[groupDict objectForKey:@"singleEvents"]objectForKey:[apDel copyEnglishTextForKey:@"SELECT_STATE"]]];
                                            
                                            [finalArr addObject:valuesArr];
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            
        }
        if(cellHeight <= kMultiLineHeight) {
            cellHeight = kCellHeight;
        }
        
        [self generateCellWithKeyValuesArr:finalArr andWidthArr:widthsArr andHeight:cellHeight];
        [contentView setFrame:CGRectMake(kXOffset, initialYoffset, kCellWidth, contentviewYoffset)];
        [self.summaryScrollView addSubview:contentView];
        
        [finalArr removeAllObjects];
    }
    yoffset += kCellHeight - 20;
}

-(void)createGeneralInformation {
    contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor clearColor]];
    contentView.layer.cornerRadius = 10.0;
    contentView.layer.borderWidth = 1.0;
    contentView.clipsToBounds = YES;
    contentView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
    
    CGFloat initialYoffset = yoffset;
    contentviewYoffset = kCellHeight;
    
    [self createGroupHeaderWithTitle:[apDel copyTextForKey:@"LEGINFORMATION"]];
    
    [self generateHeaderWithKeyValuesArr:[NSArray arrayWithObjects:[apDel copyTextForKey:@"LEG_TEXT"],[apDel copyTextForKey:@"GENERAL_TRAMO_EJECUTADO"],[apDel copyTextForKey:@"GENERAL_CAPITAN"],[apDel copyTextForKey:@"GENERAL_MATERIAL"],[apDel copyTextForKey:@"GENERAL_ENROLLMENT"], nil] andWidthArr:[NSArray arrayWithObjects:kLegKeyWidth,@"180.0",@"180.0",@"180.0",@"180.0", nil] andHeight:kHeaderHeight];
    
    NSMutableArray *valuesArr;// = [[NSMutableArray alloc] init];
    
    self.flightNumLbl.text = [[[self.flightReportDict objectForKey:@"flightKey"] objectForKey:@"airlineCode"] stringByAppendingString:[[self.flightReportDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"]];
    
    self.flightDayLbl.text = [[self.flightReportDict objectForKey:@"sortTime"]dateFormat:DATE_FORMAT_dd];
    self.flightMonthLbl.text = [[[self.flightReportDict objectForKey:@"flightKey"] objectForKey:@"flightDate"] dateFormat:DATE_FORMAT_MMMM_yyyy];
    NSMutableArray *finalArr = [[NSMutableArray alloc] init];
    for(NSDictionary *legDict in [self.flightReportDict objectForKey:@"legs"])
    {
        NSString *legDetail = [NSString stringWithFormat:@"%@ - %@",[legDict objectForKey:@"origin"],[legDict objectForKey:@"destination"]];
        valuesArr = [[NSMutableArray alloc] init];
        [valuesArr addObject:legDetail];
        for(NSDictionary *reportDict in [legDict objectForKey:@"reports"])
        {
            if([[reportDict objectForKey:@"name"] isEqualToString:@"GENERAL"])
            {
                for(NSDictionary *sectionDict in [reportDict objectForKey:@"sections"])
                {
                    BOOL legExecuted = YES;
                    if([[[[[sectionDict objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"singleEvents"] objectForKey:@"Leg Executed"] isEqualToString:@"NO"])
                    {
                        legExecuted = NO;
                    }
                    for(NSDictionary *groupDict in [sectionDict objectForKey:@"groups"])
                    {
                        
                        
                        if([[groupDict objectForKey:@"name"] isEqualToString:@"Captain"])
                        {
                            
                            
                            NSString *captain = [NSString stringWithFormat:@"%@ %@",[[groupDict objectForKey:@"singleEvents"]objectForKey:@"Surname"],[[groupDict objectForKey:@"singleEvents"]objectForKey:@"Name"]];
                            if(legExecuted == NO)
                                [valuesArr addObject:@"-"];
                            else
                                [valuesArr addObject:captain];
                            
                            
                        }
                        if([[groupDict objectForKey:@"name"] isEqualToString:@"Flight Details"])
                        {
                            
                            self.baseLbl.text = [[groupDict objectForKey:@"singleEvents"]objectForKey:@"Crew Base"];
                            if(legExecuted == NO)
                            {
                                
                                [valuesArr addObject:@"-"];
                                [valuesArr addObject:@"-"];
                            }
                            else
                            {
                                
                                
                                NSString *material = [[groupDict objectForKey:@"singleEvents"]objectForKey:@"Material"];
                                [valuesArr addObject:material];
                                NSString *tail = [[groupDict objectForKey:@"singleEvents"]objectForKey:@"Enrollment"];
                                [valuesArr addObject:tail];
                            }
                        }
                        if([[groupDict objectForKey:@"name"] isEqualToString:@"Head of Service on Board"])
                        {
                            
                            self.jsbHead.text = [NSString stringWithFormat:@"%@ %@",[[groupDict objectForKey:@"singleEvents"]objectForKey:@"Surname"],[[groupDict objectForKey:@"singleEvents"]objectForKey:@"Name"]];
                            self.bpLbl.text = [[groupDict objectForKey:@"singleEvents"]objectForKey:@"BP"];
                            
                            
                            
                        }
                        if([[groupDict objectForKey:@"name"]isEqualToString:@"Leg Executed"])
                        {
                            NSString *legExecuted = [[groupDict objectForKey:@"singleEvents"]objectForKey:@"Leg Executed"];
                            [valuesArr addObject:[apDel copyTextForKey:legExecuted]];
                        }
                    }
                }
            }
        }
        
        [finalArr addObject:valuesArr];
        
        [self generateCellWithKeyValuesArr:finalArr andWidthArr:[NSArray arrayWithObjects:kLegKeyWidth,@"180.0",@"180.0",@"180.0",@"180.0", nil] andHeight:kCellHeight];
        [contentView setFrame:CGRectMake(kXOffset, initialYoffset,kCellWidth ,yoffset - initialYoffset )];
        
        [finalArr removeAllObjects];
    }
    
    [self.summaryScrollView addSubview:contentView];
    
}




- (UIView *)generateReportofType:(NSString *)reportType
{
    UIView *reportView = [[UIView alloc] initWithFrame:CGRectMake(kXOffset, yoffset, kCellWidth , 500)];
    [reportView setBackgroundColor:[UIColor greenColor]];
    
    
    UILabel *reportLbl = [[UILabel alloc] initWithFrame:CGRectMake(reportView.center.x - 200, yoffset + 10, 200, 40)];
    reportLbl.textAlignment = NSTextAlignmentCenter;
    reportLbl.text = reportType;
    reportLbl.backgroundColor = [UIColor clearColor];
    [reportView addSubview:reportLbl];
    
    return reportView;
    
}

-(void)generateHeaderWithKeyValuesArr:(NSArray *)keysArray andWidthArr:(NSArray *)widthsArray andHeight:(CGFloat)height {
    
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, contentviewYoffset, kCellWidth, height)];
    [headerview setBackgroundColor:[UIColor clearColor]];
    int i = 0;
    CGFloat xOffset = kXOffset;
    for(NSString *key in keysArray) {
        
        UILabel *keyLbl = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 3, [[widthsArray objectAtIndex:i] floatValue], height)];
        keyLbl.textAlignment = NSTextAlignmentLeft;
        keyLbl.text = [key uppercaseString];
        keyLbl.textColor = [UIColor colorWithRed:99.0/255.0 green:153.0/255.0 blue:184.0/255.0 alpha:1];
        keyLbl.numberOfLines = 0;
        keyLbl.font = [UIFont boldSystemFontOfSize:13.0];
        keyLbl.backgroundColor = [UIColor clearColor];
        [headerview addSubview:keyLbl];
        xOffset += [[widthsArray objectAtIndex:i] floatValue];
        i++;
        
    }
    yoffset += height;
    contentviewYoffset += height;
    [contentView addSubview:headerview];
}

-(void)generateCellWithKeyValuesArr:(NSArray *)keysArray andWidthArr:(NSArray *)widthsArray andHeight:(CGFloat)height {
    for(NSArray *keyArr in keysArray) {
        UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, contentviewYoffset, kCellWidth, height)];
        [headerview setBackgroundColor:[UIColor clearColor]];
        int i = 0;
        CGFloat xOffset = kXOffset;
        
        
        CGFloat lblHeight = height;
        for(NSString *key in keyArr) {
            
            UILabel *keyLbl = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 6, [[widthsArray objectAtIndex:i] floatValue], height)];
            keyLbl.textAlignment = NSTextAlignmentLeft;
            if([key isEqualToString:@"(null)\n"])
                keyLbl.text = @"";
            else
                keyLbl.text = key;
            keyLbl.font = [UIFont systemFontOfSize:13.0];
            keyLbl.textColor = [UIColor blackColor];
            keyLbl.numberOfLines = 0;
            keyLbl.backgroundColor = [UIColor clearColor];
            [keyLbl sizeToFit];
            [headerview addSubview:keyLbl];
            
            if(lblHeight < keyLbl.frame.size.height)
                lblHeight = keyLbl.frame.size.height;
            xOffset += [[widthsArray objectAtIndex:i] floatValue];
            i++;
        }
        
        if(lblHeight > height) {
            height = lblHeight + 10;
        }
        
        UILabel *lineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, height-1, kCellWidth, 1)];
        [lineLbl setBackgroundColor:[UIColor lightGrayColor]];
        lineLbl.alpha = 0.3;
        [headerview addSubview:lineLbl];
        
        yoffset += height;
        contentviewYoffset += height;
        [contentView addSubview:headerview];
    }
}

-(void)createGroupHeaderWithTitle:(NSString *)title
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCellWidth, kCellHeight)];
    [headerView setBackgroundColor:[UIColor colorWithRed:10.0/255.0 green:92.0/255.0 blue:124.0/255.0 alpha:1]];
    UILabel *headerLbl = [[UILabel alloc] initWithFrame:CGRectMake(kXOffset, 0, kCellWidth, kCellHeight)];
    headerLbl.textAlignment = NSTextAlignmentLeft;
    headerLbl.text = [title uppercaseString];
    headerLbl.textColor = [UIColor whiteColor];
    headerLbl.font = [UIFont systemFontOfSize:12.0];
    headerLbl.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerLbl];
    yoffset += kCellHeight;
    [contentView addSubview:headerView];
}

-(void)createSectionHeaderWithTitle:(NSString *)title
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(kXOffset, yoffset, kCellWidth, kCellHeight)];
    
    UILabel *headerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kCellWidth, kCellHeight)];
    headerLbl.textAlignment = NSTextAlignmentLeft;
    headerLbl.text = title;
    headerLbl.textColor = [UIColor blackColor];
    headerLbl.backgroundColor = [UIColor clearColor];
    headerLbl.font = [UIFont systemFontOfSize:18.0];
    [headerView addSubview:headerLbl];
    yoffset += kCellHeight;
    [self.summaryScrollView addSubview:headerView];
}


-(void)createReportHeaderWithTitle:(NSString *)title
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(kXOffset, yoffset, kCellWidth, kCellHeight)];
    UILabel *headerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kCellWidth, kCellHeight)];
    headerLbl.textAlignment = NSTextAlignmentCenter;
    
    //headerLbl.text = [[title capitalizedString] stringByAppendingString:@" Report"];
    headerLbl.text = [apDel copyTextForKey:[NSString stringWithFormat:@"%@_REPORT",title]];
    headerLbl.backgroundColor = [UIColor clearColor];
    headerLbl.textColor = [UIColor colorWithRed:10.0/255.0 green:92.0/255.0 blue:124.0/255.0 alpha:1];
    headerLbl.font = [UIFont boldSystemFontOfSize:20.0];
    [headerView addSubview:headerLbl];
    yoffset += kCellHeight;
    [self.summaryScrollView addSubview:headerView];
}

-(void)noReportsMadeMessage
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(kXOffset, yoffset, kCellWidth, kCellHeight)];
    UILabel *headerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kCellWidth, kCellHeight)];
    headerLbl.textAlignment = NSTextAlignmentCenter;
    headerLbl.text = [apDel copyTextForKey:@"NO_REPORTS"];
    headerLbl.backgroundColor = [UIColor clearColor];
    headerLbl.textColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1];
    headerLbl.font = [UIFont boldSystemFontOfSize:11.0];
    [headerView addSubview:headerLbl];
    yoffset += kCellHeight;
    [self.summaryScrollView addSubview:headerView];
}

- (NSArray *) reorderArray:(NSArray *)sourceArray toArray:(NSArray *)referenceArray
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [referenceArray count]; i++)
    {
        if ([sourceArray containsObject:[referenceArray objectAtIndex:i]])
        {
            [returnArray addObject:[referenceArray objectAtIndex:i]];
        }
    }
    return [returnArray copy];
}

- (BOOL)shouldAutorotate
{
    return YES;
}
@end


