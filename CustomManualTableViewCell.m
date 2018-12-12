//
//  CustomManualTableViewCell.m
//  Nimbus2
//
//  Created by Sravani Nagunuri on 30/07/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "CustomManualTableViewCell.h"

@implementation CustomManualTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.selectIdentifier.hidden=FALSE;
    } else {
        self.selectIdentifier.hidden=TRUE;
    }
    // Configure the view for the selected state
}

- (void)displayCellContent: (NSDictionary*)manualDict {
    [self setBackgroundColor: [UIColor clearColor]];
    
    UIView *customColorView = [[UIView alloc] init];
    [customColorView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
    [self setSelectedBackgroundView: customColorView];
    [self.manualTitleLabel setText: [manualDict objectForKey:kManualName]];
    [self.manualTitleLabel setTextColor:[UIColor whiteColor]];
    [self.manualDateLabel setTextColor:[UIColor whiteColor]];
    [self.activityIndicatorView setHidden:YES];
    [self.manualTypeImageView setAlpha:1];
    if ([[manualDict objectForKey:kManualType] intValue] == ManualTypeDirectory) {
        [[self manualTypeImageView] setImage: [UIImage imageNamed: @"N__0000_fldr_icn.png"]];
        [[self manualAccessoryImageView] setImage: [UIImage imageNamed: @""]];
        [self.manualDateLabel setText:nil];
        [self setTag:0];
    } else {
        [[self manualAccessoryImageView] setImage: nil];
        //palash changed
        if ([[manualDict objectForKey:kManualExtension] isEqualToString:@"pdf"] || [[manualDict objectForKey:kManualExtension] isEqualToString:@"PDF"]) {
            [[self manualTypeImageView] setImage: [UIImage imageNamed:@"N__0001_pdf_ic.png"]];
        } else {
            [[self manualTypeImageView] setImage: [UIImage imageNamed:@""]];
        }
        if ([[manualDict objectForKey:kManualStatusMessage] isEqualToString: DOWNLOAD_STATUS_FAIL]) {
            [self.activityIndicatorView setHidden:YES];
            self.manualAccessoryImageView.image = [self.manualAccessoryImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.manualTypeImageView.image = [self.manualTypeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.manualAccessoryImageView.tintColor = [UIColor redColor];
            self.manualTypeImageView.tintColor = [UIColor redColor];
            [self setTag:999];
        } else if([[manualDict objectForKey:kManualStatusMessage] isEqualToString: DOWNLOAD_STATUS_STARTED] | [[manualDict objectForKey:kManualStatusMessage] isEqualToString: DOWNLOAD_STATUS_MESSAGE] ){
            if ([[manualDict objectForKey:kManualDownloadStatus] isEqualToString: DOWNLOAD_STATUS_SUCCESS]) {
                [self.activityIndicatorView setHidden:YES];
                [self.activityIndicatorView stopAnimating];
            } else {
                [self.activityIndicatorView setHidden:NO];
                [self.activityIndicatorView startAnimating];
                self.manualTypeImageView.image = [self.manualTypeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                self.manualTypeImageView.tintColor = [UIColor redColor];
            }
        } else if ([[manualDict objectForKey:kManualDownloadStatus] isEqualToString: DOWNLOAD_STATUS_SUCCESS]) {
            [self.activityIndicatorView setHidden:YES];
            [self.activityIndicatorView stopAnimating];
        }
        
        AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[apDel getLocalLanguageCode]];
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd-MMM-yyyy HH:mm:ss"];
        [formatter setLocale:locale];
        NSString *dateString =[formatter stringFromDate:[manualDict objectForKey:kManualDate]];
        
        [self.manualDateLabel setText: dateString];
        
    }
}

@end

