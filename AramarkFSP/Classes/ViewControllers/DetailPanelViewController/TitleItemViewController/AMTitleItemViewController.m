//
//  AMTitleItemViewController.m
//  AramarkFSP
//
//  Created by PwC on 4/24/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMTitleItemViewController.h"

#define WIDTH_OF_BUTTON_NORMAL      78
#define WIDTH_OF_BUTTON_FULL        105

#define HEIGH_OF_BUTTON             92

@interface AMTitleItemViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewTip;
@property (weak, nonatomic) IBOutlet UIImageView *imageItem;
@property (weak, nonatomic) IBOutlet UILabel *labelItem;
@end

@implementation AMTitleItemViewController
@synthesize delegate;
@synthesize tag;
@synthesize isSelected;

-(id)initWithTag:(NSInteger)aTag Selected:(BOOL)aSelected Delegate:(id<AMTitleItemViewDelegate>)aDelegate
{
    self = [self initWithNibName:@"AMTitleItemViewController" bundle:nil];
    if (self) {
        tag = aTag;
        self.delegate = aDelegate;
        self.isSelected = aSelected;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *strTitle = @"";
    UIImage *imageItem = nil;
    
    switch (tag) {
        case TitleItemType_WorkOrder:
        {
            strTitle = MyLocal(@"WORK ORDER");
        }
            break;
        case TitleItemType_Account:
        {
            strTitle = MyLocal(@"Account");
        }
            break;
        case TitleItemType_Pos:
        {
            strTitle = MyLocal(@"POS");
        }
            break;
        case TitleItemType_Location:
        {
            strTitle = MyLocal(@"LOCATION");
        }
            break;
        case TitleItemType_Contacts:
        {
             strTitle = MyLocal(@"CONTACTS");
        }
            break;
        case TitleItemType_Assets:
        {
            strTitle = MyLocal(@"ASSEETS");
        }
            break;
        case TitleItemType_Cases:
        {
            strTitle = MyLocal(@"CASES");
        }
            break;
        default:
            break;
    }
    
    self.labelItem.text = strTitle;
    self.imageItem.image = imageItem;
    self.viewTip.hidden = !isSelected;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

-(void)setIsSelected:(BOOL)_isSelected
{
    self.viewTip.hidden = !_isSelected;
    isSelected = _isSelected;
}

#pragma mark -

- (void)clickTitleItem:(id)sender {
    self.isSelected = !self.isSelected;
    if (delegate && [delegate respondsToSelector:@selector(clickedTitleItem:)]) {
        [delegate clickedTitleItem:self];
    }
}

#pragma mark -

#pragma mark - Layout Change

-(void)showFullScreen
{
    self.view.bounds = CGRectMake(0, 0, WIDTH_OF_BUTTON_FULL, CGRectGetHeight(self.view.frame));
    self.viewTip.bounds = CGRectMake(0, 0, WIDTH_OF_BUTTON_FULL, CGRectGetHeight(self.viewTip.frame));
}

-(void)hiddenFullScreen
{
    self.view.bounds = CGRectMake(0, 0, WIDTH_OF_BUTTON_NORMAL, CGRectGetHeight(self.view.frame));
    self.viewTip.bounds = CGRectMake(0, 0, WIDTH_OF_BUTTON_NORMAL, CGRectGetHeight(self.viewTip.frame));
}

@end
