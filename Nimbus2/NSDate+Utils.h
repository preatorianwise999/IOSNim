//
//  NSDate+Utilities.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 10/5/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utils)

- (NSDate*)toLocalTime;
- (NSDate*)toGlobalTime;

@end
