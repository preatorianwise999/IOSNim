//
//  DownloadManuals.h
//  Nimbus2
//
//  Created by Sravani Nagunuri on 03/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreManuals.h"
#import "AppDelegate.h"

@interface DownloadManuals : NSObject


- (NSString*)getRelativeURLPath;
- (void)downloadManuals: (NSArray*)manualList;
- (void)downloadNextManual;
- (void)cancelDownloadingManuals;
- (void)stopManualDownloader;


-(NSString *)getHost;

@property (nonatomic,getter = isReachable) BOOL reachable;
@property(nonatomic)BOOL isRunning;

+(DownloadManuals*)shareInstance;
@end
