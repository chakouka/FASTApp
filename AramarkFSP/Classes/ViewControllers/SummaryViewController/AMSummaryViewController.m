//
//  AMSummaryViewController.m
//  AramarkFSP
//
//  Created by PwC on 5/28/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMSummaryViewController.h"
#import "TestManage.h"
#import "SFRestAPI.h"
//#import "SFAccountManager.h"
#import "SFAuthenticationManager.h"
#import "SFIdentityData.h"
#import "AMProtocolParser.h"

@interface AMSummaryViewController () <UIScrollViewDelegate>
// Model
@property (strong, nonatomic)NSMutableArray  *arrInfos;
@property (strong, nonatomic)NSMutableArray *arrFutureInfos;
// UI
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewMain;
@property (weak, nonatomic) IBOutlet UIButton *btn_left;
@property (weak, nonatomic) IBOutlet UIButton *btn_right;
@property (nonatomic,strong) NSDate *firstDate;
@property (nonatomic) NSTimeInterval firstDateInterval;

@property (nonatomic) BOOL isNotFirstTime;
@end

#define numberOfDaysDisplayed 14
#define numberOfDaysDisplayedFuture 7

@implementation AMSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Summary Screen";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(update)
                                                 name:NOTIFICATION_SHOW_SUMMARY
                                               object:nil];
    
}

-(void)update
{  
    self.view.alpha = 0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.5*NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SVProgressHUD dismiss];
    });
    
    
#ifdef TEST_FOR_SVPROGRESSHUD
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%s", __FUNCTION__]];
#else
    [SVProgressHUD show];
#endif
    [self performSelector:@selector(updateModelAndUI) withObject:nil afterDelay:0.0];
}


-(void)updateModelAndUI
{
    dispatch_queue_t q = dispatch_queue_create("q", NULL);
    dispatch_async(q, ^{
        
        [self updateModel];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];


            [SVProgressHUD dismiss];
            [UIView animateWithDuration:0.3 animations:^{
                self.view.alpha = 1;
            } completion:^(BOOL finished) {

            }];
        });
    });
}


#pragma mark - Model

-(void)updateModel
{
    NSArray *array = [[AMLogicCore sharedInstance] getSummaryWorkOrderList];
    [self parseWorkOrders:array];
    
    NSArray *tmpArray =[[AMLogicCore sharedInstance] getSummaryWorkOrderListInFutureDaysExcludeToday:numberOfDaysDisplayedFuture];
    
    NSMutableArray *arrayFuture = [NSMutableArray array];
    for (int i=0; i<tmpArray.count; i++) {
        NSArray *array = [[[tmpArray objectAtIndex:i] allValues]lastObject];
        [arrayFuture addObject:array];
    }
    [self parseWorkOrdersFuture:arrayFuture];

    
    NSTimeInterval interval = [AMUtilities timeBySecondWithDate:[NSDate date]];
    self.firstDateInterval = [AMUtilities daysBefore:[self.arrInfos count]-1 from:interval];
    self.firstDate = [AMUtilities dateWithTimeSecond:self.firstDateInterval];
    
}

#pragma mark - Work Data

-(void)testData
{
    NSMutableArray *arrResult = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 7; i ++) {
        NSMutableArray *arrOneDay = [NSMutableArray array];
        NSInteger iCount = random() % 11 + 1;
        for (NSInteger j = 0; j < iCount; j ++) {
            AMWorkOrder *orderInfo = [[TestManage sharedInstance] randomLocalWorkOrder];
            
            [arrOneDay addObject:orderInfo];
        }
        [arrResult addObject:arrOneDay];
    }
    
    [self refreshWithFutureInfos:arrResult];
}

- (void)parseWorkOrders:(NSArray *)array{
    NSMutableArray *mArray = nil;
    if (array) {
        mArray = [[NSMutableArray alloc]initWithArray:array];
    }else{
        mArray = [[NSMutableArray alloc]initWithCapacity:numberOfDaysDisplayed];
        for (int i=0; i<numberOfDaysDisplayed; i++) {
            NSArray *oneDayArray = [[NSArray alloc]init];
            [mArray addObject:oneDayArray];
        }
    }
    [self refreshWithInfos:mArray];
    
}

