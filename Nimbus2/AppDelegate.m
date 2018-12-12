//
//  AppDelegate.m
//  Nimbus2
//
//  Created by 720368 on 7/2/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "AppDelegate.h"
#import "FlightViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()
{
    NSDictionary *_copyTextDict;
    NSDictionary *_englishTextDict;
}
@end

@implementation AppDelegate
@synthesize currentLanguage;

-(BOOL)isJailbroken {
    NSURL* url = [NSURL URLWithString:@"cydia://package/com.example.package"];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch
    
    [Fabric with:@[[Crashlytics class]]];
    
    if ([self isJailbroken]) {
        return YES;
    }
    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    if(![TempLocalStorageModel getUserDefaultsData:@"isFirstTimeLaunch"]) {
        [TempLocalStorageModel saveInUserDefaults:@"1" withKey:@"isFirstTimeLaunch"];
        [TempLocalStorageModel setDataInKeyChainWrapper:@"" withKey:CuserName withEncryption:YES];
        [TempLocalStorageModel setDataInKeyChainWrapper:@"" withKey:CpassWord withEncryption:YES];
        if (![TempLocalStorageModel getUserDefaultsData:kContentByVersionUri]) {
            [TempLocalStorageModel saveInUserDefaults:VERSION_URI withKey:kContentByVersionUri];
        }
    }
    
    [self initCopyText];
    
    self.hostReachability = [Reachability reachabilityWithHostName:[self getHost]];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

-(int)compareDate:(NSDate*)fromdate :(NSDate*)todate {
    NSDate *dateA=fromdate;
    NSDate *dateB=todate;
    
    NSTimeInterval secondsBetween = [dateB timeIntervalSinceDate:dateA];
    int diff = secondsBetween;
    return diff;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.lan.latam.nimbus.Nimbus2" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Nimbus2" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @NO
                              };
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Nimbus2.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [((AppDelegate*)([UIApplication sharedApplication].delegate)).managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}

#pragma mark - LanguageSelected

-(NSDictionary *)getDictionayofType:(NSString *)type selectedLang:(LanguageSelected)lang getDictionayofType:(NSString *)airlineCode{
    NSString *filePath;
    
    if(([airlineCode isEqualToString:@"JJ"] || [airlineCode isEqualToString:@"PZ"]) && [type isEqualToString:@"WB"] && lang == LANG_SPANISH)
    {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADTCTAMWBSpanish" ofType:@"geojson"];
    }
    else if(([airlineCode isEqualToString:@"JJ"] || [airlineCode isEqualToString:@"PZ"]) && [type isEqualToString:@"WB"] && lang == LANG_PORTUGUESE)
    {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADTCTAMWBPortuguese" ofType:@"geojson"];
    }else if ([type isEqualToString:@"NB"] && lang == LANG_SPANISH)
    {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADLANNBSpanish" ofType:@"geojson"];
    }
    else   if ([type isEqualToString:@"WB"] && lang == LANG_SPANISH)
    {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADLANWBSpanish" ofType:@"geojson"];
    }
    else   if ([type isEqualToString:@"NB"] && lang == LANG_PORTUGUESE)
    {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADTAMNBPortuguese" ofType:@"geojson"];
    }
    else   if ([type isEqualToString:@"WB"] && lang == LANG_PORTUGUESE)
    {
        filePath= [[NSBundle mainBundle] pathForResource:@"GADTAMWBPortuguese" ofType:@"geojson"];
    }
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dict = [DictionaryParser dictionaryFromData:data];
    return dict;
}

#pragma mark - Language Methods

- (void)initCopyText {
    if(_copyTextDict == nil){
        _copyTextDict = [[NSDictionary alloc]init];
    }
    if(_englishTextDict == nil){
        _englishTextDict = [[NSDictionary alloc] init];
        _englishTextDict = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"LocalizedCopyText" ofType:@"plist"]] objectForKey:@"ENGLISH"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] == nil)
    {
        [self switchToLocale:[self getLocalLanguage]];
    }
    else
        [self switchToLocale:[[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] integerValue]];
    
}

//To get the local language of the device
- (LanguageSelected)getLocalLanguage {
    NSString *localLanguageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([localLanguageCode isEqualToString:@"pt"]) {
        currentLanguage = LANG_PORTUGUESE;
    }
    else{
        currentLanguage = LANG_SPANISH;
    }
    return currentLanguage;
}

