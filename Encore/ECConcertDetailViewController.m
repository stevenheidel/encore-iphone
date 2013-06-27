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
#import "ECProfileViewController.h"

#import "ECAppDelegate.h"

#import "UIImage+GaussBlur.h"

#import "MBProgressHUD.h"
#define HUD_DELAY 0.9

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

#pragma mark - View Setup
- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.collectionView registerNib:[UINib nibWithNibName:@"ECCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"cellID"];
    
    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"generic"];
    
    // Do any additional setup after loading the view from its nib.
    self.artistNameLabel.text = [self.concert artistName];
    [self.artistNameLabel setAdjustsFontSizeToFitWidth:YES];
    self.dateLabel.text = [self.concert niceDate];
    self.venueNameLabel.text = [self.concert venueName];
    self.title = NSLocalizedString(@"concert", nil);//self.artistNameLabel.text;
    
    //TODO: Set pictures dynamically from image urls
    self.imgBackground.image = [[UIImage imageNamed:@"sampleArtistImage.jpg"] imageWithGaussianBlur];
    self.imgArtist.image = [UIImage imageNamed:@"placeholder.jpg"];
    self.imgLiveNow.image = [UIImage imageNamed:@"LiveIndicator.png"];
    
    self.imgArtist.layer.cornerRadius = 35.0;
    self.imgArtist.layer.masksToBounds = YES;
    self.imgArtist.layer.borderColor = [UIColor grayColor].CGColor;
    self.imgArtist.layer.borderWidth = 3.0;
    
    if ([self.concert isLive]) {
        self.imgLiveNow.hidden = NO;
    } else {
        self.imgLiveNow.hidden = YES;
    }
    
    self.isOnProfile = FALSE;
    [self setUpRightBarButton];
   // [self setUpFlowLayout];
    [self setupToolbar];
    [self loadImages];
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
    self.artistNameLabel.text = [self.concert artistName];
    
    self.venueNameLabel.text = [self.concert venueName];
    
    //TODO: Set pictures dynamically from image urls
    self.imgBackground.image = [[UIImage imageNamed:@"sampleArtistImage.jpg"] imageWithGaussianBlur];
    self.imgArtist.image = [UIImage imageNamed:@"placeholder.jpg"];
    
    if ([self.concert isLive]) {
        self.imgLiveNow.hidden = NO;
        self.dateLabel.text = NSLocalizedString(@"LiveNow", nil);
    } else {
        self.imgLiveNow.hidden = YES;
        self.dateLabel.text = [self.concert niceDate];
    }
    
    //self.title = self.artistNameLabel.text;
    [self loadImages];
    [self setupToolbar];
}

-(void) setupToolbar {
    NSString * userID = self.userID;
    [ECJSONFetcher checkIfConcert:[self.concert songkickID] isOnProfile:userID completion:^(BOOL isOnProfile) {
        if (!isOnProfile) {
            self.isOnProfile = FALSE;
            self.toolbar.addButton.title = NSLocalizedString(@"add", nil);
        }
        else {
            self.isOnProfile = TRUE;
            self.toolbar.addButton.title = NSLocalizedString(@"remove", nil);
        }
    }];
}

-(void) loadImages {
    NSNumber* serverID = [self.concert serverID];
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
        [self.collectionView reloadData];
        [self.placeholderView removeFromSuperview];
    }
    else {
        [self setUpPlaceholderView];
    }
}

-(void) setUpRightBarButton {
    self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped)];
    [self.navigationItem setRightBarButtonItem:self.shareButton];
}

#pragma mark - FB Sharing
-(void) shareTapped {
    NSLog(@"Share tapped");
    //baseurl + /concerts/:songkickId
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ShareConcertURL,self.songkickID]];
    if ([FBDialogs canPresentShareDialogWithParams:nil]) {
        [FBDialogs presentShareDialogWithLink:url
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              NSLog(@"Error: %@", error.description);
                                          } else {
                                              NSLog(@"Success!");
                                          }
                                      }];
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
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm_add_title", nil) message:NSLocalizedString(@"confirm_add_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"add", nil), nil];
    alert.tag = AddConfirm;
    [alert show];
}

