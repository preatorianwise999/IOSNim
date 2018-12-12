//
//  LTSelectRankViewController.m
//  LATAM
//
//  Created by Madan on 6/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTSelectRankViewController.h"

@interface LTSelectRankViewController ()

@end

@implementation LTSelectRankViewController
@synthesize activeRankArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"rankValue"];
   
    if (savedValue) {
         self.selectedString = savedValue;
    }
    else {
        self.selectedString = [activeRankArray firstObject];
    }
    
    // Do any additional setup after loading the view from its nib.
    
    float height = 65 * [self.activeRankArray count];
    self.rankTBView.frame = CGRectMake(self.rankTBView.frame.origin.x ,self.rankTBView.frame.origin.y, self.rankTBView.frame.size.width,height);
    
    [self.rankTBView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark -Table view delegage mathods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 65 * [self.activeRankArray count];
    self.rankTBView.frame = CGRectMake(self.rankTBView.frame.origin.x,self.rankTBView.frame.origin.y, self.rankTBView.frame.size.width,height);
    
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [activeRankArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil) {
        
        cell =  [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    // Configure the cell...
    
    NSString *cuStr = [activeRankArray objectAtIndex:indexPath.row];
    if ([self.selectedString isEqualToString:cuStr]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [activeRankArray objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    cell.textLabel.textColor = [UIColor colorWithRed:91/255.0 green:91/255.0 blue:91/255.0 alpha:1.0];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
    [self.delegate selectedRankString:[activeRankArray objectAtIndex:indexPath.row]];
    
    NSString *valueToSave = [activeRankArray objectAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"rankValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.presentedPopOverController dismissPopoverAnimated:YES];
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (self.presentedPopOverController) {
        [self.presentedPopOverController dismissPopoverAnimated:YES];
    }
}

@end
