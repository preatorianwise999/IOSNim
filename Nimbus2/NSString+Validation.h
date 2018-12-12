//
//  NSString+Validation.h
//  LATAM
//
//  Created by PalashR on 3/20/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)
- (BOOL)validateInCharacterSet:(NSMutableCharacterSet *)characterSet;
- (BOOL)validateNotEmpty;
- (BOOL)validateMinimumLength:(NSInteger)length;
- (BOOL)validateAlphanumeric;
- (BOOL)validateNumeric;
- (BOOL)validateEmail:(BOOL)stricterFilter;
- (BOOL)validatePhoneNumber;
-(BOOL)containsString:(NSString*)str;
- (BOOL)validateMaximumLength:(NSInteger)length;
- (BOOL)validateStringWithRegExprestion :(NSString *)regExprestion;
@end

@interface NSString(Mandatory)
-(NSMutableAttributedString *)mandatoryString;
@end