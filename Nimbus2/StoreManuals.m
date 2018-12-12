//
//  StoreManuals.m
//  Nimbus2
//
//  Created by Sravani Nagunuri on 30/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "StoreManuals.h"
#import "DeleteManual.h"
#import "CreateManuals.h"
#import "LTConnectionLibrary.h"
#import "LTSingleton.h"
#import "Connection.h"

@interface StoreManuals ()

@property (nonatomic, getter = getManualListFromDB) NSArray *manualList; //List of Manuals objects
@property (nonatomic) DownloadManuals *downloadManuals;

@end

@implementation StoreManuals

#pragma mark ---- downloading manuals

- (void)startDownloadingManuals {
    NSLog(@"startDownloadingManuals");
    self.downloadManuals =  [DownloadManuals shareInstance];
    if(self.downloadManuals) {
        
        [self.downloadManuals stopManualDownloader];
    }
    [_downloadManuals downloadManuals: [self getPendingManuals]];
    [self.delegate finishedDownloadingManuals];
}
#pragma mark -- get list of  manuals from DB

- (NSArray*)getManualListFromDB {
    _manualList = [self getManualsWithPredicate: nil];
    return _manualList;
}

- (NSArray*)getPendingManuals {
    NSArray *manuals = [self getManualsWithPredicate:[NSString stringWithFormat:@"downloadStatus == \'fail\'"]];
    return manuals;
}

- (NSArray*)getManualsWithPredicate:(NSString*)predicateStr {
    //get manualslist from db
    NSArray *manuals = nil;
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Manuals" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: entityDescription];
    if (predicateStr) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateStr];
        [request setPredicate:predicate];
        NSSortDescriptor *sizeSorter = [[NSSortDescriptor alloc] initWithKey:@"size" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObjects:sizeSorter, nil]];
    }
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        NSMutableArray *manualsArray = [[NSMutableArray alloc] init];
        for (Manuals *manuals in results) {
            NSMutableDictionary *manualDict = [[NSMutableDictionary alloc] init];
            
            if([manuals size] != nil) {
                [manualDict setObject:[manuals size] forKey:kManualSize];
            }
            else {
                [manualDict setObject:@(0) forKey:kManualSize];
            }
            
            if([manuals date] != nil) {
                [manualDict setObject:[manuals date] forKey:kManualDate];
            }
            else {
                [manualDict setObject:[NSDate date] forKey:kManualDate];
            }
            
            if([manuals downloadStatus] != nil) {
                [manualDict setObject:[manuals downloadStatus] forKey:kManualDownloadStatus];
            }
            else {
                [manualDict setObject:DOWNLOAD_STATUS_FAIL forKey:kManualDownloadStatus];
            }
            
            if([manuals statusMessage] != nil) {
                [manualDict setObject:[manuals statusMessage] forKey:kManualStatusMessage];
            }
            else {
                [manualDict setObject:DOWNLOAD_STATUS_MESSAGE forKey:kManualStatusMessage];
            }
            
            NSOrderedSet *linksSet = [manuals linkManual];
            if ([linksSet count] > 0) {
                ManualLinks *manualLinks = [linksSet objectAtIndex:0];
                NSString *uri = [manualLinks uriManual];
                uri = [uri stringByReplacingOccurrencesOfString:@"|" withString:@"/"];
                if(uri == nil) {
                    continue;
                }
                [manualDict setObject:uri forKey:kManualURI];
            }
            
            if(manuals.filePath == nil) {
                continue;
            }
            
            NSMutableDictionary *manualPathDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: manualDict, [manuals.filePath stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]], nil];
            
            [manualsArray addObject: manualPathDict];
        }
        manuals = [[NSArray alloc] initWithArray:manualsArray];
    }
    return manuals;
}
#pragma mark---get manual directory  path

- (NSString*)getLatamManualsDirPath {
    if (!_latamManualsDirPath) {
        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _latamManualsDirPath = [NSString stringWithFormat: @"%@/%@", documentsPath, @"LATAM_MANUALS_DIR"];
    }
    return _latamManualsDirPath;
}

