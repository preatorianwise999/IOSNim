//
//  LTCUSDropdownData.m
//  LATAM
//
//  Created by Durga Madamanchi on 5/29/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTCUSDropdownData.h"
#import "AppDelegate.h"

@implementation LTCUSDropdownData
static NSDictionary *dict;
static NSArray *docTypeValidation;



//To switch the language
+ (void)updateLanguage :(NSString*)docType
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    LanguageSelected currentLanguage;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] == nil)
    {
        currentLanguage =[appDel getLocalLanguage];;
    }
    else
    {
        currentLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] integerValue];
    }
    NSString *languageStr;
    switch (currentLanguage) {
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
    if(nil != dict)
        dict = nil;
    if([docType isEqualToString:@"LAN"])
    {
        NSDictionary *tempDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"LANCusDropDownList" ofType:@"plist"] ];
        
        dict = [tempDict objectForKey:languageStr];
        
        docTypeValidation = [dict objectForKey:@"DocTypeValidation"];
    }
    else
    {
        dict = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"TAMCusDropDownList" ofType:@"plist"]] objectForKey:languageStr];
        
        docTypeValidation = [dict objectForKey:@"DocTypeValidation"];
        
    }
    
}

//To return language specific value for the labels

+ (NSArray *)copyDataForKey:(NSString *)key forDocType:(NSString*)docType
{
    [self updateLanguage:docType];
    return [dict objectForKey:key];
}

+ (NSDictionary *)getDictForKey:(NSString *)key
{
    NSDictionary *temp;
    if(nil != key && [key length]>0
       ) {
        //DLog(@"%@",docTypeValidation);
        
        key = [[key componentsSeparatedByString:@"||"] lastObject];
        
        int index = [self getIndexOfDropdownValue:key];
        
        temp = [docTypeValidation objectAtIndex:index];
    }
    return temp;
}
+ (int)getIndexOfDropdownValue :(NSString*)value {
    int index = 345;
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSArray *array = [dict objectForKey:[appDel copyEnglishTextForKey:@"DOCUMENT_TYPE"]] ;
    if([array containsObject:value]) {
        index = [array indexOfObject:value];
    }
    return index;
}


+ (NSString *)getIndexValue:(NSString *)type atIndex:(int)index forDocType:(NSString*)docType
{
    [self updateLanguage:docType];
    
    NSArray *array = [dict objectForKey:[NSString stringWithFormat:@"%@ Index",type]];
    return     [array objectAtIndex:index];
    
}
@end
