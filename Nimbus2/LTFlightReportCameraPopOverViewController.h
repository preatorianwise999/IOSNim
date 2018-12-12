//
//  LTFlightReportCameraPopOverViewController.h
//  LATAM
//
//  Created by bhushan on 04/06/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImagePickerController+Orientation.h"
#import "UIImage+Resize.h"
@protocol LTFlightReportCameraProtocol<NSObject>
-(void)imageAfterPicking:(UIImage *)pickedImage;
-(void)cancelPickingImage;
@end
@interface LTFlightReportCameraPopOverViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    IBOutlet UITableView *cameraPopOverTableView;
    id<LTFlightReportCameraProtocol>delegate;
    BOOL newMedia;
      BOOL fromGallery;
}
@property(nonatomic,retain)NSArray *popOverDataArray;
@property(nonatomic,retain)id<LTFlightReportCameraProtocol>delegate;
@end
