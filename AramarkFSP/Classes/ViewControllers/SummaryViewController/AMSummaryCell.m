//
//  AMSummaryCell.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/3/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMSummaryCell.h"
#import <CoreText/CoreText.h>
#import "AMProtocolParser.h"

@interface AMSummaryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView_Number;
@property (weak, nonatomic) IBOutlet UIImageView *imgView_MultiEvent;
@property (nonatomic,strong) UIImage *imgBackground;

@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_woName;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_startTime;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_completeTime;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_respondedIn;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_invoiceNo;


@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_address;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_contactName;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_dateOpen;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_dateClosed;


@end


@implementation AMSummaryCell


-(NSArray *)workOrderPriority{
    return @[@"Critical",@"High",@"Medium",@"Low"];
}

-(NSArray *)workOrderPriorityColor{
    return @[
             @"alert-background.png",
             @"orange_priority.png",
             @"blue_priority.png",
             @"green_priority.png"
             ];
}

#define DEFAULT_WORK_ORDER_PRIORITY_COLOR 2

- (void)awakeFromNib
{
    self.labelTCheckInTime.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Check in Time")];
    self.labelTCheckOutTime.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Check out Time")];
    self.labelTCaseNo.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Case No")];
    self.labelTContact.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Contact")];
    self.labelTWoCreatedDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"WO Created Date")];
    self.labelTRespondAndRecove.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Respond and Recover")];
    
    [self.btnNewCase setTitle:MyLocal(@"New Case") forState:UIControlStateHighlighted];
    [self.btnNewCase setTitle:MyLocal(@"New Case") forState:UIControlStateNormal];
    
    self.btnNewCase.titleLabel.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger];
}

-(void)setOrder:(AMWorkOrder *)order
{
    _order = order;

    if (order) {
        if ([order.eventList count]>1) {
            [self.imgView_MultiEvent setHidden:NO];
        }else{
            [self.imgView_MultiEvent setHidden:YES];
        }
    }
    self.lbl_woName.attributedText = [self generateWoNameWithOrder:order];
    [self generateDescriptionsWithWorkOrder:order];
    [self generateLocationAndContact:order];
    [self generateWoCreateDateAndRespond:order];
    [self makeRoundLableVisiableOrNot:order];
    
}

-(NSAttributedString *)generateWoNameWithOrder:(AMWorkOrder *)order
{
    NSString *woTitleString = @"";
    NSString *woNumber = order.woNumber;
    NSString *woMEI = @" ";
    NSString *woName = [@" " stringByAppendingString:order.accountName];
    NSString *woType = [NSString stringWithFormat:@"  [%@]",MyLocal(order.woType)];
    
    woTitleString = [woTitleString stringByAppendingString:woNumber];
    woTitleString = [woTitleString stringByAppendingString:woMEI];
    woTitleString = [woTitleString stringByAppendingString:woName];
    woTitleString = [woTitleString stringByAppendingString:woType];
    
    NSDictionary *attrDic = [NSDictionary dictionaryWithObject:[UIColor lightGrayColor] forKey:NSForegroundColorAttributeName];
    NSRange attrRange = [woTitleString rangeOfString:woType];
    
    return [AMUtilities getAttributedStringFromString:woTitleString withAttributeDictionary:attrDic forRange:attrRange];
}

