//
//  ECConcertDetailViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECConcertDetailViewController.h"
#import "NSDictionary+ConcertList.h"
#import "Cell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDictionary+Posts.h"
#import "ECJSONPoster.h"
#import "ECPostViewController.h"

NSString *kCellID = @"cellID";

@interface ECConcertDetailViewController ()

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
    [self.collectionView registerNib:[UINib nibWithNibName:@"ECCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"cellID"];
    // Do any additional setup after loading the view from its nib.
    self.artistNameLabel.text = [self.concert artistName];
    self.dateLabel.text = [self.concert niceDate];
    self.venueNameLabel.text = [self.concert venueName];
    self.title = self.artistNameLabel.text;
    [self loadImages];
    
    self.isOnProfile = FALSE;
    [self setUpRightBarButton];
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
    else NSLog(@"%@: Can't load images, object doesn't have a server_id", NSStringFromClass([self class]));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view delegate/data source

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [self.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    if(!self.posts){
        cell.image.image = [UIImage imageNamed:nil]; //TODO replace with blank?
        return cell;
    }
    // load the image for this cell
    NSDictionary * postDic = [self.posts objectAtIndex:indexPath.row];
    
    NSURL *imageToLoad = [postDic imageURL];
    [cell.image setImageWithURL:imageToLoad];
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ECPostViewController * postVC = [[ECPostViewController alloc] init];
    postVC.post = [self.posts objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:postVC animated:YES];
}

#pragma mark - json fetcher delegate
-(void) fetchedPosts: (NSArray *) posts {
    self.posts = posts;
    [self.collectionView reloadData];
}

@end
