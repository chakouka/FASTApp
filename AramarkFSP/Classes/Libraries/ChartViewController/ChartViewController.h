//
//  ChartViewController.h
//  ChartTest
//
//  Created by PwC on 5/28/14.
//  Copyright (c) 2014 PwC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartViewController : UIViewController
<
UIScrollViewDelegate
>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewMain;

- (void)refreshWithInfos:(NSMutableArray *)arrInfos;

@end
