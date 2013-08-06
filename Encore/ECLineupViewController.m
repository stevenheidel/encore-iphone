//
//  ECLineupViewController.m
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECLineupViewController.h"

typedef enum {
    HeadlinerSection,
    OpenerSection,
    NumSectionsInLineupVC
}ECLineupSections;

@interface ECLineupCell : UITableViewCell

@end
@implementation ECLineupCell


@end

@interface ECLineupViewController ()

@end

@implementation ECLineupViewController

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
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:@"ECLineupCell" bundle:nil]
         forCellReuseIdentifier:@"ECLineupCell"];
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.titleView = encoreLogo;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return NumSectionsInLineupVC;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == OpenerSection) {
        return self.artists.count;
    }
    else return 1;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == OpenerSection ? @"Openers" : @"Headliner";
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myIdentifier = @"ECLineupCell";
    
    ECLineupCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
    
    NSString * artistName = indexPath.section == OpenerSection ? [self.artists objectAtIndex:indexPath.row] : self.headliner;
    cell.textLabel.text = artistName;
    
    return cell;

}
@end
