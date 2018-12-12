
//
//  DictionaryParser.m
//
//
//  Created by Palash on 09/04/13.
//  Copyright (c) 2013 TCS. All rights reserved.
//

#import "DictionaryParser.h"

@implementation DictionaryParser

+(NSDictionary *)dictionaryFromData:(NSData *)data {
    if (data == nil) {
        return [[NSDictionary alloc] init];
    }
    NSError *err=nil;
    NSDictionary *rootDictionary=[[NSDictionary alloc] init];
    @try {
        rootDictionary= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    }
    @catch (NSException *exception) {
        //DLog(@"exception=%@",exception.description);
    }
    
	return rootDictionary;
}

+(NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary{
    
    NSMutableDictionary *tempDict = [dictionary mutableCopy];
    
    NSError *error;
    @try {
        if ([[tempDict allKeys] count]>0) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempDict
                                                               options:0
                                                                 error:&error];
            
            if (!jsonData) {
                return nil;
            }
            else {
                NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
                return JSONString;
            }
            
        }

    }
    @catch (NSException *exception) {
       // DLog(@"exception handled");
    }
    
}

+(NSDictionary *) dictionaryFromString:(NSString *)jsonString{
    
    NSData *responseData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError* error=nil;
    NSDictionary *rootDictionary= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    return rootDictionary;
}



@end
