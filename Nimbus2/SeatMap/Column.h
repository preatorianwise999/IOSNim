//
//  ColumnInformation.h
//  SeatMapSample
//
//  Created by Rajashekar on 12/10/15.
//  Copyright (c) 2015 Rajashekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Column : NSObject {
    
    NSInteger columnName;
    BOOL isWindow;
    BOOL isAisle;
    
}
@property(nonatomic) NSInteger columnName;
@property(nonatomic) BOOL isWindow;
@property(nonatomic) BOOL isAisle;

@end
