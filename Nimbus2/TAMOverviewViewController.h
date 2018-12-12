//
//  TAMOverviewViewController.h
//  LATAM
//
//  Created by Vishnu on 16/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestView.h"
#import "NSString+Validation.h"
#import "CustomViewController.h"
#import "DropDownCell.h"

@interface TAMOverviewViewController : CustomViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PopoverDelegate>{
    NSMutableArray *boardingDropDown;
    NSDictionary *sourceDictionary;


}
@property (weak, nonatomic) IBOutlet UITableView *overviewTableView;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;
@property(weak,nonatomic) IBOutlet UILabel *headingLabel;

@end
