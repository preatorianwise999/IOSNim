//
//  LTConnectionLibrary.m
//  LATAM
//
//  Created by Palash on 06/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTConnectionLibrary.h"
#import <UIKit/UIKit.h>

@implementation LTConnectionLibrary

//Setting Login Credentials for Authetication Validation for Sharepoint server
-(void)loginCredentials:(NSString*)username1 :(NSString*)password1
{
    self.userNameStr = [NSString stringWithFormat:@"%@",username1];
    self.passwordStr = [NSString stringWithFormat:@"%@",password1];
}
//Calling asynchronous Service with Url
-(void)sendAsynchronousCallWithUrl:(NSString*)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request.URL removeAllCachedResourceValues];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:45];
    [request setHTTPMethod:@"GET"];
    responseData = [[NSMutableData alloc]init];
    responseData=nil;
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [connection start];
}
//Calling asynchronous Service with Url and custom post string
-(void)sendAsynchronousCallWithUrl:(NSString*)url andPostData:(NSString*)postString{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request.URL removeAllCachedResourceValues];
    [request setHTTPMethod:@"POST"];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [postString length]];
    [request addValue:@"Application/json"  forHTTPHeaderField:@"Content-Type"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: [postString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    responseData = [[NSMutableData alloc]init];
    responseData=nil;
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}
//Calling synchronous Service with Url
-(NSMutableData *)sendSynchronousCallWithUrl:(NSString*)url andPostData:(NSString*)postString{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [postString length]];
    [request addValue:@"Application/json"  forHTTPHeaderField:@"Content-Type"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: [postString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    //[request addValue:@"true" forHTTPHeaderField:@"serviceStatus.nativeMessage.enabled"];
    responseData = [[NSMutableData alloc]init];
    //connection = [NSURLConnection connectionWithRequest:request delegate:self];
    NSError *error;
    NSURLResponse *response;
    responseData=[[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] mutableCopy];
    return responseData;
}

-(NSString *)uploadFileToServer:(NSString *)name filePath:(NSString *)filePath urlString:(NSString*)urlString
{
    
    
    NSData *file1Data = [[NSData alloc] initWithContentsOfFile:filePath];
     
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"POST"];
    NSString *msgLength = [NSString stringWithFormat:@"%d",file1Data.length];
    [request addValue:@"Application/json"  forHTTPHeaderField:@"Content-Type"];
    //[request addValue:@"true" forHTTPHeaderField:@"serviceStatus.nativeMessage.enabled"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: file1Data];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    
    NSError *error;
    NSURLResponse *response;
    responseData=[[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] mutableCopy];
    NSString *returnString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    return returnString;
    
}
#pragma -mark connection delegates
- (void)connection:(NSURLConnection *)connection1 didReceiveResponse:(NSURLResponse *)response
{
    if ([(NSHTTPURLResponse *) response statusCode] == 504) {
        validation = @"Error";
        [connection1 cancel];
        [self.delegate loginFailed];
    }
    else if ([(NSHTTPURLResponse *) response statusCode] == 403 || [(NSHTTPURLResponse *) response statusCode] == 401 || [(NSHTTPURLResponse *) response statusCode] == 405 || [(NSHTTPURLResponse *) response statusCode] == 511) {
        validation = @"Error";
        [connection1 cancel];
        [self.delegate loginFailedDueToForbiddenAccess];
    }
    
    
    if ([(NSHTTPURLResponse *) response statusCode] == 409) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"File Conflict error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [connection1 cancel];
        [self.delegate loginFailed];
        return;
    }
    
    if ([(NSHTTPURLResponse *) response statusCode] == 502) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Bad Gateway" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
	
    if (!responseData) {
        responseData = [[NSMutableData alloc] init];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
    if([self.delegate respondsToSelector:@selector(connectionDidReceiveResponceWithData:)])
        [self.delegate connectionDidReceiveResponceWithData:responseData];
    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

}

// Called when all connection processing has completed successfully,before the delegate is released by the connection
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    if ([self.delegate respondsToSelector:@selector(succeededConnectionWithData:withTag:)]) {
        [self.delegate succeededConnectionWithData:responseData withTag:self.serviceTags];
    }
}



- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    
}

- (void)connection:(NSURLConnection *)connection1 didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    validation = @"";
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userNameStr
                                                             password:self.passwordStr
                                                          persistence:NSURLCredentialPersistenceNone];
    
    if (([challenge previousFailureCount] == 0) && ([challenge proposedCredential] == nil)) {
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        //count++;
    } else {
        validation = @"Error";
        [connection1 cancel];
        [self.delegate loginFailed];
    }
}

- (void)connection:(NSURLConnection *)connection1 willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    validation = @"";
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userNameStr
                                                             password:self.passwordStr
                                                          persistence:nil];
    
	if (([challenge previousFailureCount] == 0)) {
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        
        
    } else {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kServerSynchStop object:nil];
//        validation = @"Error";
//        [connection1 cancel];
//        [self.delegate loginFailed];
    }
}


@end
