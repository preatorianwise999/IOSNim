//
//  PickerDoneCancelViewController.m
//  LATAM
//
//  Created by vishal on 7/19/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "PickerDoneCancelViewController.h"
#import "AppDelegate.h"

@interface PickerDoneCancelViewController ()

@end

@implementation PickerDoneCancelViewController
@synthesize titleForHeader;
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
    // Do any additional setup after loading the view from its nib.
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.header_lab setTextAlignment:NSTextAlignmentCenter];
    [self.header_lab setText:self.titleForHeader];
//    [self.header_lab  setFont:[UIFont boldSystemFontOfSize:17]];
    [self.header_lab setFont:kdropDownHeading];
    [self.cancelBarButton setTitle:[appDel copyTextForKey:@"CANCEL"]];
    
    [_cancelBarButton setTitleTextAttributes:@{
                                         NSFontAttributeName:kdropDownHeading,
                                         } forState:UIControlStateNormal];
    
    
//    [self.cancelBarButton sett]
    [self.DoneBarButton setTitle:[appDel copyTextForKey:@"DONE"]];
    [_DoneBarButton setTitleTextAttributes:@{
                                               NSFontAttributeName:kdropDownHeading,
                                               } forState:UIControlStateNormal];
    
    

}
-(IBAction)onClickPickerDone {
    if([self.delgate respondsToSelector:@selector(pickerDoneButtonClicked)])
        [self.delgate pickerDoneButtonClicked];
}
-(IBAction)onClickPickerCancel {
    if([self.delgate respondsToSelector:@selector(pickerCancelButtonClicked)])
        [self.delgate pickerCancelButtonClicked];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
