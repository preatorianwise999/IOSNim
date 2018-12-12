//
//  OnlyTextViewCell.h
//  LATAM
//
//  Created by Vishnu on 12/04/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnlyTextViewCell : UITableViewCell

@property(nonatomic,retain) NSIndexPath *indexPath;
@property(nonatomic,retain) IBOutlet UITextView *textView;

@end
