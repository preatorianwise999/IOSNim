//
//  ActivityIndicatorView.m
//  UtilityPOC
//
//  Created by palash roy on 11/19/12.
//  Copyright (c) 2012 tcs. All rights reserved.
//

#import "ActivityIndicatorView.h"

@implementation ActivityIndicatorView

@synthesize isRunning;

/*
 This method is used in classes which ever want to access the ActivityIndicatorView Object
 */

+(ActivityIndicatorView *)getSharedActivityIndicatorViewInstance {
    
	static ActivityIndicatorView *SharedActivityIndicatorViewInstance = nil;
    
    @synchronized(self) {
		if (!SharedActivityIndicatorViewInstance)
			SharedActivityIndicatorViewInstance = [[ActivityIndicatorView alloc] init];
		return SharedActivityIndicatorViewInstance;
	}	
}

-(void)startActivityInView:(UIView*)currentView WithLabel:(NSString*)statusMessage {
    self.msg=statusMessage;
    [self stopAnimation];
    borderView = [[UIView alloc] init];
     borderView.frame =CGRectMake(0, 0, currentView.frame.size.width, currentView.frame.size.height);
    if(!ISiOS8)
    {
        if (![LTSingleton getSharedSingletonInstance].isComingFromBackG) {
            borderView.frame =CGRectMake(0, 0, currentView.frame.size.width, currentView.frame.size.height);
        }
        else {
            borderView.frame =CGRectMake(0, 0, currentView.frame.size.height,currentView.frame.size.width );
        }
    }
    [LTSingleton getSharedSingletonInstance].isComingFromBackG=FALSE;
    //borderView.frame =CGRectMake(0, 0, currentView.frame.size.width, currentView.frame.size.height);
    borderView.backgroundColor = [UIColor blackColor];
    borderView.alpha = 0.5;
    [currentView addSubview:borderView];
    
    activityView = [[UIView alloc] init];
    [activityView setBounds:CGRectMake(0, 0, 250, 140)];
    [activityView setCenter:borderView.center];
    activityStatus=[[UILabel alloc] initWithFrame:CGRectMake(0, 83, 250, 40)];
    activityStatus.backgroundColor=[UIColor redColor];
    
    pathView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flightpath"]];
    CGRect frame = pathView.frame;
    frame.origin.x = 85;
    frame.origin.y = 10;
    frame.size.height = 70;
    frame.size.width = 70;
    pathView.frame = frame;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self animateFlight:pathView];
    });
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.backgroundColor=[UIColor blackColor];
    activityView.alpha = 0.8;
    [activityView clipsToBounds];
    
    [currentView addSubview:activityView];
    
    activityStatus.text=statusMessage;
    activityStatus.backgroundColor=[UIColor clearColor];
    activityStatus.textAlignment= NSTextAlignmentCenter;
    activityStatus.textColor =[UIColor whiteColor];
    [activityStatus setFont:[UIFont fontWithName:@"Roboto" size:16.0]];
    [activityView addSubview:activityStatus];
    
    activityIndicator.frame = CGRectMake(105, 25, 37, 37);
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    [activityView addSubview:activityIndicator];
    [activityView bringSubviewToFront:activityIndicator];
    [activityView addSubview:pathView];
    activityView.layer.cornerRadius = 10;
    isRunning = TRUE;
}

-(void)changelabelStatusTo:(NSString*)changedStatusMessage {
    self.msg=changedStatusMessage;
    activityStatus.text= changedStatusMessage;
}

-(void)animateFlight:(UIImageView*)flightPath{
    [flightPath.layer removeAllAnimations];
    CABasicAnimation* rotationAnimation =
    [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotationAnimation setToValue:[NSNumber numberWithFloat:M_PI*2]];
    // Make a full rotation in five seconds
    [rotationAnimation setDuration:1.0];
    // Repeat forever.
    [rotationAnimation setRepeatCount:HUGE_VALF];
    // Make the animation timing linear
    [rotationAnimation setTimingFunction:
     [CAMediaTimingFunction
      functionWithName:kCAMediaTimingFunctionLinear]];
    [[flightPath layer] addAnimation:rotationAnimation forKey:nil];
}

/*
 This method is used to animate the UIActivityIndicatorView Object "activityIndicator"
 */

-(void)startAnimation {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self animateFlight:pathView];
    });
}

/*
 This method is used to stop the animation of UIActivityIndicatorView Object "activityIndicator"
 */

-(void)stopAnimation {
    
    [activityIndicator stopAnimating];
    [opQueue cancelAllOperations];
    [activityView removeFromSuperview];
    [borderView removeFromSuperview];
    isRunning = FALSE;
}



- (void) dealloc{
    
}

@end
