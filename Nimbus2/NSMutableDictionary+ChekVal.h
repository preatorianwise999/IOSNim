//
//  NSMutableDictionary+ChekVal.h
//  LATAM
//
//  Created by Palash on 20/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (ChekVal)
-(id)checkNilValueForKey:(NSString*)key;
-(NSString*)keyForValue:(NSString*)val;
@end


@interface NSDictionary (ChekVal)
-(id)checkNilValueForKey:(NSString*)key;
-(NSString*)keyForValue:(NSString*)val;
@end
