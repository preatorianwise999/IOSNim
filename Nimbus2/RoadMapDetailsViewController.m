//
//  RoadMapDetailsViewController.m
//  Nimbus2
//
//  Created by Diego Cathalifaud on 10/15/15.
//  Copyright © 2015 TCS. All rights reserved.
//

#import "RoadMapDetailsViewController.h"

@interface RoadMapDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLb;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceConstraint;

@end

@implementation RoadMapDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLb.text = self.titleStr;
    self.subtitleLb.text = self.subtitleStr;
    
    [self.dialogueView.layer setCornerRadius:20];
    [self updatePopupFrame];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.webView loadHTMLString:self.html baseURL:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged)    name:UIApplicationWillChangeStatusBarOrientationNotification  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)orientationChanged{
    [self performSelector:@selector(updatePopupFrame) withObject:nil afterDelay:0.1];
    
}
- (void)updatePopupFrame {
    dispatch_async(dispatch_get_main_queue(), ^{

    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
    self.leadingSpaceConstraint.constant = 147;
        self.topSpaceConstraint.constant = 87;
    } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.leadingSpaceConstraint.constant = 20;
        self.topSpaceConstraint.constant = 212;
    }
    });
}
- (IBAction)closeButtonClicked:(id)sender {

    [self willMoveToParentViewController:nil];  // 1
    [self.view removeFromSuperview];            // 2
    [self removeFromParentViewController];    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
