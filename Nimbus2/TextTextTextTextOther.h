//
//  TextTextTextTextOther.h
//  LATAM
//
//  Created by Durga Madamanchi on 5/19/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "TestView.h"

@interface TextTextTextTextOther : OffsetCustomCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *lastnameTextField;
@property (weak, nonatomic) IBOutlet UILabel *seconLastNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *secondLastNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *docTypeLabel;
@property (weak, nonatomic) IBOutlet TestView *doctypetestView;
@property (weak, nonatomic) IBOutlet UILabel *docNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *docNumberTextField;

@end
