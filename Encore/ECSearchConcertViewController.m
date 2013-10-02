//
//  ECSearchConcertViewController.m
//  Encore
//
//  Created by Mohamed Fouad on 9/18/13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECSearchConcertViewController.h"
#import "UIFont+Encore.h"
#import "ECNewMainViewController.h"
#import "NSUserDefaults+Encore.h"
#import "ECAlertTags.h"
#import "ECAppDelegate.h"
#import "ECJSONFetcher.h"
#import "ECSearchResultCell.h"
#import "ECConcertCellView.h"
#define SearchCellIdentifier @"ECSearchResultCell"
#define ConcertCellIdentifier @"ECConcertCellView"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ECPastViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#define SEARCH_HEADER_HEIGHT 98.0f
#define ALERT_HIDE_DELAY 2.0

#import "UIColor+EncoreUI.h"

typedef enum {
    ECSearchResultSection,
    ECSearchLoadOtherSection,
    ECNumberOfSearchSections //always have this one last
}ECSearchSection;

@interface ECSearchConcertViewController ()<UITextFieldDelegate>
{
    UIView* lastFMView;
}
@property (nonatomic, assign) CGFloat currentSearchRadius;
@property (nonatomic, strong) CLLocation* currentSearchLocation;
@property (nonatomic, strong) NSArray* concerts;
@property (assign, nonatomic) BOOL hasSearched; //Flag for whether use has performed a search
@property(nonatomic, readonly) NSArray *searchResultsEvents;
@property(nonatomic, readonly) NSDictionary *searchedArtistDic;
@property(nonatomic, readonly) NSArray *otherArtists;
@property (nonatomic, strong) NSDictionary* comboSearchResultsDic;

@property (strong, nonatomic) MBProgressHUD * hud;
@property (strong, nonatomic) UIView* searchHeaderView;
@property (nonatomic, strong) UIView* noConcertsFooterView;
@property (strong, nonatomic) UITapGestureRecognizer *tap;


@end

@implementation ECSearchConcertViewController

-(NSArray*) searchResultsEvents {
    if (self.comboSearchResultsDic != nil) {
        return [self.comboSearchResultsDic objectForKey:@"events"];
    }
    return nil;
}

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
    [self setApperance];
    [self setupLastFMView];
    [self initializeSearchLocation];
    self.tap = [[UITapGestureRecognizer alloc]
                initWithTarget:self
                action:@selector(dismissKeyboard:)];

    //if user already set location using select location controller don't listen to location changes
    if([NSUserDefaults lastSearchLocation].coordinate.latitude == 0 && [NSUserDefaults lastSearchLocation].coordinate.longitude == 0)
    {
        [(ECAppDelegate*)[[UIApplication sharedApplication] delegate] setUpLocationManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LocationAcquired) name:ECLocationAcquiredNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LocationFailed) name:ECLocationFailedNotification object:nil];
    }
    
    else {
        //TODO: Check network connection status before fetching anything
        if (![ApplicationDelegate connected]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No connection!" message:@"You must be connected to the internet to use Encore. Sorry pal." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Try again", nil];
            alert.tag = ECNoNetworkAlertTag;
            [alert show];
        }
        else {
            [self fetchPopularConcertsWithSearchType:ECSearchTypePast];
        }
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}
- (void) setApperance
{
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    [self.lblSearchConcert setFont:[UIFont heroFontWithSize:15]];
    UIView* paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIImageView* magnifyingGlass = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 11, 11)];
    magnifyingGlass.image = [UIImage imageNamed:@"magnifyingglass"];
    [paddingView addSubview:magnifyingGlass];
    
    self.searchbar.leftView = paddingView;
    self.searchbar.leftViewMode = UITextFieldViewModeAlways;
    self.searchbar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.searchbar.font = [UIFont heroFontWithSize:18.0f];
    
    self.searchbar.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [self.searchbar setTextColor:[UIColor blackColor]];
    
    UIColor *color = [UIColor darkGrayColor];
    self.searchbar.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: color}];

}
-(void) setupLastFMView {
    lastFMView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableview.frame.size.width,133.0f)];
    UIButton* lastFMBUtton = [[UIButton alloc] initWithFrame:CGRectMake(100.0f, 6.0f, 98.0f, 13.0f)];
    [lastFMBUtton addTarget:self action:@selector(openLastFM:) forControlEvents:UIControlEventTouchUpInside];
    [lastFMBUtton setBackgroundImage:[UIImage imageNamed:@"lastfmAttr"] forState:UIControlStateNormal];
    [lastFMBUtton setContentMode:UIViewContentModeScaleAspectFit];
    [lastFMView addSubview: lastFMBUtton];
    self.tableview.tableFooterView = lastFMView;
}
- (IBAction)openLastFM:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.last.fm"]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotate{
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
#pragma mark - Location Methods

