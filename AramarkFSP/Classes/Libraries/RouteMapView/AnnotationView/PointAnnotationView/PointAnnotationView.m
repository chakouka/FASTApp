//
//  PointAnnotationView.m
//  AramarkFSP
//
//  Created by PwC on 5/8/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "PointAnnotationView.h"

@implementation PointAnnotationView
@synthesize mapAnnotation;
@synthesize delegate;
@synthesize labelIndex;
@synthesize labelCount;
@synthesize labelInfo;
@synthesize labelLeft;
@synthesize labelCancel;
@synthesize imageCancel;
@synthesize imageCheckIn;
@synthesize imageCheckOut;
@synthesize imagePinPoint;
@synthesize imagePinPointLeft;
@synthesize btnLeft;
@synthesize btnRight;
@synthesize btnCancel;
@synthesize mainView;

- (void)setMapAnnotation:(AnnotationInfo *)aMapAnnotation
{
    mapAnnotation = aMapAnnotation;
    self.labelIndex.text = [NSString stringWithFormat:@"%d", mapAnnotation.index];
    self.labelCount.text = mapAnnotation.count > 99 ? @"99" : [NSString stringWithFormat:@"%d", mapAnnotation.count];
    [self resizeLabelInfoWith:mapAnnotation.accountName];
    [self changeType:(mapAnnotation.viewType ? mapAnnotation.viewType : AnnotationViewType_CheckIn) withInfo:nil];
}

- (id)initWithAnnotation:(id <MKAnnotation> )annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 246, 130)];
        
        imagePinPointLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 154, 65)];
        [imagePinPointLeft setImage:[UIImage imageNamed:@"PinPointLeft.png"]];
        [mainView addSubview:imagePinPointLeft];
        
        if ([LanguageConfig currentLanguage] == LanguageType_English) {
            imageCheckIn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 154, 65)];
        }
        else
        {
            imageCheckIn = [[UIImageView alloc] initWithFrame:CGRectMake(154-223, 0, 223, 65)];
        }
        
        [imageCheckIn setImage:[UIImage imageNamed:MyImage(@"checkin")]];
        [mainView addSubview:imageCheckIn];
        
        imageCheckOut = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 154, 65)];
        [imageCheckOut setImage:[UIImage imageNamed:MyImage(@"checkout")]];
        [mainView addSubview:imageCheckOut];
        
        imagePinPoint = [[UIImageView alloc] initWithFrame:CGRectMake(98, 0, 154, 65)];
        [imagePinPoint setImage:[[UIImage imageNamed:@"PinPoint.png"] stretchableImageWithLeftCapWidth:100 topCapHeight:0]];
        [mainView addSubview:imagePinPoint];
        
        imageCancel = [[UIImageView alloc] initWithFrame:CGRectMake(98, 0, 154, 65)];
        [imageCancel setImage:[[UIImage imageNamed:@"PinPoint.png"] stretchableImageWithLeftCapWidth:100 topCapHeight:0]];
        [mainView addSubview:imageCancel];
        
        labelLeft = [[UILabel alloc] initWithFrame:CGRectMake(3, 7, 100, 42)];
        labelLeft.textColor = [UIColor whiteColor];
        labelLeft.textAlignment = NSTextAlignmentCenter;
        labelLeft.lineBreakMode = NSLineBreakByWordWrapping;
        labelLeft.numberOfLines = 0;
        labelLeft.text = MyLocal(@"WORK NOW");
        [mainView addSubview:labelLeft];
        
        labelIndex = [[UILabel alloc] initWithFrame:CGRectMake(105, 8, 42, 37)];
        labelIndex.textColor = [UIColor whiteColor];
        labelIndex.textAlignment = NSTextAlignmentCenter;
        [mainView addSubview:labelIndex];
        
        labelInfo = [[UILabel alloc] initWithFrame:CGRectMake(147 + 5, 7, 97, 42)];
        labelInfo.textColor = [UIColor whiteColor];
        labelInfo.textAlignment = NSTextAlignmentCenter;
        [mainView addSubview:labelInfo];
        
        labelCancel = [[UILabel alloc] initWithFrame:CGRectMake(147 + 5, 7, 97, 42)];
        labelCancel.textColor = [UIColor whiteColor];
        labelCancel.textAlignment = NSTextAlignmentCenter;
        labelCancel.text = MyLocal(@"Cancel");
        [mainView addSubview:labelCancel];
        
        btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnLeft.frame = CGRectMake(7, 14, 140, 30);
        btnLeft.tag = 9;
        [btnLeft addTarget:self action:@selector(clickCheckInBtn:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:btnLeft];
        
        btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
        btnRight.frame = CGRectMake(107, 14, 140, 30);
        btnRight.tag = 1;
        [btnRight addTarget:self action:@selector(clickCheckInBtn:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:btnRight];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.frame = CGRectMake(107, 14, 140, 30);
        btnCancel.tag = 1;
        [btnCancel addTarget:self action:@selector(clickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:btnCancel];
        
        labelCount = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 23, 23)];
        labelCount.textColor = [UIColor whiteColor];
        labelCount.backgroundColor = [UIColor redColor];
        labelCount.textAlignment = NSTextAlignmentCenter;
        [[self.labelCount layer] setCornerRadius:1];
        [[self.labelCount layer] setBorderWidth:1];
        [[self.labelCount layer] setBorderColor:[UIColor whiteColor].CGColor];
        [mainView addSubview:labelCount];
        
        [[self class] refreshFontInView:mainView];
        
        self.bounds = mainView.bounds;
        [self addSubview:mainView];
    }
    
    return self;
}

