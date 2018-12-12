//
//  PickerDoneCancelViewController.h
//  LATAM
//
//  Created by vishal on 7/19/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PickerDoneCanelDelegate <NSObject>

- (void)pickerDoneButtonClicked;
- (void)pickerCancelButtonClicked;

@end

@interface PickerDoneCancelViewController : UIViewController{

}
@property (nonatomic,assign)id<PickerDoneCanelDelegate>delgate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *DoneBarButton;
@property (weak, nonatomic) IBOutlet UINavigationItem* navBar;
@property (weak, nonatomic) IBOutlet UILabel* header_lab;
@property (strong, nonatomic) NSString *titleForHeader;

-(IBAction)onClickPickerDone;
-(IBAction)onClickPickerCancel;

@end

