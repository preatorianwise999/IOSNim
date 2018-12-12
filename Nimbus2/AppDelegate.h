//
//  AppDelegate.h
//  Nimbus2
//
//  Created by 720368 on 7/2/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DictionaryParser.h"
#import "Constants.h"
#import <QuickLook/QuickLook.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource> {

    NSString *path;
    UINavigationController *navigationController;
    NSTimer *timer;
}

@property (retain, nonatomic) Reachability *hostReachability;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,getter = isReachable) BOOL reachable;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (copy) void (^backgroundSessionCompletionHandler)();


//-(NSDictionary *)getDictionayofType:(NSString *)type selectedLang:(LanguageSelected)lang;


@property LanguageSelected currentLanguage;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (LanguageSelected)getLocalLanguage;

-(void)displayPreviewControllerForManuals:(NSDictionary*)launchOptions;
-(int)compareDate:(NSDate*)fromdate :(NSDate*)todate;
//Language methods

- (void)switchToLocale:(LanguageSelected)languageSelected;
- (NSString *)copyTextForKey:(NSString *)key;
-(NSString *)copyEnglishTextForKey:(NSString *)key;
-(NSString *)englishValueForValue:(NSString *)value;
-(NSString *)valueForEnglishValue:(NSString *)value;
-(NSDictionary *)getDictionayofType:(NSString *)type selectedLang:(LanguageSelected)lang getDictionayofType:(NSString *)airlineCode;
- (NSString *)getLocalLanguageCode;
-(NSString *)getLanguageCodeForLocale;
-(void)enableAnimation;

@end

