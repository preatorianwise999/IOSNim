//
//  TwoButtonCell.m
//  LATAM
//
//  Created by Vishnu on 14/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "TwoButtonCell.h"
//Nimbus@2#import "LTSingleton.h"

@implementation TwoButtonCell
@synthesize segmentSelected;

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

- (IBAction)valueChanged:(UISegmentedControl *)sender {
    self.segmentSelected = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
//Nimbus@2    [LTSingleton getSharedSingletonInstance].isDataChanged=TRUE;
}
@end
