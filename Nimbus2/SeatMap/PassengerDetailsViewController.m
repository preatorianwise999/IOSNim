//
//  PassengerDetailsViewController.m
//  Nimbus2
//
//  Created by Rajashekar on 20/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "PassengerDetailsViewController.h"
#import "SeatMapViewController.h"
#import "AppDelegate.h"
#import "DocNumberViewController.h"
#import "SaveSeatMap.h"
#import "LTSingleton.h"

@interface PassengerDetailsViewController ()
{
    NSArray *temp;
    SeatMapViewController *seatMapobj;
    NSArray *CategoriaArray;
    NSArray *AArray;
    NSArray *CArray;
    NSArray *solicitudeArray;
    Passenger *customer;
    NSDictionary *custDict;
    AppDelegate *appDel;
    UIPopoverController * docNumberPopover;
    DocNumberViewController * docPopup ;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@end

@implementation PassengerDetailsViewController
@synthesize currentPassenger,currentPassengertemp,isClicked;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    // Do any additional setup after loading the view from its nib.
    customer = [[Passenger alloc] init];
    temp=[[NSArray alloc]init];
    
    _detailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.reportCusButton setTitle:[appDel copyTextForKey:@"Report CUS"] forState:UIControlStateNormal];
    [self.doneButton setTitle:[appDel copyTextForKey:@"Done_Text"] forState:UIControlStateNormal];
    
    [_detailsTableView registerNib:[UINib nibWithNibName:@"detailTableViewCell" bundle:nil] forCellReuseIdentifier:@"details"];
    [_detailsTableView registerNib:[UINib nibWithNibName:@"AcompanantesTableViewCell" bundle:nil] forCellReuseIdentifier:@"Acompanantes"];
    [_detailsTableView registerNib:[UINib nibWithNibName:@"SolicitudeTableViewCell" bundle:nil] forCellReuseIdentifier:@"solicitudes"];
    [_detailsTableView registerNib:[UINib nibWithNibName:@"ConexionesTableViewCell" bundle:nil] forCellReuseIdentifier:@"conexiones"];
    [_detailsTableView registerNib:[UINib nibWithNibName:@"SelectedTextTableViewCell" bundle:nil] forCellReuseIdentifier:@"selectedtext"];
    
    CategoriaArray = [NSArray arrayWithObject:@"Categoria"];
    AArray = [NSArray arrayWithObject:@"2A"];
    CArray = [NSArray arrayWithObject:@"12C"];
    solicitudeArray = [NSArray arrayWithObject:@"Solicitudes"];
    
    if(_selectPassenger==YES) {
        currentPassenger=currentPassengertemp;
    }
    else if (isClicked==YES) {
        currentPassenger=currentPassengertemp;
    }
    
    [self.detailsTableView reloadData];
}

