//
//  ManualViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/17/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "ManualViewController.h"
#import "CustomManualTableViewCell.h"
#import <UIKit/UIKit.h>
#import "NSDate+Utils.h"

@interface ManualViewController (){
    int numOfRows;
    AppDelegate *apDel;
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webviewverticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webviewHorizontalConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openwithlabelVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openwithlabelHorizontalConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *manualdelabelVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *manualdelabelHorizontalConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *webViewActivityIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userIconWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userIconHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userIconTopSapceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userIconTrailingSapceConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorLabelHorizontalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorLabelVerticalConstraint;



@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *dateUpdatedLb;
@property (weak, nonatomic) IBOutlet UILabel *cantLoadLb;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;


@end

@implementation ManualViewController
@synthesize selectedManualDict;

#pragma mark ---view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.userNameLabel.text = [LTSingleton getSharedSingletonInstance].user;
    self.manualTable.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    self.manualTable.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    numOfRows=5;
    storeManuals = [[StoreManuals alloc] init];
    
    self.pdfViewerWebView.delegate = self;
    
    self.manualList = [[storeManuals getManualsWithParentDirectory: [storeManuals getLatamManualsDirPath]] mutableCopy];
    [self setSelectedManualDict: [storeManuals getLatamManualsRootDir]];
    [self.manualTable reloadData];
    
    [self registerDownloadManaulsNotification];
    
    self.titleLb.text = [apDel copyTextForKey:@"MANUAL"];
    self.displayTitleLbl.text = [apDel copyTextForKey:@"MANUAL"];
    self.displayPDFTitleLbl.text = [apDel copyTextForKey:@"MAN_MAN_NAME"];
    [self.menuBackButton setTitle:[apDel copyTextForKey:@"MAN_BACK_BTN"] forState:UIControlStateNormal];
    
    //make the buttons content appear in the top-left
    [self.openWithBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.openWithBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    //move text 10 pixels down and right
    [self.openWithBtn setTitleEdgeInsets:UIEdgeInsetsMake(10.0f, 60.0f, 0.0f, 0.0f)];
    [self.openWithBtn setTitle:[apDel copyTextForKey:@"OPEN_WITH"] forState:UIControlStateNormal];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"dd-MM-yyyy HH:mm";
    
    self.dateUpdatedLb.text = [NSString stringWithFormat:@"%@ %@", [apDel copyTextForKey:@"MAN_UPDATED_AT"], [df stringFromDate:[[NSDate date] toLocalTime]]];
    
    self.menuBackButton.hidden = YES;
    
    [self arrangeFramesOfItemsAccordingToOrientation];
    [self.webViewActivityIndicator setHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIApplicationWillChangeStatusBarOrientationNotification  object:nil];
}
- (void)viewDidLayoutSubviews {
    [self arrangeFramesOfItemsAccordingToOrientation];
}

-(void) arrangeFramesOfItemsAccordingToOrientation {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            _backgroundImage.image = [UIImage imageNamed:@"N__0008_Background.png"];
            
            //_dropView.frame = CGRectMake(self.view.frame.size.width-150 - _dropView.frame.size.width, _carousel.frame.origin.y+50, _dropView.frame.size.width, _dropView.frame.size.height);
            
            _openwithlabelVerticalConstraint.constant = 38.0;
            _openwithlabelHorizontalConstraint.constant = 164.0;
            
            _manualdelabelVerticalConstraint.constant = 122.0;
            _manualdelabelHorizontalConstraint.constant = 43.0;
            
            _webviewverticalConstraint.constant = 180.0;
            _webviewHorizontalConstraint.constant = 23.0;
            
            _userIconHeightConstraint.constant = 42.0f;
            _userIconWidthConstraint.constant = 42.0f;
            _userIconTopSapceConstraint.constant = 31.0f;
            _userIconTrailingSapceConstraint.constant = 10.0f;
            
            self.errorLabelHorizontalConstraint.constant = 22;
            self.errorLabelVerticalConstraint.constant = 0;
            
        } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            
            _backgroundImage.image = [UIImage imageNamed:@"N__0008_Background_port.png"];
            _openwithlabelVerticalConstraint.constant = 0;
            _openwithlabelVerticalConstraint.constant = - (self.displayPDFTitleLbl.frame.size.height);
            _openwithlabelHorizontalConstraint.constant = 20.0;
            
