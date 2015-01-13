//
//  AMUserDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/10/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMUserDBManager.h"
#import "AMDBUser.h"

@implementation AMUserDBManager

#pragma mark - Transfer
- (BOOL)transferDBUser:(AMDBUser *)dbUser toUser:(AMUser *)user
{
    
    
    return YES;
}

- (BOOL)transferUser:(AMUser *)user toDBUser:(AMDBUser *)dbUser
{
    
    
    return YES;
}

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBUser";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMUser * user = (AMUser *)object;
    AMDBUser * dbUser = (AMDBUser *)dbObject;
    
    dbUser.userID = user.userID;
    dbUser.timeStamp = user.timeStamp;
    dbUser.displayName = user.displayName;
    dbUser.photoUrl = user.photoUrl;
    dbUser.longitude = user.longitude;
    dbUser.latitude = user.latitude;
    dbUser.workingHourFrom = user.workingHourFrom;
    dbUser.workingHourTo = user.workingHourTo;
    dbUser.lunchBreakFrom = user.lunchBreakFrom;
    dbUser.lunchBreakTo = user.lunchBreakTo;
    dbUser.positionTimestamp = user.positionTimestamp;
    dbUser.marketCenterEmail = user.marketCenterEmail;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMUser * user = [[AMUser alloc] init];
    AMDBUser * dbUser = (AMDBUser *)dbObject;
    
    user.userID = dbUser.userID;
    user.timeStamp = dbUser.timeStamp;
    user.displayName = dbUser.displayName;
    user.photoUrl = dbUser.photoUrl;
    user.longitude = dbUser.longitude;
    user.latitude = dbUser.latitude;
    user.workingHourFrom = dbUser.workingHourFrom;
    user.workingHourTo = dbUser.workingHourTo;
    user.lunchBreakFrom = dbUser.lunchBreakFrom;
    user.lunchBreakTo = dbUser.lunchBreakTo;
    user.positionTimestamp = dbUser.positionTimestamp;
    user.marketCenterEmail = dbUser.marketCenterEmail;
    
    return user;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMUser * user = (AMUser *)data;
    
    return [NSPredicate predicateWithFormat:@"userID = %@",user.userID];
}

#pragma mark - Methods
+ (AMUserDBManager *)sharedInstance
{
    static AMUserDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMUserDBManager alloc] init];
    });
    
    return sharedInstance;

}

- (void)updateUser:(NSPredicate *)filter timeStamp:(NSDate *)timeStamp ToDB:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSError * error = nil;
        
        [fetch setEntity:[NSEntityDescription entityForName:_entityName inManagedObjectContext:context]];
        [fetch setPredicate:filter];
        
        NSArray *dbList = [context executeFetchRequest:fetch error:&error];
        
        if (dbList.count) {
            AMDBUser * user = [dbList objectAtIndex:0];
            
            user.timeStamp = timeStamp;
            
            [context save:&error];
        }
    }];
}
@end
