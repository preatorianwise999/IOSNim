//
//  OffsetCustomCell.h
//  GeneralLatam
//
//  Created by Vishnu on 20/03/14.
//  Copyright (c) 2014 Vishnu. All rights reserved.
//

#import <UIKit/UIKit.h>

//enum DropDownType {
//    NormalDropDown,
//    DateDropDown
//};


@interface OffsetCustomCell : UITableViewCell

//states our cell could be in
typedef NS_OPTIONS(NSUInteger, CustomCellState) {
    CustomCellStateDefaultMask,
    CustomCellStateShowingEditControlMask,
    CustomCellStateShowingDeleteConfirmationMask,
};
@property (nonatomic, strong) UIImageView *controlButton;
//@property (nonatomic, strong) UIButton *editButton;

@property(nonatomic,weak) IBOutlet UILabel *leftLabel;

@property (nonatomic, assign) CustomCellState currentState;
@property (nonatomic, assign) CustomCellState previousState;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL comboBoxShown;
- (void) removeOriginalEditControl;
@end
