//
//  DownloadLibrary.m
//  Nimbus2
//
//  Created by Sravani Nagunuri on 03/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "DownloadLibrary.h"
#import "AppDelegate.h"
//#import "TempLocalStorageModel.h"
#import "DownloadManuals.h"
#import "StoreManuals.h"
#import "LTSingleton.h"

@interface  DownloadLibrary ()<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic) int authFailureCount;

@end

@implementation DownloadLibrary

static dispatch_once_t onceToken = 0;
static NSURLSession *session = nil;

//download a given source file using NSURLSESSION
- (void)downloadFileFromSource: (NSString*)source toDest: (NSString*)destination {
    
    _stopDownloading = NO;
    NSLog(@"Download file %@",destination);
    self.filePath = destination;
    self.urlSession = [self backgroundSession];
    NSURL *downloadURL = [NSURL URLWithString:[source stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    self.downloadTask = [self.urlSession downloadTaskWithRequest:request];
    [self.downloadTask resume];
}

//for supporting downloading in background session
- (NSURLSession *)backgroundSession {
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration =[NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}

//checking for size of downloaded file
-(void)downloadFileFromSource:(NSString*)source toDest:(NSString*)destination ofSize:(double)size {
    
    NSLog(@"Download from source %@ to dest %@ of size %f", source, destination, size);
    
    NSDictionary * properties = [[NSFileManager defaultManager] attributesOfItemAtPath:destination error:nil];
    NSNumber * destSize = [properties objectForKey: NSFileSize];
    if ([destSize longLongValue] == size) {
        NSLog(@"file already downloaded");
        if ([_downloadDelegate respondsToSelector:@selector(downloadSucceededForFile:manual:)]) {
            [_downloadDelegate downloadSucceededForFile: self.filePath manual:_manualDict];
        }
    }
    else {
        //[TempLocalStorageModel saveInUserDefaults:destination withKey:@"destinationPath"];
        [self downloadFileFromSource: source toDest: destination];
    }
}

//cancelling download
- (void)cancelDownload {
    NSLog(@"cancel download");
    session = nil;
    _urlSession = nil;
    onceToken = 0;
    [self.downloadTask cancel];
    self.downloadTask = nil;
}

#pragma mark - NSURLSessionDownloadDelegate Methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL {
    
    self.downloadTask = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSURL *newFileUrl=[NSURL fileURLWithPath:self.filePath];
    NSURL *destinationURL =[NSURL fileURLWithPath: [self.filePath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%@",[appdelegate copyTextForKey:@"NEW"]] withString:@""] isDirectory:NO];
    
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    
    
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    if (success) {
        
        if([[newFileUrl lastPathComponent]rangeOfString:[NSString stringWithFormat:@"_%@",[appdelegate copyTextForKey:@"NEW"]] options:1].length>0)
        {
            [fileManager removeItemAtURL:newFileUrl error:NULL];
        }
    }
    else {
        NSLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    self.downloadTask = nil;
    
    if (_stopDownloading) {
        return;
    }
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if([self.filePath rangeOfString:[appDel copyTextForKey:@"NEW"] options:1].length>0)
    {
        self.filePath = [[[self.filePath stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%@",[appDel copyTextForKey:@"NEW"]] withString:@""] stringByAppendingPathExtension:[self.filePath pathExtension]];
    }
    
    NSDictionary * properties = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:nil];
    NSNumber * destSize = [properties objectForKey: NSFileSize];
    
    if (destSize.intValue == 0 || error || task.state == NSURLSessionTaskStateCanceling) {
        if ([_downloadDelegate respondsToSelector:@selector(downloadFailedForFile:withMessage:manual:)]) {
            [_downloadDelegate downloadFailedForFile:self.filePath withMessage:[error description] manual:_manualDict];
        }
    } else if (error == nil) {
        NSLog(@"Task: %@ completed successfully", task);
        if ([_downloadDelegate respondsToSelector:@selector(downloadSucceededForFile:manual:)]) {
            [_downloadDelegate downloadSucceededForFile:self.filePath manual:_manualDict];
        }
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (appDelegate.backgroundSessionCompletionHandler) {
        void(^handler)() = appDelegate.backgroundSessionCompletionHandler;
        handler();
    }
}

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if (self.authFailureCount == 0) {
        NSURLCredential *cred = [NSURLCredential credentialWithUser:[LTSingleton getSharedSingletonInstance].username password:[LTSingleton getSharedSingletonInstance].password persistence:NSURLCredentialPersistenceNone];
        completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        self.authFailureCount++;
    }
    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if (self.authFailureCount == 0) {
        
        
        NSURLCredential *cred = [NSURLCredential credentialWithUser:[LTSingleton getSharedSingletonInstance].username password:[LTSingleton getSharedSingletonInstance].password persistence:NSURLCredentialPersistenceNone];
        completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        self.authFailureCount++;
    }
    
}

@end
