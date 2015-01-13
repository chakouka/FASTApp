//
//  AMReportViewController.m
//  AramarkFSP
//
//  Created by PwC on 4/29/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//
#import <CoreText/CoreText.h>
#import "AMReportViewController.h"
#import "ColumnInfo.h"
#import "ChartViewController.h"
#import "AMBarChartView.h"
#import "TestManage.h"
#import "AMUtilities.h"
#import "SFRestAPI.h"
#import "AMProtocolParser.h"
#import "AMReportWeekBarViewController.h"
#import "AMDBReport.h"
#import "AMReportCompletedWODM.h"
#import "AMReportWOByTypeTodayViewController.h"
#import "AMConstants.h"

#define REPORT_INSET    0.1
#define TOTAL_DAY_OF_WEEK 7
#define WORK_DAY_OF_WEEK 5
#define MC_TOTAL_DAY_SHOW 10
#define WORKORDER_STATUS_CLOSED @"Closed"

@interface AMReportViewController ()
{
    ChartViewController *chartVC;
    AMPopoverSelectTableViewController *popView;
    UIPopoverController *bPopoverVC;
}
// model
@property (nonatomic,strong) NSArray *arrayMcWO;
@property (nonatomic,strong) NSArray *arrayMyWOPastDays;

@property (nonatomic,strong) NSMutableArray *arr_MyWOToday;
@property (nonatomic,strong) NSMutableArray *arr_MyCompletedWOThisWeek;
@property (nonatomic,strong) NSMutableArray *arr_mcData;
@property (nonatomic,strong) NSMutableArray *arr_McWOThisWeek;

@property(nonatomic,strong) NSDate *today;
@property (nonatomic,strong) NSDate *firstDate;
@property (nonatomic) NSTimeInterval firstDateInterval;
@property (nonatomic,strong) NSCalendar *calendar;

#pragma mark - property for record type


@property (weak, nonatomic) IBOutlet UILabel *lbl_woRecordTypeTxt;
@property (weak, nonatomic) IBOutlet UIButton *lbl_woRecordType;
@property (nonatomic) NSInteger currentWorkOrderRecordType;
@property (nonatomic,strong) NSMutableArray *arr_WoRecordType;

#pragma mark - property for Day Pie
@property (weak, nonatomic) IBOutlet UILabel *lbl_pieTitle1;
@property (weak, nonatomic) IBOutlet AMPieChart *view_pie1;
@property (weak, nonatomic) IBOutlet UIView *PieChartMiddleView1;
@property (weak, nonatomic) IBOutlet UILabel *workCompletePie1;
@property (weak, nonatomic) IBOutlet UILabel *workTotalPie1;
@property (weak, nonatomic) IBOutlet UILabel *aveHourPie1;
@property (weak, nonatomic) IBOutlet UILabel *lbl_avgCompletionTxt;
@property (nonatomic,strong) NSMutableArray *pieSlices1;
@property (nonatomic,strong) NSArray *pieSliceColors1;
@property (weak, nonatomic) IBOutlet UILabel *lbl_CompletePerForPie1;


#pragma mark - property for Week Pie
@property (weak, nonatomic) IBOutlet UILabel *lbl_pieTitle2;
@property (weak, nonatomic) IBOutlet UIView *view_pie2;
@property (weak, nonatomic) IBOutlet AMPieChart *weekPieChart;
@property (weak, nonatomic) IBOutlet UILabel *weekShowLabel;
@property (nonatomic,strong)NSMutableArray *pieSlices2;
@property (nonatomic,strong)NSArray *pieSliceColors2;

#pragma mark - property for M.C Complete
@property (weak, nonatomic) IBOutlet UILabel *lbl_pieTitle3;
@property (weak, nonatomic) IBOutlet UIView *view_pie3;
@property(nonatomic,strong)NSMutableArray *arr_mcOrderThisWeek;
@property (nonatomic, strong) AMReportWeekBarViewController *weekBarChart3;

