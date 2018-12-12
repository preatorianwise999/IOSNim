//
//  LTSingleton.h
//  LATAM
//
//  Created by Palash on 05/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OffsetCustomCell.h"
#import "Customer.h"
#import "TempLocalStorageModel.h"
#import "CrewMembers.h"
#import "CUSReportImages.h"

@interface LTSingleton : NSObject

+(LTSingleton *)getSharedSingletonInstance;
@property(nonatomic,strong) NSString *username;
@property(nonatomic,strong) NSString *password;
@property(nonatomic,strong) NSString *lastSynchDate;
@property(nonatomic,strong) NSMutableDictionary *flightKeyDict;
@property(nonatomic,strong) NSMutableDictionary *flightRoasterDict;
@property(nonatomic,strong) NSMutableDictionary *flightCUSDict;
@property(nonatomic,strong) NSMutableDictionary *flightGADDict;
@property (nonatomic,strong) NSMutableDictionary *flightJsonGADDict;
@property(nonatomic,strong) NSString *user;
@property(nonatomic,strong) NSString *flightName;
@property(nonatomic,retain) NSString *flightDate;
@property(nonatomic,strong) NSString *materialType;
@property(nonatomic,strong) NSDictionary *urlDict;

@property(nonatomic,strong) Customer *currentCustomer;
@property(nonatomic,strong) CrewMembers *currentCrewMember;
@property(nonatomic,strong) CUSReportImages *cusImages;


@property(nonatomic) BOOL isDataChanged;
@property(nonatomic) BOOL alertShowed;
@property(nonatomic) BOOL synchStatus;
@property(nonatomic,assign)BOOL isCusStatusUpdated;
@property(nonatomic)BOOL isCusSynced;
@property(nonatomic,strong) NSMutableDictionary *legExecutedDict;
@property(nonatomic,strong) NSString *legName;
@property BOOL isFromMasterScreen;
@property BOOL legPressed;
@property BOOL isLoggingIn;
@property BOOL isCusCamera;

@property(nonatomic,strong)NSMutableArray *favArrayList;
@property(nonatomic,strong)NSMutableDictionary *favDictList;
@property(nonatomic,strong)NSMutableArray *bookmarkList;
@property(nonatomic,strong)NSMutableDictionary *currentFlightReportDict;
@property(nonatomic) BOOL isUserChanged;
@property(nonatomic,strong) NSString *emailValid;
@property(nonatomic,strong) NSIndexPath *emailIndexpath;
@property(nonatomic) BOOL isComingFromBackG;
@property(nonatomic) BOOL isCardTapped;

@property(nonatomic, strong) NSMutableDictionary *errorDict;

@property(nonatomic,strong) NSMutableArray *flightReportViewControllersArray;

@property BOOL isFromViewSummary;

//Switch Value
@property(nonatomic) BOOL enableCells;
@property(nonatomic,retain) NSMutableDictionary *enableCellsDictionary;
@property(nonatomic) int legNumber;
-(void)initializeFav;
-(void)initializeFavDict;
-(void)initializeBookmarkList;
-(void)initializeEnableDictionary;
-(NSString*)zipFolder:(NSString *)folderName andWithImageFolder:(NSString *)imageFolderName withFlodername:(NSString*)flodername;
-(NSString*)zipFolder:(NSString *)folderName andWithImageFolder:(NSString *)imageFolderName withFlodername:(NSString*)flodername actualfilePath:(NSString *)actualfilepath;
-(NSString *)gadZipFolder;

//Send Report
@property(nonatomic) BOOL sendReport;
@property(nonatomic) BOOL sendCusReport;
@property(nonatomic,retain) NSMutableDictionary *reportDictionary;
@property(nonatomic,retain) NSMutableDictionary *cusReportDictionary;

@property(nonatomic) int legCount;
-(BOOL)mandatoryCellContainsData:(OffsetCustomCell *)cell;
-(NSIndexPath *)validateCell:(OffsetCustomCell *)cell withLeastIndexPath:(NSIndexPath *)leastIndexPath;
-(NSIndexPath *)validateCusCell:(OffsetCustomCell *)cell withLeastIndexPath:(NSIndexPath *)leastIndexPath;
-(NSIndexPath *)updateLeastIndexPath:(NSMutableArray *)indexPathArray withTable:(UITableView *)tableView;
-(NSIndexPath *)upcusdateLeastIndexPath:(NSMutableArray *)indexPathArray withTable:(UITableView *)tableView;
-(BOOL)cusmandatoryCellContainsData:(OffsetCustomCell *)cell;
//Replicate Modified General Information
@property(nonatomic,retain) NSMutableDictionary *generalDictionary;
@property(nonatomic,retain) NSDate *synchDate;

//for image count
@property(nonatomic) int imageCount;

//Current FlightStatus
//@property(nonatomic) STATUS currentFlightStatus;

@property(nonatomic) BOOL isDutyIndexPathZero;



@end
