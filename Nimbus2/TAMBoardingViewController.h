//
//  TAMBoardingViewController.h
//  LATAM
//
//  Created by Vishnu on 16/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface TAMBoardingViewController : CustomViewController<UITableViewDataSource,UITableViewDelegate,PopoverDelegate>
@property (weak, nonatomic) IBOutlet UITableView *boardingTableView;
@property(nonatomic) BOOL switchValue;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;


@end