- (NSDictionary*)getLatamManualsRootDir {
    NSMutableDictionary *latamRootDict = [[NSMutableDictionary alloc] init];
    [latamRootDict setObject:[self getLatamManualsDirPath] forKey:kManualPath];
    return latamRootDict;
}

#pragma mark -- manage  directory structure
- (void)createDirectoryStructure: (NSString*)manualfilePath {
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dirPath = [NSString stringWithFormat: @"%@/%@", documentsPath,@"LATAM_MANUALS_DIR"];
    
    
    NSString *totalFilePath = [[NSString alloc] initWithFormat:@"%@/%@", dirPath, manualfilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    if (![fileManager fileExistsAtPath: totalFilePath]) {
        if (![fileManager createDirectoryAtPath: [totalFilePath stringByDeletingLastPathComponent]
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:&error]) {
            NSLog(@"Error in creating manuals directory structure: %@", error);
        }
        if (![fileManager createFileAtPath: totalFilePath
                                  contents: nil
                                attributes: nil]) {
            NSLog(@"Error in creating manuals file: %@", error);
        }
    }
}
- (void)deleteDirectoryStructureForFile: (NSString*)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [self getLatamManualsDirPath], path];
    NSError *error = nil;
    [fileManager removeItemAtPath:filePath error:&error];
    if (error) {
        DLog(@"Error in deleting file %@", filePath);
    }
    [self deleteDirectoryStructure: [filePath stringByDeletingLastPathComponent]];
}

- (void)deleteDirectoryStructure: (NSString*)dirPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *childList = [fileManager contentsOfDirectoryAtPath: dirPath error:&error];
    if (error) {
        DLog(@"Error in getting directory elements %@", error);
        return;
    }
    if ([childList count] > 0) {
        return;
    } else {
        [fileManager removeItemAtPath: dirPath error: &error];
        if (error) {
            DLog(@"Error in deleting directory %@", error);
        }
        [self deleteDirectoryStructure: [dirPath stringByDeletingLastPathComponent]];
    }
}

