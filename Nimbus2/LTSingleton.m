//
//  LTSingleton.m
//  LATAM
//
//  Created by Palash on 05/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTSingleton.h"
#import "TestView.h"
#import "ZKFileArchive.h"
@implementation LTSingleton
@synthesize isFromMasterScreen,enableCellsDictionary,reportDictionary,cusReportDictionary,legCount,legPressed;
@synthesize flightName,flightDate,materialType,flightGADDict,flightJsonGADDict;
@synthesize generalDictionary,synchDate,enableCells;
@synthesize imageCount,isFromViewSummary,currentFlightReportDict,isComingFromBackG,synchStatus,isCusSynced,legExecutedDict,legName;
@synthesize cusImages;
@synthesize favArrayList,favDictList,bookmarkList;
@synthesize isCardTapped;
@synthesize flightKeyDict;
@synthesize isCusCamera;

+(LTSingleton *)getSharedSingletonInstance {
    
	static LTSingleton *SharedSingletonInstance = nil;
    
    @synchronized(self) {
		if (!SharedSingletonInstance){
			SharedSingletonInstance = [[LTSingleton alloc] init];
            SharedSingletonInstance.isLoggingIn = NO;
            SharedSingletonInstance.isDataChanged = NO;
            SharedSingletonInstance.emailValid = @"";
            SharedSingletonInstance.isCusCamera = NO;
            SharedSingletonInstance.legExecutedDict = [[NSMutableDictionary alloc] init];
            
        }
		return SharedSingletonInstance;
	}
}

-(NSMutableDictionary *)flightGADDict {
    if(flightGADDict == nil) {
        return [[NSMutableDictionary alloc] init];
    }
    else
        return flightGADDict;
}

-(void)initializeFav {
    favArrayList = [[NSMutableArray alloc]init];
}

-(void)initializeFavDict {
    favDictList = [[NSMutableDictionary alloc]init];
}

-(void)initializeBookmarkList {
    bookmarkList = [[NSMutableArray alloc]init];
}

-(void)initializeEnableDictionary {
    enableCellsDictionary = [[NSMutableDictionary alloc] init];
    for(int i = 0; i < 6; i++) {
        [enableCellsDictionary setObject:[NSString stringWithFormat:@"YES"] forKey:[NSNumber numberWithInt:i]];
    }
}

-(NSIndexPath *)updateLeastIndexPath:(NSMutableArray *)indexPathArray withTable:(UITableView *)tableView {
    
    if(indexPathArray.count == 0) {
        return nil;
    }
    
    NSIndexPath *least = [indexPathArray objectAtIndex:0];
//    for(NSIndexPath *ip in indexPathArray){
//        if(![[LTSingleton getSharedSingletonInstance] mandatoryCellContainsData:(OffsetCustomCell *)[(id<UITableViewDataSource>)([[tableView superview] nextResponder]) tableView:tableView cellForRowAtIndexPath:ip]]){
//            least = [NSIndexPath indexPathForItem:ip.row inSection:ip.section];
//            break;
//        }
//    }
    
    for(NSIndexPath *ip in indexPathArray){
            least = [NSIndexPath indexPathForItem:ip.row inSection:ip.section];
            break;
    }

    
    return least;
}

-(NSIndexPath *)upcusdateLeastIndexPath:(NSMutableArray *)indexPathArray withTable:(UITableView *)tableView {
    NSIndexPath *least = [indexPathArray objectAtIndex:0];
    for(NSIndexPath *ip in indexPathArray){
        if(![[LTSingleton getSharedSingletonInstance] cusmandatoryCellContainsData:(OffsetCustomCell *)[(id<UITableViewDataSource>)([[tableView superview] nextResponder]) tableView:tableView cellForRowAtIndexPath:ip]]){
            least = [NSIndexPath indexPathForItem:ip.row inSection:ip.section];
            break;
        }
    }
    
    return least;
}

