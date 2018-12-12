//
//  UIImagePickerController+Orientation.m
//  LATAM
//
//  Created by bhushan on 30/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "UIImagePickerController+Orientation.h"

@implementation UIImagePickerController (Orientation)

//-(UIImagePickerController *)init{
//    if(!self){
//        self = [[UIImagePickerController alloc]init];
//        //imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    }
//    return self;
//}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}


@end