- (NSArray*)getManualsWithParentDirectory: (NSString*)parentDirPath {
    //name, type(dir/file), extension(pdf/epub), date, path, size, uri
    NSLog(@"Parent directory %@", parentDirPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:parentDirPath]) {
        return nil;
    }
    NSArray *childPaths = [fileManager contentsOfDirectoryAtPath:parentDirPath error:&error];
    if (error) {
        NSLog(@"Error in getting manuals file structure %@", error);
        return nil;
    }
    NSMutableArray *childList = [[NSMutableArray alloc] init];
    NSMutableArray *directoryList = [[NSMutableArray alloc] init];
    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    
    for (NSString *childName in childPaths) {
        NSString *childPath = [NSString stringWithFormat: @"%@/%@", parentDirPath, childName];
        NSMutableDictionary *childDict = [[NSMutableDictionary alloc] init];
        [childDict setObject:childPath forKey:kManualPath];
        [childDict setObject:childName forKey:kManualName];
        BOOL isDir;
        if ([fileManager fileExistsAtPath:childPath isDirectory:&isDir] && isDir) {
            [childDict setObject:@(ManualTypeDirectory) forKey:kManualType];
            [directoryList addObject:childDict];
        } else {
            [childDict setObject:@(ManualTypeFile) forKey:kManualType];
            [childDict setObject:[childName pathExtension] forKey:kManualExtension];
            
            
            
            NSString *childRelativePath = [childPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", [self getLatamManualsDirPath]] withString:@""];
            childRelativePath=[childRelativePath stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            //set date, size, uri
            for (NSDictionary *manualParentDict in self.manualList) {
                
                NSDictionary *manualChildDict = [manualParentDict objectForKey:childRelativePath];
                if (manualChildDict) {
                    
                    [childDict addEntriesFromDictionary: manualChildDict];
                }
            }
            [fileList addObject:childDict];
        }
    }
    [childList addObjectsFromArray: directoryList];
    [childList addObjectsFromArray: fileList];
    return childList;
}
#pragma mark --- sync manual data from URL

-(void)synchManualData {
    
    LTConnectionLibrary *connection = [[LTConnectionLibrary alloc] init];
    [connection loginCredentials:[LTSingleton getSharedSingletonInstance].username : [LTSingleton getSharedSingletonInstance].password];
    connection.serviceTags = kMANUALLIST;
    connection.delegate = self;
    NSString *url = [BASEURL stringByAppendingString:@"manuals"];
    [connection sendAsynchronousCallWithUrl:url];
}
/******adding manual data after sync to DB and local document directory****/

- (void)synchManualsFromDict: (NSDictionary*)manualsDict {
   
    NSLog(@"synch manuals");
   
    //fetching manuals list from DB
    NSArray *dbManuals = [self getManualListFromDB];
    NSMutableDictionary *dbManualsDict = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dbManualDict in dbManuals) {
        NSArray *keys = [dbManualDict allKeys];
        if ([keys count] > 0) {
            NSString *path = [keys objectAtIndex:0];
            [dbManualsDict setObject:[dbManualDict objectForKey:path] forKey:path];
        }
    }
    //fetching manuals from Synch response
    NSArray *manuals = [manualsDict objectForKey: @"manuals"];
    NSMutableDictionary *resManualsDict = [[NSMutableDictionary alloc] init];
    for (NSDictionary *resManual in manuals) {
        NSMutableDictionary *resManualDict = [[NSMutableDictionary alloc] init];
        [resManualDict setObject:[resManual objectForKey:@"date"] forKey:kManualDate];
        [resManualDict setObject:[resManual objectForKey:@"size"] forKey:kManualSize];
        NSDictionary *links = [resManual objectForKey: @"links"];
        NSArray *allKeys = [links allKeys];
        if ([allKeys count] > 0) {
            NSString *uri = [links objectForKey: @"uriManual"];
            uri=[uri stringByReplacingOccurrencesOfString:@"|" withString:@"/"];
            [resManualDict setObject:uri forKey:kManualURI];
        }
        
        NSString *filePath=[resManual objectForKey:@"filePath"];
        [resManualsDict setObject:resManualDict forKey:[filePath stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]]];
    }
    
    NSArray *dbManualsKeys = [dbManualsDict allKeys];
    
    for(NSString *dbKey in dbManualsKeys) {
        
        if(![[resManualsDict allKeys] containsObject:dbKey]) {
            //delete manuals from DB which are not there in Synched manual list
            
            NSMutableDictionary *manualDict = [dbManualsDict objectForKey: dbKey];
            [manualDict setObject: dbKey forKey:kManualPath];
            DeleteManual *deleteManual = [[DeleteManual alloc] init];
            [deleteManual deleteManual: manualDict];
            [self deleteDirectoryStructureForFile: [manualDict objectForKey:kManualPath]];
        }
        
    }
    
    NSArray *resManualsKeys = [resManualsDict allKeys];
    
    for(NSString *resKey in resManualsKeys) {
        NSDictionary *resDict = [resManualsDict objectForKey:resKey];
        
        //update DB for date and time for manuals which are synched
        
        for(NSString *dbkeys in dbManualsKeys) {
            
            NSDictionary *dbDict = [dbManualsDict objectForKey:dbkeys];
            NSDate *dbDate = [dbDict objectForKey:kManualDate];
            if([resKey isEqualToString:dbkeys]) {
                NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss +Z"];
                NSString *date1 = [dateFormater stringFromDate:dbDate];
                NSDate *dbDate1 = [dateFormater dateFromString:date1];
                NSString *resDateStr =[resDict objectForKey:@"Date"];
                [dateFormater setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                NSDate *resDate = [dateFormater dateFromString:resDateStr];
                
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *currentFilePath = [NSString stringWithFormat: @"%@/%@/%@", documentsPath, LATAM_MANUALS_DIR_NAME, dbkeys];
                NSDictionary *properties = [[NSFileManager defaultManager] attributesOfItemAtPath:currentFilePath error:nil];
                
                NSNumber *dbSize = [properties objectForKey: NSFileSize];
                double resSize = [[resDict objectForKey:kManualSize] doubleValue];
                
                if([dbDate1 compare:resDate] != NSOrderedSame &&
                   resSize != [dbSize longLongValue]) {
                    
                   AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    NSMutableDictionary *manualDict = [NSMutableDictionary dictionaryWithDictionary: [resManualsDict objectForKey: resKey]];
                    NSString *newFile = [resKey lastPathComponent];
                    newFile = [newFile stringByDeletingPathExtension];
                    newFile = [[newFile stringByAppendingString:[NSString stringWithFormat:@"_%@",[appdelegate copyTextForKey:@"NEW"]]] stringByAppendingPathExtension:[resKey pathExtension]];
                    NSString *filePath = [[resKey stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile];
                    [manualDict setObject: filePath forKey:kManualPath];
                    [manualDict setValue:resDateStr forKeyPath:kManualDate];
                    CreateManuals *createManuals = [[CreateManuals alloc] init];
                    [createManuals addManualFromDict: manualDict];
                    [self createDirectoryStructure: filePath];
                }
            }
        }
        
        if(![[dbManualsDict allKeys] containsObject:resKey]) {
            //add new manuals to DB after synch
            NSMutableDictionary *manualDict = [NSMutableDictionary dictionaryWithDictionary: [resManualsDict objectForKey: resKey]];
            [manualDict setObject: resKey forKey:kManualPath];
            CreateManuals *createManuals = [[CreateManuals alloc] init];
            [createManuals addManualFromDict: manualDict];
            [self createDirectoryStructure: resKey];
        }
    }
    
    if ([dbManualsDict count] > 0 || [resManualsDict count] > 0) {
        _manualList = nil;
    }
    
    NSDate *syncDate = [NSDate date];
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"dd-MMM-yyyy HH:mm:ss"];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[apDel getLocalLanguageCode]]];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *dateString =[df stringFromDate:syncDate];
    NSString *dateStr = [NSString stringWithFormat:@"%@", dateString];
    [[NSUserDefaults standardUserDefaults] setObject:dateStr forKey:LAST_SYNCH_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:MANUALS_SYNC_NOTIFICATION
                                                        object:nil
                                                      userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MANUALS
                                                        object:nil
                                                      userInfo:nil];
    
}

