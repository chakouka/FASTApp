//
//  AMReportWOByTypeTodayViewController.m
//  AramarkFSP
//
//  Created by Jonathan.WANG on 7/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMReportWOByTypeTodayViewController.h"
#import "AMReportWOByTypeSingleType.h"
#import "AMConstants.h"

@interface AMReportWOByTypeTodayViewController ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *view_woType;
@property (weak, nonatomic) IBOutlet UILabel *lbl_totalNum;
@property (weak, nonatomic) IBOutlet UILabel *lbl_openNum;
@property (weak, nonatomic) IBOutlet UILabel *lbl_closedNum;

@property (nonatomic,strong) NSMutableArray *arr_WoRecordType;
@property (nonatomic,strong)NSMutableArray *arr_singleWOType;

@end

#define GAP_HORIZONTAL 1.0/20.0
#define GAP_VERTICAL 1.0/40.0
#define TOTAL_NO_OF_WO @"TOTAL # OF WO : "
#define WO_STATUS_CLOSED @"Closed"
#define NUMBER_LABEL_WIDTH 1.0/8.0



@implementation AMReportWOByTypeTodayViewController

-(NSArray *)typesOfWorkOrderRecordType
{
    return @[@"REPAIR",@"INSTALL",@"MOVE",@"REMOVAL",@"SWAP",@"ADMINISTRATIVE",@"FILTER EXCHANGE",@"PREVENTATIVE MAINTENANCE",@"ASSET VERIFICATION"];
}

-(NSArray *)stringOfWorkOrderRecordType
{
    return @[kAMWORK_ORDER_TYPE_REPAIR,
             kAMWORK_ORDER_TYPE_INSTALL,
             kAMWORK_ORDER_TYPE_MOVE,
             kAMWORK_ORDER_TYPE_REMOVAL,
             kAMWORK_ORDER_TYPE_SWAP,
             kAMWORK_ORDER_TYPE_SITESURVEY,
             kAMWORK_ORDER_TYPE_EXCHANGE,
             kAMWORK_ORDER_TYPE_PM,
             kAMWORK_ORDER_TYPE_ASSETVERIFICATION
             ];
}

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
    self.arr_WoRecordType = [[NSMutableArray alloc]initWithArray:[self stringOfWorkOrderRecordType]];
    self.arr_singleWOType = [NSMutableArray array];
    for (NSString *recordType in self.arr_WoRecordType) {
        AMReportWOByTypeSingleType *singleType = [[AMReportWOByTypeSingleType alloc]init];
        singleType.recordType = [recordType uppercaseString];
        singleType.openNumber = 0;
        singleType.closedNumber = 0;
        [self.arr_singleWOType addObject:singleType];
    }
    
    self.lbl_closedNum.text = MyLocal(@"CLOSED");
    self.lbl_openNum.text = MyLocal(@"OPEN");
    self.lbl_totalNum.text = [NSString stringWithFormat:@"%@ : ",MyLocal(@"TOTAL # OF WO")];
}

-(void)initFonts{
    [self.lbl_totalNum setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:13]];
    [self.lbl_openNum setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:13]];
    [self.lbl_closedNum setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:13]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)drawBar{
    int numberOfWO = 0;
    
    if (self.arr_workOrderToday) {
        numberOfWO = (int)[self.arr_workOrderToday count];
    }
    [self.lbl_totalNum setText:[NSString stringWithFormat:@"%@ :  %02d",MyLocal(@"TOTAL # OF WO"),numberOfWO]];
    [self initData];
    [self draw];
}

-(void)initData{
    for (AMReportWOByTypeSingleType *singleRecord in self.arr_singleWOType) {
        singleRecord.openNumber = 0;
        singleRecord.closedNumber = 0;
    }
    
    for (AMWorkOrder *workOrder in self.arr_workOrderToday) {//get a work order
        for (NSInteger i=0; i<[[self stringOfWorkOrderRecordType]count]; i++) {
            if ([workOrder.recordTypeName isEqualToString:[[self stringOfWorkOrderRecordType]objectAtIndex:i]]) {
                AMReportWOByTypeSingleType *record = [self.arr_singleWOType objectAtIndex:i];
                if ([workOrder.status isEqualToLocalizedString:WO_STATUS_CLOSED]) {
                    record.closedNumber ++;
                }else{
                    record.openNumber ++;
                }
                [self.arr_singleWOType replaceObjectAtIndex:i withObject:record];
                break;
            }
        }
    }
}

-(void)draw{
    for (NSInteger i=0; i<[self.arr_singleWOType count]; i++) {
        AMReportWOByTypeSingleType *singleType = [self.arr_singleWOType objectAtIndex:i];
        
        UIView *view = [self.view_woType objectAtIndex:i];
        for (UIView *subView in view.subviews) {
            [subView removeFromSuperview];
        }
        
        //open label
        UILabel *openLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, NUMBER_LABEL_WIDTH*view.frame.size.width, view.frame.size.height)];
        openLabel.center = CGPointMake(openLabel.frame.size.width/2, openLabel.frame.size.height/2);
        [openLabel setTextAlignment:NSTextAlignmentCenter];
        [openLabel setText:[NSString stringWithFormat:@"%02d", ((int)singleType.openNumber)]];
        [openLabel setTextColor:[UIColor redColor]];
        [openLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15]];
        [view addSubview:openLabel];

        //closed label
        UILabel *closedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, NUMBER_LABEL_WIDTH*view.frame.size.width, view.frame.size.height)];
        closedLabel.center = CGPointMake(view.frame.size.width-closedLabel.frame.size.width/2, closedLabel.frame.size.height/2);
        [closedLabel setTextAlignment:NSTextAlignmentCenter];
        [closedLabel setText:[NSString stringWithFormat:@"%02d",((int)singleType.closedNumber)]];
        [closedLabel setTextColor:[UIColor greenColor]];
        [closedLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15]];
        [view addSubview:closedLabel];
        
        //total bar
        UIView *wholeBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, (1-NUMBER_LABEL_WIDTH*2)*view.frame.size.width, view.frame.size.height)];
        wholeBar.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
        if (singleType.openNumber == 0 && singleType.closedNumber == 0) {
            [wholeBar setBackgroundColor:[UIColor grayColor]];
        }else{
            [wholeBar setBackgroundColor:[UIColor greenColor]];
        }
        [view addSubview:wholeBar];
        
        //red bar
        if (singleType.openNumber != 0) {

            UIView *redBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, wholeBar.frame.size.width*singleType.openNumber / (singleType.openNumber + singleType.closedNumber), wholeBar.frame.size.height)];
            redBar.center = CGPointMake(redBar.frame.size.width/2, wholeBar.frame.size.height/2);
            [redBar setBackgroundColor:[UIColor redColor]];
            [wholeBar addSubview:redBar];
        }
        
        //name label
        UILabel *recordTypeLabel = [[UILabel alloc]initWithFrame:[wholeBar frame]];
        recordTypeLabel.center = CGPointMake(recordTypeLabel.frame.size.width/2, recordTypeLabel.frame.size.height/2);
        [recordTypeLabel setTextAlignment:NSTextAlignmentCenter];
        [recordTypeLabel setText:[NSString stringWithFormat:@"%@",[MyLocal(singleType.recordType) uppercaseString]]];
        [recordTypeLabel setTextColor:[UIColor whiteColor]];
        [recordTypeLabel setBackgroundColor:[UIColor clearColor]];
        [recordTypeLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:12]];
        [wholeBar addSubview:recordTypeLabel];
        

    }
    
}

@end
