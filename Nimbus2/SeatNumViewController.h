//
//  SeatNumViewController.h
//  LATAM
//
//  Created by Durga Madamanchi on 5/7/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ComboBoxTextNum;
@class ComboNumTextText;
@class SeatNum;

@protocol SeatNumSelectionDelegates <NSObject>

-(void) seatnumSelectionDone;
-(void) seatnumSelectionCanceled;

@end

@interface SeatNumViewController : UIViewController
@property (nonatomic,strong)NSArray *datasouce;
@property (nonatomic,assign)id<SeatNumSelectionDelegates>delgate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *DoneBarButton;
@property (weak, nonatomic) IBOutlet UINavigationItem* navBar;
@property (nonatomic, strong) id tempCell;

-(IBAction)onclickDone;
-(IBAction)onClickCancel;
@end
