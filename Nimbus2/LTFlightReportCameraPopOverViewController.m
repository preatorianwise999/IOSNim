//
//  LTFlightReportCameraPopOverViewController.m
//  LATAM
//
//  Created by bhushan on 04/06/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTFlightReportCameraPopOverViewController.h"
#import "AppDelegate.h"

@interface LTFlightReportCameraPopOverViewController ()

@end

@implementation LTFlightReportCameraPopOverViewController
@synthesize popOverDataArray;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [popOverDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text=[popOverDataArray objectAtIndex:indexPath.row];
    // Configure the cell...
    
    return cell;
}

-(UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    img = nil;
    return newImage;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selectedOption=[popOverDataArray objectAtIndex:indexPath.row];
    AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([selectedOption isEqualToString:[apDel copyTextForKey:@"TAKE_PHOTO"]]) {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                      (NSString *) kUTTypeImage,
                                      nil];
            imagePicker.allowsEditing = NO;
            [self presentViewController:imagePicker animated:YES completion:nil];
            newMedia = YES;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Cemera Doesn't open"
                                  message: @"Device does not support camera"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
        }
        
        
    }
    else{
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            fromGallery=YES;
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                      (NSString *) kUTTypeImage,
                                      nil];
            imagePicker.allowsEditing = NO;
            [self presentViewController:imagePicker animated:YES completion:nil];
            newMedia = YES;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @" Doesn't open"
                                  message: @"Device does not open Gallery"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
        }
    }

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(!ISiOS8)
        [self dismissViewControllerAnimated:YES completion:nil];
  
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
   
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *originalImage = [info
                          objectForKey:UIImagePickerControllerOriginalImage];
 

        CGFloat height = 480.0f;  // or whatever you need
        CGFloat width = (height / originalImage.size.height) * originalImage.size.width;
        
        // Resize the image
        UIImage * image = [originalImage resizedImage:CGSizeMake(width, height) interpolationQuality:kCGInterpolationDefault];
        [delegate imageAfterPicking:image];

        if (!fromGallery) {
            if (newMedia)
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               @selector(image:finishedSavingWithError:contextInfo:),
                                               nil);
            
            
            
        }
        originalImage = nil;
        image = nil;
        picker=nil;
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
    
    if(ISiOS8)
        [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        AppDelegate *apDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: [apDel copyTextForKey:@"SAVE_FAILED"]
                              message: [apDel copyTextForKey:@"ALERT_SAVEFAILED_PHOTOS"]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [delegate cancelPickingImage];
    
}
- (void)didReceiveMemoryWarning
{
    DLog(@"memory warning-------------------------");
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
