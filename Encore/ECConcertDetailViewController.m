//
//  ECConcertDetailViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//
#import "EncoreURL.h"
#import <QuartzCore/QuartzCore.h>
#import "ECConcertDetailViewController.h"
#import "NSDictionary+ConcertList.h"
#import "Cell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDictionary+Posts.h"
#import "ECJSONPoster.h"
#import "ECPostViewController.h"
#import "ECMainViewController.h"
#import "ECPostCollectionHeaderView.h"

#import "ECAppDelegate.h"

#import "UIImage+GaussBlur.h"

#import "MBProgressHUD.h"

#import "ECPictureViewController.h"

#import "UIColor+EncoreUI.h"
#import "UIFont+Encore.h"

#define HUD_DELAY 0.9
#define HEADER_HEIGHT 160.0

//#import "SGSStaggeredFlowLayout.h"

NSString *kCellID = @"cellID";
typedef enum {
    PhotoSourcePicker,
    AddConfirm,
    RemoveConfirm
}ECTag;
@interface ECConcertDetailViewController (){
//    SGSStaggeredFlowLayout* _flowLayout;

}

@end

@implementation ECConcertDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithConcert:(NSDictionary *)concert {
    self = [super init];
    if (self) {
        self.concert = concert;
    }
    return self;
}

#pragma mark - View Setup
- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.collectionView registerNib:[UINib nibWithNibName:@"ECCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"cellID"];
    
    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"generic"];
    
    self.title = NSLocalizedString(@"concert", nil);//self.artistNameLabel.text;
    self.headerView = [[ECPostCollectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.collectionView.frame.size.width, HEADER_HEIGHT) andOwner:self];
    [self setupArtistUIAttributes];
    
    self.isOnProfile = FALSE;
    [self setUpNavBarButtons];

    [self updateView];
}

-(void) setConcert:(NSDictionary *)concert andUpdate: (BOOL) update {
    self.concert = concert;
    if (update) {
        [self updateView];
    }
}

-(void) clearCollectionView {
    self.posts = nil;
    [self.collectionView reloadData];
}
-(void) setupArtistUIAttributes {
    [self.artistNameLabel setAdjustsFontSizeToFitWidth:YES];
    self.artistNameLabel.font = [UIFont heroFontWithSize: 16.0];
    [self.artistNameLabel setAdjustsFontSizeToFitWidth:YES];
    self.venueNameLabel.font = [UIFont heroFontWithSize: 14.0];
    self.dateLabel.font = [UIFont heroFontWithSize: 12.0];
    self.imgArtist.layer.cornerRadius = 25.0;
    self.imgArtist.layer.masksToBounds = YES;
    self.imgArtist.layer.borderColor = [UIColor grayColor].CGColor;
    self.imgArtist.layer.borderWidth = 0.1;
}
//-(void) setUpFlowLayout {
//    _flowLayout = [[SGSStaggeredFlowLayout alloc] init];
//    _flowLayout.layoutMode = SGSStaggeredFlowLayoutMode_Even;
//    _flowLayout.minimumLineSpacing = 2.0f;
//    _flowLayout.minimumInteritemSpacing = 2.0f;
//    _flowLayout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
//    _flowLayout.itemSize = CGSizeMake(75.0f, 75.0f);
//    
//    self.collectionView.collectionViewLayout = _flowLayout;
//}

-(void) updateView {
    //self.title = self.artistNameLabel.text;
    self.lastfmID = [self.concert lastfmID];
    [self clearCollectionView];
    [self loadArtistDetails];
    [self loadImages];
    [self setupToolbar];
}

-(void) setupToolbar {
    NSString * userID = self.userID;
    [ECJSONFetcher checkIfConcert:[self.concert lastfmID] isOnProfile:userID completion:^(BOOL isOnProfile) {
//        if (!isOnProfile) {
//            self.isOnProfile = FALSE;
//           // [self.iWasThereButton setSelected:NO];
//        }
//        else {
//            self.isOnProfile = TRUE;
//            [self.iWasThereButton setSelected:YES];
//        }
        self.isOnProfile = isOnProfile;
        [self setImageForConcertStatusButton];
    }];
}
-(void) setImageForConcertStatusButton {
    if (self.isOnProfile) {
        [self.iWasThereButton setImage:[UIImage imageNamed:@"removebutton.png"] forState:UIControlStateNormal];
    }
    else {
        if (self.searchType == ECSearchTypePast) {
            [self.iWasThereButton setImage:[UIImage imageNamed:@"IWasThereButton.png"] forState:UIControlStateNormal];
        } else {
            [self.iWasThereButton setImage:[UIImage imageNamed:@"imgoing.png"] forState:UIControlStateNormal];
        }
    }
}

