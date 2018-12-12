//
//  FlightDetailsCell.h
//  Nimbus2
//
//  Created by Rajashekar on 03/12/15.
//  Copyright © 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlightDetailsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *arrow1;
@property (weak, nonatomic) IBOutlet UIImageView *arrow2;
@property (weak, nonatomic) IBOutlet UIImageView *arrow3;
@property (weak, nonatomic) IBOutlet UIImageView *arrow4;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *bar1Width;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *bar2Width;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *bar3Width;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *bar4Width;



@end
