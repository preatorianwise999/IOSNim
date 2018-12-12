//
//  GADViewController.h
//  Nimbus2
//
//  Created by 720368 on 7/22/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADTableViewCell.h"
#import "GADDobleViewCellTam.h"
#import "GADSingleTableViewCell.h"
#import "GADSingleTableViewCellTam.h"
#import "GADTripleViewCellTam.h"
#import "GADCuadrupleViewCellTam.h"
#import "GADQuintupleViewCellTam.h"
#import "CommentTableViewCell.h"
#import "LTGADSignatureCell.h"
#import "LTGADSignatureViewController.h"
#import "DictionaryParser.h"
#import "AppDelegate.h"
#import "SynchronizationController.h"



@interface GADViewController : UIViewController<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,LTGADSignatureImageProtocol,LTGADSignatureProtocol,SynchDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UITableView *GADTableView;
@property (weak, nonatomic) IBOutlet UIView *GADview;
@property (weak, nonatomic) IBOutlet UILabel *crewNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *designationLabel;

@property (weak, nonatomic) IBOutlet UILabel *crewNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *bpIdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *crewImageView;
@property (strong, nonatomic) NSArray *legArray;
@property (nonatomic) NSInteger indexForLeg;
@property (strong, nonatomic) NSString *crewFirstName;
@property (strong, nonatomic) NSString *crewLastName;
@property (strong, nonatomic) NSString *bpIDforCrew;
@property  BOOL isForReport;
@property  BOOL isForStatus;

-(NSString *)getScoreCodeValue:(NSString *)string;
-(NSString *)getAspectCodeValue:(NSString *)string;
-(NSMutableDictionary *)formatJSON_WithGadReport:(NSDictionary *)dict;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *trashBtn;



- (IBAction)tappedOutside:(id)sender;
- (void)updateFrames;

@end
