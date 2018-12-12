//
//  GADDobleViewCellTam.h
//  Nimbus2
//
//  Created by 720368 on 7/22/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+BorderFill.h"

@interface GADDobleViewCellTam : UITableViewCell{
    UIButton *oldButton;
    UIButton *oldButton2;
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

-(NSDictionary*)getSelectedValue;
@end
