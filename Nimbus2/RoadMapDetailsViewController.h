//
//  RoadMapDetailsViewController.h
//  Nimbus2
//
//  Created by Diego Cathalifaud on 10/15/15.
//  Copyright © 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RoadMapDetailsViewController : UIViewController

@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) NSString *subtitleStr;
@property (strong, nonatomic) NSString *html;
@property (weak, nonatomic) IBOutlet UIView *dialogueView;

@end
