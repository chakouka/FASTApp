//
//   CurrentAnnotationView.h
//
//  Created by Sam Vermette on 01.03.13.
//  https://github.com/samvermette/ CurrentAnnotationView
//

#import <MapKit/MapKit.h>
#import "AnnotationInfo.h"

@interface  CurrentAnnotationView : MKAnnotationView

@property (nonatomic, strong) AnnotationInfo *mapAnnotation;
@property (nonatomic, strong) UIColor *annotationColor;               // default is same as MKUserLocationView
@property (nonatomic, readwrite) NSTimeInterval pulseAnimationDuration;     // default is 1s
@property (nonatomic, readwrite) NSTimeInterval delayBetweenPulseCycles;     // default is 1s

@end
