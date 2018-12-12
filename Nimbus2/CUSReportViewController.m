//
//  CUSReportViewController.m
//  Nimbus2
//
//  Created by Dreamer on 7/30/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "CUSReportViewController.h"
#import "CUSReportTableViewCell.h"
#import "AddRowCell.h"
#import "TextTextTextTextOther.h"
#import "OtherCell.h"
#import "LeftOtherCell.h"
#import "LabelTextCell.h"
#import "AppDelegate.h"
#import "LTCUSDropdownData.h"
#import "LTSingleton.h"
#import "LTCUSCameraViewController.h"
#import "AllDb.h"
#import "LTCUSData.h"
#import "LTAddCustomerViewController.h"
#import "LTSaveFlightData.h"
#import "LTSaveCUSData.h"
#import "SynchronizationController.h"
#import "AppDelegate.h"
#import "TestView.h"

typedef enum {
    
    kSomeMandatoryFieldsEmpty,
    kValid
    
} FormStatus;

@interface CUSReportViewController () {
    
    LTAddCustomerViewController *newcustomer;
    LTDetailCUSReportViewController *detailCusController;
    UIImageView *handImageView;
    Customer *currentCustomer;
    BOOL isFromManual;
    LTCUSCameraViewController *cusCameraViewController;
    UIPopoverController *popoverController;
    
    AppDelegate *appDel;
    
    NSMutableArray *imagesArray;
    NSArray *cameraOptionsArray;
    UIButton *senderButton;
    NSString *flightName;
    NSString *flightDate;
}

@property (weak, nonatomic) IBOutlet UILabel *reportTitleLb;


@end

@implementation CUSReportViewController
@synthesize cusReportImages,delegate;
@synthesize customer;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LTSingleton getSharedSingletonInstance].enableCells = YES;
    self.reportId = self.report.reportId;
    self.cusreportArray = [[NSArray alloc] init];
    
    if (cusReportImages) {
        [LTSingleton getSharedSingletonInstance].cusImages = cusReportImages;
    } else {
        [LTSingleton getSharedSingletonInstance].cusImages = [[CUSReportImages alloc] init];
    }
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.reportTitleLb.text = [appDel copyTextForKey:@"REPORT_CUS_LAN"];
    
    flightName = [LTSingleton getSharedSingletonInstance].flightName;
    flightDate = [LTSingleton getSharedSingletonInstance].flightDate;
    [self.cusotmerReportView.layer setCornerRadius:20.0f];
    _imageView.layer.cornerRadius = 30;
    
    [self initiallizeData];
    
    cameraOptionsArray = [[NSArray alloc]initWithObjects:[appDel copyTextForKey:@"TAKE_PHOTO"],[appDel copyTextForKey:@"CHOOSE_EXISTING"], nil];
    
    self.detailCUSReportViewController = [[LTDetailCUSReportViewController alloc] initWithNibName:@"LTDetailCUSReportViewController" bundle:nil];
    self.detailCUSReportViewController.readonly = self.readonly;
    self.detailCUSReportViewController.flightRoster = self.flightRoster;
    self.detailCUSReportViewController.legsArray = self.legsArray1;
    self.detailCUSReportViewController.customerDict = _customerDict;
    self.detailCUSReportViewController.customer = customer;
    self.detailCUSReportViewController.report=self.report;
    self.detailCUSReportViewController.view.autoresizesSubviews = NO;
    self.detailCUSReportViewController.view.frame = self.detailView.bounds;
    self.detailCUSReportViewController.view.backgroundColor = [UIColor clearColor];
    
    self.detailView.opaque = NO;
    self.detailView.backgroundColor = [UIColor clearColor];
    [self.detailView addSubview:self.detailCUSReportViewController.view];
    
    if(self.readonly) {
        [self.cameraBtn setUserInteractionEnabled:NO];
        self.cameraBtn.enabled = NO;
        self.deleteBtn.enabled = NO;
        self.sendBtn.enabled = NO;
        [self.activeTestView.dropDownButton setUserInteractionEnabled:NO];
    }
    
    [self assignHeaderValues];
    self.cameraVC = [[TestViewCameraViewController alloc] init];
    self.activeTestView.typeOfDropDown = CameraDropDown;
    self.activeTestView.selectedTextField.hidden = YES;
    self.activeTestView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self orientationChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [LTSingleton getSharedSingletonInstance].isCusCamera = NO;
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

