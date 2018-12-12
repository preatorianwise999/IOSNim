//
//  CreateManuals.h
//  Nimbus2
//
//  Created by Sravani Nagunuri on 05/08/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateManuals : NSObject


- (void)updateManual:(NSDictionary *)manualDict forFilePath:(NSString *)filePath;
- (void)addManualFromDict: (NSDictionary*)manualDict;
- (void)updateSuccessDownloadForManualWithPredicate: (NSString*)predicateStr;
-(void)updateFail:(NSString*)predicateStr;
-(void)updateFile:(NSDictionary*)manualDict path:(NSString*)predicateStr;
@end
