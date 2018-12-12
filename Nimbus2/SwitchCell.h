//
//  SwitchCell.h
//  LATAM
//
//  Created by Vishnu on 10/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
//#import "LTSingleton.h"

@interface SwitchCell : OffsetCustomCell

@property (weak, nonatomic) IBOutlet UISwitch *rightSwitch;
//@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
- (IBAction)valueChanged:(id)sender;
@end