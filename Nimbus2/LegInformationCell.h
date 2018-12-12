//
//  LegInformationCell.h
//  LATAM
//
//  Created by Vishnu on 02/06/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface LegInformationCell : OffsetCustomCell

@property (weak, nonatomic) IBOutlet UITextField *origin;
@property (weak, nonatomic) IBOutlet UITextField *destination;
@property (weak, nonatomic) IBOutlet TestView *departureTime;
@property (weak, nonatomic) IBOutlet TestView *destinationTime;

@property (weak, nonatomic) IBOutlet UILabel *origin_lab;
@property (weak, nonatomic) IBOutlet UILabel *destination_lab;
@property (weak, nonatomic) IBOutlet UILabel *departureTime_lab;
@property (weak, nonatomic) IBOutlet UILabel *destinationTime_lab;
@end