            _manualdelabelHorizontalConstraint.constant = 170.0;
            
            _webviewverticalConstraint.constant = 188.0 + self.displayPDFTitleLbl.frame.size.height / 2;
            _webviewHorizontalConstraint.constant = 53.0;
            _userIconHeightConstraint.constant = 37.0f;
            _userIconWidthConstraint.constant = 37.0f;
            _userIconTopSapceConstraint.constant = 34.0f;
            _userIconTrailingSapceConstraint.constant = 4.0f;
            
            self.errorLabelHorizontalConstraint.constant = -100;
            self.errorLabelVerticalConstraint.constant = 40;
        }
    });
}

- (void)orientationChanged:(NSNotification *)notification {
    [self arrangeFramesOfItemsAccordingToOrientation];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterDownloadManualsNotification];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate & Datasource Methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sectionIdentifier = @"SectionCell";
    CustomManualTableViewCell *sectionCell = [tableView dequeueReusableCellWithIdentifier:sectionIdentifier];
    
    if (sectionCell == nil) {
        sectionCell = [[[NSBundle mainBundle] loadNibNamed:@"CustomManualTableViewCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    NSDictionary *manualDict = [self.manualList objectAtIndex:indexPath.row];
    [sectionCell displayCellContent: manualDict];
    
    return sectionCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.manualList count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.manualList.count <= indexPath.row) {
        return;
    }
    
    UITableViewCell *cell1 = [tableView cellForRowAtIndexPath:indexPath];
    if (cell1.tag == 999) {
        SynchronizationController *synch = [[SynchronizationController alloc] init];
        if (![synch checkForInternetAvailability]) {
            [AlertUtils showErrorAlertWithTitle:[apDel copyTextForKey:@"ALERT_MSG"] message:[apDel copyTextForKey:@"CANT_DOWNLOAD_MANUAL"]];
            [self.manualTable deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
    }
    
    if ([self.manualList containsObject:self.selectedManualDict]) {
        NSInteger prevSelectedIndex = [self.manualList indexOfObject: self.selectedManualDict];
        CustomManualTableViewCell *cell = (CustomManualTableViewCell*)[self.manualTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:prevSelectedIndex inSection:0]];
        [cell displayCellContent: self.selectedManualDict];
    }
    
    NSDictionary *manualDict = [self.manualList objectAtIndex: indexPath.row];
    [self setSelectedManualDict: manualDict];
    NSString *presentManualName = [manualDict objectForKey:kManualName];
    self.displayTitleLbl.text=presentManualName;
    
    CustomManualTableViewCell *cell = (CustomManualTableViewCell*)[self.manualTable cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1]];
    
    if([presentManualName rangeOfString:@".pdf" options:NSCaseInsensitiveSearch].location == presentManualName.length - 4) {
        
        self.displayPDFTitleLbl.hidden = NO;
        self.openWithBtn.hidden = NO;
        self.pdfViewerWebView.hidden = NO;
        
        self.displayPDFTitleLbl.text=presentManualName;
        filePath = [manualDict objectForKey:@"Path"];
        NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
        
        NSString *shortPath = filePathURL.path;
        unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:shortPath error:nil] fileSize];
        
        if (fileSize != [[manualDict objectForKey:@"Size"] longLongValue]) {
            self.cantLoadLb.text = [apDel copyTextForKey:@"MAN_FILE_NOT_READY"];
            self.cantLoadLb.hidden = NO;
            self.pdfViewerWebView.hidden = YES;
            self.openWithBtn.hidden = YES;
        }
        else if(fileSize < 15000000) {
            [self.pdfViewerWebView loadRequest:[NSURLRequest requestWithURL:filePathURL]];
            [[NSUserDefaults standardUserDefaults]setObject:manualDict forKey:@"selectedItem"];
            self.cantLoadLb.hidden = YES;
            [self.webViewActivityIndicator setHidden:YES];
        }
        else {
            self.pdfViewerWebView.hidden = YES;
            self.cantLoadLb.text = [apDel copyTextForKey:@"MAN_FILE_TOO_BIG"];
            self.cantLoadLb.hidden = NO;
            [self.webViewActivityIndicator setHidden:YES];
        }
    }
    else if([presentManualName rangeOfString:@"iba" options:1].length>0 ||
            [presentManualName rangeOfString:@"epub" options:1].length>0 ||[presentManualName rangeOfString:@"txt" options:1].length>0) {
        
        
    } else {
        
        self.menuBackButton.hidden = NO;
        
        cell.detailTextLabel.text = @"";
        self.manualList = [[storeManuals getManualsWithParentDirectory:[self.selectedManualDict objectForKey:kManualPath]] mutableCopy];
        
        if([storeManuals getPendingManuals].count>0) {
            [[DownloadManuals shareInstance] stopManualDownloader];
            
            NSString *path = [manualDict objectForKey:@"Path"];
            
            path=[[manualDict objectForKey:@"Path"] lastPathComponent];
            NSString *file = [NSString stringWithFormat:@" (downloadStatus == \'fail\') && (filePath CONTAINS \'%@\')",path];
            NSArray *list = [storeManuals getManualsWithPredicate:file];
            NSLog(@"list-------%@",list);
            if(list.count > 0) {
                [[DownloadManuals shareInstance] downloadManuals:list];
            }
            
        }
        [self.manualTable reloadData];
    }
}

