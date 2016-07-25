//
//  Mailer.h
//  AramarkFSP
//
//  Created by Bruno Nader on 7/25/16.
//  Copyright © 2016 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface Mailer : NSObject

@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSArray *recipients;
@property (nonatomic, strong) NSArray *attachments;
@property (nonatomic) BOOL isHtml;

-(id) init;
-(id) initWithSubject:(NSString *) subject MessageBody:(NSString *) body Recipients:(NSArray *) recipients;
-(MFMailComposeViewController *) getMailComposer;

@end
