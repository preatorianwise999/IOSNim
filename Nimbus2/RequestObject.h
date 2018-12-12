//
//  RequestObject.h
//  Nimbus2
//
//  Created by 720368 on 8/4/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestObject : NSObject

@property (nonatomic) NSInteger tag;
@property (nonatomic) Priority priority;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)NSString *language;
@property (nonatomic,strong)NSString *version;
@property (nonatomic,strong)NSString *param;
@property (nonatomic)NSInteger position;
@property (nonatomic,strong) NSString *type;

@end