#pragma mark - property for Mark Center VS Mine
@property (weak, nonatomic) IBOutlet UILabel *lbl_barTitle;
@property (weak, nonatomic) IBOutlet UIView *view_bar;
@property (nonatomic, strong) AMBarChartView *barChart4;

#pragma mark - property for WORK ORDER by Type today
@property (weak, nonatomic) IBOutlet UILabel *lbl_workOrderByTypeToday;
@property (weak, nonatomic) IBOutlet UIView *view_workOrderByTypeToday;
@property (nonatomic,strong) AMReportWOByTypeTodayViewController *woByTypeBarChart;



@end

@implementation AMReportViewController

-(NSArray *)datesOfWeekInFullName{
    return @[@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday"];
}

-(NSArray *)typesOfWorkOrderRecordType
{
    return @[@"All",
             kAMWORK_ORDER_TYPE_ASSETVERIFICATION,
             kAMWORK_ORDER_TYPE_EXCHANGE,
             kAMWORK_ORDER_TYPE_INSTALL,
             kAMWORK_ORDER_TYPE_MOVE,
             kAMWORK_ORDER_TYPE_PM,
             kAMWORK_ORDER_TYPE_REMOVAL,
             kAMWORK_ORDER_TYPE_REPAIR,
             kAMWORK_ORDER_TYPE_SITESURVEY,
             kAMWORK_ORDER_TYPE_SWAP
             ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Report Screen";
    
    [self.lbl_woRecordType setTitle:MyLocal(@"All") forState:UIControlStateNormal];
    
    self.currentWorkOrderRecordType = 0;
    self.arr_WoRecordType = [[NSMutableArray alloc]initWithArray:[self typesOfWorkOrderRecordType]];
    self.today = [NSDate date];
    self.calendar  = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    [self.calendar setTimeZone:[[AMProtocolParser sharedInstance] timeZoneOnSalesforce]];
    [self initTitles];
    [self initFonts];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(update)
                                                 name:NOTIFICATION_SHOW_REPORTS object:nil];
    self.lbl_woRecordType.layer.borderColor = [UIColor whiteColor].CGColor;
    self.lbl_woRecordType.layer.borderWidth = 1.0;
}

-(void)initFonts{
    [self.lbl_woRecordTypeTxt setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18]];
    [self.lbl_woRecordType.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18]];
    
    [self.workCompletePie1 setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:33]];
    [self.workTotalPie1 setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:33]];
    [self.aveHourPie1 setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:22]];
    [self.lbl_avgCompletionTxt setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:11]];
    
    [self.weekShowLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15]];
    [self.lbl_CompletePerForPie1 setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15]];
    
    self.lbl_woRecordTypeTxt.text = [[NSString stringWithFormat:@"%@ :",MyLocal(@"SELECT WORK ORDER TYPE")] uppercaseString];
    self.lbl_avgCompletionTxt.text = [MyLocal(@"AVG COMPLETION") uppercaseString];
}

-(void)initTitles{
    NSDictionary *attrDic = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    
    NSString *title1String = [MyLocal(@"WO COMPLETED & AVG TIME TODAY") uppercaseString];
    NSRange attr1Range = [title1String rangeOfString:[MyLocal(@"TODAY") uppercaseString]];
    self.lbl_pieTitle1.attributedText = [AMUtilities getAttributedStringFromString:title1String withAttributeDictionary:attrDic forRange:attr1Range];
    
    NSString *title2String = [MyLocal(@"R & R THIS WEEK") uppercaseString];
    NSRange attr2Range = [title2String rangeOfString:[MyLocal(@"THIS WEEK") uppercaseString]];
    self.lbl_pieTitle2.attributedText = [AMUtilities getAttributedStringFromString:title2String withAttributeDictionary:attrDic forRange:attr2Range];
    
    NSString *title3String = [MyLocal(@"MC COMPLETED WO THIS WEEK") uppercaseString];
    NSRange attr3Range = [title3String rangeOfString:[MyLocal(@"THIS WEEK") uppercaseString]];
    self.lbl_pieTitle3.attributedText = [AMUtilities getAttributedStringFromString:title3String withAttributeDictionary:attrDic forRange:attr3Range];
    
    NSString *barTitle = [MyLocal(@"MARKET CENTER WO VS. MY COMPLETED WO") uppercaseString];
    NSRange barRange = [barTitle rangeOfString:[MyLocal(@"VS.") uppercaseString]];
    self.lbl_barTitle.attributedText = [AMUtilities getAttributedStringFromString:barTitle withAttributeDictionary:attrDic forRange:barRange];
    
    NSString *woByTypeTodayString = [MyLocal(@"WORK ORDER BY TYPE FOR TODAY") uppercaseString];
    NSRange attrByTypeRange = [woByTypeTodayString rangeOfString:[MyLocal(@"BY TYPE") uppercaseString]];
    self.lbl_workOrderByTypeToday.attributedText = [AMUtilities getAttributedStringFromString:woByTypeTodayString withAttributeDictionary:attrDic forRange:attrByTypeRange];
    
}

