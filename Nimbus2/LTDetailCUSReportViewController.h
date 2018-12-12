//
//  LTDetailCUSReportViewController.h
//  LATAM
//
//  Created by Durga Madamanchi on 5/13/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Customer.h"
#import "CusReport.h"
#import "CustomViewController.h"
#import "FlightRoaster.h"


@interface LTDetailCUSReportViewController : CustomViewController <UITextFieldDelegate,UITextViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *CUSTableView;
@property (nonatomic,strong) NSMutableArray *associatedLegArray;
@property (nonatomic,strong) NSMutableArray *passingerInfoArray;
@property (nonatomic,strong) NSMutableArray *seatManteinanceArray;
@property (nonatomic,strong) NSMutableArray *actionTakenArray;
@property (nonatomic,strong) Customer *customer;
@property (nonatomic,strong) CusReport *report;
@property (strong,nonatomic) FlightRoaster *flightRoster;
@property (nonatomic,strong) NSManagedObjectContext *localMoc;
@property (nonatomic,strong) NSMutableArray *legsArray;
@property (nonatomic,strong) NSMutableDictionary *customerDict;
@property (nonatomic) BOOL readonly;

-(void)initiallizeData;

-(BOOL)validateMandatoryFields;

@end
