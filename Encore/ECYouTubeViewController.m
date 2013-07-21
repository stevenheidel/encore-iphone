//
//  ECYouTubeViewController.m
//  Encore
//
//  Created by Shimmy on 2013-07-21.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECYouTubeViewController.h"

@interface ECYouTubeViewController () {
}

@end

@implementation ECYouTubeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithLink: (NSURL*) link {
    if (self = [super init]) {
        self.link = link;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 212\"/></head><body style=\"background:#FFF;margin-top:0px;margin-left:0px\"><div><object width=\"568\" height=\"320\"><param name=\"movie\" value=\"%@\"></param><param name=\"wmode\"value=\"transparent\"></param><embed src=\"%@\"type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"212\" height=\"172\"></embed></object></div></body></html>",self.link.absoluteString,self.link.absoluteString];

    [self.youTubeWebView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://encore.fm"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
