//
//  AMLeftBarViewController.m
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMLeftBarViewController.h"
#import "AMLogicCore.h"

@interface AMLeftBarViewController ()
{
	NSTimer *repeatTimer;
	UIButton *selectedButtn;
}

@property (strong, nonatomic) NSTimer *repeatTimer;
@property (weak, nonatomic) IBOutlet UIButton *btn0;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (weak, nonatomic) IBOutlet UIButton *btn4;
@property (weak, nonatomic) IBOutlet UIButton *btn5;
@property (weak, nonatomic) IBOutlet UIButton *btn6;
@property (strong, nonatomic) UIButton *selectedButtn;
@end

@implementation AMLeftBarViewController
@synthesize repeatTimer;
@synthesize syncType;
@synthesize selectedButtn;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SYNCING_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SYNCING_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_DID_SWITCH_LANGUAGE object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		selectedButtn = nil;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self changeDisplay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSyncCloud) name:NOTIFICATION_SYNCING_START object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSyncCloud) name:NOTIFICATION_SYNCING_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwitchLanguage) name:NOTIFICATION_DID_SWITCH_LANGUAGE object:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)didSwitchLanguage
{
    [self setupLeftMenuImage];
}

- (void)setupLeftMenuImage
{
    [self.btn1 setImage:[UIImage imageNamed:MyImage(@"home-icon")] forState:UIControlStateNormal];
    [self.btn1 setImage:[UIImage imageNamed:MyImage(@"home-icon")] forState:UIControlStateHighlighted];
    
    [self.btn2 setImage:[UIImage imageNamed:MyImage(@"summary")] forState:UIControlStateNormal];
    [self.btn2 setImage:[UIImage imageNamed:MyImage(@"summary")] forState:UIControlStateHighlighted];
    
    [self.btn3 setImage:[UIImage imageNamed:MyImage(@"reports")] forState:UIControlStateNormal];
    [self.btn3 setImage:[UIImage imageNamed:MyImage(@"reports")] forState:UIControlStateHighlighted];
    
    [self.btn4 setImage:[UIImage imageNamed:MyImage(@"new-case")] forState:UIControlStateNormal];
    [self.btn4 setImage:[UIImage imageNamed:MyImage(@"new-case")] forState:UIControlStateHighlighted];
    
    [self.btn5 setImage:[UIImage imageNamed:MyImage(@"new-lead")] forState:UIControlStateNormal];
    [self.btn5 setImage:[UIImage imageNamed:MyImage(@"new-lead")] forState:UIControlStateHighlighted];
    
    //TODO::
    [self.btn6 setImage:[UIImage imageNamed:MyImage(@"near-me")] forState:UIControlStateNormal];
    [self.btn6 setImage:[UIImage imageNamed:MyImage(@"near-me")] forState:UIControlStateHighlighted];
}

- (void)changeDisplay {
	[self finishSync];
    
    [self setupLeftMenuImage];
    
	[self.btn1 setBackgroundImage:nil forState:UIControlStateNormal];
	[self.btn1 setBackgroundImage:[UIImage imageNamed:@"clicked-sate-button"] forState:UIControlStateSelected];
    
	[self.btn2 setBackgroundImage:nil forState:UIControlStateNormal];
	[self.btn2 setBackgroundImage:[UIImage imageNamed:@"clicked-sate-button"] forState:UIControlStateSelected];
    
	[self.btn3 setBackgroundImage:nil forState:UIControlStateNormal];
	[self.btn3 setBackgroundImage:[UIImage imageNamed:@"clicked-sate-button"] forState:UIControlStateSelected];
    
	[self.btn4 setBackgroundImage:nil forState:UIControlStateNormal];
	[self.btn4 setBackgroundImage:[UIImage imageNamed:@"clicked-sate-button"] forState:UIControlStateSelected];
    
    [self.btn5 setBackgroundImage:nil forState:UIControlStateNormal];
	[self.btn5 setBackgroundImage:[UIImage imageNamed:@"clicked-sate-button"] forState:UIControlStateSelected];
    
    //TODO::
    [self.btn6 setBackgroundImage:nil forState:UIControlStateNormal];
	[self.btn6 setBackgroundImage:[UIImage imageNamed:@"clicked-sate-button"] forState:UIControlStateSelected];
}

