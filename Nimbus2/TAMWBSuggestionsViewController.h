//
//  TAMWBSuggestionsViewController.h
//  LATAM
//
//  Created by Vishnu on 27/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface TAMWBSuggestionsViewController : CustomViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *suggestionsTableView;
@property(weak,nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;


@end