- (void)generateDescriptionsWithWorkOrder:(AMWorkOrder *)order
{
    NSDateFormatter *formatterTime = [NSDateFormatter new];
    formatterTime.dateFormat = @"HH:mm";
    formatterTime.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
    
    NSString *startTime = @"";
    if (order.actualTimeStart) {
        startTime = [startTime stringByAppendingString:[formatterTime stringFromDate:order.actualTimeStart]];
    }
    NSMutableAttributedString *startTimeAttr = [[NSMutableAttributedString alloc]initWithString:startTime];
    NSRange startAMRange = [startTime rangeOfString:@"AM"];
    NSRange startPMRange = [startTime rangeOfString:@"PM"];
    [self attributeUpperScriptionForAttributedString:startTimeAttr atRange:startAMRange];
    [self attributeUpperScriptionForAttributedString:startTimeAttr atRange:startPMRange];
    self.lbl_startTime.attributedText = startTimeAttr;
    
    NSString *completeTime = @"";
    if (order.actualTimeEnd) {
        completeTime = [completeTime stringByAppendingString:[formatterTime stringFromDate:order.actualTimeEnd]];
    }
    NSMutableAttributedString *completeTimeAttr = [[NSMutableAttributedString alloc]initWithString:completeTime];
    NSRange completeAMRange = [completeTime rangeOfString:@"AM"];
    NSRange completePMRange = [completeTime rangeOfString:@"PM"];
    [self attributeUpperScriptionForAttributedString:completeTimeAttr atRange:completeAMRange];
    [self attributeUpperScriptionForAttributedString:completeTimeAttr atRange:completePMRange];
    self.lbl_completeTime.attributedText = completeTimeAttr;
    
    NSString *responseDuration = @"";
    if (order.actualTimeStart && order.createdDate) {
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned int unitHourMinFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents *components = [calendar components:unitHourMinFlags
                                                   fromDate:order.createdDate
                                                     toDate:order.actualTimeEnd
                                                    options:0];
        NSInteger hourDiff = [components hour];
        NSInteger minDiff = [components minute];
        NSString *unit = MyLocal(@"hours");
        if ((hourDiff < 1) || (hourDiff == 1 && minDiff == 0)) {
            unit = MyLocal(@"hour");
        }
        minDiff = minDiff/6;
        responseDuration = [responseDuration stringByAppendingString:[NSString stringWithFormat:@"%d.%01d %@",hourDiff,minDiff,unit]];
    }
    NSMutableAttributedString *responseDurationAttr = [[NSMutableAttributedString alloc]initWithString:responseDuration];
    self.lbl_respondedIn.attributedText = responseDurationAttr;
    
    NSString *invoiceString = @"";
    if (order.caseNumber) {
//        AMCase *woCase = [[AMLogicCore sharedInstance]getCaseInfoByID:order.caseID];
//        if (woCase.caseNumber) {
            invoiceString = order.caseNumber;
//        }
    }
    NSMutableAttributedString *invoiceAttr = [[NSMutableAttributedString alloc]initWithString:invoiceString];
    self.lbl_invoiceNo.attributedText = invoiceAttr;
}

- (void)generateLocationAndContact:(AMWorkOrder *)order
{
    
    NSString *address = @"";
    if (order.workLocation) {
        address = [address stringByAppendingString:order.workLocation];
    }
    self.lbl_address.text = address;
    
    NSString *contact = @"";
    if (order.contact) {
        contact = [contact stringByAppendingString:order.contact];
    }
    self.lbl_contactName.text = contact;
}

- (void)generateWoCreateDateAndRespond:(AMWorkOrder *)order
{
    NSDateFormatter *formatterDate = [NSDateFormatter new];
    formatterDate.dateFormat = @"MMM dd, yyyy HH:mm";
    formatterDate.timeZone = [[AMProtocolParser sharedInstance]timeZoneOnSalesforce];
     NSString *woCreateTime = @"";
    if (order.createdDate) {
        woCreateTime = [woCreateTime stringByAppendingString:[formatterDate stringFromDate:order.createdDate]];
    }
    self.lbl_dateOpen.text = woCreateTime;
    
    NSString *closeDate = @"";
    if (order.actualTimeEnd) {
        closeDate = [closeDate stringByAppendingString:[formatterDate stringFromDate:order.actualTimeEnd]];
    }
    self.lbl_dateClosed.text = closeDate;
}

- (void)makeRoundLableVisiableOrNot:(AMWorkOrder *)order
{
    if (order.priority) {
        for (int i=0; i<[[self workOrderPriority]count]; i++) {
            if ([[[self workOrderPriority]objectAtIndex:i] isEqualToString:order.priority]) {
                self.imgBackground = [UIImage imageNamed:[[self workOrderPriorityColor]objectAtIndex:i]];
            }
        }
    }else{
        self.imgBackground = [UIImage imageNamed:[[self workOrderPriorityColor]objectAtIndex:DEFAULT_WORK_ORDER_PRIORITY_COLOR]];
    }
    
    [self.imgView_Number setImage:self.imgBackground];
    [self.imgView_MultiEvent setImage:self.imgBackground];
}

- (void)attributeUpperScriptionForAttributedString:(NSMutableAttributedString *)originalString
                                                           atRange:(NSRange) range
{
    long upsideNumber = 2;
    CFNumberRef upsideNum = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &upsideNumber);
    [originalString addAttribute:(id)kCTSuperscriptAttributeName value:(__bridge id)upsideNum range:range];
    [originalString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:range];
}

@end








