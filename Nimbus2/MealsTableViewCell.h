//
//  MealsTableViewCell.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 11/27/15.
//  Copyright © 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MealsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cabinClassLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UITextView *mealsTextView;
@property (weak, nonatomic) IBOutlet UITextView *amountsTextView;

@end
