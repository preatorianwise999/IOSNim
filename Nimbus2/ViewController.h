//
//  ViewController.h
//  Nimbus2
//
//  Created by 720368 on 7/2/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlightViewController.h"
#import "SynchronizationController.h"
#import "ActivityIndicatorView.h"
#import "LTSingleton.h"
#import "AlertUtils.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController<UITextFieldDelegate, SynchDelegate, UIGestureRecognizerDelegate> {

}

@end

