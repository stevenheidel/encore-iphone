//
//  ECRowCells.h
//  Encore
//
//  Created by Shimmy on 2013-08-07.
//  Copyright (c) 2013 Encore. All rights reserved.
//  Various cell subclasses for past and upcoming

#import "ECRowCells.h"
#import "ECJSONFetcher.h"
#import "NSUserDefaults+Encore.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Encore.h"
#import "ECArtistViewController.h"
#import "UIColor+EncoreUI.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "ECConstKeys.h"
@implementation LocationCell
-(void) awakeFromNib {
    self.locationTitleLabel.font = [UIFont heroFontWithSize:ROW_TITLE_SIZE];
    self.contentView.backgroundColor = [UIColor eventRowBackgroundColor];
    self.addressLabel.font = [UIFont lightHeroFontWithSize:15];
    self.startTimeLabel.font = [UIFont lightHeroFontWithSize:14];

    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openBigMap)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:tapRecognizer];
    self.mapView.layer.borderColor = [UIColor blackColor].CGColor;
    self.mapView.layer.borderWidth = 1;
}

-(IBAction) openBigMap {
    [Flurry logEvent:@"Opened_Big_Map"];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.location2D addressDictionary:nil];
    MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.venueName];
    [mapItem openInMapsWithLaunchOptions:nil];
}
@end


@implementation LineupCell
-(void) awakeFromNib {
    self.lineupLabel.font = [UIFont heroFontWithSize:ROW_TITLE_SIZE];
    self.contentView.backgroundColor = [UIColor eventRowBackgroundColor];
    self.lineupImages = nil;
}
-(void) setLineup:(NSArray *)lineup {

    _lineup = lineup;
    
    if(!self.lineupImages) {
        self.lineupImages = [[NSMutableArray alloc] initWithCapacity:self.lineup.count];
        
        for (int i = 0; i < self.lineup.count; i++) {
            [self.lineupImages addObject:[NSNull null]];
        }
    }
}
-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger itemNumber = indexPath.row;
    NSDictionary* artist = [self.lineup objectAtIndex:itemNumber];
    NSString* name = [artist objectForKey:@"artist"];
    
    __weak LineupCollectionCell *cell = (LineupCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"LineupCell" forIndexPath:indexPath];
    [cell.artistImage setImage:nil];
    UIImage* savedImage = [self.lineupImages objectAtIndex:itemNumber];
    if (savedImage != (id) [NSNull null]) {
        [cell.artistImage setImage:savedImage];
    }
    else {
        [cell.activityIndicator startAnimating];
        [ECJSONFetcher fetchPictureForArtist:name completion:^(NSURL *imageURL) {
            
            [cell.artistImage setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL]
                                    placeholderImage:nil
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 if(image)
                                                     [cell.artistImage setImage:image];
                                                 else
                                                     [cell.artistImage setImage:[UIImage imageNamed:@"artist_placeholder"]];
                                                 
                                                 [self.lineupImages replaceObjectAtIndex:indexPath.row withObject:image];
                                                 [cell.activityIndicator stopAnimating];
                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 [cell.artistImage setImage:[UIImage imageNamed:@"artist_placeholder"]];
                                                 [cell.activityIndicator stopAnimating];

                                             }];

        }];
    }
    cell.artistLabel.text = [[artist objectForKey:@"artist"] uppercaseString];
    
    return cell;
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.lineup.count;
}
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
    NSString* artist = [[self.lineup objectAtIndex:indexPath.row] objectForKey:@"artist"];
    [Flurry logEvent:@"Tapped_Lineup_Artist" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:artist,@"artist", [NSNumber numberWithInteger:row], @"lineup_index",nil]];
    
    if ([artist isEqualToString:self.previousArtist]) {
        [self.navController popViewControllerAnimated:YES];
    }
    else {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"ECArtistView" bundle:nil];
        ECArtistViewController * vc = [sb instantiateInitialViewController];
        vc.artist = artist;
        vc.artistImage = [self.lineupImages objectAtIndex:row];
        [self.navController pushViewController:vc animated:YES];
    }
}
@end

