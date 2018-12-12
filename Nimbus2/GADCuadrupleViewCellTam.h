//
//  GADCuadrupleViewCellTam.h
//  Nimbus2
//
//  Created by 720368 on 7/22/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+BorderFill.h"

@interface GADCuadrupleViewCellTam : UITableViewCell{
    UIButton *oldButton;
    UIButton *oldButton2;
    UIButton *oldButton3;
    UIButton *oldButton4;
    NSMutableArray *clickedButtonsText;
}
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel1;
@property (weak, nonatomic) IBOutlet UIButton *AE;
@property (weak, nonatomic) IBOutlet UIButton *PE;
@property (weak, nonatomic) IBOutlet UIButton *E;
@property (weak, nonatomic) IBOutlet UIButton *SE;
@property (weak, nonatomic) IBOutlet UIButton *EX;
@property (weak, nonatomic) IBOutlet UIButton *NOT;
- (IBAction)selectButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailsLabel2;
@property (weak, nonatomic) IBOutlet UIButton *AE2;
@property (weak, nonatomic) IBOutlet UIButton *PE2;
@property (weak, nonatomic) IBOutlet UIButton *E2;
@property (weak, nonatomic) IBOutlet UIButton *SE2;
@property (weak, nonatomic) IBOutlet UIButton *EX2;
@property (weak, nonatomic) IBOutlet UIButton *NOT2;
- (IBAction)selectButtonClicked2:(id)sender;
-(void)selectButtonWithTag1:(NSInteger)tag1 andTag2:(NSInteger)tag2;

@property (weak, nonatomic) IBOutlet UILabel *detailsLabel3;
@property (weak, nonatomic) IBOutlet UIButton *AE3;
@property (weak, nonatomic) IBOutlet UIButton *PE3;
@property (weak, nonatomic) IBOutlet UIButton *E3;
@property (weak, nonatomic) IBOutlet UIButton *SE3;
@property (weak, nonatomic) IBOutlet UIButton *EX3;
@property (weak, nonatomic) IBOutlet UIButton *NOT3;
- (IBAction)selectButtonClicked3:(id)sender;
-(void)selectButtonWithTag2:(NSInteger)tag1 andTag2:(NSInteger)tag2 andTag3:(NSInteger)tag3;

@property (weak, nonatomic) IBOutlet UILabel *detailsLabel4;
@property (weak, nonatomic) IBOutlet UIButton *AE4;
@property (weak, nonatomic) IBOutlet UIButton *PE4;
@property (weak, nonatomic) IBOutlet UIButton *E4;
@property (weak, nonatomic) IBOutlet UIButton *SE4;
@property (weak, nonatomic) IBOutlet UIButton *EX4;
@property (weak, nonatomic) IBOutlet UIButton *NOT4;
- (IBAction)selectButtonClicked4:(id)sender;
-(void)selectButtonWithTag4:(NSInteger)tag1 andTag2:(NSInteger)tag2 andTag3:(NSInteger)tag3 andTag4:(NSInteger)tag4;

-(NSDictionary*)getSelectedValue;
@end
