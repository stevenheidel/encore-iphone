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
-(IBAction) tapPlayButton;
-(id) initWithPost: (NSDictionary*) post;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic,strong) NSDictionary * post;
@property (copy, nonatomic) NSString *artist;
@property (copy, nonatomic) NSString* venueAndDate;

@property (nonatomic,strong) IBOutlet UIImageView * postImage;
@property (nonatomic,strong) IBOutlet UIImageView * profilePicture;
@property (nonatomic,strong) IBOutlet UILabel * captionLabel;
@property (nonatomic,strong) IBOutlet UILabel * userNameLabel;
@property (nonatomic,strong) IBOutlet UIButton* flagPostButton;

@property (nonatomic,assign) NSInteger itemNumber;
@property (nonatomic,strong) IBOutlet UIView* containerView;
@property (nonatomic,readonly) NSString * postID;
@property (nonatomic,unsafe_unretained) id <ECPostViewControllerDelegate> delegate;
@end

@protocol ECPostViewControllerDelegate <NSObject>

-(NSDictionary*) requestPost: (NSInteger) direction currentIndex:(NSInteger) index;

@end