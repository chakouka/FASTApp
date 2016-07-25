//
//  LogFileMailer.h
//  AramarkFSP
//
//  Created by Bruno Nader on 7/24/16.
//  Copyright © 2016 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mailer.h"

typedef enum
{
    LOGS = 0,
    DB = 1
}
ATTACHMENT_TYPE;

@interface LogFileMailer : Mailer

@property (nonatomic) ATTACHMENT_TYPE attachmentType;

-(id) init;
-(void) composeLogsEmail;

@end
