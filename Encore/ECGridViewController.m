//
//  ECGridViewController.m
//  
//
//  Created by Shimmy on 2013-08-08.
//
//

#import "ECGridViewController.h"
#import "NSDictionary+ConcertList.h"
#import "NSDictionary+Posts.h"
#import "ECJSONFetcher.h"
#import "ECJSONPoster.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+EncoreUI.h"
#import "UIFont+Encore.h"
#import "ECPostViewController.h"

@implementation ECPostCell

-(void) setPostType:(ECPostType)postType {
    _postType = postType;
    self.playButton.hidden = postType != ECVideoPost;
}

@end

@implementation ECGridHeaderView

@end


@interface ECGridViewController ()

@end

@implementation ECGridViewController

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
	// Do any additional setup after loading the view.
    [ECJSONPoster populateConcert:self.concert.eventID completion:^(BOOL success) {
        [ECJSONFetcher fetchPostsForConcertWithID:self.concert.eventID completion:^(NSArray *fetchedPosts) {
            self.posts = fetchedPosts;
            [self.collectionView reloadData];
        }];
    }];
    
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = encoreLogo;
    self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
}
-(void) backButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"GridToPostViewController"]) {
        ECPostViewController* vc = (ECPostViewController*)[segue destinationViewController];
        NSUInteger row = [[[self.collectionView indexPathsForSelectedItems] objectAtIndex:0] row];
        
        vc.post = [self.posts objectAtIndex:row];
        vc.artist = [self.concert eventName];
        vc.venueAndDate = [self.concert venueAndDate];
        vc.itemNumber = row;
        vc.delegate = self;
        }
}

#pragma mark - collection view
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.posts.count;
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak ECPostCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"post" forIndexPath:indexPath];
    
    NSDictionary* post = [self.posts objectAtIndex:indexPath.row];
    [cell.activityIndicator startAnimating];
    [cell.postImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[post imageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.postImageView.image = image;
        [cell.activityIndicator stopAnimating];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [cell.activityIndicator stopAnimating];
    }];
    
    cell.postType = [post postType];
    return cell;
}

-(UICollectionReusableView*) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        ECGridHeaderView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerview" forIndexPath:indexPath];
        
        headerView.eventLabel.text = [[self.concert eventName] uppercaseString];
        [headerView.eventLabel setFont:[UIFont heroFontWithSize:16.0f]];
        [headerView.eventLabel setTextColor:[UIColor blueArtistTextColor]];
        headerView.venueAndDateLabel.text = [self.concert venueAndDate];
        [headerView.venueAndDateLabel setFont:[UIFont heroFontWithSize:12.0f]];
        return headerView;
    }
    return nil;
}

#pragma mark - PostViewControllerDelegate (swipe transitions between posts)

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

@end
