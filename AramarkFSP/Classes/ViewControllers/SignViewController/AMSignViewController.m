//
//  AMSignViewController.m
//  AramarkFSP
//
//  Created by PwC on 5/2/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMSignViewController.h"
#import "DrawView.h"
#import "UIImage+Scale.h"

@interface AMSignViewController ()
<
DrawViewDelegate
>
{
	DrawView *viewDraw;
	BOOL drawMove;
}
@property (nonatomic, assign) BOOL drawMove;
@end

@implementation AMSignViewController
@synthesize drawMove;
@synthesize delegate;
@synthesize strFileName;


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
    
    viewDraw = [[DrawView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.viewSign.frame), CGRectGetHeight(self.viewSign.frame))];
    viewDraw.backgroundColor = [UIColor whiteColor];
	viewDraw.delegate = self;
	[self.viewSign addSubview:viewDraw];

     [AMUtilities refreshFontInView:self.view];
    
    [self.btnConfirm setTitle:MyLocal(@"CONFIRM") forState:UIControlStateNormal];
    [self.btnConfirm setTitle:MyLocal(@"CONFIRM") forState:UIControlStateHighlighted];
    
    [self.btnReset setTitle:MyLocal(@"RESET") forState:UIControlStateNormal];
    [self.btnReset setTitle:MyLocal(@"RESET") forState:UIControlStateHighlighted];
    
    [self.btnCancel setTitle:MyLocal(@"CANCEL") forState:UIControlStateNormal];
    [self.btnCancel setTitle:MyLocal(@"CANCEL") forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
//	DLog(@"viewWillLayoutSubviews : AMPointsViewController");
	self.view.frame = self.view.superview.bounds;
}

- (IBAction)clickConfirmBtn:(id)sender {
    if (!drawMove) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please sign your name!")];
		return;
	}
    
	UIImage *image = [viewDraw getImageFromCurrentView];
	image = [image imageByScalingProportionallyToMinimumSize:CGSizeMake(CGRectGetWidth(self.viewSign.frame),CGRectGetHeight(self.viewSign.frame))];
//	NSData *data = UIImageJPEGRepresentation(image, 1);
    
    self.drawMove = NO;
    [viewDraw resetView];
    
    if (delegate && [delegate respondsToSelector:@selector(AMSignViewController:confirmWith:)]) {
        [delegate AMSignViewController:self confirmWith:image];
    }
}

- (IBAction)clickResetBtn:(id)sender {
    self.drawMove = NO;
    [viewDraw resetView];
    
    if (delegate && [delegate respondsToSelector:@selector(AMSignViewController:resetWith:)]) {
        [delegate AMSignViewController:self resetWith:nil];
    }
}

- (IBAction)clickCancelBtn:(id)sender {
    self.drawMove = NO;
    [viewDraw resetView];
    if (delegate && [delegate respondsToSelector:@selector(AMSignViewController:cancelWith:)]) {
        [delegate AMSignViewController:self cancelWith:nil];
    }
}

#pragma mark -

- (void)move:(BOOL)isMove {
	self.drawMove = isMove;
}
@end
