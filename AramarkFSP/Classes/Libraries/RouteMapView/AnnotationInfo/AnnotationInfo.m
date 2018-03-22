//
//   AnnotationInfo.m
//   Todo
//
//  Created by PwC on 4/12/14.
//  Copyright (c) 2014 viktyz. All rights reserved.
//

#import "AnnotationInfo.h"

@implementation  AnnotationInfo
@synthesize viewType;
@synthesize partType;
@synthesize index;
@synthesize count;
@synthesize accountName;
@synthesize woID;
@synthesize title;
@synthesize subtitle;
@synthesize location;

- (NSString *)description {
    NSString *saddr = [NSString stringWithFormat:@"%@ : %@ : %f,%f",NSStringFromClass([self class]),woID, location.coordinate.latitude, location.coordinate.longitude];
    return [NSString stringWithFormat:@"\n %d -- %@ : %@",(int)index, saddr, subtitle];
}

- (CLLocationCoordinate2D)coordinate
{
    return location.coordinate;
}

- (NSString *)title {
    return title;
}

- (NSString *)subtitle {
    return subtitle;
}

- (NSUInteger)hash {
    NSString *toHash = [NSString stringWithFormat:@"%.5F%.5F", location.coordinate.latitude, location.coordinate.longitude];
    return [toHash hash];
}

- (BOOL)isEqual:(id)object {
    return [self hash] == [object hash];
}

@end
