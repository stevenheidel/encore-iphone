//
//  ECCustomSearchBar.m
//  Encore
//
//  Created by Luis Ramirez on 2013-06-23.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECCustomSearchBar.h"

@implementation ECCustomSearchBar

- (void)layoutSubviews {
    [super layoutSubviews];
    UITextField *searchField;

    for( UIView *subview in self.subviews) {
        if([subview isKindOfClass:[UITextField class]]) {
            searchField = (UITextField *)subview;
        }
        if( [subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")] )
        {
            UIView *aView = [[UIView alloc] initWithFrame:subview.bounds];
            aView.backgroundColor = [UIColor whiteColor];
            [subview addSubview:aView];
        }
    }
    if(!(searchField == nil)) {
        [searchField setBorderStyle:UITextBorderStyleLine];
        [searchField setFont:[UIFont fontWithName:@"Hero" size:15.0]];
        [searchField setBorderStyle:UITextBorderStyleNone];
    }
    
    
}

@end