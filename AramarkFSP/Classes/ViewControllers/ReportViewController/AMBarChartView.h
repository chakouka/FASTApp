//
//  AMBarChartView.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/5/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMBarChartView : UIView

@property (nonatomic, strong) NSArray *arr_text_x;  // not including 0
@property (nonatomic, strong) NSArray *arr_text_y;  // including 0
@property (nonatomic, strong) NSArray *arr_value; //value for my completed wo
@property (nonatomic, strong) NSArray *arr_mc_value;//whole value for MC completed

-(void)redraw;

-(void)blackraw;

@end
