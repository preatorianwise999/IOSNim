//
//  DOMBoardingViewController.h
//  Nimbus2
//
//  Created by Priyanka on 07/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface DOMBoardingViewController : CustomViewController  <UITableViewDataSource,UITableViewDelegate,PopoverDelegate>
@property (weak, nonatomic) IBOutlet UITableView *boardingTableView;
@property(nonatomic) BOOL switchValue;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end
