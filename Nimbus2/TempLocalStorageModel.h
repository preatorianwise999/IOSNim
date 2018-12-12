//
//  TempLocalStorageModel.h
//  LATAM

//  Created by Palash  on 4/21/14.
//  Copyright (c) 2013 Palash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+CryptoExtensions.h"
#import "KeychainItemWrapper.h"

@interface TempLocalStorageModel : NSObject

+(void)saveInUserDefaults :(NSString *)string withKey :(NSString *)key;

+(NSString*)getUserDefaultsData:(NSString*)key;

+(void)setDataInKeyChainWrapper :(NSString*)string withKey:(id)key withEncryption :(BOOL)encryptionFlag;

+(NSString*)getDataFromKeyChainWrapperForKey:(id)key withDecrypted :(BOOL)decryptedFlag;

@end
