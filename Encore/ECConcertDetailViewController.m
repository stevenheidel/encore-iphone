//
//  ECConcertDetailViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ECConcertDetailViewController.h"
#import "NSDictionary+ConcertList.h"
#import "Cell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDictionary+Posts.h"
#import "ECJSONPoster.h"
#import "ECPostViewController.h"
#import "ECProfileViewController.h"
#import "UIImage+GaussBlur.h"


#import "SGSStaggeredFlowLayout.h"

NSString *kCellID = @"cellID";

@interface ECConcertDetailViewController (){
    SGSStaggeredFlowLayout* _flowLayout;

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
    self.title = self.artistNameLabel.text;
    
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
    
    [self loadImages];
    
    self.isOnProfile = FALSE;
    [self setUpRightBarButton];
    
    _flowLayout = [[SGSStaggeredFlowLayout alloc] init];
    _flowLayout.layoutMode = SGSStaggeredFlowLayoutMode_Even;
    _flowLayout.minimumLineSpacing = 2.0f;
    _flowLayout.minimumInteritemSpacing = 2.0f;
    _flowLayout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    _flowLayout.itemSize = CGSizeMake(75.0f, 75.0f);
    
    self.collectionView.collectionViewLayout = _flowLayout;
}

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
    
}

-(void) setUpRightBarButton {
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addConcert)];
    self.removeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(removeConcert)];
    
    NSString * userID = self.userID;
    [ECJSONFetcher checkIfConcert:[self.concert songkickID] isOnProfile:userID completion:^(BOOL isOnProfile) {
        if (!isOnProfile) {
            [self.navigationItem setRightBarButtonItem:self.addButton];
            self.isOnProfile = FALSE;
        }
        else {
            [self.navigationItem setRightBarButtonItem:self.removeButton];
            self.isOnProfile = TRUE;
        }
    }];
}
-(NSNumber*) songkickID {
    return [self.concert songkickID];
}

-(NSString*) userID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:NSLocalizedString(@"user_id", nil)];
}

-(void) addConcert {
    NSString * userID = self.userID;
    NSLog(@"%@: Adding concert %@ to profile %@",NSStringFromClass(self.class),self.songkickID.stringValue,userID);
    [ECJSONPoster addConcert:self.songkickID toUser:userID completion:^{
        [self completedAddingConcert];
    }];
}

-(void) removeConcert {
    NSString * userID = self.userID;
    NSNumber * songkickID = self.songkickID;
    NSLog(@"%@: Removing a concert %@ from profile %@",NSStringFromClass(self.class),songkickID,userID);
    [ECJSONPoster removeConcert:songkickID toUser:userID completion:^{
        [self completedRemovingConcert];
    }];
}

-(void) completedAddingConcert {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Woohoo!" message:@"You added a concert" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [self toggleOnProfileState];
    
   #warning [Simon]: probably shouldn't do it this way (ie. popping to root)
    [(ECProfileViewController*)[self.navigationController.viewControllers objectAtIndex:0] updateViewWithNewConcert:self.songkickID];
    [self.navigationController popToRootViewControllerAnimated:YES]; 
}

-(void) completedRemovingConcert {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Woohoo!" message:@"You removed a concert" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [self toggleOnProfileState];
}   

-(void) toggleOnProfileState {
    self.isOnProfile = !self.isOnProfile;
    self.navigationItem.rightBarButtonItem = self.isOnProfile ? self.removeButton : self.addButton;
}

-(void) loadImages {
    NSNumber* serverID = [self.concert serverID];
    if (serverID) {
        ECJSONFetcher * fetcher = [[ECJSONFetcher alloc] init];
        fetcher.delegate = self;
        [fetcher fetchPostsForConcertWithID:serverID];
    }
    else {
        NSLog(@"%@: Can't load images, object doesn't have a server_id", NSStringFromClass([self class]));
        [self setUpPlaceholderView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegateFlowLayout

//TODO: change this to use actual image dimensions or remove it.
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage* thisImage = [UIImage imageNamed:@"instagram.jpg"];
    
    CGSize cellSize;
    CGFloat deviceCellSizeConstant = _flowLayout.itemSize.height;
    cellSize = CGSizeMake((thisImage.size.width*deviceCellSizeConstant)/thisImage.size.height, deviceCellSizeConstant);
    
    return cellSize;
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
    NSDictionary * postDic = [self.posts objectAtIndex:indexPath.row];
    if(!cell.image) {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imageView];
        cell.image=imageView;
        cell.contentView.clipsToBounds = YES;
    }
    
    if(self.posts.count > 0) {
        NSURL *imageToLoad = [postDic imageURL];
        [cell.image setImageWithURL:imageToLoad];
    }
    
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ECPostViewController * postVC = [[ECPostViewController alloc] init];
    postVC.post = [self.posts objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:postVC animated:YES];
}

-(void) setUpPlaceholderView {
    if(!self.placeholderView){
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECPostPlaceholder" owner:nil options:nil];
        self.placeholderView = [subviewArray objectAtIndex:0];
        self.placeholderView.frame = self.collectionView.frame;
    }
    if(!self.placeholderView.superview) {
        [self.view addSubview:self.placeholderView];
    }
}

#pragma mark - json fetcher delegate
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

@end
