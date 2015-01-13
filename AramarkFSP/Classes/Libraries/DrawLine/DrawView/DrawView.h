//
//  DrawView.h
//  MyPainter
//
//  Created by ong leslie on 7/26/11.
//  Copyright 2011 activation group. All rights reserved.
//  -fno-objc-arc

#import <UIKit/UIKit.h>
#import "Squiggle.h"

@protocol DrawViewDelegate <NSObject>

- (void)move:(BOOL)isMove;

@end

@interface DrawView : UIView {
	id <DrawViewDelegate> delegate;
	NSMutableDictionary *squiggles; // squiggles in progress
	NSMutableArray *finishedSquiggles; // finished squiggles
	UIColor *color; // the current drawing color
	float lineWidth; // the current drawing line width
	BOOL _isMove;
} // end instance variable declaration

// declare color and lineWidth as properties
@property (nonatomic, retain) UIColor *color;
@property float lineWidth;
@property (nonatomic, assign) id <DrawViewDelegate> delegate;

// draw the given Squiggle into the given graphics context
- (void)drawSquiggle:(Squiggle *)squiggle inContext:(CGContextRef)context;
- (void)resetView; // clear all squiggles from the view
- (void)saveCurrentView;
- (UIImage *)getImageFromCurrentView;
- (void)setBackgroundimage:(NSString *)imageName;

@end // end interface MainView
