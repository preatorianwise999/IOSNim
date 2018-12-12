//
//  DownloadLibrary.h
//  Nimbus2
//
//  Created by Sravani Nagunuri on 03/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Manuals.h"
//#import "Reachability.h"


@protocol DownloadProtocol <NSObject>

- (void)downloadSucceededForFile: (NSString*)destination manual:(NSDictionary*)manualDict;
- (void)downloadFailedForFile: (NSString*)destination withMessage: (NSString*)message  manual:(NSDictionary*)manualDict;
- (void)downloadCancelledForFile: (NSString*)destination withMessage: (NSString*)message manual:(NSDictionary*)manualDict;

@end

@interface DownloadLibrary : NSObject

@property (nonatomic) id<DownloadProtocol> downloadDelegate;
@property (nonatomic,getter = isReachable) BOOL reachable;
@property (nonatomic,strong) NSDictionary *manualDict;
@property (nonatomic) BOOL stopDownloading;

-(void)downloadFileFromSource: (NSString*)source toDest: (NSString*)destination ofSize: (double)size;
- (void)cancelDownload;

@end

