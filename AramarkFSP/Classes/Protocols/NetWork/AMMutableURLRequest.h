//
//  AMMutableURLRequest.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/6/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMConstants.h"

@interface AMMutableURLRequest : NSMutableURLRequest
{
    NSInteger _type;
    NSDictionary * _userData;
}

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSDictionary * userData;
@property (nonatomic, copy) AMSFRestCompletionBlock completionBlock;

@end