#pragma mark -- Button Action Methods
- (IBAction)navigationBackButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openWithBtnTapped:(UIButton *)sender {
    
    if(filePath)
    {
        NSString *file=[filePath lastPathComponent];
        if([file rangeOfString:@"pdf" options:1].length>0 || [file rangeOfString:@"PDF" options:1].length>0) {
            
            [docController setUTI:@"com.adobe.pdf"];
        }
        else {
            [docController setUTI:@"public.plain-text"];
            
        }
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        docController = [[UIDocumentInteractionController alloc] init];
        [docController setURL:fileURL];
        
        docController.delegate = self;
        
        BOOL show=[docController presentOpenInMenuFromRect:self.openWithBtn.frame inView:self.view animated:YES];
        if(show){
            NSLog(@"Success");
        } else{
            NSLog(@"Failure");
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[apDel copyTextForKey:@"WARNING"]  message:[apDel copyTextForKey:@"FAILURE_MESSAGE"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
    }
}

- (IBAction)backButtonTapped:(UIButton *)sender {
    
    if ([[self.selectedManualDict objectForKey:kManualPath] isEqualToString:[storeManuals getLatamManualsDirPath]]) {
        if(sender.userInteractionEnabled == NO)
            return;
        if (self==[ManualViewController class]) {
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        return;
    }
    
    NSString *presentManual = [self.selectedManualDict objectForKey:kManualPath];
    NSString *parentManual = [presentManual stringByDeletingLastPathComponent];
    if([presentManual rangeOfString:@"pdf" options:1].length > 0 || [presentManual rangeOfString:@"PDF" options:1].length > 0) {
        parentManual = [parentManual stringByDeletingLastPathComponent];
    }
    NSString *prevParentManual = [parentManual stringByDeletingLastPathComponent];
    
    [self.menuBackButton setHidden:NO];
    self.selectedManualDict = nil;
    
    NSString *title = [parentManual lastPathComponent];
    if([title isEqualToString:@"LATAM_MANUALS_DIR"]) {
        [self.displayTitleLbl setText: @"Manuales"];
        [self.menuBackButton setHidden:YES];
    }
    else {
        [self.displayTitleLbl setText: title];
    }
    
    self.manualList = [[storeManuals getManualsWithParentDirectory:parentManual] mutableCopy];
    self.selectedManualDict = [[storeManuals getManualsWithParentDirectory:prevParentManual] firstObject];
    [self.manualTable reloadData];
    
    if([storeManuals getPendingManuals].count > 0) {
        [storeManuals startDownloadingManuals];
    }
}

#pragma mark -- other methods
- (NSInteger)isFileExitsInManualsList: (NSString*)manualFilePath {
    for (NSDictionary *manualDict in self.manualList) {
        if ([manualFilePath isEqualToString: [manualDict objectForKey:kManualPath]]) {
            
            return [self.manualList indexOfObject: manualDict];
        }
    }
    return -1;
}
#pragma mark -- Webview delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}



#pragma mark -- download succes notification methods

-(void)updateTable {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.manualTable reloadData];
    });
}

