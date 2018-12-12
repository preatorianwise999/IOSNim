//
//  DutyFreeViewController.h
//  LATAM
//
//  Created by Vishnu on 12/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface DutyfreeViewController : CustomViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PopoverDelegate>
@property (weak, nonatomic) IBOutlet UITableView *dutyfreeTableView;
@property(nonatomic) BOOL switchValue;
@property(weak,nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end
