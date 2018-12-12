//
//  TestViewCameraViewController.m
//  Nimbus2
//
//  Created by Vishal on 12/31/15.
//  Copyright © 2015 TCS. All rights reserved.
//

#import "TestViewCameraViewController.h"
#import "AppDelegate.h"

@interface TestViewCameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation TestViewCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)setImagePickerProperties {
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([_selectedOption isEqualToString:[apDel copyTextForKey:@"TAKE_PHOTO"]]) {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera])
        {
            self.delegate = self;
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.mediaTypes = [NSArray arrayWithObjects:
                               (NSString *) kUTTypeImage,
                               nil];
            self.allowsEditing = NO;
            newMedia = YES;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Cemera Doesn't open"
                                  message: @"Device does not support camera"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
        }
    }
    else{
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            fromGallery=YES;
            self.delegate = self;
            self.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            self.mediaTypes = [NSArray arrayWithObjects:
                               (NSString *) kUTTypeImage,
                               nil];
            self.allowsEditing = NO;
            newMedia = YES;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @" Doesn't open"
                                  message: @"Device does not open Gallery"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(!ISiOS8)
        [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *originalImage = [info
                                  objectForKey:UIImagePickerControllerOriginalImage];
        
        
        CGFloat height = 480.0f;  // or whatever you need
        CGFloat width = (height / originalImage.size.height) * originalImage.size.width;
        
        // Resize the image
        UIImage * image = [originalImage resizedImage:CGSizeMake(width, height) interpolationQuality:kCGInterpolationDefault];
        
        if ([_cameraDelegate respondsToSelector:@selector(imageAfterPicking:)]) {
            [_cameraDelegate imageAfterPicking:image];
        }
        
        if (!fromGallery) {
            if (newMedia)
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               @selector(image:finishedSavingWithError:contextInfo:),
                                               nil);
            
            
            
        }
        originalImage = nil;
        image = nil;
        picker=nil;
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
    
    if(ISiOS8)
        [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: [apDel copyTextForKey:@"SAVE_FAILED"]
                              message: [apDel copyTextForKey:@"ALERT_SAVEFAILED_PHOTOS"]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if ([_cameraDelegate respondsToSelector:@selector(cancelPickingImage)]) {
        [_cameraDelegate cancelPickingImage];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    img = nil;
    return newImage;
}

@end
