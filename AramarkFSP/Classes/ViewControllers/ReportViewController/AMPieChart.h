//
//  AMPieChart.h
//  AramarkFSP
//
//  Created by Jonathan.WANG on 6/27/14.
//  This file is created according to XYPieChart
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMPieChart;
@protocol AMPieChartDataSource <NSObject>
@required
- (NSUInteger)numberOfSlicesInPieChart:(AMPieChart *)pieChart;
- (CGFloat)pieChart:(AMPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index;
@optional
- (UIColor *)pieChart:(AMPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index;
@end

@protocol AMPieChartDelegate <NSObject>
@optional
- (void)pieChart:(AMPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(AMPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(AMPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(AMPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index;
@end

@interface AMPieChart : UIView
@property(nonatomic,weak) id<AMPieChartDataSource> dataSource;
@property(nonatomic,weak) id<AMPieChartDelegate> delegate;
@property(nonatomic,assign) CGFloat startPieAngle;
@property(nonatomic,assign) CGFloat animationSpeed;
@property(nonatomic,assign) CGPoint pieCenter;
@property(nonatomic,assign) CGFloat pieRadius;
@property(nonatomic,assign) BOOL showLabel;
@property(nonatomic,strong) UIFont *labelFont;
@property(nonatomic,assign) CGFloat labelRadius;
@property(nonatomic,assign) CGFloat selectedSliceStroke;
@property(nonatomic,assign) CGFloat selectedSliceOffsetRadius;
@property(nonatomic,assign) BOOL showPercentage;

- (id)initWithFrame:(CGRect)frame Center:(CGPoint)center Radius:(CGFloat)radius;
- (void)reloadData;
- (void)setPieBackgroundColor:(UIColor *)color;

@end
