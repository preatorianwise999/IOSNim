//
//  LTCUSCameraViewController.h
//  LATAM
//
//  Created by bhushan on 16/06/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTFlightReportCameraViewController.h"
#import "CUSReportImages.h"
#import "TestViewCameraViewController.h"

@interface LTCUSCameraViewController : UIViewController<LTFlightReportCameraProtocol,UIAlertViewDelegate>{
    IBOutlet UIImageView *photoImageView;
    
    IBOutlet UIImageView *tickImage1;
    IBOutlet UIImageView *tickImage2;
    IBOutlet UIImageView *tickImage3;
    IBOutlet UIImageView *tickImage4;
    IBOutlet UIImageView *tickImage5;
    
    IBOutlet UIButton *deleteButton;
    IBOutlet UIButton *previewButton1;
    IBOutlet UIButton *previewButton2;
    IBOutlet UIButton *previewButton3;
    IBOutlet UIButton *previewButton4;
    IBOutlet UIButton *previewButton5;
    
    IBOutlet UILabel *heading;

    
}
@property (nonatomic,strong)NSManagedObjectContext *localMoc;
@property (nonatomic,strong) NSDictionary *customerDict;

@property(nonatomic,retain)NSMutableArray *imagesArray;
@property (weak, nonatomic) IBOutlet TestView *activeTestView;
@property (nonatomic) TestViewCameraViewController *cameraVC;
@property (nonatomic, weak) IBOutlet UIButton *captureImageButton;
@property (nonatomic, weak)IBOutlet UIImageView *photoImage1;
@property (nonatomic, weak)IBOutlet UIImageView *photoImage2;
@property (nonatomic, weak)IBOutlet UIImageView *photoImage3;
@property (nonatomic, weak)IBOutlet UIImageView *photoImage4;
@property (nonatomic, weak)IBOutlet UIImageView *photoImage5;

-(IBAction)cameraButtonClicked:(id)sender;
-(IBAction)photoImageButtonClicked:(UIButton *)sender;
-(IBAction)deleteButtonClicked:(UIButton *)sender;
@end