-(void) initializeSearchLocation {
    self.currentSearchLocation = [NSUserDefaults lastSearchLocation];
    self.currentSearchRadius = [NSUserDefaults lastSearchRadius];
}

-(void)LocationAcquired
{
    NSLog(@"Location acquired");
    [self initializeSearchLocation];// automatically figures out if there's a saved one and if not returns the user coordinate
    [self fetchPopularConcertsWithSearchType:ECSearchTypePast];
}
-(void)LocationFailed
{

    NSLog(@"Location failed");
    [self performSegueWithIdentifier:@"ECSkipButtonTapped" sender:Nil];

}

#pragma mark - Concerts Methods

-(void) fetchPopularConcertsWithSearchType: (ECSearchType) type {
    [ECJSONFetcher fetchPopularConcertsWithSearchType:type location:self.currentSearchLocation radius:[NSNumber numberWithFloat:self.currentSearchRadius] completion:^(NSArray *concerts) {
        [self fetchedPopularConcerts:concerts forType:type];
    }];
}

-(void) fetchedPopularConcerts: (NSArray*) concerts forType: (ECSearchType) searchType {

    self.concerts = [[NSArray alloc] initWithArray:concerts];
    
    if ([self concerts].count == 0) {
        self.tableview.tableFooterView = self.noConcertsFooterView;
    }
    [self.hud hide:YES];

    [self.tableview reloadData];
    
}

-(UIView*) noConcertsFooterView {
    if(_noConcertsFooterView == nil) {
        _noConcertsFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        _noConcertsFooterView.backgroundColor = [UIColor clearColor];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(5,5,315,150)];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.tag = 213;
        
        [_noConcertsFooterView addSubview:label];
    }
    
    UILabel* label = (UILabel*)[_noConcertsFooterView viewWithTag:213];
    label.text = [NSString stringWithFormat:@"No one has added a show in your area recently.\n\nSearch for a show above"];
    
    return _noConcertsFooterView;
}
#pragma mark - Searchbar Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.view addGestureRecognizer:self.tap]; //for dismissing the keyboard if tap outside
}
- (IBAction)dismissKeyboard:(id)sender {
    [self.searchbar resignFirstResponder];
    [self.view removeGestureRecognizer:self.tap];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchbar resignFirstResponder];

    if ([textField.text length] > 0) { //don't search empty searches
        [ECJSONFetcher fetchArtistsForString:textField.text withSearchType:ECSearchTypePast
                                 forLocation:self.currentSearchLocation
                                      radius: [NSNumber numberWithFloat:self.currentSearchRadius]
                                  completion:^(NSDictionary * comboDic) {
            [self fetchedConcertsForSearch:comboDic];
        }];
        
        self.hud.labelText = NSLocalizedString(@"Searching", nil);
        self.hud.detailsLabelText = [NSString stringWithFormat:NSLocalizedString(@"hudSearchArtist", nil), [textField text]];
        [self.hud show:YES];
        
    }
    [self.view removeGestureRecognizer:self.tap];
    [textField resignFirstResponder];
    return YES;
}
-(void) resetTableHeaderView {
    if ([self.searchHeaderView isDescendantOfView:self.tableview.tableHeaderView]) {
        UIView* header =self.tableview.tableHeaderView;
        CGRect frame = header.frame;
        frame.size.height = frame.size.height - SEARCH_HEADER_HEIGHT;
        header.frame = frame;
        [self.searchHeaderView removeFromSuperview];
        self.tableview.tableHeaderView = header;
    }
}
- (void)fetchedConcertsForSearch:(NSDictionary *)comboDic {
    [self.hud hide:YES];
    [self resetTableHeaderView];
    self.tableview.tableFooterView = lastFMView;
    if (comboDic) {
        self.hasSearched = TRUE;
        self.comboSearchResultsDic = comboDic;
        if (![self.searchResultsEvents count] > 0) {
            self.hasSearched = FALSE;
            self.comboSearchResultsDic = nil;
            MBProgressHUD* alert = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            alert.labelText = NSLocalizedString(@"No events found", nil);
            alert.mode = MBProgressHUDModeText;
            alert.removeFromSuperViewOnHide = YES;
            [alert hide:YES afterDelay:ALERT_HIDE_DELAY];
            alert.labelFont = [UIFont heroFontWithSize:18.0f];
            alert.color = [UIColor redHUDConfirmationColor];
            alert.userInteractionEnabled = NO;
        }
    }
    else { //failed to find anything
        self.hasSearched = FALSE;
        self.comboSearchResultsDic = nil;
        MBProgressHUD* alert = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        alert.labelText = NSLocalizedString(@"No artists found",nil);
        alert.mode = MBProgressHUDModeText;
        alert.removeFromSuperViewOnHide = YES;
        [alert hide:YES afterDelay:ALERT_HIDE_DELAY]; //TODO use #define for delay
        alert.labelFont = [UIFont heroFontWithSize:18.0f];
        alert.color = [UIColor redHUDConfirmationColor];
        alert.userInteractionEnabled = NO;
    }
    
    [self.tableview reloadData];
    [self addArtistImageToHeader];
}
-(void) addArtistImageToHeader {
    if (self.searchResultsEvents.count > 0) {
        if(!self.searchHeaderView) {
            NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"SearchResultsSectionHeader" owner:nil options:nil];
            self.searchHeaderView = [subviewArray objectAtIndex:0];
        }
        UIImageView* artistImage = (UIImageView*)[self.searchHeaderView viewWithTag:10];
        if ([self.searchedArtistDic imageURL]) {
            [artistImage setImageWithURL:[self.searchedArtistDic imageURL] placeholderImage:[UIImage imageNamed: @"placeholder.jpg"]];
        }
        else {
            [artistImage setImageWithURL:[[self.searchResultsEvents objectAtIndex:0] imageURL] placeholderImage:[UIImage imageNamed: @"placeholder.jpg"]];
        }
        
        artistImage.layer.cornerRadius = 5.0;
        artistImage.layer.masksToBounds = YES;
        
        self.searchHeaderView.clipsToBounds =YES;
        CGRect headerFrame = self.tableview.tableHeaderView.frame;
        
        self.searchHeaderView.frame = CGRectMake(0,headerFrame.size.height,320,SEARCH_HEADER_HEIGHT);
        headerFrame.size.height = headerFrame.size.height + SEARCH_HEADER_HEIGHT;
        UIView* header = self.tableview.tableHeaderView;
        header.frame = headerFrame;
        [header addSubview:self.searchHeaderView];
        self.tableview.tableHeaderView = header;
    }
}


