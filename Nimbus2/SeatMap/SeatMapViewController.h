//
//  SeatMapViewController.h
//  Nimbus2
//
//  Created by Dreamer on 7/29/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTAddCustomerViewController.h"
#import "PassengerDetailsViewController.h"
#import "CategoryTableViewController.h"
#import "CUSReportViewController.h"

@interface SeatMapViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,doneButtonTappedProtocol,AddNewCustomerDelegate,CUSReportDelegate,UICollectionViewDelegateFlowLayout> {
    
    __weak IBOutlet UICollectionView *seatMapCollectionView;
    __weak IBOutlet UITableView *passengerFilterTabelView;
    __weak IBOutlet UITextField *passengerSearchTextField;

    PassengerDetailsViewController * passengerDetailsViewController; //passengerTable
    CategoryTableViewController *categoryTableViewController;
   // LTAddCustomerViewController * addCustomerVC;
}

@property (strong, nonatomic) NSArray *legArray;
@property  BOOL isSeatClicked;
@property  NSString *selectedSatNumber;
@property   BOOL selectedPassenger;
@property NSArray *acompaniesArray;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic,strong) NSDictionary *customerDict;
@property NSString *curent_seatNmum;
- (IBAction)onClickAdd:(UIButton *)sender;
- (void) loadPageControllerWithTotalPages:(int)totalCount;
-(NSArray *) retrievePassengerswithGroupcode:(NSString *)groupcode ;

@end
