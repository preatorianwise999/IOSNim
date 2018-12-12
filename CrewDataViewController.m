//
//  CrewDataViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/20/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "CrewDataViewController.h"
#import "CrewCPTableViewCell.h"
#import "CrewJSBTableViewCell.h"
#import "CrewTCTableViewCell.h"
#import "BlurImage.h"


@interface CrewDataViewController ()

@end

@implementation CrewDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.crewDataTable.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table View datasource and Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 65.0f;
    }else if(indexPath.row==1){
        return 70.0f;
    }else{
        return 115.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        CrewCPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cpcell"];
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CrewCPTableViewCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = [topLevelObjects objectAtIndex:0];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
            [cell.contentView.layer setCornerRadius:30.0];
            tableView.separatorColor=[UIColor clearColor];
        }
        
        return cell;
    }else if(indexPath.row==1){
        CrewJSBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"jsbcell"];
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CrewJSBTableViewCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            [cell.contentView.layer setCornerRadius:30.0];
            cell.gadLabel.layer.borderWidth = 1.5f;
            cell.gadLabel.layer.borderColor = [UIColor whiteColor].CGColor;
            [cell.gadLabel.layer setCornerRadius:21];
            [cell.gadLabel createArcPathFromstart:12 end:36 withDistance:1];
            
        }
        
        return cell;
    }else{
        CrewTCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tccell"];
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CrewTCTableViewCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            [cell.contentView.layer setCornerRadius:30.0];
            cell.gadLabel.layer.borderWidth = 1.5f;
            cell.gadLabel.layer.borderColor = [UIColor whiteColor].CGColor;
            [cell.gadLabel.layer setCornerRadius:28];
            [cell.gadLabel setText:@"5"];
            
        }
        
        return cell;
    }
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    GADViewController *gadVC = [[GADViewController alloc] initWithNibName:@"GADViewController" bundle:nil];
    UIViewController *vc= self.navigationController.topViewController;
    [vc addChildViewController:gadVC];
     [self.navigationController.topViewController.view addSubview:gadVC.view];
    [gadVC didMoveToParentViewController:vc];

}
@end
