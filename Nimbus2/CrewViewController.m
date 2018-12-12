//
//  CrewViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/14/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "CrewViewController.h"
#import "CrewDataViewController.h"
#import "AppDelegate.h"
#import "LTGetLightData.h"
#import "LTSingleton.h"

@interface CrewViewController (){
    AppDelegate *appDel;
    // NSMutableArray *crewMembersArray;
    NSArray * activeRankArray;
    
}

@end

@implementation CrewViewController


-(void)setUp {
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    legArray =  (NSMutableArray *)[LTGetLightData getFlightLegsForFlightRoaster:[LTSingleton getSharedSingletonInstance].flightRoasterDict];
    for (int i = 0; i < legArray.count; i++) {
        CrewDataViewController *crewdata = [[CrewDataViewController alloc] initWithNibName:@"CrewDataViewController" bundle:nil];
        [self addChildViewController:crewdata];
    }
    //});
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self setUp];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.contentScrollView.pagingEnabled = TRUE;
    self.contentScrollView.type = iCarouselTypeLinear;
    self.contentScrollView.clipsToBounds = TRUE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollCarousal:) name:@"TabLegScroll" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateCurrentViewFrame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)  name:UIApplicationWillChangeStatusBarOrientationNotification  object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification{
    [self performSelector:@selector(updateCurrentViewFrame) withObject:nil afterDelay:0.1];
}

- (void)updateCurrentViewFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.contentScrollView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(void)scrollCarousal:(NSNotification*)notification{
    NSDictionary *dic = notification.userInfo;
    NSInteger index = [[dic objectForKey:@"index"] integerValue];
    [self.contentScrollView scrollToItemAtIndex:index animated:YES];
}


#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel
{
    return legArray.count;
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if ([[self childViewControllers] count] > 0){
        UIViewController *vc = [[self childViewControllers] objectAtIndex:index];
        vc.view.frame = self.view.bounds;
        return vc.view;
    }
    
    return view;
}


- (CATransform3D)carousel:(__unused iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.contentScrollView.itemWidth);
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return FALSE;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (self.contentScrollView.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}

#pragma mark -
#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel {
    NSNotification *notification = [[NSNotification alloc] initWithName:@"ContentScroll" object:nil userInfo:@{@"index":@(self.contentScrollView.currentItemIndex)}];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
    [self orientationChanged:nil];
}



-(NSArray *)getSortedMembersForRank:(NSString *)rank forMembers:(NSArray *)membersArray{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"activeRank == %@",rank];
    NSArray *normalArray = [membersArray filteredArrayUsingPredicate:predicate];
    NSArray *sortedArray = [normalArray sortedArrayUsingComparator:^NSComparisonResult(CrewMembers *first,CrewMembers *second) {
        return [first.lastName compare:second.lastName];
    }];
    
    return sortedArray;
}

@end
