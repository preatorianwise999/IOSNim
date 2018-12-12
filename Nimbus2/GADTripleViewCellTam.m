//
//  GADTripleViewCellTam.m
//  Nimbus2
//
//  Created by 720368 on 7/22/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "GADTripleViewCellTam.h"

@implementation GADTripleViewCellTam

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
    clickedButtonsText = [[NSMutableArray alloc] initWithObjects:@(0),@(0),@(0), nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)selectButtonWithTag2:(NSInteger)tag1 andTag2:(NSInteger)tag2 andTag3:(NSInteger)tag3{
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
    [clickedButtonsText replaceObjectAtIndex:0 withObject:@(tag1)];
    [clickedButtonsText replaceObjectAtIndex:1 withObject:@(tag2)];
    [clickedButtonsText replaceObjectAtIndex:2 withObject:@(tag3)];
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

-(NSDictionary*)getSelectedValue{
    if (oldButton == nil || oldButton2 == nil || oldButton3 == nil) {
        NSLog(@"canot be empty");
        return nil;
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:oldButton.titleLabel.text, self.detailsLabel1.text,oldButton2.titleLabel.text,self.detailsLabel2.text,oldButton3.titleLabel.text,self.detailsLabel3.text, nil];
}

@end
