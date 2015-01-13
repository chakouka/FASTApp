//
//  MapConstants.h
//  MapShow
//
//  Created by PwC on 4/21/14.
//  Copyright (c) 2014 PwC. All rights reserved.
//

#ifndef MapShow_MapConstants_h
#define MapShow_MapConstants_h

#define INITLatitude        40.638000
#define INITLongitude       -73.901411

#define RouteLineWidth      3
#define RouteLineColor      [UIColor blackColor]

typedef NS_ENUM (NSInteger, MapLocationType) {
	MapLocationType_CurrentPoint = 0,
	MapLocationType_TargetPoint,
};

typedef NS_ENUM (NSInteger, AnnotationViewType) {
	AnnotationViewType_CheckIn = 0,
	AnnotationViewType_CheckOut,
    AnnotationViewType_Finished,
    AnnotationViewType_NearMe,
};

#endif
