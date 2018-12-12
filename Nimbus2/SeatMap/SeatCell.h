//
//  SeatCell.h
//  Nimbus2
//
//  Created by Rajashekar on 16/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Seat.h"
#import "Constants.h"

@interface SeatCell : UICollectionViewCell {
    IBOutlet UIImageView *Accessory1;
    IBOutlet UIImageView *Accessory2;
    IBOutlet UIImageView *Accessory3;
    IBOutlet UIImageView *Accessory4;
    
    IBOutlet UIImageView *divider1;
    IBOutlet UIImageView *divider2;
    
    IBOutlet UIImageView *Ribbon;
    BOOL isVip;
    BOOL issplMeal;
    BOOL issplNeed;
    BOOL isChild;
    BOOL isUpgrade;
    BOOL track1;
    BOOL track2;
    
}

-(void)configurePassengerData:(Seat *)seat;

@end
