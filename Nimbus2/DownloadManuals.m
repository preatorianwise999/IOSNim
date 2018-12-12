//
//  DownloadManuals.m
//  Nimbus2
//
//  Created by Sravani Nagunuri on 03/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "DownloadManuals.h"
#import "DownloadLibrary.h"
#import "StoreManuals.h"
//#import "Reachability.h"
#import "DeleteManual.h"
#import "AppDelegate.h"

@interface DownloadManuals () <DownloadProtocol>

@property (nonatomic, retain) NSArray *manuals;
@property (nonatomic, assign) NSInteger currentManualIndex;
@property (nonatomic, assign) NSInteger manualsCount;
@property (nonatomic) DownloadLibrary *downloadLibrary;


@property(nonatomic)BOOL stopDownloading;

@end

@implementation DownloadManuals

//singleton instance
+(DownloadManuals*)shareInstance {
    static DownloadManuals *downloadManuals = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManuals = [[DownloadManuals alloc] init];
    });
    return downloadManuals;
}


-(NSString *)getHost
{
   
    if([PORT isEqualToString:@"80"])
        return [NSString stringWithFormat:@"%@",HOSTNAME];
    else
        return [NSString stringWithFormat:@"%@:%@",HOSTNAME,PORT];
    
}

- (NSString*)getRelativeURLPath {
    NSString *url = URI;
    return url;
}

#pragma mark -- download operations
//download list of manuals
- (void)downloadManuals: (NSArray*)manualList {
    
    NSLog(@"Download manuals started");
    _stopDownloading = NO;
    self.manuals = manualList;
    self.currentManualIndex = -1;
    self.manualsCount = [self.manuals count];
    self.downloadLibrary = [[DownloadLibrary alloc] init];
    [self.downloadLibrary setDownloadDelegate: self];
    NSLog(@"manuals Arr %@", self.manuals);
    [self downloadNextManual];
}

//downloading next manual
- (void)downloadNextManual {
    
    self.currentManualIndex++;
    if (self.currentManualIndex >= self.manuals.count) {
        _isRunning = NO;
        NSLog(@"************ Download manuals completed ****************");
        return;
    }
    
    NSLog(@"-------------- Download STARTED FOR INDEX  %d / %d  -----------", (int)self.currentManualIndex, (int)self.manuals.count);
    
    NSDictionary *currentManual = [self.manuals objectAtIndex:self.currentManualIndex];
    
    NSArray *keys = [currentManual allKeys];
    if ([keys count] == 0) {
        [self downloadNextManual];
    } else {
        NSString *path = [keys objectAtIndex:0];
        NSDictionary *currentManualDict = [currentManual objectForKey: path];
        NSString *sourceURL = [NSString stringWithFormat:@"%@%@", [self getRelativeURLPath], [currentManualDict objectForKey: kManualURI]];
        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *destinataion = [NSString stringWithFormat: @"%@/%@/%@", documentsPath,LATAM_MANUALS_DIR_NAME, path];
        _isRunning = YES;
        self.downloadLibrary.manualDict = currentManual;
        [self.downloadLibrary downloadFileFromSource: sourceURL toDest: destinataion ofSize: [[currentManualDict objectForKey:kManualSize] doubleValue]];
    }
}

- (void)stopManualDownloader {
    
    NSLog(@"cancelDownloadingManuals");
    if (_downloadLibrary) {
        _downloadLibrary.stopDownloading = YES;
        [_downloadLibrary cancelDownload];
    }
    
    _stopDownloading = YES;
}

- (void)cancelDownloadingManuals {
    
    [self stopManualDownloader];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MANUALS object:self];
}

- (BOOL)checkIfFileEmpty:(NSDictionary*)manualDict {
    BOOL isEmpty = NO;
    NSString *filePath = [manualDict objectForKey:kManualPath];
    NSDictionary * properties = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSNumber * destSize = [properties objectForKey: NSFileSize];
    if (destSize.intValue == 0) {
        isEmpty = YES;
    }
    return isEmpty;
}

#pragma mark - DownloadProtocol Methods
- (void)downloadSucceededForFile: (NSString*)destination manual:(NSDictionary *)manualDict {
    
    NSLog(@"Send download success notification & update DB %@", destination);
    
    NSDictionary *currentManual = manualDict;
    //update DB
    StoreManuals *storeManual = [[StoreManuals alloc] init];
    [storeManual updateSuccessDownloadStatusOfManual: currentManual];
    
    //Notification download success
    NSArray *keys = [currentManual allKeys];
     AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([keys count] > 0) {
        
        NSString *path = [keys objectAtIndex:0];
        if([path rangeOfString:[NSString stringWithFormat:@"_%@",[appdelegate copyTextForKey:@"NEW"]] options:1].length>0) {
            path=[path stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%@",[appdelegate copyTextForKey:@"NEW"]] withString:@""];
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *destinataion = [NSString stringWithFormat: @"%@/%@/%@", documentsPath, LATAM_MANUALS_DIR_NAME, path];
            
            NSDictionary *newdict=[currentManual objectForKey:[keys objectAtIndex:0]];
            NSString *newDate=[newdict objectForKey:kManualDate];
            NSDictionary *manualDict = [NSDictionary dictionaryWithObjectsAndKeys: destinataion, kManualPath, DOWNLOAD_STATUS_SUCCESS, kManualDownloadStatus, newDate,kManualDate,nil];
            if (!_stopDownloading) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_MANUAL_NOTIFICATION
                                                                    object:nil
                                                                  userInfo:manualDict];
            }
        }
        else {
            
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *destinataion = [NSString stringWithFormat: @"%@/%@/%@", documentsPath, LATAM_MANUALS_DIR_NAME, path];
            
            NSDictionary *manualDict = [NSDictionary dictionaryWithObjectsAndKeys: destinataion, kManualPath, DOWNLOAD_STATUS_SUCCESS, kManualDownloadStatus, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_MANUAL_NOTIFICATION
                                                                object:nil
                                                              userInfo:manualDict];
        }
       
    }
    
    if (!_stopDownloading) {
        [self downloadNextManual];
    }
    
}

- (void)downloadFailedForFile: (NSString*)destination withMessage: (NSString*)message manual:(NSDictionary *)manualDict {
    NSLog(@"Download failed for file %@ -- message %@", destination, message);
    
    NSDictionary *currentManual = manualDict;
    //update DB
    StoreManuals *storeManual = [[StoreManuals alloc] init];
    [storeManual updatefail: currentManual];
   
    //Notification download fail
    NSArray *keys = [currentManual allKeys];
    
    if ([keys count] > 0) {
        NSString *path = [keys objectAtIndex:0];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *destinataion = [NSString stringWithFormat: @"%@/%@/%@", documentsPath, LATAM_MANUALS_DIR_NAME, path];
        NSDictionary *manualDict = [NSDictionary dictionaryWithObjectsAndKeys: destinataion, kManualPath, DOWNLOAD_STATUS_FAIL, kManualDownloadStatus,nil];
        if (!_stopDownloading) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_REACHABILITY_STATUS
                                                                object:nil
                                                              userInfo:manualDict];
        }
    }

    if (!_stopDownloading) {
        [self downloadNextManual];
    }
    
}

- (void)downloadCancelledForFile: (NSString*)destination withMessage: (NSString*)message manual:(NSDictionary*)manualDict{
    NSLog(@"downloadCancelledForFile");
    [self downloadFailedForFile:destination withMessage:message manual:manualDict];
}


@end
