//
//  TwoButtonCell.h
//  LATAM
//
//  Created by Vishnu on 14/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"

@interface TwoButtonCell : OffsetCustomCell
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
- (IBAction)valueChanged:(UISegmentedControl *)sender;
@property(nonatomic,retain) NSString *segmentSelected;

@end
