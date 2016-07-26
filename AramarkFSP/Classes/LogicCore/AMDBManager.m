//
//  AMDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/9/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMDBManager.h"
#import "AMWODBManager.h"
#import "AMUserDBManager.h"
#import "AMEventDBManager.h"
#import "AMAccountDBManager.h"
#import "AMContactDBManager.h"
#import "AMPoSDBManager.h"
#import "AMAssetDBManager.h"
#import "AMCaseDBManager.h"
#import "AMLocationDBManager.h"
#import "AMFilterDBManager.h"
#import "AMPartsDBManager.h"
#import "AMInvoiceDBManager.h"
#import "AMFilterUsedDBManager.h"
#import "AMPartsUsedDBManager.h"
#import "AMBestDBManager.h"
#import "AMAssetRequestDBManager.h"
#import <CoreData/CoreData.h>
#import "AMDBNewContact+AddOn.h"
#import "AMDBNewCase+AddOn.h"
#import "AMDBCustomerPrice+AddOn.h"
#import "AMDBInvoice.h"

//#define DBTESTMODE      1

@interface AMDBManager()
{
    //    dispatch_queue_t _dbQeue;
    NSManagedObjectContext * __mainManagedObjectContext;
    NSManagedObjectContext * __privateManagedObjectContext;
    NSManagedObjectModel * __managedObjectModel;
    NSPersistentStoreCoordinator * __persistentStoreCoordinator;
    
    NSString * _selfId;
    NSDate * _timeStamp;
}

@end
@implementation AMDBManager

@synthesize selfId = _selfId;
@synthesize timeStamp = _timeStamp;

+ (AMDBManager *)sharedInstance
{
    static AMDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMDBManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
#if DBTESTMODE
    //delete all db files
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"self BEGINSWITH[cd] %@",@"Aramark"];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSArray * filesWithFilter = [files filteredArrayUsingPredicate:filter];
    for (NSString * fileName in filesWithFilter) {
        NSString * dataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
    }
#endif
    
    //    _dbQeue = dispatch_queue_create("com.Aramark.objectsDB", nil);
    
    __mainManagedObjectContext = [self mainManagedObjectContext];
    __privateManagedObjectContext = [self privateManagedObjectContext];
    
   //Attempting to fix Could Not Merge Changes error - INC1223238
    //[__privateManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    //[__mainManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:__privateManagedObjectContext];
    
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)setSelfId:(NSString *)selfId
{
    _selfId = selfId;
    [AMWODBManager sharedInstance].selfId = selfId;
}


#pragma mark - CoreData Method

- (void)mergeChanges:(NSNotification *)notification {
    NSManagedObjectContext *savedContext = [notification object];
    
    // ignore change notifications for the main MOC
    if (__mainManagedObjectContext == savedContext)
    {
        return;
    } else if (__mainManagedObjectContext.persistentStoreCoordinator != savedContext.persistentStoreCoordinator) {
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [__mainManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
    //this tells the main thread moc to run on the main thread, and merge in the changes there
    //[__mainManagedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
}
/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
//- (NSManagedObjectContext *)managedObjectContext
//{
//    NSManagedObjectContext * __managedObjectContext = nil;
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil)
//    {
//        __managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
//    return __managedObjectContext;
//}

-(NSManagedObjectContext *)mainManagedObjectContext
{
    NSManagedObjectContext * __managedObjectContext = nil;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

-(NSManagedObjectContext *)privateManagedObjectContext
{
    NSManagedObjectContext * __managedObjectContext = nil;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Aramark" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Aramark.sqlite"];
    DLog(@"AMDBManager storeUrl %@",storeURL);
    NSError *error = nil;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
        [AMUtilities showAlertWithInfo:@"Database updated! Please reinstall the application"];
        return nil;
    }
    
    return __persistentStoreCoordinator;
}


#pragma mark - Internal Method
- (NSArray *)fetchDataArrayForEntity:(NSString *)entityName
                        byPredicates:(NSPredicate *)predicate
                     sortDescriptors:(NSArray *)sortDescriptiors
              inManagedObjectContext:(NSManagedObjectContext *)context
{
    __block NSArray *fetchedObjects = nil;
    
    if (context == __mainManagedObjectContext
        || context == __privateManagedObjectContext) {
        [context performBlockAndWait:^{
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            [fetchRequest setEntity:entity];
            // Specify criteria for filtering which objects to fetch
            [fetchRequest setPredicate:predicate];
            // Specify how the fetched objects should be sorted
            [fetchRequest setSortDescriptors:sortDescriptiors];
            
            NSError *error = nil;
            fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil || error) {
                fetchedObjects = nil;
            }
        }];
    } else {
        DLog(@"error: fetching from unknown context")
    }
    
    return fetchedObjects;
}





#pragma mark - Fetch

- (NSArray *)getTodayWorkOrder
{
    NSArray * woList = nil;
    
    //    NSDate * currentDate = _timeStamp ? _timeStamp : [NSDate date];
    //    NSCalendar *calendar = [NSCalendar currentCalendar];
    //    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];
    //    //create a date with these components
    //    NSDate *startDate = [calendar dateFromComponents:components];
    //    [components setMonth:0];
    //    [components setDay:1]; //reset the other components
    //    [components setYear:0]; //reset the other components
    //    NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    
    NSDate *startDate = [AMUtilities todayBeginningDate];
    NSDate *endDate = [startDate dateByAddingTimeInterval:24*60*60];
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(estimatedTimeStart >= %@) AND (estimatedTimeStart < %@)  AND (userID = %@) AND ((status = 'In Progress') OR (status = 'Scheduled') OR (status = 'Checked Out'))", startDate, endDate,_selfId];
    //NSPredicate * filter = [NSPredicate predicateWithFormat:@"(status != 'Closed')  AND (userID = %@)",_selfId];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
}

- (NSArray *)getTodayCheckInWorkOrders
{
    NSArray * woList = nil;

    NSDate *startDate = [AMUtilities todayBeginningDate];
    NSDate *endDate = [startDate dateByAddingTimeInterval:24*60*60];
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(estimatedTimeStart >= %@) AND (estimatedTimeStart <= %@)  AND (userID = %@) AND (status = 'In Progress')", startDate, endDate,_selfId];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
}

- (NSArray *)getSelfOwnedTodayCheckInWorkOrders
{
    NSArray * woList = nil;
    
    NSDate *startDate = [AMUtilities todayBeginningDate];
    NSDate *endDate = [startDate dateByAddingTimeInterval:24*60*60];
    
    //BKK - 4/27/2016 added Checked Out to the criteria so that we cannot check in to more than one work order
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(estimatedTimeStart >= %@) AND (estimatedTimeStart <= %@)  AND (userID = %@) AND ((status = 'In Progress') OR (status = 'Checked Out')) AND (ownerID = %@)", startDate, endDate, _selfId, _selfId];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
}

- (NSArray *)getTodayWorkOrderIncludeClosed
{
    NSArray * woList = nil;
    
    //    NSDate * currentDate = _timeStamp ? _timeStamp : [NSDate date];
    //    NSCalendar *calendar = [NSCalendar currentCalendar];
    //    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];
    //    //create a date with these components
    //    NSDate *startDate = [calendar dateFromComponents:components];
    //    [components setMonth:0];
    //    [components setDay:1]; //reset the other components
    //    [components setYear:0]; //reset the other components
    //    NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    
    NSDate *startDate = [AMUtilities todayBeginningDate];
    NSDate *endDate = [startDate dateByAddingTimeInterval:24*60*60];
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(estimatedTimeStart >= %@) AND (estimatedTimeStart <= %@)  AND (userID = %@)", startDate, endDate,_selfId];
    //NSPredicate * filter = [NSPredicate predicateWithFormat:@"(status != 'Closed')  AND (userID = %@)",_selfId];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
}

- (NSArray *)getSelfOwnedWorkOrderInPastDays:(int)numberOfDays
{
    NSArray *array;
    
    NSDate *startDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:-(numberOfDays-1)*24*60*60];
    NSDate *endDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:24*60*60];
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:
                            @"(estimatedTimeStart >= %@) AND (estimatedTimeStart < %@) AND (status = 'Scheduled' OR status = 'In Progress') AND (ownerID = %@)"
                            " OR "
                            "(actualTimeEnd >= %@) AND (actualTimeEnd < %@) AND (status = 'Closed') AND (ownerID = %@)",
                            startDate, endDate, _selfId, startDate, endDate, _selfId];
    array = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    
    return array;
}

