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

@implementation LocationCell
-(IBAction) openBigMap {
    [Flurry logEvent:@"Opened_Big_Map"];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.location2D addressDictionary:nil];
    MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.venueName];
    [mapItem openInMapsWithLaunchOptions:nil];
}
@end


@implementation LineupCell

-(void) setLineup:(NSArray *)lineup {
    _lineup = lineup;
    self.lineupImages = [[NSMutableArray alloc] initWithCapacity:self.lineup.count];
    
    for (int i = 0; i < self.lineup.count; i++) {
        [self.lineupImages addObject:[NSNull null]];
    }
}
-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger itemNumber = indexPath.row;
    NSDictionary* artist = [self.lineup objectAtIndex:itemNumber];
    NSString* name = [artist objectForKey:@"artist"];
    
    __weak LineupCollectionCell *cell = (LineupCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"LineupCell" forIndexPath:indexPath];
    [cell.artistImage setImage:nil];
    
    if([self.lineupImages objectAtIndex:indexPath.row] == [NSNull null]) {
        [cell.activityIndicator startAnimating];
        [ECJSONFetcher fetchPictureForArtist:name completion:^(NSURL *imageURL) {
            UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
            if (image) {
                [self.lineupImages replaceObjectAtIndex:indexPath.row withObject:image];
                [cell.artistImage setImage: image];
            }
            [cell.activityIndicator stopAnimating];
        }];
    }
    else {
        [cell.artistImage setImage:[self.lineupImages objectAtIndex:indexPath.row]];
    }
    
    cell.artistLabel.text = [[artist objectForKey:@"artist"] uppercaseString];
    
    //    [cell.artistImage setImageWithURL:[artist imageURL] placeholderImage:nil];
    //    cell.artistImage.image = [UIImage imageNamed:@"placeholder"];
    
    cell.artistLabel.font = [UIFont heroFontWithSize:10];
    cell.artistImage.layer.cornerRadius = 5.0;
    cell.artistImage.layer.masksToBounds = YES;
    cell.artistImage.layer.borderColor = [UIColor grayColor].CGColor;
    cell.artistImage.layer.borderWidth = 0.1;
    
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
    [Flurry logEvent:@"Tapped_Lineup_Artist" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:artist,@"artist", nil]];

    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"ECArtistView" bundle:nil];
    ECArtistViewController * vc = [sb instantiateInitialViewController];
    vc.artist = artist;
    vc.artistImage = [self.lineupImages objectAtIndex:row];
    [self.navController pushViewController:vc animated:YES];
}
@end

@implementation LineupCollectionCell

@end

@implementation GrabTicketsCell

-(IBAction) grabTickets {
    [[UIApplication sharedApplication] openURL:self.lastfmURL];
    [Flurry logEvent:@"Tapped_Grab_Tickets" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.lastfmURL, @"URL", nil]];
}

@end

@implementation GetPhotosCell
@end

@implementation DetailsCell


@end
