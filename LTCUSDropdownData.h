//
//  LTCUSDropdownData.h
//  LATAM
//
//  Created by Durga Madamanchi on 5/29/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTCUSDropdownData : NSObject {
}
+ (NSArray *)copyDataForKey:(NSString *)key forDocType:(NSString*)docType;
+ (NSString *)getIndexValue:(NSString *)type atIndex:(int)index forDocType:(NSString*)docType;
+ (NSDictionary *)getDictForKey:(NSString *)key;
@end