- (void)selectItemWithType:(LeftViewButtonType)aType
{
    [self.btn1 setSelected:NO];
	[self.btn2 setSelected:NO];
	[self.btn3 setSelected:NO];
	[self.btn4 setSelected:NO];
    [self.btn5 setSelected:NO];
    [self.btn6 setSelected:NO];
    
    switch (aType) {
        case LeftViewButtonType_Sync:
		{
			
		}
            break;
            
		case LeftViewButtonType_Home:
		{
			[self.btn1 setSelected:YES];
            selectedButtn = self.btn1;
		}
            break;
            
		case LeftViewButtonType_Summary:
		{
            [self.btn2 setSelected:YES];
            selectedButtn = self.btn2;
		}
            break;
            
		case LeftViewButtonType_Reports:
		{
            [self.btn3 setSelected:YES];
            selectedButtn = self.btn3;
		}
            break;
            
        case LeftViewButtonType_NewCase:
		{
            [self.btn4 setSelected:YES];
            selectedButtn = self.btn4;
		}
            break;
            
		case LeftViewButtonType_NewLead:
		{
            [self.btn5 setSelected:YES];
            selectedButtn = self.btn5;
		}
            break;
            
        case LeftViewButtonType_NearMe:
        {
            [self.btn6 setSelected:YES];
            selectedButtn = self.btn6;
        }
            break;
            
		default:
			break;
	}
}

- (IBAction)clickItemBtn:(UIButton *)sender {
    if ([selectedButtn isEqual:sender]) {
        if (![selectedButtn isEqual:self.btn1] && ![selectedButtn isEqual:self.btn6]) {
            return;
        }
    }
    [self selectItemWithType:sender.tag];
    
	switch (sender.tag) {
		case LeftViewButtonType_Sync:
		{
            DLog(@"Tap on sync button");
            BOOL isNetworkReachable = [[AMLogicCore sharedInstance] isNetWorkReachable];
            if (isNetworkReachable) {
                [[AMLogicCore sharedInstance] startSyncing];
            } else {
                [AMUtilities showAlertWithInfo:MyLocal(@"Please check network connection.")];
            }
            
		}
            break;
            
		case LeftViewButtonType_Home:
		{
		}
            break;
            
		case LeftViewButtonType_Summary:
		{
            
		}
            break;
            
		case LeftViewButtonType_Reports:
		{
		}
            break;
            
        case LeftViewButtonType_NewCase:
		{
		}
            break;
            
		case LeftViewButtonType_NewLead:
		{
		}
            break;
            
        case LeftViewButtonType_NearMe:
		{
		}
            break;
            
		default:
			break;
	}
    
	NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_BTN_ITEM_CLICKED,
                              KEY_OF_INFO:[NSNumber numberWithInteger:sender.tag]
                              };
    
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMLEFTBARVIEWCONTROLLER object:dicInfo];
}

- (void)startSyncCloud {
	if (!repeatTimer) {
		self.repeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
	}
    
	[self finishSync];
	[self.repeatTimer setFireDate:[NSDate distantPast]];
}

- (void)stopSyncCloud {
	if (repeatTimer) {
		[self.repeatTimer setFireDate:[NSDate distantFuture]];
	}
    
	[self finishSync];
}

- (void)resetAllBtns
{
    [self.btn1 setSelected:NO];
	[self.btn2 setSelected:NO];
	[self.btn3 setSelected:NO];
	[self.btn4 setSelected:NO];
    [self.btn5 setSelected:NO];
     [self.btn6 setSelected:NO];
}

- (void)timerFired:(NSTimer *)timer {
	NSString *strImageName = @"cloud-check";
    
	switch (syncType) {
		case SYNCType_1:
		{
			strImageName = @"cloud-sync2";
			self.syncType = SYNCType_2;
		}
            break;
            
		case SYNCType_2:
		{
			strImageName = @"cloud-sync3";
			self.syncType = SYNCType_3;
		}
            break;
            
		default:
		{
			strImageName = @"cloud-sync1";
			self.syncType = SYNCType_1;
		}
            break;
	}
    
	[self.btn0 setImage:[UIImage imageNamed:strImageName] forState:UIControlStateNormal];
	[self.btn0 setImage:[UIImage imageNamed:strImageName] forState:UIControlStateHighlighted];
}

- (void)finishSync {
	self.syncType = SYNCType_Finished;
	[self.btn0 setImage:[UIImage imageNamed:@"cloud-check"] forState:UIControlStateNormal];
	[self.btn0 setImage:[UIImage imageNamed:@"cloud-check"] forState:UIControlStateHighlighted];
}

-(IBAction)reInitButtonPressed:(UIButton *)button
{
    [SVProgressHUD show];
    [[AMLogicCore sharedInstance] resetToInitialization:^(NSInteger type, NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark -

- (void)userInteractionEnabled:(BOOL)enable
{
    self.view.userInteractionEnabled = enable;
}

@end
