//
//  DOMEconomyElementAPVViewController.h
//  Nimbus2
//
//  Created by Priyanka on 07/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"


@interface DOMEconomyElementAPVViewController : CustomViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PopoverDelegate>

@property(nonatomic,strong) NSMutableArray *apvElementsArr;
@property(nonatomic,strong) NSMutableArray *catElementsArr;
@property(nonatomic,strong) NSMutableArray *securityElementsArr;
@property(nonatomic,strong) NSMutableArray *bathElementsArr;
@property(nonatomic,strong) NSMutableArray *galleyElementsArr;
@property(nonatomic,strong) NSMutableArray *liquidsElementsArr;
@property(nonatomic,strong) NSMutableArray *mealsElementsArr;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@end