+ (void)refreshFontInView:(UIView *)aView
{
    for (UIView *subview in [aView subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)subview;
            [lbl setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger]];
        } else if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *tf = (UITextField *)subview;
            [tf setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger]];
        } else if ([[subview subviews] count] > 0) {
            [self refreshFontInView:subview];
        }
    }
}

- (void)resizeLabelInfoWith:(NSString *)aInfo
{
    NSDictionary *attribute = @{NSFontAttributeName: [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger]};
    
    CGFloat offset = 154 - 98;
    
    CGFloat aWidth = [aInfo boundingRectWithSize:CGSizeMake(MAXFLOAT, 42.0)
                                         options: NSStringDrawingUsesDeviceMetrics
                                      attributes:attribute
                                         context:nil].size.width;
    
    labelInfo.frame = CGRectMake(147 + 5, 7, aWidth + 15 > 100 ? (aWidth + 15) : 100 , 42);
    labelInfo.text = aInfo;
    imagePinPoint.frame = CGRectMake(98, 0, CGRectGetWidth(labelInfo.frame) + offset > 154 ?  CGRectGetWidth(labelInfo.frame) + offset : 154, 65);
    btnRight.frame = labelInfo.frame;
    mainView.frame = CGRectMake(0, 0, CGRectGetWidth(imagePinPoint.frame) + 154, 130);
    self.bounds = mainView.bounds;
    
    [self setNeedsDisplay];
}

- (void)clickCheckInBtn:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(didTappedPointAnnotationView:)]) {
        [delegate didTappedPointAnnotationView:self];
    }
}

- (void)clickCancelBtn:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(didTappedCancelAnnotationView:)]) {
        [delegate didTappedCancelAnnotationView:self];
    }
}

- (void)changeType:(AnnotationViewType)aType withInfo:(id)info {
    self.mapAnnotation.viewType = aType;
    
    self.labelCount.hidden = YES;
    self.labelInfo.hidden = YES;
    self.imageCheckIn.hidden = YES;
    self.imageCheckOut.hidden = YES;
    self.imagePinPoint.hidden = YES;
    self.btnLeft.hidden = YES;
    self.btnRight.hidden = YES;
    self.labelCount.frame = CGRectMake(90, 0, 23, 23);
    self.labelIndex.textColor = [UIColor whiteColor];
    self.imageCancel.hidden = YES;
    self.labelCancel.hidden = YES;
    self.btnCancel.hidden = YES;
    self.labelLeft.hidden = YES;
    self.imagePinPointLeft.hidden = YES;
    
    switch (aType) {
        case AnnotationViewType_CheckIn:
        {
            self.labelCount.hidden = NO;
            self.imageCheckIn.hidden = NO;
            self.btnLeft.hidden = NO;
            
            self.labelCount.hidden = NO;
            self.labelInfo.hidden = NO;
            self.imagePinPoint.hidden = NO;
            self.btnRight.hidden = NO;
        }
            break;
            
        case AnnotationViewType_CheckOut:
        {
            self.labelCount.hidden = NO;
            self.imageCheckOut.hidden = NO;
            self.btnLeft.hidden = NO;
            
            self.labelCancel.hidden = NO;
            self.imageCancel.hidden = NO;
            self.btnCancel.hidden = NO;
        }
            break;
        case AnnotationViewType_Finished:
        {
            self.imageCheckOut.hidden = NO;
            self.btnLeft.hidden = NO;
            self.labelIndex.textColor = [UIColor redColor];
        }
            break;
        case AnnotationViewType_NearMe:
        {
            self.btnLeft.hidden = NO;
            self.imagePinPointLeft.hidden = NO;
            self.labelLeft.hidden = NO;
            
            self.labelInfo.hidden = NO;
            self.imagePinPoint.hidden = NO;
            //			self.btnRight.hidden = NO;
        }
            break;
        default:
            break;
    }
    
    if ([self.labelCount.text length] == 0 || [self.labelCount.text isEqualToString:@"0"]) {
        self.labelCount.hidden = YES;
    }
    
    [mainView bringSubviewToFront:labelCount];
}

@end
