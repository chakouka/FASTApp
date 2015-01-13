//
//  AMLocationViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMLocationViewController.h"
#import "AMAddLocationView.h"
#import "AMLocation.h"

@interface AMLocationViewController ()

@end

@implementation AMLocationViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.superview.frame), CGRectGetHeight(self.view.frame));
    self.locationListScrollView.frame = CGRectMake(self.locationListScrollView.frame.origin.x, self.locationListScrollView.frame.origin.y, CGRectGetWidth(self.view.frame) - 20.0, self.locationListScrollView.frame.size.height);
    if (self.updateSiteSurveyScrollView) {
        self.updateSiteSurveyScrollView.frame = CGRectMake(self.updateSiteSurveyScrollView.frame.origin.x, self.updateSiteSurveyScrollView.frame.origin.y, CGRectGetWidth(self.view.frame), self.updateSiteSurveyScrollView.frame.size.height);
        if (self.updateSiteSurveyVC) {
            self.updateSiteSurveyVC.view.frame = CGRectMake(self.updateSiteSurveyVC.view.frame.origin.x, self.updateSiteSurveyVC.view.frame.origin.y, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.updateSiteSurveyVC.view.frame));
            [self.updateSiteSurveyScrollView setContentSize:self.updateSiteSurveyVC.view.bounds.size];
        }
    }
    for (UIView *cellView in [self.locationListScrollView subviews]) {
        CGRect tempRect = cellView.frame;
        tempRect.size.width = CGRectGetWidth(self.locationListScrollView.frame);
        cellView.frame = tempRect;
    }
    
    NSString *strT = [NSString stringWithFormat:@"   %@",MyLocal(@"Cancel")];
    MyButtonTitle(self.cancelSurvey, strT);
    [self.cancelSurvey.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Private Methods
- (void)setLocationArr:(NSArray *)locationArr
{
    [self cancelSurveyTapped:nil]; //reset location view
    if (_locationArr && locationArr == _locationArr) {
        return;
    }
    _locationArr = locationArr;
    //remove previous subviews
    for (UIView *subView in [_locationListScrollView subviews]) {
        if (subView.tag != 1000) { //Do NOT remove Add Location View
            [subView removeFromSuperview];
        }
    }
    [_locationsView removeAllObjects];
    float yOrigin = 0.0;
    for (int i=0; i < [_locationArr count]; i++) {
        AMLocation *location = [_locationArr objectAtIndex:i];
        AMCustomCellView *cellView = [AMUtilities loadViewByClassName:NSStringFromClass([AMCustomCellView class]) fromXib:nil];
        cellView.frame = CGRectMake(0.0, i * 36.0, CGRectGetWidth(cellView.frame), CGRectGetHeight(cellView.frame));
        cellView.assignedLocation = location;
        cellView.delegate = self;
        [self.locationListScrollView addSubview:cellView];
        [_locationsView addObject:cellView];
        yOrigin = CGRectGetMaxY(cellView.frame);
    }
//    AMAddLocationView *addLocation = [AMUtilities loadViewByClassName:NSStringFromClass([AMAddLocationView class]) fromXib:nil];
    if (!_addLocationVC) {
        _addLocationVC = [[AMAddLocationViewController alloc] initWithNibName:@"AMAddLocationViewController" bundle:nil];
        _addLocationVC.delegate = self;
        [self.locationListScrollView insertSubview:_addLocationVC.view atIndex:0];
    }
    [self.locationListScrollView bringSubviewToFront:_addLocationVC.view];
    
    _addLocationVC.view.frame = CGRectMake(0.0, yOrigin, CGRectGetWidth(_addLocationVC.view.frame), CGRectGetHeight(_addLocationVC.view.frame));
    
    yOrigin = CGRectGetMaxY(_addLocationVC.view.frame);
    if (yOrigin > CGRectGetHeight(self.locationListScrollView.frame)) {
        [self.locationListScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.locationListScrollView.frame), yOrigin)];
        [self.locationListScrollView setScrollEnabled:YES];
    } else {
        [self.locationListScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.locationListScrollView.frame), CGRectGetHeight(self.locationListScrollView.frame))];
        [self.locationListScrollView setScrollEnabled:NO];
    }
}

- (void)didTapOnSaveLocation:(AMLocation *)newLocation
{
    newLocation.accountID = self.accountId;
    [[AMLogicCore sharedInstance] addLocation:newLocation completionBlock:^(NSInteger type, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:MyLocal(@"Save Fail")];
            } else {
                [SVProgressHUD showSuccessWithStatus:MyLocal(@"Save Success")];
                //reload location list
                
                NSArray *tempArr = [[AMLogicCore sharedInstance] getLocationListByAccountID:self.accountId];
                if (tempArr && [tempArr count] > 0) {
                    self.locationArr = tempArr;
                    self.relatedWO.woAccount.locationList = tempArr;
                }
            }
        });
    }];
}

- (void)didTappedOnUpdateSiteSurvey:(AMLocation *)location;
{
    if (!_updateSiteSurveyVC) {
        _updateSiteSurveyVC = [[AMUpdateSiteSurveyViewController alloc] initWithNibName:@"AMUpdateSiteSurveyViewController" bundle:nil];
        _updateSiteSurveyVC.delegate = self;
        [self.updateSiteSurveyScrollView addSubview:_updateSiteSurveyVC.view];
        [self.updateSiteSurveyScrollView setContentSize:_updateSiteSurveyVC.view.bounds.size];
        [self.updateSiteSurveyScrollView setScrollEnabled:YES];
        self.updateSiteSurveyScrollView.alpha = 0;
        self.updateSiteSurveyScrollView.hidden = YES;
    }
    _updateSiteSurveyVC.location = location;
    self.locationListScrollView.hidden = YES;
    self.locationListScrollView.alpha = 0.0;
    self.updateSiteSurveyScrollView.hidden = NO;
    self.cancelSurvey.hidden = NO;
    self.locationNameLabel.text = [NSString stringWithFormat:@"%@: %@", MyLocal(@"Location Name"),location.location];
    [UIView animateWithDuration:0.5 animations:^{
        self.updateSiteSurveyScrollView.alpha = 1.0;
    }];
}
- (IBAction)cancelSurveyTapped:(id)sender {
    //reset location view
    self.cancelSurvey.hidden = YES;
    self.locationNameLabel.text = MyLocal(@"Location");
    self.locationListScrollView.hidden = NO;
    self.updateSiteSurveyScrollView.hidden = YES;
    self.updateSiteSurveyScrollView.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.locationListScrollView.alpha = 1.0;
    }];
}

#pragma AMUpdateSiteSurveyViewControllerDelegate
- (void)didTappedOnSubmit:(NSError *)error
{
    if (!error) {
        //Hidden Survey Screen
        [self cancelSurveyTapped:nil];
    }
}

@end
