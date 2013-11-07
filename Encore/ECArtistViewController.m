//
//  ECArtistViewController.m
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECArtistViewController.h"
#import "ECJSONFetcher.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Encore.h"
#import "UIColor+EncoreUI.h"
#import "MBProgressHUD.h"
#import "ECUpcomingViewController.h"
#import "ECPastViewController.h"
#import "UIImage+GaussBlur.h"
#import "UIImage+Merge.h"
#import "ECSearchResultCell.h"
#import "ECRowCells.h"
#import "defines.h"
#import "UIImageView+AFNetworking.h"

#import "AFNetworking.h"

#define SearchCellIdentifier @"ECSearchResultCell"

typedef enum {
    ArtistInfoMusicSection,
    ArtistInfoEventSection,
    ArtistInfoNumSections
}ArtistInfoSections;

@interface ECArtistViewController (){
    UIAlertView* alert;
}
@end

@implementation ECArtistViewController

#pragma mark - autorotation
-(BOOL)shouldAutorotate{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - view loading
-(void) viewWillDisappear:(BOOL)animated {
    [self.hud removeFromSuperview];
    self.hud = nil;
    alert = nil;
    [self.infoOperation cancel];
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad
{
    [self.tableView registerNib:[UINib nibWithNibName:@"ECSearchResultCell" bundle:nil]
         forCellReuseIdentifier:SearchCellIdentifier];
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor separatorColor];
    
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton"];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;


    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:hud];
    hud.color = [UIColor lightBlueHUDConfirmationColor];
    hud.userInteractionEnabled = NO;
	[hud show:YES];
    hud.labelText = [NSString stringWithFormat:@"Loading recent events"];
    self.hud = hud;
    alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, something went wrong. No events were found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    self.infoOperation = [ECJSONFetcher fetchInfoForArtist:self.artist completion:^(NSDictionary *artistInfo) {
        self.events = [artistInfo objectForKey:@"events"];
        UISegmentedControl* control = self.sectionHeaderView.segmentedControl;
        NSInteger pastCount = self.pastEvents.count;
        NSInteger upcomingCount = self.upcomingEvents.count;
        if (!pastCount>0) {
            self.currentSelection = UpcomingSegment;
        }
        else {
            self.currentSelection = PastSegment;
        }
        control.selectedSegmentIndex = self.currentSelection;
        
        [control setEnabled:pastCount != 0 forSegmentAtIndex:PastSegment];
        [control setEnabled:upcomingCount != 0 forSegmentAtIndex:UpcomingSegment];
//        [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        [hud hide:YES];
        if ((pastCount == 0 && upcomingCount == 0) || artistInfo == nil) {
            if (alert)
                [alert show];
        }
    }];
    //Fetch song previews
    [ECJSONFetcher fetchSongPreviewsForArtist:self.artist completion:^(NSArray *songs) {
        self.songs = [NSArray arrayWithArray:songs];
        self.currentSongIndex = 0;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:ArtistInfoMusicSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    if (self.artistImage == (id)[NSNull null] || !self.artistImage) {
        [ECJSONFetcher fetchPictureForArtist:self.artist completion:^(NSURL *imageURL) {
            [self.artistImageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                self.artistImage = image;
                self.artistImageView.image = self.artistImage;
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                self.artistImage = [UIImage imageNamed:@"placeholder"];
                self.artistImageView.image = self.artistImage;
            }];
        }];
    }
    else {
        self.artistImageView.image = self.artistImage;
    }
    self.artistImageView.layer.cornerRadius = 5.0;
    self.artistImageView.layer.masksToBounds = YES;
    self.artistImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.artistImageView.layer.borderWidth = 0.1;
    
    self.artistNameLabel.text = [self.artist uppercaseString];
    self.artistNameLabel.font = [UIFont heroFontWithSize:16.f];
    self.artistNameLabel.textColor = [UIColor blueArtistTextColor];
    
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = encoreLogo;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    [self setBackgroundImage];
}

-(void) setBackgroundImage {
    UIImage* image =  self.artistImage;
    if(image != (id) [NSNull null] && image != nil) {
        UIImage* backgroundImage = [UIImage mergeImage:[image imageWithGaussianBlur]
                                         withImage:[UIImage imageNamed:@"fullgradient"]];
    
        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        [tempImageView setFrame:self.tableView.frame];
        tempImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.tableView.backgroundView = tempImageView;
    }
}

-(void) backButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    if (section == ArtistInfoEventSection) {
        if (self.currentSelection == PastSegment) {
            UIStoryboard* pastBoard = [UIStoryboard storyboardWithName:@"ECPastStoryboard" bundle:nil];
            ECPastViewController* pastVC =  (ECPastViewController*)[pastBoard instantiateInitialViewController];
            pastVC.concert = [self.pastEvents objectAtIndex:indexPath.row];
            pastVC.tense = ECSearchTypePast;
            pastVC.previousArtist = self.artist;
            [self.navigationController pushViewController:pastVC animated:YES];
        }
        else {
            UIStoryboard* upcomingBoard = [UIStoryboard storyboardWithName:@"ECUpcomingStoryboard" bundle:nil];
            ECUpcomingViewController* upcomingVC = (ECUpcomingViewController*) [upcomingBoard instantiateInitialViewController];
            upcomingVC.concert = [self.upcomingEvents objectAtIndex:indexPath.row];
            upcomingVC.tense = ECSearchTypeFuture;
            upcomingVC.previousArtist = self.artist;
            [self.navigationController pushViewController:upcomingVC animated:YES];
        }
        [Flurry logEvent:@"Main_Selected_Row" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Artist_%@",self.currentSelection==PastSegment ? @"Past" : @"Upcoming"], @"Search_Type", [NSNumber numberWithInt:indexPath.row], @"row", @"n/a", @"is_post_search", nil]];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return ArtistInfoNumSections;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == ArtistInfoMusicSection) {
        return 1;
    }
    else if (section == ArtistInfoEventSection) {
        return [[self currentEventArray] count];
    }
    return 0;
}

-(NSArray*) pastEvents {
    return [self.events objectForKey:@"past"];
}
-(NSArray*) upcomingEvents {
    return [self.events objectForKey:@"upcoming"];
}

-(NSArray*) currentEventArray {
    switch (self.currentSelection) {
        case UpcomingSegment :
            return self.upcomingEvents;
        case PastSegment:
            return self.pastEvents;
        default:
            return nil;
    }
}

//-(NSString*) titleForSection: (NSInteger) section {
//    switch (section) {
//        case ArtistInfoPastSection:
//            return @"PAST";
//        case ArtistInfoUpcomingSection:
//            return @"UPCOMING";
//    }
//    return nil;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == ArtistInfoMusicSection) {
        return 0.0f;
    }
    else if (section == ArtistInfoEventSection) {
        return 75.0f;
    }
    return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (ArtistInfoMusicSection) {
        return nil;
    }
    if (self.sectionHeaderView == nil) {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECArtistSectionHeaderView" owner:nil options:nil];
        ECPastUpcomingSectionHeader* view = [subviewArray objectAtIndex:0];
        view = [subviewArray objectAtIndex:0];
        view.titleLabel.font = [UIFont heroFontWithSize:ROW_TITLE_SIZE];
        view.artistVC = self;
        view.segmentedControl.selectedSegmentIndex = self.currentSelection;
        [self.sectionHeaderView setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.sectionHeaderView = view;
    }
    return self.sectionHeaderView;
}

