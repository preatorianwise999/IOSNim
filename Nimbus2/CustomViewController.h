//
//  CustomViewController.h
//  LATAM
//
//  Created by Vishnu on 19/05/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestView.h"
#import "TestViewCameraViewController.h"

@interface CustomViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate , UITableViewDelegate>
{
    BOOL isKeyboardUp;
    
}

//Validation
@property(nonatomic,retain) NSIndexPath *leastIndexPath;
@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) NSMutableArray *ipArray;
@property int legNumber;

@property(nonatomic,assign) BOOL isCus;
@property(nonatomic,assign) void (^_isCustomViewLoadedCompletionHandler)(BOOL isCustomViewLoaded);
@property (nonatomic) TestView *activeTestView;
@property (nonatomic) TestViewCameraViewController *cameraVC;


-(void)textFieldDidEndEditing:(UITextField *)textField;
-(void)textViewDidEndEditing:(UITextView *)textView;

-(void)initializeIndexPathArray;
-(void)updateReportDictionary;
-(void)updateCusReportDictionary;
-(void)updateDiskFile;
-(void)deleteImage:(NSString*)imageName;
-(void)cellsForTableView:(UITableView *)tableView;
- (void)presentCameraVC;

@end
