//
//  WBFirstIFEViewController.h
//  LATAM
//
//  Created by Durga Madamanchi on 4/14/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "ComboNumTextText.h"
#import "CustomViewController.h"

@interface WBFirstIFEViewController :  CustomViewController <ComboNumTextTextDelegate>
@property (weak, nonatomic) IBOutlet UITableView *IFEtableView;
@property(nonatomic,strong)NSMutableArray *individualFailureArray;
@property(nonatomic,strong)NSMutableArray *massiveFailuresArray;
@property(nonatomic,strong)NSMutableArray *stateOfSystemArray;
@property(nonatomic,strong)NSMutableArray *descriptionofFailureArray;
@property(nonatomic,strong)NSMutableArray *correctiveActionArray;
@property(nonatomic,strong)NSMutableArray *finalSystemStatusArray;
@property (weak, nonatomic) IBOutlet UILabel *_headingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;

- (OffsetCustomCell *)createCellForTableView:(UITableView *)tableView withCellID:(NSString *)cellID;
@end