-(void)disableCusReportButton:(NSString *)reportStatus {
    
    _reportCusButton.enabled = true;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self disableCusReportButton:currentPassengertemp.status];
    [self updateHeightConstraint];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)updateHeightConstraint {
    // calculate height of table view
    int h = 0;
    int nSections = [self numberOfSectionsInTableView:self.detailsTableView];
    for(int i = 0; i < nSections; i++) {
        int nRows = [self tableView:self.detailsTableView numberOfRowsInSection:i];
        for(int j = 0; j < nRows; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            h += [self tableView:self.detailsTableView heightForRowAtIndexPath:indexPath];
        }
    }
    self.tableViewHeightConstraint.constant = MIN(h, self.view.bounds.size.height - 115);
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int n = 2;
    
    if(_acompaniesDataArray.count > 0) {
        n++;
    }
    if(currentPassenger.specialMeals.count > 0 || (currentPassenger.vipCategory && [currentPassenger.vipCategory isEqualToString:@""] == NO)) {
        n++;
    }
    if(currentPassenger.cusConnection.count > 0) {
        n++;
    }
    
    return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int index = [self indexForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    if(index == 0) {
        return 1;
    }
    if(index == 1) {
        return 1;
    }
    if(index == 2) {
        return _acompaniesDataArray.count > 0 ? 1 : 0;
    }
    if(index == 3) {
        if(currentPassenger.specialMeals.count > 0) {
            return 1;
        }
        else if(currentPassenger.vipCategory && [currentPassenger.vipCategory isEqualToString:@""] == NO) {
            return 1;
        }
        else {
            return 0;
        }
    }
    if(index == 4) {
        return currentPassenger.cusConnection.count > 0 ? 1 : 0;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int index = [self indexForIndexPath:indexPath];
    
    if(index == 0) {
        SelectedTextTableViewCell *selectedTableViewcell=[tableView dequeueReusableCellWithIdentifier:@"selectedtext"];
        selectedTableViewcell.backgroundColor = [UIColor clearColor];
        selectedTableViewcell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
        
        selectedTableViewcell.bc_Label.text = @"";
        if ([currentPassengertemp.flightClass isEqualToString:@"Business"]) {
            // = @"Business";
            selectedTableViewcell.bc_Label.text = @"BC";
        } else if ([currentPassengertemp.flightClass isEqualToString:@"Economy"]) {
            // = @"Economy";
            selectedTableViewcell.bc_Label.text = @"YC";
        }
        NSString * ribbonColor = [currentPassengertemp freqFlyerCategory];
        
        if ([ribbonColor isEqualToString:@"SAPH"]) {
            selectedTableViewcell.selectedPassengerImage.image= [UIImage imageNamed:@"searSelectedImageblue.png"];
        }
        else if ([ribbonColor isEqualToString:@"EMLD"]) {
            selectedTableViewcell.selectedPassengerImage.image= [UIImage imageNamed:@"searSelectedImageGreen.png"];
        }
        else if ([ribbonColor isEqualToString:@"RUBY"]) {
            selectedTableViewcell.selectedPassengerImage.image= [UIImage imageNamed:@"searSelectedImage.png"];
        }
        else {
            selectedTableViewcell.selectedPassengerImage.image= [UIImage imageNamed:@"searSelectedImagegray.png"];
        }
        
        selectedTableViewcell.lname_Label.textColor = [UIColor whiteColor];
        selectedTableViewcell.a_Label.textColor = [UIColor whiteColor];
        selectedTableViewcell.bc_Label.textColor = [UIColor whiteColor];
        
        if(currentPassenger.firstName != nil || currentPassenger.lastName != nil ) {
            selectedTableViewcell.lname_Label.text= [[NSString stringWithFormat:@"%@ %@",currentPassenger.firstName,currentPassenger.lastName]uppercaseString];
        }
        else {
            selectedTableViewcell.lname_Label.text = @"";
        }
        
        if(currentPassenger.seatNumber !=nil){
            selectedTableViewcell.a_Label.text=currentPassenger.seatNumber;
        }
        else {
            selectedTableViewcell.a_Label.text = @"";
        }
        
        if(currentPassenger.editCodes != nil) {
            selectedTableViewcell.presilver_Label.text = currentPassenger.editCodes;
        }
        else {
            selectedTableViewcell.presilver_Label.text = @"";
        }
        
        selectedTableViewcell.backgroundColor = [UIColor clearColor];
        
        return selectedTableViewcell;
    }
    
    else if(index == 1) {
        detailTableViewCell *detailTableViewcell=[tableView dequeueReusableCellWithIdentifier:@"details"];
        detailTableViewcell.Cumpleanos_Label.text = [appDel copyTextForKey:@"Cumpleanos"];
        detailTableViewcell.NumeraFFP_Label.text = [appDel copyTextForKey:@"Numero FFp"];
        detailTableViewcell.Categoria_Label.text = [appDel copyTextForKey:@"Categoria"];
        detailTableViewcell.Kms_Label.text = @"Kms.Lanpass";
        
        if (currentPassenger.dateOfBirth != nil) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"dd-MM-yyyy";
            detailTableViewcell.bday_Label.text = [df stringFromDate:currentPassenger.dateOfBirth];
        }
        else {
            detailTableViewcell.bday_Label.text = @"N/D";
        }
        
        if (currentPassenger.freqFlyerNum != nil && ![currentPassenger.freqFlyerNum isEqualToString:@""] && ![currentPassenger.freqFlyerNum isEqualToString:@"0"]) {
            
            detailTableViewcell.docNum_Label.text = currentPassenger.freqFlyerNum;
            
            if(currentPassenger.freqFlyerComp != nil && ![currentPassenger.freqFlyerComp isEqualToString:@""]) {
                detailTableViewcell.docNum_Label.text = [NSString stringWithFormat:@"%@ %@", currentPassenger.freqFlyerComp, detailTableViewcell.docNum_Label.text];
            }
        }
        else {
            detailTableViewcell.docNum_Label.text = @"N/D";
        }
        
        if(currentPassenger.lanPassCategory) {
            detailTableViewcell.Comodoro_Label.text = currentPassenger.lanPassCategory;
        }
        else {
            detailTableViewcell.Comodoro_Label.text = @"N/D";
        }
        
        if(currentPassenger.lanPassKms != nil) {
            NSString * str = currentPassenger.lanPassKms;
            NSString *numberString = [@([str intValue]) descriptionWithLocale:[NSLocale currentLocale]];;
            detailTableViewcell.KM_Label.text = numberString;
        }
        else {
            detailTableViewcell.KM_Label.text = @"N/D";
        }
        
        detailTableViewcell.backgroundColor = [UIColor clearColor];
        return detailTableViewcell;
    }
    
    else if (index == 2) {
        AcompanantesTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Acompanantes"];
        temp = _acompaniesDataArray;
        cell.Acompanantes_Label.text=[appDel copyTextForKey:@"Acompanantes"];
        if([_acompaniesDataArray count] > 0){
            NSString *inStr = [NSString stringWithFormat:@"%ld", [temp count]];
            [cell.Acompanies_buton_label setHidden:NO];
            [cell.acc_button_image setHidden:NO];
            cell.Acompanies_buton_label.text = inStr;
            int y = 20;
            for (int i = 0; i < _acompaniesDataArray.count; i++){
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(8, y = y + 20, 200, 20)];
                [cell addSubview:label];
                label.text = [_acompaniesDataArray objectAtIndex:i];
                [label setFont:kseatMapLabelFont];
                [label setAlpha:1.0f];
                [label setTextColor:[UIColor whiteColor]];
            }
        }
        
        else {
            [cell.Acompanies_buton_label setHidden:YES];
            [cell.acc_button_image setHidden:YES];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    else if (index == 3) {
        SolicitudeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"solicitudes"];
        
        cell.solicitude_Label.text = [solicitudeArray objectAtIndex:0];
        int y = 20;
        int z = 20;
        int d = 20;
        
        if([currentPassenger.specialMeals count] > 0) {
            for(int i = 0; i < [currentPassenger.specialMeals count]; i++) {
                UIImageView *spclMealImg=[[UIImageView alloc] initWithFrame:CGRectMake(8, y + 20, 15, 15)];
                spclMealImg.image = [UIImage imageNamed:@"N__0004_spl_icn.png"];
                spclMealImg.contentMode = UIViewContentModeCenter;
                [cell addSubview:spclMealImg];
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30, y = y + 20, 40, 20)];
                [cell addSubview:label];
                label.text = [[currentPassenger.specialMeals objectAtIndex:i] objectForKey:@"serviceCode"];
                [label setAlpha:1.0f];
                [label setFont:kseatMapLabelFont];
                [label setTextColor:[UIColor whiteColor]];
                
                UILabel *dash_Label = [[UILabel alloc]initWithFrame:CGRectMake(75, d = d + 20, 10, 20)];
                [cell addSubview:dash_Label];
                dash_Label.text = @"-";
                [dash_Label setTextColor:[UIColor whiteColor]];
                
                UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(90, z = z + 20, self.view.bounds.size.width - 95, 20)];
                [cell addSubview:label1];
                label1.text = [[currentPassenger.specialMeals objectAtIndex:i] objectForKey:@"option"];
                [label1 setFont:kseatMapLabelFont];
                [label1 setTextColor:[UIColor whiteColor]];
                [label1 setAlpha:1.0f];
            }
        }
        
        if(currentPassenger.vipCategory && [currentPassenger.vipCategory isEqualToString:@""] == NO) {
            UIImageView *vipImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, y + 25, 15, 15)];
            vipImg.image = [UIImage imageNamed:@"N__0004_vip_icn.png"];
            vipImg.contentMode = UIViewContentModeCenter;
            [cell addSubview:vipImg];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, y = y + 25, self.view.bounds.size.width - 35, 20)];
            [cell addSubview:label];
            label.text = currentPassenger.vipCategory;
            [label setAlpha:1.0f];
            [label setFont:kseatMapLabelFont];
            [label setTextColor:[UIColor whiteColor]];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(30, z = z + 50, self.view.bounds.size.width - 35, 400)];
            label1.numberOfLines = 0;
            [cell addSubview:label1];
            label1.text = currentPassenger.vipRemarks;
            [label1 setFont:kseatMapLabelFont];
            [label1 setTextColor:[UIColor whiteColor]];
            [label1 setAlpha:1.0f];
            [label1 sizeToFit];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else {
        
        ConexionesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conexiones"];
        cell.conexiones_Label.text = [appDel copyTextForKey:@"Conexiones"];
        
        int y = 40;
        
        if([currentPassenger.cusConnection count] > 0) {
            NSString *inStr = [NSString stringWithFormat:@"%ld", (long)[currentPassenger.cusConnection count]];
            [cell.button_label_count setHidden:NO];
            [cell.button_image setHidden:NO];
            cell.button_label_count.text = inStr;
            
            for(int i = 0; i < [currentPassenger.cusConnection count]; i++) {
                
                NSString *airlineCode = [[currentPassenger.cusConnection objectAtIndex:i]objectForKey:@"airlineCode"];
                NSString *flightNumber = [[currentPassenger.cusConnection objectAtIndex:i]objectForKey:@"flightNumber"];
                NSString *flightName = [airlineCode stringByAppendingString:flightNumber];
                UILabel *flightNumberLb = [[UILabel alloc]initWithFrame:CGRectMake(10, y, 60, 20)];
                flightNumberLb.text = flightName;
                [flightNumberLb setFont:kseatMapLabelFont];
                [flightNumberLb setTextColor:[UIColor whiteColor]];
                [flightNumberLb setAlpha:1.0f];
                [cell addSubview:flightNumberLb];
                
                UILabel *dateLb = [[UILabel alloc]initWithFrame:CGRectMake(60, y, 250, 20)];
                dateLb.text = [[currentPassenger.cusConnection objectAtIndex:i] objectForKey:@"departureDate"];
                [dateLb setFont:kseatMapLabelFont];
                [dateLb setTextColor:[UIColor whiteColor]];
                [dateLb setAlpha:1.0f];
                [cell addSubview:dateLb];
                
                UIImageView *departureImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y + 25, 15, 15)];
                departureImg.image = [UIImage imageNamed:@"N__0005_dep_icn.png"];
                [cell addSubview:departureImg];
                
                UILabel *departureAirportLb = [[UILabel alloc] initWithFrame:CGRectMake(30, y + 23, 35, 19)];
                departureAirportLb.text=[[currentPassenger.cusConnection objectAtIndex:i]objectForKey:@"departureAP"];
                [departureAirportLb setFont:kseatMapLabelFont];
                [departureAirportLb setTextColor:[UIColor whiteColor]];
                [cell addSubview:departureAirportLb];
                
                UIImageView *arrivalImg = [[UIImageView alloc] initWithFrame:CGRectMake(80, y + 25, 15, 15)];
                arrivalImg.image = [UIImage imageNamed:@"N__0006_arl_icn.png"];
                [cell addSubview:arrivalImg];
                
                UILabel *arrivalAirportLb = [[UILabel alloc] initWithFrame:CGRectMake(100, y + 23, 35, 19)];
                arrivalAirportLb.text=[[currentPassenger.cusConnection objectAtIndex:i]objectForKey:@"arrivalAP"];
                [arrivalAirportLb setFont:kseatMapLabelFont];
                [arrivalAirportLb setTextColor:[UIColor whiteColor]];
                [cell addSubview:arrivalAirportLb];
                
                y += 60;
            }
        }
        
        else {
            [cell.button_image setHidden:YES];
            [cell.button_label_count setHidden:YES];
        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int index = [self indexForIndexPath:indexPath];
    
    if(index == 0) {
        return 59;
    }
    
    else if(index == 1) {
        return 135;
    }
    
    else if (index == 2) {
        int x = 45;
        x = x + _acompaniesDataArray.count*20;
        return x;
    }
    
    else if (index == 3) {
        int y = 45;
        y = y + currentPassenger.specialMeals.count * 20;
        
        if(currentPassenger.vipCategory && [currentPassenger.vipCategory isEqualToString:@""] == NO) {
            y += 25;
            NSDictionary *attributes = @{NSFontAttributeName: kseatMapLabelFont};
            CGFloat h = [currentPassenger.vipRemarks boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 35, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.height;
            
            y += h;
        }
        
        return y;
    }
    
    else {
        if(currentPassengertemp.cusConnection.count > 0) {
            int z = 35;
            z = z + currentPassenger.cusConnection.count * 60;
            return z;
        }
        else
            return 45;
    }
}

#pragma mark TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)doneButtonTapped:(id)sender {
    [self.delegate doneButtonTapped];
}

