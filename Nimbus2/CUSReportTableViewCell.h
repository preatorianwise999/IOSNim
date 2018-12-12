//
//  CUSReportTableViewCell.h
//  Nimbus2
//
//  Created by Dreamer on 7/30/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CUSReportTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet UIImageView *addImageView;
@property (weak, nonatomic) IBOutlet UIButton *addButtonView;

@property (weak, nonatomic) IBOutlet UIView *dataView;

@end
