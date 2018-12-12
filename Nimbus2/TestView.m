


#import "TestView.h"
#import "AppDelegate.h"
#import "OffsetCustomCell.h"
#import "LTSingleton.h"
#import "UIPopoverController+removeInBackground.h"
#import "AlertUtils.h"
#import "LTFlightReportCameraViewController.h"

@interface TestView()
{
    UIPopoverArrowDirection popoverDirection;
    
    
    AppDelegate *appDel;
    LTFlightReportCameraViewController *flightReportCameraViewController;
    NSString *flightName;
    
    NSString *flightDate;
    BOOL isPickerChanged;
    PickerDoneCancelViewController* popoverContent;
}

@end

@implementation TestView
@synthesize dropDownObject,selectedValue,typeOfDropDown,dataSource;
@synthesize key,saveButton,deleteButton,backgroundView,notesView,headingLabel,dateHeaderTitle;
@synthesize  addFlight;
@synthesize imageName;

@synthesize deleteImage;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    if([[self subviews] count] == 0) {
        TestView *view = [[[NSBundle mainBundle] loadNibNamed:@"TestView" owner:Nil options:nil] firstObject];
        view.frame = self.frame;
        view.autoresizingMask = self.autoresizingMask;
        view.addFlight = NO;
        view.selectedTextField.textColor = kFontColor;
        view.selectedTextField.layer.borderWidth = 1.0f;
        view.selectedTextField.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3].CGColor;//[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3].CGColor;//[[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
        
        view.selectedTextField.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3];
        
        view.selectedTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
        //        if(view.dataSource.count == 0)
        //            view.dataSource = [NSArray arrayWithObjects:@"A340",@"B767",@"B787", nil];
        isPickerChanged = NO;
        
        
        return view;
    }
    return self;
}



-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        //        [self baseInit];
    }
    return self;
}

-(void)layoutSubviews{
    if(typeOfDropDown == AlertDropDown || typeOfDropDown == CameraDropDown){
        _accessoryImage.hidden = YES;
    }
}

- (void)willRotateToOrientation:(UIInterfaceOrientation)newOrientation {
    // Handle rotation
    NSLog(@"pop over %@", popoverController);
    UIButton *sender = _senderButton;
    [popoverController dismissPopoverAnimated:NO];
    [popoverController presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:popoverDirection animated:NO];
}

-(void)selectedValueInDropdown:(DropDownViewController *)obj{
    [LTSingleton getSharedSingletonInstance].isDataChanged=TRUE;
    
    _selectedTextField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    self.selectedValue = obj.valueSelected;
    // _selectedTextField.text=obj.valueSelected;
    if([self.selectedValue containsString:@"-1"])
        _selectedTextField.text= [self.selectedValue substringFromIndex:3];
    else
        _selectedTextField.text=[obj.dropTableDataSource objectAtIndex:obj.selectedIndex];
    
    self.selectedIndex = obj.selectedIndex;
    
    [popoverController dismissPopoverAnimated:YES];
    obj=nil;
    popoverController = nil;
    if (self.typeOfDropDown == CameraDropDown) {
        NSString *documentsDirectory=[self createImageFolder];
        if ( [LTSingleton getSharedSingletonInstance].isCusCamera) {
            [LTSingleton getSharedSingletonInstance].isCusCamera = NO;
            
        }

        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[imageName lastPathComponent]];
        DLog(@"doc path:%@",dataPath);
        if([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:nil] count] == 5 && (imageName == nil || [imageName isEqualToString:@""]) )
        {
            [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"WARNING"] message:[appDel copyTextForKey:@"ALERT_MAX_PHOTOS"]];
            return;
        }
        if(imageName==nil)
            imageName=[[NSString alloc]init];
        UIImage *img = [UIImage imageWithContentsOfFile:dataPath];
        if (img == nil) {
            self.typeOfDropDown = CameraDropDownImage;
        }
    }
    if([_delegate respondsToSelector:@selector(valueSelectedInPopover:)]){
        [_delegate valueSelectedInPopover:self];
    }
}
/*
 NSDateFormatter *outputFormatter3 = [[NSDateFormatter alloc] init];
 [outputFormatter3 setDateFormat:@"yyyy MM dd'T'HH:mm:ss"];
 [outputFormatter3 setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
 
 
 */
