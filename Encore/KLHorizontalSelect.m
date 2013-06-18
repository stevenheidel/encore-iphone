//
//  KLHorizontalSelect.m
//  KLHorizontalSelect
//
//  Created by Kieran Lafferty on 2012-12-08.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.
//  Modified extensively 2013 Simon Bromberg



#import "KLHorizontalSelect.h"
#import "NSDictionary+ConcertList.h"
#import <QuartzCore/QuartzCore.h>
#define NUM_ENDS 2

@interface KLHorizontalSelect ()
-(CGFloat) defaultMargin;
@end
@implementation KLHorizontalSelect
-(CGFloat) defaultMargin {
    return self.frame.size.width/2.0 - kDefaultCellWidth/2.0;
}

-(id) initWithFrame:(CGRect)frame delegate:(id<KLHorizontalSelectDelegate>) delegate {
    self.delegate = delegate;
    return  [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //Configure the arrow
//        self.arrow = [[KLHorizontalSelectArrow alloc] initWithFrame:CGRectMake(0, kDefaultCellHeight, kHeaderArrowWidth, kHeaderArrowHeight)color:kDefaultGradientBottomColor];
//        [self.arrow setCenter:CGPointMake(self.frame.size.width/2.0, self.arrow.center.y)];
//        [self addSubview:self.arrow];
        
        // Make the UITableView's height the width, and width the height so that when we rotate it it will fit exactly
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.width)];
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        
        // Rotate the tableview by 90 degrees so that it is side scrollable
        [self.tableView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        [self.tableView setCenter: self.center];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        
        [self.tableView setContentInset: UIEdgeInsetsMake(self.defaultMargin, 0, self.defaultMargin, 0)];
        [self.tableView setShowsVerticalScrollIndicator:NO];
        [self.tableView setDecelerationRate: UIScrollViewDecelerationRateFast];

        [self addSubview: self.tableView];

        [self.layer setShadowColor: [kDefaultShadowColor CGColor]];
        [self.layer setShadowOffset: kDefaultShadowOffset];
        [self.layer setShadowOpacity: kDefaultShadowOpacity];
        
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

-(void) setFrame:(CGRect)frame {
    [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, kDefaultCellHeight)];
}
-(void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Draw gradient
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    CGFloat topRed = 0.0, topGreen = 0.0, topBlue = 0.0, topAlpha =0.0;
    [kDefaultGradientTopColor getRed:&topRed green:&topGreen blue:&topBlue alpha:&topAlpha];
    
    CGFloat bottomRed = 0.0, bottomGreen = 0.0, bottomBlue = 0.0, bottomAlpha =0.0;
    [kDefaultGradientBottomColor getRed:&bottomRed green:&bottomGreen blue:&bottomBlue alpha:&bottomAlpha];
    
    CGFloat components[8] = { topRed, topGreen, topBlue, topAlpha,  // Start color
        bottomRed, bottomGreen, bottomBlue, bottomAlpha}; // End color
    
    myColorspace = CGColorSpaceCreateDeviceRGB();
    
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    CGColorSpaceRelease(myColorspace);
    CGPoint myStartPoint, myEndPoint;
    myStartPoint.x = self.frame.size.width/2;
    myStartPoint.y = 0.0;
    myEndPoint.x = self.frame.size.width/2;
    myEndPoint.y = self.frame.size.height;
    CGContextDrawLinearGradient (context, myGradient, myStartPoint, myEndPoint, 0);
    CGGradientRelease(myGradient);

}


#pragma mark - UIScrollViewDelegate implementation

-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    CGPoint point = [self convertPoint:CGPointMake(self.frame.size.width/2.0, kDefaultCellHeight/2.0) toView:self.tableView];
     NSIndexPath* centerIndexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if ([self shouldHideArrowForSelectedCellType:centerIndexPath.section]) {
        [self.arrow hide:YES];  
    }

    else [self.arrow show:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging) {
     //   [self.arrow hide:YES];
            CGPoint point = [self convertPoint:CGPointMake(self.frame.size.width/2.0, kDefaultCellHeight/2.0) toView:self.tableView];
        [self.arrow lock: point];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidFinishScrolling:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        [self scrollViewDidFinishScrolling:scrollView];
    }
}

