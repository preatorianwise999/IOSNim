//
//  DOMOverviewViewController.h
//  Nimbus2
//
//  Created by Priyanka on 07/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Validation.h"
#import "CustomViewController.h"
#import "DropDownCell.h"

@interface DOMOverviewViewController : CustomViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PopoverDelegate>
{
NSDictionary *sourceDictionary;
}
@property (weak, nonatomic) IBOutlet UITableView *overviewTableView;
@property(weak,nonatomic) IBOutlet UILabel *headingLabel;
@property(nonatomic) BOOL switchValue;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end
