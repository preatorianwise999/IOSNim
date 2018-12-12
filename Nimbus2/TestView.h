//
//  TestView.h
//  customView
//
//  Created by Vishnu on 15/04/14.
//  Copyright (c) 2014 abc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownViewController.h"
#import "PickerDoneCancelViewController.h"
#import "AppDelegate.h"

//#import "LTFlightReportCameraViewController.h"
//#import "LTFlightReportCameraPopOverViewController.h"


@class TestView;
@protocol PopoverDelegate <NSObject>
@optional
-(void)valueSelectedInPopover:(TestView *)testView;
-(void)valueSelectedWhenDismissPopover:(TestView *)testView;
- (void)setActiveTestView:(TestView*)testView;

@end

@interface TestView : UIView<DropSelectionDelegate,UIPopoverControllerDelegate,PickerDoneCanelDelegate,UITextFieldDelegate,UITextViewDelegate>{
    //LTFlightReportCameraProtocol
    UIPopoverController *popoverController;
    UIDatePicker *datePicker;
}
//@property(nonatomic,retain) NSData *imageData;

@property (nonatomic) UIButton *senderButton;
@property(nonatomic,retain) NSString *imageName;
@property(nonatomic,weak) IBOutlet UITextField *selectedTextField;;

@property (weak, nonatomic) IBOutlet UIImageView *accessoryImage;
@property(nonatomic,retain) IBOutlet UIButton *dropDownButton;
- (IBAction)dropDownTap:(UIButton *)sender;
@property(strong,nonatomic) DropDownViewController *dropDownObject;
@property(nonatomic,retain) NSString *selectedValue;
@property(nonatomic,assign) int selectedIndex;

@property(nonatomic,weak) id<PopoverDelegate> delegate;
@property(nonatomic) enum DropDownType typeOfDropDown;
@property(nonatomic,retain) NSArray *dataSource;

//For AlertStyle Popover View
@property(nonatomic,retain) UIView *backgroundView;
@property(nonatomic,retain) UIButton *deleteButton;
@property(nonatomic,retain) UIButton *saveButton;
@property(nonatomic,retain) UILabel *headingLabel;
@property(nonatomic,retain) UITextView *notesView;
@property(nonatomic,retain) NSString *dateHeaderTitle;

//For add Flight controller
@property(nonatomic) BOOL addFlight;

//To Access Value in the different controllers
@property(nonatomic, retain) NSString *key;

//For image delete
@property(nonatomic) BOOL deleteImage;

- (void)willRotateToOrientation:(UIInterfaceOrientation)newOrientation;
-(void)imageAfterPicking:(UIImage *)pickedImage;

@end
