//
//  CategoryTableViewController.h
//  Nimbus2
//
//  Created by Palash on 21/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Passenger.h"

@interface CategoryTableViewController : UITableViewController{

}
@property (nonatomic , retain) NSArray *mealListArray;
@property (nonatomic , retain) NSArray *economyArray;
@property (nonatomic , retain) NSArray *bussnessArray;
@property (nonatomic , retain) NSArray *passengerInfoArray;

@property (nonatomic , retain) NSArray *lanpassArray;
-(void)reloadTheViews;
@end
