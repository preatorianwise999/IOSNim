//
//  LTFlightReportCameraViewController.h
//  LATAM
//
//  Created by bhushan on 22/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "LTFlightReportCameraPopOverViewController.h"
#import "UIImagePickerController+Orientation.h"

@class TestView;
@interface LTFlightReportCameraViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,LTFlightReportCameraProtocol>{
    IBOutlet UIImageView *photoImageView;
    IBOutlet UIButton *captureImageButton;
    
    NSArray *cameraOptionsArray;
    BOOL newMedia;
    BOOL fromGallery;
    BOOL noImage;
    int imageCount;
  //  NSString *photoName;
     UIPopoverController *cameraOptionPopOverController;
    
    
}
@property(nonatomic,retain)id del;
 @property(nonatomic,retain) TestView *testViewImage;
@property(nonatomic,retain)UIImage *pickingImage;
-(void)showPopOver;
-(IBAction)cameraButtonClicked:(id)sender;
-(IBAction)deleteButtonClicked:(id)sender;

@end
