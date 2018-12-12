//
//  LTGADSignatureCell.h
//  LATAM
//
//  Created by Madhu on 5/7/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@protocol LTGADSignatureProtocol<NSObject>
- (void)textViewSelectedWithTitle:(NSString *)signatureTitle withSignatureTag:(NSInteger)tag;
@end
@interface LTGADSignatureCell : UITableViewCell<UITextViewDelegate>
@property(nonatomic,retain)IBOutlet UIImageView *signatureImageView;
@property(nonatomic,retain)IBOutlet UIImageView *firmaTcImageView;
@property (nonatomic, strong)IBOutlet UILabel *firmaObservadorLabel;
@property (nonatomic, strong)IBOutlet UILabel *firmaTCLabel;

@property (nonatomic, weak)IBOutlet UIView *firmaTCContainerView;
@property (nonatomic, weak)IBOutlet UIView *firmaObservadorContainerView;
@property (nonatomic, assign)NSInteger signatureImageTag;


@property id<LTGADSignatureProtocol> delegate;
@end