-(void) removeConcert {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm_remove_title", nil) message:NSLocalizedString(@"confirm_remove_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"remove", nil), nil];
    alert.tag = RemoveConfirm;
    [alert show];    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        NSString * userID = self.userID;
        NSNumber * songkickID = self.songkickID;
        switch (alertView.tag) {
            case AddConfirm: {
                NSLog(@"%@: Adding concert %@ to profile %@",NSStringFromClass(self.class),songkickID.stringValue,userID);
                [ECJSONPoster addConcert:songkickID toUser:userID completion:^{
                    [self completedAddingConcert];
                }];
                break;
            }
            case RemoveConfirm: {
                NSLog(@"%@: Removing a concert %@ from profile %@",NSStringFromClass(self.class),songkickID,userID);
                [ECJSONPoster removeConcert:songkickID toUser:userID completion:^{
                    [self completedRemovingConcert];
                }];
                break;
            }
            default:
                break;
        }
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
    HUD.color = [UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:227.0/255.0 alpha:0.90];
	[HUD show:YES];
	[HUD hide:YES afterDelay:HUD_DELAY];
    [self toggleOnProfileState];
    
    [[self profileViewController] refreshForConcertID:self.songkickID];
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
    HUD.color = [UIColor colorWithRed:255.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0.90];
	[HUD show:YES];
	[HUD hide:YES afterDelay:HUD_DELAY];

    [[self profileViewController] refreshForConcertID:nil];
    //Refresh for concert ID will make profile vc pop back to itself
}   

//Toggle whether or not the profile is on the user's profile.
-(void) toggleOnProfileState {
    self.isOnProfile = !self.isOnProfile;
    self.toolbar.addButton.title = self.isOnProfile ? NSLocalizedString(@"remove", nil) : NSLocalizedString(@"add", nil);
}

//#pragma mark - UICollectionViewDelegateFlowLayout
//
////TODO: change this to use actual image dimensions or remove it.
//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UIImage* thisImage = [UIImage imageNamed:@"instagram.jpg"];
//    
//    CGSize cellSize;
//    CGFloat deviceCellSizeConstant = _flowLayout.itemSize.height;
//    cellSize = CGSizeMake((thisImage.size.width*deviceCellSizeConstant)/thisImage.size.height, deviceCellSizeConstant);
//    
//    return cellSize;
//}

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

-(void) setUpPlaceholderView {
    if(!self.placeholderView){
        self.placeholderView = [[ECPlaceHolderView alloc] initWithFrame:self.collectionView.frame owner: self];
    }
    if(!self.placeholderView.superview) {
        [self.view addSubview:self.placeholderView];
    }
}

#pragma mark - adding photos
-(IBAction)addPhoto {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Post photo" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"pick_from_lib", nil),[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? NSLocalizedString(@"new_from_camera", nil):nil, nil];
    actionSheet.tag = PhotoSourcePicker;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}


-(void) showImagePickerForSourceType: (UIImagePickerControllerSourceType) sourceType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if(sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
    }
    self.imagePickerController = imagePickerController;
    [self presentViewController: self.imagePickerController animated:YES completion: nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:NULL];
 
    NSDictionary * imageDic = [NSDictionary dictionaryWithObjectsAndKeys:image, @"image",[self.concert songkickID], @"concert", self.userID, @"user", nil];
    [ECJSONPoster postImage: imageDic completion:^{
        NSLog(@"Complete!");
    }];
}

#pragma mark - Action Sheet Delegate
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
    }
}

#pragma mark - post view controller delegate

-(NSDictionary*) requestPost:(NSInteger)direction currentIndex:(NSInteger)index {
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

-(ECProfileViewController*) profileViewController {
    ECAppDelegate* appDel = (ECAppDelegate *)[UIApplication sharedApplication].delegate;
    return appDel.profileViewController;
}

@end

#pragma mark -
@implementation ECPlaceHolderView

-(id) initWithFrame:(CGRect)frame owner: (id) owner {
    if (self = [super initWithFrame:frame]){
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECPostPlaceholder" owner:owner options:nil];
        self = [subviewArray objectAtIndex:0];
        self.frame = frame;
        self.label1.font = [UIFont fontWithName:@"Hero" size:18.0];
        self.label2.font = [UIFont fontWithName:@"Hero" size:18.0];
        
        self.label1.text = NSLocalizedString(@"POST_PLACEHOLDER_TEXT_1", nil);
        self.label2.text = NSLocalizedString(@"POST_PLACEHOLDER_TEXT_2", nil);
        
//        self.button.titleLabel.font = [UIFont fontWithName:@"Hero" size:22.0];
    }
    return self;
}

@end

@implementation ECToolbar

@end