-(void) scrollViewDidFinishScrolling: (UIScrollView*) scrollView {
//    CGPoint point = [self convertPoint:CGPointMake(self.frame.size.width/2.0, kDefaultCellHeight/2.0) toView:self.tableView];
//    NSLog(@"%@", NSStringFromCGPoint(point));
//    NSIndexPath* centerIndexPath = [self.tableView indexPathForRowAtPoint:point];
//    
//    [self.tableView selectRowAtIndexPath: centerIndexPath
//                                animated: YES
//                          scrollPosition: UITableViewScrollPositionTop];
//    
//    NSLog(@"%@", [centerIndexPath description]);
//    if (centerIndexPath.row != self.currentIndex.row || centerIndexPath.section != self.currentIndex.section) {
//        //Hide the arrow when scrolling
//        [self setCurrentIndex:centerIndexPath];
//    }
//    if ([self shouldHideArrowForSelectedCellType:centerIndexPath.section]) {
//        [self.arrow hide:YES];  //TODO: this doesn't work reliably!
//    }
//    else [self.arrow show:YES];
}
-(void) setCurrentIndex:(NSIndexPath *)currentIndex {
    self->_currentIndex = currentIndex;
    [self.arrow hide:YES];
    [self.tableView scrollToRowAtIndexPath:currentIndex
                          atScrollPosition:UITableViewScrollPositionNone
                                  animated:YES];
}
#pragma mark - UITableViewDelegate implementation
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self shouldHideArrowForSelectedCellType: indexPath.section]) {
        [self.arrow hide:YES];
    }
    
    if (indexPath.row != self.currentIndex.row || indexPath.section != self.currentIndex.section) {
        //Hide the arrow when scrolling but don't hide it when clicking on already active cell
        [self setCurrentIndex:indexPath];
    }

    if ([self.delegate respondsToSelector:@selector(horizontalSelect:didSelectCell:atIndexPath:)]) {
        [self.delegate horizontalSelect:self didSelectCell:(KLHorizontalSelectCell*)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
    }
}

-(BOOL) shouldHideArrowForSelectedCellType: (ECCellType) type {
    return type == ECCellTypeAddFuture || type == ECCellTypeAddPast;
}

#pragma mark - UITableViewDataSource implementation
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == ECCellTypeAddFuture || section == ECCellTypeAddPast) {
        return 1;
    }
    if (section == ECCellTypeToday) {
        return 1;
    }
    if  (section == ECCellTypeFutureShows)
        return [[self.tableData objectForKey:@"future"] count];
    if  (section == ECCellTypePastShows)
         return [[self.tableData objectForKey:@"past"] count];
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ECNumberOfSections;
}

-(id) initCellAtIndexPath: (NSIndexPath *) indexPath {
    ECCellType cellType = indexPath.section;
    switch (cellType) {
        case ECCellTypeAddFuture:
            NSLog(@"added future cell");
            return (id)[[ECHorizontalEndCell alloc] initWithType:ECCellTypeAddFuture];
        case ECCellTypeAddPast:
              NSLog(@"added past cell");
            return (id)[[ECHorizontalEndCell alloc] initWithType:ECCellTypeAddPast];
        case ECCellTypeToday:
            return (id) [[ECTodayCell alloc] init];
        case ECCellTypeFutureShows: //TODO: clean up past and future thing
            return (id)[[KLHorizontalSelectCell alloc] initWithCellData:[[self.tableData objectForKey:@"future"] objectAtIndex:indexPath.row] forType:ECCellTypeFutureShows];
        case ECCellTypePastShows:
            return (id)[[KLHorizontalSelectCell alloc] initWithCellData:[[self.tableData objectForKey:@"past"] objectAtIndex:indexPath.row] forType:ECCellTypePastShows];
        default:
            return nil;
    }
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    ECCellType cellType = indexPath.section;

    NSString* reuseIdentifier = reuseIdentifierForCellType(cellType);

    id cell = (id)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell==nil) {
        cell = [self initCellAtIndexPath:indexPath];
    }
    else if (cellTypeNeedsUpdating(cellType)){
        NSString * key = cellType == ECCellTypePastShows ? @"past" : @"future";
        NSDictionary * cellData = [[self.tableData objectForKey:key] objectAtIndex:indexPath.row];
        ((KLHorizontalSelectCell*)cell).cellType = cellType;
        [(KLHorizontalSelectCell*) cell updateWithCellData:cellData];
        
    }
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ECCellType type = indexPath.section;
    if (type == ECCellTypeAddPast || type == ECCellTypeAddFuture) {
        return kEndCellWidth;
    }
    return kDefaultCellWidth;
}

@end

#pragma mark - Table View Cell Subclasses
#import "ECHorizontalCellView.h"
@implementation KLHorizontalSelectCell
-(id) initWithCellData: (NSDictionary *) cellData forType: (ECCellType) cellType {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierForCellType(cellType)]){
        self.cellType = cellType;
        if(!self.cellView) {
            self.cellView = [[ECHorizontalCellView alloc] initWithFrame: CGRectMake(0, 0, kDefaultCellWidth, kDefaultCellHeight)];
            [self.cellView  setTransform:CGAffineTransformMakeRotation(M_PI_2)];
            [self addSubview:self.cellView ];
        }
        [self updateWithCellData:cellData];
    }
    return self;
}

