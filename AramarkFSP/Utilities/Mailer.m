//
//  Mailer.m
//  AramarkFSP
//
//  Created by Bruno Nader on 7/25/16.
//  Copyright © 2016 PWC Inc. All rights reserved.
//

#import "Mailer.h"

@implementation Mailer

-(id) init
{
    if (self = [super init])
    {
        self.subject = @"";
        self.body = @"";
        self.recipients = nil;
        self.attachments = [NSArray new];
        self.isHtml = NO;
    }
    
    return self;
}

-(id) initWithSubject:(NSString *) subject MessageBody:(NSString *) body Recipients:(NSArray *) recipients
{
    if (self = [super init])
    {
        self.subject = subject;
        self.body = body;
        self.recipients = recipients;
        self.attachments  = [NSArray new];
        self.isHtml = NO;
    }
    
    return self;
}

-(MFMailComposeViewController *) getMailComposer
{
    MFMailComposeViewController *mail = [MFMailComposeViewController new];
    
    [mail setSubject: self.subject];
    [mail setMessageBody: self.body isHTML:self.isHtml];
    [mail setToRecipients: self.recipients];
    
    [self.attachments enumerateObjectsUsingBlock:^(id attchment, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *attchmentDictionary = attchment;
        
        [attchmentDictionary enumerateKeysAndObjectsUsingBlock:^(id fileName, id dataObj, BOOL *attachmentStop) {
            
            [mail addAttachmentData:dataObj mimeType:[self getMimeTypeFromAttachmentFileName:fileName]
                           fileName:fileName];
            
        }];
        
    }];
    
    return mail;
}

-(NSString *) getMimeTypeFromAttachmentFileName:(NSString *) attachmentName
{
    NSArray *fileparts = [attachmentName componentsSeparatedByString:@"."];
    NSString *extension = [fileparts objectAtIndex:1];
    
    NSString *mimeType;
    
    if ([extension isEqualToString:@"log"] || [extension isEqualToString:@"txt"])
    {
        mimeType = @"text/txt";
    }
    else if ([extension isEqualToString:@"jpg"])
    {
        mimeType = @"image/jpeg";
    }
    else if ([extension isEqualToString:@"png"])
    {
        mimeType = @"image/png";
    }
    else if ([extension isEqualToString:@"doc"])
    {
        mimeType = @"application/msword";
    }
    else if ([extension isEqualToString:@"ppt"])
    {
        mimeType = @"application/vnd.ms-powerpoint";
    }
    else if ([extension isEqualToString:@"html"])
    {
        mimeType = @"text/html";
    }
    else if ([extension isEqualToString:@"pdf"])
    {
        mimeType = @"application/pdf";
    }
    else if ([extension isEqualToString:@"zip"])
    {
        mimeType = @"application/zip";
    }
    else if ([extension isEqualToString:@"zlib"])
    {
        mimeType = @"application/zlib";
    }
    
    return mimeType;
}

@end
