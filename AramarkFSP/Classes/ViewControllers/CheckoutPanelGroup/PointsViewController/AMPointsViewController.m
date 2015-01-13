//
//  AMPointsViewController.m
//  AramarkFSP
//
//  Created by PwC on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMPointsViewController.h"
#import "AMTitleTableViewCell.h"
#import "AMPointsQuestionTableViewCell.h"

@interface AMPointsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@end

@implementation AMPointsViewController
@synthesize arrPointsInfos;
@synthesize workOrder;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
    
    [self.btnNext.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger]];
    
    [self.btnNext setTitle:MyLocal(@"NEXT") forState:UIControlStateNormal];
    [self.btnNext setTitle:MyLocal(@"NEXT") forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
//	DLog(@"viewWillLayoutSubviews : AMPointsViewController");
	self.view.frame = self.view.superview.bounds;
}

#pragma mark - Data

- (void)setupDataSourceByInfo:(AMWorkOrder *)aWorkOrder {
    
    if ([workOrder.woID isEqualToString:aWorkOrder.woID]) {
		return;
	}
    
    if ([self.arrPointsInfos count] > 0) {
        [self.arrPointsInfos removeAllObjects];
    }
    
	self.workOrder = aWorkOrder;

	self.arrPointsInfos = [NSMutableArray array];

	NSMutableDictionary *dicTitle = [NSMutableDictionary dictionary];
	[dicTitle setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Points_Title] forKey:KEY_OF_CELL_TYPE];
	[dicTitle setObject:MyLocal(@"3 CHECK POINTS") forKey:KEY_OF_ADD_HEAD_TITLE];
	[self.arrPointsInfos addObject:dicTitle];

	NSMutableDictionary *dic0 = [NSMutableDictionary dictionary];
	[dic0 setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Points_Check_0] forKey:KEY_OF_CELL_TYPE];
	[dic0 setObject:MyLocal(@"Break room was left in an orderly manner ?") forKey:KEY_OF_QUESTION];
	[dic0 setObject:[NSNumber numberWithBool:[aWorkOrder.leftInOrderlyManner boolValue]] forKey:KEY_OF_CHECK_STATUS];
	[self.arrPointsInfos addObject:dic0];

	NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
	[dic1 setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Points_Check_1] forKey:KEY_OF_CELL_TYPE];
	[dic1 setObject:MyLocal(@"Tested all equipment ?") forKey:KEY_OF_QUESTION];
	[dic1 setObject:[NSNumber numberWithBool:[aWorkOrder.testedAll boolValue]] forKey:KEY_OF_CHECK_STATUS];
	[self.arrPointsInfos addObject:dic1];

	NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
	[dic2 setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Points_Check_2] forKey:KEY_OF_CELL_TYPE];
	[dic2 setObject:MyLocal(@"Inspected tubing for any potential leaks ?") forKey:KEY_OF_QUESTION];
	[dic2 setObject:[NSNumber numberWithBool:[aWorkOrder.inspectedTubing boolValue]] forKey:KEY_OF_CHECK_STATUS];
	[self.arrPointsInfos addObject:dic2];

	[self.mainTableView reloadData];
}

#pragma mark -

- (void)clickCheckBtn:(UIButton *)sender {
	NSMutableDictionary *dicInfo = [self.arrPointsInfos objectAtIndex:sender.tag];
	if ([[dicInfo objectForKey:KEY_OF_CHECK_STATUS] boolValue]) {
		[dicInfo setObject:[NSNumber numberWithBool:NO] forKey:KEY_OF_CHECK_STATUS];
	}
	else {
		[dicInfo setObject:[NSNumber numberWithBool:YES] forKey:KEY_OF_CHECK_STATUS];
	}

	[self.mainTableView reloadData];
}

- (IBAction)clickSubmitBtn:(id)sender {
    
    if (delegate && [delegate respondsToSelector:@selector(didClickPointsViewControllerNextBtn)]) {
        [delegate didClickPointsViewControllerNextBtn];
    }
}

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableDictionary *dicInfo = [self.arrPointsInfos objectAtIndex:indexPath.row];

	switch ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue]) {
		case AMCheckoutCellType_Points_Title:
		{
			AMTitleTableViewCell *cell = (AMTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMTitleTableViewCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMTitleTableViewCell" owner:[AMTitleTableViewCell class] options:nil];
				cell = (AMTitleTableViewCell *)[nib objectAtIndex:0];
			}

			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.labelTitle.text = [NSString stringWithFormat:@"%@", [dicInfo objectForKey:KEY_OF_ADD_HEAD_TITLE]];

			return cell;
		}
		break;

		default:
		{
			AMPointsQuestionTableViewCell *cell = (AMPointsQuestionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMPointsQuestionTableViewCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMPointsQuestionTableViewCell" owner:[AMPointsQuestionTableViewCell class] options:nil];
				cell = (AMPointsQuestionTableViewCell *)[nib objectAtIndex:0];
			}

			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.labelTitle.text = [NSString stringWithFormat:@"%@", [dicInfo objectForKey:KEY_OF_QUESTION]];
			cell.imageCheck.hidden = ![[dicInfo objectForKey:KEY_OF_CHECK_STATUS] boolValue];

			cell.btnCheck.tag = indexPath.row;
			[cell.btnCheck addTarget:self action:@selector(clickCheckBtn:) forControlEvents:UIControlEventTouchUpInside];
//			[cell.btnCheck addTarget:self action:@selector(clickCheckBtn:) forControlEvents:UIControlEventTouchUpInside];

			return cell;
		}
		break;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.arrPointsInfos count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 1.0)];
	return aView;
}

@end
