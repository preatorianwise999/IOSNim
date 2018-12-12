//
//  OnlyTextViewCell.m
//  LATAM
//
//  Created by Vishnu on 12/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "OnlyTextViewCell.h"

@implementation OnlyTextViewCell
@synthesize indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)awakeFromNib{
    
    UIView *cellScrollView = [[self subviews] firstObject];
    UIView *contentView;
    for(UIView *subview in cellScrollView.subviews){
        if([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellContentView"]){
            contentView = subview;
        }
    }
    NSArray *subViews = [contentView subviews];
    
    _textView.layer.borderWidth = 1.0f;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.layer.borderColor =[[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];


}


@end
