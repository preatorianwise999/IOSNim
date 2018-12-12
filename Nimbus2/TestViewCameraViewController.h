//
//  TestViewCameraViewController.h
//  Nimbus2
//
//  Created by Vishal on 12/31/15.
//  Copyright © 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImagePickerController+Orientation.h"
#import "UIImage+Resize.h"
#import "TestView.h"

@protocol TestViewCameraProtocol<NSObject>
-(void)imageAfterPicking:(UIImage *)pickedImage;
-(void)cancelPickingImage;
@end

@interface TestViewCameraViewController : UIImagePickerController {
    BOOL newMedia;
    BOOL fromGallery;
}

@property (nonatomic) NSString *selectedOption;
@property (nonatomic) TestView *testView;
@property (nonatomic) id cameraDelegate;

- (void)setImagePickerProperties;


@end