#pragma mark- LTConnection delegate methods
-(void) succeededConnectionWithData:(NSData *)jsonData withTag:(enum ServiceTags)serviceTag {
    NSDictionary *responseDict = [DictionaryParser dictionaryFromData:jsonData];
    jsonData = nil;
    NSLog(@"response------%@", responseDict);
    // Temporarly calling this method to get list of manuals from URl.Need to call in the flow for manual synchronization
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self synchManualsFromDict:responseDict];
        [self.delegate finishedSyncingManualData];
    });
}

#pragma mark -- download status methods
//update the DB for download status success

- (void)updateSuccessDownloadStatusOfManual:(NSDictionary*)manualDict {
    NSArray *keys = [manualDict allKeys];
    if ([keys count] == 0) {
        return;
    } else {
        NSString *path = [keys objectAtIndex:0];
        // path=[path stringByReplacingOccurrencesOfString:@"_new" withString:@""];
        CreateManuals *updateManual = [[CreateManuals alloc] init];

        NSString *predicateStr = [NSString stringWithFormat:@"filePath == \'%@\'", path];
        [updateManual updateSuccessDownloadForManualWithPredicate: predicateStr];
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if([path rangeOfString:[NSString stringWithFormat:@"_%@",[appdelegate copyTextForKey:@"NEW"]] options:1].length > 0) {
            [updateManual updateFile:manualDict path:predicateStr];
        }
        else {
            [updateManual updateSuccessDownloadForManualWithPredicate: predicateStr];
        }
    }
}
//update the DB for download status fail
-(void)updatefail:(NSDictionary*)manualDict {
    NSArray *keys = [manualDict allKeys];
    if ([keys count] == 0) {
        return;
    } else {
        NSString *path = [keys objectAtIndex:0];
        NSString *predicateStr = [NSString stringWithFormat:@"filePath == \'%@\'", path];
        CreateManuals *updateManual = [[CreateManuals alloc] init];
        [updateManual updateFail: predicateStr];
    }
}

@end
