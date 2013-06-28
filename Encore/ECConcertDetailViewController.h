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
@class ECPlaceHolderView,ECToolbar,ECPostCollectionHeaderView;
@interface ECConcertDetailViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate/*, UICollectionViewDelegateFlowLayout*/,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ECPostViewControllerDelegate,UIAlertViewDelegate,ECPictureViewControllerDelegate>

-(IBAction)addPhoto;
-(void) shareTapped;


@property (nonatomic,strong) NSDictionary * concert;
@property (nonatomic,strong) IBOutlet UILabel * artistNameLabel;
@property (nonatomic,strong) IBOutlet UILabel * venueNameLabel;
@property (nonatomic,strong) IBOutlet UILabel * dateLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) IBOutlet UIImageView *imgArtist;
@property (nonatomic,strong) IBOutlet UIImageView *imgBackground;
@property (nonatomic,strong) IBOutlet UIImageView *imgLiveNow;

@property (nonatomic, strong) NSArray * posts;

@property (nonatomic, readonly) NSNumber * songkickID;
@property (nonatomic, readonly) NSString * userID;


@property (nonatomic,strong) UIBarButtonItem * shareButton;

@property (nonatomic, assign) BOOL isOnProfile;

@property (nonatomic,strong) ECPlaceHolderView * placeholderView;
-(void) updateView;

@property (nonatomic,strong) UIImagePickerController* imagePickerController;
@property (nonatomic,strong) IBOutlet ECToolbar* toolbar;

@property (nonatomic,unsafe_unretained) id <ECPostViewControllerDelegate> delegate;

@property (nonatomic, strong) ECPostCollectionHeaderView* headerView;
@end

@interface ECPlaceHolderView : UIView
@property (nonatomic, strong) IBOutlet UILabel* label1;
@property (nonatomic, strong) IBOutlet UILabel* label2;
@property (nonatomic, strong) IBOutlet UIImageView *liveGIF;
//@property (nonatomic, strong) IBOutlet UIButton* button;
-(id) initWithFrame:(CGRect)frame owner: (id) owner;
@end

@interface ECToolbar : UIToolbar
@property (nonatomic,strong) IBOutlet UIBarButtonItem* addButton;
@end