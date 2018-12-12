//
//  DocNumberCPopoverControllerViewController.h
//  Nimbus2
//
//  Created by vishal on 12/1/15.
//  Copyright © 2015 TCS. All rights reserved.
//


@protocol DocNumberPopoverProtocol <NSObject>

-(void)doneBtnTapped;
-(void)cancelBtnTapped;

@end

#import <UIKit/UIKit.h>
#import "TestView.h"
//#import "PassengerDetailsViewController.h"





@interface DocNumberViewController : UIViewController<UITextFieldDelegate,PopoverDelegate> {
    NSDictionary *docValidationDict;

}

@property id<DocNumberPopoverProtocol> delegate;
@property IBOutlet UITextField * docNumberField;
@property IBOutlet UILabel * docNumberLabel;
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)doneButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet TestView *docTypeView;
@property (weak, nonatomic) IBOutlet UILabel *docTypeLabel;
@property (nonatomic) TestView *activeTestView;

@end
