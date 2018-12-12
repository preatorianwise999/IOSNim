//
//  OtherNum.m
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "OtherTextCamera.h"

@implementation OtherTextCamera

@synthesize reasonLbl,observationLbl;
@synthesize reasonTxt, alertComboView, commentBtn;
@synthesize cameraImageView,cameraView;

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
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [super setSelected:selected animated:animated];
    reasonTxt.selectedTextField.attributedPlaceholder=kDarkPlaceholder([appDel copyTextForKey:@"REPORT@TAM"]);
    
    // Configure the view for the selected state
}

@end
