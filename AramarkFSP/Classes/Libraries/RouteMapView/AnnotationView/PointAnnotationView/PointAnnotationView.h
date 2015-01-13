//
//  PointAnnotationView.h
//  AramarkFSP
//
//  Created by PwC on 5/8/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "AnnotationInfo.h"

@protocol PointAnnotationViewDelegate;

@interface PointAnnotationView : MKAnnotationView

@property (weak, nonatomic) id <PointAnnotationViewDelegate> delegate;
@property (strong, nonatomic) AnnotationInfo *mapAnnotation;
@property (strong, nonatomic) UILabel *labelIndex;
@property (strong, nonatomic) UILabel *labelCount;
@property (strong, nonatomic) UILabel *labelInfo;
@property (strong, nonatomic) UILabel *labelCancel;
@property (strong, nonatomic) UILabel *labelLeft;
@property (strong, nonatomic) UIImageView *imageCancel;
@property (strong, nonatomic) UIImageView *imageCheckIn;
@property (strong, nonatomic) UIImageView *imageCheckOut;
@property (strong, nonatomic) UIImageView *imagePinPoint;
@property (strong, nonatomic) UIImageView *imagePinPointLeft;
@property (strong, nonatomic) UIButton *btnLeft;
@property (strong, nonatomic) UIButton *btnRight;
@property (strong, nonatomic) UIButton *btnCancel;
@property (strong, nonatomic) UIView *mainView;

- (void)clickCheckInBtn:(id)sender;
- (void)resizeLabelInfoWith:(NSString *)aInfo;
- (void)changeType:(AnnotationViewType)aType withInfo:(id)info;

@end

@protocol PointAnnotationViewDelegate <NSObject>

- (void)didTappedPointAnnotationView:(PointAnnotationView *)aPointAnnotationView;
- (void)didTappedCancelAnnotationView:(PointAnnotationView *)aPointAnnotationView;

@end
