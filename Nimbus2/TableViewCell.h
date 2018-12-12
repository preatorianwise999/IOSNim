//
//  TableViewCell.h
//  Nimbus2
//
//  Created by 720368 on 9/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *DetailsLbl;
@property (weak, nonatomic) IBOutlet UILabel *synchDateLbl;
@property (weak, nonatomic) IBOutlet UILabel *statusLb;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@end