-(NSString *)getLocalLanguageCode {
    if(currentLanguage == LANG_ENGLISH)
        return @"en";
    else if (currentLanguage == LANG_PORTUGUESE)
        return @"pt_BR";
    else if (currentLanguage == LANG_SPANISH)
        return @"es";
    else
        return @"es";
}

-(NSString *)getLanguageCodeForLocale {
    if(currentLanguage == LANG_ENGLISH)
        return @"en";
    else if (currentLanguage == LANG_PORTUGUESE)
        return @"pt_BR";
    else if (currentLanguage == LANG_SPANISH)
        return @"es_ES";
    else
        return @"es";
}

//To switch the language
- (void)switchToLocale:(LanguageSelected)languageSelected
{
    currentLanguage = languageSelected;
    NSString *languageStr;
    switch (languageSelected) {
        case LANG_ENGLISH:
            languageStr = @"ENGLISH";
            break;
        case LANG_SPANISH:
            languageStr = @"SPANISH";
            break;
        case LANG_PORTUGUESE:
            languageStr = @"PORTUGUESE";
            break;
        default:
            break;
    }
    
    _copyTextDict = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"LocalizedCopyText" ofType:@"plist"]] objectForKey:languageStr];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",languageSelected] forKey:@"Language"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//To return only english keys to save in db
-(NSString *)copyEnglishTextForKey:(NSString *)key{
    return [_englishTextDict objectForKey:key];
}

//To return language specific value for the labels

-(NSString *)englishValueForValue:(NSString *)value {
    
    NSString *temp;
    for(NSString *key in [_copyTextDict allKeys]){
        if([[_copyTextDict objectForKey:key] isEqualToString:value]){
            temp = key;
            break;
        }
    }
    
    return [_englishTextDict objectForKey:temp];
    
}

-(NSString *)valueForEnglishValue:(NSString *)value{
    
    NSString *temp;
    for(NSString *key in [_copyTextDict allKeys]){
        if([[_englishTextDict objectForKey:key] isEqualToString:value]){
            temp = key;
            break;
        }
    }
    
    return [_copyTextDict objectForKey:temp];
    
}

- (NSString *)copyTextForKey:(NSString *)key {
    return [_copyTextDict objectForKey:key];
}

- (void)reachabilityChanged:(NSNotification *)note {
    
    NetworkStatus internetStatus = [self.hostReachability currentReachabilityStatus];
    
    if(internetStatus != ReachableViaWiFi) {
        [[DownloadManuals shareInstance] cancelDownloadingManuals];
    }
    
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

-(NSString *)getHost {
    //[self registerDefaultsFromSettingsBundle];
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //DLog(@"getHost %@",[defaults objectForKey:@"HOST"]);
    //return [defaults objectForKey:@"HOST"];
    //return [NSString stringWithFormat:@"%@:%@",HOSTNAME,PORT];
    if([PORT isEqualToString:@"80"])
    return [NSString stringWithFormat:@"%@",HOSTNAME];
    else
    return [NSString stringWithFormat:@"%@:%@",HOSTNAME,PORT];
    
}

-(BOOL) checkForInternetAvailability {
    
    Reachability *reachabilityObject=[Reachability reachabilityWithHostName:REACHABILITY_HOST];
    //Reachability *reachabilityObject=[Reachability reachabilityWithHostName:[[[self getHost] componentsSeparatedByString:@":"] firstObject]];
    NetworkStatus netStatus = [reachabilityObject currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability {
    
    if (reachability == self.hostReachability) {
        [timer invalidate];
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        if (netStatus != NotReachable) {
            UINavigationController *navigationCont = (UINavigationController *)self.window.rootViewController;
            for (UIViewController *cont in [navigationCont viewControllers]) {
                if ([cont isKindOfClass:[FlightViewController class]]) {
//                    [(FlightViewController*)cont synchBtnClicked:[UIButton buttonWithType:UIButtonTypeCustom]];
                    if(netStatus == ReachableViaWiFi) {
                        [(FlightViewController*)cont startDownloadingManuals];
                    }
                }
            }
            NSLog(@"---------------------------------->Reachable %d",self.reachable);
        } else {
            self.reachable = NO;
            if ([LTSingleton getSharedSingletonInstance].synchStatus) {
                
//                timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(finishSynch) userInfo:nil repeats:NO];
                
            }
            NSLog(@"---------------------------------->Not Reachable %d",self.reachable);
        }
    }
}

-(void)finishSynch {
    [[NSNotificationCenter defaultCenter] postNotificationName:kServerSynchStop object:nil];
}

- (void)dealloc {
    NSLog(@"DEALLOC APP DEL");
}


@end
