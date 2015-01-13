//
//  ChartViewController.m
//  ChartTest
//
//  Created by PwC on 5/28/14.
//  Copyright (c) 2014 PwC. All rights reserved.
//

#import "ChartViewController.h"
#import "ColumnViewController.h"
#import "ColumnInfo.h"

@interface ChartViewController ()
<
ColumnViewControllerDelegate
>
{
    NSMutableArray *arrColumnItems;
}

@property (nonatomic,strong)NSMutableArray *arrColumnItems;

@end

@implementation ChartViewController
@synthesize arrColumnItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        arrColumnItems = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)refreshWithInfos:(NSMutableArray *)arrInfos
{
    if ([arrColumnItems count] > 0) {
        for (ColumnViewController *column in arrColumnItems) {
            [column.view removeFromSuperview];
        }
        
        [arrColumnItems removeAllObjects];
    }
    
    CGFloat fwidth = [arrInfos count] * 60.0;
    
    if (fwidth > CGRectGetWidth(self.scrollViewMain.frame)) {
        [self.scrollViewMain setContentSize:CGSizeMake(fwidth, CGRectGetHeight(self.scrollViewMain.frame))];
    }
    else
    {
        [self.scrollViewMain setContentSize:CGSizeMake(CGRectGetWidth(self.scrollViewMain.frame)+1.0, CGRectGetHeight(self.scrollViewMain.frame))];
    }
    
    for (NSInteger i = 0; i < [arrInfos count]; i++) {
        ColumnInfo *info = [arrInfos objectAtIndex:i];
        ColumnViewController *columnVC = [[ColumnViewController alloc] initWithNibName:@"ColumnViewController" bundle:nil];
        columnVC.delegate = self;
        [self.scrollViewMain addSubview:columnVC.view];
        columnVC.view.frame = CGRectMake(i * 60.0, 0, CGRectGetWidth(columnVC.view.frame), CGRectGetHeight(columnVC.view.frame));
        [columnVC refreshWithInfo:info];
        [arrColumnItems addObject:columnVC];
    }
}

#pragma mark -

- (void)columnViewControllerClickedWithInfo:(ColumnInfo *)aInfo
{
    NSLog(@"columnViewControllerClickedWithInfo : %@",aInfo.strIndex);
}

@end
