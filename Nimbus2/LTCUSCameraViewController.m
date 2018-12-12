//
//  LTCUSCameraViewController.m
//  LATAM
//
//  Created by bhushan on 16/06/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTCUSCameraViewController.h"
#import "LTSingleton.h"
#import "CUSImages.h"
#import "AppDelegate.h"

@interface LTCUSCameraViewController ()<PopoverDelegate>
{
    NSArray *cameraOptionsArray;
    UIPopoverController *cameraOptionPopOverController;
    NSMutableArray *deletedArray;
    NSMutableArray *deletedButtonIndexArray;
    NSString *flightName;
    NSString *flightDate;
    AppDelegate *apDel;
    
    __weak IBOutlet UIButton *cancelBtn;
    int currentSelectionTag;
}
@end

@implementation LTCUSCameraViewController
@synthesize imagesArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidDisappear:(BOOL)animated{
//    photoImageView = nil;
//    self.captureImageButton= nil;
    
//    photoImage1 = nil;
//    photoImage2 = nil;
//    photoImage3 = nil;
//    photoImage4 = nil;
//    photoImage5 = nil;
    
//    tickImage1 = nil;
//    tickImage2 = nil;
//    tickImage3 = nil;
//    tickImage4 = nil;
//    tickImage5 = nil;
//    
//    deleteButton = nil;
//    previewButton1 = nil;
//    previewButton2 = nil;
//    previewButton3 = nil;
//    previewButton4 = nil;
//    previewButton5 = nil;
//    
//    heading = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[LTSingleton getSharedSingletonInstance].cusImages image1] == nil && [[LTSingleton getSharedSingletonInstance].cusImages image2] == nil && [[LTSingleton getSharedSingletonInstance].cusImages image3] == nil && [[LTSingleton getSharedSingletonInstance].cusImages image4] == nil && [[LTSingleton getSharedSingletonInstance].cusImages image5] == nil)
    {
        deleteButton.enabled = NO;
    }
    else
        deleteButton.enabled = YES;
    apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    cameraOptionsArray =[[NSArray alloc]initWithObjects:[apDel copyTextForKey:@"TAKE_PHOTO"],[apDel copyTextForKey:@"CHOOSE_EXISTING"], nil];
    //    previewButton1.enabled=NO;
    //    previewButton2.enabled=NO;
    //    previewButton3.enabled=NO;
    flightName=[LTSingleton getSharedSingletonInstance].flightName;
    flightDate=[LTSingleton getSharedSingletonInstance].flightDate;
    [self loadSelectButton];
    deletedArray=[[NSMutableArray alloc]init];
    deletedButtonIndexArray=[[NSMutableArray alloc]init];

    heading.text = [apDel copyTextForKey:@"PHOTO"];
    
    CUSReportImages *cusImage = [LTSingleton getSharedSingletonInstance].cusImages;
    NSString *folderPath=[self createImageFolder];
    if (cusImage.image1) {
        
        NSString *concatString=[@"/" stringByAppendingString:[cusImage.image1 lastPathComponent]];
        NSString *imagePath=[folderPath stringByAppendingString:concatString];
        UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
        self.photoImage1.image=imageSelected;
        photoImageView.image=imageSelected;
        [self.captureImageButton setImage:[UIImage imageNamed:@"cam_blue.png"] forState:UIControlStateNormal];
        
    } if (cusImage.image2){
        
        NSString *concatString=[@"/" stringByAppendingString:[cusImage.image2 lastPathComponent]];
        NSString *imagePath=[folderPath stringByAppendingString:concatString];
        UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
        self.photoImage2.image=imageSelected;
    }if (cusImage.image3) {
        
        
        NSString *concatString=[@"/" stringByAppendingString:[cusImage.image3 lastPathComponent]];
        NSString *imagePath=[folderPath stringByAppendingString:concatString];
        UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
        self.photoImage3.image=imageSelected;
    }if (cusImage.image4) {
        
        
        NSString *concatString=[@"/" stringByAppendingString:[cusImage.image4 lastPathComponent]];
        NSString *imagePath=[folderPath stringByAppendingString:concatString];
        UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
        self.photoImage4.image=imageSelected;
    }if (cusImage.image5) {
        
        
        NSString *concatString=[@"/" stringByAppendingString:[cusImage.image5 lastPathComponent]];
        NSString *imagePath=[folderPath stringByAppendingString:concatString];
        UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
        self.photoImage5.image=imageSelected;
    }
    
    [cancelBtn setTitle:[apDel copyTextForKey:@"CANCEL"] forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.
    self.cameraVC = [[TestViewCameraViewController alloc] init];
    self.activeTestView.typeOfDropDown = CameraDropDown;
    self.activeTestView.selectedTextField.hidden = YES;
    self.activeTestView.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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

-(void)cancelPickingImage{
    [self performSelector:@selector(postOrientationNotification) withObject:nil afterDelay:0.2];
    [self.cameraVC dismissViewControllerAnimated:YES completion:^{
        self.cameraVC.testView.typeOfDropDown = CameraDropDown;
    }];
}

-(IBAction)cameraButtonClicked:(id)sender{
    [LTSingleton getSharedSingletonInstance].isCusCamera = YES;

    [self.activeTestView dropDownTap:self.captureImageButton];
}

-(void)showPopOver{
    LTFlightReportCameraPopOverViewController *flightReportCameraPopOverViewController=[[LTFlightReportCameraPopOverViewController alloc] initWithNibName:@"LTFlightReportCameraPopOverViewController" bundle:nil];
    flightReportCameraPopOverViewController.delegate=self;
    flightReportCameraPopOverViewController.popOverDataArray=cameraOptionsArray;
    if(cameraOptionPopOverController!= nil)
    {
        cameraOptionPopOverController = nil;
    }
    cameraOptionPopOverController =[[UIPopoverController alloc] initWithContentViewController:flightReportCameraPopOverViewController];
 
    
    if(ISiOS8){
        flightReportCameraPopOverViewController.preferredContentSize =  CGSizeMake(200, 100);
        
    }
    else{
           cameraOptionPopOverController.popoverContentSize = CGSizeMake(200, 100);
    }
    
    [cameraOptionPopOverController presentPopoverFromRect:self.captureImageButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    
    
}
// create CUS folder in document directory
-(NSString *)createImageFolder{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/CUS"];
    NSString *imageFolderName=[[flightName stringByReplacingOccurrencesOfString:@" " withString:@""] stringByAppendingString:flightDate];
    NSString *insideFolderPath=[dataPath stringByAppendingPathComponent:imageFolderName];
    NSString *documentNumber= [_customerDict objectForKey:@"DOCUMENT_NUMBER"]; //[[LTSingleton getSharedSingletonInstance] currentCustomer].docNumber;
    NSString *imagesFolderPath=[insideFolderPath stringByAppendingPathComponent:documentNumber];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    if (![[NSFileManager defaultManager] fileExistsAtPath:insideFolderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:insideFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagesFolderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    return imagesFolderPath;
}

//generate random string for image name
-(NSString *)generateRandomString
{
    NSString *letters = @"0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:3];
    
    for (int i = 0; i < 3; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
    
}
-(void)loadSelectButton{
    cancelBtn.hidden = YES;
    self.captureImageButton.hidden = NO;
    [deleteButton setTitle:[apDel copyTextForKey:@"SELECT"] forState:UIControlStateNormal];
    deleteButton.tag=0;
    [deleteButton setTitleColor:[UIColor colorWithRed:25.0/255.0 green:146.0/255.0 blue:249.0/255.0 alpha:1.0] forState:UIControlStateNormal];
}
//delegate methods
- (void)removeImageAtTheCurrentSelection
{
    NSString *fileNameToBeDeleted;
    if(currentSelectionTag == 0)
    {
        fileNameToBeDeleted = [[LTSingleton getSharedSingletonInstance].cusImages image1];
        
    }
    else if (currentSelectionTag == 1)
    {
        fileNameToBeDeleted = [[LTSingleton getSharedSingletonInstance].cusImages image2];
    }
    else if (currentSelectionTag == 2)
    {
        fileNameToBeDeleted = [[LTSingleton getSharedSingletonInstance].cusImages image3];
    }
    else if (currentSelectionTag == 3)
    {
        fileNameToBeDeleted = [[LTSingleton getSharedSingletonInstance].cusImages image4];
    }
    else if (currentSelectionTag == 4)
    {
        fileNameToBeDeleted = [[LTSingleton getSharedSingletonInstance].cusImages image5];
    }
    
    NSString *filePath = [[self createImageFolder] stringByAppendingPathComponent:fileNameToBeDeleted];
    [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
}
-(void)updateUIAfterPickingImage:(UIImage *)pickedImage{
    [cameraOptionPopOverController dismissPopoverAnimated:YES];
    photoImageView.image=pickedImage;
    [self.captureImageButton setImage:[UIImage imageNamed:@"cam_blue.png"] forState:UIControlStateNormal];
    
    
    [self loadSelectButton];
    NSString *randomString=[self generateRandomString];
    NSString *photoName=[flightName stringByAppendingString:randomString];
    NSString *photoName1=[photoName stringByAppendingString:@".png"];
    NSString *folderPath=[self createImageFolder];
    NSData *pngData = UIImageJPEGRepresentation(pickedImage, 0.4);
    CUSReportImages *cusImages = [LTSingleton getSharedSingletonInstance].cusImages;
  /*  bool isFirstTime = NO;
    if(nil == cusImages){
        cusImages = [NSEntityDescription insertNewObjectForEntityForName:@"CUSImages" inManagedObjectContext:self.localMoc];
        isFirstTime = YES;
    }*/
    NSString *filePath = [folderPath stringByAppendingPathComponent:photoName1];
    //    NSArray *docPathArray =[filePath componentsSeparatedByString:@"/"];
    //    int count=[docPathArray count];
    //    NSString *imagePathString=[NSString stringWithFormat:@"%@/%@/%@/%@",[docPathArray objectAtIndex:count-4 ],[docPathArray objectAtIndex:count-3 ],[docPathArray objectAtIndex:count-2 ],[docPathArray objectAtIndex:count-1 ]];
    
    if (self.photoImage1.image==nil) {
        self.photoImage1.image=pickedImage;
        
        [cusImages setImage1:photoName1];
    }
    else if (self.photoImage2.image==nil){
        self.photoImage2.image=pickedImage;
        
        [cusImages setImage2:photoName1];
        
    }
    else if (self.photoImage3.image==nil ){
        self.photoImage3.image=pickedImage;
        
        [cusImages setImage3:photoName1];
    }
    else if (self.photoImage4.image==nil ){
        self.photoImage4.image=pickedImage;
        
        [cusImages setImage4:photoName1];
    }else if (self.photoImage5.image==nil ){
        self.photoImage5.image=pickedImage;
        
        [cusImages setImage5:photoName1];
    }
    else
    {
        [self removeImageAtTheCurrentSelection];
        if(currentSelectionTag == 0)
        {
            self.photoImage1.image=pickedImage;
            
            [cusImages setImage1:photoName1];
        }
        else if(currentSelectionTag == 1)
        {
            self.photoImage2.image=pickedImage;
            
            [cusImages setImage2:photoName1];
        }
        else if(currentSelectionTag == 2)
        {
            self.photoImage3.image=pickedImage;
            
            [cusImages setImage3:photoName1];
        }
        else if(currentSelectionTag == 3)
        {
            self.photoImage4.image=pickedImage;
            
            [cusImages setImage4:photoName1];
        }
        else if(currentSelectionTag == 4)
        {
            self.photoImage5.image=pickedImage;
            
            [cusImages setImage5:photoName1];
        }
        
    }
    [pngData writeToFile:filePath atomically:YES];
    deleteButton.enabled = YES;
 /*   if(isFirstTime){
        [LTSingleton getSharedSingletonInstance].cusImages= cusImages;
    } */
    NSError *error = nil;
    photoName1=nil;
    pngData=nil;
    pickedImage = nil;
 /*   if(![self.localMoc save:&error]){
        DLog(@"Failed to save cusImages");
    }*/
    
    
}


-(IBAction)photoImageButtonClicked:(UIButton *)sender{
    
    currentSelectionTag = sender.tag;
    NSString *imageName ;
    // LTAppDelegate *apDel = (LTAppDelegate *)[UIApplication sharedApplication].delegate;
    CUSImages *cusImage = [LTSingleton getSharedSingletonInstance].cusImages;
    //    [deleteButton setTitle:[apDel copyTextForKey:@"TABLEVIEW_DELETE"] forState:UIControlStateNormal];
    //    [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    //    deleteButton.tag=1;
    
    switch (sender.tag) {
        case 0:
            imageName = [cusImage.image1 lastPathComponent];
            break;
        case 1:
            imageName = [cusImage.image2 lastPathComponent];
            break;
        case 2:
            imageName = [cusImage.image3 lastPathComponent];
            break;
        case 3:
            imageName = [cusImage.image4 lastPathComponent];
            break;
        case 4:
            imageName = [cusImage.image5 lastPathComponent];
            break;
        default:
            break;
    }
    NSString *folderPath=[self createImageFolder];
    
    if([deleteButton.titleLabel.text isEqualToString:[apDel copyTextForKey:@"SELECT"]])
    {
        if(imageName == nil)
        {
            photoImageView.image = [UIImage imageNamed:@"img_cam.png"];
        }
        else
        {
            if (sender.tag==0) {
                NSString *concatString=[@"/" stringByAppendingString:imageName];
                NSString *imagePath=[folderPath stringByAppendingString:concatString];
                UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
                if (imageSelected) {
                    photoImageView.image=imageSelected;
                }
                
            }
            else if (sender.tag==1){
                NSString *concatString=[@"/" stringByAppendingString:imageName];
                NSString *imagePath=[folderPath stringByAppendingString:concatString];
                UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
                if (imageSelected) {
                    photoImageView.image=imageSelected;
                }
                
            }
            else if (sender.tag==2){
                NSString *concatString=[@"/" stringByAppendingString:imageName];
                NSString *imagePath=[folderPath stringByAppendingString:concatString];
                UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
                if (imageSelected) {
                    photoImageView.image=imageSelected;
                }
            }
            else if (sender.tag==3){
                NSString *concatString=[@"/" stringByAppendingString:imageName];
                NSString *imagePath=[folderPath stringByAppendingString:concatString];
                UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
                if (imageSelected) {
                    photoImageView.image=imageSelected;
                }
            }
            else if (sender.tag==4){
                NSString *concatString=[@"/" stringByAppendingString:imageName];
                NSString *imagePath=[folderPath stringByAppendingString:concatString];
                UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
                if (imageSelected) {
                    photoImageView.image=imageSelected;
                }
            }
        }
        
    }
    else
    {
        if ([deletedArray containsObject:imageName]) {
            int i=[deletedArray indexOfObject:imageName];
            DLog(@"%d",i);
            [deletedArray removeObjectAtIndex:i];
            [deletedButtonIndexArray removeObjectAtIndex:i];
            if (sender.tag==0) {
                tickImage1.image=nil;
            }else if (sender.tag==1){
                tickImage2.image=nil;
            }else if (sender.tag==2){
                tickImage3.image=nil;
            }else if (sender.tag==3){
                tickImage4.image=nil;
            }else if (sender.tag==4){
                tickImage5.image=nil;
            }
        }
        else if (imageName){
            
            [deletedArray addObject:imageName];
            NSString *btnTag=[NSString stringWithFormat:@"%d",sender.tag];
            [deletedButtonIndexArray addObject:btnTag];
            if (sender.tag==0) {
                NSString *concatString=[@"/" stringByAppendingString:imageName];
                NSString *imagePath=[folderPath stringByAppendingString:concatString];
                UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
                if (imageSelected) {
                    tickImage1.image=[UIImage imageNamed:@"tick_.png"];
                    // deleteButton.tag=0;
                    photoImageView.image=imageSelected;
                }
                
            }
            else if (sender.tag==1){
                NSString *concatString=[@"/" stringByAppendingString:imageName];
                NSString *imagePath=[folderPath stringByAppendingString:concatString];
                UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
                if (imageSelected) {
                    tickImage2.image=[UIImage imageNamed:@"tick_.png"];
                    // deleteButton.tag=1;
                    photoImageView.image=imageSelected;
                }
                
            }
            else if (sender.tag==2){
                NSString *concatString=[@"/" stringByAppendingString:imageName];
                NSString *imagePath=[folderPath stringByAppendingString:concatString];
                UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
                if (imageSelected) {
                    tickImage3.image=[UIImage imageNamed:@"tick_.png"];
                    //deleteButton.tag=2;
                    photoImageView.image=imageSelected;
                }
            }
            else if (sender.tag==3){
                NSString *concatString=[@"/" stringByAppendingString:imageName];
                NSString *imagePath=[folderPath stringByAppendingString:concatString];
                UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
                if (imageSelected) {
                    tickImage4.image=[UIImage imageNamed:@"tick_.png"];
                    //deleteButton.tag=2;
                    photoImageView.image=imageSelected;
                }
            }
            else if (sender.tag==4){
                NSString *concatString=[@"/" stringByAppendingString:imageName];
                NSString *imagePath=[folderPath stringByAppendingString:concatString];
                UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
                if (imageSelected) {
                    tickImage5.image=[UIImage imageNamed:@"tick_.png"];
                    //deleteButton.tag=2;
                    photoImageView.image=imageSelected;
                }
            }
            
        }
        else
        {
            photoImageView.image = [UIImage imageNamed:@"img_cam.png"];
        }
        
    }
    
    
}

-(IBAction)cancelButtonClicked:(UIButton *)sender
{
    [deleteButton setTitle:[apDel copyTextForKey:@"SELECT"] forState:UIControlStateNormal];
    //[deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor colorWithRed:25.0/255.0 green:146.0/255.0 blue:249.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    cancelBtn.hidden = YES;
    self.captureImageButton.hidden = NO;
    
    [deletedArray removeAllObjects];
    [deletedButtonIndexArray removeAllObjects];
    
    tickImage1.image=nil;
    tickImage2.image=nil;
    tickImage3.image=nil;
    tickImage4.image=nil;
    tickImage5.image=nil;

    
    
}
-(IBAction)deleteButtonClicked:(UIButton *)sender{
    if([sender.titleLabel.text isEqualToString:[apDel copyTextForKey:@"SELECT"]])
    {
        [deleteButton setTitle:[apDel copyTextForKey:@"TABLEVIEW_DELETE"] forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        deleteButton.tag=1;
        
        cancelBtn.hidden = NO;
        self.captureImageButton.hidden = YES;
        return;
    }
    CUSImages *cusImage = [LTSingleton getSharedSingletonInstance].cusImages;
    if (sender.tag==0) {
        if ([deletedArray containsObject:cusImage.image1]) {
            int i=[deletedArray indexOfObject:cusImage.image1];
            [deletedArray removeObjectAtIndex:i];
        }else{
            [deletedArray addObject:cusImage.image1];
            NSString *btnTag=[NSString stringWithFormat:@"%d",sender.tag];
            [deletedButtonIndexArray addObject:btnTag];
        }
        //        previewButton1.enabled=YES;
        //        previewButton2.enabled=YES;
        //        previewButton3.enabled=YES;
        //LTAppDelegate *apDel = (LTAppDelegate *)[UIApplication sharedApplication].delegate;
        
        
        [deleteButton setTitle:[apDel copyTextForKey:@"TABLEVIEW_DELETE"] forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        deleteButton.tag=1;
        NSString *folderPath=[self createImageFolder];
        NSString *concatString=[@"/" stringByAppendingString:cusImage.image1];
        NSString *imagePath=[folderPath stringByAppendingString:concatString];
        UIImage *imageSelected=[ UIImage imageWithContentsOfFile:imagePath];
        if (imageSelected) {
            tickImage1.image=[UIImage imageNamed:@"tick_.png"];
            //deleteButton.tag=0;
            photoImageView.image=imageSelected;
        }
        imageSelected = nil;
        
    }else if ([deletedArray count]==0){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[apDel copyTextForKey:@"NO_IMAGE_TODELETE"] delegate:self cancelButtonTitle:[apDel copyTextForKey:@"CANCEL"] otherButtonTitles:[apDel copyTextForKey:@"OK"], nil];
        [alert show];
//        if ([AlertUtils checkAlertExist]) {
//            [alert show];
//        }
    }
    
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[apDel copyTextForKey:@"DELETE_IMAGE"] delegate:self cancelButtonTitle:[apDel copyTextForKey:@"CANCEL"] otherButtonTitles:[apDel copyTextForKey:@"OK"], nil];
        [alert show];
//        if ([AlertUtils checkAlertExist]) {
//            [alert show];
//        }
    }
    
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    CUSImages *cusImage = [LTSingleton getSharedSingletonInstance].cusImages;
    if (buttonIndex==1) {
        
        for (int i=0; i<[deletedArray count]; i++) {
            if ([deletedButtonIndexArray count]>0) {
                photoImageView.image=[UIImage imageNamed:@"img_cam.png"];
                
                int j=[[deletedButtonIndexArray objectAtIndex:i]intValue];
                if (j==0) {
                    tickImage1.image=nil;
                    self.photoImage1.image=nil;
                    cusImage.image1=nil;
                }else if (j==1){
                    tickImage2.image=nil;
                    self.photoImage2.image=nil;
                    cusImage.image2=nil;
                }else if (j==2){
                    tickImage3.image=nil;
                    self.photoImage3.image=nil;
                    cusImage.image3=nil;
                }else if (j==3){
                    tickImage4.image=nil;
                    self.photoImage4.image=nil;
                    cusImage.image4=nil;
                }else if (j==4){
                    tickImage5.image=nil;
                    self.photoImage5.image=nil;
                    cusImage.image5=nil;
                }
                
            }
            
            
            [self deleteImageFromFolder:[deletedArray objectAtIndex:i]];
            
            
        }
        [deletedArray removeAllObjects];
        [deletedButtonIndexArray removeAllObjects];
        if([[LTSingleton getSharedSingletonInstance].cusImages image1] == nil && [[LTSingleton getSharedSingletonInstance].cusImages image2] == nil && [[LTSingleton getSharedSingletonInstance].cusImages image3] == nil && [[LTSingleton getSharedSingletonInstance].cusImages image4] == nil && [[LTSingleton getSharedSingletonInstance].cusImages image5] == nil)
        {
            [self loadSelectButton];
            deleteButton.enabled = NO;
        }
    }
}
//delete image form flight report folder
-(void)deleteImageFromFolder:(NSString *)imageName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imagePath=[self createImageFolder];
    NSString *filePath = [imagePath stringByAppendingPathComponent:imageName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        DLog(@"Image deleted");
    }
    else{
        DLog(@"Unable to delete image");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [deletedArray removeAllObjects];
    // Dispose of any resources that can be recreated.
}

@end
