//
//  TempLocalStorageModel.m
//  LATAM

//  Created by palash  on 4/21/14.
//  Copyright (c) 2013 Palash. All rights reserved.
//

#import "TempLocalStorageModel.h"

@implementation TempLocalStorageModel

+(void)saveInUserDefaults:(NSString *)string withKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults] setObject:string forKey:key];
    
}

+(NSString*)getUserDefaultsData:(NSString*)key {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
}

+(void)setDataInKeyChainWrapper :(NSString*)string withKey:(id)key withEncryption :(BOOL)encryptionFlag{
    if (encryptionFlag) {
        if (string!=nil) {
            @try {
                NSData *nonEncryptedData = [string dataUsingEncoding:NSUTF8StringEncoding];
                
                NSData *encryptedData = [nonEncryptedData AES256EncryptWithKey:[self getKeyFromSaltHash]];
               
                [[KeychainItemWrapper SharedInstance] setObject:encryptedData forKey:key];
                [[KeychainItemWrapper SharedInstance] setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
            }
            @catch (NSException *exception) {
                DLog(@"excption=%@",exception.description);
            }
        }
        else{
            [[KeychainItemWrapper SharedInstance] setObject:KEmptyString forKey:key];
            [[KeychainItemWrapper SharedInstance] setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
        }
    }
    else{

            [[KeychainItemWrapper SharedInstance] setObject:string forKey:key];
            [[KeychainItemWrapper SharedInstance] setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
    }
}

+(NSString*)getDataFromKeyChainWrapperForKey:(id)key withDecrypted :(BOOL)decryptedFlag{
    if (decryptedFlag) {
        if ([[KeychainItemWrapper SharedInstance] objectForKey:key]!=nil || ![[[KeychainItemWrapper SharedInstance] objectForKey:key] isEqualToString:KEmptyString]) {
            @try {
                NSData *encryptedData;
                if ([[[KeychainItemWrapper SharedInstance] objectForKey:key] isKindOfClass:[NSData class]]) {
                    encryptedData =[[KeychainItemWrapper SharedInstance] objectForKey:key];
                }
                else{
                    NSString *string = [[KeychainItemWrapper SharedInstance] objectForKey:key];
                    if ([string isEqualToString:KEmptyString]) {
                        return KEmptyString;
                    }
                    else
                        encryptedData = [string dataUsingEncoding:NSUTF8StringEncoding];
                }
                encryptedData =[[KeychainItemWrapper SharedInstance] objectForKey:key];
                NSData *decryptedData = [encryptedData AES256DecryptWithKey:[self getKeyFromSaltHash]];
                return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
            }
            @catch (NSException *exception) {
                DLog(@"excption=%@",exception.description);
                return @"";
            }
            
            
        }
        else{
            return KEmptyString;
        }
        
    }
    else{
        return [[KeychainItemWrapper SharedInstance] objectForKey:key];
    }
}
+(NSString*)getKeyFromSaltHash{
    NSString *source = SALT_HASH;
    NSString *firstFour = [source substringToIndex:3];
    // firstFour is @"0123"
    
    NSString *allButFirstThree = [source substringFromIndex:60];
    // allButFirstThree is @"3456789"
    
    NSRange twoToSixRange = NSMakeRange(42, 8);
    NSString *twoToSix = [source substringWithRange:twoToSixRange];
    NSString *key = [NSString stringWithFormat:@"%@%@%@",firstFour,allButFirstThree,twoToSix];
    return key;
}
- (void) dealloc {
    
}

@end
