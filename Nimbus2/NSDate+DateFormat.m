//
//  NSDate+DateFormat.m
//  LATAM
//
//  Created by Ankush jain on 4/8/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "NSDate+DateFormat.h"
#import "AppDelegate.h"

@implementation NSDate (DateFormat)
- (NSString *)dateFormat:(DATE_FORMAT_TYPE)formatType{
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[apDel getLocalLanguageCode]];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    //NSString *dateFormat;
    
    switch (formatType) {
        case DATE_FORMAT_HH_mm:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"HH:mm" options:0 locale:locale];
        [formatter setDateFormat:@"HH:mm"];
        break;
        case DATE_FORMAT_EEE_DD_MMM:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEE dd MMM" options:0 locale:locale];
        [formatter setDateFormat:@"EEE dd MMM"];
        break;
            
        case DATE_FORMAT_EEEE_dd_MMMM:
        [formatter setDateFormat:@"EEEE dd MMMM"];
        break;
            
        case DATE_FORMAT_dd:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd" options:0 locale:locale];
        [formatter setDateFormat:@"dd"];
        break;
        case DATE_FORMAT_EEEE:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEE" options:0 locale:locale];
        [formatter setDateFormat:@"EEEE"];
        
        break;
        case DATE_FORMAT_EEEE_MMMM_dd:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEE,MMMM dd" options:0 locale:locale];
        [formatter setDateFormat:@"EEEE MMMM dd"];
        break;
        case DATE_FORMAT_EEE_DD:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEE,dd" options:0 locale:locale];
        [formatter setDateFormat:@"EEE dd"];
        break;
        case DATE_FORMAT_EEE:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEE" options:0 locale:locale];
        [formatter setDateFormat:@"EEE"];
        break;
        case DATE_FORMAT_DD_MMM:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd MMM" options:0 locale:locale];
        [formatter setDateFormat:@"dd MMM"];
        break;
        case DATE_FORMAT_MMMM_yyyy:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd MMM" options:0 locale:locale];
        [formatter setDateFormat:@"MMMM yyyy"];
        break;
        case DATE_FORMAT_dd_MMM_yyyy:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd MMM" options:0 locale:locale];
        [formatter setDateFormat:@"dd MMM yyyy"];
        break;
        case DATE_FORMAT_dd_MMM_HH_mm:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd MMM" options:0 locale:locale];
        [formatter setDateFormat:@"dd MMM HH:mm"];
        break;
        case DATE_FORMAT_dd_MMMM_YYYY:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd MMM" options:0 locale:locale];
        [formatter setDateFormat:@"dd MMMM YYYY"];
        break;
        
        case DATE_FORMAT_yyyy_MM_dd_HH_mm_ss:
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        break;
        
        case DATE_FORMAT_dd_MM_yyyy:
            [formatter setDateFormat:@"dd-MM-yyyy"];
            break;
        
        case DATE_FORMAT_dd_MM_yyyy_HH_mm_ss:
            [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];

        default:
        break;
    }
    
    //[formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateString =[formatter stringFromDate:self];
    return dateString;
}


+ (NSDate *)dateFromString:(NSString *)dateStr dateFormatType:(DATE_FORMAT_TYPE)dateFormatType{
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[apDel getLocalLanguageCode]];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    NSString *dateFormat;
    
    switch (dateFormatType) {
        
        case DATE_FORMAT_yyyy_MM_dd_HH_mm_ss:
        dateFormat = @"yyyy-MM-dd HH:mm:ss";
        break;
        case DATE_FORMAT_dd_MM_yyyy_HH_mm:
        dateFormat = @"dd-MM-yyyy HH:mm";
        break;
        case DATE_FORMAT_dd_MM_yyyy_HH_mm_ss:
            dateFormat = @"dd-MM-yyyy HH:mm:ss";
            break;
        case DATE_FORMAT_dd_MMM_yyyy:
        
        //dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd MMM" options:0 locale:locale];
        dateFormat = @"dd MMM yyyy";
        break;
        case DATE_FORMAT_HH_mm:
        dateFormat = @"HH:mm";
        break;
        default:
        break;
    }
    
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];   //rajesh
    // [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDate *formattedDate =[formatter dateFromString:dateStr];
    
    
    return formattedDate;
}
@end
