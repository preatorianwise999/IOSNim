//
//  SideMenuRowTableViewCell.h
//  Nimbus2
//
//  Created by Palash on 29/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuRowTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rowTitle;
@property (weak, nonatomic) NSIndexPath *rowSelected;

@property (weak, nonatomic) IBOutlet UIImageView *rowBackgroundImg;

@end