//Method is publically accessible, currently called by cellForRowAtIndexPath if cell is being reused.
-(void) updateWithCellData: (NSDictionary *) cellData {
    self.cellData = cellData;
    [self updateCellView];
}

-(void) updateCellView {
    self.contentView.backgroundColor = self.cellType == ECCellTypePastShows ? [UIColor colorWithRed:240.0/255.0 green:1.0 blue:240.0/255.0 alpha:1.0] : [UIColor clearColor];
    ECHorizontalCellView * view =  self.cellView;
    NSDictionary * data = self.cellData;
    view.yearLabel.text = [data year];
    view.monthLabel.text = [data month];
    view.dayNumberLabel.text = [data day];
}


@end

@implementation ECTodayCell
-(id) init {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierForCellType(ECCellTypeToday)]){

        UILabel * cellView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kDefaultCellWidth, kDefaultCellHeight)];
        cellView.text = @"TODAY";
        
//TODO: figure out why this didn't work
//        NSArray * arr = [[NSBundle mainBundle] loadNibNamed:@"ECTodayCellView" owner:self options:nil];
        //UIView * view = [arr objectAtIndex:0];
        [cellView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
         cellView.backgroundColor = [UIColor clearColor];
        cellView.font = [UIFont boldSystemFontOfSize:14.0];
        [self addSubview:cellView];
       
    }
    
    return self;
}
@end

#import "ECEndCellView.h"
@implementation ECHorizontalEndCell

-(id) initWithType:(ECCellType)type {
    if (self=[super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierForCellType(type)]) {
        ECEndCellView * cellView = [[ECEndCellView alloc] initWithFrame: CGRectMake(0, -5, kEndCellWidth, kEndCellHeight)];
        //UILabel * cellView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kEndCellWidth, kEndCellHeight)];
        cellView.backgroundColor = [UIColor clearColor];
        NSString * text = type == ECCellTypeAddPast ? @"Add Past" : @"Add Upcoming";
        cellView.textLabel.text = text;//.text = text;
        cellView.textLabel.textAlignment = type == ECCellTypeAddPast ? NSTextAlignmentRight : NSTextAlignmentLeft;
        [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        
        [self addSubview:cellView];
        [self setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    return self;
}

@end

#pragma mark - Arrow upon selection

@implementation KLHorizontalSelectArrow
- (float) hypotenuse {
    return (CGFloat)self.frame.size.width / sqrt(2.0);
}
-(id) initWithFrame:(CGRect)frame color:(UIColor*) color {
    if (self = [super initWithFrame:frame]) {
        self.isShowing = YES;
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path,NULL,0.0,0.0);
        CGPathAddLineToPoint(path, NULL, 0.0f, 0.0f);
        CGPathAddLineToPoint(path, NULL, frame.size.width, 0.0f);
        CGPathAddLineToPoint(path, NULL, frame.size.width/2.0, frame.size.height);

        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setPath:path];
        [shapeLayer setFillColor:[[UIColor blueColor] CGColor]]; //TODO Change colouring
        
        
        
        [self.layer addSublayer:shapeLayer];

        CGPathRelease(path);
        
        [self setAnchorPoint:CGPointMake(0.5, 0.0) forView:self];

    }
    return self;
}
-(void) show:(BOOL) animated {
    if (!self.isShowing) {
        if (animated) {
            [UIView animateWithDuration:0.1 animations:^{
                [self.layer setTransform: CATransform3DRotate(self.layer.transform, (1/4.0)*M_PI, 1.0, 0.0, 0.0)];
            }];
        }
        {
            [self.layer setTransform: CATransform3DRotate(self.layer.transform,(1/4.0)*M_PI, 1.0, 0.0, 0.0)];
        }
    }

    self.isShowing = YES;
}
-(void) lock:(CGPoint)point {
//    self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
//    [self.layer setTransform: CATransform3DRotate(self.layer.transform, -(1/4.0)*M_PI,1.0, 0.0, 0.0)];
}
//Allows setting of the anchor point for animations without moving the sublayers (i.e the drawn arrow) to the origin of the anchor
-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}
-(void) hide:(BOOL) animated {
    if (self.isShowing) {
        if (animated) {
            [UIView animateWithDuration:0.1 animations:^{
                [self.layer setTransform: CATransform3DRotate(self.layer.transform, -(1/4.0)*M_PI,1.0, 0.0, 0.0)];
                
            }];
        }
        {
            [self.layer setTransform: CATransform3DRotate(self.layer.transform, -(1/4.0)*M_PI, 1.0, 0.0, 0.0)];
        }
    }
    self.isShowing = NO;
}
-(void) toggle:(BOOL) animated {
    if (self.isShowing) {
        [self hide:animated];
    }
    else {
        [self show:animated];
    }
}
@end