-(NSString*)zipFolder:(NSString *)folderName andWithImageFolder:(NSString *)imageFolderName withFlodername:(NSString*)flodername {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *zipFileName;
    NSString *zipFilePath;
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithString:folderName]];
    
    if ([folderName isEqualToString:@"GadReport"] ) {
        zipFileName=[flodername stringByAppendingString:@".zip"];
        zipFilePath =[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",imageFolderName,zipFileName]];
        
    } else if([folderName isEqualToString:@"CUS"]) {
        zipFileName=[flodername stringByAppendingString:@".zip"];
        zipFilePath =[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",imageFolderName,zipFileName]];
        
    } else {
        zipFileName=[imageFolderName stringByAppendingString:@".zip"];
        zipFilePath =[folderPath stringByAppendingPathComponent:zipFileName];
    }
    NSString *folderPath1 = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",imageFolderName]];
    //Delete previously creted zip and create new =====Palash
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:zipFilePath];
    if (fileExists) {
        [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
    }
    ZKFileArchive *archive = [ZKFileArchive archiveWithArchivePath:zipFilePath];
    NSInteger result;
    if ([folderName isEqualToString:@"CUS"] ) {
        NSString *documentNumber=flodername;
        NSString *imageFolderPath=[folderPath1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",documentNumber]];
        result = [archive deflateDirectory:imageFolderPath relativeToPath:folderPath1 usingResourceFork:NO];
    }
    else if ([folderName isEqualToString:@"GadReport"]) {
        NSString *documentNumber=flodername;
        NSString *imageFolderPath=[folderPath1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",documentNumber]];
        result = [archive deflateDirectory:imageFolderPath relativeToPath:folderPath1 usingResourceFork:NO];
    }
    else {
        result = [archive deflateDirectory:folderPath1 relativeToPath:folderPath usingResourceFork:NO];
    }
    
    if (result == 1) {
        NSLog(@"success");
    } else {
        NSLog(@"fail");
    }
    
    return zipFilePath;
}

-(NSString*)zipFolder:(NSString *)folderName andWithImageFolder:(NSString *)imageFolderName withFlodername:(NSString*)flodername actualfilePath:(NSString *)actualfilepath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *zipFileName;//=[imageFolderName stringByAppendingString:@".zip"];
    NSString *zipFilePath ;//=[documentsDirectory stringByAppendingPathComponent:zipFileName];
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithString:folderName]];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithString:folderName]];
    NSString *locationofimages = [filePath stringByAppendingPathComponent:actualfilepath];
    NSString *finalPathOfImages = [locationofimages stringByAppendingPathComponent:flodername];
    if ([folderName isEqualToString:@"GadReport"]) {
        zipFileName=[flodername stringByAppendingString:@".zip"];
        zipFilePath =[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",imageFolderName,zipFileName]];
        
    } else if([folderName isEqualToString:@"CUS"]) {
        zipFileName=[flodername stringByAppendingString:@".zip"];
        zipFilePath =[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",imageFolderName,zipFileName]];
        
    } else {
        zipFileName=[imageFolderName stringByAppendingString:@".zip"];
        zipFilePath =[folderPath stringByAppendingPathComponent:zipFileName];
    }
    NSString *folderPath1 = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",imageFolderName]];
    //Delete previously creted zip and create new =====Palash
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:zipFilePath];
    if (fileExists) {
        [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
    }
    ZKFileArchive *archive = [ZKFileArchive archiveWithArchivePath:zipFilePath];
    NSInteger result;
    if ([folderName isEqualToString:@"CUS"] ) {
        NSString *documentNumber=flodername;
        NSString *imageFolderPath=[folderPath1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",documentNumber]];
        result = [archive deflateDirectory:finalPathOfImages relativeToPath:folderPath1 usingResourceFork:NO];
    }
    else if ([folderName isEqualToString:@"GadReport"]) {
        NSString *documentNumber=flodername;
        NSString *imageFolderPath=[folderPath1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",documentNumber]];
        result = [archive deflateDirectory:imageFolderPath relativeToPath:folderPath1 usingResourceFork:NO];
    }
    else {
        result = [archive deflateDirectory:folderPath1 relativeToPath:folderPath usingResourceFork:NO];
    }
    
    if (result == 1) {
        NSLog(@"success");
    } else {
        NSLog(@"fail");
    }
    
    return zipFilePath;
}

-(NSString *)gadZipFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *zipFilePath =[documentsDirectory stringByAppendingPathComponent:@"GadReport.zip"];
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"GadReport"]];
    ZKFileArchive *archive = [ZKFileArchive archiveWithArchivePath:zipFilePath];
    NSInteger result = [archive deflateDirectory:folderPath relativeToPath:documentsDirectory usingResourceFork:NO];
    if (result == 1) {
        NSLog(@"success");
    }else {
        NSLog(@"fail");
    }
    
    return zipFilePath;
}

