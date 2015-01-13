//
//  AMWorkNotePopoverViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 7/2/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMWorkNotePopoverViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *valueTF;
@property (weak, nonatomic) NSString *workOrderNotes;

@end
