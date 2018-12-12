//
//  TableViewCell.m
//  Nimbus2
//
//  Created by 720368 on 9/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "TableViewCell.h"

#import "AppDelegate.h"

@implementation TableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    self.statusLb.text = [appDel copyTextForKey:@"STATUS_UPDATED"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
