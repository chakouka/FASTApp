//
//  AMSummaryFutureCell.m
//  AramarkFSP
//
//  Created by Jonathan.WANG on 7/23/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMSummaryFutureCell.h"
#import <CoreText/CoreText.h>


@interface AMSummaryFutureCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgView_Number;
@property (weak, nonatomic) IBOutlet UIImageView *imageView_MultiEvent;
@property (nonatomic,strong) UIImage *imgBackground;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_woName;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_startTime;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_completeTime;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_invoiceNo;

@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_address;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_contactName;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_dateOpen;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_priority;


@end

@implementation AMSummaryFutureCell

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
    self.labelTEstimatedStartTime.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Estimated Start Time")];
    self.labelTEstimatedEndTime.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Estimated End Time")];
    self.labelTCaseNo.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Case No")];
    self.labelTContact.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Contact")];
    self.labelTWoCreatedDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"WO Created Date")];
      self.labelTPriority.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Priority")];
    
    [self.btnWorkNow setTitle:MyLocal(@"Work Now") forState:UIControlStateHighlighted];
    [self.btnWorkNow setTitle:MyLocal(@"Work Now") forState:UIControlStateNormal];
    
    // Initialization code
    self.btnWorkNow.titleLabel.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setOrder:(AMWorkOrder *)order{
    _order = order;
    if (order) {
        if ([order.eventList count] > 1) {
            [self.imageView_MultiEvent setHidden:NO];
        }else{
            [self.imageView_MultiEvent setHidden:YES];
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
    if (order.estimatedTimeStart) {
        startTime = [startTime stringByAppendingString:[formatterTime stringFromDate:order.estimatedTimeStart]];
    }
    NSMutableAttributedString *startTimeAttr = [[NSMutableAttributedString alloc]initWithString:startTime];
    NSRange startAMRange = [startTime rangeOfString:@"AM"];
    NSRange startPMRange = [startTime rangeOfString:@"PM"];
    [self attributeUpperScriptionForAttributedString:startTimeAttr atRange:startAMRange];
    [self attributeUpperScriptionForAttributedString:startTimeAttr atRange:startPMRange];
    self.lbl_startTime.attributedText = startTimeAttr;
    
    NSString *completeTime = @"";
    if (order.estimatedTimeEnd) {
        completeTime = [completeTime stringByAppendingString:[formatterTime stringFromDate:order.estimatedTimeEnd]];
    }
    NSMutableAttributedString *completeTimeAttr = [[NSMutableAttributedString alloc]initWithString:completeTime];
    NSRange completeAMRange = [completeTime rangeOfString:@"AM"];
    NSRange completePMRange = [completeTime rangeOfString:@"PM"];
    [self attributeUpperScriptionForAttributedString:completeTimeAttr atRange:completeAMRange];
    [self attributeUpperScriptionForAttributedString:completeTimeAttr atRange:completePMRange];
    self.lbl_completeTime.attributedText = completeTimeAttr;
    
    NSString *invoiceString = @"";
    if (order.caseID) {
        AMCase *woCase = [[AMLogicCore sharedInstance]getCaseInfoByID:order.caseID];
        if (woCase.caseNumber) {
            invoiceString = [invoiceString stringByAppendingString:woCase.caseNumber];
        }
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
    
    NSString *priority = @"";
    if (order.priority) {
        priority = [priority stringByAppendingString:order.priority];
    }
    
    NSString *strPriority = MyLocal(priority);
    
    if ([LanguageConfig currentLanguage] == LanguageType_French) {
        strPriority = [strPriority stringByReplacingOccurrencesOfString:@"hours" withString:@"heures"];
    }
    
    [self.lbl_priority setText:strPriority];
}

- (void)generateWoCreateDateAndRespond:(AMWorkOrder *)order
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MMM dd yyyy HH:mm";
    formatter.timeZone = [[AMProtocolParser sharedInstance]timeZoneOnSalesforce];
    NSString *openDate = @"";
    if (order.createdDate) {
        openDate = [openDate stringByAppendingString:[formatter stringFromDate:order.createdDate]];
    }
    [self.lbl_dateOpen setText:openDate];
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
    [self.imageView_MultiEvent setImage:self.imgBackground];
}

- (void)attributeUpperScriptionForAttributedString:(NSMutableAttributedString *)originalString
                                           atRange:(NSRange) range
{
    long upsideNumber = 2;
    CFNumberRef upsideNum = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &upsideNumber);
    [originalString addAttribute:(id)kCTSuperscriptAttributeName value:(__bridge id)upsideNum range:range];
    [originalString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:range];
}

#pragma mark - button click actions

- (IBAction)summaryWorkNowButtonAction:(id)sender {
    [self.delegate didWorkNowButtonClicked:self];
}
@end
