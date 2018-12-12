//
//  AddRowCell.m
//  LATAM
//
//  Created by Ankush Jain on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "AddRowCell.h"

@implementation AddRowCell
@synthesize headingLbl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    
    [self removeOriginalEditControl];
    
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];

    self.controlButton.frame = CGRectMake(40, 15, 23, 23);
    headingLbl.frame = CGRectMake(self.controlButton.frame.size.width + 10, self.controlButton.center.y - 20, 400, 40);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    CGRect frame = headingLbl.frame;
    headingLbl.frame = frame;    // Configure the view for the selected state

    [super setSelected:selected animated:animated];
}

@end
