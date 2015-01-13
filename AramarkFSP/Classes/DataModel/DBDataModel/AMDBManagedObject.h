//
//  AMDBManagedObject.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/24/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface AMDBManagedObject : NSManagedObject

// abstract method
+(instancetype)newEntity;

@end
