//
//  ECNewMainViewController.m
//  Encore
//
//  Created by Shimmy on 2013-07-08.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECNewMainViewController.h"
#import "ECJSONFetcher.h"
#import "ECSearchType.h"
@interface ECNewMainViewController ()

@end

@implementation ECNewMainViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View loading
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupBarButtons];
    [self setNavBarAppearance];
}

//Set up left bar button for going to profile and right bar button for sharing
-(void) setupBarButtons {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"profileButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(profileTapped) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = profileButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButImage = [UIImage imageNamed:@"shareButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
    self.shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.shareButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.shareButton;
}

-(void) setNavBarAppearance {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor blackColor]];
    
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.titleView = encoreLogo;
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.arrTodaysConcerts == nil) {
        [ECJSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypeToday completion:^(NSArray *concerts) {
            [self fetchedPopularConcerts:concerts];
        }];
//        [self.hud show:YES];
    }
}

-(void) fetchedPopularConcerts:(NSArray *)concerts {
    self.arrTodaysConcerts = concerts;
    NSLog(@"%@", self.arrTodaysConcerts.description);
//    for (NSDictionary *concertDic in concerts) {
//        NSURL *imageURL = [concertDic imageURL];
//        UIImage *regImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
//        if (regImage) {
//            [self.arrTodaysImages addObject:regImage];
//        } else {
//            [self.arrTodaysImages addObject:[UIImage imageNamed:@"placeholder.jpg"]];
//        }
//    }
    [self.tableView reloadData];
//    [self.hud hide:YES];
//    [self setupAttribution];
    //    [self.delegate doneLoadingTodayConcerts];
}


#pragma mark - Buttons
-(void)profileTapped {
    if (self.profileViewController == nil) {
        self.profileViewController = [[ECProfileViewController alloc] init];
//        self.profileViewController.arrPastConcerts = [self.concerts objectForKey:@"past"];
    }
    
    [self.navigationController pushViewController:self.profileViewController animated:YES];
    [Flurry logEvent:@"Profile_Button_Pressed"];
}


-(IBAction) switchedSelection: (id) sender {
    
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    NSLog(@"thanks for switching me! %d",control.selectedSegmentIndex);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) fetchConcerts {
//    [ECJSONFetcher fetchConcertsForUserID:self.facebook_id completion:^(NSDictionary *concerts) {
//        NSLog(@"Successfully fetched %d past concerts and %d future concerts", [[concerts past] count],[[concerts future]count]);
        //NSLog(@"Fetched concerts for user:%@", concerts);
//        self.concerts = [NSMutableDictionary dictionaryWithDictionary: concerts];
        //        [self setUpHorizontalSelect]; //only setting up horizontal select once the concert data is received
        //        [self selectTodayCell];
        
//    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.arrTodaysConcerts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
//    cell.textLabel.text =
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