-(void)orientationChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        popoverController.popoverContentSize = CGSizeMake(650,650);
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
            self.cusReportTopConstraint.constant=85;
            self.cusReportToLeadingConstraint.constant=15;
            
            self.view.frame=CGRectMake(0, 0,768, 1024);
            
        } else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
            self.view.frame=CGRectMake(0, 0,1024, 768);
            self.cusReportTopConstraint.constant=85;
            self.cusReportToLeadingConstraint.constant=160;
        }
        [self performSelector:@selector(updatePopupFrame) withObject:nil afterDelay:0.1];
    });
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
            AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if ([self.cameraVC.selectedOption isEqualToString:[apDel copyTextForKey:@"TAKE_PHOTO"]]) {
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

#pragma mark --image picking methods
-(void)updateUIAfterPickingImage:(UIImage *)pickedImage{
    
    [popoverController dismissPopoverAnimated:YES];
    NSString *randomString=[self generateRandomString];
    NSString *photoName=[flightName stringByAppendingString:randomString];
    NSString *photoName1=[photoName stringByAppendingString:@".png"];
    NSString *folderPath=[self createImageFolder];
    NSData *pngData = UIImageJPEGRepresentation(pickedImage, 0.4);
    NSString *filePath = [folderPath stringByAppendingPathComponent:photoName1];
    
    [pngData writeToFile:filePath atomically:YES];
    
    CUSReportImages *cusImages = [LTSingleton getSharedSingletonInstance].cusImages;
    
    [cusImages setImage1:photoName1];
    
    if(cusCameraViewController !=nil)
        cusCameraViewController = nil;
    
    cusCameraViewController =[[LTCUSCameraViewController alloc] initWithNibName:@"LTCUSCameraViewController" bundle:nil];
    cusCameraViewController.customerDict = _customerDict;
    //  cusCameraViewController.localMoc = self.localMoc;
    if(popoverController != nil)
        popoverController = nil;
    popoverController =[[UIPopoverController alloc] initWithContentViewController:cusCameraViewController];
    popoverController.delegate = self;
    popoverController.popoverContentSize = CGSizeMake(650, 650);
    
    [popoverController presentPopoverFromRect:self.cameraBtn.frame inView:self.cameraBtn.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    pickedImage = nil;
}

//-(void)cancelPickingImage{
//    [popoverController dismissPopoverAnimated:YES];
//}

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
//        [self.cameraVC.testView imageAfterPicking:selectedImage];
        [self updateUIAfterPickingImage:selectedImage];
        self.cameraVC.testView.typeOfDropDown = CameraDropDown;
    });
}

-(void)cancelPickingImage {
    [self performSelector:@selector(postOrientationNotification) withObject:nil afterDelay:0.2];
    [self.cameraVC dismissViewControllerAnimated:YES completion:^{
        self.cameraVC.testView.typeOfDropDown = CameraDropDown;
    }];
}

