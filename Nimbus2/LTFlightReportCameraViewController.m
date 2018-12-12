//
//  LTFlightReportCameraViewController.m
//  LATAM
//
//  Created by bhushan on 22/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTFlightReportCameraViewController.h"
#import "LTSingleton.h"
#import "TestView.h"
#import "ZKFileArchive.h"
#import "AppDelegate.h"
#import "TestViewCameraViewController.h"

@interface LTFlightReportCameraViewController ()<PopoverDelegate>
{
    NSString *flightName;
    NSString *flightDate;
    __weak IBOutlet UIButton *deleteBtn;
    NSString *currentImageName;
}

@property (weak, nonatomic) IBOutlet UILabel *observationsPhotoTitleLb;
@property (weak, nonatomic) IBOutlet TestView *activeTestView;

@property (nonatomic) TestViewCameraViewController *cameraVC;

@end

@implementation LTFlightReportCameraViewController
@synthesize pickingImage;
@synthesize testViewImage;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.observationsPhotoTitleLb.text = [apDel copyTextForKey:@"FR_TITLE"];
    [deleteBtn setTitle:[apDel copyTextForKey:@"TABLEVIEW_DELETE"] forState:UIControlStateNormal];
     cameraOptionsArray =[[NSArray alloc]initWithObjects:[apDel copyTextForKey:@"TAKE_PHOTO"],[apDel copyTextForKey:@"CHOOSE_EXISTING"], nil];
     flightName=[LTSingleton getSharedSingletonInstance].flightName;
     flightDate=[LTSingleton getSharedSingletonInstance].flightDate;
    
    self.cameraVC = [[TestViewCameraViewController alloc] init];
    self.activeTestView.typeOfDropDown = CameraDropDown;
    self.activeTestView.selectedTextField.hidden = YES;
    self.activeTestView.delegate = self;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (pickingImage) {
        photoImageView.image = pickingImage;
    }
    if (photoImageView.image){
        [captureImageButton setImage:[UIImage imageNamed:@"cameraFill.png"] forState:UIControlStateNormal];
        [captureImageButton setHidden:YES];
        [self.activeTestView setHidden:YES];
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self orientationChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

-(void) orientationChanged{
    [self performSelector:@selector(updatePopupFrame) withObject:nil afterDelay:0.1];
}

- (void)updatePopupFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.activeTestView != nil) {
            UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            [self.activeTestView willRotateToOrientation:toInterfaceOrientation];
        }
    });
}

- (void)presentCameraVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:self.cameraVC animated:YES completion:^{
            AppDelegate *apDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if ([self.cameraVC.selectedOption isEqualToString:[apDelegate copyTextForKey:@"TAKE_PHOTO"]]) {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            }
        }];
    });
}

-(void)valueSelectedInPopover:(TestView *)testView
{
    if (self.activeTestView.typeOfDropDown == CameraDropDownImage) {
        self.cameraVC.selectedOption = self.activeTestView.selectedValue;
        [self.cameraVC setImagePickerProperties];
        self.cameraVC.testView = self.activeTestView;
        self.cameraVC.cameraDelegate = self;
        [self performSelector:@selector(presentCameraVC) withObject:nil afterDelay:0.2];
        return;
    }
}

#pragma mark - Popover Delegate Methods

-(void)imageAfterPicking:(UIImage *)pickedImage {
    [self performSelector:@selector(postOrientationNotification) withObject:nil afterDelay:0.2];
    [self performSelector:@selector(showSelectedImage:) withObject:pickedImage afterDelay:0.4];
}

- (void)postOrientationNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    });
}

- (void)showSelectedImage: (UIImage*)selectedImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUIAfterPickingImage:selectedImage];
        self.cameraVC.testView.typeOfDropDown = CameraDropDown;
    });
}

//flight report camera popover delegate

-(void)updateUIAfterPickingImage:(UIImage *)pickedImage {
    dispatch_async(dispatch_get_main_queue(), ^{

        [self deleteImageFromFolder];
        NSString *randomString = [self generateRandomString];
        NSString *photoName = [flightName stringByAppendingString:randomString];
        NSString *photoName1 = [photoName stringByAppendingString:@".png"];
        NSString *folderPath = [self createImageFolder];
        NSData *pngData = UIImageJPEGRepresentation(pickedImage, 0.4);
        NSString *filePath = [folderPath stringByAppendingPathComponent:photoName1];
        
        //Add the file name
        [pngData writeToFile:filePath atomically:YES];
        if (photoImageView.image) {
            testViewImage.deleteImage=YES;
        }
        deleteBtn.hidden = NO;
        photoImageView.image = pickedImage;
        pickingImage = pickedImage;
        [cameraOptionPopOverController dismissPopoverAnimated:YES];
        [captureImageButton setImage:[UIImage imageNamed:@"cameraFill"] forState:UIControlStateNormal];
        [captureImageButton setHidden:YES];
        [self.activeTestView setHidden:YES];
        testViewImage.imageName=photoName1;
        if([testViewImage.delegate respondsToSelector:@selector(valueSelectedInPopover:)]) {
            [testViewImage.delegate valueSelectedInPopover:testViewImage];
        }
        pngData=nil;

    });
}