-(void) loadArtistDetails {
    self.artistNameLabel.text = [self.concert artistName];
    self.venueNameLabel.text = [self.concert venueName];

    self.dateLabel.text = [NSString stringWithFormat:@"%@, %@", [self.concert venueName], [self.concert niceDate]];

    NSURL *imageURL = [self.concert imageURL];
    if (imageURL) {
        UIImage *regImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        
        if (regImage) {
            self.imgArtist.image = regImage;
            self.imgBackground.image = [regImage imageWithGaussianBlur];
        } else {
            self.imgBackground.image = [[UIImage imageNamed:@"Default"] imageWithGaussianBlur];
            self.imgArtist.image = [UIImage imageNamed:@"placeholder.jpg"];
        }
    } else {
        self.imgBackground.image = [[UIImage imageNamed:@"Default"] imageWithGaussianBlur];
        self.imgArtist.image = [UIImage imageNamed:@"placeholder.jpg"];
    }
}

-(void) loadImages {
    NSString* serverID = [self.concert lastfmID];
    if (serverID) {
        [ECJSONFetcher fetchPostsForConcertWithID:serverID completion:^(NSArray *fetchedPosts) {
            [self fetchedPosts:fetchedPosts];
        }];
    }
    else {
        NSLog(@"%@: Can't load images, object doesn't have a server_id", NSStringFromClass([self class]));
        [self setUpPlaceholderView];
    }
}

-(void) fetchedPosts: (NSArray *) posts {
    self.posts = posts;
    if ([self.posts count] > 0) {
        [self.placeholderView removeFromSuperview];
    }
    else {
        [self setUpPlaceholderView];
   }
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
}

-(void) setUpNavBarButtons {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButImage = [UIImage imageNamed:@"shareButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
    self.shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = self.shareButton;
    
//    self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped)];
//    [self.navigationItem setRightBarButtonItem:self.shareButton];
}

-(void) backButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - FB Sharing
-(void) shareTapped {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ShareConcertURL,self.songkickID]];
    
    FBShareDialogParams* params = [[FBShareDialogParams alloc] init];
    params.link = url;
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs presentShareDialogWithLink:url
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              NSLog(@"Error sharing concert: %@", error.description);
                                              [Flurry logEvent:@"Concert_Share_To_FB_Fail" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:url.absoluteString, @"url", nil]];
                                          } else {
                                              NSLog(@"Success sharing concert!");
                                              [Flurry logEvent:@"Concert_Share_To_FB_Success" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:url.absoluteString, @"url", nil]];
                                          }
                                      }];
    }
    else {
        NSArray* items = [NSArray arrayWithObjects:url,[NSString stringWithFormat:@"Check out %@ on Encore",[self.concert artistName]],nil];
        UIActivityViewController* activityVC = [[UIActivityViewController alloc] initWithActivityItems: items applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeSaveToCameraRoll,UIActivityTypeAssignToContact];
        activityVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        activityVC.completionHandler = ^(NSString* activityType, BOOL completed){
            [Flurry logEvent:@"Concert_Share_With_ActivityVC" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:completed], @"completed", activityType, @"activity_type", url.absoluteString, @"url",nil]];
        };
        [self presentViewController:activityVC animated:YES completion:nil];

    }
}

#pragma mark - Adding/Removing Concerts

-(IBAction) addToProfile {
    if (!self.isOnProfile) {
        [self addConcert];
    }
    else {
        [self removeConcert];
    }
}

-(void) addConcert {
    [Flurry logEvent:@"Tapped_Add_Concert" withParameters:[self flurryParam]];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm_add_title", nil) message:NSLocalizedString(@"confirm_add_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"add", nil), nil];
    alert.tag = AddConfirm;
    [alert show];
}