-(void)reloadtableData{
    
    [self.detailsTableView reloadData];
    isClicked = NO;
    _selectPassenger = NO;
    seatMapobj.selectedPassenger = _selectPassenger;
    seatMapobj.isSeatClicked = isClicked;
    _acompaniesDataArray = [[NSArray alloc]init];
}

-(void)cancelBtnTapped {
    
    [docNumberPopover dismissPopoverAnimated:YES];
}

-(void)doneBtnTapped {
    [docPopup.docNumberField resignFirstResponder];
    currentPassenger.docNumber = [docPopup.docNumberField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    currentPassenger.docType = docPopup.docTypeView.selectedTextField.text;
    [docNumberPopover dismissPopoverAnimated:YES];
    
    NSMutableDictionary *customerDict = [[NSMutableDictionary alloc]init];
    
    [customerDict setValue:currentPassenger.customerId forKey:@"customerId"];
    
    [customerDict setValue:currentPassenger.docNumber forKey:@"docNumber"];
    [customerDict setValue:currentPassenger.docType forKey:@"docType"];
    
    
    NSDictionary *flightDict = [[LTSingleton getSharedSingletonInstance].flightKeyDict valueForKey:@"flightKey"];
    [SaveSeatMap updateCustomerForFlight:flightDict andCustomerDict:customerDict legNumber:_legIndex];
    [self.delegate reportCusButtonTapped:currentPassenger];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    currentPassenger.docNumber = [docPopup.docNumberField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [docNumberPopover dismissPopoverAnimated:YES];
    
    NSMutableDictionary * customerDict = [[NSMutableDictionary alloc]init];
    
    [customerDict setValue:currentPassenger.customerId forKey:@"customerId"];
    
    [customerDict setValue:currentPassenger.docNumber forKey:@"docNumber"];
    NSDictionary * flightDict = [[LTSingleton getSharedSingletonInstance].flightKeyDict valueForKey:@"flightKey"];
    [SaveSeatMap updateCustomerForFlight:flightDict andCustomerDict:customerDict legNumber:_legIndex];
    [self.delegate reportCusButtonTapped:currentPassenger];
    return YES;
    
}
- (IBAction)reportCusButtonTapped:(UIButton *)sender {
    
    if ((currentPassenger.docNumber == nil || [currentPassenger.docNumber isEqualToString:@""]) &&
        (currentPassenger.freqFlyerNum == nil || [currentPassenger.freqFlyerNum isEqualToString:@""])) {
        docPopup = [[DocNumberViewController alloc] init];
        docPopup.delegate = self;
        
        docNumberPopover = [[UIPopoverController alloc] initWithContentViewController:docPopup];
        
        [docNumberPopover  setPopoverContentSize:CGSizeMake(docPopup.view.frame.size.width, docPopup.view.frame.size.height)];
        
        [docNumberPopover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    } else {
        [self.delegate reportCusButtonTapped:currentPassenger];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 101) {
        if (buttonIndex == 0) {
            currentPassenger.docNumber =[[alertView textFieldAtIndex:0] text];
            [self.delegate reportCusButtonTapped:currentPassenger];
        }
        else
            [alertView removeFromSuperview];
    }
}

-(int)indexForIndexPath:(NSIndexPath*)indexPath {
    int index = indexPath.section;
    if(index >= 2 && _acompaniesDataArray.count == 0) {
        index++;
    }
    if(index >= 3 && (currentPassenger.specialMeals.count == 0 && (!currentPassenger.vipCategory || [currentPassenger.vipCategory isEqualToString:@""]))) {
        index++;
    }
    if(index >= 4 && currentPassenger.cusConnection.count == 0) {
        index++;
    }
    
    return index;
}

- (void)reloadConstraints {
    [self updateHeightConstraint];
}

@end
