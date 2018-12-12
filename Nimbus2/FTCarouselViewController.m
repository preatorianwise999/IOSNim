//
//  FTCarouselViewController.m
//  Nimbus2
//  Created by Palash on 29/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "FTCarouselViewController.h"
#import "LTSingleton.h"
#import "CustomViewController.h"
@interface FTCarouselViewController ()
{
    int legsCount;
    NSString *nameOfController;
}
@end

@implementation FTCarouselViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil legsCount:(int)count controllerName:(NSString*)ctrlName {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        legsCount = count;
        [self setUp:count nibName:ctrlName];
        nameOfController = ctrlName;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _carouseView.pagingEnabled=TRUE;
    _carouseView.type = iCarouselTypeLinear;
    _carouseView.clipsToBounds = TRUE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollCarousal:) name:@"TabLegScroll" object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    _carouseView.currentItemIndex = (NSInteger)[LTSingleton getSharedSingletonInstance].legNumber;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setUp:(int)count nibName:(NSString*)name {
    _viewContrllerArray = [NSMutableArray new];
    legsCount = count;
    [[LTSingleton getSharedSingletonInstance].flightReportViewControllersArray removeAllObjects];
    
    int index = [LTSingleton getSharedSingletonInstance].legNumber;
    for (int legIndex = 0; legIndex < count; legIndex++) {
        [LTSingleton getSharedSingletonInstance].legNumber = legIndex;
        _viewController = (CustomViewController*) [[NSClassFromString(name) alloc] initWithNibName:name bundle:nil];
        _viewController.legNumber = legIndex;
        [self addChildViewController:_viewController];
        [_viewContrllerArray addObject:_viewController];
        [LTSingleton getSharedSingletonInstance].legNumber = legIndex;
    }
    
    [LTSingleton getSharedSingletonInstance].flightReportViewControllersArray = [[NSMutableArray alloc] init];
    [LTSingleton getSharedSingletonInstance].flightReportViewControllersArray = _viewContrllerArray;
    [LTSingleton getSharedSingletonInstance].legNumber=index;
}

-(void)scrollCarousal:(NSNotification*)notification {
    
    NSDictionary *dic = notification.userInfo;
    NSInteger index = [[dic objectForKey:@"index"] integerValue];
    [_carouseView scrollToItemAtIndex:index animated:YES];
    DLog(@"%s___ Index %ld ____ Notification %@", __PRETTY_FUNCTION__ , (long)index , notification);
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel {
    return legsCount;
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    CustomViewController *vc = [[self childViewControllers] objectAtIndex:index];
    vc.view.frame = CGRectMake(0, 0, self.carouseView.bounds.size.width, self.carouseView.bounds.size.height);
    vc.tableView.frame = CGRectMake(0, vc.tableView.frame.origin.y, vc.view.frame.size.width, vc.view.frame.size.height - vc.tableView.frame.origin.y);
    
    return vc.view;
}

- (CATransform3D)carousel:(__unused iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.carouseView.itemWidth);
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option) {
        case iCarouselOptionWrap: {
            //normally you would hard-code this to YES or NO
            return FALSE;
        }
        case iCarouselOptionSpacing: {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax: {
            if (self.carouseView.type == iCarouselTypeCustom) {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default: {
            return value;
        }
    }
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    
    return self.carouseView.bounds.size.width;
}

#pragma mark -
#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel {
    NSNotification *notification = [[NSNotification alloc] initWithName:@"ContentScroll" object:nil userInfo:@{@"index":@(self.carouseView.currentItemIndex)}];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
    [self.delegate didScrollToIndex:_carouseView.currentItemIndex withTotalItems:legsCount];
}


@end
