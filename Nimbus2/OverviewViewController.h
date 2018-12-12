//
//  OverviewViewController.h
//  LATAM
//
//  Created by Vishnu on 11/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Validation.h"
#import "CustomViewController.h"
#import "DropDownCell.h"

@interface OverviewViewController : CustomViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PopoverDelegate>{
    NSDictionary *sourceDictionary;

}
@property (weak, nonatomic) IBOutlet UITableView *overviewTableView;
@property(weak,nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end
