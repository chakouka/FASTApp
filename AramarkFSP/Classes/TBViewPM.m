//
//  TBViewPM.m
//  TBReusableUIView
//
//  Created by Markos Charatzas on 16/03/2013.
//  Copyright (c) 2013 Markos Charatzas (@qnoid).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "TBViewPM.h"
#import "AMPopoverSelectTableViewController.h"
#import "AMCheckoutViewController.h"
#import "AMFilterTableViewCell.h"

typedef NS_ENUM (NSInteger, PopViewType) {
    PopViewType_Select_RepairCode = 1000,
    PopViewType_Select_HoursWorked,
    PopViewType_Select_InvoiceCode,
    PopViewType_Select_FilterName,
    PopViewType_Select_PartName,
    PopViewType_Select_FilterType,//bkk 2/5/15
};

@implementation TBViewPM
@synthesize txtLabel;

@synthesize confirmAndCreateButton;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    //loadViewPM()
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *views = [mainBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    [self addSubview:views[0]];
    
    [self.confirmAndCreateButton setTitle: MyLocal(@"Confirm and create case") forState:UIControlStateNormal];
    txtLabel.text = @"You have just created a PM on an Ice Machine.  There was no PM code selected, please click on 'Confirm and Create Case'";
    
return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }

    //loadViewPM()

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *views = [mainBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    [self addSubview:views[0]];

return self;
}

-(void)dealloc {
}

- (IBAction)confirmAndSaveCase:(id)sender {

    NSDictionary *notification = @{ @"POST_PMS_AND_QUANTITIES" : @1, @"POST_PMS_AND_QUANTITIES_SENDER" : sender};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"POST_PMS_AND_QUANTITIES" object:self userInfo:notification];

//    NSString *errorMsg = MyLocal(@"No PMs selected");
//    [AMUtilities showAlertWithInfo:errorMsg];

}

@end
