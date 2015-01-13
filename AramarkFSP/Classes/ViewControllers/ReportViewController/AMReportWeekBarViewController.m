//
//  AMReportWeekBarViewController.m
//  AramarkFSP
//
//  Created by Jonathan.WANG on 7/8/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "AMReportWeekBarViewController.h"
#import "AMReportAxisLabel.h"
#import "AMDBReport.h"
#import "AMBarView.h"
#import "AMReportCompletedWODM.h"

@interface AMReportWeekBarViewController ()

@property (weak, nonatomic) IBOutlet UILabel *avgTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *barBaseLine;
@property (nonatomic) NSInteger numberShown;

@end

#define GAP_LEFT 1.0/20.0
#define GAP_RIGHT 1.0/20.0

#define GAP_VERTICAL 1.0/20.0
#define GAP_COLUMN 1.0/5.0

@implementation AMReportWeekBarViewController



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
    // Do any additional setup after loading the view from its nib.
    [self initFonts];
    
    self.avgTimeLabel.text = MyLocal(@"AVG TIME (HR)");
}

-(void)initFonts{
    [self.avgTimeLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:11]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawBar{
    if (self.arr_mcData.count > 0) {
        self.numberShown = self.arr_mcData.count;
        for (UIView *subView in self.view.subviews) {
            if ([subView isEqual:self.avgTimeLabel] || [subView isEqual:self.barBaseLine]) {
                
            }else{
                [subView removeFromSuperview];
            }
            
        }
        [self draw];
    }
}

- (NSString *)getStringOfWeekDay:(NSInteger)dayOfWeek{
//    NSDate *date = [[NSDate alloc]init];
    
    switch (dayOfWeek) {
        case 0:
            return @"MON";
            break;
        case 1:
            return @"TUE";
            break;
        case 2:
            return @"WED";
            break;
        case 3:
            return @"THU";
            break;
        case 4:
            return @"FRI";
            break;
        default:
            break;
    }
    return @"";
}

- (void)draw{
    CGSize bgSize = self.view.frame.size;
    CGPoint barOriginPoint = CGPointMake(self.view.frame.size.width * GAP_LEFT + self.avgTimeLabel.frame.size.width, self.avgTimeLabel.frame.size.height);
    int maxBarCount = 0;
    for (int i=0; i<self.arr_mcData.count; i++) {
        AMReportCompletedWODM *report = (AMReportCompletedWODM *)self.arr_mcData[i];
        int tmp = [report.mcCompletedCount intValue];
        if (tmp > maxBarCount) {
            maxBarCount = tmp;
        }
    }
    
    //get y unit
    CGFloat yUnit = 0;
    if (maxBarCount > 0) {
        yUnit = (self.barBaseLine.frame.origin.y - barOriginPoint.y)*5/6/maxBarCount;
    }
    CGFloat yNumber =(self.barBaseLine.frame.origin.y - barOriginPoint.y)/8;

    //draw x labels
    NSInteger numOfCols = self.arr_mcData.count;
    
    CGFloat xUnit = (self.barBaseLine.frame.size.width - self.avgTimeLabel.frame.size.width) / (numOfCols*(1+GAP_COLUMN)+GAP_COLUMN);
    CGFloat gapUnit = xUnit*GAP_COLUMN;
    
    for (int i=0;i<self.arr_mcData.count;i++) {
        CGFloat x = barOriginPoint.x + gapUnit + xUnit/2 + (gapUnit+xUnit)*i;
        AMReportAxisLabel *label = [[AMReportAxisLabel alloc]initWithFrame:CGRectMake(0, 0, xUnit, (bgSize.height-self.barBaseLine.frame.origin.y)/2)];
        label.center = CGPointMake(x, self.barBaseLine.frame.origin.y + (bgSize.height-self.barBaseLine.frame.origin.y)/2);
        
        AMReportCompletedWODM *report = (AMReportCompletedWODM *)self.arr_mcData[i];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.timeZone = [[AMProtocolParser sharedInstance]timeZoneOnSalesforce];
        formatter.dateFormat = @"EEE";
//        label.text = [formatter stringFromDate:report.date];
        label.text = MyLocal([formatter stringFromDate:report.date]);
        
        [self.view addSubview:label];
        
        //bar
        
        CGFloat heightRed = [report.mcCompletedCount intValue]*yUnit;
        AMBarView *redBar = [[AMBarView alloc]initWithFrame:CGRectMake(0, 0, xUnit, heightRed)];
        redBar.center = CGPointMake(x, self.barBaseLine.frame.origin.y - heightRed/2);
        [redBar setBackgroundColor:[UIColor colorWithRed:168/255.0 green:68/255.0 blue:75/255.0 alpha:1]];
        [self.view addSubview:redBar];
        
        // number label
        
        UILabel *amountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, xUnit, yNumber)];
        amountLabel.center = CGPointMake(x, self.barBaseLine.frame.origin.y - heightRed - yNumber/2);
        [amountLabel setTextAlignment:NSTextAlignmentCenter];
        [amountLabel setText:[NSString stringWithFormat:@"%02d",[report.mcCompletedCount intValue]]];
        [amountLabel setTextColor:[UIColor blackColor]];
        [amountLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18]];
        [self.view addSubview:amountLabel];
        
        //number avg hour
        UILabel *aveTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, xUnit, self.avgTimeLabel.frame.size.height)];
        aveTimeLabel.center = CGPointMake(x, self.avgTimeLabel.frame.size.height/2);
        int woNumber =[report.mcCompletedCount intValue];
        int timeTotal = [report.mcCompletedMinutes intValue];
        int fAveTime = 0;
        if (woNumber > 0) {
            fAveTime = timeTotal/woNumber;
        }
        [aveTimeLabel setTextAlignment:NSTextAlignmentCenter];
        NSString *timeString = [NSString stringWithFormat:@"%d:%02d",fAveTime/60,fAveTime%60];
        [aveTimeLabel setText:timeString];
        [aveTimeLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:10]];
        [self.view addSubview:aveTimeLabel];
        
        //middle line
        UILabel *blackLine = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 1, amountLabel.frame.origin.y - aveTimeLabel.frame.size.height - aveTimeLabel.frame.origin.y)];
        blackLine.center = CGPointMake(x, aveTimeLabel.frame.origin.y + aveTimeLabel.frame.size.height + (amountLabel.frame.origin.y - aveTimeLabel.frame.size.height - aveTimeLabel.frame.origin.y)/2);
        [blackLine setBackgroundColor:[UIColor grayColor]];
        [self.view addSubview:blackLine];
        
    }
}


@end
