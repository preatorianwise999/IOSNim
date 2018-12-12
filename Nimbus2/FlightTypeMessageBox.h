//
//  FlightTypeMessageBox.h
//  LATAM
//
//  Created by Ankush Jain on 5/7/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInformationParser.h"

@protocol FlightTypeMessageBoxProtocol <NSObject>

- (void)setFlightTypeManually:(NSString *)flightTypeStr andBusinessUnit:(NSString *)businessUnit andMaterialType:(NSString *)materialType;
- (void)cancelClicked;
@end

@interface FlightTypeMessageBox : UIViewController

@property (nonatomic, strong) NSString *flightType;
@property (nonatomic, strong) NSString *airlineCode;
@property (nonatomic, strong) NSString *bUnit;
@property (nonatomic, strong) NSString *materialVal;
@property id delegate;

@end
