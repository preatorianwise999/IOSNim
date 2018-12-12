//
//  SynchStatusViewController.m
//  Nimbus2
//
//  Created by 720368 on 9/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//
#import "SynchronizationController.h"
#import "SynchStatusViewController.h"
#import "TableViewCell.h"
#import "AppDelegate.h"
#import "LTCUSData.h"
/* AppDelegate object */
//#define APP_DELEGATE1 ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@interface SynchStatusViewController (){

}

@property (weak, nonatomic) IBOutlet UILabel *noInfoLb;
@property (nonatomic) BOOL animating;
@property (nonatomic) BOOL isActive;
@property (weak) UIButton *addbtnFlightInform;
@property (weak) UIButton *btnCusTemporal;
@property (weak) UIButton *addbtnCustemp;
//@property (nullable, nonatomic, retain) NSString *imageLoadUrl;
//@property (nullable, nonatomic, retain) NSString *reportId;

@end

@implementation SynchStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.statArray = [UserInformationParser getStatusForAllFlights];
    
    if (self.isSingleFlight) {
        NSDictionary *flightKey = [[LTSingleton getSharedSingletonInstance].flightKeyDict objectForKey:@"flightKey"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"airlineCode == %@ AND flightDate==%@ AND flightNumber==%@", [flightKey objectForKey:@"airlineCode"], [flightKey objectForKey:@"flightDate"], [flightKey objectForKey:@"flightNumber"]];
        self.statArray = [[self.statArray filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    
    for(NSDictionary *flightDict in self.statArray) {
        
        for(NSDictionary *cusReportDict in flightDict[@"CUS"]) {
            int status = [[cusReportDict objectForKey:@"status"] intValue];
            NSLog(@"[CUS STATUS] %d", status);
        }
    }
    
    [self.statusTableView.layer setCornerRadius:20.0];
    
    if ([self.statArray count] == 0) {
        
        AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.statusTableView.hidden = YES;
        self.view.hidden = YES;
        [self closeBtnTapped:nil];
        [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"WARNING"] message:[appDel copyTextForKey:@"STATUS_NO_INFO"]];
        
        [self removeFromParentViewController];
    }
    //[self SearchInternerConnection];
    
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];  
}
-(void)SearchInternerConnection{

    NSString *remoteHostName = URI;
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];

}


