//
//  ConnectionLibrary.h
//  Nimbus2
//
//  Created by 720368 on 8/4/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RequestObject.h"
#import "DictionaryParser.h"
@protocol ConnectionLibraryDelegate <NSObject>
@optional
-(void) connectionDidReceiveResponceWithData:(NSMutableData *)data;
-(void) succeededConnectionWithData:(NSData *)jsonData withTag:(enum ServiceTags)serviceTag;
-(void) loginFailed;
-(void) loginFailedDueToForbiddenAccess;
-(void)restServicefailwithError : (NSError *)error;
@end

@interface ConnectionLibrary : NSObject<NSURLSessionDelegate> {
    NSMutableData *responseData;
}
@property (nonatomic) id<ConnectionLibraryDelegate> delegate;
@property(nonatomic,retain) NSMutableDictionary *requestDictionary;
@property(nonatomic,retain) NSMutableArray *serialSynchArray;
@property (nonatomic,strong) NSURLConnection *connection;
@property(nonatomic, assign) enum ServiceTags serviceTags;
@property (nonatomic,strong)NSString *userNameStr;
@property (nonatomic,strong)NSString *passwordStr;
-(NSMutableURLRequest*)createRequestWithData:(RequestObject*)req;
-(NSMutableData *)sendSynchronousCallWithUrl:(RequestObject *)req error:(NSError**)error;
-(void)loginCredentials:(NSString*)username1 :(NSString*)password1;
-(NSMutableData *)sendSynchronousCallWithUrl:(NSString*)url andPostData:(NSString*)postString;
-(NSString *)uploadFileToServer:(NSString *)name filePath:(NSString *)filePath urlString:(NSString*)urlString;

@end
