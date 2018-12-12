//
//  OffsetCustomCell.m
//  GeneralLatam
//
//  Created by Vishnu on 20/03/14.
//  Copyright (c) 2014 Vishnu. All rights reserved.
//

#import "OffsetCustomCell.h"
#import "LTSingleton.h"
#import "LegInformationCell.h"
#import "AlertUtils.h"
#import "AppDelegate.h"
@implementation OffsetCustomCell
@synthesize controlButton, currentState, previousState, indexPath,comboBoxShown;

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//is not used here beause we're loading from storyboard

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        //add our custom controlbutton to view
        controlButton = [[UIImageView alloc] initWithFrame:CGRectZero]; //(Watch it, Automatic Reference Counting is used here!)
        [self addSubview:controlButton]; //to the view, not to the contentView!
        //default states
        previousState = CustomCellStateDefaultMask;
        currentState = CustomCellStateDefaultMask;
    }
    return self;
}

-(void)awakeFromNib {
    NSArray *subViews;
    if(ISiOS8) {
        subViews = [[[self subviews] firstObject] subviews];
    }
    else
        subViews = [[[[[self subviews] firstObject] subviews] objectAtIndex:1] subviews];
    
    
    for(UIView *textView in subViews){
        if([textView class] == [UITextField class]){
            if(textView.tag != kSeatRowLetterTag){
                textView.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
            }
            textView.layer.borderColor =[[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
            textView.layer.borderWidth = 1.0f;
            [textView setBackgroundColor: [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.3]];
        }
    }
}

-(void)didTransitionToState:(UITableViewCellStateMask)state {
    [super didTransitionToState:state];
    [self removeOriginalEditControl];
}

- (void)willTransitionToState:(UITableViewCellStateMask)newState {
    [super willTransitionToState:newState];
    if ((newState & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                UIImageView *deleteBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 64, 33)];
                [deleteBtn setImage:[UIImage imageNamed:@"delete.png"]];
                [[subview.subviews objectAtIndex:0] addSubview:deleteBtn];
            }
        }
    }
    
    if(newState == 3 && [self isKindOfClass:[LegInformationCell class]]) {
        AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [AlertUtils showErrorAlertWithTitle:[apDel copyTextForKey:@"WARNING"] message:[apDel copyTextForKey:@"DELETE_LEG_DELETE_DATA"]];
    }
    
    //Animate button in in the next [self layoutsubviews] call
    if(newState == UITableViewCellStateShowingEditControlMask && [self currentState] == CustomCellStateDefaultMask){
        [self setPreviousState:CustomCellStateDefaultMask];
        [self setCurrentState:CustomCellStateShowingEditControlMask];
    }
    
    //Animate button out in the next [self layoutsubviews] call
    if(newState == UITableViewCellStateDefaultMask && [self currentState] == CustomCellStateShowingEditControlMask){
        [self setPreviousState:CustomCellStateShowingEditControlMask];
        [self setCurrentState:CustomCellStateDefaultMask];
    }
    
    //Turn button 90 degrees ccw in the next [self layoutsubviews] call
    if(newState == 3 && [self currentState] == CustomCellStateShowingEditControlMask){
        
        [self setPreviousState:CustomCellStateShowingEditControlMask];
        [self setCurrentState:CustomCellStateShowingDeleteConfirmationMask];
    }
    
    //Turn delete button 90 degrees cw in the next [self layoutsubviews] call
    if(newState == UITableViewCellStateShowingEditControlMask && [self currentState] == CustomCellStateShowingDeleteConfirmationMask){
        [self setPreviousState:CustomCellStateShowingDeleteConfirmationMask];
        [self setCurrentState:CustomCellStateShowingEditControlMask];
    }
}

#define radius 10

-(void) layoutSubviews {
    [super layoutSubviews];
    CGRect newFrame = self.controlButton.frame;
    newFrame.origin.y = (self.frame.size.height - self.controlButton.image.size.height) * 0.5;
    newFrame.size = CGSizeMake(23, 23);
    if([controlButton.image isEqual:[UIImage imageNamed:@"add"]]) {
        newFrame.origin.y = 28;
    }
    if([controlButton.image isEqual:[UIImage imageNamed:@"remove"]]) {
        newFrame.origin.y = 28;
    }
    if([NSStringFromClass([self class]) isEqualToString:@"ComboBoxTextCell"]) {
        newFrame.origin.y = 30;
        
    }
    if([NSStringFromClass([self class]) isEqualToString:@"TextTextCell"]) {
        newFrame.origin.y = 25;
        
    }
    if([NSStringFromClass([self class]) isEqualToString:@"TextFieldNameCell"]) {
        newFrame.origin.y = 21;
        
    }
    if([NSStringFromClass([self class]) isEqualToString:@"LegInformationCell"]) {
        newFrame.origin.x = 42;
        newFrame.origin.y = 13;
        //Make your changes in it.
    }
    
    newFrame.origin.x = 42;
    newFrame.origin.y = 13;
    
    if([NSStringFromClass([self class]) isEqualToString:@"LegInformationCell"]){
        newFrame = self.controlButton.frame;
        newFrame.origin.y = (self.frame.size.height - self.controlButton.image.size.height) * 0.5;
        newFrame.size = CGSizeMake(23, 23);
        newFrame.origin.x = 10;
        if([controlButton.image isEqual:[UIImage imageNamed:@"add"]]) {
            newFrame.origin.y = 28;
        }
        else if([controlButton.image isEqual:[UIImage imageNamed:@"remove"]]) {
            newFrame.origin.y = 15;
        }
    }
    
    if ([controlButton.image isEqual:[UIImage imageNamed:@"N__0002_plus.png"]]) {
        newFrame.origin.x = 10;
    }
    
    if([self currentState] != CustomCellStateDefaultMask){
        [self removeOriginalEditControl];
    }
    
    if([self currentState] == CustomCellStateShowingDeleteConfirmationMask && self.comboBoxShown){
        [UIView animateWithDuration:0.4 animations:^{
            ((UIScrollView *)[[self subviews] firstObject]).contentOffset = CGPointMake(0, 0);
        }];
    }
    // end removing Delete
    self.controlButton.frame = newFrame;
}

//helper
- (void) removeOriginalEditControl{
    //remove apple's delete or add button
    NSArray *subViews;
    if(ISiOS8) {
        subViews = [self subviews];
    }
    else
        subViews = [[self.subviews objectAtIndex:0] subviews];
    
    for (UIView *subview in subViews) {
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellEditControl"]) {
            
            subview.center = self.controlButton.center;
            
            for (UIView *subsubview in subview.subviews) {
                if ([NSStringFromClass([subsubview class]) isEqualToString:@"UIImageView"]) {
                    [subsubview removeFromSuperview];
                }
            }
        }
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

