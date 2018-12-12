//
//  AlertUtils.m
//  HPStoreFront
//
//  Created by chakravarthy on 02/04/13.
//  Copyright (c) 2013 Palash. All rights reserved.
//

#import "AlertUtils.h"
#import "LTSingleton.h"
#import "AppDelegate.h"

@implementation AlertUtils

/*
 
 Use:- This method is used to display alert view with title and message
 
 */



+(BOOL)checkAlertExist{
    UIAlertView *topMostAlert = [NSClassFromString(@"_UIAlertManager") performSelector:@selector(topMostAlert)];
    if(topMostAlert)
        return NO;
    else
        return YES;
    
//    for (UIWindow* window in [UIApplication sharedApplication].windows) {
//        NSArray* subviews = window.subviews;
//        if ([subviews count] > 0){
//            for (id cc in subviews) {
//                if ([cc isKindOfClass:[UIAlertView class]]) {
//                    return NO;
//                }
//            }
//        }
//    }
//    return YES;
}


+ (void) showErrorAlertWithTitle:(NSString *) title message:(NSString *)message {

    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message
                                                       delegate:nil
                                              cancelButtonTitle:KOkButtonTitle
                                              otherButtonTitles:nil];
    if ([self checkAlertExist]) {
        [alertView show];
    }
    
}

/*
 
 Use:- The below methods are used to display alert view with title and message and tag is set for identification
 
 */

+ (void) showErrorAlertWithTitle:(NSString *) title message:(NSString *)message withDelegate:(id)delegate {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message
                                                       delegate:delegate
                                              cancelButtonTitle:KOkButtonTitle
                                              otherButtonTitles:nil];
    //alertView.tag = KAlertViewWithDelegate_Tag;
    if ([self checkAlertExist]) {
        [alertView show];
    }
}

+ (void) showErrorAlertWithTitle:(NSString *) title message:(NSString *)message withDelegate:(id)delegate withTag:(NSInteger)tag {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message
                                                       delegate:delegate
                                              cancelButtonTitle:KOkButtonTitle
                                              otherButtonTitles:nil];
    alertView.tag = tag;
    if ([self checkAlertExist]) {
        [alertView show];
    }
}


+ (void) showErrorAlertWithOKCancel:(NSString *) title message:(NSString *)message withDelegate:(id)delegate {

    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message
                                                       delegate:delegate
                                              cancelButtonTitle:[apDel copyTextForKey:@"NO"]
                                              otherButtonTitles:[apDel copyTextForKey:@"YES"],nil];
    //alertView.tag = KAlertViewWithYESNODelegate_Tag;
    if ([self checkAlertExist]) {
        [alertView show];
    }
}

+ (void) showErrorAlertWithTitle:(NSString *) title message:(NSString *)message cancelButtonTiltle:(NSString*)buttonTitle withDelegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message
                                                       delegate:delegate
                                              cancelButtonTitle:buttonTitle
                                              otherButtonTitles:nil];
    //alertView.tag = KAlertViewWithDelegate_Tag;
    if ([self checkAlertExist]) {
        [alertView show];
    }
}

- (void) dealloc{
    
}

@end