-(void)update
{
    self.view.alpha = 0;
    
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


#pragma mark - Properties

-(AMBarChartView *)barChart
{
    if (!_barChart4) {
        _barChart4= [[AMBarChartView alloc] initWithFrame: self.view_bar.bounds];
        [self.view_bar addSubview:_barChart4];
        
    }
    return _barChart4;
}

-(AMReportWeekBarViewController *)weekBarChart3
{
    if (!_weekBarChart3) {
        _weekBarChart3 = [[AMReportWeekBarViewController alloc]init];
        [self.view_pie3 addSubview:_weekBarChart3.view];
    }
    return _weekBarChart3;
}

-(AMReportWOByTypeTodayViewController *)woByTypeBarChart
{
    if (!_woByTypeBarChart) {
        _woByTypeBarChart = [[AMReportWOByTypeTodayViewController alloc]init];
        [self.view_workOrderByTypeToday addSubview:_woByTypeBarChart.view];
    }
    return _woByTypeBarChart;
}

#pragma mark - Popover view

- (IBAction)woRecordTypeDropdownTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (!bPopoverVC) {
        popView = [[AMPopoverSelectTableViewController alloc]initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
        popView.delegate = self;
        bPopoverVC = [[UIPopoverController alloc]initWithContentViewController:popView];
        [bPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), 200.0)];
    }
    popView.arrInfos = [self buildUpPopoverDataSource];
    [bPopoverVC presentPopoverFromRect:button.frame inView:button.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    
    
    self.lbl_woRecordType.enabled = NO;
    [self performSelector:@selector(enableWoRecordTypeBtn) withObject:nil afterDelay:1];
    
}

-(void) enableWoRecordTypeBtn{
    self.lbl_woRecordType.enabled = YES;
}


