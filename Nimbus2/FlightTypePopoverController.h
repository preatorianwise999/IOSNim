//
//  FlightTypePopoverController.h
//  LATAM
//
//  Created by Ankush Jain on 5/7/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FlightTypePopoverProtocol <NSObject>

-(void)setSelectedValue:(NSString *)selectedValue forViewWithTag:(int)btnTag;


@end

@interface FlightTypePopoverController : UIViewController

@property(nonatomic,strong) NSArray *dataSource;
@property id delegate;
@property int btnTag;
@property(nonatomic,strong) NSString *prevText;
@end
