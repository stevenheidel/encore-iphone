//
//  ECConcertDetailViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECPostViewController.h"
#import "ECPictureViewController.h"
#import "ECSearchType.h"
#import "FBConnect.h"
#import "KNMultiItemSelector.h"

@class ECPlaceHolderView,ECToolbar,ECPostCollectionHeaderView,FBFriendPickerViewController;

@interface ECConcertDetailViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ECPostViewControllerDelegate,UIAlertViewDelegate, KNMultiItemSelectorDelegate,ECPictureViewControllerDelegate,FBRequestDelegate> {
    NSMutableArray* friends;
}

-(IBAction)addPhoto;
-(void) shareTapped;
-(id) initWithConcert:(NSDictionary*) concert;
-(void) setConcert:(NSDictionary *)concert andUpdate: (BOOL) update;
-(void) updateView;

@property (nonatomic,strong) FBFriendPickerViewController* friendPickerController;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView* footerActivityIndicator;
@property (nonatomic, assign) CGPoint savedPosition;
@property (weak, nonatomic) IBOutlet UIView *footerIsPopulatingView;
@property (nonatomic,strong) NSTimer* timer;

@property (nonatomic, readonly) BOOL isLoggedIn;
@property (nonatomic, assign) ECSearchType searchType;
@property (nonatomic,strong) NSDictionary * concert;
@property (nonatomic,strong) IBOutlet UILabel * artistNameLabel;
@property (nonatomic,strong) IBOutlet UILabel * venueNameLabel;
@property (nonatomic,strong) IBOutlet UILabel * dateLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) IBOutlet UIImageView *imgArtist;
@property (nonatomic,strong) IBOutlet UIImageView *imgBackground;
@property (nonatomic,strong) IBOutlet UIImageView *imgLiveNow;
@property (nonatomic, strong) IBOutlet UIButton *concertStausButton;

@property (nonatomic, strong) NSArray * posts;

@property (nonatomic, readonly) NSString * userID;

@property (nonatomic,strong) UIBarButtonItem * shareButton;

@property (nonatomic, assign) BOOL isOnProfile;

@property (nonatomic,strong) ECPlaceHolderView * placeholderView;

@property (nonatomic,strong) UIImagePickerController* imagePickerController;

@property (nonatomic,unsafe_unretained) id <ECPostViewControllerDelegate> delegate;

@property (nonatomic, strong) ECPostCollectionHeaderView* headerView;

@property (nonatomic, assign) BOOL isPopulating;
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@end

@interface ECPlaceHolderView : UIView
@property (nonatomic, strong) IBOutlet UILabel* label1;
@property (nonatomic, strong) IBOutlet UILabel* label2;
//@property (nonatomic, strong) IBOutlet UIButton* button;
-(id) initWithFrame:(CGRect)frame owner: (id) owner;
@end
