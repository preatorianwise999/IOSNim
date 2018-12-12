//
//  ClassInformation.h
//  SeatMapSample
//
//  Created by Rajashekar on 12/10/15.
//  Copyright (c) 2015 Rajashekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassInformation : NSObject {
    
    NSString *className;
    NSInteger numberOfRows;
    NSInteger numberOfColumns;
    NSInteger numberOfHiddenColumns;
    NSInteger numberOfItems;
    NSMutableArray *seatsArray;
    NSString *columnHeaderString;
    NSMutableArray *rowInfoArray;
    NSMutableArray *columnInfoArray;
    NSString * columnTypeString;
    
    
}
@property (nonatomic,retain) NSString *className;
@property (nonatomic) NSInteger numberOfRows;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) NSInteger numberOfHiddenColumns;
@property (nonatomic) NSInteger numberOfItems;
@property (nonatomic,retain) NSMutableArray *seatsArray;
@property (nonatomic,retain) NSString *columnHeaderString;
@property (nonatomic,retain) NSMutableArray *rowInfoArray;
@property (nonatomic,retain) NSMutableArray *columnInfoArray;
@property (nonatomic,retain) NSString * columnTypeString;

@end
