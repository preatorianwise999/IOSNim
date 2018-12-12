//
//  GADViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/22/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "GADViewController.h"
#import "LTSingleton.h"
#import "LTSaveFlightData.h"
#import "GADController.h"
#import "UserInformationParser.h"



@interface GADViewController () {
    NSString *materialType;
    LanguageSelected language;
    NSDictionary *contentDict;
    NSArray *GADtextArray;
    NSMutableDictionary *selectedValue;
    NSArray *sectionArray;
    UIImage *signatureImage;
    UIImage *signatureImageTC;
    NSMutableDictionary *gadFormDictionary;
    NSMutableArray * keysArray;
    NSMutableArray *gadReportArray;
    SynchronizationController * synch;
    NSArray * headingArray;
    NSMutableDictionary * btnTagValueDict;
    NSArray * catKeyArray;
    int answeredCount;
    NSString *typeFly;
    Boolean stado;

    
    // NSMutableArray * legArray;
    
}

@property (nonatomic) BOOL keyboardIsVisible;

@property (nonatomic) BOOL modifiedReport;

@property (weak, nonatomic) IBOutlet UILabel *formTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gadCenterConstraintY;

@end

@implementation GADViewController

-(NSDictionary *)getDictionayofType:(NSString *)type selectedLang:(LanguageSelected)lang {
    NSString *filePath;
    NSDictionary *fDict = [LTSingleton getSharedSingletonInstance].flightKeyDict;
    NSDictionary *fKey = fDict[@"flightKey"];
    NSString *airlineCode = fKey[@"airlineCode"];
    typeFly = fKey[@"airlineCode"];
    
    if(([airlineCode isEqualToString:@"JJ"] || [airlineCode isEqualToString:@"PZ"]) && [type isEqualToString:@"WB"] && lang == LANG_SPANISH)
    {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADTCTAMWBSpanish" ofType:@"geojson"];
    }
    else if(([airlineCode isEqualToString:@"JJ"] || [airlineCode isEqualToString:@"PZ"]) && [type isEqualToString:@"WB"] && lang == LANG_PORTUGUESE)
    {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADTCTAMWBPortuguese" ofType:@"geojson"];
    }
     
    else
    if ([type isEqualToString:@"NB"] && lang == LANG_SPANISH) {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADLANNBSpanish" ofType:@"geojson"];
    }
    else   if ([type isEqualToString:@"WB"] && lang == LANG_SPANISH) {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADLANWBSpanish" ofType:@"geojson"];
    }
    else   if ([type isEqualToString:@"NB"] && lang == LANG_PORTUGUESE) {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADTAMNBPortuguese" ofType:@"geojson"];
    }
    else   if ([type isEqualToString:@"WB"] && lang == LANG_PORTUGUESE) {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADTAMWBPortuguese" ofType:@"geojson"];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dict = [DictionaryParser dictionaryFromData:data];
    
    //NSLog(@"dict %@",dict);
    return dict;
}

-(void)setUp {
    
    self.modifiedReport = NO;
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    language = appDel.currentLanguage;
    NSDictionary *fKey = [LTSingleton getSharedSingletonInstance].flightKeyDict;
    materialType = [UserInformationParser getMaterialType:fKey[@"material"]];
    
    NSDictionary *dict=[[NSDictionary alloc] init];
    if ( [materialType isEqualToString:@"NB"] && language == LANG_SPANISH) {
        sectionArray = [[NSArray alloc] initWithObjects:@"  GAD TC NARROW BODY",@"  Comentarios del Observador",@"  Comentarios de TC",@"", nil];
        dict = [self getDictionayofType:@"NB" selectedLang:language];
    }
    else if ([materialType isEqualToString:@"WB"] && language == LANG_SPANISH) {
        sectionArray = [[NSArray alloc] initWithObjects:@"  GAD TC WIDE BODY",@"  Comentarios del Observador",@"  Comentarios de TC",@"", nil];
        dict = [self getDictionayofType:@"WB" selectedLang:language];
    }
    else if ([materialType isEqualToString:@"NB"] && language == LANG_PORTUGUESE) {
        sectionArray = [[NSArray alloc] initWithObjects:@"  GAD TC NARROW BODY",@"  Comentários do Observador",@"Comentários do Comissário",@"", nil];
        dict = [self getDictionayofType:@"NB" selectedLang:language];
        
    }
    else if ([materialType isEqualToString:@"WB"] && language == LANG_PORTUGUESE) {
        sectionArray = [[NSArray alloc] initWithObjects:@"  GAD TC WIDE BODY",@" Comentários do Observador",@" Comentários do Comissário",@"", nil];
        dict = [self getDictionayofType:@"WB" selectedLang:language];
    }
    
    GADtextArray = [dict objectForKey:@"Value"];
    keysArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [GADtextArray count]; i++) {
        NSString * key = [[[GADtextArray objectAtIndex:i] allKeys] objectAtIndex:0];
        [keysArray addObject:key];
    }
    
    catKeyArray = [NSArray arrayWithArray:keysArray];
    [keysArray addObject:[sectionArray objectAtIndex:1]];
    [keysArray addObject:[sectionArray objectAtIndex:2]];
    

    synch = [[SynchronizationController alloc]init];
    
    btnTagValueDict = [[NSMutableDictionary alloc]init];
    
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
}

//returns whether it is double cell or single cell

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self setUp];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.GADview.layer setCornerRadius:20.0f];
    selectedValue = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellButtonSelected:) name:@"GADValueSelection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keboardDissmissed:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    self.formTitle.text = [appDel copyTextForKey:@"GAD_FORM_TITLE"];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

-(void)orientationChanged:(NSNotification *)notification {
    [self performSelector:@selector(updateFrames) withObject:nil afterDelay:0.1];
}

