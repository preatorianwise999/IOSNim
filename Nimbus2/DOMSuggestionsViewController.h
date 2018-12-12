//
//  DOMSuggestionsViewController.h
//  Nimbus2
//
//  Created by Priyanka on 07/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Validation.h"
#import "CustomViewController.h"

@interface DOMSuggestionsViewController : CustomViewController <UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *suggestionsTableView;
@property(weak,nonatomic) IBOutlet UILabel *headingLabel;
@property(nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end
