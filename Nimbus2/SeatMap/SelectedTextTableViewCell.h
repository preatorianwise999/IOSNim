//
//  SelectedTextTableViewCell.h
//  Nimbus2
//
//  Created by Dreamer on 10/23/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectedTextTableViewCell : UITableViewCell{
}
@property (weak, nonatomic) IBOutlet UILabel *bc_Label;
@property (weak, nonatomic) IBOutlet UILabel *lname_Label;
@property (weak, nonatomic) IBOutlet UILabel *presilver_Label;

@property (weak, nonatomic) IBOutlet UILabel *a_Label;
@property (weak, nonatomic) IBOutlet UIImageView *selectedPassengerImage;

@end
