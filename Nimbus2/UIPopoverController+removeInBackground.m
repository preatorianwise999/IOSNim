//
//  UIPopoverController+removeInBackground.m
//  LATAM
//
//  Created by vishal on 7/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//
#import <objc/runtime.h>
#import "UIPopoverController+removeInBackground.h"


@implementation UIPopoverController (removeInBackground)

static NSHashTable* replace_popoverHashTable;

+ (void) load
{
    SEL originalSelector = @selector(initWithContentViewController:);
    SEL replacementSelector = @selector(replace_initWithContentViewController:);
    Method originalMethod = class_getInstanceMethod( [UIPopoverController class], originalSelector);
    Method replacementMethod = class_getInstanceMethod( [UIPopoverController class], replacementSelector);
    method_exchangeImplementations(originalMethod, replacementMethod);
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( applicationDidEnterBackgroundNotification: )
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];
}

- (id) replace_initWithContentViewController: (UIViewController*) contentViewController
{
    UIPopoverController* popoverController = [self replace_initWithContentViewController: contentViewController];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        replace_popoverHashTable = [NSHashTable weakObjectsHashTable];
    });
    [replace_popoverHashTable addObject: popoverController];
    return popoverController;
}

+ (void) applicationDidEnterBackgroundNotification: (NSNotification*) n
{
    for ( UIPopoverController* popoverController in replace_popoverHashTable )
    {
        if ( popoverController.isPopoverVisible )
        {
            [popoverController dismissPopoverAnimated: NO];
        }
    }
}

@end
