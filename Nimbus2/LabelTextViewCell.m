//
//  LabelTextViewCell.m
//  LATAM
//
//  Created by Durga Madamanchi on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LabelTextViewCell.h"

@implementation LabelTextViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textField.layer.borderColor =[[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
        
        self.textField.layer.borderWidth = 1.0f;
        self.textField.layer.backgroundColor = [[UIColor whiteColor] CGColor];
        self.textField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//-(void) layoutSubviews {
//    [super layoutSubviews];
//    
//    //current frame
//    CGRect newFrame = self.controlButton.frame;
//    newFrame.origin.y = (self.frame.size.height - self.controlButton.image.size.height) * 0.5;
//    newFrame.size = self.controlButton.image.size;
//    if([self.controlButton.image isEqual:[UIImage imageNamed:@"add"]])
//    {
//        newFrame.origin.y = 23;
//    }
//    else if([self.controlButton.image isEqual:[UIImage imageNamed:@"remove"]]){
//        newFrame.origin.y = 20;
//    }
//    
//    newFrame.origin.x = 15;
//    
//    //remove original button (UIkit might have regenerated it)
//    if([self currentState] != CustomCellStateDefaultMask){
//        [self removeOriginalEditControl];
//    }
//    
//    self.controlButton.frame = newFrame;
//    
//    // Vishnu: changing the y center of deletable cell,since for every deletable cell,mius has to be at the center
//    if([self.controlButton.image isEqual:[UIImage imageNamed:@"remove"]]){
//        CGPoint center = self.controlButton.center;
//        center.y = self.contentView.center.y+9;
//        self.controlButton.center = center;
//    }
//    
//    
//}

@end