-(void) removeConcert {
    [Flurry logEvent:@"Tapped_Remove_Concert" withParameters:[self flurryParam]];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm_remove_title", nil) message:NSLocalizedString(@"confirm_remove_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"remove", nil), nil];
    alert.tag = RemoveConfirm;
    [alert show];    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        NSString * userID = self.userID;
        NSString * lastfmID = self.lastfmID;
        switch (alertView.tag) {
            case AddConfirm: {
                NSLog(@"%@: Adding concert %@ to profile %@", NSStringFromClass(self.class), lastfmID, userID);
                [Flurry logEvent:@"Confirmed_Add_Concert" withParameters:[self flurryParam]];
                
                [ECJSONPoster addConcert:lastfmID toUser:userID completion:^{
                    [self completedAddingConcert];
                    [Flurry logEvent:@"Completed_Adding_Concert" withParameters:[self flurryParam]];
                }];
                break;
            }
            case RemoveConfirm: {
                [Flurry logEvent:@"Confirmed_Remove_Concert" withParameters:[self flurryParam]];
                
                NSLog(@"%@: Removing a concert %@ from profile %@", NSStringFromClass(self.class), lastfmID, userID);
                [ECJSONPoster removeConcert:lastfmID toUser:userID completion:^{
                    [self completedRemovingConcert];
                    [Flurry logEvent:@"Completed_Removing_Concert" withParameters:[self flurryParam]];
                }];
                break;
            }
            default:
                break;
        }
    }
    else {
        [Flurry logEvent:@"Canceled_Adding_or_Removing_Concert" withParameters:[self flurryParam]];
    }
}

-(void) completedAddingConcert {
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.labelText = NSLocalizedString(@"concert_added",nil);
    HUD.color = [UIColor lightBlueHUDConfirmationColor];
	[HUD show:YES];
	[HUD hide:YES afterDelay:HUD_DELAY];
    [self toggleOnProfileState];
    
    //[[self mainViewController] refreshForConcertID:self.lastfmID];
    //Refresh for concert ID will make profile vc pop back to itself
}

-(void) completedRemovingConcert {
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	// TODO replace with our own or a free X icon
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.labelText = NSLocalizedString(@"concert_removed", nil);
    HUD.color = [UIColor redHUDConfirmationColor];
	[HUD show:YES];
	[HUD hide:YES afterDelay:HUD_DELAY];

    //TODO: update this for new design
    //[[self mainViewController] refreshForConcertID:nil];
    //Refresh for concert ID will make profile vc pop back to itself
}   

//Toggle whether or not the profile is on the user's profile.
-(void) toggleOnProfileState {
    self.isOnProfile = !self.isOnProfile;
    [self.iWasThereButton setSelected:self.isOnProfile];
}

#pragma mark - collection view delegate/data source

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [self.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    Cell *cell = (Cell*)[cv dequeueReusableCellWithReuseIdentifier:@"generic" forIndexPath:indexPath];
    
    
    // load the image for this cell
    if(!cell.image) {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imageView];
        cell.image=imageView;
        cell.contentView.clipsToBounds = YES;
    }
    if(self.posts.count > 0) {
        NSDictionary * postDic = [self.posts objectAtIndex:indexPath.row];
        NSURL *imageToLoad = [postDic imageURL];
        [cell.image setImageWithURL:imageToLoad];
    }
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ECPostViewController * postVC = [[ECPostViewController alloc] init];
    postVC.post = [self.posts objectAtIndex:indexPath.item];
    postVC.itemNumber = indexPath.item;
    postVC.delegate = self;
    [self.navigationController pushViewController:postVC animated:YES];
}

-(UICollectionReusableView*) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView* reusableView = nil;

    if (kind == UICollectionElementKindSectionHeader) {
        reusableView = self.headerView;
    }
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    //Manually set to desired height
    return CGSizeMake(self.collectionView.frame.size.width, HEADER_HEIGHT);
}

-(void) setUpPlaceholderView {
    if(!self.placeholderView){
        
        //Manually set the height of the placeholder view so it fits in under the collection view's header (so that the header scrolls out of the way when you're searching through posts
        //[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        
        self.placeholderView = [[ECPlaceHolderView alloc] initWithFrame:CGRectMake(0.0, HEADER_HEIGHT, self.collectionView.frame.size.width, self.collectionView.frame.size.height-HEADER_HEIGHT) owner: self];
    }
    if(!self.placeholderView.superview) {
        [self.view addSubview:self.placeholderView];
    }
}

