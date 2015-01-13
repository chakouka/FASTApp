//
//  AMLabelCount.m
//  AramarkFSP
//
//  Created by Aaron Hu on 6/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMLabelCount.h"

@implementation AMLabelCount

- (id)init
{
    self = [self initWithFrame:CGRectMake(90, 0, 23, 23)];
    if (self) {

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = [UIColor whiteColor];
		self.backgroundColor = [UIColor redColor];
		self.textAlignment = NSTextAlignmentCenter;
        [self setHidden:YES];
		[[self layer] setCornerRadius:1];
		[[self layer] setBorderWidth:1];
		[[self layer] setBorderColor:[UIColor whiteColor].CGColor];
    }
    return self;
}

- (id)initWithCountNumber:(NSInteger)countNumber
{
    self = [self initWithFrame:CGRectMake(50.0, 10.0, 23.0, 23.0)];
    if (self) {
        self.countNumber = countNumber;
    }
    return self;
}

- (void)setCountNumber:(NSInteger)countNumber
{
    _countNumber = countNumber;
    if (countNumber <= 0) {
        [self setText:@"0"];
        [self setHidden:YES];
    } else {
        if (countNumber >= 99) {
            countNumber = 99;
        }
        [self setText:[NSString stringWithFormat:@"%i", countNumber]];
        [self setHidden:NO];
    }
}

@end
