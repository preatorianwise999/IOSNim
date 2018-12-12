//
//  LTConnectionLibrary.h
//  LATAM
//
//  Created by Palash on 06/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
//Protocol to delegate status

@protocol LTConnectionLibraryDelegate <NSObject>
@optional
    -(void) connectionDidReceiveResponceWithData:(NSMutableData *)data;
    -(void) succeededConnectionWithData:(NSData *)jsonData withTag:(enum ServiceTags)serviceTag;
    -(void) loginFailed;
    -(void) loginFailedDueToForbiddenAccess;
    -(void)restServicefailwithError : (NSError *)error;
@end


@interface LTConnectionLibrary : NSObject<NSURLConnectionDataDelegate>{
    NSMutableData *responseData;
    NSString *responseString;
    NSString *serverURLStr;
    NSString *mode;
    NSString *serverIPStr;
    BOOL storeUrl;
    NSMutableArray *newsFeedArray;

    NSString *validation;
    NSURLConnection *connection;
}
@property (nonatomic) id<LTConnectionLibraryDelegate> delegate;
@property(nonatomic, assign) enum ServiceTags serviceTags;
@property (nonatomic,strong)NSString *userNameStr;
@property (nonatomic,strong)NSString *passwordStr;

-(void)loginCredentials:(NSString*)username :(NSString*)password;
-(void)sendAsynchronousCallWithUrl:(NSString*)url;
-(void)sendAsynchronousCallWithUrl:(NSString*)url andPostData:(NSString*)postString;
-(NSMutableData *)sendSynchronousCallWithUrl:(NSString*)url andPostData:(NSString*)postString;

-(NSString *)uploadFileToServer:(NSString *)name filePath:(NSString *)filePath urlString:(NSString*)urlString;
@end