- (NSMutableArray *)buildUpPopoverDataSource{
    NSMutableArray *mArray = [NSMutableArray array];
    for (NSString *type in self.arr_WoRecordType) {
        NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
        [mDic setObject:MyLocal(type) forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
        [mDic setObject:type forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
        [mArray addObject:mDic];
    }
    return mArray;
}

-(void)didSelectedIndex:(NSInteger)aIndex contentArray:(NSArray *)aArray{
    if (bPopoverVC) {
        [bPopoverVC dismissPopoverAnimated:YES];
    }
    NSString *recordTypeString = [[aArray objectAtIndex:aIndex]objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
    self.currentWorkOrderRecordType = aIndex;
    [self.lbl_woRecordType setTitle:MyLocal(recordTypeString) forState:UIControlStateNormal];
    [self changeWoRecordType];
}


#pragma mark - Model


-(void)updateModel
{
    self.today = [NSDate date];
    NSTimeInterval interval = [AMUtilities timeBySecondWithDate:[NSDate date]];
    self.firstDateInterval = [AMUtilities daysBefore:MC_TOTAL_DAY_SHOW-1 from:interval];
    self.firstDate = [AMUtilities dateWithTimeSecond:self.firstDateInterval];
    
    self.arrayMcWO = [[AMLogicCore sharedInstance] getReportDataRaw];//mc wo and my wo and time
    self.arrayMyWOPastDays = [[AMLogicCore sharedInstance]getArrangedSelfWorkOrderInPastDays:TOTAL_DAY_OF_WEEK];
    
    [self parseModels];
}

-(void)changeWoRecordType{
    [self parseModels];
    [self updateUI];
}

-(void)parseModels
{
    [self parseMyWOToday:self.arrayMyWOPastDays];//pie 1
    [self parseMyCompletedWOThisWeek:self.arrayMyWOPastDays];//pie 2
    [self parseMcWorkOrders:self.arrayMcWO];//bar 4
    [self parseMcWorkOrdersThisWeek:self.arrayMcWO];// bar3
}

#pragma mark - Data for Pie1
-(void)parseMyWOToday:(NSArray *)array{
    self.arr_MyWOToday = [NSMutableArray array];
    if (array != nil && [array count] > 0) {
        [self.arr_MyWOToday addObject:[array lastObject]];
    }
}

#pragma mark - Data for Pie2
-(void)parseMyCompletedWOThisWeek:(NSArray *)array{
    self.arr_MyCompletedWOThisWeek = [NSMutableArray array];
    if (array != nil && [array count] > 0) {
        int numDayOfWeek = [self.today weekdayWithCalendar:self.calendar];
        if (numDayOfWeek == 1) {
            numDayOfWeek = 8;
        }
        for (int i=TOTAL_DAY_OF_WEEK-numDayOfWeek+1; i<TOTAL_DAY_OF_WEEK; i++) {
            [self.arr_MyCompletedWOThisWeek addObject:array[i]];
        }
    }
}

-(void)parseMcWorkOrdersThisWeek:(NSArray *)array{
    NSString *currentRecordType = [self.arr_WoRecordType objectAtIndex:self.currentWorkOrderRecordType];
    self.arr_McWOThisWeek = [[NSMutableArray alloc]initWithCapacity:WORK_DAY_OF_WEEK];
    int numDayOfWeek = [self.today weekdayWithCalendar:self.calendar];
    if (numDayOfWeek == 1) {
        numDayOfWeek = 8;
    }
    
    NSTimeInterval interval = [AMUtilities timeBySecondWithDate:[NSDate date]];
    NSTimeInterval firstDateOfWeekShowInterval = [AMUtilities daysBefore:numDayOfWeek-2 from:interval];
    
    for (int i=0; i<WORK_DAY_OF_WEEK; i++) {
        NSTimeInterval theDateInterval = [AMUtilities daysLater:i after:firstDateOfWeekShowInterval];
        NSDate *theDate = [AMUtilities dateWithTimeSecond:theDateInterval];
        AMReportCompletedWODM *mcReport = [[AMReportCompletedWODM alloc]init];
        [mcReport setDate:theDate];
        [mcReport setMcCompletedCount:[NSNumber numberWithInt:0]];
        [mcReport setMcCompletedMinutes:[NSNumber numberWithInt:0]];
        [mcReport setMyCompletedCount:[NSNumber numberWithInt:0]];
        [mcReport setMyCompletedMinutes:[NSNumber numberWithInt:0]];
        [mcReport setRecordType:@""];
        for (AMDBReport *report in array) {
            if (([self CheckSameDay:report.date AnotherDate:theDate]) && ([currentRecordType isEqualToLocalizedString:report.recordType])) {
                if (report.mcCompletedCount) {
                    mcReport.mcCompletedCount = report.mcCompletedCount;
                }
                if (report.mcCompletedMinutes) {
                    mcReport.mcCompletedMinutes = report.mcCompletedMinutes;
                }
                if (report.myCompletedCount) {
                    mcReport.myCompletedCount = report.myCompletedCount;
                }
                if (report.myCompletedMinutes) {
                    mcReport.myCompletedMinutes = report.myCompletedMinutes;
                }
                if (report.recordType) {
                    mcReport.recordType = report.recordType;
                }
            }
        }
        NSLog(@"%@",mcReport);
        [self.arr_McWOThisWeek addObject:mcReport];
    }
}

-(void)parseMcWorkOrders:(NSArray *)array{
    self.arr_mcData = [[NSMutableArray alloc]initWithCapacity:MC_TOTAL_DAY_SHOW];
    for (int i=0; i<MC_TOTAL_DAY_SHOW; i++) {
        NSTimeInterval theDateInterval = [AMUtilities daysLater:i after:self.firstDateInterval];
        NSDate *theDate = [AMUtilities dateWithTimeSecond:theDateInterval];
        AMReportCompletedWODM *mcReport = [[AMReportCompletedWODM alloc]init];
        [mcReport setDate:theDate];
        [mcReport setMcCompletedCount:[NSNumber numberWithInt:0]];
        [mcReport setMcCompletedMinutes:[NSNumber numberWithInt:0]];
        [mcReport setMyCompletedCount:[NSNumber numberWithInt:0]];
        [mcReport setMyCompletedMinutes:[NSNumber numberWithInt:0]];
        [mcReport setRecordType:@""];
        for (AMDBReport *report in array) {
            DLog(@"report date = %@, mcCount = %@, myCount = %@, recordType = %@",report.date,report.mcCompletedCount,report.myCompletedCount,report.recordType);
            if (([self CheckSameDay:report.date AnotherDate:theDate]) && ([report.recordType isEqualToLocalizedString:[[self typesOfWorkOrderRecordType] objectAtIndex:0]])) {
                if (report.mcCompletedCount) {
                    mcReport.mcCompletedCount = report.mcCompletedCount;
                }
                if (report.mcCompletedMinutes) {
                    mcReport.mcCompletedMinutes = report.mcCompletedMinutes;
                }
                if (report.myCompletedCount) {
                    mcReport.myCompletedCount = report.myCompletedCount;
                }
                if (report.myCompletedMinutes) {
                    mcReport.myCompletedMinutes = report.myCompletedMinutes;
                }
                if (report.recordType) {
                    mcReport.recordType = report.recordType;
                }
            }
        }
        [self.arr_mcData addObject:mcReport];
    }
}



-(BOOL) CheckSameDay:(NSDate*)_date1 AnotherDate:(NSDate*)_date2
{
    unsigned unitFlats = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *comp1 = [self.calendar components:unitFlats fromDate:_date1];
    NSDateComponents *comp2 = [self.calendar components:unitFlats fromDate:_date2];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year] == [comp2 year];
}

-(NSString *)getDayOfWeek:(NSDate *)date{
    NSDateFormatter *dayOfWeek = [[NSDateFormatter alloc]init];
    [dayOfWeek setDateFormat:@"EEEE"];
    NSString *strDayOfWeek = [dayOfWeek stringFromDate:date];
    return strDayOfWeek;
    
}

-(NSDate *)getFirstDateOfWeek:(NSDate *)originDate{
    NSDate *date = nil;
    
    NSString *strDayOfWeek = [self getDayOfWeek:originDate];
    
    for (NSInteger i=0; i<[[self datesOfWeekInFullName]count]; i++) {
        if ([strDayOfWeek isEqualToLocalizedString:[[self datesOfWeekInFullName]objectAtIndex:i]]) {
            date = [NSDate dateWithTimeInterval:-24*60*60*i sinceDate:originDate];
            break;
        }
    }
    return date;
}

-(NSInteger) getWorkOrderRecordTypeIndex:(NSString *)recordType{
    NSInteger recordTypeIndex = 0;
    for (NSInteger i=0; i<[[self typesOfWorkOrderRecordType]count]; i++) {
        if ([recordType isEqualToLocalizedString:[[self typesOfWorkOrderRecordType]objectAtIndex:i]]) {
            recordTypeIndex = i;
        }
    }
    return recordTypeIndex;
}

#pragma mark - UI
-(void)updateUI
{
    if (self.arr_MyWOToday != nil) {
        [self performSelector:@selector(updatePieChart1) withObject:nil afterDelay:0.1];
        [self performSelector:@selector(updateWOByTypeToday) withObject:nil afterDelay:0.1];
    }
    if (self.arr_MyCompletedWOThisWeek != nil) {
        [self performSelector:@selector(updatePieChart2) withObject:nil afterDelay:0.1];
    }
    if (self.arr_McWOThisWeek) {
        [self performSelector:@selector(updateWeekBarChart3) withObject:nil afterDelay:0.1];
    }
    if (self.arr_mcData) {
        [self performSelector:@selector(updateBarChart4) withObject:nil afterDelay:0.1];
    }
    
}

#pragma mark - Code for Pie Chart1

- (void)updatePieChart1{
    int totalOrder = 0;
    int completeOrder = 0;
    NSInteger totalMinute = 0;
    NSInteger aveHourInt = 0;
    NSInteger aveMinInt = 0;
    
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSMinuteCalendarUnit;
    NSString *currentRecordType = [self.arr_WoRecordType objectAtIndex:self.currentWorkOrderRecordType];
    
    if (self.arr_MyWOToday != nil) {
        
        NSArray *oneDayArr = [self.arr_MyWOToday lastObject];
        NSInteger totalArray = [oneDayArr count];
        if (totalArray > 0 && [[oneDayArr lastObject]isKindOfClass:[AMWorkOrder class]]) {
            for (AMWorkOrder *workOrder in oneDayArr) {
                if ((self.currentWorkOrderRecordType == 0) || ([workOrder.woType isEqualToLocalizedString:currentRecordType])) {
                    totalOrder ++;
                    if ([workOrder.status isEqualToLocalizedString:WORKORDER_STATUS_CLOSED]) {
                        completeOrder ++;

                        NSDateComponents *components = [calendar components:unitFlags fromDate:workOrder.actualTimeStart toDate:workOrder.actualTimeEnd options:0];
                        NSInteger minDiff = [components minute];
                        totalMinute = totalMinute + minDiff;
                    }
                }
                
            }
        }
    }

    self.pieSlices1 = [NSMutableArray arrayWithCapacity:2];

    [self.pieSlices1 addObject:[NSNumber numberWithInt:completeOrder]];
    [self.pieSlices1 addObject:[NSNumber numberWithInt:(totalOrder - completeOrder)]];
    [self.view_pie1 setDataSource:self];
    [self.view_pie1 setStartPieAngle:M_PI_2*3];
    [self.view_pie1 setAnimationSpeed:1];
    [self.view_pie1 setLabelRadius:160];
    [self.view_pie1 setLabelFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:12]];
    [self.view_pie1 setShowLabel:NO];
    [self.view_pie1 setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];

    [self.view_pie1 setUserInteractionEnabled:NO];
    
    [self.PieChartMiddleView1.layer setCornerRadius:75];
    [self.workCompletePie1 setText:[NSString stringWithFormat:@"%d",completeOrder]];
    [self.workTotalPie1 setText:[NSString stringWithFormat:@"/%d",totalOrder]];
    if (totalMinute != 0) {
        NSInteger aveTime = totalMinute/completeOrder;
        aveHourInt = aveTime/60;
        aveMinInt = aveTime%60;
    }
    NSString *hourString = [NSString stringWithFormat:@"%02d:%02d HR",aveHourInt,aveMinInt];
    NSMutableAttributedString *hourAttrString = [[NSMutableAttributedString alloc]initWithString:hourString];
    
    NSRange hourRange = [hourString rangeOfString:@"HR"];
    [self attributeUpperScriptionForAttributedString:hourAttrString atRange:hourRange];
    
    self.aveHourPie1.attributedText = hourAttrString;
    CGFloat completeWoPercentage = 0.0f;
    if (totalOrder != 0) {
        completeWoPercentage = completeOrder*100/totalOrder;
    }
    [self.lbl_CompletePerForPie1 setText:[NSString stringWithFormat:@"%@: %.00f %%",[MyLocal(@"Completed WO") uppercaseString],completeWoPercentage]];
    
    self.pieSliceColors1 = [NSArray arrayWithObjects:
                           [UIColor greenColor],
                           [UIColor redColor
                            ],
                           nil];
    [self.view_pie1 reloadData];
}

- (void)attributeUpperScriptionForAttributedString:(NSMutableAttributedString *)originalString
                                           atRange:(NSRange) range
{
    long upsideNumber = 2;
    CFNumberRef upsideNum = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &upsideNumber);
    [originalString addAttribute:(id)kCTSuperscriptAttributeName value:(__bridge id)upsideNum range:range];
    [originalString addAttribute:NSFontAttributeName value:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:8] range:range];
}


