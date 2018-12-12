//
//  LegViewController.h
//  Nimbus2
//
//  Created by 720368 on 7/15/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTSingleton.h"
#import "NSDate+DateFormat.h"
#import "Constants.h"

@interface LegViewController : UIViewController
@property (nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UILabel *origin;
@property (weak, nonatomic) IBOutlet UILabel *destination;
@property (weak, nonatomic) IBOutlet UILabel *arrivalDate;
@property (weak, nonatomic) IBOutlet UILabel *arrivalTime;
@property (weak, nonatomic) IBOutlet UILabel *departureDate;
@property (weak, nonatomic) IBOutlet UILabel *departureTime;

@end
