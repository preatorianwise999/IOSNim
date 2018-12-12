//
//  LTAddGADViewController.h
//  LATAM
//
//  Created by Madhu on 5/15/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTSelectRankViewController.h"
@protocol LTAddFlightCrewProtocol<NSObject>
-(BOOL)flightCrewFirstName:(NSString *)firstName amdLastName:(NSString *)lastName andbpNumber:(NSString *)bpNumber rankValue:(NSString *)rank;
@end
@interface LTAddGADViewController : UIViewController<LTSelectRankProtocol,UIPopoverControllerDelegate,UITextFieldDelegate>

{
    NSArray *activeArray;
}
@property (nonatomic, strong)UIPopoverController *selectRankPopOverController;

@property (nonatomic) int currentLeg;

@property (nonatomic, weak)IBOutlet UILabel *firstNameLabel;
@property (nonatomic, weak)IBOutlet UILabel *lastNameLabel;
@property (nonatomic, weak)IBOutlet UILabel *bpLabel;
@property (nonatomic, weak)IBOutlet UILabel *rankLabel;
@property (nonatomic, weak)IBOutlet UIButton *closeBtn;
@property (nonatomic, weak)IBOutlet UIButton *saveBtn;
@property (nonatomic, weak)IBOutlet UILabel *addCrewMemberLabel;
@property (nonatomic, weak)IBOutlet UIView *currentView;
@property (nonatomic, weak)IBOutlet UIView *footerView;



@property(nonatomic,weak) IBOutlet UIView *firstNameFieldBGView;
@property(nonatomic,weak) IBOutlet UIView *lastNameFieldBGView;
@property(nonatomic,weak) IBOutlet UIView *bpFieldBGView;
@property(nonatomic,weak) IBOutlet UIView *rankBGViewBGView;
@property(nonatomic,weak) IBOutlet UIButton *rankBtn;
@property(nonatomic,strong) NSArray *activeArray;


@property(nonatomic,strong) IBOutlet UITextField *firstNameField;
@property(nonatomic,strong) IBOutlet UITextField *lastNameField;
@property(nonatomic,strong) IBOutlet UITextField *bpField;


@property(nonatomic, strong) IBOutlet NSLayoutConstraint *topConstraint;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *leadingSpaceConstraint;


@property (nonatomic, strong)LTSelectRankViewController *selectRankViewController;
@property(nonatomic,assign)  UIPopoverController *presentedPopOverController;
@property id<LTAddFlightCrewProtocol>delegate;

-(IBAction)closeButtonClicked:(id)sender;
-(IBAction)saveButtonClicked:(id)sender;
-(IBAction)selectRank:(id)sender;
@end