#pragma mark - AMPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(AMPieChart *)pieChart
{
    if ([pieChart isEqual:self.view_pie1]) {
        return self.pieSlices1.count;
    }else{
        return self.pieSlices2.count;
    }
    
}

- (CGFloat)pieChart:(AMPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    if ([pieChart isEqual:self.view_pie1]) {
        return [[self.pieSlices1 objectAtIndex:index] intValue];
    }else{
        return [[self.pieSlices2 objectAtIndex:index]intValue];
    }
    
}

- (UIColor *)pieChart:(AMPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    if ([pieChart isEqual:self.view_pie1]) {
        return [self.pieSliceColors1 objectAtIndex:(index % self.pieSliceColors1.count)];
    }else{
        return [self.pieSliceColors2 objectAtIndex:(index % self.pieSliceColors2.count)];
    }
    
}

#pragma mark - AMPieChart Delegate
- (void)pieChart:(AMPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    if ([pieChart isEqual:self.weekPieChart]) {
        [self showWeeklyPieClickedWithSelection:index];
    }
    
}

- (void)showWeeklyPieClickedWithSelection:(NSInteger) index{
    NSString *woForHours = @"";
    if (index == 0) {
        woForHours = [woForHours stringByAppendingString:[NSString stringWithFormat:@"%@: ",MyLocal(@"8 HRS")]];
    }else if (index == 1){
        woForHours = [woForHours stringByAppendingString:[NSString stringWithFormat:@"%@: ",MyLocal(@"24 HRS")]];
    }else{
        woForHours = [woForHours stringByAppendingString:[NSString stringWithFormat:@"%@: ",MyLocal(@"GREATER 24 HRS")]];
    }
    woForHours = [woForHours stringByAppendingString:[NSString stringWithFormat:@"%@ %@",[self.pieSlices2 objectAtIndex:index],MyLocal(@"WO")]];
    [self.weekShowLabel setText:woForHours];
}

