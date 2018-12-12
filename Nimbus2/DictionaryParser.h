//
//  DictionaryParser.h
//  HPStoreFront
//
//  Created by Palash on 09/04/13.
//  Copyright (c) 2013 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DictionaryParser : NSObject

+(NSDictionary *)dictionaryFromData:(NSData *)data;

+(NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary;

+(NSDictionary *) dictionaryFromString:(NSString *)jsonString;

@end
