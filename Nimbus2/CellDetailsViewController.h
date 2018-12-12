//
//  CellDetailsViewController.h
//  Nimbus2
//
//  Created by 720368 on 8/24/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+DateFormat.h"

@interface CellDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *BCDetailslbl;
@property (weak, nonatomic) IBOutlet UILabel *YCDetailslbl;
@property (weak, nonatomic) IBOutlet UILabel *R1lbl;
@property (weak, nonatomic) IBOutlet UILabel *S1lbl;
@property (weak, nonatomic) IBOutlet UILabel *C1lbl;
@property (weak, nonatomic) IBOutlet UILabel *childernlbl;
@property (weak, nonatomic) IBOutlet UILabel *arrivalTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *departureTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *arrivalDateLbl;
@property (weak, nonatomic) IBOutlet UILabel *departureDateLbl;
- (IBAction)nextLegClicked:(id)sender;
- (IBAction)prevLegClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *legLbl;
@property(nonatomic,retain)NSArray *legs;
@property(nonatomic) int index;

@end
