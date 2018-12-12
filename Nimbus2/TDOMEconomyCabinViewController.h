//
//  TDOMEconomyCabinViewController.h
//  LATAM
//
//  Created by Ankush Jain on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface TDOMEconomyCabinViewController : CustomViewController

@property(nonatomic,strong) NSMutableArray *bathroomsArr;
@property(nonatomic,strong) NSMutableArray *galleyArr;
@property(nonatomic,strong) NSMutableArray *cabinArr;
@property(nonatomic,strong) NSMutableArray *faultySeatArr;
@property(nonatomic,strong) NSMutableArray *tempratureArr;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;


@end