#pragma mark - Tabelview Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //    if (self.hasSearched) {
    //        return ECNumberOfSearchSections;
    //    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.hasSearched) {
        return [self.searchResultsEvents count];
    }
    else {
        return [self.concerts count];
    }
    return 0;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasSearched) {
        if (indexPath.section == ECSearchResultSection) {
            ECSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier forIndexPath:indexPath];
            NSDictionary * eventDic = [self.searchResultsEvents objectAtIndex:indexPath.row];
            [cell setupCellForEvent:eventDic];
            return cell;
        }
    }
    else { //popular concert cell
        ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:ConcertCellIdentifier forIndexPath:indexPath];
        NSDictionary * concertDic = [self.concerts objectAtIndex:indexPath.row];
        
        
        [cell setUpCellForConcert:concertDic];
        cell.lblName.textColor = [UIColor whiteColor];

        //Using UIImageView+AFNetworking, automatically set the cell's image view based on the URL
        [cell.imageArtist setImageWithURL:[concertDic imageURL] placeholderImage:nil]; //TODO add placeholder
        
        return cell;
    }
    
    return nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissKeyboard:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasSearched) {
        return SEARCH_CELL_HEIGHT;
    } else {
        return 85;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.hasSearched) {
        if (indexPath.section == ECSearchLoadOtherSection) {
            [self.tableview reloadData];
        }
        else {
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                UIStoryboard* sb = [UIStoryboard storyboardWithName:@"ECPastStoryboard" bundle:nil];
                ECPastViewController * vc = [sb instantiateInitialViewController];
                vc.tense = ECSearchTypePast;
                vc.hideShareButton = YES;
                vc.concert = [self.searchResultsEvents objectAtIndex:indexPath.row];
                [self.navigationController pushViewController:vc animated:YES];
                [self.navigationController setNavigationBarHidden:NO animated:YES];

            
        }
    }
    else {

        NSDictionary* concert = [self.concerts objectAtIndex:indexPath.row];
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"ECPastStoryboard" bundle:nil];
            ECPastViewController * vc = [sb instantiateInitialViewController];
            vc.tense = ECSearchTypePast;
            vc.concert = concert;
            vc.hideShareButton = YES;
            [self.navigationController pushViewController:vc animated:YES];
            [self.navigationController setNavigationBarHidden:NO animated:YES];

           }
}
-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
@end
