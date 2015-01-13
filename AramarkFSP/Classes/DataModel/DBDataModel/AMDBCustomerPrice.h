//
//  AMDBCustomerPrice.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/2/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBCustomerPrice : NSManagedObject

@property (nonatomic, retain) NSString * customerPriceID;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * productID;
@property (nonatomic, retain) NSNumber * price; //unitPrice
@property (nonatomic, retain) NSString * posID;
@property (nonatomic, retain) NSString * productType;

@end