- (NSArray *)getSelfInvolvedWorkOrderInPastDays:(int)numberOfDays
{
//    numberOfDays = 1;
    NSArray *array;
    
    NSDate *startDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:-(numberOfDays-1)*24*60*60];
    NSDate *endDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:24*60*60];
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:
                            @"((estimatedTimeStart >= %@) AND (estimatedTimeStart < %@) AND (ownerID = %@))"
                            " OR "
                            "((actualTimeEnd >= %@) AND (actualTimeEnd < %@) AND (ownerID = %@))",
                            startDate, endDate, _selfId, startDate, endDate, _selfId];
    NSArray *eventList = [[AMEventDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    
    
    NSMutableArray *woMA = [NSMutableArray array];
    for (AMEvent *event in eventList) {
        AMWorkOrder *workOrder = [self getWorkOrderByWOID:event.woID];
        if (workOrder) {
            [woMA addObject:workOrder];
        }
        
    }
    array = woMA;
    
    return array;
}

- (NSArray *)getSelfWorkOrderListInPastDaysIncludeToday:(int)numberOfPastDays
{
    NSArray * woList = nil;
    
    //    NSDate * currentDate = _timeStamp ? _timeStamp : [NSDate date];
    //    NSCalendar * calendar = [NSCalendar currentCalendar];
    //    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];
    //    //create a date with these components
    //    NSDate * standardToday = [calendar dateFromComponents:components];
    //    [components setMonth:0];
    //    [components setDay:1]; //reset the other components
    //    [components setYear:0]; //reset the other components
    //    NSDate * endDate = [calendar dateByAddingComponents:components toDate:standardToday options:0];
    //    [components setMonth:0];
    //    [components setDay:-13]; //reset the other components
    //    [components setYear:0]; //reset the other components
    //    NSDate * startDate = [calendar dateByAddingComponents:components toDate:endDate options:0];

    
    NSDate *startDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:-(numberOfPastDays-1)*24*60*60];
    NSDate *endDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:24*60*60];
    
    NSPredicate * eventFilter = [NSPredicate predicateWithFormat:@"ownerID = %@",_selfId];
    NSArray *eventList = [[AMEventDBManager sharedInstance] getDataListByFilter:eventFilter fromDB:__mainManagedObjectContext];
    NSMutableArray *woMA = [NSMutableArray array];
    for (AMEvent *event in eventList) {
        AMWorkOrder *workOrder = [self getWorkOrderByWOID:event.woID];
        if ([workOrder.actualTimeEnd compare: startDate] == NSOrderedDescending
            && [workOrder.actualTimeEnd compare: endDate] == NSOrderedAscending
            && [workOrder.status isEqualToLocalizedString: @"Closed"])
        {
            [woMA addObject:workOrder];
        }
    }
    woList = woMA;
    
    return woList;
}

-(NSArray *)getSelfWorkOrderListInFutureDaysExcludeToday:(int)numberOfFutureDays
{
    NSArray * woList = nil;

    NSDate *startDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval: 24*60*60];
    NSDate *endDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:(numberOfFutureDays+1)*24*60*60];
    
    NSPredicate * eventFilter = [NSPredicate predicateWithFormat:@"ownerID = %@ AND (estimatedTimeStart >= %@) AND (estimatedTimeStart < %@)", _selfId, startDate, endDate];
    NSArray *eventList = [[AMEventDBManager sharedInstance] getDataListByFilter:eventFilter fromDB:__mainManagedObjectContext];
    
    NSMutableArray *woMA = [NSMutableArray array];
    for (AMEvent *event in eventList) {
        AMWorkOrder *workOrder = [self getWorkOrderByWOID:event.woID];
        if ([workOrder.status isEqualToLocalizedString: @"Scheduled"])
        {
            [woMA addObject:workOrder];
        }
    }
    woList = woMA;
    
    return woList;
}

- (NSArray *)getWorkOrderListAfterTodayBegin
{
    NSArray * woList = nil;
    
    NSDate *startDate = [AMUtilities todayBeginningDate];
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"estimatedTimeStart >= %@", startDate];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
}


- (NSArray *)getAccountPendingWorkOrderList:(NSString *)accountID
{
    NSArray * woList = nil;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(status = 'Queued') AND (accountID = %@)", accountID];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"posID" ascending:YES];
    woList = [[AMWODBManager sharedInstance] getWorkOrderWithPOSByFilter:filter sortArray:@[sortDescriptor] fromDB:__mainManagedObjectContext];
    
//    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
    
}

- (NSArray *)getPoSPendingWorkOrderList:(NSString *)posID
{
    NSArray * woList = nil;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(status = 'Queued') AND (posID = %@)", posID];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
    
}

- (NSArray *)getAllPendingWorkOrderList
{
    NSArray * woList = nil;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"status = 'Queued'"];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
    
}

- (NSArray *)getAllExceptPendingWorkOrderList
{
    NSArray * woList = nil;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"status != 'Queued'"];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
    
}

- (NSArray *)getCaseWorkOrderList:(NSString *)caseID
{
    NSArray * woList = nil;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"caseID = %@", caseID];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
}

- (NSArray *)getCaseOpenWorkOrderList:(NSString *)caseID
{
    NSArray * woList = nil;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(status != 'Closed') AND caseID = %@", caseID];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
}

- (NSArray *)getOpenFilterExchangeWorkOrdersByCaseId:(NSString *)caseID
{
    NSArray * woList = nil;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(status != 'Closed') AND (woType = 'Filter Exchange') AND caseID = %@", caseID];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
}


- (NSArray *)getAssetPast6MonthsRepairWorkOrderList:(NSString *)assetID
{
    NSArray * woList = nil;
    
//    NSDate * currentDate = [NSDate date];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    calendar.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
    
//    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];
//    //create a date with these components
//    [components setMonth:-6];
//    [components setDay:0]; //reset the other components
//    [components setYear:0]; //reset the other components
//    NSDate *endDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:24*60*60];
//    NSDate *startDate = [calendar dateByAddingComponents:components toDate:endDate options:0];
//    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(actualTimeEnd >= %@) AND (actualTimeEnd <= %@) AND (assetID = %@) AND (woType = 'Repair')", startDate, endDate, assetID];
    //Don't need to set actualTimeEnd in this query, as Salesforce is getting asset list for past 6 months, so just query the asset list with colse status and type is repair
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(status = 'Closed') AND (assetID = %@) AND (woType = 'Repair')", assetID];
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return woList;
}

- (NSNumber *)getPoSPast28DaysRepairWorkOrderNumber:(NSString *)posID
{
    NSArray * woList = nil;
    
    //    NSDate * currentDate = _timeStamp ? _timeStamp : [NSDate date];
    //    NSCalendar *calendar = [NSCalendar currentCalendar];
    //    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];
    //    //create a date with these components
    //    NSDate *endDate = [calendar dateFromComponents:components];
    //    [components setMonth:0];
    //    [components setDay:-28]; //reset the other components
    //    [components setYear:0]; //reset the other components
    //    NSDate *startDate = [calendar dateByAddingComponents:components toDate:endDate options:0];
    
    int numberOfDays = 28;
    
    NSDate *startDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:-(numberOfDays-1)*24*60*60];
    NSDate *endDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:24*60*60];
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(actualTimeEnd >= %@) AND (actualTimeEnd <= %@) AND (posID = %@) AND (woType = 'Repair')", startDate, endDate, posID];
    
    woList = [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    return [NSNumber numberWithInt:woList.count];
    
}