-(BOOL)isNetworkAvailable
{
    CFNetDiagnosticRef dReference;
    dReference = CFNetDiagnosticCreateWithURL (NULL, (__bridge CFURLRef)[NSURL URLWithString:URI]);
    
    CFNetDiagnosticStatus status;
    status = CFNetDiagnosticCopyNetworkStatusPassively (dReference, NULL);
    
    CFRelease (dReference);
    
    if ( status == kCFNetDiagnosticConnectionUp )
    {
        NSLog (@"Connection is Available");
        return YES;
    }
    else
    {
        NSLog (@"Connection is down");
        return NO;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.statArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[[self.statArray objectAtIndex:section] objectForKey:@"flightStatus"] integerValue] > 0) {
        return ([[[self.statArray objectAtIndex:section] objectForKey:@"GAD"] count]+[[[self.statArray objectAtIndex:section] objectForKey:@"CUS"] count])+1;
    }
    return ([[[self.statArray objectAtIndex:section] objectForKey:@"GAD"] count]+[[[self.statArray objectAtIndex:section] objectForKey:@"CUS"] count]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 57.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
        UIView *view1  = [[[NSBundle mainBundle]loadNibNamed:@"StatusHeaderView"owner:self options:nil]lastObject];
        UILabel *label = (UILabel*)[view1 viewWithTag:104];
        NSDictionary *flightDict = [self.statArray objectAtIndex:section];
        NSDate *fdate = [flightDict objectForKey:@"flightDate"];
        
        NSString *date = [fdate dateFormat:DATE_FORMAT_EEE_DD_MMM];
        label.text=[NSString stringWithFormat:@"%@ %@ - %@",[flightDict objectForKey:@"airlineCode"],[flightDict objectForKey:@"flightNumber"],date];
        return view1;
}
- (void) spinWithOptionsCus: (UIViewAnimationOptions) options{
    // this spin completes 360 degrees every 2 seconds
    UIButton *button =_btnCusTemporal;
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                            button.frame = CGRectMake(550, 15.0f, 31, 31);
                            [button setBackgroundImage:[UIImage imageNamed:@"N__0001_process.png"]
                             
                                              forState:UIControlStateNormal];
                         [button setTitle:@"" forState:UIControlStateNormal];
                         button.transform = CGAffineTransformRotate(button.transform, -M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (self.animating) {
                             // if flag still set, keep spinning with constant speed
                             [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                         } else if (options != UIViewAnimationOptionCurveEaseOut) {
                             // one last spin, with deceleration
                             [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                         }
                     }];
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    UIButton *buttonCusTempo;
     [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                          buttonCusTempo.frame = CGRectMake(450, 15.0f, 31, 31);
                         [buttonCusTempo setBackgroundImage:[UIImage imageNamed:@"N__0003_sync.png"] forState:UIControlStateNormal];
                         [buttonCusTempo setTitle:@"" forState:UIControlStateNormal];
                          buttonCusTempo.transform = CGAffineTransformRotate(buttonCusTempo.transform, -M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (self.animating) {
                             // if flag still set, keep spinning with constant speed
                             [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                         } else if (options != UIViewAnimationOptionCurveEaseOut) {
                             // one last spin, with deceleration
                             [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                         }
                     }];
}

- (void)stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    self.animating = NO;
    //SynchStatusViewController *synchStatus = [[SynchStatusViewController alloc] init];
   [self.delegate closePopOverforObject:self];
    
}
- (void)startSpinCus{
    //if (self.isActive)
    //{
        if (!self.animating)
        {
            self.animating = YES;
            [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
        }
   // }
}
- (void)startSpin {
    if (self.isActive)
    { 
        if (!self.animating)
        {
            self.animating = YES;
            [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
        }
    }
}
- (void)startSpinProcess {
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"INFORMATION_MESSAGE"]
                                                    message: [appDel copyTextForKey:@"INFORMATION_LOADING"]
                                                   delegate:self
                                          cancelButtonTitle:[appDel copyTextForKey:@"INFORMATION_AGREE"] otherButtonTitles: nil];
    [alert show];

}


-(int)syncCountAllGadReportsNotSent
{
    NSInteger intcount;
    return intcount;
}
-(int)syncCountAllGadReportsSent
{
    NSInteger intcount;
    return intcount;
}

-(BOOL) checkForInternetAvailabilityItems {
    //    return NO;
    Reachability *reachabilityObject=[Reachability reachabilityWithHostName:HOSTNAME];
    NetworkStatus netStatus = [reachabilityObject currentReachabilityStatus];
    DLog(@"######--------------------checkForInternetAvailability %ld",(long)netStatus);
    if (netStatus==NotReachable) {
        return NO;
    }
    else {
        return YES;
    }
}
-(BOOL) checkForInternetAvailability {
    
    Reachability *reachabilityObject=[Reachability reachabilityWithHostName:HOSTNAME];
    //Reachability *reachabilityObject=[Reachability reachabilityWithHostName:[[[self getHost] componentsSeparatedByString:@":"] firstObject]];
    NetworkStatus netStatus = [reachabilityObject currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        return NO;
    }
    else {
        return YES;
    }
}

-(void)SendIndividualInformFlightProcessByID:(NSString*)dateflight:(NSString*)idFlight{
    SynchronizationController *synch = [[SynchronizationController alloc] init];
    synch.delegate = self;
    NSArray *FlightArraybyId = [LTGetLightData getFlightsByIDFlight:(NSString*)idFlight];
    if([FlightArraybyId count] > 0)
    {
        [LTSingleton getSharedSingletonInstance].synchStatus = YES;
        [self startSpin];
        @try
        {
            [self synchCreateFlightForStatusTemporal:(NSString*)dateflight:(NSString*)idFlight:inqueue Oncomplete:^{
               // [synch synchCheckStatusOncompleteByIfFlight:(NSString*)idFlight :^{
                  //  [[NSNotificationCenter defaultCenter] postNotificationName:kNotifSyncFinished object:nil];
               // }];
            }];
        }
        @catch (NSException * e) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(550,15.0f                                                                                                , 31, 31)];
            [imageView setImage:[UIImage imageNamed:@"ic_modal_dash_04_error.png"]];
            [self.view addSubview: imageView];
        }
        @finally {
            [self stopSpin];
        }
    } else {
        [self stopSpin];
    }
    
}

