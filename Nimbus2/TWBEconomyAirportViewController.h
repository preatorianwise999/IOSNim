//
//  TDOMEconomyAirportViewController.h
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestView.h"
#import "CustomViewController.h"


@interface TWBEconomyAirportViewController : CustomViewController<UITextFieldDelegate, PopoverDelegate>

@property(nonatomic,strong) NSMutableArray *handLuggageArr;
@property(nonatomic,strong) NSMutableArray *mallAssignedSeatsArr;
@property(nonatomic,strong) NSMutableArray *propertyInfoSeatArr;
@property(nonatomic,strong) NSMutableArray *duplicateSeatArr;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end
