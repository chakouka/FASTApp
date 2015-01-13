//
//  AMDBAttachment+AddOn.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/9/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBAttachment+AddOn.h"
#import "NSData+Base64.h"

@implementation AMDBAttachment (AddOn)

+(void)insertNewEntitiesWithSFResponse:(NSArray *)array InManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *dict in array) {
        [self insertNewEntityWithSFDictionary:dict InManagedObjectContext:context];
    }
}

+(AMDBAttachment *)insertNewEntityWithSFDictionary:(NSDictionary *)dictionary InManagedObjectContext:(NSManagedObjectContext *)context
{
    AMDBAttachment *entity = nil;
    entity = [[AMDBManager sharedInstance] getAttachmentById:[dictionary valueForKeyWithNullToNil:@"Id"]];
    if (!entity) {
        entity = [NSEntityDescription insertNewObjectForEntityForName:@"AMDBAttachment" inManagedObjectContext:context];
    }  else {
        entity = (AMDBAttachment *)[context objectWithID: entity.objectID];
    }
    
    if (![entity.dataStatus isEqualToNumber:@(EntityStatusDeleted)]) {
        entity.dataStatus = @(EntityStatusFromSalesforce);
    }
    entity.id = [dictionary valueForKeyWithNullToNil:@"Id"];
    entity.name = [dictionary valueForKeyWithNullToNil:@"Name"];
    entity.contentType = [dictionary valueForKeyPathWithNullToNil:@"ContentType"];
    entity.bodyLength = [dictionary valueForKeyPathWithNullToNil:@"BodyLength"];
    entity.parentId = [dictionary valueForKeyPathWithNullToNil:@"ParentId"];
    entity.remoteURL = [dictionary valueForKeyPathWithNullToNil:@"attributes.url"];
    entity.createdById = [dictionary valueForKeyPathWithNullToNil:@"CreatedById"];

    return entity;
}


+(AMDBAttachment *)insertNewEntityWithSetupBlock:(void(^)(AMDBAttachment *newAttachment))block
                          inManagedObjectContext:(NSManagedObjectContext *)context
{
    AMDBAttachment *newEntity = [self newEntityInManagedObjectContext:context];
    block(newEntity);
    newEntity.dataStatus = @(EntityStatusCreated);
    newEntity.createdById = [AMDBManager sharedInstance].selfId;
    
    return newEntity;
}

+(AMDBAttachment *)newEntityInManagedObjectContext:(NSManagedObjectContext *)context
{
    AMDBAttachment *entity = nil;
    entity = [NSEntityDescription insertNewObjectForEntityForName:@"AMDBAttachment" inManagedObjectContext:context];
    entity.dataStatus = [NSNumber numberWithInt:EntityStatusNew];
    entity.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];
    
    return entity;
}

-(NSDictionary *)dictionaryToUploadSalesforce
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSData * imageData = [NSData dataWithContentsOfFile:self.localURL];
    UIImage *image = [UIImage imageWithContentsOfFile:self.localURL];
    imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString * base64Str = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    base64Str = [imageData base64EncodedString];
    //        NSString *contentType = @"image/jpeg";
    
    if (self.parentId && base64Str) {
        [dict setObject:base64Str forKey:@"Body"];
        [dict setObject:self.parentId forKey:@"ParentId"];
        [dict setValue:self.contentType forKey:@"ContentType"];
        [dict setValue:self.fakeID forKey:@"fakeId"];
    }
    return dict;
}


@end





