//
//  GADSingleTableViewCell.m
//  Nimbus2
//
//  Created by 720368 on 7/24/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "GADSingleTableViewCell.h"

@implementation GADSingleTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.BE setUnclicked];
    [self.PE setUnclicked];
    [self.E setUnclicked];
    [self.SE setUnclicked];
    [self.EX setUnclicked];
    [self.NOT setUnclicked];
    [self.oldButton setClicked];
}

-(void)clearButtons{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setButtonclicked:(UIButton*)button{
    [button setClicked];
    
}
-(void)selectButtonWithTag:(NSInteger)tag{
    if (tag>=101 && tag<=106) {
        _oldButton=(UIButton*)[self viewWithTag:tag];
        [_oldButton setClicked];
    }
    
}
- (IBAction)selectButtonClicked:(id)sender {
    [_oldButton setUnclicked];
    UIButton *newButton = (UIButton *)sender;
    [newButton setClicked];
    _oldButton=newButton;
    NSNotification *notification = [[NSNotification alloc] initWithName:@"GADValueSelection" object:nil userInfo:[NSDictionary dictionaryWithObject:@(_oldButton.tag) forKey:self.headingLabel.text]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(NSDictionary*)getSelectedValue{
   if (_oldButton==nil) {
    NSLog(@"canot be empty");
     return [[NSDictionary alloc] init];
   }
     return [NSDictionary dictionaryWithObject:_oldButton.titleLabel.text forKey:self.detailsLabel.text];
}
@end
