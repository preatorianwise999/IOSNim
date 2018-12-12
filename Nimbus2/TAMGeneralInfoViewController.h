//
//  TAMGeneralInfoViewController.h
//  LATAM
//
//  Created by Vishnu on 16/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownViewController.h"
#import "CustomViewController.h"

@interface TAMGeneralInfoViewController : CustomViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,PopoverDelegate>{
    int tryCount;
}

@property (weak, nonatomic) IBOutlet UITableView *generalTableView;
@property(nonatomic) BOOL switchValue;

@property(nonatomic,retain) NSMutableArray *materialDropdown;
@property(nonatomic,retain) NSMutableArray *baseCrewDropdown;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end
