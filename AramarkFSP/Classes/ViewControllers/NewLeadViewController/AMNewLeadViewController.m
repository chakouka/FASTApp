//
//  AMNewLeadViewController.m
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMNewLeadViewController.h"
#import "AMNewLeadHistoryViewController.h"
#import "AMAddNewLeadViewController.h"

#define HEIGHT_OF_PANEL     716.0
#define WIDTH_OF_PANEL      836.0
#define PAGE_NUMBER         5

typedef NS_ENUM(NSInteger, PanelType) {
    PanelType_History = 0,
    PanelType_Add,
};

@interface AMNewLeadViewController ()
<
AMNewLeadViewControllerDelegate
>
{
    PanelType   currentType;
    NSMutableArray *arrHistory;
    NSMutableArray *arrViews;
    AMAddNewLeadViewController *addNewVC;
}

@property (nonatomic, strong) NSMutableArray *arrHistory;
@property (nonatomic, strong) NSMutableArray *arrViews;
@property (nonatomic, strong) AMAddNewLeadViewController *addNewVC;

@end

@implementation AMNewLeadViewController
@synthesize arrHistory;
@synthesize arrViews;
@synthesize addNewVC;

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RELOAD_LEAD_HISTORY_LIST object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentType = PanelType_History;
        arrViews = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"New Lead Screen";
    
    [self addVCInitialization];
    self.scrollViewMain.contentOffset = CGPointMake(WIDTH_OF_PANEL * (PAGE_NUMBER -1), 0);
    
    [self.btnHistory setImage:[UIImage imageNamed:MyImage(@"lead-history")] forState:UIControlStateNormal];
    
    [self.btnAddNew setImage:[UIImage imageNamed:MyImage(@"new-lead_sub-nav")] forState:UIControlStateNormal];
    
    [self.btnCancel setImage:[UIImage imageNamed:MyImage(@"cancel")] forState:UIControlStateNormal];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewLeadView) name:NOTIFICATION_RELOAD_LEAD_HISTORY_LIST object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self changeWithPanelType:PanelType_History];
    [addNewVC refreshWithInfo:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)refreshNewLeadView
{
    [self dataInitialization];
    [self viewInitialization];
    [self changeWithPanelType:currentType];
}

- (void)dataInitialization
{
     arrHistory = [NSMutableArray arrayWithArray:[[AMLogicCore sharedInstance] getCreatedLeadsHistoryByDayInRecentDays:5]];
}

- (void)viewInitialization
{
    if (arrViews && [arrViews count] > 0) {
        for (AMNewLeadHistoryViewController *historyVC in arrViews) {
            [historyVC.view removeFromSuperview];
        }
    }
    
    self.scrollViewMain.contentSize = CGSizeMake(WIDTH_OF_PANEL * ([arrHistory count] == 0 ? 1 : [arrHistory count]), HEIGHT_OF_PANEL);
    self.scrollViewMain.pagingEnabled = YES;
    self.scrollViewMain.directionalLockEnabled = YES;
    
    for (NSInteger i = 0; i < [arrHistory count] ; i ++) {
        NSMutableDictionary *dicInfo = [arrHistory objectAtIndex:i];
        AMNewLeadHistoryViewController *historyVC = [[AMNewLeadHistoryViewController alloc] initWithNibName:@"AMNewLeadHistoryViewController" bundle:nil];
        [self.scrollViewMain addSubview:historyVC.view];
        historyVC.view.frame = CGRectMake(WIDTH_OF_PANEL * i, 0, WIDTH_OF_PANEL, HEIGHT_OF_PANEL);
        [historyVC refreshHistoryListWithInfo:dicInfo];
        [arrViews addObject:historyVC];
    }
}

- (void)addVCInitialization
{
    addNewVC = [[AMAddNewLeadViewController alloc] initWithNibName:@"AMAddNewLeadViewController" bundle:nil];
    addNewVC.delegate = self;
    [self.viewAddNewPanel addSubview:addNewVC.view];
    addNewVC.view.frame = CGRectMake(0, 0, WIDTH_OF_PANEL, HEIGHT_OF_PANEL);
}

#pragma mark -

- (IBAction)clickHistoryBtn:(id)sender {
    [self changeWithPanelType:PanelType_History];
}

- (IBAction)clickCancelBtn:(id)sender {
    [self changeWithPanelType:PanelType_History];
}

- (IBAction)clickAddBtn:(UIButton *)sender {
    [self changeWithPanelType:PanelType_Add];
    [addNewVC refreshWithInfo:nil];
}

- (void)changeWithPanelType:(PanelType)aType
{
    currentType = aType;
    self.scrollViewMain.hidden = YES;
    self.viewAddNewPanel.hidden = YES;
    
    switch (aType) {
        case PanelType_History:
        {
            self.scrollViewMain.hidden = NO;
            self.btnCancel.hidden = YES;
            self.imageDivCancel.hidden = YES;
        }
            break;
            
        case PanelType_Add:
        {
            self.viewAddNewPanel.hidden = NO;
            self.btnCancel.hidden = NO;
            self.imageDivCancel.hidden = NO;
        }
            break;
    }
}

#pragma mark -

- (void)didClickSaveNewLead:(BOOL)success
{
    [self changeWithPanelType:PanelType_History];
    [self refreshNewLeadView];
}

@end
