//
//  FlightTypePopoverController.m
//  LATAM
//
//  Created by Ankush Jain on 5/7/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "FlightTypePopoverController.h"

@interface FlightTypePopoverController ()

@end

@implementation FlightTypePopoverController
@synthesize dataSource,delegate,btnTag,prevText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.dataSource count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    
 
    
    if([prevText isEqualToString:[self.dataSource objectAtIndex:indexPath.row]]){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick_grey"]];
        imageView.frame = CGRectMake(0, 0, 14, 14);
        cell.accessoryView = imageView;
    }
    else
        cell.accessoryView = nil;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *oldCell =[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource indexOfObject:prevText] inSection:0]];
    oldCell.accessoryView = nil;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick_grey"]];
    imageView.frame = CGRectMake(0, 0, 14, 14);
    cell.accessoryView = imageView;
    
    [self.delegate setSelectedValue:[self.dataSource objectAtIndex:indexPath.row] forViewWithTag:btnTag];

}
@end
