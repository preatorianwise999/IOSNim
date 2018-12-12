//
//  CrewCPTableViewCell.h
//  Nimbus2
//
//  Created by 720368 on 7/20/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CrewCPTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *dataView;

@property (weak, nonatomic) IBOutlet UIImageView *cptImageView;
@property (weak, nonatomic) IBOutlet UILabel *cptBPIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *cptNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *cptSecondImageView;
@property (weak, nonatomic) IBOutlet UILabel *cptSecondBPId;
@property (weak, nonatomic) IBOutlet UILabel *cptSecondNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *cptThreeImageView;
@property (weak, nonatomic) IBOutlet UILabel *cptthreeBPId;
@property (weak, nonatomic) IBOutlet UILabel *cptThreeNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *designationLabel;
@property (weak, nonatomic) IBOutlet UILabel *designationSecondLabel;
@property (weak, nonatomic) IBOutlet UILabel *designationThreeLabel;

@end
