//
//  ECGridViewController.h
//  
//
//  Created by Shimmy on 2013-08-08.
//
//

#import <UIKit/UIKit.h>
#import "ECPostType.h"
#import "ECPostViewController.h"

@interface ECGridHeaderView : UICollectionReusableView
@property (nonatomic,weak) IBOutlet UILabel* eventLabel;
@property (nonatomic,weak) IBOutlet UILabel* venueAndDateLabel;

@end

@interface ECGridViewController : UICollectionViewController <ECPostViewControllerDelegate>
@property (nonatomic,strong) NSDictionary * concert;
@property (nonatomic,strong) NSArray * posts;
@property (nonatomic,strong) NSMutableArray * images;
@property (nonatomic,strong) IBOutlet UILabel * eventLabel;
@property (nonatomic,strong) IBOutlet UILabel * venueAndDateLabel;

@end

@interface ECPostCell : UICollectionViewCell
@property (nonatomic,weak) IBOutlet UIImageView* postImageView;
@property (nonatomic,assign) ECPostType postType;
@property (strong, nonatomic) IBOutlet UIImageView *playButton;

@end