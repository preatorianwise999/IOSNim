//
//  FlightDetailsViewController.h
//  Nimbus2
//
//  Created by Priyanka on 7/14/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellDetailsViewController.h"
#import "NSDate+DateFormat.h"
#import "UserInformationParser.h"
@interface FlightDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    NSMutableDictionary *pubdict;
    NSArray *contingencies;
}
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,strong) IBOutlet UIButton * leg1Btn;
@property (nonatomic,strong) IBOutlet UIButton * leg2Btn;
@property (nonatomic,strong) IBOutlet UIButton * leg3Btn;
@property (nonatomic,strong) IBOutlet UIButton * leg4Btn;
@property (nonatomic,strong) NSMutableArray * legs;

- (IBAction)buttonClicked:(id)sender;
- (IBAction)leg1buttonClicked:(id)sender;
- (IBAction)leg2buttonClicked:(id)sender;
- (IBAction)leg3buttonClicked:(id)sender;
- (IBAction)leg4buttonClicked:(id)sender;


@end
