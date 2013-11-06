//
//  ECViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ECPostViewControllerDelegate;
@interface ECPostViewController : UIViewController <UIActionSheetDelegate> 
-(IBAction)flagPhoto;
//-(IBAction) tapPlayButton;
-(id) initWithPost: (NSDictionary*) post;
@property (nonatomic, assign) BOOL youtubeShowing;
//@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic,strong) NSDictionary * post;
@property (copy, nonatomic) NSString *artist;
@property (copy, nonatomic) NSString* venueAndDate;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic,weak) IBOutlet UIImageView * postImageView;
@property (nonatomic,weak) IBOutlet UIImageView * profilePicture;
@property (nonatomic,weak) IBOutlet UILabel * captionLabel;
@property (nonatomic,weak) IBOutlet UILabel * userNameLabel;
@property (nonatomic,weak) IBOutlet UIButton* flagPostButton;
@property (nonatomic,assign) NSInteger itemNumber;
@property (nonatomic,strong) IBOutlet UIView* containerView;
@property (nonatomic,readonly) NSString * postID;
@property (assign) BOOL showShareButton;

@property (nonatomic,unsafe_unretained) id <ECPostViewControllerDelegate> delegate;
- (IBAction)playButtonTapped:(id)sender;

@end

@protocol ECPostViewControllerDelegate <NSObject>

-(NSDictionary*) requestPost: (NSInteger) direction currentIndex:(NSInteger) index;

@end