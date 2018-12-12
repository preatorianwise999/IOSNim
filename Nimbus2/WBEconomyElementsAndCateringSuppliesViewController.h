//
//  WBEconomyElementsAndCateringSuppliesViewController.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "TestView.h"
#import "CustomViewController.h"

@interface WBEconomyElementsAndCateringSuppliesViewController : CustomViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PopoverDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

@property(nonatomic,strong) NSMutableArray *apvElementsArr;
@property(nonatomic,strong) NSMutableArray *catElementsArr;
@property(nonatomic,strong) NSMutableArray *securityElementsArr;
@property(nonatomic,strong) NSMutableArray *bathElementsArr;
@property(nonatomic,strong) NSMutableArray *galleyElementsArr;
@property(nonatomic,strong) NSMutableArray *liquidsElementsArr;
@property(nonatomic,strong) NSMutableArray *mealsElementsArr;

@end

