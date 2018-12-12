//
//  CustomManualTableViewCell.h
//  Nimbus2
//
//  Created by Sravani Nagunuri on 30/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreManuals.h"
#import "AppDelegate.h"

@interface CustomManualTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *selectIdentifier;
@property (weak, nonatomic) IBOutlet UIImageView *manualTypeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *manualAccessoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *manualTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *manualDateLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (void)displayCellContent: (NSDictionary*)manualDict;

@end