- (AMUser *)getUserInfoByUserID:(NSString *)userID
{
    //NSString * filter = [NSString stringWithFormat:@"userID = %@", userID];
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"userID = %@",userID];
    
    return [[AMUserDBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
}


- (AMWorkOrder *)getWorkOrderByWOID:(NSString *)woID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"woID = %@",woID];
    
    return [[AMWODBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getWorkOrderListByCaseID:(NSString *)caseID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"caseID = %@", caseID];
    
    return [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getEventListByWOID:(NSString *)woID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"woID = %@",woID];
    return [[AMEventDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getAllEventList
{
    return [[AMEventDBManager sharedInstance] getDataListByFilter:nil fromDB:__mainManagedObjectContext];
}

- (NSArray *)getEventListAfterTodayBegin
{
    NSArray *array = nil;
    
    NSDate *startDate = [AMUtilities todayBeginningDate];
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"estimatedTimeStart >= %@", startDate];
    array = [[AMEventDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    
    return array;
}

-(AMDBCustomerPrice *)getMaintainanceFeeByWOID:(NSString *)woID;
{
    AMWorkOrder *workOrder = [self getWorkOrderByWOID:woID];
    AMAsset *asset = [self getAssetInfoByID:workOrder.assetID];
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"productID = %@ AND posID = %@ AND productType = %@", asset.productID, workOrder.posID, @"Product"];
    
    NSArray *array = [self fetchDataArrayForEntity:NSStringFromClass([AMDBCustomerPrice class])
                                      byPredicates:filter
                                   sortDescriptors:nil
                            inManagedObjectContext:__mainManagedObjectContext];
    
    return [array firstObject];
}


-(AMEvent *)getSelfEventByWOID:(NSString *)woID
{
    AMEvent *event = nil;
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"woID = %@ AND ownerID = %@", woID, _selfId];
    event = [[AMEventDBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
    return event;
}

- (AMAccount *)getAccountInfoByID:(NSString *)accountID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"accountID = %@",accountID];
    return [[AMAccountDBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
}

- (AMPoS *)getPoSInfoByID:(NSString *)posID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"posID = %@",posID];
    return [[AMPoSDBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
}

- (AMCase *)getCaseInfoByID:(NSString *)caseID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"caseID = %@",caseID];
    return [[AMCaseDBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
}

- (AMAsset *)getAssetInfoByID:(NSString *)assetID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"assetID = %@",assetID];
    return [[AMAssetDBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
}

- (AMContact *)getContactInfoByID:(NSString *)contactID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"contactID = %@",contactID];
    return [[AMContactDBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
}

- (AMLocation *)getLocationInfoByID:(NSString *)locationID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"locationID = %@",locationID];
    return [[AMLocationDBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
}

- (AMParts *)getPartsInfoByID:(NSString *)partsID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"partID = %@",partsID];
    return [[AMPartsDBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
}

- (AMFilter *)getFilterInfoByID:(NSString *)filterID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"filterID = %@",filterID];
    return [[AMFilterDBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getAllInvoiceList
{
    return [[AMInvoiceDBManager sharedInstance] getDataListByFilter:nil fromDB:__mainManagedObjectContext];
}

- (NSArray *)getInvoiceListByWOID:(NSString *)woID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"woID = %@",woID];
    return [[AMInvoiceDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getInvoiceListByWOID:(NSString *)woID recordTypeName:(NSString *)recordTypeName
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"woID = %@ AND recordTypeName = %@",woID, recordTypeName];
    return [[AMInvoiceDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (AMBest *)getBestPointByWOID:(NSString *)woID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"woID = %@",woID];
    return [[AMBestDBManager sharedInstance] getDataByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getLocationListByAccountID:(NSString *)accountID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"accountID = %@",accountID];
    return [[AMLocationDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getContactListByPoSID:(NSString *)posID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"posID = %@",posID];
    return [[AMContactDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getFilterListByPoSID:(NSString *)posID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"posID = %@",posID];
    return [[AMFilterDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getPartsListByProductID:(NSString *)productID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"productID = %@",productID];
    return [[AMPartsDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getInvoiceListByWOIDList:(NSArray *)woIDList
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"woID IN %@",woIDList];
    return [[AMInvoiceDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getInvoiceListByCaseID:(NSString *)caseID
{
    NSArray *woList = [self getWorkOrderListByCaseID:caseID];
    NSMutableArray *woIDList = [NSMutableArray array];
    for (AMWorkOrder *workOrder in woList) {
        [woIDList addObject:workOrder.woID];
    }
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"woID IN %@",woIDList];
    return [[AMInvoiceDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getAssetListByPoSID:(NSString *)posID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"posID = %@",posID];
    return [[AMAssetDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getAssetRequestListByPoSID:(NSString *)posID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"posID = %@",posID];
    return [[AMAssetRequestDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getFilterUsedListByInvoiceID:(NSString *)invoiceID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"invoiceID = %@",invoiceID];
    return [[AMFilterUsedDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getPartsUsedListByInvoiceID:(NSString *)invoiceID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"invoiceID = %@",invoiceID];
    return [[AMPartsUsedDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getBestListByWOID:(NSString *)woID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"woID = %@",woID];
    return [[AMBestDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getCreatedLocation
{
//    NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdBy = %@",_selfId];
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"dataStatus = %@", @(EntityStatusCreated)];
    return [[AMLocationDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    
}

- (NSArray *)getCreatedEvent
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdBy = %@",_selfId];
    return [[AMEventDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    
}

- (NSArray *)getCreatedFilterUsed
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdBy = %@",_selfId];
    return [[AMFilterUsedDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    
}

- (NSArray *)getCreatedPartsUsed
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdBy = %@",_selfId];
    return [[AMPartsUsedDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    
}

- (NSArray *)getCreatedInvoices
{
    //TODO::Need check
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdBy = %@ AND invoiceNumber = nil",_selfId];
//     NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdBy = %@",_selfId];
    
    return [[AMInvoiceDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    
}

- (NSArray *)getCreatedAssetRequests
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdBy = %@",_selfId];
    return [[AMAssetRequestDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getCreatedWorkOrders
{
    NSArray *array;
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"dataStatus = %@", @(EntityStatusCreated)];
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBNewWorkOrder"
                                                     byPredicates:filter
                                                  sortDescriptors:nil
                                           inManagedObjectContext:__mainManagedObjectContext];
    return array;
    
}
- (NSArray *)getCreatedContacts
{
    NSArray *array;
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"dataStatus = %@", @(EntityStatusCreated)];
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBNewContact"
                                                     byPredicates:filter
                                                  sortDescriptors:nil
                                           inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

- (NSArray *)getCreatedCases
{
    NSArray *array;
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"dataStatus = %@", @(EntityStatusCreated)];
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBNewCase"
                                                     byPredicates:filter
                                                  sortDescriptors:nil
                                           inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

- (NSArray *)getCreatedCasesHistoryInRecentDays:(int)numberOfDays
{
    NSArray *array;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdDate >= %@",
                            [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:-(numberOfDays-1)*24*60*60]];
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBNewCase"
                                                     byPredicates:filter
                                                  sortDescriptors:nil
                                           inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

- (NSArray *)getCreatedWorkOrderHistory
{
    NSArray *array;
    int numberOfDays = 7;
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdDate >= %@",
                            [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:-(numberOfDays-1)*24*60*60]];
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBNewWorkOrder"
                                                     byPredicates:filter
                                                  sortDescriptors:nil
                                           inManagedObjectContext:__mainManagedObjectContext];
    return array;
}


- (NSArray *)getNewAddedAsset
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"assetID = nil"];
    return [[AMAssetDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
    
}


- (NSArray *)getModifiedWorkOrder
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"lastModifiedBy = %@",_selfId];
    return [[AMWODBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getModifiedAsset
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"lastModifiedBy = %@",_selfId];
    return [[AMAssetDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getModifiedInvoice
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"lastModifiedBy = %@",_selfId];
    return [[AMInvoiceDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getDeletedContacts
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"shouldDelete == 1"];
    return [[AMContactDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}
- (NSArray *)getModifiedContacts
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"lastModifiedBy = %@",_selfId];
    return [[AMContactDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}
- (NSArray *)getModifiedCase
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"lastModifiedBy = %@",_selfId];
    return [[AMCaseDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getModifiedLocation
{
//    NSPredicate * filter = [NSPredicate predicateWithFormat:@"lastModifiedBy = %@",_selfId];
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"dataStatus = %@", @(EntityStatusModified)];
    return [[AMLocationDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

- (NSArray *)getModifiedPoS
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"lastModifiedBy = %@",_selfId];
    return [[AMPoSDBManager sharedInstance] getDataListByFilter:filter fromDB:__mainManagedObjectContext];
}

-(NSArray *)getFilterListByWOID:(NSString *)woID
{
    AMWorkOrder *workOrder = [self getWorkOrderByWOID:woID];
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"posID = %@ AND productType = %@", workOrder.posID, @"Filters"];
    
    NSArray *array = [self fetchDataArrayForEntity:NSStringFromClass([AMDBCustomerPrice class])
                                      byPredicates:filter
                                   sortDescriptors:nil
                            inManagedObjectContext:__mainManagedObjectContext];
    
    return array;
}

-(NSArray *)getInvoiceCodeListByWOID:(NSString *)woID
{
    AMWorkOrder *workOrder = [self getWorkOrderByWOID:woID];

    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"posID = %@ AND productType = %@", workOrder.posID, @"Invoice Codes"];
    
    NSArray *array = [self fetchDataArrayForEntity:NSStringFromClass([AMDBCustomerPrice class])
                                      byPredicates:predicate
                                   sortDescriptors:nil
                            inManagedObjectContext:__mainManagedObjectContext];
    
    return array;
}

-(AMDBNewCase *)getNewCaseByFakeID:(NSString *)fakeID
{
    AMDBNewCase *newCase = nil;
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"fakeID = %@", fakeID];
    
    NSArray *array = [self fetchDataArrayForEntity:NSStringFromClass([AMDBNewCase class])
                                      byPredicates:filter
                                   sortDescriptors:nil
                            inManagedObjectContext:__mainManagedObjectContext];
    newCase = [array firstObject];
    return newCase;
}

-(AMDBNewWorkOrder *)getNewWorkOrderByFakeID:(NSString *)fakeID
{
    AMDBNewWorkOrder *newWorkOrder = nil;
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"fakeID = %@", fakeID];
    
    NSArray *array = [self fetchDataArrayForEntity:NSStringFromClass([AMDBNewWorkOrder class])
                                      byPredicates:filter
                                   sortDescriptors:nil
                            inManagedObjectContext:__mainManagedObjectContext];
    newWorkOrder = [array firstObject];
    return newWorkOrder;
}


-(NSArray *)getAllReportData;
{
    NSArray *array;
    
//    NSDate *startDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:-(numberOfDays-1)*24*60*60];
//    NSDate *endDate = [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:24*60*60];
    
//    NSPredicate * filter = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date < %@)",
//                            startDate, endDate];
    
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBReport"
                                                     byPredicates:nil
                                                  sortDescriptors:nil
                                           inManagedObjectContext:__mainManagedObjectContext];
    return array;
}


-(AMDBReport *)getReportByDate:(NSDate *)date
{
    AMDBReport *report = nil;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"date = %@", date];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBReport"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    report = array.firstObject;
    
    return report;
}

-(AMDBReport *)getReportByDate:(NSDate *)date andRecordType:(NSString *)recordType
{
    AMDBReport *report = nil;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"date = %@ AND recordType = %@", date, recordType];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBReport"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    report = array.firstObject;
    
    return report;
}

-(NSString *)getRecordTypeNameById:(NSString *)id forObject:(NSString *)object
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"id = %@ AND objectType = %@", id, object];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBRecordType"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    AMDBRecordType *recordType = array.firstObject;
    return recordType.name;
}

-(NSString *)getRecordTypeIdByName:(NSString *)name forObject:(NSString *)object
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"name = %@ AND objectType = %@", name, object];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBRecordType"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    AMDBRecordType *recordType = array.firstObject;
    return recordType.id;
}

-(NSArray *)getRecordTypeListForObjectType:(NSString *)objectType
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"objectType = %@", objectType];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBRecordType"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

-(AMDBRecordType *)getRecordTypeByID:(NSString *)recordTypeID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"id = %@", recordTypeID];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBRecordType"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array.firstObject;
}


-(AMDBAttachment *)getAttachmentById:(NSString *)id;
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"id = %@ OR fakeID = %@", id, id];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBAttachment"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array.firstObject;
}

-(NSArray *)getUnfetchedAttachments
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"localURL = NULL"];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBAttachment"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

-(NSArray *)getAttachmentsByWOID:(NSString *)woID;
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"parentId = %@ AND dataStatus != %@", woID, @(EntityStatusDeleted)];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBAttachment"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

-(NSArray *)getLocalAttachmentsByWOID:(NSString *)woID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"parentId = %@ AND dataStatus != %@ AND dataStatus != %@", woID, @(EntityStatusFromSalesforce), @(EntityStatusDeleted)];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBAttachment"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

-(NSArray *)getRemoteAttachmentsByWOID:(NSString *)woID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"parentId = %@ AND dataStatus = %@ AND dataStatus != %@", woID, @(EntityStatusFromSalesforce), @(EntityStatusDeleted)];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBAttachment"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

-(NSArray *)getSelfCreatedAttachmentsByWOID:(NSString *)woID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"parentId = %@ AND createdById = %@ AND dataStatus != %@", woID, _selfId, @(EntityStatusDeleted)];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBAttachment"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

-(NSArray *)getOtherCreatedAttachmentsByWOID:(NSString *)woID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"parentId = %@ AND createdById != %@ AND dataStatus != %@", woID, _selfId, @(EntityStatusDeleted)];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBAttachment"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

-(NSArray *)getAttachmentsForUpload
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"dataStatus = %@", @(EntityStatusCreated)];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBAttachment"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

-(NSArray *)getAttachmentsForDeletion
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"dataStatus = %@", @(EntityStatusDeleted)];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBAttachment"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

-(AMDBCustomerPrice *)getCustomerPriceByID:(NSString *)customerPriceID
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"customerPriceID = %@", customerPriceID];
    NSArray *array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBCustomerPrice"
                                                              byPredicates:filter
                                                           sortDescriptors:nil
                                                    inManagedObjectContext:__mainManagedObjectContext];
    return array.firstObject;
}


