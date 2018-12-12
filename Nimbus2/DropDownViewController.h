//
//  DropDownViewController.h
//  Dropdown
//
//  Created by Vishnu on 11/03/14.
//  Copyright (c) 2014 Vishnu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropDownViewController;
@protocol DropSelectionDelegate <NSObject>

-(void)selectedValueInDropdown:(DropDownViewController *)obj;

@end

@interface DropDownViewController : UITableViewController<UITextFieldDelegate>

@property(nonatomic,retain) NSString *valueSelected;
@property(nonatomic,retain) NSArray *dropTableDataSource;
@property(nonatomic,assign) int selectedIndex;

@property(nonatomic,assign) id<DropSelectionDelegate> delegate;
@property (nonatomic) BOOL isOther;

-(id)initWithData:(NSArray *)dataSource;
-(id)initWithData:(NSArray *)dataSource withCheckMark:(BOOL)checkMark;

@end