#pragma mark - adding photos
-(IBAction)addPhoto {
    [Flurry logEvent:@"Tapped_Add_Photo" withParameters:[self flurryParam]];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Post photo" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"pick_from_lib", nil),[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? NSLocalizedString(@"new_from_camera", nil):nil, nil];
    actionSheet.tag = PhotoSourcePicker;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

#pragma mark Action Sheet Delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == PhotoSourcePicker ) {
        NSString* selectedSource;
        UIImagePickerControllerSourceType sourceType;
        if(buttonIndex != actionSheet.cancelButtonIndex){
            selectedSource = [actionSheet buttonTitleAtIndex:buttonIndex];
            if ([selectedSource isEqualToString:NSLocalizedString(@"new_from_camera", nil)]) {
                sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self showImagePickerForSourceType: sourceType];
        }
        else {
            [Flurry logEvent:@"Canceled_Photo_Adding" withParameters:[self flurryParam]];
        }
    }
}

-(void) showImagePickerForSourceType: (UIImagePickerControllerSourceType) sourceType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if(sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
        [Flurry logEvent:@"Showed_Camera" withParameters:[self flurryParam]];
    }
    else {
        [Flurry logEvent:@"Showed_Photo_Library" withParameters:[self flurryParam]];
    }
    self.imagePickerController = imagePickerController;
    [self presentViewController: self.imagePickerController animated:YES completion: nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [Flurry logEvent:@"Finished_Picking_Image" withParameters:[self flurryParam]];
    UIImage* image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        ECPictureViewController* pictureVC = [[ECPictureViewController alloc] initWithImage:image];
        pictureVC.delegate = self;
        [self presentViewController:pictureVC animated:NO completion:nil];
    }];
}

#pragma mark Picture View Controller Delegate
-(void) postImage:(UIImage *)image {
    NSDictionary * imageDic = [NSDictionary dictionaryWithObjectsAndKeys:image, @"image",[self.concert songkickID], @"concert", self.userID, @"user", nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    [ECJSONPoster postImage: imageDic completion:^{
        NSLog(@"Completed posting image!");
        MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [HUD setColor:[UIColor lightBlueHUDConfirmationColor]];
        [HUD show:YES];
        [HUD hide:YES afterDelay:HUD_DELAY];
        [Flurry logEvent:@"Completed_Posting_Image" withParameters:[self flurryParam]];
    }];
}
-(NSDictionary*) flurryParam {
    return self.concert;
}
#pragma mark - post view controller delegate

-(NSDictionary*) requestPost:(NSInteger)direction currentIndex:(NSInteger)index {
    if(self.posts.count <= 1) { //if only one or zero posts, no need to switch
        return nil;
    }
    
    NSInteger newIndex = index + direction;
    if (newIndex < 0) {
        newIndex = self.posts.count - 1; //loop to the end
    }
    else if (newIndex >= self.posts.count) {
        newIndex = 0;  //loop to the beginning
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[self.posts objectAtIndex:newIndex], @"dic", [NSNumber numberWithInt:newIndex], @"index",nil];
}

#pragma mark - getters
//Property readonly getter to grab songkickID in a slightly shorter way
-(NSNumber*) songkickID {
    return [self.concert songkickID];
}

-(NSString*) userID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:NSLocalizedString(@"user_id", nil)];
}

-(ECMainViewController*) mainViewController {
    ECAppDelegate* appDel = (ECAppDelegate *)[UIApplication sharedApplication].delegate;
    return appDel.mainViewController;
}

@end

#import "UIImage+GIF.h"

#pragma mark -
@implementation ECPlaceHolderView

-(id) initWithFrame:(CGRect)frame owner: (id) owner {
    if (self = [super initWithFrame:frame]){
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECPostPlaceholder" owner:owner options:nil];
        self = [subviewArray objectAtIndex:0];
        self.frame = frame;
        self.label1.font = [UIFont heroFontWithSize: 18.0];
        self.label2.font = [UIFont heroFontWithSize: 18.0];
        
        self.label1.text = NSLocalizedString(@"POST_PLACEHOLDER_TEXT_1", nil);
        self.label2.text = NSLocalizedString(@"POST_PLACEHOLDER_TEXT_2", nil);
        
        self.liveGIF.image = [UIImage animatedGIFNamed:@"liveNow"];
        
//        self.button.titleLabel.font = [UIFont heroFontWithSize: 22.0];
    }
    return self;
}

@end