- (NSArray *)getCreatedLeadsForUpload
{
    NSArray *array;
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"dataStatus = %@", @(EntityStatusCreated)];
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBNewLead"
                                                     byPredicates:filter
                                                  sortDescriptors:nil
                                           inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

- (NSArray *)getCreatedLeadsHistoryInRecentDays:(int)numberOfDays
{
    NSArray *array;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdDate >= %@",
                            [[AMUtilities todayBeginningDate] dateByAddingTimeInterval:-(numberOfDays-1)*24*60*60]];
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBNewLead"
                                                     byPredicates:filter
                                                  sortDescriptors:nil
                                           inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

-(AMDBPicklist *)getPicklistWithObjectName:(NSString *)objName
                                 fieldName:(NSString *)fieldName
                                fieldValue:(NSString *)fieldValue
{
    NSArray *array;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"objectName = %@ AND fieldName = %@ AND fieldValue = %@", objName, fieldName, fieldValue];
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBPicklist"
                                                     byPredicates:filter
                                                  sortDescriptors:nil
                                           inManagedObjectContext:__mainManagedObjectContext];
    return array.firstObject;
}

-(NSArray *)getPicklistOfComplaintCodeInWorkOrder
{
    NSArray *array;
    
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"objectName = %@ AND fieldName = %@", @"Work_Order__c", @"Complaint_Code__c"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fieldValue" ascending:YES];
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBPicklist"
                                                     byPredicates:filter
                                                  sortDescriptors:@[sortDescriptor]
                                           inManagedObjectContext:__mainManagedObjectContext];
    return array;
}

- (NSArray *)getAllAccountList
{
    return [[AMAccountDBManager sharedInstance] getDataListByFilter:nil fromDB:__mainManagedObjectContext];
}

- (NSArray *)getAllAssetList
{
    return [[AMAssetDBManager sharedInstance] getDataListByFilter:nil fromDB:__mainManagedObjectContext];
}

- (NSArray *)getAllAttachmentList
{
    return [self fetchDataArrayForEntity:@"AMDBAttachment"
                            byPredicates:nil
                         sortDescriptors:nil
                  inManagedObjectContext:__mainManagedObjectContext];
}

- (NSArray *)getAllCaseList
{
    return [[AMCaseDBManager sharedInstance] getDataListByFilter:nil fromDB:__mainManagedObjectContext];
}

- (NSArray *)getAllContactList
{
    return [[AMContactDBManager sharedInstance] getDataListByFilter:nil fromDB:__mainManagedObjectContext];
}

- (NSArray *)getAllCustomerPriceList
{
    return [self fetchDataArrayForEntity:@"AMDBCustomerPrice"
                            byPredicates:nil
                         sortDescriptors:nil
                  inManagedObjectContext:__mainManagedObjectContext];
}

- (NSArray *)getAllLocationList
{
    return [[AMLocationDBManager sharedInstance] getDataListByFilter:nil fromDB:__mainManagedObjectContext];
}

- (NSArray *)getAllPartsList
{
    return [[AMPartsDBManager sharedInstance] getDataListByFilter:nil fromDB:__mainManagedObjectContext];
}

- (NSArray *)getAllPoSList
{
    return [[AMPoSDBManager sharedInstance] getDataListByFilter:nil fromDB:__mainManagedObjectContext];
}

- (NSArray *)getAllWorkOrderList
{
    return [[AMWODBManager sharedInstance] getDataListByFilter:nil fromDB:__mainManagedObjectContext];
}

#pragma mark - Create From User

-(AMDBNewCase *)createNewCaseInDB
{
    AMDBNewCase *entity = [AMDBNewCase newEntityInManagedObjectContext:__mainManagedObjectContext];
    
    return entity;
}

-(void)createNewContactInDBWithSetupBlock:(void (^)(AMDBNewContact *))setupBlock completion:(AMDBOperationCompletionBlock)completionBlock
{
    [__privateManagedObjectContext performBlock:^{
        AMDBNewContact *entity = [AMDBNewContact newEntityInManagedObjectContext:__privateManagedObjectContext];
        
        if (setupBlock) {
            setupBlock(entity);
        }
        
        entity.dataStatus = @(EntityStatusCreated);
        
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
        
    }];
}

-(void)createNewCaseInDBWithSetupBlock:(void(^)(AMDBNewCase *newCase))setupBlock
                            completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    
    [__privateManagedObjectContext performBlock:^{
        AMDBNewCase *entity = [AMDBNewCase newEntityInManagedObjectContext:__privateManagedObjectContext];
        
        if (setupBlock) {
            setupBlock(entity);
        }
        
        entity.dataStatus = @(EntityStatusCreated);
        
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
    
    //    });
}

-(void)createNewWorkOrderInDBWithSetupBlock:(void(^)(AMDBNewWorkOrder *newWorkOrder))setupBlock
                                 completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        
        AMDBNewWorkOrder *entity = [AMDBNewWorkOrder newEntityInManagedObjectContext:__privateManagedObjectContext];
        
        if (setupBlock) {
            setupBlock(entity);
        }
        
        entity.dataStatus = @(EntityStatusCreated);
        
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
}


-(void)createNewWorkOrderInDBWithAMWorkOrder:(AMWorkOrder *)workOrder
                        additionalSetupBlock:(void(^)(AMDBNewWorkOrder *newWorkOrder))setupBlock
                                  completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        
        AMDBNewWorkOrder *entity = [AMDBNewWorkOrder newEntityWithAMWorkOrder:workOrder InManagedObjectContext:__privateManagedObjectContext];
        
        if (setupBlock) {
            setupBlock(entity);
        }
        
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
    
}


