//
//  CommentTableViewCell.m
//  Nimbus2
//
//  Created by 720368 on 7/29/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.commentTextView.layer setBorderColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4].CGColor];
    self.commentTextView.layer.borderWidth=1.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSDictionary*)getSelectedValue {
    return [NSDictionary dictionaryWithObject:self.commentTextView.text forKey:self.headingLabel.text];
}

@end
