//
//  SeatNumViewController.m
//  LATAM
//
//  Created by Durga Madamanchi on 5/7/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "SeatNumViewController.h"
#import "AppDelegate.h"
#import "ComboBoxTextNum.h"
#import "SeatNum.h"
@interface SeatNumViewController ()

@end

@implementation SeatNumViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

            }
    return self;
}
-(void)awakeFromNib {
    

}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [self.cancelBarButton setTitle:[appDel copyTextForKey:@"CANCEL"]];
    [self.DoneBarButton setTitle:[appDel copyTextForKey:@"DONE"]];
        
    [self.navBar setTitle:[appDel copyTextForKey:@"SELECT_SEAT"]];
   
	// Do any additional setup after loading the view.
}
-(IBAction)onclickDone {
    //if([self.delgate respondsToSelector:@selector(seatnumSelectionDone)])
       // [self.delgate seatnumSelectionDone];
    if(nil != self.tempCell){
        if([self.tempCell isKindOfClass:[ComboBoxTextNum class]]) {
            
            [(ComboBoxTextNum*)self.tempCell seatnumSelectionDone];
        }else if([self.tempCell isKindOfClass:[ComboNumTextText class]]) {
            [(ComboNumTextText*)self.tempCell seatnumSelectionDone];

        }
        else if([self.tempCell isKindOfClass:[SeatNum class]]) {
            [(SeatNum*)self.tempCell seatnumSelectionDone];

        }
    }
}
-(IBAction)onClickCancel {
    if([self.delgate respondsToSelector:@selector(seatnumSelectionCanceled)])
        [self.delgate seatnumSelectionCanceled];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
