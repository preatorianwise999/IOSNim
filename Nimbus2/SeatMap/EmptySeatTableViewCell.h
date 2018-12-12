//
//  EmptySeatTableViewCell.h
//  Nimbus2
//
//  Created by Palash on 12/11/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmptySeatTableViewCell : UITableViewCell
{
    
}
@property (weak, nonatomic) IBOutlet UILabel *seatType;
@property (weak, nonatomic) IBOutlet UILabel *seats;

@end
