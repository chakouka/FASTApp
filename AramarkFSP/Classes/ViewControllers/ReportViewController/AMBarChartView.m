//
//  AMBarChartView.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/5/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMBarChartView.h"
#import "AMReportAxisLabel.h"
#import "AMBarView.h"

#define GAP_LEFT    1.0/10.0
#define GAP_RIGHT   1.0/20.0
#define GAP_TOP     1.0/10.0
#define GAP_BOTTOM  1.0/10.0

#define AXIS_THICKNESS  1.0

#define GAP_COLUMN  1.0/5.0

#define PIN_WIDTH_TO_GAP    1.0/10.0
#define LABEL_AMOUNT_DYNAMIC_HEIGHT 1.0/20


@implementation AMBarChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)redraw
{
    if (self.arr_text_x.count && self.arr_text_y.count && self.arr_value.count
        && self.arr_text_x.count == self.arr_value.count)
    {
        [self draw];
    }
}

- (void)blackraw
{
    if (self.arr_text_x.count && self.arr_text_y.count && self.arr_mc_value.count
        && self.arr_text_x.count == self.arr_mc_value.count) {
        for (UIView *subview in self.subviews) {
            [subview removeFromSuperview];
        }
        [self draw];
    }
}

-(void)draw
{
    CGSize bgSize = self.frame.size;
    CGPoint origin = CGPointMake(self.frame.size.width * GAP_LEFT,
                                 self.frame.size.height * (1-GAP_BOTTOM));
    // draw x Axis
    UIView *xAxis = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y,
                                                             bgSize.width * (1-(GAP_LEFT+GAP_RIGHT)),
                                                             AXIS_THICKNESS)];
    xAxis.backgroundColor = [UIColor blackColor];
    [self addSubview:xAxis];
    
    // draw y Axis
    UIView *yAxis = [[UIView alloc] initWithFrame:CGRectMake(origin.x, bgSize.height * GAP_TOP, AXIS_THICKNESS,
                                                             bgSize.height * (1-(GAP_TOP+GAP_BOTTOM)))];
    yAxis.backgroundColor = [UIColor blackColor];
    [self addSubview:yAxis];
    
    // draw y Axis pin and Labels
    CGFloat pinWidth = origin.x * PIN_WIDTH_TO_GAP;
    CGFloat yUnit = yAxis.frame.size.height / (self.arr_text_y.count - 1);
    for (int i = 0; i< self.arr_text_y.count; i++)
    {
        // pin
        CGFloat y = yAxis.frame.origin.y + yUnit * (self.arr_text_y.count - 1 - i);
        UIView *pin = [[UIView alloc] initWithFrame:CGRectMake(yAxis.frame.origin.x - pinWidth, y, pinWidth, AXIS_THICKNESS)];
        pin.backgroundColor = [UIColor blackColor];
        [self addSubview:pin];
        
        // labels
        AMReportAxisLabel *label = [[AMReportAxisLabel alloc] initWithFrame:CGRectMake(0, 0, origin.x*7/10, yUnit*4/5)];
        label.center = CGPointMake(origin.x/2, y);
        label.text = self.arr_text_y[i];
        [self addSubview:label];
    }
    
    // draw x Labels and columns
    NSInteger numOfCols = self.arr_text_x.count;
    CGFloat xUnit = xAxis.frame.size.width / (numOfCols*(1+GAP_COLUMN)+GAP_COLUMN);
    CGFloat gapUnit = xUnit * GAP_COLUMN;
    
    for (int i = 0; i< self.arr_text_x.count; i++)
    {
        // x labels
        CGFloat x = origin.x + gapUnit + xUnit/2 +  (gapUnit + xUnit) * i;
        AMReportAxisLabel *label = [[AMReportAxisLabel alloc] initWithFrame:CGRectMake(0, 0, xUnit, (bgSize.height - origin.y)*7/10)];
        label.center = CGPointMake(x, (bgSize.height + origin.y)/2);
        label.text = self.arr_text_x[i];
        [self addSubview:label];
        
        // columns
        CGFloat unitPoint = yAxis.frame.size.height / [self.arr_text_y.lastObject integerValue];
        
        CGFloat heightBlack = [self.arr_mc_value[i] doubleValue]*unitPoint;
        AMBarView *blackBar = [[AMBarView alloc] initWithFrame:CGRectMake(0, 0, xUnit, heightBlack)];
        blackBar.center = CGPointMake(x, origin.y-heightBlack/2);
        [blackBar setBackgroundColor:[UIColor blackColor]];
        [self addSubview:blackBar];
        
        CGFloat heightRed = [self.arr_value[i] doubleValue] * unitPoint;
        AMBarView *redBar = [[AMBarView alloc] initWithFrame:CGRectMake(0, 0, xUnit, heightRed)];
        redBar.center = CGPointMake(x, origin.y - heightRed/2);
        [redBar setBackgroundColor:[UIColor colorWithRed:168/255.0 green:68/255.0 blue:75/255.0 alpha:1]];
        [self addSubview:redBar];
        
        //number label for self
        UILabel *amountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, xUnit, bgSize.height * LABEL_AMOUNT_DYNAMIC_HEIGHT)];
        amountLabel.center = CGPointMake(x, origin.y - heightRed - amountLabel.frame.size.height/2);
        [amountLabel setTextAlignment:NSTextAlignmentCenter];
        if ([self.arr_value[i] isEqualToValue:self.arr_mc_value[i]]) {
            [amountLabel setTextColor:[UIColor blackColor]];
        }else{
           [amountLabel setTextColor:[UIColor whiteColor]];
        }
        [amountLabel setText:[NSString stringWithFormat:@"%02d",[self.arr_value[i] intValue]]];
        [amountLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15]];
        [self addSubview:amountLabel];
        
        // number label for whole center
        if ([self.arr_value[i] intValue] < [self.arr_mc_value[i] intValue]) {
            UILabel *amountCenterLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, xUnit, bgSize.height*LABEL_AMOUNT_DYNAMIC_HEIGHT)];
            amountCenterLabel.center = CGPointMake(x, origin.y - heightBlack - amountCenterLabel.frame.size.height/2);
            if (amountLabel.center.y - amountCenterLabel.center.y < amountCenterLabel.frame.size.height) {
                amountCenterLabel.center = CGPointMake(x, origin.y - heightBlack - amountCenterLabel.frame.size.height);
            }
            [amountCenterLabel setTextAlignment:NSTextAlignmentCenter];
            [amountCenterLabel setTextColor:[UIColor blackColor]];
            [amountCenterLabel setText:[NSString stringWithFormat:@"%02d",[self.arr_mc_value[i] intValue]]];
            [amountCenterLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15]];
            [self addSubview:amountCenterLabel];
        }
        
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