- (void)parseWorkOrdersFuture:(NSArray *)array{
    NSMutableArray *mFutureArray = nil;
    if (array) {
        mFutureArray = [[NSMutableArray alloc]initWithArray:array];
    }else{
        mFutureArray = [[NSMutableArray alloc]initWithCapacity:numberOfDaysDisplayedFuture];
        for (int i=0; i<numberOfDaysDisplayedFuture; i++) {
            NSArray *oneDayArray = [[NSArray alloc]init];
            [mFutureArray addObject:oneDayArray];
        }
    }
    [self refreshWithFutureInfos:mFutureArray];
}

- (void)refreshWithInfos:(NSMutableArray *)aInfos
{
    if ([aInfos count] == 0) {
        return;
    }
    
    self.arrInfos = aInfos;
}

- (void)refreshWithFutureInfos:(NSMutableArray *)aFutureInfos
{
    if ([aFutureInfos count] == 0) {
        return;
    }
    self.arrFutureInfos = aFutureInfos;
}

#pragma mark - UI

-(void)updateUI
{
    if (self.isNotFirstTime) {
        [self setSummaryTableViewWithOneDayOrders:self.arrInfos.lastObject atIndex:self.arrInfos.count-1];
        [self setRestSummaryTables];
        
    }else{
        self.scrollViewMain.contentSize = CGSizeMake(self.scrollViewMain.frame.size.width * (self.arrInfos.count+self.arrFutureInfos.count), self.scrollViewMain.frame.size.height);
        self.scrollViewMain.contentOffset = CGPointMake(self.scrollViewMain.frame.size.width * (self.arrInfos.count - 1), 0);
        [self updateScrollControlButtons];
        
        [self addSummaryTableViewWithOneDayOrders:self.arrInfos.lastObject atIndex:self.arrInfos.count-1];
        [self addRestSummaryTables];
        self.isNotFirstTime = YES;
    }
    
    
}

-(void)addRestSummaryTables
{
    for (int i=0; i<[self.arrInfos count]; i++) {
        NSArray *oneDayOrders = [self.arrInfos objectAtIndex:i];
        [self addSummaryTableViewWithOneDayOrders:oneDayOrders atIndex:i];
    }
    for (int i=0; i<[self.arrFutureInfos count]; i++) {
        NSArray *oneDayOrders = [self.arrFutureInfos objectAtIndex:i];
        [self addSummaryTableViewWithOneDayOrdersFuture:oneDayOrders atIndex:([self.arrInfos count]+i)];
    }
}

-(void)setRestSummaryTables
{
    for (int i=0; i<[self.arrInfos count]; i++) {
        NSArray *oneDayOrders = [self.arrInfos objectAtIndex:i];
        [self setSummaryTableViewWithOneDayOrders:oneDayOrders atIndex:i];
    }
    for (int i=0; i<[self.arrFutureInfos count]; i++) {
        NSArray *oneDayOrders = [self.arrFutureInfos objectAtIndex:i];
        [self setSummaryTableViewWithOneDayOrdersFuture:oneDayOrders atIndex:([self.arrInfos count]+i)];
    }
}


-(void)addSummaryTableViewWithOneDayOrders:(NSArray *)oneDayOrders atIndex:(NSUInteger)index
{
    AMSummaryTVC *tvc = [[AMSummaryTVC alloc] initWithNibName:@"AMSummaryTVC" bundle:nil];
    tvc.oneDayOrders = oneDayOrders;
    NSTimeInterval theDateInterval = [AMUtilities daysLater:index after:self.firstDateInterval];
    NSDate *theDate = [AMUtilities dateWithTimeSecond:theDateInterval];
    tvc.date = theDate;
    tvc.isHistoryDate = YES;
    tvc.tag = index;
    tvc.delegate = self;
    CGRect frame = self.scrollViewMain.frame;
    frame.origin.x = index * frame.size.width;
    frame.size.width = frame.size.width - self.btn_right.frame.size.width;
    tvc.tableView.frame = frame;
    [self addChildViewController:tvc];
    [tvc didMoveToParentViewController:self];
    [self.scrollViewMain addSubview:tvc.tableView];
}

-(void)setSummaryTableViewWithOneDayOrders:(NSArray *)oneDayOrders atIndex:(NSUInteger)index
{
    for (AMSummaryTVC *tvc in self.childViewControllers) {
        if (tvc.tag == index) {
            tvc.oneDayOrders = oneDayOrders;
            NSTimeInterval theDateInterval = [AMUtilities daysLater:index after:self.firstDateInterval];
            NSDate *theDate = [AMUtilities dateWithTimeSecond:theDateInterval];
            tvc.date = theDate;
            tvc.isHistoryDate = YES;
        }
    }
}

