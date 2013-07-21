
#import <UIKit/UIKit.h>
#import "ECPostType.h"
@interface Cell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *image;
@property (nonatomic,assign) ECPostType postType;
@property (strong, nonatomic) UIImageView *playButton;

@end
