//
//  PaddedTextField.m
//  LATAM
//
//  Created by Ankush Jain on 7/8/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "PaddedTextField.h"

@implementation PaddedTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 7, bounds.origin.y, bounds.size.width - 40, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 7, bounds.origin.y, bounds.size.width - 40, bounds.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
