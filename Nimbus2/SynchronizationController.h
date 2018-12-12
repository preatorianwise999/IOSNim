//
//  SynchronizationController.h
//  Nimbus2
//
//  Created by 720368 on 8/4/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIkit/UIKit.h>
#import "Reachability.h"
#import "LTSingleton.h"
#import "ConnectionLibrary.h"
#import "RequestObject.h"
#import "DictionaryParser.h"
#import "TempLocalStorageModel.h"
#import "LTFlightReportContent.h"
#import "NSDate+DateFormat.h"
#import "SavePublicationData.h"
#import "LTGetLightData.h"
#import "LTCreateFlightReport.h"
#import "AlertUtils.h"
#import "ActivityIndicatorView.h"
#import "SaveSeatMap.h"
//#import "SynchStatusViewController.h"

extern NSString *kNotifSyncFinished;
extern NSString *kNotifBriefingDownloaded;

//#import "AddManualFlightViewController.h"
@protocol SynchDelegate<NSObject>
-(void)synchCompletedWithSuccess;
-(void)updateFlightCardForPublication:(NSDictionary*)flightDict;
-(void)synchFailedWithErrorTag:(enum status)statusTag;
-(void)synchFailedWithError:(enum errorTag)errorTag;

@end

@interface SynchronizationController : NSObject<ConnectionLibraryDelegate>{
    LTSingleton *singleton;
    NSMutableDictionary *errorDict;
    BOOL ShouldAdd;
    NSString *bpNumber;
    NSString * gadImageUri;
    BOOL isAllSyncGAD;
}
-(void)initiateSynchronization;
-(NSArray *)getFlightroaster;
-(void)actualizeDataForFlight:(NSDictionary*)flightDict Oncomplete:(void (^)(BOOL))onComplete;
-(void)notFlowanAsJSB:(NSDictionary*)flightDict completion:(void (^)(void))completionBlock;
-(void)synchManuallyAddedFlight;
-(void)synchFlightDetails;
-(void)synchCrewMembers;
-(NSMutableDictionary*)getDetailsForFlight:(NSDictionary*)flightDict;
-(NSMutableDictionary*)getGADDetailsForFlight:(NSDictionary*)flightDict forlegIndex:(int)index andCrewId:(NSString *)bpNumber;
-(BOOL)checkForInternetAvailability;
-(BOOL)checkForWifiAvailability;
-(NSDictionary *)fetchFlightInformation:(NSMutableDictionary*)flightDict;
-(void)addSingleManualFlight:(NSMutableDictionary*)newflightDict withOldFlight:(NSMutableDictionary*)oldFlightDict forMode:(enum flightAddMode)mode Oncomplete:(void (^)(void))onComplete;
-(NSString *)getHost;
-(void)savePublicationDetailsFromDict:(NSDictionary*)publicationDict;
-(void)saveGaDDict:(NSDictionary *)dict;
-(NSMutableDictionary *)getGADforCrew:(NSDictionary *)crewDict forFlight:(NSDictionary *)flightDic;
-(void)sendFeedbackGadReport:(NSDictionary *)flightReportDict;
-(void)gadCheckStatusReport:(NSDictionary *)flightReportDict;
-(NSMutableDictionary *)getGadCheckReportStatusDict:(NSDictionary *)flightReportDict;
-(void)sendCUSReportforCustomer:(NSDictionary *)customerdict forFlight:(NSMutableDictionary *)flightKeyDict forleg:(int)legNo forReportId:(NSString*)reportId fromSync:(BOOL)isfromSync;
-(void)syncCusReportsForFlightRoster:(FlightRoaster*)flight;
-(void)syncCusReportWithCompletionHandler:(void (^)(void))block;
-(void)synchBasicInfos:(NSArray*)allFutureFlights forIndex:(int)i Oncomplete:(void (^)(void))onComplete;
-(void)getAllFutureFlightList;
-(void)sendCreatedFlightReport;
-(void)syncGADReportsFlorFlightDict:(NSDictionary*)flightDict onlySyncInQueue:(BOOL)onlyInQueue;
-(void)syncAllGadReportsOncomplete:(void (^)(void))onComplete;
-(void)syncFlightReportForFlightDict:(NSDictionary*)flightDict;
-(void)synchCreateFlightForStatus:(STATUS)stat Oncomplete:(void (^)(void))onComplete;
-(void)deleteGADForCrewBp:(NSString*)crewBP ForFlight:(NSDictionary*)dict;
-(void)synchFlightSeatMapOnComplete:(void (^)(void))onComplete;
-(void)synchAllPassengerDataOnComplete:(void (^)(void))onComplete;
-(void)actualizeDataForFlightSeat:(NSDictionary*)flightDict Oncomplete:(void (^)(BOOL))onComplete;
-(void)actualizeDataForFlightPassenger:(NSDictionary*)flightDict Oncomplete:(void (^)(BOOL))onComplete;
-(BOOL)shouldSyncSeatmapAndPassengerListForFlight:(NSDictionary*)flightDictionary leg:(int)leg;
-(BOOL)shouldSyncFlight:(NSDictionary*)flightDictionary;
-(void)synchCheckStatusOncomplete:(void (^)(void))onComplete;
-(void)synchBasicInfosByIDFlight:(NSArray*)allFutureFlights forIndex:(int)i Oncomplete:(void (^)(void))onComplete;
-(void)synchNotFlownAsJSB;
-(int)syncCusReportsFlighCounter:(NSString*)idFlights;
-(void)synchFlightSeatMapOnCompleteByIdFlight:(NSString*)idFlights :(void (^)(void))onComplete;
-(void)synchAllPassengerDataOnCompleteById:(NSString *)idflight :(void (^)(void))onComplete;
-(void)syncAllGadReportsOncompleteByIdFlight:(NSString *)dateflight:(NSString *)idGAD:(NSString *)idflight:(void (^)(void))onComplete;
-(void)synchCreateFlightForStatusByIdFlight:(NSString *)idFlight :(STATUS)stat Oncomplete:(void (^)(void))onComplete;
-(void)syncCusReportWithCompletionHandlerByIdflight:(NSString*)dateflight:(NSString*)idflight:(NSString*)idReport:(NSString*)idCustomer:(void (^)(void))block;
-(void)synchCheckStatusOncompleteByIfFlight:(NSString *)idflights:(void (^)(void))onComplete;
-(void)syncCusReportsForFlightRosterIndividualCUS:(FlightRoaster*)flight:(NSString*)idflight:(NSString*)idReport:(NSString*)idCustomer;
-(void)syncGADReportsFlorFlightDictIndividuals:(NSString *)idGAD:(NSDictionary*)flightDict onlySyncInQueue:(BOOL)onlyInQueue;

@property (nonatomic,retain)id<SynchDelegate>delegate;
@property(nonatomic) int counter;
@end
