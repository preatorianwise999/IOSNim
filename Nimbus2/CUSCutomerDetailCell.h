//
//  CUSCutomerDetailCell.h
//  LATAM
//
//  Created by Durga Madamanchi on 5/22/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"

@interface CUSCutomerDetailCell : OffsetCustomCell
@property (weak, nonatomic) IBOutlet UILabel *lastNameFirstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *docType;
@property (weak, nonatomic) IBOutlet UILabel *docType1;


@end