-(BOOL)mandatoryCellContainsData:(OffsetCustomCell *)cell {
    
    UIView *cellContentView ;
    if(ISiOS8)
    {
        if([[cell.subviews firstObject] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")])
        {
            cellContentView = [cell.subviews firstObject];
            
        }
    }
    else
    {
        if([[[[cell.subviews firstObject] subviews] objectAtIndex:0] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")])
        {
            cellContentView = [[[cell.subviews firstObject] subviews] objectAtIndex:0];
        
        }
        else if(([[[[cell.subviews firstObject] subviews] objectAtIndex:1] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]))
        {
            cellContentView = [[[cell.subviews firstObject] subviews] objectAtIndex:1];
        
        }
    }
    
    //Direct text fields
    NSMutableArray *textFieldsArray = [[NSMutableArray alloc] init];
    
    [textFieldsArray addObjectsFromArray:((NSMutableArray *)([[cellContentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d",MANDATORYTAG]]))];
    
    //TestView-TextViews
    NSMutableArray *testViewsArray = (NSMutableArray *)[[cellContentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@",[TestView class]]];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for(TestView *testView in testViewsArray)
    {
        // Find testview mand
        [tempArray addObjectsFromArray:[testView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d",MANDATORYTAG]]];
    }
    
    if([tempArray count] > 0){
        [textFieldsArray addObjectsFromArray:tempArray];
    }
    
    NSMutableArray *emptyTextArray = [[NSMutableArray alloc] init];
    
    for (UITextField *currentTextField in textFieldsArray) {
        currentTextField.text = [currentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (currentTextField.text.length == 0 || [currentTextField.text isEqualToString:@""] ) {
            [emptyTextArray addObject:currentTextField];
        }
    }
    
    if([emptyTextArray count] == 0){
        return YES;
    }
    else{
        return NO;
    }
}

-(BOOL)cusmandatoryCellContainsData:(OffsetCustomCell *)cell {
    
    UIView *cellContentView ;
    
    if(ISiOS8) {
        if([[cell.subviews firstObject] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) {
            cellContentView = [cell.subviews firstObject];
        }
    }
    
    else {
        if([[[[cell.subviews firstObject] subviews] objectAtIndex:0] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) {
            cellContentView = [[[cell.subviews firstObject] subviews] objectAtIndex:0];
        }
        else if(([[[[cell.subviews firstObject] subviews] objectAtIndex:1] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")])) {
            cellContentView = [[[cell.subviews firstObject] subviews] objectAtIndex:1];
        }
    }
  
    NSMutableArray *textFieldsArray = [[NSMutableArray alloc] init];
    
    [textFieldsArray addObjectsFromArray:((NSMutableArray *)([[cellContentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d",MANDATORYTAG]]))];
    
    NSMutableArray *testViewsArray = (NSMutableArray *)[[cellContentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@",[TestView class]]];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for(TestView *testView in testViewsArray) {
        [tempArray addObjectsFromArray:[testView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d",MANDATORYTAG]]];
    }
    
    if([tempArray count] > 0) {
        [textFieldsArray addObjectsFromArray:tempArray];
    }
    
    NSMutableArray *emptyTextArray = [[NSMutableArray alloc] init];
    
    //[emptyTextArray addObjectsFromArray:[textFieldsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"text == %@",@""]]];
    for (UITextField *currentTextField in textFieldsArray) {
        currentTextField.text = [currentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (currentTextField.text.length == 0 || [currentTextField.text isEqualToString:@""] ) {
            [emptyTextArray addObject:currentTextField];
        }
    }
    
    if([emptyTextArray count] == 0) {
        return YES;
    }
    else {
        return NO;
    }
}

-(NSIndexPath *)validateCell:(OffsetCustomCell *)cell withLeastIndexPath:(NSIndexPath *)leastIndexPath{
    static BOOL leastIndexPathContainsValue = NO;
    NSIndexPath *tempIndexPath;
    
    
    UIView *cellContentView;
    if(ISiOS8) {
        if([[cell.subviews firstObject] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) {
            cellContentView = [cell.subviews firstObject];
        }
    }
    
    else {
        if([[[[cell.subviews firstObject] subviews] objectAtIndex:0] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) {
            cellContentView = [[[cell.subviews firstObject] subviews] objectAtIndex:0];
        }
        else if(([[[[cell.subviews firstObject] subviews] objectAtIndex:1] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")])) {
            cellContentView = [[[cell.subviews firstObject] subviews] objectAtIndex:1];
        }
    }
    
    NSMutableArray *textFieldsArray = [[NSMutableArray alloc] init];
    
    [textFieldsArray addObjectsFromArray:((NSMutableArray *)([[cellContentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d",MANDATORYTAG]]))];
    
    
    NSMutableArray *testViewsArray = (NSMutableArray *)[[cellContentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@",[TestView class]]];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for(TestView *testView in testViewsArray) {
        [tempArray addObjectsFromArray:[testView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d",MANDATORYTAG]]];
    }
    
    if([tempArray count] > 0){
        [textFieldsArray addObjectsFromArray:tempArray];
    }
    for(UITextField *textField in textFieldsArray) {
        textField.layer.borderColor = [UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0].CGColor;
    }
    
    NSMutableArray *emptyTextArray = [[NSMutableArray alloc] init];
    
    [emptyTextArray addObjectsFromArray:[textFieldsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"text == %@",@""]]];
    
    if ([[self.legExecutedDict allKeys] count] > 1) {
        for (NSString * key in [self.legExecutedDict allKeys]) {
            
            NSString *legExecuted = [self.legExecutedDict objectForKey:key];
            
            if ([legExecuted isEqualToString:@"YES"]) {
                for(UITextField *textField in emptyTextArray) {
                    textField.layer.borderColor = [[UIColor redColor] CGColor];
                }
            }
        }
    } else if([[self.legExecutedDict allValues] count] == 1){
        NSString *legExecuted = [[self.legExecutedDict allValues] firstObject];
        
        if ([legExecuted isEqualToString:@"YES"]) {
            for(UITextField *textField in emptyTextArray) {
                textField.layer.borderColor = [[UIColor redColor] CGColor];
            }
        }
    }
    
    if(leastIndexPath.row == cell.indexPath.row && leastIndexPath.section == cell.indexPath.section){
        if([emptyTextArray count] == 0) {
            leastIndexPathContainsValue = YES;
        }
    }
    if(leastIndexPathContainsValue) {
        leastIndexPath = [NSIndexPath indexPathForItem:cell.indexPath.row inSection:cell.indexPath.section];
    }
    
    if([emptyTextArray count] > 0) {
        tempIndexPath = cell.indexPath;
        NSComparisonResult r = [tempIndexPath compare:leastIndexPath];
        if(r == NSOrderedAscending){
            leastIndexPath = [NSIndexPath indexPathForItem:tempIndexPath.row inSection:tempIndexPath.section];
            
        }
        leastIndexPathContainsValue = NO;
    }
    
    if(leastIndexPath.row == 0 && leastIndexPath.section == 0 && [self mandatoryCellContainsData:(OffsetCustomCell *)[(id<UITableViewDataSource>)([[[[cell superview] superview] superview] nextResponder]) tableView:(UITableView *)[[cell superview] superview] cellForRowAtIndexPath:leastIndexPath]] ) {
        leastIndexPath = [NSIndexPath indexPathForItem:cell.indexPath.row inSection:cell.indexPath.section];
    }
    
    if([emptyTextArray count] == 0 && leastIndexPath.row == cell.indexPath.row && leastIndexPath.section == cell.indexPath.section && cell.indexPath.section == [(UITableView *)([[cell superview] superview]) numberOfSections]-1 && cell.indexPath.row ==[(UITableView *)([[cell superview] superview]) numberOfRowsInSection:cell.indexPath.section]-1) {
        leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    
    return leastIndexPath;
}

-(NSIndexPath *)validateCusCell:(OffsetCustomCell *)cell withLeastIndexPath:(NSIndexPath *)leastIndexPath {
    static BOOL leastIndexPathContainsValue = NO;
    NSIndexPath *tempIndexPath;
    
    UIView *cellContentView ;
    
    if(ISiOS8) {
        if([[cell.subviews firstObject] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) {
            cellContentView = [cell.subviews firstObject];
        }
    }
    
    else {
        if([[[[cell.subviews firstObject] subviews] objectAtIndex:0] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) {
            cellContentView = [[[cell.subviews firstObject] subviews] objectAtIndex:0];
        }
        else if(([[[[cell.subviews firstObject] subviews] objectAtIndex:1] isKindOfClass:NSClassFromString(@"UITableViewCellContentView")])) {
            cellContentView = [[[cell.subviews firstObject] subviews] objectAtIndex:1];
        }
    }

    NSMutableArray *textFieldsArray = [[NSMutableArray alloc] init];
    
    [textFieldsArray addObjectsFromArray:((NSMutableArray *)([[cellContentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d",MANDATORYTAG]]))];
    
    
    NSMutableArray *testViewsArray = (NSMutableArray *)[[cellContentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@",[TestView class]]];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for(TestView *testView in testViewsArray) {
        [tempArray addObjectsFromArray:[testView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d",MANDATORYTAG]]];
    }
    
    if([tempArray count] > 0) {
        [textFieldsArray addObjectsFromArray:tempArray];
    }
    
    for(UITextField *textField in textFieldsArray) {
        textField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    }
    
    NSMutableArray *emptyTextArray = [[NSMutableArray alloc] init];
    
    [emptyTextArray addObjectsFromArray:[textFieldsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"text == %@",@""]]];
    
    for(UITextField *textField in emptyTextArray) {
        textField.layer.borderColor = [[UIColor redColor] CGColor];
    }
    
    if(leastIndexPath.row == cell.indexPath.row && leastIndexPath.section == cell.indexPath.section) {
        if([emptyTextArray count] == 0) {
            leastIndexPathContainsValue = YES;
        }
    }
    
    if(leastIndexPathContainsValue) {
        leastIndexPath = [NSIndexPath indexPathForItem:cell.indexPath.row inSection:cell.indexPath.section];
    }
    
    if([emptyTextArray count] > 0) {
        tempIndexPath = cell.indexPath;
        NSComparisonResult r = [tempIndexPath compare:leastIndexPath];
        if(r == NSOrderedAscending) {
            leastIndexPath = [NSIndexPath indexPathForItem:tempIndexPath.row inSection:tempIndexPath.section];
        }
        
        leastIndexPathContainsValue = NO;
    }
    
    if(leastIndexPath.row == 0 && leastIndexPath.section == 0 && [self mandatoryCellContainsData:(OffsetCustomCell *)[(id<UITableViewDataSource>)([[[[cell superview] superview] superview] nextResponder]) tableView:(UITableView *)[[cell superview] superview] cellForRowAtIndexPath:leastIndexPath]] ) {
        leastIndexPath = [NSIndexPath indexPathForItem:cell.indexPath.row inSection:cell.indexPath.section];
    }
    
    if([emptyTextArray count] == 0 && leastIndexPath.row == cell.indexPath.row && leastIndexPath.section == cell.indexPath.section && cell.indexPath.section == [(UITableView *)([[cell superview] superview]) numberOfSections]-1 && cell.indexPath.row ==[(UITableView *)([[cell superview] superview]) numberOfRowsInSection:cell.indexPath.section]-1) {
        leastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    
    return leastIndexPath;
}

@end
