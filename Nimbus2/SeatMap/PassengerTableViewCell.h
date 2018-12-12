//
//  PassengerTableViewCell.h
//  SeatMapSample
//
//  Created by Rajashekar on 14/10/15.
//  Copyright (c) 2015 Rajashekar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassengerTableViewCell : UITableViewCell {
    
}
@property (weak, nonatomic) IBOutlet UILabel *seatNumber;
@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *accountType;

@end