-(void)SendIndividualCUSProcessByID:(NSString*)idFlight:(NSString*)idReport:(NSString*)idCustumer:(NSString*)dateflight{
    SynchronizationController *synch = [[SynchronizationController alloc] init];
    synch.delegate = self;
    NSArray *FlightArraybyId = [LTGetLightData getFlightsByIDFlight:(NSString*)idFlight];
    if([FlightArraybyId count] > 0)
    {
        [LTSingleton getSharedSingletonInstance].synchStatus = YES;
       [self startSpin];
        @try
        {
            [synch syncCusReportWithCompletionHandlerByIdflight:(NSString*)dateflight:(NSString*)idFlight:(NSString*)idReport:(NSString*)idCustumer:^{
                //[synch synchCheckStatusOncompleteByIfFlight:(NSString*)idFlight :^{
//                [synch synchCheckStatusOncomplete:^{
//                    
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifSyncFinished object:nil];
//                }];
            }];
            
        }
        @catch (NSException * e) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(550,15.0f                                                                                                , 31, 31)];
            [imageView setImage:[UIImage imageNamed:@"ic_modal_dash_04_error.png"]];
            [self.view addSubview: imageView];
        }
        @finally {
            [self stopSpin];
        }
    }else{
        [self stopSpin];
    }
}
-(void)synchCreateFlightForStatusTemporal:(NSString*)dateflight:(NSString*)idFlight:(STATUS)stat Oncomplete:(void (^)(void))onComplete
{
    SynchronizationController *synch = [[SynchronizationController alloc] init];
    synch.delegate = self;
        NSMutableArray *arra = [LTCreateFlightReport createFlightReportForAllFlightsForStatus:stat];
        for (NSMutableDictionary *flightDict in arra) {
            if([[[flightDict objectForKey:@"flightKey"] objectForKey:@"flightNumber"] isEqualToString:(NSString *)idFlight])
            {
                NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
                [dateFormate setDateFormat:@"YYYY-MM-dd"];
                NSString *flightDateStr = [dateFormate stringFromDate:[[flightDict objectForKey:@"flightKey"] objectForKey:@"flightDate"]];
                
                if([ flightDateStr isEqualToString:(NSString *)dateflight])
                {
                   [synch syncFlightReportForFlightDict:flightDict];
                   [synch gadCheckStatusReport:flightDict];
                }
            }
        }
        onComplete();
}

