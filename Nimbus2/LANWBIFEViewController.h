//
//  LANWBIFEViewController.h
//  LATAM
//
//  Created by Vishnu on 17/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OffsetCustomCell.h"
#import "CustomViewController.h"

@interface LANWBIFEViewController : CustomViewController{
    BOOL needReload;
}
@property (weak, nonatomic) IBOutlet UILabel *_headingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *header_Line;
@property (weak, nonatomic) IBOutlet UITableView *IFEtableView;
@property(nonatomic,strong)NSMutableArray *massiveFailuresArray;
@property(nonatomic,strong)NSMutableArray *stateOfSystemArray;
@property(nonatomic,strong)NSMutableArray *descriptionofFailureArray;
@property(nonatomic,strong)NSMutableArray *correctiveActionArray;
@property(nonatomic,strong)NSMutableArray *finalSystemStatusArray;
- (OffsetCustomCell *)createCellForTableView:(UITableView *)tableView withCellID:(NSString *)cellID;


@end