#pragma mark - Code for PieChart 2 This Week

- (void)updatePieChart2{
    self.pieSlices2 = [NSMutableArray arrayWithCapacity:3];
    
    int orderLessThan8Hours = 0;
    int orderBetween8And24Hours = 0;
    int orderMoreThan24Hours = 0;

    int tmp = 0;
    int comptmp = 0;
    NSString *currentRecordType = [self.arr_WoRecordType objectAtIndex:self.currentWorkOrderRecordType];
    
    NSInteger minuteFlags = NSMinuteCalendarUnit;
    if (self.arr_MyCompletedWOThisWeek != nil && [self.arr_MyCompletedWOThisWeek count] > 0) {
        for (NSArray *oneDayArray in self.arr_MyCompletedWOThisWeek) {
            if (oneDayArray != nil && [oneDayArray count] > 0 && [[oneDayArray lastObject]isKindOfClass:[AMWorkOrder class]]) {
                for (AMWorkOrder *workOrder in oneDayArray) {
                    if ((self.currentWorkOrderRecordType == 0) || ([workOrder.woType isEqualToLocalizedString:currentRecordType])) {
                        tmp++;
                        if ([workOrder.status isEqualToLocalizedString:WORKORDER_STATUS_CLOSED]) {
                            comptmp++;
                            NSDateComponents *minComponents = [self.calendar components:minuteFlags fromDate:workOrder.createdDate toDate:workOrder.actualTimeEnd options:0];
                            NSInteger minDiff = [minComponents minute];
                            if (minDiff <= 60*8) {
                                orderLessThan8Hours ++;
                            }else if (minDiff > 60*8 && minDiff < 60*24){
                                orderBetween8And24Hours ++;
                            }else if (minDiff >= 60*24){
                                orderMoreThan24Hours ++;
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    [self.pieSlices2 addObject:[NSNumber numberWithInt:orderLessThan8Hours]];
    [self.pieSlices2 addObject:[NSNumber numberWithInt:orderBetween8And24Hours]];
    [self.pieSlices2 addObject:[NSNumber numberWithInt:orderMoreThan24Hours]];
    
    [self.weekPieChart setDataSource:self];
    [self.weekPieChart setDelegate:self];
    [self.weekPieChart setStartPieAngle:M_PI_2*3];
    [self.weekPieChart setAnimationSpeed:1];
    [self.weekPieChart setShowPercentage:NO];
    [self.weekPieChart setLabelFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18]];
    [self.weekPieChart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.weekPieChart setTintColor:[UIColor blackColor]];

    [self.weekPieChart setUserInteractionEnabled:YES];
    
    self.pieSliceColors2 = [NSArray arrayWithObjects:
                            [UIColor greenColor],
                            [UIColor yellowColor],
                            [UIColor redColor],
                            nil];
    
    NSString *labelString = @"";
    if (orderLessThan8Hours != 0) {
        labelString = [labelString stringByAppendingString:[NSString stringWithFormat:@"%@: %d %@",MyLocal(@"8 HRS"),orderLessThan8Hours,MyLocal(@"WO")]];
    }else if (orderBetween8And24Hours != 0){
        labelString = [labelString stringByAppendingString:[NSString stringWithFormat:@"%@: %d %@",MyLocal(@"24 HRS"),orderBetween8And24Hours,MyLocal(@"WO")]];
    }else if (orderMoreThan24Hours != 0){
        labelString = [labelString stringByAppendingString:[NSString stringWithFormat:@"%@: %d %@",MyLocal(@"GREATER 24 HRS"),orderMoreThan24Hours,MyLocal(@"WO")]];
    }else{
        labelString = [labelString stringByAppendingString:MyLocal(@"No work orders this week")];
    }
    [self.weekShowLabel setText:labelString];
    
    [self.weekPieChart reloadData];
    
}

#pragma mark - Code for Bar Chart3
- (void)updateWeekBarChart3{
    AMReportWeekBarViewController *weekBarChart3 = self.weekBarChart3;
    weekBarChart3.arr_mcData = self.arr_McWOThisWeek;
    [self.weekBarChart3 drawBar];
    
    
}


#pragma mark - Code for Bar Chart4

- (void)updateBarChart4{
    AMBarChartView *barChart = self.barChart;
    
    // setup x label text and value
    NSMutableArray *xData = [NSMutableArray array];
    NSMutableArray *valueData = [NSMutableArray array];
    NSMutableArray *valueMCData = [NSMutableArray array];
    
    for (AMReportCompletedWODM *report in self.arr_mcData) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"MMM dd";
        formatter.timeZone = [[AMProtocolParser sharedInstance]timeZoneOnSalesforce];
        NSString *dateString = [formatter stringFromDate:report.date];
        [xData addObject:dateString];
        [valueData addObject:report.myCompletedCount];
        [valueMCData addObject:report.mcCompletedCount];
    }
    
    barChart.arr_text_x = xData;
    barChart.arr_value = valueData;
    barChart.arr_mc_value = valueMCData;
    
    // setup y label text
    NSNumber *maxCount = [barChart.arr_mc_value valueForKeyPath:@"@max.self"];
    NSInteger yMax = (NSInteger)ceil((maxCount.integerValue)/10.0) * 10;
    if (yMax <10) {
        yMax = 10;
    }
    NSMutableArray *yData = [NSMutableArray array];
    for (int i = 0; i<=10; i++) {
        [yData addObject:[NSString stringWithFormat:@"%d", yMax/10 * i]];
    }
    barChart.arr_text_y = yData;
    
    [self.barChart blackraw];
}


#pragma mark - Code for today By Type Chart
-(void)updateWOByTypeToday{
    AMReportWOByTypeTodayViewController *woByTypeBarChart = self.woByTypeBarChart;
    woByTypeBarChart.arr_workOrderToday = [self.arr_MyWOToday lastObject];
    [self.woByTypeBarChart drawBar];
}


@end









