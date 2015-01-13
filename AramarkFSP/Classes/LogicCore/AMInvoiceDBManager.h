//
//  AMInvoiceDBManager.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/18/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMObjectDBManager.h"
#import "AMInvoice.h"

@interface AMInvoiceDBManager : AMObjectDBManager

+ (AMInvoiceDBManager *)sharedInstance;
@end
