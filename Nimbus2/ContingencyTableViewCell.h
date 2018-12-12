//
//  ContingencyTableViewCell.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 9/29/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContingencyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet UITextView *descLb;

@property (weak, nonatomic) IBOutlet UILabel *phoneLb;
@property (weak, nonatomic) IBOutlet UILabel *snackLb;
@property (weak, nonatomic) IBOutlet UILabel *mealLb;
@property (weak, nonatomic) IBOutlet UILabel *busLb;
@property (weak, nonatomic) IBOutlet UILabel *hotelLb;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImgView;

@end
