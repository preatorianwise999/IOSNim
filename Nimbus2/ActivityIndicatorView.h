//
//  ActivityIndicatorView.h
//  UtilityPOC
//
//  Created by palash roy on 11/19/12.
//  Copyright (c) 2012 tcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "LTSingleton.h"

@interface ActivityIndicatorView : NSObject {
    
    UIActivityIndicatorView *activityIndicator;                                 // uiactivityindicator object
    
    UIView *borderView;                                                         // border view
    
    UIView *activityView;                                                       // activity view
    
    UILabel *activityStatus;                                                    // label to show the status
    
    NSOperationQueue *opQueue;
    
    BOOL isRunning;                                                             // flag to check its running or stopped
    NSThread *thread;
    UIImageView *pathView;
    
    
}

@property (nonatomic) BOOL isRunning;
@property (nonatomic,strong) NSString *msg;

-(void)startActivityInView:(UIView*)currentView WithLabel:(NSString*)statusMessage;

// this method updates the status of existing activity indicator
-(void)changelabelStatusTo:(NSString*)changedStatusMessage;

// this method is to start the animation
-(void)startAnimation;

// this method is to stop the animation
-(void)stopAnimation;

// this method returns the singleton shared instance
+(ActivityIndicatorView *)getSharedActivityIndicatorViewInstance;

@end
