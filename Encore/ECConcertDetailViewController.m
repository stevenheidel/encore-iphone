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
}

-(void) loadImages {
    NSString* server_id = [self.concert serverID];
    ECJSONFetcher * fetcher = [[ECJSONFetcher alloc] init];
    fetcher.delegate = self;
    [fetcher fetchPostsForConcertWithID:server_id];
    
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
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    // make the cell's title the actual NSIndexPath value
    cell.label.text = [NSString stringWithFormat:@"{%ld,%ld}", (long)indexPath.row, (long)indexPath.section];
    
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