-(void)createNewAttachmentInDBWithSetupBlock:(void(^)(AMDBAttachment *newAttachment))block
                                  completion:(AMDBOperationCompletionBlock)completionBlock;
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        
        [AMDBAttachment insertNewEntityWithSetupBlock:block inManagedObjectContext:__privateManagedObjectContext];
        
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
}

-(void)createNewLeadInDBWithSetupBlock:(void(^)(AMDBNewLead *newLead))block
                                  completion:(AMDBOperationCompletionBlock)completionBlock;
{

    [__privateManagedObjectContext performBlock:^{
        [AMDBNewLead insertNewEntityWithSetupBlock:block inManagedObjectContext:__privateManagedObjectContext];
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
}

-(AMDBReport *)createNewReportInDB
{
    __block AMDBReport *report = nil;
    
    [__privateManagedObjectContext performBlockAndWait:^{
        report = [AMDBReport createNewEntityInManagedObjectContext:__privateManagedObjectContext];
        
        NSError *error;
        [__privateManagedObjectContext save:&error];
    }];
    
    return report;
}


#pragma mark - Create From Salesforce

-(void)saveAsyncReportDictionaryFromSalesforce:(NSDictionary *)dictionary completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        NSArray *allReports = [self getAllReportData];
        for (AMDBReport *report in allReports) {
            AMDBReport *privateObj = (AMDBReport *)[__privateManagedObjectContext objectWithID:report.objectID];
            [__privateManagedObjectContext deleteObject:privateObj];
        }
        
        [AMDBReport insertNewEntitiesWithSFResponse:dictionary InManagedObjectContext:__privateManagedObjectContext];
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
}


-(void)saveAsyncRecordTypeArrayFromSalesforce:(NSArray *)array completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [AMDBRecordType insertNewEntitiesWithSFResponse:array InManagedObjectContext: __privateManagedObjectContext];
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
}

-(void)saveAsyncAttachmentArrayFromSalesforce:(NSArray *)array completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [AMDBAttachment insertNewEntitiesWithSFResponse:array InManagedObjectContext:__privateManagedObjectContext];
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
}

-(void)saveAsyncCustomerPriceArray:(NSArray *)array completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        for (NSDictionary *dict in array) {
            [AMDBCustomerPrice newEntityWithSFDictionary:dict InManagedObjectContext:__privateManagedObjectContext];
        }
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
}

-(void)saveAsyncPicklistDictionaryFromSalesforce:(NSDictionary *)dictionary completion:(AMDBOperationCompletionBlock)completionBlock
{
    [__privateManagedObjectContext performBlock:^{
        [AMDBPicklist insertNewEntitiesWithSFResponse:dictionary inManagedObjectContext:__privateManagedObjectContext];
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
}

#pragma mark - Edit

-(void)saveManagedObject:(NSManagedObject *)object completion:(AMDBOperationCompletionBlock)completionBlock
{
    NSManagedObjectContext *moc = object.managedObjectContext;
    
    if (moc == __mainManagedObjectContext
        || moc == __privateManagedObjectContext) {
        
        [moc performBlockAndWait:^{
            NSError *error;
            [moc save:&error];
            completionBlock(AM_DBOPR_SAVE, error);
        }];
        
    } else {
        NSError *error = [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey:MyLocal(@"db save context fault")}];
        completionBlock(AM_DBOPR_SAVE, error);
    }
}



- (void)saveAsyncWorkOrderList:(NSArray *)woList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    
    [__privateManagedObjectContext performBlock:^{
        [[AMWODBManager sharedInstance] saveDataList:woList ToDB:__privateManagedObjectContext checkExist:check];
        
        completionBlock(AM_DBOPR_SAVEWOLIST,nil);
    }];
    
    //    });
}

- (void)saveAsyncInitialSyncLoadList:(NSDictionary *)initialLoad checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    [__privateManagedObjectContext performBlock:^{
        
        NSError * error = nil;
        if (initialLoad && [initialLoad allKeys].count) {
            NSArray * woList = [initialLoad objectForKey:@"AMWorkOrder"];
            NSArray * accountList = [initialLoad objectForKey:@"AMAccount"];
            NSArray * assetList = [initialLoad objectForKey:@"AMAsset"];
            NSArray * caseList = [initialLoad objectForKey:@"AMCase"];
            NSArray * contactList = [initialLoad objectForKey:@"AMContact"];
            NSArray * invoiceList = [initialLoad objectForKey:@"AMInvoice"];
            NSArray * posList = [initialLoad objectForKey:@"AMPoS"];
            NSArray * partsList = [initialLoad objectForKey:@"AMParts"];
            NSArray * filterList = [initialLoad objectForKey:@"AMFilter"];
            NSArray * locationList = [initialLoad objectForKey:@"AMLocation"];
            NSArray * eventList = [initialLoad objectForKey:@"AMEvent"];

            //            NSManagedObjectContext *tmpContext = [self managedObjectContext];
            NSManagedObjectContext *tmpContext = __privateManagedObjectContext;
            
            if (woList && woList.count) {//account
                [[AMWODBManager sharedInstance] memSaveDataList:woList ToDB:tmpContext checkExist:YES];
            }
            if (accountList && accountList.count) {//account
                [[AMAccountDBManager sharedInstance] memSaveDataList:accountList ToDB:tmpContext checkExist:YES];
            }
            
            if (assetList && assetList.count) {//asset
                [[AMAssetDBManager sharedInstance] memSaveDataList:assetList ToDB:tmpContext checkExist:YES];
            }
            
            if (caseList && caseList.count) {//case
                [[AMCaseDBManager sharedInstance] memSaveDataList:caseList ToDB:tmpContext checkExist:YES];
            }
            
            if (contactList && contactList.count) {//contact
                [[AMContactDBManager sharedInstance] memSaveDataList:contactList ToDB:tmpContext checkExist:YES];
            }
            
            if (invoiceList && invoiceList.count) {//invoice
                [[AMInvoiceDBManager sharedInstance] memSaveDataList:invoiceList ToDB:tmpContext checkExist:YES];
            }
            
            if (posList && posList.count) {//pos
                [[AMPoSDBManager sharedInstance] memSaveDataList:posList ToDB:tmpContext checkExist:YES];
            }
            
            if (partsList && partsList.count) {//parts
                [[AMPartsDBManager sharedInstance] memSaveDataList:partsList ToDB:tmpContext checkExist:YES];
            }
            
            if (filterList && filterList.count) {//filter
                [[AMFilterDBManager sharedInstance] memSaveDataList:filterList ToDB:tmpContext checkExist:YES];
            }
            
            if (locationList && locationList.count) {//location
                [[AMLocationDBManager sharedInstance] memSaveDataList:locationList ToDB:tmpContext checkExist:YES];
            }
            if (eventList.count) {
                [[AMEventDBManager sharedInstance] memSaveDataList:eventList ToDB:tmpContext checkExist:YES];
            }
            
            [tmpContext save:&error];
            DLog(@"saveAsyncInitialLoadList error:%@",error);
        }
        
        completionBlock(AM_DBOPR_SAVEBINITIALLOAD,error);
    }];
    //    });
}

//- (void)saveSyncWorkOrderList:(NSArray *)woList checkExist:(BOOL)check
//{
//    [[AMWODBManager sharedInstance] saveDataList:woList ToDB:__mainManagedObjectContext checkExist:check];
//
//}



- (void)updateUser:(NSString *)userID timeStamp:(NSDate *)timeStamp
{
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"userID = %@",userID];
    
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        
        [[AMUserDBManager sharedInstance] updateUser:filter timeStamp:timeStamp ToDB:__privateManagedObjectContext];
    }];
}

- (void)saveAsyncUserList:(NSArray *)userList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    
    [__privateManagedObjectContext performBlock:^{
        
        [[AMUserDBManager sharedInstance] saveDataList:userList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEUSERLIST,nil);
    }];
    //    });
}

- (void)saveAsyncEventList:(NSArray *)eventList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        
        [[AMEventDBManager sharedInstance] saveDataList:eventList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEEVENTLIST,nil);
    }];
}

- (void)saveAsyncAccountList:(NSArray *)accountList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMAccountDBManager sharedInstance] saveDataList:accountList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEACCOUNTLIST,nil);
    }];
}

- (void)saveAsyncContactList:(NSArray *)contactList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMContactDBManager sharedInstance] saveDataList:contactList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVECONTACTLIST,nil);
    }];
}

- (void)saveAsyncPoSList:(NSArray *)posList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMPoSDBManager sharedInstance] saveDataList:posList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEPOSLIST,nil);
    }];
}

- (void)saveAsyncAssetList:(NSArray *)assetList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMAssetDBManager sharedInstance] saveDataList:assetList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEASSETLIST,nil);
    }];
}

- (void)saveAsyncCaseList:(NSArray *)caseList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMCaseDBManager sharedInstance] saveDataList:caseList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVECASELIST,nil);
    }];
}

- (void)saveAsyncLocationList:(NSArray *)locationList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMLocationDBManager sharedInstance] saveDataList:locationList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVELOCATIONLIST,nil);
    }];
}

