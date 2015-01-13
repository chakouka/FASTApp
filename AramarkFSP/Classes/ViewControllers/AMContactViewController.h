//
//  AMContactViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWOTabBaseViewController.h"

@interface AMContactViewController : AMWOTabBaseViewController

@property (strong, nonatomic) NSArray *contactArr;
@property (strong, nonatomic) NSMutableArray *contactBlockArr;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
