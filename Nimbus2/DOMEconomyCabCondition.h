//
//  NBCabConditionViewController.h
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface DOMEconomyCabCondition : CustomViewController
@property(nonatomic,strong) NSMutableArray *stateCabConditioningArr;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end