- (void)saveAsyncFilterList:(NSArray *)filterList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMFilterDBManager sharedInstance] saveDataList:filterList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEFILTERLIST,nil);
    }];
}

- (void)saveAsyncPartsList:(NSArray *)partsList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMPartsDBManager sharedInstance] saveDataList:partsList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEPARTSLIST,nil);
    }];
}

- (void)saveAsyncInvoiceList:(NSArray *)invoiceList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMInvoiceDBManager sharedInstance] saveDataList:invoiceList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEACCOUNTLIST,nil);
    }];
}

- (void)saveAsyncAssetRequestList:(NSArray *)assetReqList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMAssetRequestDBManager sharedInstance] saveDataList:assetReqList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEACCOUNTLIST,nil);
    }];
}

- (void)saveAsyncFilterUsedList:(NSArray *)filterList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMFilterUsedDBManager sharedInstance] saveDataList:filterList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEFILTERUSEDLIST,nil);
    }];
}

- (void)saveAsyncPartsUsedList:(NSArray *)partsList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMPartsUsedDBManager sharedInstance] saveDataList:partsList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEPARTSUSEDLIST,nil);
    }];
    
}
- (void)saveAsyncBestList:(NSArray *)bestList checkExist:(BOOL)check completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        [[AMBestDBManager sharedInstance] saveDataList:bestList ToDB:__privateManagedObjectContext checkExist:check];
        completionBlock(AM_DBOPR_SAVEBESTPOINTLIST,nil);
    }];
}


- (void)updateAddedAssetWithList:(NSDictionary *)idMap completion:(AMDBOperationCompletionBlock)completionBlock
{
    
}

- (void)updateAddLocationWithIdMap:(NSDictionary *)idMap completion:(AMDBOperationCompletionBlock)completionBlock
{
    /*NSMutableArray * fakeIDs = [NSMutableArray array];
     NSMutableArray * validIDs = [NSMutableArray array];
     
     NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"fakeId" ascending:NO];
     NSArray *descriptors = [NSArray arrayWithObject: descriptor];
     
     NSArray *reverseOrder = [idMap sortedArrayUsingDescriptors:descriptors];
     
     for (NSDictionary * map in reverseOrder) {
     [fakeIDs addObject:[map objectForKey:@"fakeId"]];
     [validIDs addObject:[map objectForKey:@"Id"]];
     }*/
    
    //    dispatch_async(_dbQeue, ^{
    [__privateManagedObjectContext performBlock:^{
        NSError * error = nil;
        if (idMap && [idMap allKeys].count) {
            //            NSManagedObjectContext *tmpContext = [self managedObjectContext];
            NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdBy = %@",_selfId];
            [[AMLocationDBManager sharedInstance] memReplaceFieldsByFilter:filter withFields:idMap fromDB:__privateManagedObjectContext];
            filter = [NSPredicate predicateWithFormat:@"locationID IN %@",[idMap allKeys]];
            [[AMAssetDBManager sharedInstance] memReplaceFieldsByFilter:filter withFields:idMap fromDB:__privateManagedObjectContext];
            /*NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"locationID" ascending:NO];
             NSArray *descriptors = [NSArray arrayWithObject: descriptor];
             
             NSArray *reverseOrder = [locations sortedArrayUsingDescriptors:descriptors];
             
             NSInteger loIndex = 0;
             for (NSInteger index1 = 0; index1 < fakeIDs.count; index1 ++) {
             for (NSInteger index2 = loIndex; index2 < reverseOrder.count; index2 ++) {
             AMLocation * lo = [reverseOrder objectAtIndex:index2];
             if ([lo.locationID isEqualToString:[fakeIDs objectAtIndex:index1]]) {
             lo.locationID = [validIDs objectAtIndex:index1];
             loIndex = index2;
             break;
             }
             }
             }*/
            
            
            [__privateManagedObjectContext save:&error];
            DLog(@"updateAddLocationWithIdMap error:%@",error);
        }
        
        completionBlock(AM_DBOPR_UPDATENEWOBJECTS,error);
    }];
}

- (void)updateAddObjectsWithIdMap:(NSDictionary *)idMap completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    [__privateManagedObjectContext performBlock:^{
        NSError * error = nil;
        if (idMap && [idMap allKeys].count) {
            NSDictionary * locationIdMap = [idMap objectForKey:@"AMLocation"];
            NSDictionary * invoiceIdMap = [idMap objectForKey:@"AMInvoice"];
            NSDictionary * assetReqIdMap = [idMap objectForKey:@"AMAssetRequest"];
            //            NSDictionary * fuIdMap = [idMap objectForKey:@"AMFilterUsed"];
            //            NSDictionary * puIdMap = [idMap objectForKey:@"AMPartsUsed"];
            NSPredicate * filter = [NSPredicate predicateWithFormat:@"createdBy = %@",_selfId];
            //            NSManagedObjectContext *tmpContext = [self managedObjectContext];
            
            if (locationIdMap) {
                filter = [NSPredicate predicateWithFormat:@"dataStatus = %@", @(EntityStatusCreated)];
                [[AMLocationDBManager sharedInstance] memReplaceFieldsByFilter:filter withFields:locationIdMap fromDB:__privateManagedObjectContext];
                filter = [NSPredicate predicateWithFormat:@"locationID IN %@",[locationIdMap allKeys]];
                [[AMAssetDBManager sharedInstance] memReplaceFieldsByFilter:filter withFields:locationIdMap fromDB:__privateManagedObjectContext];
                [[AMAssetRequestDBManager sharedInstance] memReplaceFieldsByFilter:filter withFields:locationIdMap fromDB:__privateManagedObjectContext];
                filter = [NSPredicate predicateWithFormat:@"toLocationID IN %@",[locationIdMap allKeys]];
                [[AMWODBManager sharedInstance] memReplaceFieldsByFilter:filter withFields:locationIdMap fromDB:__privateManagedObjectContext];

            }
            filter = [NSPredicate predicateWithFormat:@"createdBy = %@",_selfId];
            if (invoiceIdMap) {
                [[AMInvoiceDBManager sharedInstance] memReplaceFieldsByFilter:filter withFields:invoiceIdMap fromDB:__privateManagedObjectContext];
            }
            if (assetReqIdMap) {
                [[AMAssetRequestDBManager sharedInstance] memReplaceFieldsByFilter:filter withFields:assetReqIdMap fromDB:__privateManagedObjectContext];
            }
            
            //            if (fuIdMap) {
            //                [[AMFilterUsedDBManager sharedInstance] memReplaceFieldsByFilter:filter withFields:fuIdMap fromDB:__seriaManagedObjectContext];
            //            }
            //            if (puIdMap) {
            //                [[AMPartsUsedDBManager sharedInstance] memReplaceFieldsByFilter:filter withFields:puIdMap fromDB:__seriaManagedObjectContext];
            //            }
            
            
            
            [__privateManagedObjectContext save:&error];
            DLog(@"updateAddObjectWithIdMap error:%@",error);
        }
        
        completionBlock(AM_DBOPR_UPDATENEWOBJECTS,error);
    }];
}