- (void)downloadManualNotification: (NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self downloadManualNotOnMainThread:notification];
        [self.manualTable reloadData];
    });
    
}
-(void)downloadManualNotOnMainThread:(NSNotification *)notification {
    
    NSDictionary *manualDict = [notification userInfo];
    NSString *manualDownloadStatus = [manualDict objectForKey:kManualDownloadStatus];
    NSString *manualFilePath = [manualDict objectForKey:kManualPath];
    if([manualDict count] == 3) {
        NSDate *newDate = [manualDict objectForKey:kManualDate];
        NSInteger manualIndex = [self isFileExitsInManualsList: manualFilePath];
        if (manualIndex >= 0) {
            if([manualDownloadStatus isEqualToString:DOWNLOAD_STATUS_SUCCESS]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray *manuals = [NSMutableArray arrayWithArray: self.manualList];
                    NSMutableDictionary *currentManual = [NSMutableDictionary dictionaryWithDictionary: [self.manualList objectAtIndex: manualIndex]];
                    [currentManual setObject:DOWNLOAD_STATUS_SUCCESS forKey:kManualDownloadStatus];
                    [manuals replaceObjectAtIndex: manualIndex withObject:currentManual];
                    [self setManualList: manuals];
                    CustomManualTableViewCell *cell = (CustomManualTableViewCell*)[self.manualTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:manualIndex inSection:0]];
                    //update UI
                    NSLog(@"Update UI for download success notification %@", manualDict);
                    [cell.activityIndicatorView stopAnimating];
                    [cell.activityIndicatorView setHidden:YES];
                    [cell.manualTitleLabel setTextColor:[UIColor whiteColor]];
                    [cell.manualDateLabel setTextColor:[UIColor whiteColor]];
                    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[apDel getLocalLanguageCode]];
                    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
                    [formatter setDateFormat:@"dd-MMM-yyyy HH:mm:ss"];
                    [formatter setLocale:locale];
                    NSString *dateString =[formatter stringFromDate:newDate];
                    [cell.manualDateLabel setText:dateString];
                    [cell.manualTypeImageView setAlpha:1];
                    [cell setUserInteractionEnabled:YES];
                });
            }
        }
    }
    
    else {
        NSInteger manualIndex = [self isFileExitsInManualsList: manualFilePath];
        if (manualIndex >= 0) {
            if([manualDownloadStatus isEqualToString:DOWNLOAD_STATUS_SUCCESS]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray *manuals = [NSMutableArray arrayWithArray: self.manualList];
                    NSMutableDictionary *currentManual = [NSMutableDictionary dictionaryWithDictionary: [self.manualList objectAtIndex: manualIndex]];
                    [currentManual setObject:DOWNLOAD_STATUS_SUCCESS forKey:kManualDownloadStatus];
                    [manuals replaceObjectAtIndex: manualIndex withObject:currentManual];
                    [self setManualList: manuals];
                    CustomManualTableViewCell *cell = (CustomManualTableViewCell*)[self.manualTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:manualIndex inSection:0]];
                    //update UI
                    NSLog(@"Update UI for download success notification %@", manualDict);
                    [cell displayCellContent:currentManual];
                    [cell.activityIndicatorView stopAnimating];
                    [cell.activityIndicatorView setHidden:YES];
                    [cell.manualTitleLabel setTextColor:[UIColor whiteColor]];
                    [cell.manualDateLabel setTextColor:[UIColor whiteColor]];
                    [cell.manualTypeImageView setAlpha:1];
                    [cell setUserInteractionEnabled:YES];
                    
                });
            }
        }
    }
}

#pragma mark -- register and unregister notifications
- (void)registerDownloadManaulsNotification {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(downloadManualNotification:)
                                                 name: DOWNLOAD_MANUAL_NOTIFICATION
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateTable)
                                                 name: UPDATE_MANUALS
                                               object: nil];
    
}

- (void)unregisterDownloadManualsNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DOWNLOAD_MANUAL_NOTIFICATION
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UPDATE_MANUALS
                                                  object:nil];
}

@end
