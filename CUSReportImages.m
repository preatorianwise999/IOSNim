//
//  CUSReportImages.m
//  Nimbus2
//
//  Created by Rajashekar on 09/09/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "CUSReportImages.h"

@implementation CUSReportImages

@synthesize image1;
@synthesize image2;
@synthesize image3;
@synthesize image4;
@synthesize image5;
-(NSDictionary *)getDictionaryRepresentation {
    NSDictionary *temp = [[NSDictionary alloc] initWithObjectsAndKeys:image1,@"image1",image2,@"image2",image3,@"image3",image4,@"image4",image5,@"image5", nil];
    return temp;
}
@end