-(void)addSummaryTableViewWithOneDayOrdersFuture:(NSArray *)oneDayOrders atIndex:(NSUInteger)index
{
    AMSummaryTVC *tvc = [[AMSummaryTVC alloc] initWithNibName:@"AMSummaryTVC" bundle:nil];
    tvc.oneDayOrders = oneDayOrders;
    NSTimeInterval theDateInterval = [AMUtilities daysLater:index after:self.firstDateInterval];
    NSDate *theDate = [AMUtilities dateWithTimeSecond:theDateInterval];
    tvc.date = theDate;
    tvc.isHistoryDate = NO;
    tvc.tag = index;
    tvc.delegate = self;
    CGRect frame = self.scrollViewMain.frame;
    frame.origin.x = index * frame.size.width;
    frame.size.width = frame.size.width - self.btn_right.frame.size.width;
    tvc.tableView.frame = frame;
    [self addChildViewController:tvc];
    [tvc didMoveToParentViewController:self];
    [self.scrollViewMain addSubview:tvc.tableView];
}

-(void)setSummaryTableViewWithOneDayOrdersFuture:(NSArray *)oneDayOrders atIndex:(NSUInteger)index
{
    for (AMSummaryTVC *tvc in self.childViewControllers) {
        if (tvc.tag == index) {
            tvc.oneDayOrders = oneDayOrders;
            NSTimeInterval theDateInterval = [AMUtilities daysLater:index after:self.firstDateInterval];
            NSDate *theDate = [AMUtilities dateWithTimeSecond:theDateInterval];
            tvc.date = theDate;
            tvc.isHistoryDate = NO;
        }
    }
}

-(void)updateScrollControlButtons
{
    self.btn_left.hidden = NO;
    self.btn_right.hidden = NO;
    
    if (self.scrollViewMain.contentOffset.x < self.scrollViewMain.frame.size.width - 1) {
        self.btn_left.hidden = YES;
    }
    
    if (self.scrollViewMain.contentOffset.x > self.scrollViewMain.contentSize.width - self.scrollViewMain.frame.size.width - 1) {
        self.btn_right.hidden = YES;
    }
}

#pragma mark - Actions

- (IBAction)clickLeftBtn:(UIButton *)sender
{
    CGRect toRect = self.scrollViewMain.frame;
    toRect.origin.x = self.scrollViewMain.contentOffset.x - toRect.size.width;
    
    if (toRect.origin.x > -1) {
        [self.scrollViewMain scrollRectToVisible:toRect animated:YES];
    }
}

- (IBAction)clickRightBtn:(UIButton *)sender
{
    CGRect toRect = self.scrollViewMain.frame;
    toRect.origin.x = self.scrollViewMain.contentOffset.x + toRect.size.width;
    
    if (toRect.origin.x < self.scrollViewMain.contentSize.width + 1) {
        [self.scrollViewMain scrollRectToVisible:toRect animated:YES];
    }
}

#pragma mark - Scroll View
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    CGPoint currentOffset = self.scrollViewMain.contentOffset;
    float currentX = currentOffset.x;
    float floatFrame = self.scrollViewMain.frame.size.width;
    int iCurrentNum = currentX / floatFrame;
    float gap = currentX - (floatFrame * iCurrentNum);
    
    if (gap > floatFrame/2) {
        self.scrollViewMain.contentOffset = CGPointMake(floatFrame*(iCurrentNum+1), 0);
    }else{
        self.scrollViewMain.contentOffset = CGPointMake(floatFrame*iCurrentNum, 0);
    }

    [self updateScrollControlButtons];

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateScrollControlButtons];
}

#pragma mark - 

- (void)scrollToLeft:(NSInteger)aPages
{
    NSLog(@"scroll to left");
}

- (void)scrollToRight:(NSInteger)aPages
{
    NSLog(@"scroll to right");
}

#pragma mark - Summary Future Cell Delegate
-(void)didWorkNowClicked:(AMWorkOrder *)workOrder{
    [[AMLogicCore sharedInstance]moveWorkOrderToToday:workOrder completion:^(NSInteger type, NSError *error){
        if (!error) {
            [self updateModelAndUI];
        }else{
            [AMUtilities showAlertWithInfo:[error localizedDescription]];
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.5*NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                [SVProgressHUD dismiss];
//            });
//            [SVProgressHUD showWithStatus:error.description];
            
        }
        
    }];
    
}

@end
