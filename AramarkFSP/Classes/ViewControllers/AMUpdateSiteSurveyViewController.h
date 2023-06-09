//
//  AMUpdateSiteSurveyViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 6/3/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMWOTabBaseViewController.h"
#import "AMPopoverSelectTableViewController.h"
@protocol AMUpdateSiteSurveyViewControllerDelegate;
@interface AMUpdateSiteSurveyViewController : AMWOTabBaseViewController <UITextFieldDelegate, UITextViewDelegate, AMPopoverSelectTableViewControllerDelegate>

@property (strong, nonatomic) AMLocation *location;
@property (weak, nonatomic) IBOutlet UITextField *cabinetHeightTF;
@property (weak, nonatomic) IBOutlet UITextView *addtionalNoteTA;
@property (weak, nonatomic) IBOutlet UIButton *badgeNeededBtn;
@property (weak, nonatomic) IBOutlet UIButton *dockAvailableButton;
@property (weak, nonatomic) IBOutlet UIButton *doorToBeRemovedBtn;
@property (weak, nonatomic) IBOutlet UITextField *doorwayWidthTF;
@property (weak, nonatomic) IBOutlet UILabel *electricOutletTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *eletricityWith3ftBtn;
@property (weak, nonatomic) IBOutlet UILabel *elevatorOrStairLabel;
@property (weak, nonatomic) IBOutlet UITextField *elevatorSizeTF;
@property (weak, nonatomic) IBOutlet UIButton *freightElevatorAvailableBtn;
@property (weak, nonatomic) IBOutlet UIButton *PersonalProBtn;
@property (weak, nonatomic) IBOutlet UIButton *RequiredEletricalBtn;
@property (weak, nonatomic) IBOutlet UIButton *requiredVisitBtn;
@property (weak, nonatomic) IBOutlet UIButton *siteLevelBtn;
@property (weak, nonatomic) IBOutlet UITextField *siteSurveyDateTF;
@property (weak, nonatomic) IBOutlet UITextField *roomMeasurementTF;
@property (weak, nonatomic) IBOutlet UIButton *wateSourceBtn;
@property (weak, nonatomic) IBOutlet UITextView *specialInstructionTV;
@property (weak, nonatomic) IBOutlet UIView *addtionalNoteParentView;
@property (weak, nonatomic) IBOutlet UIView *specialInstructionParentView;
@property (weak, nonatomic) IBOutlet UITextField *typtOfFlooringTF;
@property (weak, nonatomic) IBOutlet UIButton *specificSafetyTrainingReqedBtn;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UILabel *labelTAddtionalNote;
@property (weak, nonatomic) IBOutlet UILabel *labelTBadgeNeeded;
@property (weak, nonatomic) IBOutlet UILabel *labelTCabinetHeight;
@property (weak, nonatomic) IBOutlet UILabel *labelTDockAvailable;
@property (weak, nonatomic) IBOutlet UILabel *labelTDoorsToBeRemoved;
@property (weak, nonatomic) IBOutlet UILabel *labelTDoorwayWidth;
@property (weak, nonatomic) IBOutlet UILabel *labelTElectricOutlet;
@property (weak, nonatomic) IBOutlet UILabel *labelTEletricityWithin;
@property (weak, nonatomic) IBOutlet UILabel *labelElevatorOrStairs;
@property (weak, nonatomic) IBOutlet UILabel *labelTElevatorSize;
@property (weak, nonatomic) IBOutlet UILabel *labelTFrightElevator;
@property (weak, nonatomic) IBOutlet UILabel *labelTPersonalProtection;
@property (weak, nonatomic) IBOutlet UILabel *labelTRequiredElectrical;
@property (weak, nonatomic) IBOutlet UILabel *labelTRequiresVisitByService;
@property (weak, nonatomic) IBOutlet UILabel *labelTSiteLevelAndLighted;
@property (weak, nonatomic) IBOutlet UILabel *labelTSiteSurveyDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTRoomMeasurement;
@property (weak, nonatomic) IBOutlet UILabel *labelTSpecificSafety;
@property (weak, nonatomic) IBOutlet UILabel *labelTTypeOfFlooring;
@property (weak, nonatomic) IBOutlet UILabel *labelTWaterSource;
@property (weak, nonatomic) IBOutlet UILabel *labelTSpecialInstruction;


@property (weak, nonatomic) id<AMUpdateSiteSurveyViewControllerDelegate> delegate;

@end

@protocol AMUpdateSiteSurveyViewControllerDelegate <NSObject>

- (void)didTappedOnSubmit:(NSError *)error;

@end
