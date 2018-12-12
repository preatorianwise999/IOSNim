//
//  CUSReportImages.h
//  Nimbus2
//
//  Created by Rajashekar on 09/09/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUSReportImages : NSObject


@property (nonatomic, retain) NSString * image1;
@property (nonatomic, retain) NSString * image2;
@property (nonatomic, retain) NSString * image3;
@property (nonatomic, retain) NSString * image4;
@property (nonatomic, retain) NSString * image5;
-(NSDictionary *)getDictionaryRepresentation;
@end
