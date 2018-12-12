//
//  CellDetailsViewController.m
//  Nimbus2
//
//  Created by 720368 on 8/24/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "CellDetailsViewController.h"

@interface CellDetailsViewController ()

@end

@implementation CellDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    NSDictionary *legdict = [self.legs objectAtIndex:self.index];
    if (self.index<[self.legs count]-1) {
        NSDate *arr = [legdict objectForKey:@"arrivalLocal"];
        self.legLbl.text = [legdict objectForKey:@"destination"];
        self.arrivalTimeLbl.text = [arr dateFormat:DATE_FORMAT_HH_mm];
        self.arrivalDateLbl.text = [arr dateFormat:DATE_FORMAT_EEE_DD_MMM];
        NSDictionary *legdict2 = [self.legs objectAtIndex:self.index+1];
        NSDate *dep = [legdict2 objectForKey:@"departureLocal"];
        self.departureTimeLbl.text = [dep dateFormat:DATE_FORMAT_HH_mm];
        self.departureDateLbl.text = [dep dateFormat:DATE_FORMAT_EEE_DD_MMM];
    }
    
    if ([legdict objectForKey:@"numpj"]) {
        
        self.BCDetailslbl.text=[[legdict objectForKey:@"numpj"] stringValue];
    }
    if ([legdict objectForKey:@"numpy"]) {
        self.YCDetailslbl.text=[[legdict objectForKey:@"numpy"] stringValue];
    }
    if ([legdict objectForKey:@"umnr"]) {
        self.childernlbl.text=[[legdict objectForKey:@"umnr"] stringValue];
    }
    if ([legdict objectForKey:@"wchr"]) {
        self.R1lbl.text=[NSString stringWithFormat:@"R%@",[[legdict objectForKey:@"wchr"] stringValue]];
    }
    if ([legdict objectForKey:@"wchs"]) {
        self.S1lbl.text=[NSString stringWithFormat:@"S%@",[[legdict objectForKey:@"wchs"] stringValue]];
    }
    if ([legdict objectForKey:@"wchc"]) {
        self.C1lbl.text=[NSString stringWithFormat:@"C%@",[[legdict objectForKey:@"wchc"] stringValue]];
    }
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

- (IBAction)nextLegClicked:(id)sender {
}

- (IBAction)prevLegClicked:(id)sender {
}
@end