- (void)updateLocalModifiedContactObjectsToDone:(NSDictionary *)modifiedObjects completion:(AMDBOperationCompletionBlock)completionBlock
{
    [__privateManagedObjectContext performBlock:^{
        NSError * error = nil;
        if (modifiedObjects && [modifiedObjects allKeys].count) {
            NSArray * deletedContactsList = [modifiedObjects objectForKey:@"AMContact"];
            
            NSManagedObjectContext *tmpContext = __privateManagedObjectContext;

            
            
            if (deletedContactsList) {
                NSMutableArray * contactIDs = [NSMutableArray array];
                for (AMContact * contact in deletedContactsList) {
                    if (contact.shouldDelete) {
                        [contactIDs addObject:contact.contactID];
                    }
                }
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"contactID IN %@",contactIDs];

                
                filter = [NSPredicate predicateWithFormat:@"contactID IN %@ AND shouldDelete ==1", contactIDs];
                [[AMContactDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            
            [tmpContext save:&error];
            DLog(@"updateLocalModifiedObjectsToDone error:%@",error);
            
            
        }
        completionBlock(AM_DBOPR_UPDATEMODIFIEDTODONE,error);
    }];

}
- (void)updateLocalModifiedObjectsToDone:(NSDictionary *)modifiedObjects completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    [__privateManagedObjectContext performBlock:^{
        NSError * error = nil;
        if (modifiedObjects && [modifiedObjects allKeys].count) {
            NSArray * woList = [modifiedObjects objectForKey:@"AMWorkOrder"];
            NSArray * assetList = [modifiedObjects objectForKey:@"AMAsset"];
            NSArray * locationList = [modifiedObjects objectForKey:@"AMLocation"];
            NSArray * invoiceList = [modifiedObjects objectForKey:@"AMInvoice"];
            NSArray * posList = [modifiedObjects objectForKey:@"AMPoS"];
            NSArray * updatedContactsList = [modifiedObjects objectForKey:@"AMContact"];
            NSArray * newContactsList = [modifiedObjects objectForKey:@"AMNewContact"];
            //            NSManagedObjectContext *tmpContext = [self managedObjectContext];
            
            NSManagedObjectContext *tmpContext = __privateManagedObjectContext;
            if (woList) {
                NSMutableArray * woIDs = [NSMutableArray array];
                for (AMWorkOrder * wo in woList) {
                    [woIDs addObject:wo.woID];
                }
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"woID IN %@",woIDs];
                [[AMWODBManager sharedInstance] memReplaceFields:@"lastModifiedBy" ByFilter:filter withValue:nil fromDB:tmpContext];
            }
            if (assetList) {
                NSMutableArray * assetIDs = [NSMutableArray array];
                for (AMAsset * asset in assetList) {
                    [assetIDs addObject:asset.assetID];
                }
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"assetID IN %@",assetIDs];
                [[AMAssetDBManager sharedInstance] memReplaceFields:@"lastModifiedBy" ByFilter:filter withValue:nil fromDB:tmpContext];
            }
            if (locationList) {
                NSMutableArray * locationIDs = [NSMutableArray array];
                for (AMLocation * location in locationList) {
                    [locationIDs addObject:location.locationID];
                }
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"locationID IN %@",locationIDs];
                [[AMLocationDBManager sharedInstance] memReplaceFields:@"lastModifiedBy" ByFilter:filter withValue:nil fromDB:tmpContext];
            }
            if (invoiceList) {
                NSMutableArray * invoiceIDs = [NSMutableArray array];
                for (AMInvoice * invoice in invoiceList) {
                    [invoiceIDs addObject:invoice.invoiceID];
                }
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"invoiceID IN %@",invoiceIDs];
                [[AMInvoiceDBManager sharedInstance] memReplaceFields:@"lastModifiedBy" ByFilter:filter withValue:nil fromDB:tmpContext];
            }
            if (posList) {
                NSMutableArray * posIDs = [NSMutableArray array];
                for (AMPoS * pos in posList) {
                    [posIDs addObject:pos.posID];
                }
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"posID IN %@",posIDs];
                [[AMPoSDBManager sharedInstance] memReplaceFields:@"lastModifiedBy" ByFilter:filter withValue:nil fromDB:tmpContext];
            }
            if (newContactsList) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"AMDBNewContact" inManagedObjectContext:tmpContext];
                
                // Optionally add an NSPredicate if you only want to delete some of the objects.
                
                [fetchRequest setEntity:entity];
                
                NSArray *myObjectsToDelete = [tmpContext executeFetchRequest:fetchRequest error:nil];
                
                for (AMDBNewContact *objectToDelete in myObjectsToDelete) {
                    [tmpContext deleteObject:objectToDelete];
                }
            }
            
            if (updatedContactsList) {
                NSMutableArray * contactIDs = [NSMutableArray array];
                NSMutableArray *deletedContactIDs = [NSMutableArray array];
                for (AMContact * contact in updatedContactsList) {
                    [contactIDs addObject:contact.contactID];
                    if (contact.shouldDelete) {
                        [deletedContactIDs addObject:contact.contactID];
                    }
                }
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"contactID IN %@",contactIDs];
                [[AMContactDBManager sharedInstance] memReplaceFields:@"lastModifiedDate" ByFilter:filter withValue:nil fromDB:tmpContext];

//                filter = [NSPredicate predicateWithFormat:@"contactID IN %@ AND shouldDelete ==1", deletedContactIDs];
//                
//                [[AMContactDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            
            [tmpContext save:&error];
            DLog(@"updateLocalModifiedObjectsToDone error:%@",error);
            
            
        }
        completionBlock(AM_DBOPR_UPDATEMODIFIEDTODONE,error);
    }];
}

-(void)updateAttachmentWithID:(NSString *)attachmentID
                   setupBlock:(void(^)(AMDBAttachment *attachment))setupBlock
                   completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
    [__privateManagedObjectContext performBlock:^{
        
        AMDBAttachment *attachmentMain = [[AMDBManager sharedInstance] getAttachmentById:attachmentID];
        AMDBAttachment *attachment = (AMDBAttachment *)[__privateManagedObjectContext objectWithID:attachmentMain.objectID];
        setupBlock(attachment);
        
        NSError *error;
        [__privateManagedObjectContext save:&error];
        completionBlock(AM_DBOPR_SAVE, error);
    }];
}

-(void)moveWorkOrderToToday:(AMWorkOrder *)workOrder completion:(AMDBOperationCompletionBlock)completionBlock
{
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    calendar.timeZone = [[AMLogicCore sharedInstance] timeZoneOnSalesforce];
//    
//    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:[AMUtilities todayBeginningDate] toDate:workOrder.estimatedTimeStart options:0];
//    workOrder.estimatedTimeStart = [workOrder.estimatedTimeStart dateByAddingDays:-[components day]];
//    workOrder.estimatedTimeEnd = [workOrder.estimatedTimeStart dateByAddingDays:-[components day]];
    
    if (workOrder.estimatedTimeEnd) {
        NSTimeInterval duration = [workOrder.estimatedTimeEnd timeIntervalSinceDate:workOrder.estimatedTimeStart];
        workOrder.estimatedTimeEnd = [[NSDate date] dateByAddingTimeInterval:duration];
    }
    workOrder.estimatedTimeStart = [NSDate date];

    for (AMEvent * event in workOrder.eventList) {
        if ([event.ownerID isEqualToString:workOrder.ownerID]) {
            event.estimatedTimeStart = workOrder.estimatedTimeStart;
            event.estimatedTimeEnd = workOrder.estimatedTimeEnd;
            break;
        }
    }
    
    [self saveAsyncWorkOrderList:@[workOrder] checkExist:YES completion:completionBlock];
}

-(void)updateCaseTotalInvoicePriceByCaseID:(NSString *)caseID
                            withCompletion:(AMDBOperationCompletionBlock)completionBlock
{
    NSArray *invoiceList = [self getInvoiceListByCaseID:caseID];
    AMCase *aCase = [self getCaseInfoByID:caseID];
    aCase.estimatedTotalPrice = [invoiceList valueForKeyPath:@"@sum.price"];
    aCase.lastModifiedBy = _selfId;
    if (aCase) {
        [self saveAsyncCaseList:@[aCase] checkExist:YES completion:completionBlock];
    }
}


-(void)updateCaseTotalInvoicePriceWithCompletion:(AMDBOperationCompletionBlock)completionBlock;
{
    NSArray *invoiceList = [self getAllInvoiceList];
    if (!invoiceList.count) {
        NSError *error = [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"no invoice, so no case updated")}];
        completionBlock(AM_DBOPR_SAVE, error);
        return;
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"caseId" ascending:YES];
    NSArray *sortedInvoiceList = [invoiceList sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSMutableArray *modifiedCaseList = [NSMutableArray array];
    
    for (AMInvoice *invoice in sortedInvoiceList) {
        AMCase *caseObj = modifiedCaseList.lastObject;
        
        if ([invoice.caseId isEqualToString:caseObj.caseID]) {
            caseObj.estimatedTotalPrice = @(caseObj.estimatedTotalPrice.floatValue + invoice.price.floatValue);
        } else {
            AMCase *caseObj = [self getCaseInfoByID:invoice.caseId];
            //TODO::fasfsfefqwr
            if (caseObj) {
                [modifiedCaseList addObject:caseObj];
                caseObj.estimatedTotalPrice = invoice.price;
                caseObj.lastModifiedBy = _selfId;
            }
        }
    }
    
    [self saveAsyncCaseList:modifiedCaseList checkExist:YES completion:completionBlock];
}


#pragma mark - Delete
- (void)clearAllData:(AMDBOperationCompletionBlock)completionBlock
{
    
    [__privateManagedObjectContext performBlock:^{
        
        //        NSManagedObjectContext *tmpContext = [self managedObjectContext];
        NSManagedObjectContext *tmpContext = __privateManagedObjectContext;
        [[AMWODBManager sharedInstance] memClearAllData:tmpContext];
        [[AMUserDBManager sharedInstance] memClearAllData:tmpContext];
        [[AMEventDBManager sharedInstance] memClearAllData:tmpContext];
        [[AMAccountDBManager sharedInstance] memClearAllData:tmpContext];
        [[AMContactDBManager sharedInstance] memClearAllData:tmpContext];
        [[AMPoSDBManager sharedInstance] memClearAllData:tmpContext];
        [[AMAssetDBManager sharedInstance] memClearAllData:tmpContext];
        [[AMLocationDBManager sharedInstance] memClearAllData:tmpContext];
        [[AMCaseDBManager sharedInstance] memClearAllData:tmpContext];
        [[AMInvoiceDBManager sharedInstance] memClearAllData:tmpContext];
        [[AMFilterDBManager sharedInstance] memClearAllData:tmpContext];
        [[AMPartsDBManager sharedInstance] memClearAllData:tmpContext];
        [[AMAssetRequestDBManager sharedInstance] memClearAllData:tmpContext];
        
        [self deleteAllDataForEntity:@"AMDBRecordType"];
        [self deleteAllDataForEntity:@"AMDBAttachment"];
        [self deleteAllDataForEntity:@"AMDBBest"];
        [self deleteAllDataForEntity:@"AMDBCustomerPrice"];
        [self deleteAllDataForEntity:@"AMDBFilterUsed"];
        [self deleteAllDataForEntity:@"AMDBNewCase"];
        [self deleteAllDataForEntity:@"AMDBNewLead"];
        [self deleteAllDataForEntity:@"AMDBNewWorkOrder"];
        [self deleteAllDataForEntity:@"AMDBPartsUsed"];
        [self deleteAllDataForEntity:@"AMDBPicklist"];
        [self deleteAllDataForEntity:@"AMDBReport"];
        
        NSError * error = nil;
        [tmpContext save:&error];
        if (error) {
           DLog(@"Error deleting - error:%@",error);
        }
        completionBlock(AM_DBOPR_CLEARALL,error);
    }];
    
    
    /*
    // clear data by delete and create sqlite file
    NSPersistentStoreCoordinator *storeCoordinator = __persistentStoreCoordinator;
    NSPersistentStore *store = storeCoordinator.persistentStores.firstObject;
    NSError *error = nil;
    NSURL *storeURL = store.URL;
    [storeCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    [__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
     */
}

