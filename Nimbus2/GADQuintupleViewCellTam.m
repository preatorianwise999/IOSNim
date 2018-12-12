//
//  GADQuintupleViewCellTam.m
//  Nimbus2
//
//  Created by 720368 on 7/22/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "GADQuintupleViewCellTam.h"

@implementation GADQuintupleViewCellTam

- (void)awakeFromNib {
    // Initialization code
    [self.AE setUnclicked];
    [self.PE setUnclicked];
    [self.E setUnclicked];
    [self.SE setUnclicked];
    [self.EX setUnclicked];
    [self.NOT setUnclicked];
    [self.AE2 setUnclicked];
    [self.PE2 setUnclicked];
    [self.E2 setUnclicked];
    [self.SE2 setUnclicked];
    [self.EX2 setUnclicked];
    [self.NOT2 setUnclicked];
    [self.AE3 setUnclicked];
    [self.PE3 setUnclicked];
    [self.E3 setUnclicked];
    [self.SE3 setUnclicked];
    [self.EX3 setUnclicked];
    [self.NOT3 setUnclicked];
    [self.AE4 setUnclicked];
    [self.PE4 setUnclicked];
    [self.E4 setUnclicked];
    [self.SE4 setUnclicked];
    [self.EX4 setUnclicked];
    [self.NOT4 setUnclicked];
    [self.AE5 setUnclicked];
    [self.PE5 setUnclicked];
    [self.E5 setUnclicked];
    [self.SE5 setUnclicked];
    [self.EX5 setUnclicked];
    [self.NOT5 setUnclicked];
    clickedButtonsText = [[NSMutableArray alloc] initWithObjects:@(0),@(0),@(0),@(0),@(0), nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)selectButtonWithTag5:(NSInteger)tag1 andTag2:(NSInteger)tag2 andTag3:(NSInteger)tag3 andTag4:(NSInteger)tag4 andTag5:(NSInteger)tag5{
    if (tag1>=102 && tag1<=107) {
        oldButton = (UIButton*)[self viewWithTag:tag1];
        [oldButton setClicked];
    }
    if (tag2>=201 && tag2<=207){
        oldButton2 = (UIButton*)[self viewWithTag:tag2];
        [oldButton2 setClicked];
    }
    if (tag3>=301 && tag3<=307){
        oldButton3 = (UIButton*)[self viewWithTag:tag3];
        [oldButton3 setClicked];
    }
    if (tag4>=401 && tag4<=407){
        oldButton4 = (UIButton*)[self viewWithTag:tag4];
        [oldButton4 setClicked];
    }
    if (tag5>=501 && tag5<=507){
        oldButton5 = (UIButton*)[self viewWithTag:tag5];
        [oldButton5 setClicked];
    }
    [clickedButtonsText replaceObjectAtIndex:0 withObject:@(tag1)];
    [clickedButtonsText replaceObjectAtIndex:1 withObject:@(tag2)];
    [clickedButtonsText replaceObjectAtIndex:2 withObject:@(tag3)];
    [clickedButtonsText replaceObjectAtIndex:3 withObject:@(tag4)];
    [clickedButtonsText replaceObjectAtIndex:4 withObject:@(tag5)];
}

- (IBAction)selectButtonClicked:(id)sender {
    [oldButton setUnclicked];
    UIButton *newButton = (UIButton *)sender;
    [newButton setClicked];
    oldButton=newButton;
    [clickedButtonsText replaceObjectAtIndex:0 withObject:@(oldButton.tag)];
    NSNotification *notification = [[NSNotification alloc] initWithName:@"GADValueSelection" object:nil userInfo:[NSDictionary dictionaryWithObject:clickedButtonsText forKey:self.headingLabel.text]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)selectButtonClicked2:(id)sender {
    [oldButton2 setUnclicked];
    UIButton *newButton = (UIButton *)sender;
    [newButton setClicked];
    oldButton2=newButton;
    [clickedButtonsText replaceObjectAtIndex:1 withObject:@(oldButton2.tag)];
    NSNotification *notification = [[NSNotification alloc] initWithName:@"GADValueSelection" object:nil userInfo:[NSDictionary dictionaryWithObject:clickedButtonsText forKey:self.headingLabel.text]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)selectButtonClicked3:(id)sender {
    [oldButton3 setUnclicked];
    UIButton *newButton = (UIButton *)sender;
    [newButton setClicked];
    oldButton3=newButton;
    [clickedButtonsText replaceObjectAtIndex:2 withObject:@(oldButton3.tag)];
    NSNotification *notification = [[NSNotification alloc] initWithName:@"GADValueSelection" object:nil userInfo:[NSDictionary dictionaryWithObject:clickedButtonsText forKey:self.headingLabel.text]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)selectButtonClicked4:(id)sender {
    [oldButton4 setUnclicked];
    UIButton *newButton = (UIButton *)sender;
    [newButton setClicked];
    oldButton4=newButton;
    [clickedButtonsText replaceObjectAtIndex:3 withObject:@(oldButton4.tag)];
    NSNotification *notification = [[NSNotification alloc] initWithName:@"GADValueSelection" object:nil userInfo:[NSDictionary dictionaryWithObject:clickedButtonsText forKey:self.headingLabel.text]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)selectButtonClicked5:(id)sender {
    [oldButton5 setUnclicked];
    UIButton *newButton = (UIButton *)sender;
    [newButton setClicked];
    oldButton5=newButton;
    [clickedButtonsText replaceObjectAtIndex:4 withObject:@(oldButton5.tag)];
    NSNotification *notification = [[NSNotification alloc] initWithName:@"GADValueSelection" object:nil userInfo:[NSDictionary dictionaryWithObject:clickedButtonsText forKey:self.headingLabel.text]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(NSDictionary*)getSelectedValue{
    if (oldButton == nil || oldButton2 == nil || oldButton3 == nil || oldButton4 == nil || oldButton5 == nil) {
        NSLog(@"canot be empty");
        return nil;
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:oldButton.titleLabel.text, self.detailsLabel1.text,oldButton2.titleLabel.text,self.detailsLabel2.text,oldButton3.titleLabel.text,self.detailsLabel3.text, oldButton4.titleLabel.text,self.detailsLabel4.text,oldButton5.titleLabel.text,self.detailsLabel5.text, nil];
}

@end
