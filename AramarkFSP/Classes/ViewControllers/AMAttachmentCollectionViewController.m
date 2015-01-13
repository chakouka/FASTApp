//
//  AMAttachmentCollectionViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 6/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAttachmentCollectionViewController.h"
#import "AMAttachmentCollViewCell.h"
#import "AMAttachmentCollViewAddCell.h"
#import "AMDBAttachment.h"

static NSString *CollectionCellIdentifier = @"CollectionViewCell";
static NSString *CollectionAddCellIdentifier = @"CollectionViewAddCell";
static NSString *CollectionLocalCellIdentifier = @"CollectionViewLocalCell";

@interface AMAttachmentCollectionViewController (){
    UIPopoverController *popoverVC;
    UIPopoverController *albumPopover;
    UIView *selectedCellView;
    BOOL isPreviewLocal;
    NSInteger localCellIndex;
}

@end

@implementation AMAttachmentCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.collectionView registerNib:[UINib nibWithNibName:@"AMAttachmentCollViewCell" bundle:nil] forCellWithReuseIdentifier:CollectionCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AMAttachmentCollViewAddCell" bundle:nil] forCellWithReuseIdentifier:CollectionAddCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AMAttachmentCollViewLocalCell" bundle:nil] forCellWithReuseIdentifier:CollectionLocalCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attachmentDownloadIsDone:) name:NOTIFICATION_ATTACHMENT_DOWNLOADED object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ATTACHMENT_DOWNLOADED object:nil];
}

- (void)setWorkOrder:(AMWorkOrder *)workOrder
{
    _workOrder = workOrder;
    self.remoteAttArr = [[AMLogicCore sharedInstance] getOtherCreatedAttachmentsByWOID:workOrder.woID];
    self.localAttArr = [[AMLogicCore sharedInstance] getSelfCreatedAttachmentsByWOID:workOrder.woID];
    [self.collectionView reloadData];
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self.remoteAttArr count] + 1;
            break;
        
        case 1:
            return [self.localAttArr count];
            break;
            
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.localAttArr count] > 0 ? 2 : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == [self.remoteAttArr count]) {
                AMAttachmentCollViewAddCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionAddCellIdentifier forIndexPath:indexPath];
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnAddCell:)];
                [cell addGestureRecognizer:tapGesture];
                return cell;
                
            } else {
                AMAttachmentCollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellIdentifier forIndexPath:indexPath];
                cell.attachment = [self.remoteAttArr objectAtIndex:indexPath.row];
                cell.tag = indexPath.row;
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnRemoteViewCell:)];
                [cell addGestureRecognizer:tapGesture];
                return cell;
            }
        }
            break;
            
        case 1:
        {
            AMAttachmentCollViewLocalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionLocalCellIdentifier forIndexPath:indexPath];
            cell.attachment = [self.localAttArr objectAtIndex:indexPath.row];
            cell.delegate = self;
            cell.tag = indexPath.row;
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 0);
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSURL *qlURL;
    AMDBAttachment *attachment;
    if (isPreviewLocal) {
        attachment = [_localAttArr objectAtIndex:localCellIndex];
    } else {
        attachment = [_remoteAttArr objectAtIndex:selectedCellView.tag];
    }
    if (attachment.localURL) {
        qlURL = [NSURL fileURLWithPath:attachment.localURL];
    } else {

    }
    return qlURL;
}

