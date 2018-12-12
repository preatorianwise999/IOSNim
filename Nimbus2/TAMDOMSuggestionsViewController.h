//
//  TAMDOMSuggestionsViewController.h
//  LATAM
//
//  Created by Vishnu on 16/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface TAMDOMSuggestionsViewController : CustomViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *suggestionsTableView;
@property(weak,nonatomic) IBOutlet UILabel *headingLabel;


@end
