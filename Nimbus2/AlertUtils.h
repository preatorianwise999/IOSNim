//
//  AlertUtils.h
//  HPStoreFront
//
//  Created by chakravarthy on 02/04/13.
//  Copyright (c) 2013 Palash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertUtils : NSObject

+ (void) showErrorAlertWithTitle:(NSString *) title message:(NSString *)message;

+ (void) showErrorAlertWithTitle:(NSString *) title message:(NSString *)message withDelegate:(id)delegate;

+ (void) showErrorAlertWithOKCancel:(NSString *) title message:(NSString *)message withDelegate:(id)delegate;

+ (void) showErrorAlertWithTitle:(NSString *) title message:(NSString *)message cancelButtonTiltle:(NSString*)title withDelegate:(id)delegate;

+ (void) showErrorAlertWithTitle:(NSString *) title message:(NSString *)message withDelegate:(id)delegate withTag:(NSInteger)tag;
+(BOOL)checkAlertExist;
@end
