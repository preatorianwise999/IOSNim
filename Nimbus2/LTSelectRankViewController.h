//
//  LTSelectRankViewController.h
//  LATAM
//
//  Created by Madan on 6/11/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LTSelectRankProtocol<NSObject>

- (void)selectedRankString:(NSString *)rank;

@end

@interface LTSelectRankViewController : UIViewController<UIPopoverControllerDelegate>
{
    NSArray *activeRankArray;
}
@property (nonatomic, strong)NSString *selectedString;
@property (nonatomic, strong)IBOutlet UITableView *rankTBView;
@property (nonatomic, strong)NSArray *activeRankArray;

@property(nonatomic,assign)  UIPopoverController *presentedPopOverController;
@property id<LTSelectRankProtocol> delegate;
@end



