//
//  CategoryTableViewController.m
//  Nimbus2
//
//  Created by Palash on 21/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "EmptySeatTableViewCell.h"
#import "SpecialMealsTableViewCell.h"
#import "HeadingTableViewCell.h"
#import "Seat.h"
#import "LanPassTableViewCell.h"
#import "AppDelegate.h"

//N__0000_hdg_bg.png
@interface CategoryTableViewController ()
{
    NSString *econmyEmptySeats;
    NSString *bussessEmptySeats;
    NSMutableArray *specialMealList;
    NSMutableArray  *dictinct;
    NSMutableArray *lanPassList;
    AppDelegate *appDel;
    
}
@end

@implementation CategoryTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
-(void)viewDidAppear:(BOOL)animated{
    
}

-(void)reloadAllStrings {
    econmyEmptySeats = @"";
    bussessEmptySeats = @"";
    
    for(Seat *customer in self.economyArray) {
        if([customer.columnName isEqualToString:@"="]) {
            
        } else if(![customer.state isEqualToString:@""]) {
            econmyEmptySeats = [econmyEmptySeats stringByAppendingString:[NSString stringWithFormat:@"%@%@ - ",customer.rowName,customer.columnName]];
        }
    }
    
    if(![econmyEmptySeats isEqualToString:@""]) {
        econmyEmptySeats = [econmyEmptySeats substringWithRange:NSMakeRange(0,[econmyEmptySeats length] - 3)];
    }
    
    for(Seat * customer in self.bussnessArray) {
        if([customer.columnName isEqualToString:@"="]) {
            
        } else if(![customer.state isEqualToString:@""]) {
            bussessEmptySeats = [bussessEmptySeats stringByAppendingString:[NSString stringWithFormat:@"%@%@ - ",customer.rowName,customer.columnName]];
        }
    }
    
    if(![bussessEmptySeats isEqualToString:@""]) {
        bussessEmptySeats = [bussessEmptySeats substringWithRange:NSMakeRange(0,[bussessEmptySeats length] - 3)];
    }
    
    NSArray *distinctPass = @[@"BLACK", @"COMODORO", @"PREMIUM SILVER", @"PREMIUM", @"BLACK SIGNATURE"];
    lanPassList = [[NSMutableArray alloc] init];
    
    for (NSString *string in distinctPass) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lanPassCategory ==[cd] %@ AND lanPassUpgrade == TRUE", string];
        NSArray *filteredArray = [self.lanpassArray filteredArrayUsingPredicate:predicate];
        
        if(filteredArray.count == 0) {
            continue;
        }
        
        NSString *passList = @"";
        
        for (Passenger *passenger in filteredArray) {
            
            if(passList.length > 0) {
                passList = [passList stringByAppendingString:@"\n"];
            }
            
            NSString *line = [NSString stringWithFormat:@"%@ - %@ %@", passenger.seatNumber, passenger.firstName, passenger.lastName];
            
            int maxW = self.tableView.frame.size.width - 23;
            int w = 0;
            do {
                if(w > maxW) {
                    line = [NSString stringWithFormat:@"%@...", [line substringToIndex:line.length - 4]];
                }
                
                w = [[[NSAttributedString alloc] initWithString:line attributes:@{NSFontAttributeName : kseatMapLabelFont}] size].width;
                
            } while(w > maxW);
            
            passList = [passList stringByAppendingString:line];
        }
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:string forKey:@"lanPassCategory" ];
        [dict setObject:passList forKey:@"lanPassValue" ];
        [lanPassList addObject:dict];
    }
    
    specialMealList = [[NSMutableArray alloc] init];
    dictinct = [[NSMutableArray alloc] init];
    
    dictinct = [self.mealListArray valueForKeyPath:@"@distinctUnionOfObjects.service"];
    for (NSString *string in dictinct) {
        NSString *mealsList = @"";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"service CONTAINS[cd] %@ AND seatnumber.length > 0", string];
        ;
        NSArray *filteredArray = [self.mealListArray filteredArrayUsingPredicate:predicate];
        
        for (NSDictionary *meals in filteredArray) {
            NSString *line = [NSString stringWithFormat:@"%@ - %@ %@", [meals objectForKey:@"seatnumber"], [meals objectForKey:@"firstname"], [meals objectForKey:@"lastname"]];
            
            int maxW = self.tableView.frame.size.width - 62;
            int w = 0;
            do {
                if(w > maxW) {
                    line = [NSString stringWithFormat:@"%@...", [line substringToIndex:line.length - 4]];
                }
                
                w = [[[NSAttributedString alloc] initWithString:line attributes:@{NSFontAttributeName : [UIFont fontWithName:@"RobotoCondensed-Light" size:14]}] size].width;
                
            } while(w > maxW);
            
            mealsList =  [mealsList stringByAppendingString:[NSString stringWithFormat:@"%@\n", line]];
        }
        
        if(mealsList.length > 0) {
            mealsList = [mealsList substringToIndex:mealsList.length - 1];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setObject:mealsList forKey:@"mealsList" ];
            [dict setObject:string forKey:@"service" ];
            [specialMealList addObject:dict];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self reloadAllStrings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0) {
        int n = 1;
        if(econmyEmptySeats.length > 0) {
            n++;
        }
        if(bussessEmptySeats.length > 0) {
            n++;
        }
        return n;
        
    } else if (section == 1) {
        return specialMealList.count + 1;
        
    } else if (section == 2) {
        return lanPassList.count + 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int w = self.view.bounds.size.width;
    
    if(indexPath.section == 0) {
        int index = indexPath.row;
        if(indexPath.row == 1 && econmyEmptySeats.length == 0) {
            index++;
        }
        
        if(index == 1) {
            if ([self getLabelHeightForText:econmyEmptySeats font:KRobotoFontSize14 constrainedToWidth:w - 60] + 22 < 50) {
                return 50;
            } else {
                return [self getLabelHeightForText:econmyEmptySeats font:KRobotoFontSize14 constrainedToWidth:w - 60] + 22;
            }
            
        } else if(index == 2) {
            if ([self getLabelHeightForText:bussessEmptySeats font:KRobotoFontSize14 constrainedToWidth:w - 60] + 22 < 50) {
                return 50;
            } else {
                return [self getLabelHeightForText:bussessEmptySeats font:KRobotoFontSize14 constrainedToWidth:w - 60] + 22;
            }
        }
    }
    else if(indexPath.section == 1) {
        if (indexPath.row != 0) {
            NSString *text = [[specialMealList objectAtIndex:indexPath.row - 1] objectForKey:@"mealsList"];
            return [self getLabelHeightForText:text font:KRobotoFontSize14 constrainedToWidth:w - 60] + 20;
        }
        
    } else if(indexPath.section == 2) {
        if (indexPath.row != 0) {
            return [self getLabelHeightForText:[[lanPassList objectAtIndex:indexPath.row-1] objectForKey:@"lanPassValue"] font:kseatMapLabelFont constrainedToWidth:w - 23] + 60;
        }
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HeadingTableViewCell *headingTableViewCell = nil;
    EmptySeatTableViewCell *emptySeatTableViewCell = nil;
    SpecialMealsTableViewCell *mealsListTableViewCell = nil;
    LanPassTableViewCell *lanPassTableViewCell = nil;
    
    UITableViewCell *cell;
    if(indexPath.row == 0) {
        //Heading//
        headingTableViewCell = (HeadingTableViewCell *)[self createCellForTableView:tableView withCellID:@"HeadingTableViewCell"];
        headingTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        headingTableViewCell.headingText.textColor =[UIColor whiteColor];
        
        cell = headingTableViewCell;
    }
    if (indexPath.section == 0 && indexPath.row !=0 ) {
        // EmptySeats
        emptySeatTableViewCell = (EmptySeatTableViewCell *)[self createCellForTableView:tableView withCellID:@"EmptySeatTableViewCell"];
        emptySeatTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [emptySeatTableViewCell sizeToFit];
        cell =  emptySeatTableViewCell;
    }
    
    if(indexPath.section == 1 && indexPath.row != 0)
    {
        //Meals
        mealsListTableViewCell = (SpecialMealsTableViewCell *)[self createCellForTableView:tableView withCellID:@"SpecialMealsTableViewCell"];
        mealsListTableViewCell.serviceCode.textColor = [UIColor whiteColor];
        mealsListTableViewCell.mealsListString.textColor = [UIColor whiteColor];
        mealsListTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = mealsListTableViewCell;
    }
    if(indexPath.section == 2 && indexPath.row != 0) {
        //lan pass
        lanPassTableViewCell = (LanPassTableViewCell *)[self createCellForTableView:tableView
                                                                         withCellID:@"LanPassTableViewCell"];
        lanPassTableViewCell.listOfPassengers.textColor = [UIColor whiteColor];
        lanPassTableViewCell.headingLanPass.textColor = [UIColor whiteColor];
        lanPassTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = lanPassTableViewCell;
    }
    
    if (indexPath.section == 0 ) {
        int index = indexPath.row;
        if(indexPath.row == 1 && econmyEmptySeats.length == 0) {
            index++;
        }
        if (index == 0) {
            headingTableViewCell.imageView.image = [UIImage imageNamed:@"N__0000_seat_icn.png"];
            headingTableViewCell.headingText.text = [appDel copyTextForKey:@"Asientos Desocupados"];
        }
        if (index == 1) {
            emptySeatTableViewCell.seats.text = econmyEmptySeats;
            emptySeatTableViewCell.seatType.text = @"YC";
        }
        else if (index == 2){
            emptySeatTableViewCell.seats.text = bussessEmptySeats;
            emptySeatTableViewCell.seatType.text = @"BC";
        }
        
    } else if (indexPath.section == 1 ) {
        if (indexPath.row == 0) {
            headingTableViewCell.imageView.image = [UIImage imageNamed:@"N__0001_ml_icn.png"];
            headingTableViewCell.headingText.text = [appDel copyTextForKey:@"Comidas Especiales"];
        }
        
        if (indexPath.row != 0) {
            mealsListTableViewCell.mealsListString.text = [[specialMealList objectAtIndex:indexPath.row - 1] objectForKey:@"mealsList"];
            mealsListTableViewCell.serviceCode.text = [[specialMealList objectAtIndex:indexPath.row - 1] objectForKey:@"service"];
        }
    }
    else if (indexPath.section == 2 ) {
        if (indexPath.row == 0) {
            headingTableViewCell.imageView.image = [UIImage imageNamed:@"N__0002_upgrd_icn.png"];
            headingTableViewCell.headingText.text =[appDel copyTextForKey:@"Subidas de categoria Lanpass"];
            
        } else {
            lanPassTableViewCell.headingLanPass.text = [[lanPassList objectAtIndex:indexPath.row - 1] objectForKey:@"lanPassCategory"];
            lanPassTableViewCell.listOfPassengers.text = [[lanPassList objectAtIndex:indexPath.row - 1] objectForKey:@"lanPassValue"];
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UITableViewCell *)createCellForTableView:(UITableView *)tableView withCellID:(NSString *)cellID {
    if([cellID isEqualToString:@"HeadingTableViewCell"]){
        HeadingTableViewCell* headingTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"HeadingTableViewCell"];
        if (headingTableViewCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HeadingTableViewCell" owner:self options:nil];
            headingTableViewCell = [topLevelObjects objectAtIndex:0];
            headingTableViewCell.selectionStyle=UITableViewCellSelectionStyleGray;
            
        }
        return headingTableViewCell;
    }
    else if ([cellID isEqualToString:@"EmptySeatTableViewCell"]){
        EmptySeatTableViewCell *emptySeatTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"EmptySeatTableViewCell"];
        if (emptySeatTableViewCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EmptySeatTableViewCell" owner:self options:nil];
            emptySeatTableViewCell = [topLevelObjects objectAtIndex:0];
            emptySeatTableViewCell.selectionStyle=UITableViewCellSelectionStyleGray;
        }
        
        return emptySeatTableViewCell;
    }
    else if ([cellID isEqualToString:@"SpecialMealsTableViewCell"]){
        SpecialMealsTableViewCell *mealsListTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"SpecialMealsTableViewCell"];
        if (mealsListTableViewCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SpecialMealsTableViewCell" owner:self options:nil];
            mealsListTableViewCell = [topLevelObjects objectAtIndex:0];
            mealsListTableViewCell.selectionStyle=UITableViewCellSelectionStyleGray;
        }
        
        return mealsListTableViewCell;
    }
    else if ([cellID isEqualToString:@"LanPassTableViewCell"]){
        LanPassTableViewCell *lanPassTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"LanPassTableViewCell"];
        if (lanPassTableViewCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LanPassTableViewCell" owner:self options:nil];
            lanPassTableViewCell = [topLevelObjects objectAtIndex:0];
            lanPassTableViewCell.selectionStyle=UITableViewCellSelectionStyleGray;
        }
        return lanPassTableViewCell;
    }
    return nil;
}

- (CGFloat)getLabelHeightForText:(NSString*)text font:(UIFont*)font constrainedToWidth:(int)width {
    
    CGSize constraint = CGSizeMake(width, 2000.0f);
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{ NSFontAttributeName: font } context:context].size;
    
    CGSize size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

-(void)reloadTheViews {
    [self reloadAllStrings];
    [self.tableView reloadData];
}



@end