-(NSDictionary*) eventForIndexPath: (NSIndexPath*) indexPath {
    NSUInteger section = indexPath.section;
    if (section == ArtistInfoEventSection) {
        if (self.currentSelection == PastSegment) {
            return [[self.events objectForKey:@"past"] objectAtIndex:indexPath.row];
        }
        else return [[self.events objectForKey:@"upcoming"] objectAtIndex:indexPath.row];
    }
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == ArtistInfoMusicSection) {
        return 76.0f;
    }
    else return 70.0f;
}

-(NSString*) identifierForIndexPath: (NSIndexPath*)indexPath {
    NSInteger section = indexPath.section;
    if (section == ArtistInfoMusicSection) {
        return @"songpreview";
    }
    else return SearchCellIdentifier;
    
    return nil;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = [self identifierForIndexPath:indexPath];
    if (indexPath.section == ArtistInfoMusicSection) {
        SongPreviewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];

        if(!self.songInfo){
            [cell.btnPlay setEnabled:NO];
            [cell.btnItunes setEnabled:NO];
            
        }else{
            [cell.btnPlay setEnabled:YES];
            [cell.btnItunes setEnabled:YES];
            [cell.btnPlay addTarget:self
                             action:@selector(playpauseButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
            [cell.btnItunes addTarget:self
                               action:@selector(openItunesLink)
                     forControlEvents:UIControlEventTouchUpInside];
        }
        [cell.lblSongName setText:self.songInfo[@"trackCensoredName"]];
        
        if(self.player.rate == 1.0){
            [cell.btnPlay setSelected:YES];
        }
        return cell;
    }
    else {
        NSArray* selectedArray = [self currentEventArray];
        
        ECSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        [cell setBackgroundColor:[UIColor eventRowBackgroundColor]];
        NSDictionary * eventDic = [selectedArray objectAtIndex:indexPath.row];
        [cell setupCellForEvent:eventDic];
        // remove scroll view background color and keep the cell background color
        for(UIView *subview in cell.subviews){
            if([subview isKindOfClass:[UIScrollView class]]){
                UIScrollView *theScrollView = (UIScrollView *)subview;
                [theScrollView setBackgroundColor:[UIColor clearColor]];
            }
        }
        return cell;
    }
    
    return nil;
}


#pragma mark - Play/Pause Song preview

-(NSDictionary*) songInfo {
    //    NSLog(@"Song %@",[self.songs objectAtIndex:self.currentSongIndex]);
    if (self.songs.count >0) {
        return [self.songs objectAtIndex:self.currentSongIndex];
    }
    return nil;
}

-(void)prepareCurrentSong
{
    NSURL *url = [NSURL URLWithString:self.songInfo[@"previewUrl"]];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
}
- (void) playpauseButtonTapped:(UIButton*)button
{
    if(!self.player)
        [self prepareCurrentSong];
    
    [button setSelected:!button.selected];
    if (self.player.rate == 1.0) {
        [self.player pause];
    } else {
        [self.player play];
    }
    [Flurry logEvent:@"Tapped_Play_Button" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Artist",@"PageType",self.artist, @"artist", nil]];
}
-(void)songDidFinishPlaying
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                                 object:self.player.currentItem];
    if(self.currentSongIndex < self.songs.count-1){
        self.currentSongIndex++;
        [self prepareCurrentSong];
        [self.player play];
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:ArtistInfoMusicSection]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        //Reset everything back
        self.currentSongIndex = 0;
        self.player= nil;
        //Reload the view
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:SongPreview inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        //Deselect the button
        SongPreviewCell * songCell =(SongPreviewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ArtistInfoMusicSection]];
        [songCell.btnPlay setSelected:NO];
    }
    
}

-(void)openItunesLink
{
    NSString* affliateURL = [self.songInfo[@"trackViewUrl"] stringByAppendingFormat:@"&at=%@",kAffiliateCode];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:affliateURL]];
    
    [Flurry logEvent:@"Tapped_iTunes_Link" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Artist", @"PageType", self.artist,@"artist", nil]];
}

-(void) setCurrentSelection:(SegmentedControlIndices)currentSelection {
    _currentSelection = currentSelection;
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:ArtistInfoEventSection];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end

@implementation ECPastUpcomingSectionHeader
-(void) awakeFromNib {
    [self.titleLabel setFont:[UIFont lightHeroFontWithSize:ROW_TITLE_SIZE]];
}

- (IBAction)switchedSelection:(id)sender {
    NSInteger selectedIndex = [(UISegmentedControl*) sender selectedSegmentIndex];
    self.artistVC.currentSelection = selectedIndex;
}
@end
