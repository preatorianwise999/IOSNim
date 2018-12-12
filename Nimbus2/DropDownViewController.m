//
//  DropDownViewController.m
//  Dropdown
//
//  Created by Vishnu on 11/03/14.
//  Copyright (c) 2014 Vishnu. All rights reserved.
//

#import "DropDownViewController.h"
#import "AppDelegate.h"

@interface DropDownViewController ()
{
    BOOL checkmark;
}
@end

@implementation DropDownViewController
@synthesize valueSelected,delegate,dropTableDataSource;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithData:(NSArray *)dataSource{
    return [self initWithData:dataSource withCheckMark:YES];
    
}

-(id)initWithData:(NSArray *)dataSource withCheckMark:(BOOL)check{
    self = [self init];
    if(self){
        checkmark = check;
        self.selectedIndex = 55555;
        self.dropTableDataSource = [[NSArray alloc] initWithArray:dataSource copyItems:YES];
        self.clearsSelectionOnViewWillAppear = NO;
        
        CGFloat largestLabelWidth = 0;
        for (NSString *value in self.dropTableDataSource){
            CGSize labelSize = [value sizeWithAttributes:@{NSFontAttributeName  :   [UIFont systemFontOfSize:40.0]}];
            if(labelSize.width > largestLabelWidth){
                largestLabelWidth = labelSize.width;
            }
        }
        self.preferredContentSize = CGSizeMake(largestLabelWidth, 150);
        // self.contentSizeForViewInPopover = CGSizeMake(largestLabelWidth, 150);
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.valueSelected=@"";
//    if([self.dropTableDataSource count]==0){
//        self.dropTableDataSource = [NSArray arrayWithObjects:@"A340",@"B767",@"B787", nil];
//    }
    //self.tableView.separatorColor = [UIColor grayColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.isOther) {
        return [self.dropTableDataSource count]+3;
    }
    return [self.dropTableDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    static NSString *cellIndentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    if ([self.dropTableDataSource count]>indexPath.row) {
        //NSString *text = [self.dropTableDataSource objectAtIndex:indexPath.row];
        cell.textLabel.text = [self.dropTableDataSource objectAtIndex:indexPath.row];
        cell.textLabel.font=kDropDownFont;
//        cell.textLabel.textColor=[UIColor blackColor];
    }
    else if([self.dropTableDataSource count]+1==indexPath.row) {
        cell.textLabel.font=kDropDownFont;

        cell.textLabel.text = [apDel copyTextForKey:@"OTHER"];
//        cell.textLabel.font=kDropDownFont;

    }
    else {
        cell.textLabel.text=@"";
    }
    //cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if(checkmark) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(self.selectedIndex == indexPath.row) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick_grey"]];
            imageView.frame = CGRectMake(0, 0, 14, 14);
            imageView.tag = 111;
            cell.accessoryView = imageView;
        } else {
            cell.accessoryView = nil;
        }
        
    }
    
    if(!checkmark) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dropTableDataSource count]>indexPath.row) {
      
        if(self.selectedIndex != 5555) {
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
            oldCell.accessoryView = nil;
        }
        if(checkmark){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick_grey"]];
        imageView.frame = CGRectMake(0, 0, 14, 14);
        imageView.tag = 111;
        cell.accessoryView = imageView;
        }
        NSString *text = [self.dropTableDataSource objectAtIndex:indexPath.row];
        
        if (text && [text accessibilityLabel] == nil) {
            self.valueSelected = text;
        } else {
            self.valueSelected = [text accessibilityLabel];
        }
        
        self.selectedIndex = indexPath.row;
       
        if([delegate respondsToSelector:@selector(selectedValueInDropdown:)]) {
            [delegate selectedValueInDropdown:self];
        }
    }
    else if([self.dropTableDataSource count]+1==indexPath.row) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = @"";
        UITextField *textF = [[UITextField alloc] initWithFrame:cell.textLabel.frame];
        textF.backgroundColor = [UIColor clearColor];
        textF.delegate=self;
        [cell addSubview:textF];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [textF becomeFirstResponder];
    }
    
    
}
#pragma textFeild delegate

-(void)textFieldDidEndEditing:(UITextField *)textField {
//    self.valueSelected = textField.text;
      self.valueSelected = [NSString stringWithFormat:@"-1/%@",textField.text];
      self.valueSelected = [self.valueSelected substringToIndex: MIN(255, [self.valueSelected length])];
    if([delegate respondsToSelector:@selector(selectedValueInDropdown:)]) {
        [delegate selectedValueInDropdown:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
   
    NSString *concatText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (concatText.length > KOtherFieldsLength) {
        textField.text = [concatText substringToIndex:KOtherFieldsLength];
        return NO;
    }
    
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    //self.valueSelected = textField.text;
  
    self.valueSelected = [NSString stringWithFormat:@"-1/%@",textField.text];
    
    if([delegate respondsToSelector:@selector(selectedValueInDropdown:)]) {
        [delegate selectedValueInDropdown:self];
    }
    return TRUE;
}


@end