- (void)updateFrames {
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        
        if(self.keyboardIsVisible) {
            self.gadCenterConstraintY.constant = 70;
        }
        else {
            self.gadCenterConstraintY.constant = 0;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    NSMutableDictionary * flightDict;
    flightDict = [LTSingleton getSharedSingletonInstance].flightKeyDict;
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setValue:self.bpIDforCrew forKey:@"bp"];
    [dic setValue:[NSNumber numberWithInt:_indexForLeg]forKey:@"legIndex"];
    
    gadFormDictionary = [synch getGADforCrew:dic forFlight:flightDict];
    headingArray = [gadFormDictionary allKeys];
    NSNumber *status =[[gadFormDictionary valueForKey:@"crewMember"] valueForKey:@"status"] ;
    
    for(int i = 0; i < GADtextArray.count; i++) {
        
        NSDictionary *gadEntryDict = GADtextArray[i];
        NSString *heading = [[gadEntryDict allKeys] objectAtIndex:0];
        NSString *text = [gadEntryDict[heading] objectAtIndex:0];
        for (NSString * headingText in headingArray) {
            
            if ([headingText isEqualToString:@"ObserverComment"]) {
                [selectedValue setObject: [gadFormDictionary valueForKey:@"ObserverComment"] forKey:@"ObserverComment"];
            }
            else if ([headingText isEqualToString:@"TCComment"]) {
                [selectedValue setObject: [gadFormDictionary valueForKey:@"TCComment"] forKey:@"TCComment"];
            }
            else if ([headingText isEqualToString:@"Signatur_Observer"]) {
                [selectedValue setObject: [gadFormDictionary valueForKey:@"Signatur_Observer"] forKey:@"Signatur_Observer"];
            }
            else if ([headingText isEqualToString:@"Signature_TC"]) {
                [selectedValue setObject: [gadFormDictionary valueForKey:@"Signature_TC"] forKey:@"Signature_TC"];
            }
            if ([heading isEqualToString:headingText]) {
                
                if (i == 5 || [materialType isEqualToString:@"WB"]) {
                    // double
                    NSArray *valueArray = [[gadFormDictionary objectForKey:heading] allValues];
                    
                    if(([typeFly isEqualToString:@"JJ"] || [typeFly isEqualToString:@"PZ"]) && [materialType isEqualToString:@"WB"]){
                    
                        int v1 = 0;
                        int v2 = 0;
                        int v3 = 0;
                        int v4 = 0;
                        int v5 = 0;
                        
                        if(valueArray.count == 1) {
                         v1 = [valueArray[0] intValue];
                        }
                        if(valueArray.count == 2) {
                         v1 = [valueArray[0] intValue];
                         v2 = [valueArray[1] intValue];
                        }
                        if(valueArray.count == 3) {
                         v1 = [valueArray[0] intValue];
                         v2 = [valueArray[1] intValue];
                         v3 = [valueArray[2] intValue];
                        }
                        if(valueArray.count == 4) {
                         v1 = [valueArray[0] intValue];
                         v2 = [valueArray[1] intValue];
                         v3 = [valueArray[2] intValue];
                         v4 = [valueArray[3] intValue];
                        }
                        
                        if(valueArray.count == 5) {
                            v1 = [valueArray[0] intValue];
                            v2 = [valueArray[1] intValue];
                            v3 = [valueArray[2] intValue];
                            v4 = [valueArray[3] intValue];
                            v5 = [valueArray[4] intValue];
                            valueArray = @[@(v5), @(v4), @(v3), @(v2), @(v1)];

                        }else
                        {
                        valueArray = @[@(v4), @(v3), @(v2), @(v1)];
                        
                        }
                    }else{
                       
                        int v1 = [valueArray[0] intValue];
                        int v2 = 0;
                        if(valueArray.count == 2) {
                            v2 = [valueArray[1] intValue];
                        }
                    
                        if ((v2 >= 101 && v2 <= 106) || (v1 >= 201 && v2 <= 206)) {
                            valueArray = @[@(v2), @(v1)];
                        }
                    }
                    [selectedValue setValue:valueArray forKey:heading];
                }
                else {
                    // single
                    NSDictionary *valueDictionary= [gadFormDictionary valueForKey:heading];
                    NSString *value = [valueDictionary valueForKey:text];
                    [selectedValue setValue:value forKey:heading];
                }
            }
        }
    }
    
    if (status.intValue == draft || status.intValue == eror || status.intValue == 0) {
        self.isForStatus = NO;
        self.isForReport = NO;
    } else {
        self.isForStatus = YES;
        self.isForReport = YES;
    }
    [self updateFrames];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cellButtonSelected:(NSNotification*)notification {
    
    self.modifiedReport = YES;
    
    NSDictionary *dic = notification.userInfo;
    [selectedValue addEntriesFromDictionary:dic];
    NSLog(@"selected dict=%@",selectedValue);
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [GADtextArray count] + 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSDictionary *dict;
    NSString *heading;
    if (row < [GADtextArray count]) {
        dict = [GADtextArray objectAtIndex:row];
        heading  = [[(NSDictionary*)[GADtextArray objectAtIndex:row] allKeys] objectAtIndex:0];
    }
    NSArray *arr = [dict objectForKey:heading];
    NSInteger rowType = [arr count] ;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(([typeFly isEqualToString:@"JJ"] || [typeFly isEqualToString:@"PZ"]) && [materialType isEqualToString:@"WB"]){
    
        if (rowType == 4) {
            if (orientation == UIInterfaceOrientationLandscapeLeft ||
                  orientation == UIInterfaceOrientationLandscapeRight) {
                return 280.0f;
            }else{
                return 360.0f;
                
            }
        } else if (rowType == 5) {
            if(orientation == UIInterfaceOrientationLandscapeLeft ||
               orientation == UIInterfaceOrientationLandscapeRight) {
                return 360.0f;                
            }else{
                return 470.0f;

                
            }
        } else if(row == [GADtextArray count] || row == [GADtextArray count]+1) {
            return 150.0f;
        } else {
            return 200.0f;
        }


    }else{
        if (rowType == 1) {
            return 100.0f;
        } else if (rowType == 2) {
            return 162.0f;
        
        } else if(row == [GADtextArray count] || row == [GADtextArray count]+1) {
            return 150.0f;
        } else {
            return 200.0f;
        }

    }
 //   if (rowType == 3) {
        
 //       if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
 //      {
            // if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))

 //           return 350.0f;
 //       }else{
 //           return 250.0f;
 //       }

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isForReport || self.isForStatus || [[[LTSingleton getSharedSingletonInstance].flightRoasterDict objectForKey:@"isFlownAsJSB"] boolValue] == NO){
        cell.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        _sendBtn . hidden = YES;
        _trashBtn.hidden = YES;
        
    }
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSDictionary *dict;
    NSString *heading;
    if (row < [GADtextArray count]) {
        dict = [GADtextArray objectAtIndex:row];
        heading  = [[(NSDictionary*)[GADtextArray objectAtIndex:row] allKeys] objectAtIndex:0];
    }
    
    NSArray *arr = [dict objectForKey:heading];
    NSInteger rowType = [arr count] ;
    if (rowType == 1) {
        
        if(([typeFly isEqualToString:@"JJ"] || [typeFly isEqualToString:@"PZ"]) && [materialType isEqualToString:@"WB"]){
           
            GADSingleTableViewCellTam *cell = nil;
            cell.headingLabel = nil;
            cell.detailsLabel = nil;
            if (cell == nil) {
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GADSingleTableViewCellTam" owner:self options:nil];
                
                // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
                
                cell = [topLevelObjects objectAtIndex:0];
                cell.headingLabel.text=heading;
                NSString *text = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:0];
                NSString *textToShow = [[text componentsSeparatedByString:@"||"] objectAtIndex:0];
                cell.detailsLabel.text=textToShow;
                cell.backgroundColor = [UIColor clearColor];
                cell.contentView.backgroundColor = [UIColor clearColor];
                
                if ([selectedValue objectForKey:heading] != nil) {
                    NSInteger val = [[selectedValue objectForKey:heading] integerValue];
                    [cell selectButtonWithTag:val];
                }
            }
            return cell;
            
        }else{
        GADSingleTableViewCell *cell = nil;
        cell.headingLabel = nil;
        cell.detailsLabel = nil;
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GADSingleTableViewCell" owner:self options:nil];
            
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            
            cell = [topLevelObjects objectAtIndex:0];
            cell.headingLabel.text=heading;
            NSString *text = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:0];
            NSString *textToShow = [[text componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel.text=textToShow;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            
            if ([selectedValue objectForKey:heading] != nil) {
                NSInteger val = [[selectedValue objectForKey:heading] integerValue];
                [cell selectButtonWithTag:val];
            }
        }
        return cell;
      }
    } else if(rowType == 2) {
        
        if(([typeFly isEqualToString:@"JJ"] || [typeFly isEqualToString:@"PZ"]) && [materialType isEqualToString:@"WB"]){
        
            GADDobleViewCellTam *cell = nil;
            cell.headingLabel = nil;
            cell.detailsLabel1 = nil;
            cell.detailsLabel2 = nil;
            if (cell == nil) {
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GADDobleViewCellTam" owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
                
                cell.headingLabel.text=heading;
                NSString *text1 =[[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:0];
                NSString *textToShow1 = [[text1 componentsSeparatedByString:@"||"] objectAtIndex:0];
                cell.detailsLabel1.text=textToShow1;
                NSString *text2 = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:1];
                NSString *textToShow2 = [[text2 componentsSeparatedByString:@"||"] objectAtIndex:0];
                cell.detailsLabel2.text=textToShow2;
                cell.backgroundColor = [UIColor clearColor];
                cell.contentView.backgroundColor = [UIColor clearColor];
                
                if ([selectedValue objectForKey:heading] != nil) {
                    
                    NSArray *arr = [[selectedValue valueForKey:heading] allObjects];
                    
                    NSInteger val1 = [[arr objectAtIndex:0] integerValue];
                    NSInteger val2 = [[arr objectAtIndex:1] integerValue];
                    [cell selectButtonWithTag1:val1 andTag2:val2];
                }
            }
            return cell;
        
        }else{
        
        GADTableViewCell *cell = nil;
        cell.headingLabel = nil;
        cell.detailsLabel1 = nil;
        cell.detailsLabel2 = nil;
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GADTableViewCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
            cell.headingLabel.text=heading;
            NSString *text1 =[[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:0];
            NSString *textToShow1 = [[text1 componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel1.text=textToShow1;
            NSString *text2 = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:1];
            NSString *textToShow2 = [[text2 componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel2.text=textToShow2;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            
            if ([selectedValue objectForKey:heading] != nil) {
                
                NSArray *arr = [[selectedValue valueForKey:heading] allObjects];
                
                NSInteger val1 = [[arr objectAtIndex:0] integerValue];
                NSInteger val2 = [[arr objectAtIndex:1] integerValue];
                [cell selectButtonWithTag1:val1 andTag2:val2];
            }
        }
        return cell;
      }
    }else if(rowType == 3) {
            
            GADTripleViewCellTam *cell = nil;
            cell.headingLabel = nil;
            cell.detailsLabel1 = nil;
            cell.detailsLabel2 = nil;
            cell.detailsLabel3 = nil;
            if (cell == nil) {
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GADTripleViewCellTam" owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
                
                cell.headingLabel.text=heading;
                NSString *text1 =[[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:0];
                NSString *textToShow1 = [[text1 componentsSeparatedByString:@"||"] objectAtIndex:0];
                cell.detailsLabel1.text=textToShow1;
                NSString *text2 = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:1];
                NSString *textToShow2 = [[text2 componentsSeparatedByString:@"||"] objectAtIndex:0];
                cell.detailsLabel2.text=textToShow2;
                NSString *text3 = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:2];
                NSString *textToShow3 = [[text3 componentsSeparatedByString:@"||"] objectAtIndex:0];
                cell.detailsLabel3.text=textToShow3;
                cell.backgroundColor = [UIColor clearColor];
                cell.contentView.backgroundColor = [UIColor clearColor];
                
                if ([selectedValue objectForKey:heading] != nil) {
                    
                    NSArray *arr = [[selectedValue valueForKey:heading] allObjects];
                    
                    NSInteger val1=0;
                    NSInteger val2=0;
                    NSInteger val3=0;

                    
                    for (int i = 0; i < arr.count; i++) {
                        
                        NSInteger numIng = [[arr objectAtIndex:i] integerValue];
                        
                        if (numIng>=102 && numIng<=107) {
                            val1 = [[arr objectAtIndex:i] integerValue];
                        }
                        if (numIng>=201 && numIng<=207){
                            val2 = [[arr objectAtIndex:i] integerValue];
                        }
                        if (numIng>=302 && numIng<=307) {
                            val3 = [[arr objectAtIndex:i] integerValue];
                        }
                        
                    }

                    [cell selectButtonWithTag2:val1 andTag2:val2 andTag3:val3];
                }
            }
            return cell;
      
    }else if(rowType == 4) {
        
        GADCuadrupleViewCellTam *cell = nil;
        cell.headingLabel = nil;
        cell.detailsLabel1 = nil;
        cell.detailsLabel2 = nil;
        cell.detailsLabel3 = nil;
        cell.detailsLabel4 = nil;
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GADCuadrupleViewCellTam" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
            cell.headingLabel.text=heading;
            NSString *text1 =[[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:0];
            NSString *textToShow1 = [[text1 componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel1.text=textToShow1;
            NSString *text2 = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:1];
            NSString *textToShow2 = [[text2 componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel2.text=textToShow2;
            NSString *text3 = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:2];
            NSString *textToShow3 = [[text3 componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel3.text=textToShow3;
            NSString *text4 = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:3];
            NSString *textToShow4 = [[text4 componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel4.text=textToShow4;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            
            if ([selectedValue objectForKey:heading] != nil) {
                
                NSArray *arr = [[selectedValue valueForKey:heading] allObjects];
                NSInteger val1=0;
                NSInteger val2=0;
                NSInteger val3=0;
                NSInteger val4=0;
                
                for (int i = 0; i < arr.count; i++) {
                    
                    NSInteger numIng = [[arr objectAtIndex:i] integerValue];
                    
                    if (numIng>=102 && numIng<=107) {
                        val1 = [[arr objectAtIndex:i] integerValue];
                    }
                    if (numIng>=201 && numIng<=207){
                        val2 = [[arr objectAtIndex:i] integerValue];
                    }
                    if (numIng>=302 && numIng<=307) {
                        val3 = [[arr objectAtIndex:i] integerValue];
                    }
                    if (numIng>=402 && numIng<=407) {
                        val4 = [[arr objectAtIndex:i] integerValue];
                    }
                    
                }
                [cell selectButtonWithTag4:val1 andTag2:val2 andTag3:val3 andTag4:val4];

            }
        }
        return cell;
        
    }else if(rowType == 5) {
        
        GADQuintupleViewCellTam *cell = nil;
        cell.headingLabel = nil;
        cell.detailsLabel1 = nil;
        cell.detailsLabel2 = nil;
        cell.detailsLabel3 = nil;
        cell.detailsLabel4 = nil;
        cell.detailsLabel5 = nil;
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GADQuintupleViewCellTam" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
            cell.headingLabel.text=heading;
            NSString *text1 =[[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:0];
            NSString *textToShow1 = [[text1 componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel1.text=textToShow1;
            NSString *text2 = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:1];
            NSString *textToShow2 = [[text2 componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel2.text=textToShow2;
            NSString *text3 = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:2];
            NSString *textToShow3 = [[text3 componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel3.text=textToShow3;
            NSString *text4 = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:3];
            NSString *textToShow4 = [[text4 componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel4.text=textToShow4;
            NSString *text5 = [[(NSDictionary*)[GADtextArray objectAtIndex:indexPath.row] objectForKey:heading] objectAtIndex:4];
            NSString *textToShow5 = [[text5 componentsSeparatedByString:@"||"] objectAtIndex:0];
            cell.detailsLabel5.text=textToShow5;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            
            if ([selectedValue objectForKey:heading] != nil) {
                
                NSArray *arr = [[selectedValue valueForKey:heading] allObjects];
                NSInteger val1=0;
                NSInteger val2=0;
                NSInteger val3=0;
                NSInteger val4=0;
                NSInteger val5=0;
                
                for (int i = 0; i < arr.count; i++) {
                   
                    NSInteger numIng = [[arr objectAtIndex:i] integerValue];
                    
                    if (numIng>=102 && numIng<=107) {
                        val1 = [[arr objectAtIndex:i] integerValue];
                    }
                    if (numIng>=201 && numIng<=207){
                        val2 = [[arr objectAtIndex:i] integerValue];
                    }
                    if (numIng>=302 && numIng<=307) {
                        val3 = [[arr objectAtIndex:i] integerValue];
                    }
                    if (numIng>=402 && numIng<=407) {
                        val4 = [[arr objectAtIndex:i] integerValue];
                    }
                    if (numIng>=502 && numIng<=507) {
                        val5 = [[arr objectAtIndex:i] integerValue];
                    }

                }
                [cell selectButtonWithTag5:val1 andTag2:val2 andTag3:val3 andTag4:val4 andTag5:val5];
            }
        }
        return cell;

    
    }else if(indexPath.row == ([GADtextArray count])) {
        CommentTableViewCell *cell=nil;
        heading  = @"ObserverComment";
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommentTableViewCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            cell.headingLabel.text=[sectionArray objectAtIndex:1];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.tag = 0;
            
            if ([selectedValue objectForKey:heading] != nil) {
                cell.commentTextView.text=[selectedValue objectForKey:heading];
            }
            
            cell.commentTextView.delegate = self;
        }
        
        return cell;
    }else if(row==[GADtextArray count] + 1) {
        CommentTableViewCell *cell=nil;
        heading  = @"TCComment";
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommentTableViewCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
            cell.headingLabel.text=[sectionArray objectAtIndex:2];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.tag = 1;
            
            if ([selectedValue objectForKey:heading]!=nil) {
                cell.commentTextView.text = [selectedValue objectForKey:heading];
            }
            
            cell.commentTextView.delegate = self;
        }
        
        return cell;
    } else {
        LTGADSignatureCell *cell=nil;
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LTGADSignatureCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            cell.delegate=self;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            
            if ([selectedValue objectForKey:@"Signatur_Observer"] != nil) {
                NSString *imagepath = [selectedValue objectForKey:@"Signatur_Observer"];
                
                NSString *completePath;
                if (self.isForReport) {
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *directoryPath = [documentsDirectory stringByAppendingPathComponent:@"/GadReport"];
                    completePath = [NSString stringWithFormat:@"%@/%@",[directoryPath stringByDeletingLastPathComponent], imagepath];
                }
                else {
                    NSString *directoryPath = [self createImageFolder];
                    completePath = [NSString stringWithFormat:@"%@/%@",directoryPath,[imagepath lastPathComponent]];
                }
                [cell.signatureImageView setContentMode:UIViewContentModeScaleAspectFit];
                [cell.signatureImageView setImage:[UIImage imageWithContentsOfFile:completePath]];
            }
            if ([selectedValue objectForKey:@"Signature_TC"] !=nil) {
                NSString *imagepath = [selectedValue objectForKey:@"Signature_TC"];
                NSString *completePath;
                if (self.isForReport){
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *directoryPath = [documentsDirectory stringByAppendingPathComponent:@"/GadReport"];
                    completePath = [NSString stringWithFormat:@"%@/%@",[directoryPath stringByDeletingLastPathComponent], imagepath];
                }
                else{
                    NSString *directoryPath = [self createImageFolder];
                    completePath = [NSString stringWithFormat:@"%@/%@",directoryPath,[imagepath lastPathComponent]];
                }
                [cell.firmaTcImageView setContentMode:UIViewContentModeScaleAspectFit];
                [cell.firmaTcImageView setImage:[UIImage imageWithContentsOfFile:completePath]];
            }
        }
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)saveData {
    NSMutableDictionary *GADdict = [[NSMutableDictionary alloc] init];
    [LTSingleton getSharedSingletonInstance].flightGADDict = selectedValue;
    gadReportArray = [[NSMutableArray alloc] init];
    NSMutableDictionary * flightDict = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    NSMutableDictionary * crewDict = [[NSMutableDictionary alloc] init];
    
    [crewDict setValue:@(draft) forKey:@"status"];
    
    [crewDict setValue:self.crewFirstName forKey:@"firstName"];
    [crewDict setValue:self.crewLastName forKey:@"lastName"];
    [crewDict setValue:self.bpIDforCrew forKey:@"bp"];
    [crewDict setValue:self.designationLabel.text forKey:@"activeRank"];
    
    NSDictionary * legDict = [[NSMutableDictionary alloc]init];
    NSDictionary * tempFlightDict = [[NSMutableDictionary alloc]init];
    tempFlightDict = [flightDict valueForKey:@"flightKey"];
    
    [GADdict setValue:[tempFlightDict valueForKey:@"airlineCode"] forKey:@"airlineCode"];
    [GADdict setValue:[tempFlightDict valueForKey:@"flightDate"] forKey:@"flightDate"];
    [GADdict setValue:[tempFlightDict valueForKey:@"flightNumber"] forKey:@"flightNumber"];
    
    [GADdict setValue:[tempFlightDict valueForKey:@"reportId"] forKey:@"reportId"];
    
    [GADdict setValue:[tempFlightDict valueForKey:@"suffix"] forKey:@"suffix"];
    if (([self.legArray count] - 1) < self.indexForLeg) {
        self.indexForLeg = 0;
    }
    [legDict setValue:[[self.legArray objectAtIndex:self.indexForLeg] valueForKey:@"destination"]  forKey:@"destination"];
    [legDict setValue:[[self.legArray objectAtIndex:self.indexForLeg] valueForKey:@"origin"]  forKey:@"origin"];
    [legDict setValue:crewDict forKey:@"crew"];
     stado = true;
    for (int i = 0; i < GADtextArray.count; i++) {
        NSMutableArray * tempValueArray = [[NSMutableArray alloc]init]; ;
        NSMutableDictionary * tempDict = [[NSMutableDictionary alloc]init];
        NSMutableDictionary * valueDict = [[NSMutableDictionary alloc]init];
       
        if (i == 5 || [materialType isEqualToString:@"WB"]) {
            NSArray * value = [[selectedValue objectForKey:[keysArray objectAtIndex:i]] allObjects];
            NSString * value1;
            NSString * value2;
            NSString * key2;
            NSString * key1;
            
            if(([typeFly isEqualToString:@"JJ"] || [typeFly isEqualToString:@"PZ"]) && [materialType isEqualToString:@"WB"]){
                
                if(value.count > 0) {
                    key1 =[[[GADtextArray objectAtIndex:i] objectForKey:[keysArray objectAtIndex:i]] objectAtIndex:0];
                    value1 =  [NSString stringWithFormat:@"%@",[value objectAtIndex:0]];
                    if (value1 != nil){
                        if (!([value1 isEqualToString:@"0"])) {
                            [valueDict setValue:value1 forKey:key1];
                        }else{
                            stado = false;
                        }
                    }else{
                     stado = false;
                    }

                }
                if (value.count > 1) {
                    key2 = [[[GADtextArray objectAtIndex:i] objectForKey:[keysArray objectAtIndex:i]] objectAtIndex:1];

                    value2 = [NSString stringWithFormat:@"%@",[value objectAtIndex:1]];
                    if (value2 != nil){
                        if (!([value2 isEqualToString:@"0"])) {
                            [valueDict setValue:value2 forKey:key2];
                        }else{
                            stado = false;
                        }
                    }else{
                        stado = false;
                    }

                }
                
                
                
                NSString * value3=@"";
                NSString * value4=@"";
                NSString * value5=@"";
                NSString * key5;
                NSString * key3;
                NSString * key4;
                
                
                if (value.count > 2) {
                    key3 = [[[GADtextArray objectAtIndex:i] objectForKey:[keysArray objectAtIndex:i]] objectAtIndex:2];
                    value3 = [NSString stringWithFormat:@"%@",[value objectAtIndex:2]];
                    if (value3 != nil){
                        if (!([value3 isEqualToString:@"0"] )) {
                            [valueDict setValue:value3 forKey:key3];
                        }else{
                            stado = false;
                        }
                    }else{
                        stado = false;
                    }
                }
                
                if (value.count > 3) {
                    key4 = [[[GADtextArray objectAtIndex:i] objectForKey:[keysArray objectAtIndex:i]] objectAtIndex:3];
                    value4 = [NSString stringWithFormat:@"%@",[value objectAtIndex:3]];
                    if (value4 != nil){
                        if (!([value4 isEqualToString:@"0"]) ){
                            [valueDict setValue:value4 forKey:key4];
                        }else{
                            stado = false;
                        }
                    }else{
                        stado = false;
                    }
                }
                if (value.count > 4) {
                    key5 = [[[GADtextArray objectAtIndex:i] objectForKey:[keysArray objectAtIndex:i]] objectAtIndex:4];
                    value5 = [NSString stringWithFormat:@"%@",[value objectAtIndex:4]];
                    if (value5 != nil){
                        if (!([value5 isEqualToString:@"" ] )) {
                            if (!([value5 isEqualToString:@"0"] )) {
                                [valueDict setValue:value5 forKey:key5];
                            }else{
                                if (i == 0){
                                    stado = false;
                                }
                            }
                        }
                    }else{
                        stado = false;
                    }

                }
                
               
            }else{
               
                if(value.count > 0) {
                    value1 =  [NSString stringWithFormat:@"%@",[value objectAtIndex:0]];
                }
                if (value.count > 1) {
                    value2 = [NSString stringWithFormat:@"%@",[value objectAtIndex:1]];
                }
                NSString * key1 = [[[GADtextArray objectAtIndex:i] objectForKey:[keysArray objectAtIndex:i]] objectAtIndex:0];
                NSString * key2 = [[[GADtextArray objectAtIndex:i] objectForKey:[keysArray objectAtIndex:i]] objectAtIndex:1];
                if (!([value1 isEqualToString:@""] || value1 == nil)) {
                    [valueDict setValue:value1 forKey:key1];
                }
                if (!([value2 isEqualToString:@""] || value2 == nil)) {
                    [valueDict setValue:value2 forKey:key2];
                }
                
                if ([valueDict valueForKey:key1] != nil || [valueDict valueForKey:key2] != nil) {
                    [tempValueArray addObject:valueDict];
                }
            
            }
            
            if ([valueDict valueForKey:key1] != nil || [valueDict valueForKey:key2] != nil) {
                [tempValueArray addObject:valueDict];
            }
            
        } else {
            
            NSString *key =[[[GADtextArray objectAtIndex:i] objectForKey:[keysArray objectAtIndex:i]] objectAtIndex:0];
            NSString *value;
            if ([selectedValue valueForKey:[keysArray objectAtIndex:i]]) {
                value  = [NSString stringWithFormat:@"%@",[selectedValue valueForKey:[keysArray objectAtIndex:i]]];
            }
            
            if (!([value isEqualToString:@""] || value == nil) || [value isEqualToString:@"(null)"]) {
                [valueDict setValue:value forKey:key];
                [tempValueArray addObject:valueDict];
            }
        }
        
        if (tempValueArray.count > 0) {
            [tempDict setObject:tempValueArray forKey:[keysArray objectAtIndex:i]];
            [gadReportArray addObject:tempDict];
        }
        
        tempDict = nil;
        tempValueArray = nil;
        valueDict = nil;
    }
    
    NSMutableDictionary* commentDict = [[NSMutableDictionary alloc]init];
    NSString * obsComment;
    NSString * tcComment;
    NSString * tcSign =[selectedValue valueForKey:@"Signature_TC"];
    NSString * obsSign =[selectedValue valueForKey:@"Signatur_Observer"];
    
    if(([typeFly isEqualToString:@"JJ"] || [typeFly isEqualToString:@"PZ"]) && [materialType isEqualToString:@"WB"])
    {

        obsComment =[selectedValue valueForKey:@"ObserverComment"];
        tcComment =[selectedValue valueForKey:@"TCComment"];
        
        if (obsComment != nil) {
            if (!([obsComment isEqualToString:@""])){
                [commentDict setValue:[selectedValue valueForKey:@"ObserverComment"] forKey:@"ObserverComment"];
            }else {
                stado = false;
            }
        } else {
            stado = false;
        }
        
        if (tcComment !=nil) {
            if (!([tcComment isEqualToString:@""])){
                [commentDict setValue:[selectedValue valueForKey:@"TCComment"] forKey:@"TCComment"];
            }else {
                stado = false;
            }
        } else {
            stado = false;
        }
        
        if (tcSign != nil) {
             if (!([tcSign isEqualToString:@""])){
                 [commentDict setValue:tcSign forKey:@"Signature_TC"];
             }else {
                 [commentDict setValue:tcSign forKey:@"Signature_TC"];
                 stado = false;
             }
        }else {
            [commentDict setValue:[selectedValue valueForKey:@"Signature_TC"] forKey:@"Signature_TC"];

            stado = false;
        }
        
        if (obsSign != nil) {
            if (!([obsSign isEqualToString:@""])){
                [commentDict setValue:obsSign forKey:@"Signatur_Observer"];
            }else {
                [commentDict setValue:obsSign forKey:@"Signatur_Observer"];
                stado = false;
            }
        }else {
            stado = false;
            [commentDict setValue:[selectedValue valueForKey:@"Signatur_Observer"] forKey:@"Signatur_Observer"];

        }
    }else{
        
        obsComment =[selectedValue valueForKey:[keysArray objectAtIndex:7]];
        tcComment =[selectedValue valueForKey:[keysArray objectAtIndex:8]];
        tcSign =[selectedValue valueForKey:@"Signature_TC"];
        obsSign =[selectedValue valueForKey:@"Signatur_Observer"];
        
        if (obsComment != nil) {
            [commentDict setValue:obsComment forKey:@"ObserverComment"];
        } else {
            [commentDict setValue:[selectedValue valueForKey:@"ObserverComment"] forKey:@"ObserverComment"];
        }
        
        if (tcComment !=nil) {
            [commentDict setValue:tcComment forKey:@"TCComment"];
        } else {
            [commentDict setValue:[selectedValue valueForKey:@"TCComment"] forKey:@"TCComment"];
        }
        
        if (![tcSign isEqualToString:@""] && tcSign != nil) {
            [commentDict setValue:tcSign forKey:@"Signature_TC"];
        }
        
        if (![obsSign isEqualToString:@""] && obsSign != nil) {
            [commentDict setValue:obsSign forKey:@"Signatur_Observer"];
        }
        
        
    }
    
    if ([commentDict valueForKey:@"ObserverComment"] != nil || [commentDict valueForKey:@"TCComment"] != nil || [commentDict valueForKey:@"Signature_TC"] != nil || [commentDict valueForKey:@"Signatur_Observer"] != nil) {
        [gadReportArray addObject:commentDict];
    }
    if (gadReportArray.count > 0) {
        [legDict setValue:gadReportArray forKey:@"GAD"];
    }
    [GADdict setValue:legDict forKey:@"leg"];
    [synch saveGaDDict:GADdict];
}
//sync data
-(void)makeSendBtnDisabled {
    // _sendBtn.userInteractionEnabled = NO;
}

-(NSString *)getAspectCodeValue:(NSString *)string {
    NSArray *valueKeyArray = [string componentsSeparatedByString: @"="];
    NSString *value = [valueKeyArray objectAtIndex:0];
    NSArray *valueKeyArray1 = [value componentsSeparatedByString: @"||"];
    NSString *aspectCode = [valueKeyArray1 objectAtIndex: 1];
    aspectCode = [aspectCode stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [aspectCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(NSString *)getScoreCodeValue:(NSString *)string {
    NSArray* valueKeyArray = [string componentsSeparatedByString: @"="];
    int valueCode = [[valueKeyArray objectAtIndex:1] intValue];
    NSString *finalCode = [NSString stringWithFormat:@"%d",valueCode];
    NSString *scoreCode = [btnTagValueDict valueForKey:finalCode];
    return scoreCode;
}

-(NSMutableDictionary *)formatJSON_WithGadReport:(NSDictionary *)dict {
    NSMutableDictionary *gadDetailDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *jsonFormatDict = [[NSMutableDictionary alloc] init];
    
    NSString *jsbCommets = [dict valueForKey:@"ObserverComment"];
    NSString *commentsTC = [dict valueForKey:@"TCComment"];
    jsbCommets = [jsbCommets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    commentsTC = [commentsTC stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (materialType) {
        [gadDetailDict setObject:materialType forKey:@"guideTypeCode"];
    }
    if (jsbCommets) {
        [gadDetailDict setObject:jsbCommets forKey:@"jsbComments"];
    }
    
    if (commentsTC) {
        [gadDetailDict setObject:commentsTC forKey:@"tcComments"];
    }
    
    NSMutableArray *evaluationArray = [[NSMutableArray alloc] init];
    NSArray * keyArrayForCategory = [dict allKeys];
    int i = 0;
    for (NSString *key in catKeyArray) {
        i++;
        for (NSString *keys in keyArrayForCategory) {
            
            if ([key isEqualToString:keys]) {
                NSMutableDictionary *evalutionDict = [[NSMutableDictionary alloc] init];
                
                if (i == 6 || [materialType isEqualToString:@"WB"]) {
                    
                    NSDictionary * valueDict= [dict valueForKey:keys];
                    NSArray * valueArray = [valueDict allValues];
                    NSArray * keyArrays = [valueDict allKeys];
                    for (int j=0;j<valueArray.count;j++) {
                        
                        NSMutableDictionary *evalutionDict1 = [[NSMutableDictionary alloc]init];
                        
                        [evalutionDict1 setObject:[self getAspectCodeValue:[keyArrays objectAtIndex:j]] forKey:@"aspectCode"];
                        NSString * finalCode = [NSString stringWithFormat:@"%@",[valueArray objectAtIndex:j]];
                        if([finalCode intValue]!=0)
                            [evalutionDict1 setObject:[btnTagValueDict valueForKey:finalCode] forKey:@"scoreCode"];
                        [evaluationArray addObject:evalutionDict1];
                    }
                    
                } else{
                    NSString *valueDic = [[dict valueForKey:keys] description];
                    [evalutionDict setObject:[self getAspectCodeValue:valueDic] forKey:@"aspectCode"];
                    [evalutionDict setObject:[self getScoreCodeValue:valueDic] forKey:@"scoreCode"];
                    [evaluationArray addObject:evalutionDict];
                    break;
                }
            }
        }
    }
    
    [gadDetailDict setObject:evaluationArray forKey:@"evaluation"];
    NSMutableDictionary *signatureFileDict  = [[NSMutableDictionary alloc]init];
    if ([dict objectForKey:@"Signatur_Observer"] != nil) {
        NSString *string =[dict objectForKey:@"Signatur_Observer"];
        NSArray* valueKeyArray = [string componentsSeparatedByString: @"/"];
        NSString* imageName = [valueKeyArray objectAtIndex: 3];
        [signatureFileDict setObject:imageName forKey:@"signatureFileJSB"];
    }
    if ([dict objectForKey:@"Signature_TC"] != nil) {
        NSString *string =[dict objectForKey:@"Signature_TC"];
        NSArray* valueKeyArray = [string componentsSeparatedByString: @"/"];
        NSString* imageName = [valueKeyArray objectAtIndex: 3];
        [signatureFileDict setObject:imageName forKey:@"signatureFileTC"];
    }
    [gadDetailDict setObject:signatureFileDict forKey:@"signatureFile"];
    NSMutableDictionary *crewMemberDict = [[NSMutableDictionary alloc]init];
    [crewMemberDict setObject:self.bpIDforCrew forKey:@"bp"];
    [crewMemberDict setObject:self.crewFirstName forKey:@"firstName"];
    [crewMemberDict setObject:self.crewLastName forKey:@"lastName"];
    [crewMemberDict setObject:self.designationLabel.text forKey:@"activeRank"];
    
    NSMutableDictionary *flightDict = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
    NSDictionary *tempFlightDict = [[NSMutableDictionary alloc]init];
    tempFlightDict = [flightDict valueForKey:@"flightKey"];
    if (self.bpIDforCrew!=nil) {
        NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
        [dateFormate setDateFormat:@"ddMM"];
        NSString *flightDateStr = [dateFormate stringFromDate:[tempFlightDict valueForKey:@"flightDate"]];
        NSString *reportIdFormation = @"";
        reportIdFormation = [reportIdFormation stringByAppendingString:flightDateStr];
        reportIdFormation = [reportIdFormation stringByAppendingString:[tempFlightDict valueForKey:@"airlineCode"]];
        reportIdFormation = [reportIdFormation stringByAppendingString:self.bpIDforCrew];
        reportIdFormation = [reportIdFormation stringByAppendingString:[self generateRandomString]];
        [gadDetailDict setObject:reportIdFormation forKey:@"reportId"];
    }
    
    [gadDetailDict setObject:crewMemberDict forKey:@"crewMember"];
    NSMutableArray *aLegArray = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *legDict = [[NSMutableDictionary alloc]init];
    [legDict setObject:[[self.legArray objectAtIndex:self.indexForLeg] valueForKey:@"origin"] forKey:@"origin"];
    [legDict setObject:[[self.legArray objectAtIndex:self.indexForLeg] valueForKey:@"destination"] forKey:@"destination"];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDateFormatter *outputFormatter2 = [[NSDateFormatter alloc] init];
    [outputFormatter2 setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    [legDict setObject: [outputFormatter stringFromDate:[[self.legArray objectAtIndex:self.indexForLeg] valueForKey:@"legDepartureLocal"]] forKey:@"legDepartureLocal"];
    [legDict setObject: [outputFormatter2 stringFromDate:[[self.legArray objectAtIndex:self.indexForLeg] valueForKey:@"legArrivalLocal"]] forKey:@"legArrivalLocal"];
    [aLegArray addObject:legDict];
    
    [gadDetailDict setObject:aLegArray forKey:@"legs"];
    [jsonFormatDict setObject:gadDetailDict forKey:@"gadDetail"];
    if (jsonFormatDict) {
        return jsonFormatDict;
    } else {
        return nil;
    }
}

-(void)sendGadReportRequest {
    NSMutableDictionary *dict = [self formatJSON_WithGadReport:gadFormDictionary];
    
    [LTSingleton getSharedSingletonInstance].flightJsonGADDict = [gadFormDictionary mutableCopy];
    NSString *bpNumber = [[[dict objectForKey:@"gadDetail"]objectForKey:@"crewMember"]objectForKey:@"bp"];
    
    synch.delegate = self;
    [GADController updateCrewMemberStatusFormInterface:inqueue uniqueBP:bpNumber forFlight:dict];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [synch sendFeedbackGadReport:dict];
    });
    
    [self performSelector:@selector(removeGADView) withObject:nil afterDelay:1.0];
}

- (void)removeGADView {
    [self willMoveToParentViewController:nil];  // 1
    [self.view removeFromSuperview];            // 2
    [self removeFromParentViewController];
}

- (IBAction)closeButtonClicked:(id)sender {
    NSInteger status =[[[gadFormDictionary valueForKey:@"crewMember"] valueForKey:@"status"] integerValue] ;
    
    if(([typeFly isEqualToString:@"JJ"] || [typeFly isEqualToString:@"PZ"]) && [materialType isEqualToString:@"WB"])
    {
        [self saveData];
    }
    else if (self.modifiedReport && (status==draft || status==eror || status == 0)) {
        [self saveData];
    }
    
    [self willMoveToParentViewController:nil];  // 1
    [self.view removeFromSuperview];            // 2
    [self removeFromParentViewController];
}

- (IBAction)trashButtonClicked:(id)sender {
    
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *alertString = [appDel copyTextForKey:@"ALERT_DELETE_GAD"];
    
    NSString *alertmsg = [appDel copyTextForKey:@"ALERT_MSG"];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:alertmsg message:alertString delegate:self cancelButtonTitle:[appDel copyTextForKey:@"CANCEL"] otherButtonTitles:[appDel copyTextForKey:@"ALERT_OK"],nil];
    alertView.tag = 101;
    [alertView show];
}

- (IBAction)sendButtonClicked:(id)sender {
    
    [keysArray addObject:@"Signatur_Observer"];
    @try{
        [self saveData];
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    @finally {
        // Added to show finally works as well
    }
    if ([self isAllQuestionsAnswered] == NO){
        NSString * notAnsweredKey   = [self getKeyForNotAnsweredQuestion];
        [self highlightNotAnsweredSection:notAnsweredKey];
    }
    
    else {
        
        
        AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        NSString *alertString = [appDel copyTextForKey:@"ALERT_GADSENDREPORT"];
        
        NSString *alertmsg = [appDel copyTextForKey:@"ALERT_MSG"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertmsg message:alertString delegate:self cancelButtonTitle:[appDel copyTextForKey:@"CANCEL"] otherButtonTitles:[appDel copyTextForKey:@"ALERT_SEND"],nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            
            [self willMoveToParentViewController:nil];  // 1
            [self.view removeFromSuperview];            // 2
            [self removeFromParentViewController];
            [alertView removeFromSuperview];
            [synch deleteGADForCrewBp:self.bpIDforCrew ForFlight:[[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"flightKey"]];
        } else {
            [alertView removeFromSuperview];
        }
    }
    
    else {
        if (buttonIndex == 1) {
            AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
            ActivityIndicatorView *acview = [ActivityIndicatorView getSharedActivityIndicatorViewInstance];
            [acview startActivityInView:self.view WithLabel:[appdel copyTextForKey:@"PLS_WAIT"]];
            
            NSMutableDictionary * flightDict = [LTSingleton getSharedSingletonInstance].flightRoasterDict;
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setValue:self.bpIDforCrew forKey:@"bp"];
            [dic setValue:[NSNumber numberWithInt:_indexForLeg]forKey:@"legIndex"];
            gadFormDictionary =[synch getGADforCrew:dic forFlight:flightDict];
            [self sendGadReportRequest];
            [acview stopAnimation];
        }
    }
}

- (IBAction)tappedOutside:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
    CGPoint point = [gesture locationInView:self.view];
    if (!CGRectContainsPoint(self.GADview.frame, point)) {
        [self closeButtonClicked:nil];
    }
}

-(BOOL)isAllQuestionsAnswered {
    
    if(([typeFly isEqualToString:@"JJ"] || [typeFly isEqualToString:@"PZ"]) && [materialType isEqualToString:@"WB"]){
        NSArray * allValues = [selectedValue allValues];
        if(stado){
            if ([allValues count] == 7) {
                return YES;
            }
        }
        return NO;
    }else{
       
        NSArray * allValues = [selectedValue allValues];
        if ([gadFormDictionary count] == 12)
            return YES;
        if ([allValues count]<[self.GADTableView numberOfRowsInSection:0] + 1) {
            return NO;
            
        }

    
    }
    return YES;
}

-(NSString *)getKeyForNotAnsweredQuestion {
    for (int j=0 ; j<[keysArray count]; j++){
        NSString * tempKey = [keysArray objectAtIndex:j];
        if ([selectedValue objectForKey:tempKey]){
            
        }else{
            return tempKey;
            break;
        }
    }
    
    
    return nil;
}

-(void)highlightNotAnsweredSection:(NSString *)key
{
    NSIndexPath * myIndexPath = [NSIndexPath indexPathForRow:[keysArray indexOfObject:key] inSection:0];
    AppDelegate * appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *alertMsg = [appDel copyTextForKey:@"ALERT_MSG"];
    NSString *allMandate = [appDel copyTextForKey:@"ALL_MANDATE"];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertMsg message:allMandate delegate:nil cancelButtonTitle:[appDel copyTextForKey:@"OK"] otherButtonTitles:nil];
    [alert show];
    [self.GADTableView scrollToRowAtIndexPath:myIndexPath
                             atScrollPosition:UITableViewScrollPositionNone
                                     animated:YES];
    
    [self.GADTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:myIndexPath,nil] withRowAnimation:NO];
    
    UITableViewCell * cell = [self.GADTableView cellForRowAtIndexPath:myIndexPath];
    cell.layer.borderWidth = 10.0f;
    cell.layer.borderColor = (__bridge CGColorRef)([UIColor redColor]);
    
    [self.GADTableView reloadData];
}

- (void)deleteImageObservador{
    [selectedValue setValue:@"" forKey:@"Signatur_Observer"];
    [self.GADTableView reloadData];
}

# pragma mark - Signature Capture delegate methods
//signature delegate methods
- (void)imageCapturedForObservador:(UIImage *)capturedImage{
    
    self.modifiedReport = YES;
    
    signatureImage = capturedImage;
    
    NSString *bpID=self.bpIDforCrew;
    NSString *randomString=@"OBS";
    NSString *photoName=[bpID stringByAppendingString:randomString];
    NSString *photoName1=[photoName stringByAppendingString:@".png"];
    NSString *folderPath=[self createImageFolder];
    NSData *pngData = UIImageJPEGRepresentation(capturedImage, 0.4);
    NSString *filePath = [folderPath stringByAppendingPathComponent:photoName1];
    [capturedImage setAccessibilityLabel:filePath];
    //Add the file name
    [pngData writeToFile:filePath atomically:YES];
    
    
    NSArray *docPathArray =[filePath componentsSeparatedByString:@"/"];
    
    NSInteger count = [docPathArray count];
    NSString *imagePathString=[NSString stringWithFormat:@"%@/%@/%@/%@",[docPathArray objectAtIndex:count-4 ],[docPathArray objectAtIndex:count-3 ],[docPathArray objectAtIndex:count-2 ],[docPathArray objectAtIndex:count-1 ]];
    
    [selectedValue setValue:imagePathString forKey:@"Signatur_Observer"];
    [self.GADTableView reloadData];
}

- (void)deleteImageCapturedForTc{
    [selectedValue setValue:@"" forKey:@"Signature_TC"];
    [self.GADTableView reloadData];
}

-(void)imageCapturedForTc:(UIImage *)capturedImage{
    
    self.modifiedReport = YES;
    
    signatureImageTC=capturedImage;
    
    NSString *flightName=self.bpIDforCrew;//crewMemberObj.bp;//[LTSingleton getSharedSingletonInstance].flightName;
    //NSString *bpnumber = crewMemberObj.bp;
    NSString *randomString=@"TC";
    
    NSString *photoName=[flightName stringByAppendingString:randomString];
    NSString *photoName1=[photoName stringByAppendingString:@".png"];
    NSString *folderPath=[self createImageFolder];
    NSData *pngData = UIImageJPEGRepresentation(capturedImage, 0.4);
    NSString *filePath = [folderPath stringByAppendingPathComponent:photoName1];
    //Add the file name
    [pngData writeToFile:filePath atomically:YES];
    
    NSArray *docPathArray =[filePath componentsSeparatedByString:@"/"];
    
    int count=[docPathArray count];
    NSString *imagePathString=[NSString stringWithFormat:@"%@/%@/%@/%@",[docPathArray objectAtIndex:count-4 ],[docPathArray objectAtIndex:count-3 ],[docPathArray objectAtIndex:count-2 ],[docPathArray objectAtIndex:count-1 ]];
    
    [selectedValue setValue:imagePathString forKey:@"Signature_TC"];
    [self.GADTableView reloadData];
}

-(NSString *)generateRandomString {
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:5];
    
    for (int i = 0; i < 5; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
}

-(NSString *)createImageFolder {
    
    NSError *error;
    NSString *flightName =[[[LTSingleton getSharedSingletonInstance].flightRoasterDict valueForKey:@"flightKey"] valueForKey:@"airlineCode"];
    flightName = [flightName stringByAppendingString:[[[LTSingleton getSharedSingletonInstance].flightKeyDict valueForKey:@"flightKey"] valueForKey:@"flightNumber"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString * flightDate=[dateFormatter stringFromDate:[[[LTSingleton getSharedSingletonInstance].flightKeyDict valueForKey:@"flightKey"] valueForKey:@"flightDate"]];// [LTSingleton getSharedSingletonInstance].flightDate;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/GadReport"];
    
    NSString *imageFolderName=[flightName stringByAppendingString:flightDate];
    NSString *insideFolderPath=[dataPath stringByAppendingPathComponent:imageFolderName];
    NSString *crewMemberBP=[flightName stringByAppendingString:self.bpIDforCrew];//crewMemberObj.bp;
    
    NSString *imagesFolderPath=[insideFolderPath stringByAppendingPathComponent:crewMemberBP];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    if (![[NSFileManager defaultManager] fileExistsAtPath:insideFolderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:insideFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagesFolderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
    return imagesFolderPath;
}

- (void)textViewSelectedWithTitle:(NSString *)signatureTitle withSignatureTag:(NSInteger)tag {
    LTGADSignatureViewController *popoverView = [[LTGADSignatureViewController alloc] initWithNibName:@"LTGADSignatureViewController" bundle:nil];
    popoverView.delegate = self;
    popoverView.titleString = signatureTitle;
    popoverView.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:popoverView animated:YES completion:nil];
    popoverView.view.superview.frame = CGRectMake(0, 0, 600, 525);
    if(ISiOS8) {
        popoverView.preferredContentSize = CGSizeMake(600, 525);
    }
    
    if (popoverView.signImageView != nil) {
        if (tag == 101) {
            
            popoverView.signImageView.image = signatureImage;
        }
        else if(tag == 102) {
            popoverView.signImageView.image = signatureImageTC;
        }
    }
}

#pragma mark - TextField Methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    CGPoint pointInTable = [textView.superview.superview convertPoint:textView.frame.origin toView:self.GADTableView];
    CGPoint contentOffset = self.GADTableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - kTableViewScrollOffset);
    
    [self.GADTableView setContentOffset:contentOffset animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    id textfieldCellRef;
    if(ISiOS8)
        textfieldCellRef = textView.superview.superview;
    else
        textfieldCellRef = textView.superview.superview.superview;
    
    if ([textfieldCellRef isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell;
        
        if(ISiOS8)
            cell = (UITableViewCell*)textView.superview.superview;
        else
            cell = (UITableViewCell*)textView.superview.superview.superview;
        
        NSIndexPath *indexPath = [self.GADTableView indexPathForCell:cell];
        
        [self.GADTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    [textView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *concatText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if(concatText.length > 700) {
        
        textView.text = [concatText substringToIndex:700];
        return NO;
    }
    
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    
    CommentTableViewCell *cell = (CommentTableViewCell*)textView.superview.superview;
    
    NSString *key;
    
    if(cell.tag == 0) {
        key = @"ObserverComment";
    }
    else if(cell.tag == 1) {
        key = @"TCComment";
    }
    
    NSNotification *notification = [[NSNotification alloc] initWithName:@"GADValueSelection" object:nil userInfo:[NSDictionary dictionaryWithObject:textView.text forKey:key]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)keboardWillShow:(id)sender {
    
    if(self.keyboardIsVisible) {
        return;
    }
    
    self.keyboardIsVisible = YES;
    
    self.gadCenterConstraintY.constant = -130;
    [UIView animateWithDuration:1.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    CGSize newContentSize = self.GADTableView.contentSize;
    newContentSize.height += kKeyboardFrame;
    self.GADTableView.contentSize = newContentSize;
}

-(void)keboardDissmissed:(id)sender {
   
    [self.view.layer removeAllAnimations];
    
    self.keyboardIsVisible = NO;
    
    self.gadCenterConstraintY.constant = 0;
    [UIView animateWithDuration:1.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    CGSize newContentSize = self.GADTableView.contentSize;
    newContentSize.height -= kKeyboardFrame;
    self.GADTableView.contentSize = newContentSize;
}

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.height, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
