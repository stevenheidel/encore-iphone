
#import "Cell.h"
//#import "CustomCellBackground.h"

@implementation Cell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        
    }
    return self;
}

-(void) setPostType:(ECPostType)postType {
    _postType = postType;
    if(postType == ECVideoPost && self.playButton == nil) {
        self.playButton = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"playbutton"]];
        self.playButton.frame = self.contentView.frame;
        self.playButton.contentMode = UIViewContentModeCenter;
        [self addSubview:self.playButton];
        [self bringSubviewToFront:self.playButton];
    }
            self.playButton.hidden = postType == ECPhotoPost;

}
@end