@implementation LineupCollectionCell
-(void) awakeFromNib {
    self.artistLabel.font = [UIFont heroFontWithSize:10];
    self.artistImage.layer.cornerRadius = 5.0;
    self.artistImage.layer.masksToBounds = YES;
    self.artistImage.layer.borderColor = [UIColor grayColor].CGColor;
    self.artistImage.layer.borderWidth = 0.1;
}
@end

@implementation GrabTicketsCell
-(void) awakeFromNib {
    self.grabTicketsButton.titleLabel.font = [UIFont heroFontWithSize:20];
    self.grabTicketsButton.layer.cornerRadius = 5.0;
    self.grabTicketsButton.layer.masksToBounds = YES;
    self.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
}


@end

@implementation GetPhotosCell
-(void) awakeFromNib {
    self.grabPhotosButton.titleLabel.font = [UIFont heroFontWithSize:16];
    self.grabPhotosButton.layer.cornerRadius = 5.0;
    self.grabPhotosButton.layer.masksToBounds = YES;
    self.contentView.backgroundColor = [UIColor eventRowBackgroundColor];
}
@end

@implementation SongPreviewCell
-(void) awakeFromNib {
    self.contentView.backgroundColor = [UIColor eventRowBackgroundColor];
    self.lblMusicTitle.font = [UIFont heroFontWithSize:ROW_TITLE_SIZE];
    self.lblSongName.font = [UIFont lightHeroFontWithSize:15];

}
- (IBAction)playpauseButtonTapped:(id)sender {
}

- (IBAction)itunesButtonTapped:(id)sender {
}
@end

@implementation DetailsCell
-(void) awakeFromNib {
    self.contentView.backgroundColor = [UIColor eventRowBackgroundColor];
    self.changeStateButton.titleLabel.font = [UIFont heroFontWithSize:20];
    self.changeStateButton.layer.cornerRadius = 5.0;
    self.changeStateButton.layer.masksToBounds = YES;
}

@end

@implementation FriendsCell
-(void) awakeFromNib {
    self.friendsTitleLabel.font = [UIFont heroFontWithSize:ROW_TITLE_SIZE];
    self.contentView.backgroundColor = [UIColor eventRowBackgroundColor];
    self.noFriendsLabel.hidden = NO;
    self.noFriendsLabel.font = [UIFont lightHeroFontWithSize:15];

}
-(void) setFriends:(NSArray *)friends {
    _friends = friends;
    self.friendImages = [[NSMutableArray alloc] initWithCapacity:self.friends.count];
    
    if (friends.count > 0) {
        for (int i = 0; i < self.friends.count; i++) {
            [self.friendImages addObject:[NSNull null]];
        }
        [self.friendsCollectionView reloadData];
        self.noFriendsLabel.hidden = YES;
        [self.addFriendsButton removeFromSuperview];
    }
    else {
        self.noFriendsLabel.hidden = NO;
    }
}
-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger itemNumber = indexPath.row;
    NSDictionary* friend = [self.friends objectAtIndex:itemNumber];
    NSString* name = [friend objectForKey:@"name"];
    
__weak FriendCollectionCell *cell = (FriendCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
    [cell.activityIndicator startAnimating];
    NSURL* imageURL = [NSURL URLWithString:[friend objectForKey:KeyFacebookImageURL]];
    [cell.friendImage setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL]
                            placeholderImage:[[UIImage alloc] init]
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                         [cell.friendImage setImage:image];
                                         [cell.activityIndicator stopAnimating];
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                         [cell.friendImage setImage:[UIImage imageNamed:@"placeholder"]];
                                         [cell.activityIndicator stopAnimating];

                                     }];
    cell.friendNameLabel.text = name;
    
    return cell;
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.friends.count;
}
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [Flurry logEvent:@"Tapped_Friend" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:indexPath.row], @"index", nil]];
    return;
}
@end

@implementation FriendCollectionCell
-(void) awakeFromNib {
    self.friendNameLabel.font = [UIFont heroFontWithSize:10];
    self.friendImage.layer.cornerRadius = CGRectGetWidth(self.friendImage.frame)/2;
    self.friendImage.layer.masksToBounds = YES;
    self.friendImage.layer.borderColor = [UIColor grayColor].CGColor;
    self.friendImage.layer.borderWidth = 0.1;

}
@end