-(void)cancelPickingImage {
    pickingImage = nil;
    [self performSelector:@selector(postOrientationNotification) withObject:nil afterDelay:0.2];
    [self.cameraVC dismissViewControllerAnimated:YES completion:^{
        self.cameraVC.testView.typeOfDropDown = CameraDropDown;
    }];
}

-(IBAction)cameraButtonClicked:(id)sender {
    [self.activeTestView dropDownTap:captureImageButton];
}

-(void)showPopOver {
    LTFlightReportCameraPopOverViewController *flightReportCameraPopOverViewController=[[LTFlightReportCameraPopOverViewController alloc] initWithNibName:@"LTFlightReportCameraPopOverViewController" bundle:nil];
    flightReportCameraPopOverViewController.delegate = self;
    flightReportCameraPopOverViewController.popOverDataArray = cameraOptionsArray;
    cameraOptionPopOverController = [[UIPopoverController alloc] initWithContentViewController:flightReportCameraPopOverViewController];
    if(ISiOS8)
        flightReportCameraPopOverViewController.preferredContentSize = CGSizeMake(200, 100);
    else
        cameraOptionPopOverController.popoverContentSize = CGSizeMake(200, 100);

    if (noImage) {
        [cameraOptionPopOverController presentPopoverFromRect:CGRectMake(510, 225, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
    else {
        [cameraOptionPopOverController presentPopoverFromRect:captureImageButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

//create a folder for saving image
-(NSString *)createImageFolder {
      NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/FlightReport"];
    NSString *imageFolderName = [flightName stringByAppendingString:flightDate];
    NSString *insideFolderPath = [dataPath stringByAppendingPathComponent:imageFolderName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    if (![[NSFileManager defaultManager] fileExistsAtPath:insideFolderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:insideFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    if ([LTSingleton getSharedSingletonInstance].isCusCamera) {
        insideFolderPath = [insideFolderPath stringByAppendingString:@"/CUS"];

    }
    
    return insideFolderPath;
}

-(NSString *)generateRandomString {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:3];
    
    for (int i = 0; i < 3; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
}

-(IBAction)deleteButtonClicked:(id)sender{
   
    if (photoImageView) {
         photoImageView.image=nil;

        [self deleteImageFromFolder];
        testViewImage.imageName=@"";
        testViewImage.deleteImage=YES;
        [captureImageButton setImage:[UIImage imageNamed:@"cameraBtn"] forState:UIControlStateNormal];
        [captureImageButton setHidden:NO];
        [self.activeTestView setHidden:NO];
        deleteBtn.hidden = YES;
        if([testViewImage.delegate respondsToSelector:@selector(valueSelectedInPopover:)]){
            [testViewImage.delegate valueSelectedInPopover:testViewImage];
        }
    }

}

//zip a folder present in document directory

-(void)zipFolder{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *zipFilePath =[documentsDirectory stringByAppendingPathComponent:@"FlightReport.zip"];
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"FlightReport"]];
    NSString *imageFolderName=[flightName stringByAppendingString:flightDate];
    NSString *folderPath1 = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",imageFolderName]];
    ZKFileArchive *archive = [ZKFileArchive archiveWithArchivePath:zipFilePath];
    NSInteger result = [archive deflateDirectory:folderPath1 relativeToPath:documentsDirectory usingResourceFork:NO];
    if (result==1) {
        NSLog(@"success");
    }else{
        NSLog(@"fail");
    }
    
    
}

//delete image form flight report folder
-(void)deleteImageFromFolder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imagePath=[self createImageFolder];
    if([testViewImage.imageName isEqualToString:@""])
        return;
    NSString *filePath = [imagePath stringByAppendingPathComponent:testViewImage.imageName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    fileManager=nil;
    if (success) {
        DLog(@"Image deleted");
    }
    else{
         DLog(@"Unable to delete image");
    }
}
-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
       
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
