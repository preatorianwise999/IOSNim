//
//  SeatCell.m
//  Nimbus2
//
//  Created by Rajashekar on 16/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "SeatCell.h"
#import "GetSeatMapData.h"

@implementation SeatCell

-(void)configurePassengerData:(Seat *)seat {
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    divider1.backgroundColor = [UIColor clearColor];
    divider2.backgroundColor = [UIColor clearColor];
    
    Ribbon.backgroundColor = [UIColor clearColor];
    Accessory1.hidden = YES;
    Accessory2.hidden = YES;
    Accessory3.hidden = YES;
    Accessory4.hidden = YES;
    isVip = NO;
    issplMeal = NO;
    isChild = NO;
    issplNeed = NO;
    isUpgrade = NO;
    track1 = NO;
    track2 = NO;
    self.layer.cornerRadius = 5;
    
    if (seat.seatPassenger !=nil && ![seat.seatPassenger isEqual:nil]){
        Passenger * pass = seat.seatPassenger;
        // if ([seatNum isEqualToString:pass.seatNumber]){
        if ([pass valueForKey:@"vipCategory"] != nil && ![[pass valueForKey:@"vipCategory"]  isEqualToString:@""] ) {
            isVip = YES;
        }
        if ([[pass.specialMeals array] count] > 0) {
            issplMeal = YES;
        }
        if ( [[pass valueForKey:@"isWCH"] boolValue] ) {
            issplNeed = YES;
        }
        else if ( [[pass valueForKey:@"isChild"] boolValue] ) {
            isChild = YES;
        }
        if ( [[pass valueForKey:@"lanPassUpgrade"] boolValue] ) {
            isUpgrade = YES;
        }
        
        if (isVip) {
            Accessory1.image = [UIImage imageNamed:@"N__0026_vip_icn.png"];
            Accessory1.hidden = NO;
        }
        if (issplMeal) {
            if (isVip) {
                Accessory2.image = [UIImage imageNamed:@"N__0027_spl_ml_icn.png"];
                Accessory2.hidden = NO;
                divider1.backgroundColor = kSeatAccessoryDividerColor;
                
                track1 = YES;
            }
            else {
                Accessory1.image =[UIImage imageNamed:@"N__0027_spl_ml_icn.png"];
                Accessory1.hidden = NO;
            }
        }
        
        if (issplNeed || isChild) {
            
            NSString *imgName = @"N__0024_wchr_icn.png";
            
            if(isChild) {
                imgName = @"ic_kids.png";
            }
            
            if (isVip)  {
                if (issplMeal) {
                    Accessory3.image = [UIImage imageNamed:imgName];
                    Accessory3.hidden = NO;
                    divider1.backgroundColor = kSeatAccessoryDividerColor;
                    divider2.backgroundColor = kSeatAccessoryDividerColor;
                }else {
                    Accessory2.image = [UIImage imageNamed:imgName];
                    Accessory2.hidden = NO;
                    divider1.backgroundColor = kSeatAccessoryDividerColor;
                    
                }
            } else if (issplMeal) {
                Accessory2.image = [UIImage imageNamed:imgName];
                Accessory2.hidden = NO;
                divider1.backgroundColor = kSeatAccessoryDividerColor;
            }
            else {
                Accessory1.image = [UIImage imageNamed:imgName];
                Accessory1.hidden = NO;
            }
        }
        
        if (isUpgrade) {
            if (isVip) {
                if (issplMeal) {
                    if (issplNeed) {
                        Accessory4.image = [UIImage imageNamed:@"N__0023_upgrd_icn.png"];
                        Accessory4.hidden = NO;
                        divider1.backgroundColor = kSeatAccessoryDividerColor;
                        divider2.backgroundColor = kSeatAccessoryDividerColor;
                        
                        
                    } else{
                        Accessory3.image = [UIImage imageNamed:@"N__0023_upgrd_icn.png"];
                        Accessory3.hidden = NO;
                        divider1.backgroundColor = kSeatAccessoryDividerColor;
                        divider2.backgroundColor = kSeatAccessoryDividerColor;
                    }
                } else {
                    if(issplNeed){
                        Accessory3.image = [UIImage imageNamed:@"N__0023_upgrd_icn.png"];
                        Accessory3.hidden = NO;
                        divider1.backgroundColor = kSeatAccessoryDividerColor;
                        divider2.backgroundColor = kSeatAccessoryDividerColor;
                        
                        
                    }
                    else{
                        Accessory2.image = [UIImage imageNamed:@"N__0023_upgrd_icn.png"];
                        Accessory2.hidden = NO;
                        divider1.backgroundColor = kSeatAccessoryDividerColor;
                    }
                    
                }
            } else if (issplMeal) {
                if(issplNeed) {
                    Accessory3.image = [UIImage imageNamed:@"N__0023_upgrd_icn.png"];
                    Accessory3.hidden = NO;
                    divider1.backgroundColor = kSeatAccessoryDividerColor;
                    divider2.backgroundColor = kSeatAccessoryDividerColor;
                }
                
                else {
                    Accessory2.image = [UIImage imageNamed:@"N__0023_upgrd_icn.png"];
                    Accessory2.hidden = NO;
                    divider1.backgroundColor = kSeatAccessoryDividerColor;
                    
                }
                
            } else if (issplNeed) {
                Accessory2.image = [UIImage imageNamed:@"N__0023_upgrd_icn.png"];
                Accessory2.hidden = NO;
                divider1.backgroundColor = kSeatAccessoryDividerColor;
            } else {
                Accessory1.image = [UIImage imageNamed:@"N__0023_upgrd_icn.png"];
                Accessory1.hidden = NO;
            }
        }
        
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        
        NSString * ribbonColor = [pass freqFlyerCategory];
        if ([ribbonColor isEqualToString:@"SAPH"]) {
            Ribbon.backgroundColor = kSeatRibbonBlueColor;
        }
        else if ([ribbonColor isEqualToString:@"EMLD"]){
            Ribbon.backgroundColor = kSeatRibbonGreenColor;
        }
        else if ([ribbonColor isEqualToString:@"RUBY"]){
            Ribbon.backgroundColor = kSeatRibbonRedColor;
        }
        else {
            Ribbon.backgroundColor = kSeatRibbonGrayColor;
        }
        
        if (seat.seatPassenger != nil) {
            self.backgroundColor =  kSeatBackgroundColor;
        }
        if (seat.isHighlighted) {
            self.backgroundColor = [UIColor whiteColor];
        }
    }
    
    if ([seat.columnName isEqualToString:@"="]) {
        self.alpha = 0.000;
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 0.0;
    }
    
    // @NOTE(diego) empty state should indicate non-existent seat, but backend is giving empty state for seats that actually exist. Uncomment this when backend fixes the issue
    
    if([seat.state isEqualToString:@""]) {
        self.contentView.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
    else {
        self.contentView.hidden = NO;
    }
}

@end
