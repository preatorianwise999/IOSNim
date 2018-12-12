//
//  CrewDataViewController.h
//  Nimbus2
//
//  Created by 720368 on 7/20/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UILabel+Border.h"
#import "GADViewController.h"
#import "LTAddGADViewController.h"

@interface CrewDataViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,LTAddFlightCrewProtocol,UIScrollViewDelegate>{
    int cptCount;
    NSMutableArray *captainArr;
}
@property (weak, nonatomic) IBOutlet UITableView *crewDataTable;
@property (nonatomic, retain) NSMutableArray * legArray;



@end
