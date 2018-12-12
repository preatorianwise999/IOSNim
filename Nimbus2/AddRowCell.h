//
//  AddRowCell.h
//  LATAM
//
//  Created by Ankush Jain on 4/10/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"

@interface AddRowCell : OffsetCustomCell

@property(nonatomic, weak) IBOutlet UILabel *headingLbl;
@property (nonatomic ,weak) UIViewController *viewController;
@end
