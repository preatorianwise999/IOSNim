//
//  OtherNum.h
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface OtherTextCamera : OffsetCustomCell

@property (weak, nonatomic) IBOutlet UILabel *reasonLbl;
@property (weak, nonatomic) IBOutlet UILabel *observationLbl;
@property (weak, nonatomic) IBOutlet TestView *reasonTxt;
@property(nonatomic,weak) IBOutlet TestView *alertComboView;
@property (weak, nonatomic) IBOutlet UIImageView *commentBtn;

@property(nonatomic,weak) IBOutlet TestView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@end
