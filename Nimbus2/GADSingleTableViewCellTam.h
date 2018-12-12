//
//  GADSingleTableViewCellTam.h
//  Nimbus2
//
//  Created by 720368 on 7/24/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+BorderFill.h"

@interface GADSingleTableViewCellTam : UITableViewCell{
    
}
@property (weak, nonatomic) IBOutlet UIButton *AE;
@property (weak, nonatomic) IBOutlet UIButton *PE;
@property (weak, nonatomic) IBOutlet UIButton *E;
@property (weak, nonatomic) IBOutlet UIButton *SE;
@property (weak, nonatomic) IBOutlet UIButton *EX;
@property (weak, nonatomic) IBOutlet UIButton *NOT;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (strong, nonatomic) UIButton *oldButton;
- (IBAction)selectButtonClicked:(id)sender;
-(NSDictionary*)getSelectedValue;
-(void)clearButtons;
-(void)selectButtonWithTag:(NSInteger)tag;
@end
