//
//   AnnotationInfo.h
//   Todo
//
//  Created by PwC on 4/12/14.
//  Copyright (c) 2014 viktyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MapConstants.h"

@interface  AnnotationInfo : NSObject <MKAnnotation>

@property (nonatomic, assign)   AnnotationViewType    viewType;
@property (nonatomic, assign)   MapLocationType       partType;
@property (nonatomic, assign)   NSInteger             index;
@property (nonatomic, assign)   NSInteger             count;
@property (nonatomic, strong)   NSString              *accountName;
@property (nonatomic, strong)   NSString              *woID;
@property (nonatomic, copy)     NSString              *title;
@property (nonatomic, copy)     NSString              *subtitle;
@property (nonatomic, strong)   CLLocation            *location;

@end
