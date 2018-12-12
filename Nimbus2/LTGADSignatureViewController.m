//
//  LTGADSignatureViewController.m
//  LATAM
//
//  Created by Madhu on 5/7/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import "LTGADSignatureViewController.h"

#import "AppDelegate.h"

@interface LTGADSignatureViewController ()
{
}
@end

@implementation LTGADSignatureViewController
@synthesize delegate=_delegate;
@synthesize titleString=_titleString;
Boolean stado=false;


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
    opacity=1.0;
    titleString1.text = nil;
    titleString1.text=_titleString;
    
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    //[appDel copyTextForKey:@"CLOSE"]//[appDel copyTextForKey:@"ERASE"]
    [closeBtn setTitle:[appDel copyTextForKey:@"SIGNATURE_CLOSE"] forState:UIControlStateNormal];
    [eraseBtn setTitle:[appDel copyTextForKey:@"SIGNATURE_ERASE"] forState:UIControlStateNormal];
    [acceptBtn setTitle:[appDel copyTextForKey:@"SIGNATURE_ACCEPT"] forState:UIControlStateNormal];

  
    // Do any additional setup after loading the view from its nib.
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!(lastPoint.y > 57 && lastPoint.y < 460))
        return;
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.signImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineJoin(UIGraphicsGetCurrentContext(), kCGLineJoinRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.signImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.signImageView setAlpha:opacity];
    UIGraphicsEndImageContext();
    stado= true;
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!(lastPoint.y > 57 && lastPoint.y < 460))
        return;
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.signImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.signImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        stado= true;
    }
    
    UIGraphicsBeginImageContext(self.signImageView.frame.size);
    [self.signImageView.image drawInRect:CGRectMake(0, 0,self.signImageView.frame.size.width,self.signImageView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    // [self.signImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.signImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //  self.tempSignImageView.image = nil;
    UIGraphicsEndImageContext();
}
- (IBAction)eraserPressed:(id)sender{
    self.signImageView.image = nil;
    if ([_titleString isEqualToString:@"Firma Observador"] || [_titleString isEqualToString:@"Assinatura do Observador"]) {
    [_delegate deleteImageObservador];
    }else{
    [_delegate deleteImageCapturedForTc];
    }
    stado= false;
}
- (IBAction)acceptPressed:(id)sender{
    if(stado){
        UIGraphicsBeginImageContextWithOptions(self.signImageView.bounds.size, NO,0.0);
        [self.signImageView.image drawInRect:CGRectMake(0, 0, self.signImageView.frame.size.width, self.signImageView.frame.size.height)];
   
        UIImage *saveImage = UIGraphicsGetImageFromCurrentImageContext();
    
        UIGraphicsEndImageContext();
    
        if ([_titleString isEqualToString:@"Firma Observador"] || [_titleString isEqualToString:@"Assinatura do Observador"]) {
            [_delegate imageCapturedForObservador:saveImage];
        }
        else {
            [_delegate imageCapturedForTc:saveImage];
        }
    
        [self dismissViewControllerAnimated:YES completion:nil];
        stado= false;
    }else{
    
        if ([_titleString isEqualToString:@"Firma Observador"] || [_titleString isEqualToString:@"Assinatura do Observador"]) {
            [_delegate deleteImageObservador];
        }else{
            [_delegate deleteImageCapturedForTc];
        }

        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)closeButtonPressed:(id)sender{
    //[_delegate closeSignaturePopover];
    [self dismissViewControllerAnimated:YES completion:nil];
    stado= false;
   }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
