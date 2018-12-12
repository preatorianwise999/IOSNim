//
//  CrewViewController.h
//  Nimbus2
//
//  Created by 720368 on 7/14/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface CrewViewController : UIViewController<iCarouselDataSource,iCarouselDelegate>{
    NSMutableArray * legArray;
}
@property (strong, nonatomic) IBOutlet iCarousel *contentScrollView;
- (void)updateCurrentViewFrame;
@end
