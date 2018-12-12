//
//  SwitchCell.m
//  LATAM
//
//  Created by Vishnu on 10/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "SwitchCell.h"
//#import "LTSingleton.h"

@implementation SwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (IBAction)valueChanged:(id)sender {
    
}

@end
