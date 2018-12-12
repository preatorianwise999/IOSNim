//
//  ManualViewController.h
//  Nimbus2
//
//  Created by 720368 on 7/17/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreManuals.h"
#import "LTSingleton.h"
#import "SynchronizationController.h"
#import "AlertUtils.h"
#import "AppDelegate.h"

@interface ManualViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIDocumentInteractionControllerDelegate,StoreManualsDelegate,UIWebViewDelegate>
{
    NSString *filePath;
    UIDocumentInteractionController *docController;
    StoreManuals *storeManuals;
 
}
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *displayPDFTitleLbl;
@property (nonatomic, retain) NSMutableArray *manualList;
@property (nonatomic, retain) NSDictionary *selectedManualDict;
@property (strong, nonatomic) IBOutlet UIButton *openWithBtn;
@property (weak, nonatomic) IBOutlet UITableView *manualTable;
@property (weak, nonatomic) IBOutlet UIWebView *pdfViewerWebView;
@property (strong, nonatomic) IBOutlet UILabel *displayTitleLbl;
@property (retain, nonatomic) IBOutlet UIButton *menuBackButton;
@property(nonatomic,retain)IBOutlet UIButton *backBtn;

- (IBAction)navigationBackButtonClicked:(id)sender;
- (IBAction)openWithBtnTapped:(UIButton *)sender;
- (IBAction)backButtonTapped:(UIButton *)sender;

@end
