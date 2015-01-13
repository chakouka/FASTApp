//
//  DetailRootViewController.m
//  AramarkFSP
//
//  Created by PwC on 4/25/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "DetailRootViewController.h"

@interface DetailRootViewController ()

@end

@implementation DetailRootViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_AMDETAILPANELVIEWCONTROLLER object:nil];
}

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromDetailPanelViewController:) name:NOTIFICATION_FROM_AMDETAILPANELVIEWCONTROLLER object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

-(void)dealWithNotiFromDetailPanelViewController:(NSNotification *)notification {
    
}

#pragma mark - Layout Change

-(void)showFullScreen
{
    
}

-(void)hiddenFullScreen
{
    
}

@end
