//
//  LTGADSignatureCell.m
//  LATAM
//
//  Created by Madhu on 5/7/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTGADSignatureCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation LTGADSignatureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *obserString = [appDel copyTextForKey:@"SIGNATURE_OBSERVER"];
    _firmaObservadorLabel.text = obserString;
     NSString *firmaString = [appDel copyTextForKey:@"SIGNATURE_TC"];
    _firmaTCLabel.text = firmaString;
    self.signatureImageView.backgroundColor = [UIColor whiteColor];
    self.firmaTcImageView.backgroundColor = [UIColor whiteColor];

    // Configure the view for the selected state
}

- (IBAction)observadorSignatureTapped:(id)sender {
    [_delegate textViewSelectedWithTitle:self.firmaObservadorLabel.text withSignatureTag:101];
}

- (IBAction)tcSignatureTapped:(id)sender {
    [_delegate textViewSelectedWithTitle:self.firmaTCLabel.text withSignatureTag:102];
}

@end