- (void)pickerDoneButtonClicked{
    isPickerChanged = YES;
    
    _selectedTextField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    if(addFlight){
        [outputFormatter setDateFormat:@"dd MMMM HH:mm"];
        [outputFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
        
        NSDateFormatter *dateWithYear = [[NSDateFormatter alloc] init];
        [dateWithYear setDateFormat:@"yyyy MM dd'T'HH:mm"];//dd MM yyyy HH:mm
        self.selectedValue = [dateWithYear stringFromDate:datePicker.date];
        
        if(self.selectedValue == nil)
        {
            DLog(@"abc..............");
        }
        _selectedTextField.text = [outputFormatter stringFromDate:datePicker.date];
        dateWithYear= nil;
        
    }
    else{
        [outputFormatter setDateFormat:@"HH:mm"];
        self.selectedValue = [outputFormatter stringFromDate:datePicker.date];
        _selectedTextField.text = self.selectedValue;
    }
    
    [LTSingleton getSharedSingletonInstance].isDataChanged = YES;
    if([_delegate respondsToSelector:@selector(valueSelectedInPopover:)]){
        [_delegate valueSelectedInPopover:self];
    }
    
    if([_delegate respondsToSelector:@selector(valueSelectedWhenDismissPopover:)]){
        [_delegate valueSelectedWhenDismissPopover:self];
    }
    [popoverController dismissPopoverAnimated:YES];
    
    //ßdatePicker = nil;
    popoverController = nil;
    outputFormatter = nil;
}
- (void)pickerCancelButtonClicked{
    [popoverController dismissPopoverAnimated:YES];
    datePicker = nil;
    popoverController = nil;
}


-(void)pickerChanged:(UIDatePicker *)picker{
    
    
}

- (IBAction)dropDownTap:(UIButton *)sender {
    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.senderButton=sender;
    if ([self.delegate respondsToSelector:@selector(setActiveTestView:)]) {
        [self.delegate setActiveTestView:self];
    }
    
    if(![popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:NO];
        popoverController = nil;
    }
    
    // Vishnu: to resign a textfield when a dropdown is tapped; to prevent popover from floating around
    UIView *view = (UIView *) [[[UIApplication sharedApplication] keyWindow] performSelector:@selector(firstResponder)];
    [view resignFirstResponder];
    
    //End
    
    // Vishnu: If there is delete,remove it
    if(ISiOS8)
    {
        if([NSStringFromClass([[[[[self superview] superview] subviews] firstObject] class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"]){
            if([[[self superview] superview] isKindOfClass:[OffsetCustomCell class]]) {
                ((OffsetCustomCell *)[[self superview] superview]).comboBoxShown = YES;
                [((OffsetCustomCell *)[[self superview] superview]) layoutSubviews];
            }
        }
    }
    else
    {
        if([NSStringFromClass([[[[[self superview] superview] subviews] firstObject] class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"]){
            if([[[[self superview] superview] superview] isKindOfClass:[OffsetCustomCell class]]) {
                ((OffsetCustomCell *)[[[self superview] superview] superview]).comboBoxShown = YES;
                [((OffsetCustomCell *)[[[self superview] superview] superview]) layoutSubviews];
            }
        }
    }
    
    // End removing Delete
    
    if (self.typeOfDropDown == CameraDropDown) {
        self.dataSource = [[NSArray alloc]initWithObjects:[appDel copyTextForKey:@"TAKE_PHOTO"],[appDel copyTextForKey:@"CHOOSE_EXISTING"], nil];
    }
    
    //    if(!dropDownObject){
    if(dropDownObject!=nil)
        dropDownObject = nil;
    dropDownObject = [[DropDownViewController alloc] initWithData:dataSource];
    UINavigationController *dropDownNav = [[UINavigationController alloc] initWithRootViewController:dropDownObject];
    dropDownObject.title = [appDel valueForEnglishValue:self.key];
    
    
    
    
    CGRect frame = CGRectMake(0, 0, 200, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = NAVIGATIONBAR_COLOR;
//    [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor redColor];
    label.font=kdropDownHeading;
    label.text = dropDownObject.navigationItem.title;
    // emboss in the same way as the native title
    [label setShadowColor:[UIColor darkGrayColor]];
    [label setShadowOffset:CGSizeMake(0, -0.5)];
    dropDownObject.navigationItem.titleView = label;

    [dropDownNav.navigationBar setBackgroundColor:NAVIGATIONBAR_COLOR];
    
    //    }
    if([self.selectedTextField.text length]>0) {
        int index = [dataSource indexOfObject:self.selectedTextField.text];
        dropDownObject.selectedIndex = index;
        
    }else {
        dropDownObject.selectedIndex = 5555;
        
    }
    if(typeOfDropDown == NormalDropDown){
        //        if(!popoverController){
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController:dropDownNav];
        dropDownObject.delegate = self;
        //dropDownObject.isOther=TRUE;
        //            if(dataSource.count == 0)
        //               dataSource = [NSArray arrayWithObjects:@"A340",@"B767",@"B787", nil];
        
        if(dataSource.count>=7){
            if(ISiOS8)
                dropDownNav.preferredContentSize = CGSizeMake(400, 350);
            else
                [popoverController setPopoverContentSize:CGSizeMake(400, 350) animated:NO];
            
        }
        else
        {
            if(ISiOS8)
                dropDownNav.preferredContentSize = CGSizeMake(400, (dataSource.count+1)*45);
            else
                [popoverController setPopoverContentSize:CGSizeMake(400, (dataSource.count+1)*45) animated:NO];
            
        }
        if([self.key isEqualToString:[appDel copyEnglishTextForKey:@"SEAT_MAINTENANCE"]])
        {
            if(ISiOS8)
                dropDownNav.preferredContentSize =CGSizeMake(550, dropDownNav.preferredContentSize.height);
            else
                [popoverController setPopoverContentSize:CGSizeMake(550, popoverController.popoverContentSize.height) animated:NO];
            
            
        }
        
        popoverDirection = UIPopoverArrowDirectionAny;
        //        }
        [dropDownObject.tableView reloadData];
        
    }
    else if(typeOfDropDown == OtherDropDown){
        //  if(!popoverController){
        popoverController = [[UIPopoverController alloc] initWithContentViewController:dropDownNav];
        dropDownObject.delegate = self;
        dropDownObject.isOther=TRUE;
        if(dataSource.count+3>=7)
        {
            if(ISiOS8)
                dropDownObject.preferredContentSize = CGSizeMake(400, 350);
            else
                [popoverController setPopoverContentSize:CGSizeMake(400, 350) animated:NO];
            
        }
        else
        {
            if(ISiOS8)
                dropDownObject.preferredContentSize = CGSizeMake(400, (dataSource.count+3)*45);
            else
                [popoverController setPopoverContentSize:CGSizeMake(400, (dataSource.count+3)*45) animated:NO];
        }
        
        
        //[popoverController setPopoverContentSize:CGSizeMake(400, 350) animated:NO];
        popoverDirection = UIPopoverArrowDirectionDown;
        
        //   }
        [dropDownObject.tableView reloadData];
        
    }
    
    else if(typeOfDropDown == DateDropDown){
        
        if(datePicker){
            datePicker = nil;
        }
        
        datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = (addFlight)?UIDatePickerModeDateAndTime:UIDatePickerModeTime;
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[appDel getLanguageCodeForLocale]];
        [datePicker setLocale:locale];
        [datePicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
        
        popoverContent = [[PickerDoneCancelViewController alloc] initWithNibName:@"PickerDoneCancelViewController" bundle:nil]; //ViewController
        popoverContent.delgate = self;
        
//        CGRect frame1 = CGRectMake(0, 0, 200, 44);
//        UILabel *label = [[UILabel alloc] initWithFrame:frame];
//        label.backgroundColor = [UIColor redColor];
//        //    [UIColor clearColor];
//        label.textAlignment = NSTextAlignmentCenter;
//        //    label.textColor = [UIColor redColor];
//        label.font=kdropDownHeading;
//        label.text = self.dateHeaderTitle;

        popoverContent.titleForHeader = self.dateHeaderTitle;
    
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        if(addFlight){
            [outputFormatter setDateFormat:@"yyyy MM dd'T'HH:mm"];//yyyy MM dd'T'HH:mm:ss //"yyyy-MM-dd"
        }
        else{
            [outputFormatter setDateFormat:@"HH:mm"];
        }
        
        if(!self.selectedValue || [self.selectedValue isEqualToString:@""]){
            if(addFlight){
                self.selectedValue = [outputFormatter stringFromDate:[NSDate date]];
            }
            else{
                self.selectedValue = @"00:00";
            }
        }
        [datePicker setDate:[outputFormatter dateFromString:self.selectedValue] animated:YES];
        //  popoverContent.view = popoverView;
        CGRect frame = datePicker.frame;
        frame.origin.y = +44;
        datePicker.frame = frame;
        [popoverContent.view addSubview:datePicker];
        popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        popoverController.delegate = self;
        if(ISiOS8)
            popoverContent.preferredContentSize = CGSizeMake(320, 265);
        else
            [popoverController setPopoverContentSize:CGSizeMake(320, 265) animated:NO];
        
        popoverDirection = UIPopoverArrowDirectionAny;
        //       / }
        outputFormatter = nil;
        
        
        /*
         @humera code changes commented
         //=======
         if(!self.selectedValue || [self.selectedValue isEqualToString:@""]){
         if(addFlight){
         self.selectedValue = [outputFormatter stringFromDate:[NSDate date]];
         }
         else{
         self.selectedValue = @"00:00";
         }
         }
         
         [datePicker setDate:[outputFormatter dateFromString:self.selectedValue] animated:YES];
         
         //  popoverContent.view = popoverView;
         CGRect frame = datePicker.frame;
         
         
         frame.origin.y = +44;
         datePicker.frame = frame;
         [popoverContent.view addSubview:datePicker];
         popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
         popoverController.delegate = self;
         if(ISiOS8)
         popoverContent.preferredContentSize = CGSizeMake(320, 265);
         else
         [popoverController setPopoverContentSize:CGSizeMake(320, 265) animated:NO];
         //>>>>>>> .r7844
         */

        
    }
    else if(typeOfDropDown == AlertDropDown){
        
        if(!backgroundView){
            
            backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 530, 230)];
            [backgroundView setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
            deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [deleteButton setFrame:CGRectMake(5, 0, 100, 50)];
            [deleteButton setTitle:[appDel copyTextForKey:@"TABLEVIEW_DELETE"] forState:UIControlStateNormal];
//            [deleteButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
            [deleteButton.titleLabel setFont:[UIFont fontWithName:kFontName_Robotica_Light size:18.0f]];

            [deleteButton addTarget:self action:@selector(deleteTapped:) forControlEvents:UIControlEventTouchUpInside];
            [backgroundView addSubview:deleteButton];
            
            
            saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [saveButton setFrame:CGRectMake(435, 0, 100, 50)];
            [saveButton setTitle:[appDel copyTextForKey:@"SAVE_LABEL"] forState:UIControlStateNormal];
            [saveButton.titleLabel setFont:[UIFont fontWithName:kFontName_Robotica_Light size:18.0f]];

//            [saveButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
            
            [saveButton addTarget:self action:@selector(saveTapped:) forControlEvents:UIControlEventTouchUpInside];
            
//            NSString *trimmedStr = [notesView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//            trimmedStr = [notesView.text substringToIndex: MIN(255, [notesView.text length])];
//            self.selectedValue = trimmedStr;
//            if([_delegate respondsToSelector:@selector(valueSelectedInPopover:)]){
//                [_delegate valueSelectedInPopover:self];
//            }
            [popoverController dismissPopoverAnimated:YES];
            [backgroundView addSubview:saveButton];
            
            headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
            [headingLabel setTextAlignment:NSTextAlignmentCenter];
            headingLabel.center = CGPointMake(backgroundView.center.x, saveButton.center.y);
            headingLabel.text = [appDel copyTextForKey:@"OBSERVATION"];
            [headingLabel setFont:[UIFont fontWithName:kFontName_Robotica_Light size:18.0f]];

            [backgroundView addSubview:headingLabel];
            
            
            notesView = [[UITextView alloc] initWithFrame:CGRectMake(15, 50, 500, 150)];
//            [notesView setFont:[UIFont systemFontOfSize:18.0f]];
                      [notesView setFont:knotesViewFont];

//            [notesView textColor:]
//            [notesView textColor:[UIColor redColor]];
            [notesView setText:self.selectedValue];
            notesView.delegate = self;
            [backgroundView addSubview:notesView];
            
            notesView.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
            notesView.layer.borderWidth = 1.0f;
            
            UIViewController *popoverContent = [[UIViewController alloc] init];
            
            UIView *popoverView = [[UIView alloc] init];
            [popoverView addSubview:backgroundView];
            
            popoverContent.view = popoverView;
            popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
            if(ISiOS8)
                popoverContent.preferredContentSize = CGSizeMake(530, 230);
            else
                [popoverController setPopoverContentSize:CGSizeMake(530, 230) animated:NO];
            popoverDirection = UIPopoverArrowDirectionDown;
            
        }
        
    }
    //madhu added
    //******************************************//
    // Code Commented In Second Phase for Tempo //
    //******************************************//
    else if(typeOfDropDown == CameraDropDown){
        NSString *documentsDirectory=[self createImageFolder];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[imageName lastPathComponent]];
        DLog(@"doc path:%@",dataPath);
        if([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:nil] count] == 5 && (imageName == nil || [imageName isEqualToString:@""])  && ![LTSingleton getSharedSingletonInstance].isCusCamera)
        {
            [AlertUtils showErrorAlertWithTitle:[appDel copyTextForKey:@"WARNING"] message:[appDel copyTextForKey:@"ALERT_MAX_PHOTOS"]];
            return;
        }
        if(imageName==nil)
            imageName=[[NSString alloc]init];
        UIImage *img = [UIImage imageWithContentsOfFile:dataPath];
        if (img) {
            flightReportCameraViewController =[[LTFlightReportCameraViewController alloc] initWithNibName:@"LTFlightReportCameraViewController" bundle:nil];
            
            flightReportCameraViewController.testViewImage=self;
            flightReportCameraViewController.pickingImage = img;
            popoverController =[[UIPopoverController alloc] initWithContentViewController:flightReportCameraViewController];
            popoverController.delegate = self;
            
            if(ISiOS8)
                flightReportCameraViewController.preferredContentSize = CGSizeMake(500, 450);
            else
                popoverController.popoverContentSize = CGSizeMake(500, 450);
            popoverDirection = UIPopoverArrowDirectionRight;
        }else{
            
//            NSArray *cameraOptionsArray =[[NSArray alloc]initWithObjects:[appDel copyTextForKey:@"TAKE_PHOTO"],[appDel copyTextForKey:@"CHOOSE_EXISTING"], nil];
//            TestViewCameraPopOverViewController *flightReportCameraPopOverViewController=[[TestViewCameraPopOverViewController alloc] initWithNibName:@"TestViewCameraPopOverViewController" bundle:nil];
//            flightReportCameraPopOverViewController.delegate=self;
//            flightReportCameraPopOverViewController.popOverDataArray=cameraOptionsArray;
            DropDownViewController *dropDownObject1 = [[DropDownViewController alloc] initWithData:dataSource withCheckMark:NO];
            dropDownObject1.delegate = self;

            popoverController =[[UIPopoverController alloc] initWithContentViewController:dropDownObject1];
            if(ISiOS8)
                dropDownObject1.preferredContentSize = CGSizeMake(250, 100);
            else
                popoverController.popoverContentSize = CGSizeMake(250, 100);
            popoverDirection = UIPopoverArrowDirectionRight;
            
        }
    }
    
    popoverController.delegate = self;
    if(![popoverController isPopoverVisible])
        [popoverController presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:popoverDirection animated:YES];
    dropDownNav=nil;
}


-(NSString *)generateRandomString
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:3];
    
    for (int i = 0; i < 3; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
    
}
//create folder for image storing
-(NSString *)createImageFolder{
    
    NSError *error;
    flightName=[LTSingleton getSharedSingletonInstance].flightName;
    flightDate=[LTSingleton getSharedSingletonInstance].flightDate;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/FlightReport"];
    NSString *imageFolderName=[flightName stringByAppendingString:flightDate];
    NSString *insideFolderPath=[dataPath stringByAppendingPathComponent:imageFolderName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    if (![[NSFileManager defaultManager] fileExistsAtPath:insideFolderPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:insideFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
    if ([LTSingleton getSharedSingletonInstance].isCusCamera){
        insideFolderPath = [insideFolderPath stringByAppendingString:@"/CUS"];
    }
    
    return insideFolderPath;
    
    
}
-(void)imageAfterPicking:(UIImage *)pickedImage{
    flightName=[LTSingleton getSharedSingletonInstance].flightName;
    
    NSString *randomString=[self generateRandomString];
    NSString *photoName=[flightName stringByAppendingString:randomString];
    NSString *photoName1=[photoName stringByAppendingString:@".png"];
    NSData *pngData = UIImageJPEGRepresentation(pickedImage, 0.4);
    NSString *imagePath=[self createImageFolder];
    NSString *filePath = [imagePath stringByAppendingPathComponent:photoName1];
    imageName=photoName1;
    
    //Add the file name
    
    [pngData writeToFile:filePath atomically:YES];
    
    //Add the file name
    DLog(@"inside afeter image pickeing in test view");
    flightReportCameraViewController =[[LTFlightReportCameraViewController alloc] initWithNibName:@"LTFlightReportCameraViewController" bundle:nil];
    flightReportCameraViewController.testViewImage=self;
    [popoverController dismissPopoverAnimated:YES];
    popoverController=nil;
    flightReportCameraViewController.pickingImage=pickedImage;
    popoverController =[[UIPopoverController alloc] initWithContentViewController:flightReportCameraViewController];
    popoverController.delegate = self;
    if(ISiOS8)
        flightReportCameraViewController.preferredContentSize = CGSizeMake(500, 450);
    else
        popoverController.popoverContentSize = CGSizeMake(500, 450);
    popoverDirection = UIPopoverArrowDirectionRight;
//    if(self.window!=nil)
        [popoverController presentPopoverFromRect:_senderButton.frame inView:_senderButton.superview permittedArrowDirections:popoverDirection animated:YES];
    
    pngData=nil;
    pickedImage = nil;
    
}
-(void)cancelPickingImage{
    [popoverController dismissPopoverAnimated:YES];
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover{
    if(ISiOS8)
    {
        if([[[self superview] superview] isKindOfClass:[OffsetCustomCell class]])
            ((OffsetCustomCell *)[[self superview] superview]).comboBoxShown = NO;
    }
    else
    {
        if([[[[self superview] superview] superview] isKindOfClass:[OffsetCustomCell class]])
            ((OffsetCustomCell *)[[[self superview] superview] superview]).comboBoxShown = NO;
    }
    if(typeOfDropDown == AlertDropDown ){
        NSString *trimmedStr = [notesView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        trimmedStr = [notesView.text substringToIndex: MIN(255, [notesView.text length])];
        self.selectedValue = trimmedStr;
        if([_delegate respondsToSelector:@selector(valueSelectedInPopover:)]){
            [_delegate valueSelectedInPopover:self];
        }
        [popoverController dismissPopoverAnimated:YES];
    }
    else if(typeOfDropDown == CameraDropDown){
        self.deleteImage=NO;
        if([_delegate respondsToSelector:@selector(valueSelectedInPopover:)]){
            [_delegate valueSelectedInPopover:self];
        }
    }
    else if(typeOfDropDown == NormalDropDown || typeOfDropDown == OtherDropDown){
        if(ISiOS8)
        {
            if([[[self superview] superview] isKindOfClass:[OffsetCustomCell class]])
            {
                NSIndexPath *ip = ((OffsetCustomCell *)[[self superview] superview]).indexPath;
                
                if(ip.section == 5 || ip.section == 6){
                
                    ip = [NSIndexPath
                           indexPathForRow:ip.row
                           inSection:1];
                    
                }
                
                [((UITableView *)([[[[self superview] superview] superview] superview])) beginUpdates];
                [((UITableView *)([[[[self superview] superview] superview] superview])) reloadRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationNone];
                [((UITableView *)([[[[self superview] superview] superview] superview])) endUpdates];
            }
        }
        else
        {
            if([[[[self superview] superview] superview] isKindOfClass:[OffsetCustomCell class]])
            {
                NSIndexPath *ip = ((OffsetCustomCell *)[[[self superview] superview] superview]).indexPath;
                if(ip.section == 5 || ip.section == 6){
                    
                    ip = [NSIndexPath
                          indexPathForRow:ip.row
                          inSection:1];
                    
                }
                [((UITableView *)([[[[[self superview] superview] superview] superview] superview])) beginUpdates];
                [((UITableView *)([[[[[self superview] superview] superview] superview] superview])) reloadRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationNone];
                [((UITableView *)([[[[[self superview] superview] superview] superview] superview])) endUpdates];
            }
        }
    }
    else if(typeOfDropDown == DateDropDown){
        // NSString *stringFromWS =self.selectedTextField.text;
        // if (!isPickerChanged) {}
        _selectedTextField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        if(addFlight)
        {
            [outputFormatter setDateFormat:@"dd MMMM HH:mm"];
            [outputFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[appDel getLanguageCodeForLocale]]];
            NSDateFormatter *dateWithYear = [[NSDateFormatter alloc] init];
            [dateWithYear setDateFormat:@"yyyy MM dd'T'HH:mm"];//yyyy MM dd'T'HH:mm:ss //dd MM yyyy HH:mm
            self.selectedValue = [dateWithYear stringFromDate:datePicker.date];
            _selectedTextField.text = [outputFormatter stringFromDate:datePicker.date];
        }
        else{
            [outputFormatter setDateFormat:@"HH:mm"];
            NSDateFormatter *dateWithYear = [[NSDateFormatter alloc] init];
            [dateWithYear setDateFormat:@"HH:mm"];
            self.selectedValue = [dateWithYear stringFromDate:datePicker.date];
            _selectedTextField.text = self.selectedValue;
            [LTSingleton getSharedSingletonInstance].isDataChanged = YES;
        }
        
        if([_delegate respondsToSelector:@selector(valueSelectedInPopover:)]){
            [_delegate valueSelectedInPopover:self];
        }
    }
    if([_delegate respondsToSelector:@selector(setActiveTestView:)]){
        [_delegate setActiveTestView:nil];
    }
    datePicker=nil;
    self.senderButton=nil;
    self.dropDownButton=nil;
    popoverController=nil;
    self.notesView=nil;
    self.dateHeaderTitle=nil;
    self.headingLabel=nil;
    self.deleteButton=nil;
    self.backgroundView=nil;
    //self.dataSource=nil;
    self.dropDownObject=nil;
    self.notesView=nil;
}

-(void)deleteTapped:(UIButton *)sender{
    notesView.text=@"";
    self.selectedValue=@"";
    if([_delegate respondsToSelector:@selector(valueSelectedInPopover:)]){
        [_delegate valueSelectedInPopover:self];
    }
    [popoverController dismissPopoverAnimated:YES];
}

-(void)saveTapped:(UIButton *)sender{
    
    NSString *trimmedStr = [notesView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    trimmedStr = [notesView.text substringToIndex: MIN(255, [notesView.text length])];
    
    
    if ([trimmedStr length] == 0) {
        self.selectedValue = @"";
    }
    else
        self.selectedValue = trimmedStr;
    if([_delegate respondsToSelector:@selector(valueSelectedInPopover:)]) {
        [_delegate valueSelectedInPopover:self];
    }
    [popoverController dismissPopoverAnimated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *concatText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if (concatText.length > TEXTVIEWLENGTH) {
        
        textView.text = [concatText substringToIndex:TEXTVIEWLENGTH];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    DLog(@"%@",NSStringFromCGSize([[popoverController contentViewController] preferredContentSize]));
    
    [UIView animateWithDuration:kTableViewTransitionSpeed animations:^{
        if(ISiOS8)
            [[popoverController contentViewController] setPreferredContentSize:CGSizeMake(530, 230)];
        else
            [popoverController setPopoverContentSize:CGSizeMake(530, 230) animated:NO];
        
    }];
}
@end
