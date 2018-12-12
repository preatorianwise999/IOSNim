//
//  NSData+CryptoExtensions.h
//  HPStoreFront
//
//  Created by Palash on 4/29/13.
//  Copyright (c) 2013 Palash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CryptoExtensions)

- (NSData*)AES256EncryptWithKey:(NSString*)key;

- (NSData*)AES256DecryptWithKey:(NSString*)key;

@end