- (void)tappedOnRemoteViewCell:(UIGestureRecognizer *)gesture
{
    isPreviewLocal = NO;
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    previewController.currentPreviewItemIndex = 0;
    
    selectedCellView = gesture.view;
    UINavigationController *navCon = (UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    [navCon.topViewController presentViewController:previewController animated:YES completion:^{
        
    }];
//    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:previewController animated:YES completion:nil];
    
}


- (void)tappedOnAddCell:(UIGestureRecognizer *)gesture
{
    if (!popoverVC) {
        AMPopoverSelectTableViewController *contentVC = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
        //                    contentVC.arrInfos = @[
        
        BOOL isCameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        NSArray *dataSource;
        if (isCameraAvailable) {
            dataSource = @[@{kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Camera") , kAMPOPOVER_DICTIONARY_KEY_DATA : @(0)}, @{kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Choose From Album"), kAMPOPOVER_DICTIONARY_KEY_DATA : @(1)}];
        } else {
            dataSource = @[@{kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Choose From Album"), kAMPOPOVER_DICTIONARY_KEY_DATA : @(1)}];
        }
        contentVC.arrInfos = [NSMutableArray arrayWithArray:dataSource];
        contentVC.delegate = self;
        popoverVC = [[UIPopoverController alloc] initWithContentViewController:contentVC];
        [popoverVC setPopoverContentSize:CGSizeMake(200.0, 88.0) animated:YES];
    }
    selectedCellView = gesture.view;
    [popoverVC presentPopoverFromRect:gesture.view.frame inView:gesture.view.superview permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

#pragma mark - AMPopoverSelectTableViewControllerDelegate
- (void)didSelectedIndex:(NSInteger)aIndex contentArray:(NSArray *)aArray
{
    [popoverVC dismissPopoverAnimated:YES];
    NSNumber *number = [[aArray objectAtIndex:aIndex] objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
    switch ([number intValue]) {
        case 0:
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            
            if([UIImagePickerController isSourceTypeAvailable:sourceType])
            {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                
                imagePickerController.delegate = self;
                imagePickerController.sourceType = sourceType;
                imagePickerController.allowsEditing = YES;
                [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:imagePickerController animated:YES completion:nil];
            }
        }
            break;
            
        case 1:
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            if([UIImagePickerController isSourceTypeAvailable:sourceType])
            {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                
                imagePickerController.delegate = self;
                imagePickerController.sourceType = sourceType;
                imagePickerController.allowsEditing = YES;
                albumPopover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
                //permittedArrowDirections
                [albumPopover presentPopoverFromRect:selectedCellView.frame inView:selectedCellView.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark -UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    UIImage *scaledImage = [AMUtilities scaleImage:image toScale:0.5];
    
//    NSTimeInterval timerInterval = [[NSDate alloc] timeIntervalSince1970];
//    NSString *__imageName = [NSString stringWithFormat:@"%f.png", timerInterval];
    NSString *uuidStr = [[NSUUID UUID] UUIDString];
    __block NSString *__imageName = [NSString stringWithFormat:@"%@.png", uuidStr];
//    if ([info valueForKey:@"UIImagePickerControllerReferenceURL"]) {
//        long long hash = [[info valueForKey:@"UIImagePickerControllerReferenceURL"] hash];
//        __imageName = [NSString stringWithFormat:@"%lld.png",hash];
//    }
    NSString *filePath =  [[[AMFileCache sharedInstance] getDirectoryPath] stringByAppendingPathComponent:__imageName];
    [[AMLogicCore sharedInstance] createNewAttachmentInDBWithSetupBlock:^(AMDBAttachment *newAttachment) {
        newAttachment.name = __imageName;
        newAttachment.contentType = @"image/png";
        newAttachment.parentId = self.workOrder.woID;
        newAttachment.localURL = filePath;
    } completion:^(NSInteger type, NSError *error) {
        if (!error) {
            [[AMFileCache sharedInstance] saveFile:UIImagePNGRepresentation(scaledImage) WithFileName:__imageName];
            self.localAttArr = [[AMLogicCore sharedInstance] getSelfCreatedAttachmentsByWOID:self.workOrder.woID];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
        
    }];
    if (albumPopover) {
        [albumPopover dismissPopoverAnimated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AMAttachmentCollViewLocalCellDelegate
- (void)didTappedOnDeleteButton:(AMDBAttachment *)attachment
{
//    [SVProgressHUD showErrorWithStatus:@"Delete Failed"];
    [[AMLogicCore sharedInstance] deleteAttachment:attachment completion:^(NSInteger type, NSError *error) {
        self.localAttArr = [[AMLogicCore sharedInstance] getSelfCreatedAttachmentsByWOID:self.workOrder.woID];
//        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            if (!error) {
                [SVProgressHUD showSuccessWithStatus:MyLocal(@"Delete Succeed")];
            } else {
                [SVProgressHUD showErrorWithStatus:MyLocal(@"Delete Failed")];
            }
        });
        
    }];
}

- (void)didTappedOnPreviewButton:(AMDBAttachment *)attachment withIndex:(NSInteger)index
{
    isPreviewLocal = YES;
    localCellIndex = index;
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    previewController.currentPreviewItemIndex = 0;
    
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:previewController animated:YES completion:nil];
}

#pragma mark - Notification Selector
- (void)attachmentDownloadIsDone:(NSNotification *)notification
{
    if ([notification object] && [[notification object] isKindOfClass:[AMDBAttachment class]]) {
        AMDBAttachment *attachment = (AMDBAttachment *)[notification object];
        for (AMDBAttachment *att in self.remoteAttArr) {
            if ([att.id isEqualToString:attachment.id]) {
                NSInteger index = [self.remoteAttArr indexOfObject:att];
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                AMAttachmentCollViewCell *cell = (AMAttachmentCollViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                cell.attachment = attachment;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                });
                break;
            }
        }
        
    }

    
    
}
@end
