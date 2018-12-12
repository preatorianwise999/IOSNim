//
//  DomGeneralInfoViewController.h
//  Nimbus2
//
//  Created by Palash on 30/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownViewController.h"
#import "CustomViewController.h"
#import "DropDownCell.h"

@interface DomGeneralInfoViewController :CustomViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,PopoverDelegate>{
    int tryCount;

}

@property (weak, nonatomic) IBOutlet UITableView *tableView_genralInfo;
@property (weak, nonatomic) IBOutlet UILabel *label_heading;
@property(nonatomic) BOOL switchValue;

@property(nonatomic,retain) NSMutableArray *materialDropdown;
@property(nonatomic,retain) NSMutableArray *baseCrewDropdown;
@property(nonatomic,retain) NSIndexPath *ip;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end