// delete local object from "DEL" dictionary of Sync
- (void)deleteLocalObjects:(NSDictionary *)deleteIDs completion:(AMDBOperationCompletionBlock)completionBlock
{
    //    dispatch_async(_dbQeue, ^{
    [__privateManagedObjectContext performBlock:^{
        NSError * error = nil;
        if (deleteIDs && [deleteIDs allKeys].count) {
            NSArray *woIDs, *accountIDs, *assetIDs, *caseIDs, *contactIDs, *invoiceIDs, *posIDs, *partsIDs, *filterIDs, *locationIDs, *eventIDs;
            
            woIDs = [deleteIDs valueForKeyPathWithNullToNil:@"AMWorkOrder.Id"];
            accountIDs = [deleteIDs valueForKeyPathWithNullToNil:@"AMAccount.Id"];
            assetIDs = [deleteIDs valueForKeyPathWithNullToNil:@"AMAsset.Id"];
            caseIDs = [deleteIDs valueForKeyPathWithNullToNil:@"AMCase.Id"];
            contactIDs = [deleteIDs valueForKeyPathWithNullToNil:@"AMContact.Id"];
            invoiceIDs = [deleteIDs valueForKeyPathWithNullToNil:@"AMInvoice.Id"];
            posIDs = [deleteIDs valueForKeyPathWithNullToNil:@"AMPoS.Id"];
            partsIDs = [deleteIDs valueForKeyPathWithNullToNil:@"AMParts.Id"];
            filterIDs = [deleteIDs valueForKeyPathWithNullToNil:@"AMFilter.Id"];
            locationIDs = [deleteIDs valueForKeyPathWithNullToNil:@"AMLocation.Id"];
            eventIDs = [deleteIDs valueForKeyPathWithNullToNil:@"AMEvent.Id"];
            NSMutableArray * newWOIDs = nil;//if event is deleted, related woid should be delted too
            //            NSManagedObjectContext *tmpContext = [self managedObjectContext];
            NSManagedObjectContext *tmpContext = __privateManagedObjectContext;
            if (woIDs) {
                newWOIDs = [NSMutableArray arrayWithArray:woIDs];
            }
            else {
                newWOIDs = [NSMutableArray array];
            }
            
            if (eventIDs) {
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"eventID IN %@",eventIDs];
                NSArray * events = [[AMEventDBManager sharedInstance] getDataListByFilter:filter fromDB:tmpContext];
                
                for (AMEvent * event in events) {
                    [newWOIDs addObject:event.woID];
                }
                [[AMEventDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            if (newWOIDs && newWOIDs.count) {
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"woID IN %@",newWOIDs];
                [[AMWODBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            if (accountIDs) {
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"accountID IN %@",accountIDs];
                [[AMAccountDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            if (assetIDs) {
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"assetID IN %@",assetIDs];
                [[AMAssetDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            if (caseIDs) {
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"caseID IN %@",caseIDs];
                [[AMCaseDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            if (contactIDs) {
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"contactID IN %@",contactIDs];
                [[AMContactDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            if (invoiceIDs) {
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"invoiceID IN %@",invoiceIDs];
                [[AMInvoiceDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            if (posIDs) {
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"posID IN %@",posIDs];
                [[AMPoSDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            if (partsIDs) {
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"partID IN %@",partsIDs];
                [[AMPartsDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            if (filterIDs) {
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"filterID IN %@",filterIDs];
                [[AMFilterDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            if (locationIDs) {
                NSPredicate * filter = [NSPredicate predicateWithFormat:@"locationID IN %@",locationIDs];
                [[AMLocationDBManager sharedInstance] memClearDataByFilter:filter fromDB:tmpContext];
            }
            
            
            [tmpContext save:&error];
            DLog(@"deleteLocalObjects error:%@",error);
        }
        completionBlock(AM_DBOPR_DEL,error);
    }];
}

-(void)deleteDBObject:(id)object completion:(AMDBOperationCompletionBlock)completionBlock
{
    
    NSManagedObjectContext *moc = ((NSManagedObject *)object).managedObjectContext;
    __block NSError *error;
    
    [moc performBlock:^{
        [moc deleteObject:object];
        [moc save:&error];
        completionBlock(AM_DBOPR_DEL, error);
    }];

}

- (void)deleteContactById:(NSString *)contactId completion:(AMDBOperationCompletionBlock)completionBlock
{
    NSArray *array;
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"contactID = %@ AND deleteStatus = 1", contactId];
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBContact"
                                                     byPredicates:filter
                                                  sortDescriptors:nil
                                           inManagedObjectContext:__mainManagedObjectContext];
}

- (void)deleteInvoiceById:(NSString *)invoiceId completion:(AMDBOperationCompletionBlock)completionBlock
{
    NSArray *array;
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"invoiceID = %@", invoiceId];
    array = [[AMDBManager sharedInstance] fetchDataArrayForEntity:@"AMDBInvoice"
                                                     byPredicates:filter
                                                  sortDescriptors:nil
                                           inManagedObjectContext:__mainManagedObjectContext];
    if (array.count == 1) {
        AMDBInvoice *dbInvoice = array.firstObject;
        [self deleteDBObject:dbInvoice completion:completionBlock];
    } else {
        NSError *error = [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey: MyLocal(@"invoice to be deleted not found or more than one")}];
        completionBlock(AM_DBOPR_DEL, error);
    }
}


- (void)markDeleteAttachment:(AMDBAttachment *)attachment completion:(AMDBOperationCompletionBlock)completionBlock
{
    NSString *attachmentId = attachment.id ? attachment.id : attachment.fakeID;
    [[AMDBManager sharedInstance] updateAttachmentWithID:attachmentId setupBlock:^(AMDBAttachment *attachment) {
        attachment.dataStatus = @(EntityStatusDeleted);
    } completion:completionBlock];
}


- (void)deleteAttachment:(AMDBAttachment *)attachment completion:(AMDBOperationCompletionBlock)completionBlock;
{
    [[AMFileCache sharedInstance] removeFile:[attachment.localURL lastPathComponent]];
    
    [self deleteDBObject:attachment completion:completionBlock];

    //    } else {
//        completionBlock(AM_DBOPR_DEL, [NSError errorWithDomain:@"db" code:0 userInfo:@{NSLocalizedDescriptionKey: @"file to be deleted not found"}]);
//    }
}

-(void)deleteAttachmentsByIDs:(NSArray *)ids completion:(AMDBOperationCompletionBlock)completionBlock
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id IN %@", ids];
    [self deleteObjectsInDB:@"AMDBAttachment" byPredicate:predicate completion:completionBlock];
}


-(void)deleteObjectsInDB:(NSString *)entityName byPredicate:(NSPredicate *)predicate  completion:(AMDBOperationCompletionBlock)completionBlock
{
    [__privateManagedObjectContext performBlock:^{
        NSArray *objects = [self fetchDataArrayForEntity:entityName byPredicates:predicate sortDescriptors:nil inManagedObjectContext:__privateManagedObjectContext];
        for (NSManagedObject *mo in objects) {
            if ([mo isKindOfClass:[AMDBAttachment class]]) {
                [[AMFileCache sharedInstance] removeFile:[((AMDBAttachment *)mo).localURL lastPathComponent]];
            }
            [__privateManagedObjectContext deleteObject:mo];
        }
        NSError *error;
        [__privateManagedObjectContext save: &error];
        completionBlock(AM_DBOPR_DEL, error);
    }];
}

-(void)deleteAllDataForEntity:(NSString *)entityName
{
    [__privateManagedObjectContext performBlockAndWait:^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:__privateManagedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error;
        NSArray *items = [__privateManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (NSManagedObject *managedObject in items) {
            [__privateManagedObjectContext deleteObject:managedObject];
            //    	DLog(@"%@ object deleted",entityName);
        }
    }];
}


@end