-(void)assignHeaderValues {
    NSMutableString *string;
    if([[_customerDict objectForKey:@"SECOND_LAST_NAME"] length]>0)
    {
        string = [NSMutableString stringWithFormat:@"%@ %@",[_customerDict objectForKey:@"LAST_NAME"],[_customerDict objectForKey:@"SECOND_LAST_NAME"]];
    }else {
        string = [NSMutableString stringWithFormat:@"%@",[_customerDict objectForKey:@"LAST_NAME"]];
    }
    
    _nameLabel.text = [NSString stringWithFormat:@"%@, %@",string,[_customerDict objectForKey:@"FIRST_NAME"]];
    
    if ([_customerDict objectForKey:@"DOCUMENT_NUMBER"]) {
        
        NSString *type =    [_customerDict objectForKey:@"DOCUMENT_TYPE"];
        NSString *newtype;
        if ([type containsString:@"||"]) {
            newtype = [type substringFromIndex:[type rangeOfString:@"||"].location + 2];
            _documentTypeLabel.text = [NSString stringWithFormat:@"%@ : %@", newtype, [_customerDict objectForKey:@"DOCUMENT_NUMBER"]];
            
        }
        else
            _documentTypeLabel.text = [NSString stringWithFormat:@"%@ : %@",[_customerDict objectForKey:@"DOCUMENT_TYPE"],[_customerDict objectForKey:@"DOCUMENT_NUMBER"]];
    }
    
    if ([_customerDict objectForKey:@"SEAT_NUMBER"]) {
        
        _seatNumberLabel.text = [NSString stringWithFormat:@"%@",[_customerDict objectForKey:@"SEAT_NUMBER"]];
    }
    if ([_customerDict objectForKey:@"FREQUENTFLYER_CATEGORY"] && [_customerDict objectForKey:@"FREQUENTFLYER_NUMBER"]) {
        _frequentFlyerLabel.text = [NSString stringWithFormat:@"FFP : %@ %@",[_customerDict objectForKey:@"FREQUENTFLYER_CATEGORY"],[_customerDict objectForKey:@"FREQUENTFLYER_NUMBER"]];
    }
    
}
-(void)initiallizeData {
    self.associatedLegArray = [[NSMutableArray alloc] init];
    self.seatManteinanceArray = [[NSMutableArray alloc] init];
    self.actionTakenArray = [[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark --- Button Action Methods

- (IBAction)cancelButtonTapped:(id)sender {
    
    [self willMoveToParentViewController:nil];  // 1
    [self.view removeFromSuperview];            // 2
    [self removeFromParentViewController];
    
    // save data
    
    CUSReportImages *cusImages = [LTSingleton getSharedSingletonInstance].cusImages;
    NSDictionary *cusimagesDict =  cusImages.getDictionaryRepresentation;
    
    [LTSaveCUSData saveCUSReportforFlightLeg:[LTSingleton getSharedSingletonInstance].legNumber forCustomer:_customerDict forCUSImages:cusimagesDict forCUSDict:[LTSingleton getSharedSingletonInstance].flightCUSDict forFlight:[LTSingleton getSharedSingletonInstance].flightRoasterDict hasSeatMap:_doseNotHaveSeatMap forReportid:self.reportId];
    
    if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(finishedSavingCUSReport)]) {
        [self.delegate finishedSavingCUSReport];
    }
}

- (IBAction)cameraButtonTapped:(UIButton*)sender {
    senderButton=sender;
    CUSReportImages *cusImage = [LTSingleton getSharedSingletonInstance].cusImages;
    [LTSingleton getSharedSingletonInstance].isCusCamera = YES;
    if (cusImage.image1 || cusImage.image2 || cusImage.image3 || cusImage.image4 || cusImage.image5) {
        
        if(cusCameraViewController != nil)
            cusCameraViewController = nil;
        cusCameraViewController =[[LTCUSCameraViewController alloc] initWithNibName:@"LTCUSCameraViewController" bundle:nil];
        cusCameraViewController.customerDict = _customerDict;
        if(popoverController != nil)
            popoverController = nil;
        cusCameraViewController.localMoc = self.localMoc;
        popoverController =[[UIPopoverController alloc] initWithContentViewController:cusCameraViewController];
        popoverController.delegate = self;
        popoverController.popoverContentSize = CGSizeMake(650,650);
        
        [popoverController presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    else {
        [self.activeTestView dropDownTap:_cameraBtn];
    }
    
}

- (FormStatus)getFormStatus {
    
    if(![self.detailCUSReportViewController validateMandatoryFields]) {
        return kSomeMandatoryFieldsEmpty;
    }
    
    return kValid;
}

- (IBAction)sendReportButtonTapped:(id)sender {
    
    FormStatus status = [self getFormStatus];
    
    if(status == kSomeMandatoryFieldsEmpty) {
        
        NSString *msg = [appDel copyTextForKey:@"ALERT_MANDATORY_FIELDS"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:[appDel copyTextForKey:@"ALERT_OK"] otherButtonTitles: nil];
        alertView.tag = 10;
        [alertView setDelegate:self];
        [alertView show];
    }
    
    else if(status == kValid) {
        
        NSString *string = [NSString stringWithFormat:@"%@ %@ %@%@", [appDel copyTextForKey:@"CUS_SEND_ALERT1"],[_customerDict objectForKey:@"FIRST_NAME"],[_customerDict objectForKey:@"LAST_NAME"], [appDel copyTextForKey:@"CUS_SEND_ALERT2"]];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:string delegate:self cancelButtonTitle:[appDel copyTextForKey:@"CANCEL"] otherButtonTitles:[appDel copyTextForKey:@"ALERT_OK"], nil];
        alertView.tag = 50;
        [alertView setDelegate:self];
        [alertView show];
    }
}

- (IBAction)deleteButtonTapped:(id)sender {
    NSString *string = [NSString stringWithFormat:@"%@ %@ %@?",[appDel copyTextForKey:@"ALERT_DELETE_CUSTOMER"],[_customerDict objectForKey:@"FIRST_NAME"],[_customerDict objectForKey:@"LAST_NAME"]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:string delegate:self cancelButtonTitle:[appDel copyTextForKey:@"CANCEL"] otherButtonTitles:[appDel copyTextForKey:@"ALERT_OK"], nil];
    alertView.tag = 101;
    [alertView setDelegate:self];
    [alertView show];
}

#pragma mark -- alert view delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 4444) {
        if(buttonIndex == 1) {
            
        }
    }
    else if(alertView.tag == 10) {
        if(buttonIndex == 1) {
            
        }
    } else if(alertView.tag == 50) {
        
        if(buttonIndex == 1) {
            
            CUSReportImages *cusImages = [LTSingleton getSharedSingletonInstance].cusImages;
            
            NSDictionary *cusimagesDict =  cusImages.getDictionaryRepresentation;
            
            int legNo = [LTSingleton getSharedSingletonInstance].legNumber;
            
            NSMutableDictionary *flightRoster =  [LTSingleton getSharedSingletonInstance].flightRoasterDict;
            
            [LTSaveCUSData modifyStatus:draft forCustomer:_customerDict forLeg:legNo forFlight:flightRoster forReportId:self.reportId];
            
            NSString *reportId= [LTSaveCUSData saveCUSReportforFlightLeg:legNo forCustomer:_customerDict forCUSImages:cusimagesDict forCUSDict:[LTSingleton getSharedSingletonInstance].flightCUSDict forFlight:flightRoster hasSeatMap:_doseNotHaveSeatMap forReportid:self.reportId];
            
            self.reportId=reportId;
            
            SynchronizationController *sync = [[SynchronizationController alloc] init];
            
            [LTSaveCUSData modifyStatus:inqueue forCustomer:_customerDict forLeg:legNo forFlight:flightRoster forReportId:reportId];
            
            if([sync checkForInternetAvailability]) {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [sync sendCUSReportforCustomer:_customerDict forFlight:flightRoster forleg:legNo forReportId:reportId fromSync:NO];
                });
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"WARNING"] message:[appDel copyTextForKey:@"SEND_REPORT_OFFLINE_MSG"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
            if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(finishedSavingCUSReport)]) {
                [self.delegate finishedSavingCUSReport];
            }
            
            [self willMoveToParentViewController:nil];  // 1
            [self.view removeFromSuperview];            // 2
            [self removeFromParentViewController];
        }
    }
    
    else if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            
            CATransition *animation = [CATransition animation];
            animation.type = @"suckEffect";
            animation.delegate = self;
            animation.duration = 1.0f;
            animation.timingFunction = UIViewAnimationCurveEaseInOut;
            [self.view.layer addAnimation:animation forKey:@"transitionViewAnimation"];
            
            [self willMoveToParentViewController:nil];  // 1
            [self.view removeFromSuperview];            // 2
            [self removeFromParentViewController];
            
            //   [LTSaveCUSData deleteCustomerFromDict:self.customerDict];
            [LTSaveCUSData deleteReportForCustomerDict:_customerDict forFlightDict:[LTSingleton getSharedSingletonInstance].flightCUSDict forreportId:self.reportId];
            
        } else {
            
        }
    }
    else {
        
        if(buttonIndex == 1){
            CATransition *animation = [CATransition animation];
            animation.type = @"suckEffect";
            animation.delegate = self;
            animation.duration = 1.0f;
            animation.timingFunction = UIViewAnimationCurveEaseInOut;
            [self.view.layer addAnimation:animation forKey:@"transitionViewAnimation"];
            
            [self willMoveToParentViewController:nil];  // 1
            [self.view removeFromSuperview];            // 2
            [self removeFromParentViewController];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    //do what you need to do when animation ends...
    [self.parentViewController.view setUserInteractionEnabled:YES];
    
}

#pragma mark -- supporting methods

//create folder for image storing
-(NSString *)createImageFolder {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
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

-(NSString *)generateRandomString {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:3];
    
    for (int i = 0; i < 3; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
}

-(NSMutableDictionary*)prepareFlightRoasterDictWithFlightIndex:(FlightRoaster*)fRoaster {
    
    NSMutableDictionary *flightRoasterDict = [[NSMutableDictionary alloc]init];
    
    @try {
        NSMutableDictionary *flightKeyDict = [[NSMutableDictionary alloc]init];
        [flightKeyDict setObject:fRoaster.airlineCode forKey:@"airlineCode"];
        [flightKeyDict setObject:fRoaster.flightNumber forKey:@"flightNumber"];
        [flightKeyDict setObject:fRoaster.flightDate forKey:@"flightDate"];
        [flightKeyDict setObject:fRoaster.suffix forKey:@"suffix"];
        [flightKeyDict setObject:fRoaster.flightReport forKey:@"reportId"];
        [flightRoasterDict setObject:fRoaster.materialType forKey:@"material"];
        [flightRoasterDict setObject:fRoaster.materialType forKey:@"material"];
        [flightRoasterDict setObject:fRoaster.businessUnit forKey:@"businessUnit"];
        [flightRoasterDict setObject:fRoaster.isManualyEntered forKey:@"isManualyEntered"];
        [flightRoasterDict setObject:flightKeyDict forKey:@"flightKey"];
        [flightRoasterDict setObject:fRoaster.type forKey:@"flightReportType"];
        [flightRoasterDict setObject:@"1.0" forKey:@"flightReportVersion"];
        
        [LTSingleton getSharedSingletonInstance].flightRoasterDict = flightRoasterDict;
    }
    @catch (NSException *exception) {
        DLog(@"Setting nil : %@",exception.description);
    }
    return flightRoasterDict;
}

@end
