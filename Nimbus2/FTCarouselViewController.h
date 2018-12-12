//
//  FTCarouselViewController.h
//  Nimbus2
//
//  Created by Palash on 29/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "CustomViewController.h"

@protocol FTCarouselViewControllerDelegate <NSObject>
@optional

- (void) didScrollToIndex:(NSInteger) index withTotalItems:(NSInteger) totalItems;


@end


@interface FTCarouselViewController : UIViewController<iCarouselDataSource,iCarouselDelegate>
@property (strong, nonatomic) IBOutlet iCarousel *carouseView;
@property  int currentIndex;
@property (strong, nonatomic) CustomViewController *viewController;
@property (strong, nonatomic) NSMutableArray *viewContrllerArray;

@property(nonatomic, weak) id<FTCarouselViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil legsCount:(int)count controllerName:(NSString*)ctrlName;   

@end


