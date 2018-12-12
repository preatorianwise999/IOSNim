    
//
//  ConnectionLibrary.m
//  Nimbus2
//
//  Created by 720368 on 8/4/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "ConnectionLibrary.h"
#import "LTSingleton.h"

@implementation ConnectionLibrary

-(void)loginCredentials:(NSString*)username1 :(NSString*)password1 {
    self.userNameStr = [NSString stringWithFormat:@"%@",username1];
    self.passwordStr = [NSString stringWithFormat:@"%@",password1];
}

-(void)prtioritizeExecutionArrayForObject:(RequestObject*)req{
    NSInteger index = req.position;
    if (index != 0) {
        [self.serialSynchArray removeObjectAtIndex:index];
        [self.serialSynchArray insertObject:req atIndex:1];
    }
}

-(NSMutableURLRequest*)createRequestWithData:(RequestObject*)req{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:req.url]];
    [request setHTTPMethod:req.type];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [req.param length]];
    [request setTimeoutInterval:90.0];

    [request addValue:@"Application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    LTSingleton *singleton = [LTSingleton getSharedSingletonInstance];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", singleton.username, singleton.password];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody: [req.param dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    return request;
}

-(NSMutableData *)sendSynchronousCallWithUrl:(NSString*)url andPostData:(NSString*)postString {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postString length]];
    [request setTimeoutInterval:90.0];
    [request addValue:@"Application/json"  forHTTPHeaderField:@"Content-Type"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: [postString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    responseData = [[NSMutableData alloc]init];
    NSError *error;
    NSURLResponse *response;
    responseData = [[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] mutableCopy];
    return responseData;
}

- (void)sendSynchronousDataTaskWithRequest:(NSURLRequest *)request  Oncomplete:(NSMutableData* (^)(void))onComplete{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse *response, NSError *error) {
        responseData=[data mutableCopy];
        onComplete();
    }];
    [dataTask resume];
}

-(NSMutableData *)sendSynchronousCallWithUrl:(RequestObject *)req error:(NSError**)error {
    
    NSURLRequest *request = [self createRequestWithData:req];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSError *bError = nil;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse *response, NSError *e) {
        
        if(e) {
            bError = e;
        }
        
        if (data) {
            // do whatever you want with the data here
            responseData = [data mutableCopy];
        }
        else {
            NSLog(@"error = %@", e);
            responseData = nil;
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    
    // but have the thread wait until the task is done
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if(error && bError) {
        *error = bError;
    }
    // now carry on with other stuff contingent upon what you did above
    return responseData;
}

-(NSString *)uploadFileToServer:(NSString *)name filePath:(NSString *)filePath urlString:(NSString*)urlString {
    NSData *file1Data = [[NSData alloc] initWithContentsOfFile:filePath];
    NSString *base64String = [file1Data base64EncodedStringWithOptions: 0];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];//urlString
    
    [request setHTTPMethod:@"POST"];
    NSString *msgLength = [NSString stringWithFormat:@"%d",base64String.length];
    [request addValue:@"Application/json"  forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    LTSingleton *singleton = [LTSingleton getSharedSingletonInstance];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", singleton.username, singleton.password];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:[base64String dataUsingEncoding:NSUTF8StringEncoding]];
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
        [_connection cancel];
        [self.delegate loginFailed];
    }
    else if ([(NSHTTPURLResponse *) response statusCode] == 403 || [(NSHTTPURLResponse *) response statusCode] == 401 || [(NSHTTPURLResponse *) response statusCode] == 405 || [(NSHTTPURLResponse *) response statusCode] == 511) {
        [_connection cancel];
        [self.delegate loginFailedDueToForbiddenAccess];
    }
    
    
    if ([(NSHTTPURLResponse *) response statusCode] == 409) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"File Conflict error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [_connection cancel];
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
    if([self.delegate respondsToSelector:@selector(connectionDidReceiveResponceWithData:)])
        [self.delegate connectionDidReceiveResponceWithData:responseData];
}


- (void)connection:(NSURLConnection *)connection1 didFailWithError:(NSError *)error {
    [self.connection cancel];
    responseData=nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kServerSynchStop object:nil];
    if ([self.delegate respondsToSelector:@selector(restServicefailwithError:)]) {
        [self.delegate restServicefailwithError:error];
    }
}

// Called when all connection processing has completed successfully,before the delegate is released by the connection
- (void)connectionDidFinishLoading:(NSURLConnection *)connection1 {
    [_connection cancel];
    
    if ([self.delegate respondsToSelector:@selector(succeededConnectionWithData:withTag:)]) {
        [self.delegate succeededConnectionWithData:responseData withTag:self.serviceTags];
    }
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
}

- (void)connection:(NSURLConnection *)connection1 didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userNameStr
                                                             password:self.passwordStr
                                                          persistence:NSURLCredentialPersistenceNone];
    
    if (([challenge previousFailureCount] == 0) && ([challenge proposedCredential] == nil)) {
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    } else {
        [connection1 cancel];
        [self.delegate loginFailed];
    }
}

- (void)connection:(NSURLConnection *)connection1 willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    
    else {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        
        NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userNameStr
                                                                 password:self.passwordStr
                                                              persistence:NSURLCredentialPersistenceNone];
        
        
        if (([challenge previousFailureCount] == 0)) {
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kServerSynchStop object:nil];
            //validation = @"Error";
            [connection1 cancel];
            [self.delegate loginFailed];
        }
    }
}

#pragma mark URL Session Delegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

@end
