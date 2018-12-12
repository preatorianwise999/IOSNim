//
//  TextTextTextTextOther.m
//  LATAM
//
//  Created by Durga Madamanchi on 5/19/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TextTextTextTextOther.h"

@implementation TextTextTextTextOther

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)awakeFromNib {
    
    self.firstNameTextField.layer.borderColor =[[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    
    self.firstNameTextField.layer.borderWidth = 1.0f;
    self.firstNameTextField.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.firstNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    
    self.lastnameTextField.layer.borderColor =[[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    
    self.lastnameTextField.layer.borderWidth = 1.0f;
    self.lastnameTextField.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.lastnameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    
    self.secondLastNameTextField.layer.borderColor =[[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    
    self.secondLastNameTextField.layer.borderWidth = 1.0f;
    self.secondLastNameTextField.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.secondLastNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    
    self.docNumberTextField.layer.borderColor =[[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    
    self.docNumberTextField.layer.borderWidth = 1.0f;
    self.docNumberTextField.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.docNumberTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
