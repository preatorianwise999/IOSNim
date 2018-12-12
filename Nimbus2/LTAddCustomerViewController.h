//
//  LTAddCustomerViewController.h
//  Nimbus2
//
//  Created by Dreamer on 7/30/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TestView.h"
#import "TestView.h"
//#import "DropDownViewController.h"
#import "FlightRoaster.h"


@protocol AddNewCustomerDelegate <NSObject>

-(void)finishedEnteringNewCustomer;
@end

@interface LTAddCustomerViewController : UIViewController<UITextFieldDelegate,PopoverDelegate>{
    NSArray * documentTypeArray;
    BOOL isFirst;
    NSDictionary *docValidationDict;
    int currentLegNumber;
    NSDictionary *customerDict;
    NSString *seatNumber;

}
@property (nonatomic) BOOL seatMapExists;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UILabel *seatNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *seatNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLastNameLabel;
@property (nonatomic,strong)NSManagedObjectContext *localMoc;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondLastNameTextField;
@property (weak, nonatomic) IBOutlet UIView *addCustomerView;
@property (weak, nonatomic) IBOutlet TestView *docTypeView;
@property (weak, nonatomic) IBOutlet UITextField *docNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *docTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *docNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *addNewCustomerTitle;
@property (weak, nonatomic) IBOutlet UILabel *docTypeHelpLabel;
@property (strong,nonatomic) FlightRoaster *flightRoster;

@property (assign, nonatomic) id <AddNewCustomerDelegate> delegate;

@property (nonatomic,strong)      NSString *seatNumber;
@property (nonatomic,strong)      NSMutableArray *allseats;


@property(weak,nonatomic)IBOutlet NSLayoutConstraint *addcustomerTopConstraint;
@property(weak,nonatomic)IBOutlet NSLayoutConstraint *addcustomerLeadingConstraint;
@property (nonatomic) TestView *activeTestView;


- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)documentTypeButtonTapped:(id)sender;



@end
