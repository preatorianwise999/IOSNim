//
//  ViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/2/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

//
//  ViewController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/29/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "ViewController.h"

#define FormXPos 100

@interface ViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginFormConstraintX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginFormConstraintY;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *greetingLabel1;
@property (weak, nonatomic) IBOutlet UILabel *greetingLabel2;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (nonatomic, strong) NSArray *iataCodes;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.nameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    NSString *appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"v%@ %@", appBuildString, VERSION];
    self.versionLabel.font = KRobotoFontSize16;
    self.versionLabel.textColor = [UIColor whiteColor];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.versionLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetView];
    
    // orientation notifs
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:nil];
    
    // keyboard notifs
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [LTSingleton getSharedSingletonInstance].isLoggingIn = NO;
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.greetingLabel1.text = [appDel copyTextForKey:@"LOGIN_WELCOME"];
    self.greetingLabel2.text = [appDel copyTextForKey:@"LOGIN_PLEASE"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pushLoginForm];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetView {
    self.nameTextField.text = @"";
    self.passwordTextField.text = @"";
    self.loginFormConstraintX.constant = 1024;
    self.loginFormConstraintY.constant = 0;
    [self.view layoutIfNeeded];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((touch.view == self.loginBtn)) {
        return NO;
    }
    return YES;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)changeViewPositionY:(int)newY {
    self.loginFormConstraintY.constant = newY;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)loginBtnPressed:(id)sender {
    
    [self tryToLogIn];
}

- (void)pushLoginForm {
    
    self.loginFormConstraintX.constant = FormXPos;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:nil
     ];
}

#pragma mark Orientation

-(void)orientationChanged:(NSNotification *)notif {
    
    [self updateActivityViewFrame];
}

- (void)updateActivityViewFrame {
    
    if([LTSingleton getSharedSingletonInstance].isLoggingIn) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [[ActivityIndicatorView getSharedActivityIndicatorViewInstance] startActivityInView:self.view WithLabel:[appDel copyTextForKey:@"LOGIN_ACTIVITY"]];
        });
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - TextFields

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [self changeViewPositionY:-200];
    }
    else if (textField == self.passwordTextField) {
        [self changeViewPositionY:-300];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [textField resignFirstResponder];
        [self.view endEditing:YES];
        [self tryToLogIn];
    }
    return YES;
}

#pragma mark - UIKeyboard notifications

- (void)keyboardWillShow:(NSNotification*)notif {
}

- (void)keyboardWillHide:(NSNotification*)notif {
    [self changeViewPositionY:0];
}

-(BOOL)validateFields {
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (![self.nameTextField.text validateNotEmpty]) {
        [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_VALIDATIONERROR"] message:[appDel copyTextForKey:@"ALERT_CANNOTBEEMPTY"]];
        return FALSE;
    } else if(![self.nameTextField.text validateMaximumLength:30]) {
        [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_VALIDATIONERROR"] message:[appDel copyTextForKey:@"USERNAME_30CHAR"]];
        return FALSE;
    } else if (![self.passwordTextField.text validateNotEmpty] && [self.nameTextField.text validateMaximumLength:30]) {
        [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_VALIDATIONERROR"] message:[appDel copyTextForKey:@"ALERT_CANNOTBEEMPTY"]];
        return FALSE;
    } else if(![self.passwordTextField.text validateMaximumLength:30]) {
        [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_VALIDATIONERROR"] message:[appDel copyTextForKey:@"PASSWORD_30CHAR"]];
        return FALSE;
    } else
        return TRUE;
}

-(void)tryToLogIn {
    
    if (![self validateFields]) {
        return;
    }
    
    LTSingleton *singleton = [LTSingleton getSharedSingletonInstance];
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (singleton.isLoggingIn == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ActivityIndicatorView *acview = [ActivityIndicatorView getSharedActivityIndicatorViewInstance];
            [acview startActivityInView:self.view WithLabel:[appDel copyTextForKey:@"LOGIN_ACTIVITY"]];
        });
        
        singleton.username = self.nameTextField.text;
        singleton.password = self.passwordTextField.text;
        SynchronizationController *synch = [[SynchronizationController alloc] init];
        
        synch.delegate = self;
        singleton.isLoggingIn = YES;
        [synch initiateSynchronization];
        
        [self.view endEditing:YES];
    }
}

-(void)synchCompletedWithSuccess {
    
    SynchronizationController *synch = [[SynchronizationController alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ActivityIndicatorView *acview = [ActivityIndicatorView getSharedActivityIndicatorViewInstance];
        [acview stopAnimation];
    });
    
    FlightViewController *flightVC = [[FlightViewController alloc] initWithNibName:@"FlightViewController" bundle:nil];
    flightVC.flightArray = [synch getFlightroaster];
    [self.navigationController pushViewController:flightVC animated:YES];
    
    synch.delegate=nil;
    
    [LTSingleton getSharedSingletonInstance].isLoggingIn = TRUE;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)synchFailedWithError:(enum errorTag)errorTag {
    
    [LTSingleton getSharedSingletonInstance].isLoggingIn = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        ActivityIndicatorView *acview = [ActivityIndicatorView getSharedActivityIndicatorViewInstance];
        [acview stopAnimation];

        AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        switch (errorTag) {
            case kInvalidPassword:
                //            [self.loginIndicator stopAnimating];
                [self.navigationController popToRootViewControllerAnimated:YES];
                //alert for authentication failed
                [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_LOGINFAILED"] message:[appDel copyTextForKey:@"ALERT_INCORRECTPASSWORD"]];
                break;
                
            case kAuthenticationFailed:
                //[self.loginIndicator stopAnimating];
                [self.navigationController popToRootViewControllerAnimated:YES];
                //alert for authentication failed
                [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_LOGINFAILED"] message:[appDel copyTextForKey:@"ALERT_INCORRECTUSRPWD"]];
                break;
            case kReachabilityFailed:
                //[self.loginIndicator stopAnimating];
                //alert for authentication failed
                [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_LOGINFAILED"] message:[appDel copyTextForKey:@"ALERT_UNABLETOAUTHENTICATE"]];
                break;
            case kDifferentUser:
                //[self.loginIndicator stopAnimating];
                //alert for authentication failed
                [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_LOGINFAILED"] message:[appDel copyTextForKey:@"ALERT_UNABLETOAUTHENTICATE"]];
                break;
            case kTimeOut:
                //[self.loginIndicator stopAnimating];
                //alert for timeout
                [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_DATAFAILED"] message:[appDel copyTextForKey:@"ALERT_DATAFAILED_MSG"]];
                break;
            case kAccessForbidden:
                //[self.loginIndicator stopAnimating];
                [self.navigationController popToRootViewControllerAnimated:YES];
                //alert for authentication failed
                [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"ALERT_LOGINFAILED"] message:[appDel copyTextForKey:@"ALERT_ACCESSFORBIDDEN"]];
                break;
            default:
                break;
        }
    });
}

@end