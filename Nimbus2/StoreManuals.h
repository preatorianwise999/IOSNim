//
//  StoreManuals.h
//  Nimbus2
//
//  Created by Sravani Nagunuri on 30/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTConnectionLibrary.h"
#import "DictionaryParser.h"
#import "DownloadManuals.h"
#import "Manuals.h"
#import "ManualLinks.h"


typedef enum : NSUInteger {
    ManualExtensionNone = 100,
    ManualExtensionPDF,
    ManualExtensionEPUB,
} ManualExtension;

typedef enum : NSUInteger {
    ManualTypeNone = 200,
    ManualTypeDirectory,
    ManualTypeFile,
} ManualType;

@protocol StoreManualsDelegate

- (void)finishedSyncingManualData;
- (void)finishedDownloadingManuals;

@end

@interface StoreManuals : NSObject<LTConnectionLibraryDelegate> {
    NSMutableArray *dirList;
}
@property (nonatomic, getter = getLatamManualsDirPath, retain) NSString *latamManualsDirPath;
@property (nonatomic, weak) id<StoreManualsDelegate> delegate;

-(void)synchManualData;
- (void)synchManualsFromDict: (NSDictionary*)manualsDict;
- (NSArray*)getManualsWithParentDirectory: (NSString*)parentDirPath;
- (NSString*)getLatamManualsDirPath;
- (NSDictionary*)getLatamManualsRootDir;
- (void)startDownloadingManuals;
- (NSArray*)getPendingManuals;
- (void)updateSuccessDownloadStatusOfManual: (NSDictionary*)manualDict;
-(void)updatefail:(NSDictionary*)manualDict;
- (NSArray*)getManualsWithPredicate: (NSString*)predicateStr;
- (void)deleteDirectoryStructureForFile: (NSString*)path;
- (void)deleteDirectoryStructure: (NSString*)dirPath;
@end