-(void)SendIndividualGadProcessByID:(NSString*)dateflight:(NSString*)idFlight:(NSString*)idGAD{
    SynchronizationController *synch = [[SynchronizationController alloc] init];
    synch.delegate = self;
    NSArray *FlightArraybyId = [LTGetLightData getFlightsByIDFlight:(NSString*)idFlight];
    if([FlightArraybyId count] > 0) {
        [LTSingleton getSharedSingletonInstance].synchStatus = YES;
           [self startSpin];
        @try {
                         [synch syncAllGadReportsOncompleteByIdFlight:(NSString*)dateflight:(NSString*)idGAD:(NSString*)idFlight :^{
                           // [self synchCreateFlightForStatusTemporal:(NSString*)idFlight:inqueue Oncomplete:^{
                                //[synch syncCusReportWithCompletionHandler:^{
                                    //[synch synchCheckStatusOncomplete:^{
//                                    [synch synchCheckStatusOncompleteByIfFlight:(NSString*)idFlight :^{
//                                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifSyncFinished object:nil];
//                                    }];
                                //}];
                           // }];
                        }];
        }
        @catch (NSException * e) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(550,15.0f                                                                                                , 31, 31)];
            [imageView setImage:[UIImage imageNamed:@"ic_modal_dash_04_error.png"]];
            [self.view addSubview: imageView];
        }
        @finally {
           [self stopSpin];
        }
    } else {
       [self stopSpin];
    }
}
- (IBAction)addBtnInformFlight:(id)sender
{
    
    @try {
        UIButton *btn= (UIButton *)sender;
        NSString *data =  (@"%@",btn.accessibilityLabel);
        
        NSArray* dateArray = [data componentsSeparatedByString: @","];
        _idflightTemp = [dateArray objectAtIndex: 0];
        _dateReportFlight = [dateArray objectAtIndex: 1];
    }
    @catch (NSException *exception) {
        DLog(@"exception handled==%@",exception.description);
    }
    
    bool existeConexion=false;
    if([self isNetworkAvailable]==true)
    {
        _isCUSReportToSend=false;
        _isGADReportToSend=false;
        _isFlightReportToSend=TRUE;
        //[self disableButtonGAD:_NameBottonFlight];
        [self ConfirmationFlightReportSend];
        
  
    }else{
        
        existeConexion=false;
        [self MessageAlertOffline];
      
    }
}
- (IBAction)addFriend:(id)sender
{
    UIButton *btn= (UIButton *)sender;
    _idReportGAD =  btn.accessibilityLabel;
    
    _isCUSReportToSend=false;
    _isGADReportToSend=TRUE;
    _isFlightReportToSend=FALSE;
    
    //[self ConfirmationGADSSend];
    bool existeConexion=false;
    if([self isNetworkAvailable]==true)
    {
        // [self disableButtonGAD:_NameBottonGAD];
        [self ConfirmationGADSSend];
       
   
    }else{
        
        existeConexion=false;
        [self MessageAlertOffline];
   
    }
 
}
- (IBAction)addBtnCus:(id)sender
{
    @try {
        UIButton *btn= (UIButton *)sender;
        NSString *data =  (@"%@",btn.accessibilityLabel);
    
        NSArray* dateArray = [data componentsSeparatedByString: @","];
        _idReportTemp = [dateArray objectAtIndex: 0];
        _idCustomer = [dateArray objectAtIndex: 1];
    }
    @catch (NSException *exception) {
        DLog(@"exception handled==%@",exception.description);
    }
    
    bool existeConexion=false;
    if([self isNetworkAvailable]==true)
    {
        existeConexion=true;
        _isCUSReportToSend=true;
        _isGADReportToSend=false;
        _isFlightReportToSend=FALSE;
        [self ConfirmationCUSSend];
        
       // [self disableButtonCus:_NameBottonCUS];
        
    }else{
        
        existeConexion=false;
        [self MessageAlertOffline];
        
    }
    
    
}
-(void)MessageAlertOffline{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;


 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"INFORMATION_MESSAGE"]
                                                          message: [appDel copyTextForKey:@"INFORMATION_CONTEXT"]
                                                          delegate:self
                                                          cancelButtonTitle:[appDel copyTextForKey:@"INFORMATION_AGREE"] otherButtonTitles: nil];
  [alert show];
}
-(void)MessageConfirmProcessReport
{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"INFORMATION_MESSAGE"]
                                                    message:[appDel copyTextForKey:@"INFORMATION_QUESTION"]
                                                   delegate:self
                                          cancelButtonTitle:[appDel copyTextForKey:@"INFORMATION_NO"]
                                          otherButtonTitles:[appDel copyTextForKey:@"INFORMATION_YES"], nil];
    [alert show];
    
}
- (void)ConfirmationFlightReportSend
{
    [self MessageConfirmProcessReport];

}
- (void)ConfirmationGADSSend
{
    [self MessageConfirmProcessReport];

}
- (void)ConfirmationCUSSend
{
    [self MessageConfirmProcessReport];

}
-(void)CUSforwardingReport:(NSString *)idflight:(NSString *)idreport :(NSString *)idcustomer
{

    NSString* idflights = idflight;
    NSString* idReport = idreport;
    NSString* idCustumer =idcustomer;
    NSString* dateflight=@"";
    
    [self SendIndividualCUSProcessByID:(NSString*)idflights:(NSString*)idReport:(NSString*)idCustumer:(NSString*)dateflight];
    //[self.navigationController popViewControllerAnimated:YES];

}
-(void)GADforwardingReport:(NSString*)dateflight:(NSString *)idflight:(NSString*)idGAD
{
    NSString *idflights;
    NSString *idGADs;
    idflights = idflight;
    idGADs=idGAD;
    [self SendIndividualGadProcessByID:(NSString*)dateflight:(NSString*)idflights:(NSString*)idGADs];
    
    
}
-(bool)ValidationOfCUSReportSent :(NSString *)idflight:(NSString *)idreport :(NSString *)idcustomer
{
    bool processval = false;
  
    return processval;
}
-(bool)ValidationOfGADReportSent:(NSString *)idflight:(NSString*)idGAD
{
    bool processval = false;
    
    return processval;
}
-(bool)ValidationOfFlightReportSent:(NSString *)idflight
{
    bool processval = false;
    
    return processval;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *idflights;
    NSString *idReport;
    NSString *idCustumer;
    NSString *dateflight=@"";
    
    switch(buttonIndex) {
        case 0: //"No" pressed
            //do something?
            [self stopSpin];
            break;
        case 1: //"Yes" pressed
          
            if(_isCUSReportToSend)
            {
                dateflight=@"";
                SynchronizationController *synch = [[SynchronizationController alloc] init];
                synch.delegate = self;
                idflights = _idflightTemp;
                idReport = _idReportTemp;
                idCustumer =_idCustomer;
                dateflight=_dateflightActual;
                
                [self startSpinProcess];
                [self SendIndividualCUSProcessByID:(NSString*)idflights:(NSString*)idReport:(NSString*)idCustumer:(NSString*)dateflight];
//                [self.navigationController popViewControllerAnimated:YES];
//                [synch synchCheckStatusOncompleteByIfFlight :(NSString*)idflights:^{
//    
                   [[NSNotificationCenter defaultCenter] postNotificationName:kNotifSyncFinished object:nil];
//                }];
                [self stopSpin];

            }
            if(_isGADReportToSend)
            {
                dateflight=@"";
                NSString *idflights;
                NSString *idGAD;
                idflights = _idflightTemp;
                idGAD=_idReportGAD;
                dateflight=_dateflightGad;
                [self startSpinProcess];
                [self SendIndividualGadProcessByID:(NSString*)dateflight:(NSString*)idflights:(NSString*)idGAD];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifSyncFinished object:nil];
                [self stopSpin];
            
            }
            if(_isFlightReportToSend)
            {
                dateflight=@"";
                NSString *idflights;
                idflights = _idflightTemp;
                dateflight=_dateReportFlight;
                [self startSpinProcess];
                [self SendIndividualInformFlightProcessByID:(NSString*)dateflight:(NSString*)idflights];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifSyncFinished object:nil];
            [self stopSpin];
            }

            break;
    }
}
-(IBAction)enableButtonCus:(UIButton *)Botton{

    Botton.enabled = YES;
}
-(IBAction)disableButtonCus:(UIButton *)Botton{
    
   Botton.enabled = NO;
}
-(IBAction)enableButtonGAD:(UIButton *)Botton{
    
    Botton.enabled = YES;
}
-(IBAction)disableButtonGAD:(UIButton *)Botton{
    
   Botton.enabled = NO;
}
-(IBAction)enableButtonFlight:(UIButton *)Botton{
   
    Botton.enabled = YES;
}
-(IBAction)disableButtonFlight:(UIButton *)Botton{
    
    Botton.enabled = NO;
}
-(BOOL)checkCUSStatusBool :(NSMutableDictionary*)flightDict withUploadURL:(NSString*)imageLoadUrl isFromSunc:(BOOL)fromSync forReportId:(NSString*)cusreportId {
    
    BOOL transstatus=false;
    
    NSMutableDictionary *statusDict = [LTCUSData getCusFlightDict:flightDict forReportId:cusreportId];
    /* ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
     singleton=[LTSingleton getSharedSingletonInstance];
     [connection loginCredentials:singleton.username :singleton.password];
     connection.serviceTags = kCHECKSTATUS;
     connection.delegate = self; */
    NSString *url = [NSString stringWithFormat:@"%@%@",BASEURL,CHECKSTATUS_URI];
    NSString *postJson = [DictionaryParser jsonStringFromDictionary:statusDict];
    
    DLog(@"CUS status json:%@",postJson);
    DLog(@"CUS status url:%@",url);
    
    RequestObject *requset = [[RequestObject alloc] init] ;
    requset.url = url;
    requset.language = @"en_ES";
    requset.tag = 1;
    requset.type = @"POST";
    requset.param = postJson;
    requset.priority = normal;
    
    ConnectionLibrary *connection = [[ConnectionLibrary alloc] init];
    
    NSMutableData *jsonData = [connection sendSynchronousCallWithUrl:requset error:nil];
    
    NSDictionary *responseDict = [DictionaryParser dictionaryFromData:jsonData];
    
    if([[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"]) {
        NSDictionary *dict = [[[responseDict objectForKey:@"checkReportStatus"] objectForKey:@"flights"] objectAtIndex:0];
        NSString *status = [[[dict objectForKey:@"status"] objectAtIndex:0]objectForKey:@"status"];
        DLog(@"CUS status response:%@",responseDict);
        
        if([status isEqualToString:@"OK"]) {
            [LTCUSData updateCUSStatus:dict status:ok flightDict:flightDict forReportId:cusreportId];
            transstatus=true;
        }
        else if([status isEqualToString:@"ER"] || [status isEqualToString:@"NOT_SENT"]) {
            int attmpts = [LTCUSData updateCUSStatus:dict status:inqueue flightDict:flightDict forReportId:cusreportId];
            [LTCUSData updateCUSStatus:dict status:eror flightDict:flightDict forReportId:cusreportId];
            
        }
        else if([status isEqualToString:@"EE"]) {
            [LTCUSData updateCUSStatus:dict status:ee flightDict:flightDict forReportId:cusreportId];
            transstatus=true;
        }
        else if ([status isEqualToString:@"EA"]) {
            int attempts = [LTCUSData updateCUSStatus:dict status:ea flightDict:flightDict forReportId:cusreportId];
            if(attempts == 0) {
               // [self sendImagesZipFor:CUS forFlight:flightDict onURI:imageLoadUrl withCheckStatus:YES];
            } else {
                [LTCUSData updateCUSStatus:dict status:ok flightDict:flightDict forReportId:cusreportId];
            }
        }
        else if([status isEqualToString:@"WF"]) {
            int attempts = [LTCUSData updateCUSStatus:dict status:wf flightDict:flightDict forReportId:cusreportId];
            [LTCUSData updateCUSStatus:dict status:ok flightDict:flightDict forReportId:cusreportId];
        }
    }
    
    return transstatus;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statusCell"];
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        [cell.contentView.layer setCornerRadius:30.0];
        tableView.separatorColor=[UIColor clearColor];
    }else{
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        [cell.contentView.layer setCornerRadius:30.0];
        tableView.separatorColor=[UIColor clearColor];
    }
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *flightDict = [self.statArray objectAtIndex:indexPath.section];
    NSInteger stat = [[flightDict objectForKey:@"flightStatus"] integerValue] ;
    int num = 0;
    if (stat > 0) {
        num = 1;
    }
    if (stat > 0 && indexPath.row == 0) {
        if (stat == draft) {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_01.png"];
            cell.statusLb.text = [appDel copyTextForKey:@"DRAFT_LABEL"];
        } else if(stat == inqueue || stat == sent || stat == ea || stat == wf  || stat == ee) {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_02.png"];
            cell.statusLb.text = [appDel copyTextForKey:@"QUEUE_LABEL"];
            
            //Create button Informe Vuelos
            
            UIButton *addbtnFlightInform = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                 addbtnFlightInform.frame = CGRectMake(550, 15.0f, 51, 51);
                 [addbtnFlightInform setBackgroundImage:[UIImage imageNamed:@"N___0004_Sent.png"]
                                       forState:UIControlStateNormal];
            [addbtnFlightInform setTitle:@"" forState:UIControlStateNormal];
            [cell addSubview:addbtnFlightInform];
            [addbtnFlightInform addTarget:self
                                action:@selector(addBtnInformFlight:)
                      forControlEvents:UIControlEventTouchUpInside];
            
            
            NSData *fecha = [flightDict objectForKey:@"flightDate"];
            
            @try {
                if (fecha != nil){
                    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                    [dateformate setDateFormat:@"yyyy-MM-dd"]; // Date formater
                    _dateReportFlight = [dateformate stringFromDate:fecha];
                }
                
            }
            @catch (NSException *exception) {
                DLog(@"exception handled==%@",exception.description);
            }

            
             _idflightTemp=@"";
             _idflightTemp = [@([[flightDict objectForKey:@"flightNumber"] integerValue]) stringValue];
            
            addbtnFlightInform.accessibilityLabel= [_idflightTemp stringByAppendingFormat:@",%@", _dateReportFlight];
            
           _NameBottonFlight=addbtnFlightInform;
            
        } else if (stat == received || stat == ok) {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_03.png"];
            cell.statusLb.text = [appDel copyTextForKey:@"RECEIVED_LABEL"];
        } else {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_04_error.png"];
            cell.statusLb.text = [appDel copyTextForKey:@"ERROR_LABEL"];
        }
        cell.DetailsLbl.text=[appDel copyTextForKey:@"FLIGHT_REPORT"];
        NSDate *synchDate = [flightDict objectForKey:@"synchTime"];
        cell.synchDateLbl.text = [synchDate dateFormat:DATE_FORMAT_dd_MM_yyyy];
        cell.tag = 1;
        return cell;
    } else if([[flightDict objectForKey:@"GAD"] count]>(indexPath.row-num)) {
        
        NSInteger   row;
        NSInteger stat = [[flightDict objectForKey:@"flightStatus"] integerValue];
        if (stat>0) {
            row=indexPath.row-1;
        } else {
            row=indexPath.row;
        }
        
        NSDictionary *gadDict = [[flightDict objectForKey:@"GAD"] objectAtIndex:row];
        
        cell.DetailsLbl.text = [NSString stringWithFormat:@"GAD - %@, %@",[gadDict objectForKey:@"lastName"],[gadDict objectForKey:@"firstName"]];
        stat = [[gadDict objectForKey:@"status"] integerValue];
        if (stat == draft) {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_01.png"];
            cell.statusLb.text = [appDel copyTextForKey:@"DRAFT_LABEL"];
        } else if(stat == inqueue || stat == sent || stat == ea || stat == wf  || stat == ee) {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_02.png"];
            cell.statusLb.text = [appDel copyTextForKey:@"QUEUE_LABEL"];

             UIButton *addFriendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            //Create button GADS

            addFriendButton.frame = CGRectMake(550, 15.0f, 51, 51);
            [addFriendButton setBackgroundImage:[UIImage imageNamed:@"N___0004_Sent.png"]
                           forState:UIControlStateNormal];

            [addFriendButton setTitle:@"" forState:UIControlStateNormal];
            [cell addSubview:addFriendButton];
            [addFriendButton addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
           
            
            _idflightTemp=@"";
            _idflightTemp = [@([[flightDict objectForKey:@"flightNumber"] integerValue]) stringValue];
            
            NSData *fecha = [flightDict objectForKey:@"flightDate"];
            
            @try {
                if (fecha != nil){
                    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                    [dateformate setDateFormat:@"yyyy-MM-dd"]; // Date formater
                    _dateflightGad = [dateformate stringFromDate:fecha];
                }
                
            }
            @catch (NSException *exception) {
                DLog(@"exception handled==%@",exception.description);
            }

            
            NSDictionary *GADSDictData = [[flightDict objectForKey:@"GAD"] objectAtIndex:row];
            _idReportGAD=@"";
            _idCustomerGAD=@"";
            
            _idReportGAD =[GADSDictData objectForKey:@"bp"];
            
             addFriendButton.accessibilityLabel=_idReportGAD;
            
            _NameBottonGAD=addFriendButton;

     
            
        } else if (stat == received || stat == ok ) {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_03.png"];
            cell.statusLb.text = [appDel copyTextForKey:@"RECEIVED_LABEL"];
        }
        else {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_04_error.png"];
            cell.statusLb.text = [appDel copyTextForKey:@"ERROR_LABEL"];
        }
        NSDate *synchDate = [gadDict objectForKey:@"synchDate"];
        if (synchDate!=nil) {
            cell.synchDateLbl.text = [synchDate dateFormat:DATE_FORMAT_dd_MM_yyyy];
        }
        cell.tag=2;
        return cell;
    } else if([[flightDict objectForKey:@"CUS"] count]> (indexPath.row-num-[[flightDict objectForKey:@"GAD"] count])) {
        
       // [self checkCUSStatus:flightDict withUploadURL:report.imageLoadUrl isFromSunc:YES forReportId:report.reportId];
        
        NSInteger row;
        NSInteger stat = [[flightDict objectForKey:@"flightStatus"] integerValue];
        if (stat>0) {
            row=indexPath.row-1-[[flightDict objectForKey:@"GAD"] count];
        }else{
            row=indexPath.row-[[flightDict objectForKey:@"GAD"] count];
        }
        NSDictionary *cusDict = [[flightDict objectForKey:@"CUS"] objectAtIndex:row];
        cell.DetailsLbl.text = [NSString stringWithFormat:@"CUS - %@, %@",[cusDict objectForKey:@"lastName"],[cusDict objectForKey:@"firstName"]];
        stat = [[cusDict objectForKey:@"status"] integerValue];
        NSString *statusStr;
        if (stat == draft) {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_01.png"];
            statusStr = [appDel copyTextForKey:@"DRAFT_LABEL"];
        } else if(stat == inqueue || stat == ea || stat == wf  || stat == ee || stat == sent ) {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_02.png"];
            statusStr = [appDel copyTextForKey:@"QUEUE_LABEL"];
            
            //Create button CUS

            //[self checkCUSStatus:fKeyDict withUploadURL:nil isFromSunc:YES forReportId:report.reportId];
            
            
            
            UIButton *addButtonCus = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
                addButtonCus.frame = CGRectMake(550, 15.0f, 51, 51);
                [addButtonCus setBackgroundImage:[UIImage imageNamed:@"N___0004_Sent.png"]
                                       forState:UIControlStateNormal];
                [addButtonCus setTitle:@"" forState:UIControlStateNormal];
            
                _addbtnCustemp.frame = CGRectMake(550, 15.0f, 51, 51);
                [_addbtnCustemp setBackgroundImage:[UIImage imageNamed:@"N___0004_Sent.png"]
                                    forState:UIControlStateNormal];
                [_addbtnCustemp setTitle:@"" forState:UIControlStateNormal];
            
            [cell addSubview:addButtonCus];
            [addButtonCus addTarget:self action:@selector(addBtnCus:) forControlEvents:UIControlEventTouchUpInside];
            
            _dateflightActual=@"";
            _idflightTemp=@"";
            _idflightTemp = [@([[flightDict objectForKey:@"flightNumber"] integerValue]) stringValue];
            
            NSData *fecha = [flightDict objectForKey:@"flightDate"];
            
            @try {
                if (fecha != nil){
                    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                   [dateformate setDateFormat:@"yyyy-MM-dd"]; // Date formater
                   _dateflightActual = [dateformate stringFromDate:fecha];
                }
             
            }
            @catch (NSException *exception) {
                DLog(@"exception handled==%@",exception.description);
            }
            
            _idReportTemp=@"";
            _idCustomer=@"";
            
            
            
            NSDictionary *cusDictData = [[flightDict objectForKey:@"CUS"] objectAtIndex:row];
            
            _idReportTemp =[cusDictData objectForKey:@"reportId"];
            _idCustomer=[cusDictData objectForKey:@"customerId"];
            
             addButtonCus.accessibilityLabel= [_idReportTemp stringByAppendingFormat:@",%@", _idCustomer];
            
            _NameBottonCUS=addButtonCus;
            
            //NSString *strimage=_imageLoadUrl;
            
           
            
        } else if (stat == received || stat == ok) {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_03.png"];
            statusStr = [appDel copyTextForKey:@"RECEIVED_LABEL"];
        } else {
            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_04_error.png"];
            statusStr = [appDel copyTextForKey:@"ERROR_LABEL"];
        }
        
        cell.statusLb.text = [NSString stringWithFormat:@"%@", statusStr];
       
        NSDate *synchDate = [cusDict objectForKey:@"synchDate"];
        if (synchDate!=nil) {
            cell.synchDateLbl.text = [synchDate dateFormat:DATE_FORMAT_dd_MM_yyyy];
        }
        
        NSDictionary *cusDictDatas = [[flightDict objectForKey:@"CUS"] objectAtIndex:row];

//        if ([self checkCUSStatusBool:flightDict withUploadURL:report.imageLoadUrl isFromSunc:YES forReportId:[cusDictDatas objectForKey:@"reportId"]])
//        {
//            
//            cell.statusImageView.image = [UIImage imageNamed:@"ic_modal_dash_03.png"];
//            statusStr = [appDel copyTextForKey:@"RECEIVED_LABEL"];
//            
//        }
        
        cell.tag = 3;
        return cell;
    }
    else{
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *flightDict = [self.statArray objectAtIndex:indexPath.section];
    NSInteger stat = [[flightDict objectForKey:@"flightStatus"] integerValue] ;
    int num = 0;
    if (stat > 0) {
        num = 1;
    }

    if (cell.tag == 1) {
        if ([self.delegate respondsToSelector:@selector(scrollToFlightReportFromVC:forFlight:)]) {
            [self.delegate scrollToFlightReportFromVC:self forFlight:flightDict];
        }
    } else if (cell.tag == 2){
        
        NSDictionary *gadDict = [[flightDict objectForKey:@"GAD"] objectAtIndex:(indexPath.row-num)];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if([gadDict[@"status"] intValue] == draft || [gadDict[@"status"] intValue] == eror) {
            if ([self.delegate respondsToSelector:@selector(scrollToGADReportFromVC:forFlight:andGADDict:)]) {
                [self.delegate scrollToGADReportFromVC:self forFlight:flightDict andGADDict:gadDict];
            }
        }
        else {
            AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDel copyTextForKey:@"ALERT_MSG"] message:[appDel copyTextForKey:@"GAD_SENT_MSG"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    } else if (cell.tag == 3){
        
        NSDictionary *cusDict = [[flightDict objectForKey:@"CUS"] objectAtIndex:(indexPath.row-num-[[flightDict objectForKey:@"GAD"] count])];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if ([self.delegate respondsToSelector:@selector(scrollToCUSReportFromVC:forFlight:andCUSDict:)]) {
            [self.delegate scrollToCUSReportFromVC:self forFlight:[flightDict mutableCopy] andCUSDict:cusDict];
        }
    }
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

- (IBAction)closeBtnTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(closePopOverforObject:)]) {
        [self.delegate closePopOverforObject:self];
    }
    
}
@end
