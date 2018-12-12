//
//  NSString+Validation.m
//  LATAM
//
//  Created by PalashR on 3/20/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "NSString+Validation.h"

#import <CoreText/CoreText.h>

@implementation NSString (Validation)


//--------------------------------------------------------------

- (BOOL)validateNotEmpty
{
    NSString *same = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    return ([same length] != 0);
}

//--------------------------------------------------------------
- (BOOL)validateMinimumLength:(NSInteger)length
{
    return ([self length] >= length);
}

//--------------------------------------------------------------
- (BOOL)validateMaximumLength:(NSInteger)length
{
    return ([self length] <= length);
}

//--------------------------------------------------------------
- (BOOL)validateMatchesConfirmation:(NSString *)confirmation
{
    return [self isEqualToString:confirmation];
}

//--------------------------------------------------------------
- (BOOL)validateInCharacterSet:(NSMutableCharacterSet *)characterSet
{
    return ([self rangeOfCharacterFromSet:[characterSet invertedSet]].location == NSNotFound);
}

//--------------------------------------------------------------
- (BOOL)validateAlpha
{
    return [self validateInCharacterSet:[NSCharacterSet letterCharacterSet]];
}

//--------------------------------------------------------------
- (BOOL)validateAlphanumeric
{
    return [self validateInCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
}

//--------------------------------------------------------------
- (BOOL)validateNumeric
{
    return [self validateInCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
}



//--------------------------------------------------------------
- (BOOL)validateAlphaSpace
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet letterCharacterSet];
    [characterSet addCharactersInString:@" "];
    return [self validateInCharacterSet:characterSet];
}

//--------------------------------------------------------------
- (BOOL)validateAlphanumericSpace
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString:@" "];
    return [self validateInCharacterSet:characterSet];
}

//--------------------------------------------------------------
// Alphanumeric characters, underscore (_), and period (.)
- (BOOL)validateUsername
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString:@"'_."];
    return [self validateInCharacterSet:characterSet];
}

//--------------------------------------------------------------

- (BOOL)validateEmail:(BOOL)stricterFilter
{
    /* NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
     NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
     NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
     NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
     return [emailTest evaluateWithObject:self];*/
    
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    // @TODO:
//    emailRegex = @"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}

- (BOOL)validateStringWithRegExprestion :(NSString *)regExprestion
{
    /* NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
     NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
     NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
     NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
     return [emailTest evaluateWithObject:self];*/
    //NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", regExprestion];

    NSError *error = nil;
    
    NSRegularExpression *regExpresion1 = [[NSRegularExpression alloc] initWithPattern:regExprestion options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSUInteger regExMatches = [regExpresion1 numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    if(regExMatches == 0){
        return  NO;
    }else
        return YES;
    
    return NO;
}

//--------------------------------------------------------------
- (BOOL)validatePhoneNumber
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [characterSet addCharactersInString:@"'-*+#,;. "];
    return [self validateInCharacterSet:characterSet];
}

-(BOOL)containsString:(NSString*)str{
    if ([self rangeOfString:str].location == NSNotFound) {
        return FALSE;
    } else {
        return TRUE;
    }
}

@end



@implementation  NSString(Mandatory)

-(NSMutableAttributedString *)mandatoryString
{
    NSMutableAttributedString *attrStr=[[NSMutableAttributedString alloc] initWithString:self];
        [attrStr addAttribute:(NSString*)kCTSuperscriptAttributeName value:@"0.5" range:NSMakeRange(self.length - 1, 1)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(self.length - 1,1)];
    
    return attrStr;
    
}

@end
