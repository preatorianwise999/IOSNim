//
//  FilterButton.m
//  SeatMapSample
//
//  Created by Rajashekar on 13/10/15.
//  Copyright (c) 2015 Rajashekar. All rights reserved.
//

#import "FilterButton.h"

@interface FilterButton () {
    
    UILabel *firstLineLabel;
    UILabel *secondLineLabel;
    
}

@end

@implementation FilterButton
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)modifyQuantity:(NSString *)quantityText andButtonName: (NSString *)name {
    
    if (firstLineLabel==nil) {
    
    firstLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 12, 43, 17)];
    firstLineLabel.font = [UIFont systemFontOfSize:23];
        firstLineLabel.textColor = [UIColor whiteColor];
    firstLineLabel.textAlignment = NSTextAlignmentCenter;
     //   firstLineLabel.backgroundColor = [UIColor yellowColor];
    [self addSubview:firstLineLabel];
    }
    firstLineLabel.text = quantityText;

    if (secondLineLabel==nil) {
    secondLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 31, 37, 12)];
    secondLineLabel.font = [UIFont systemFontOfSize:12];
    secondLineLabel.textColor = [UIColor whiteColor];
    secondLineLabel.textAlignment = NSTextAlignmentCenter;
    //    secondLineLabel.backgroundColor = [UIColor whiteColor];

    [self addSubview:secondLineLabel];
    }
    secondLineLabel.text = name;
    
}
-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        firstLineLabel.textColor = [UIColor blackColor];
        secondLineLabel.textColor = [UIColor blackColor];
    }else {
        firstLineLabel.textColor = [UIColor whiteColor];
        secondLineLabel.textColor = [UIColor whiteColor];

    }
    
}
/*-(void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        firstLineLabel.textColor = [UIColor blackColor];

        secondLineLabel.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"N__0003_cir_sel.png"]];

    }else {
        firstLineLabel.textColor = [UIColor whiteColor];
        
        secondLineLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"N__0007_cir_nor.png"]];

    }
 
    
}*/
@end
