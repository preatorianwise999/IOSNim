//
//  LTGADSignatureViewController.h
//  LATAM
//
//  Created by Madhu on 5/7/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LTGADSignatureImageProtocol<NSObject>
- (void)imageCapturedForObservador:(UIImage *)capturedImage;
- (void)deleteImageObservador;
- (void)deleteImageCapturedForTc;
- (void)imageCapturedForTc:(UIImage *)capturedImage;
-(void)closeSignaturePopover;
@end
@interface LTGADSignatureViewController : UIViewController{
    BOOL mouseSwiped;
    CGPoint lastPoint;
    CGFloat opacity;
    IBOutlet UILabel *titleString1;
    IBOutlet UIButton *closeBtn;
    IBOutlet UIButton *eraseBtn;
    IBOutlet UIButton *acceptBtn;

}
@property(nonatomic,retain)IBOutlet UIImageView *signImageView;
@property(nonatomic,retain)IBOutlet UIImageView *finalImageView;
@property(nonatomic,strong)NSString *titleString;

@property id<LTGADSignatureImageProtocol> delegate;
- (IBAction)eraserPressed:(id)sender;
- (IBAction)acceptPressed:(id)sender;
- (IBAction)closeButtonPressed:(id)sender;
@end
