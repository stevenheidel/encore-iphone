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

#import "UIFont+Encore.h"
#import "UIColor+EncoreUI.h"


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
        self.arrow = [[KLHorizontalSelectArrow alloc] initWithFrame:CGRectMake(0, kDefaultCellHeight, kHeaderArrowWidth, kHeaderArrowHeight)color:[UIColor horizontalSelectTodayCellColor]];
        [self.arrow setCenter:CGPointMake(self.frame.size.width/2.0, self.arrow.center.y)];
        
        
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

//        [self.layer setShadowColor: [kDefaultShadowColor CGColor]];
//        [self.layer setShadowOffset: kDefaultShadowOffset];
//        [self.layer setShadowOpacity: kDefaultShadowOpacity];
        
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
    
    CGFloat topRed = 0.0, topGreen = 0.0, topBlue = 0.0, topAlpha =1.0;
    //[kDefaultGradientTopColor getRed:&topRed green:&topGreen blue:&topBlue alpha:&topAlpha];
    
    CGFloat bottomRed = 0.0, bottomGreen = 0.0, bottomBlue = 0.0, bottomAlpha =1.0;
    //[kDefaultGradientBottomColor getRed:&bottomRed green:&bottomGreen blue:&bottomBlue alpha:&bottomAlpha];
    
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

    if (![self shouldHideArrowForSelectedCellType:[self.tableView indexPathForSelectedRow].section] && [centerIndexPath isEqual:self.tableView.indexPathForSelectedRow]) {
        if(flag) {
            [self.tableView scrollToRowAtIndexPath:centerIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [self.arrow show:YES];
            flag = false;
        }
    }
}
//-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self.arrow hide:YES];
//}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging) {
        [self.arrow hide:YES];
        flag = true;
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
    CGPoint point = [self convertPoint:CGPointMake(self.frame.size.width/2.0, kDefaultCellHeight/2.0) toView:self.tableView];
    NSIndexPath* centerIndexPath = [self.tableView indexPathForRowAtPoint:point];
    if (![self shouldHideArrowForSelectedCellType:[self.tableView indexPathForSelectedRow].section] && [centerIndexPath isEqual:self.tableView.indexPathForSelectedRow]) {
        [self.tableView scrollToRowAtIndexPath:centerIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}
-(void) setCurrentIndex:(NSIndexPath *)currentIndex {
    self->_currentIndex = currentIndex;
    [self.arrow hide:YES];
    [self.tableView scrollToRowAtIndexPath:currentIndex
                          atScrollPosition:UITableViewScrollPositionNone
                                  animated:YES];
}


#pragma mark - UITableViewDelegate implementation
-(NSIndexPath*) tableView: (UITableView*) tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:self.tableView.indexPathForSelectedRow]) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return nil;
    }
    return indexPath;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != self.currentIndex.row || indexPath.section != self.currentIndex.section) {
        //Hide the arrow when scrolling but don't hide it when clicking on already active cell
        [self setCurrentIndex:indexPath];
    }
    if(![self.arrow isDescendantOfView:self]){
        [self addSubview:self.arrow];
        [self.arrow show:YES];
    }
//    if ([self shouldHideArrowForSelectedCellType: indexPath.section]) {
//        [self.arrow hide:YES];
//    }
//    else {
//        [self.arrow show:YES];
//    }

    if ([self.delegate respondsToSelector:@selector(horizontalSelect:didSelectCell:atIndexPath:)]) {
        [self.delegate horizontalSelect:self didSelectCell:(KLHorizontalSelectCell*)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
    }
}

-(BOOL) shouldHideArrowForSelectedCellType: (ECCellType) type {
    return type != ECCellTypeToday;//type == ECCellTypeAddFuture || type == ECCellTypeAddPast;
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
            return (id)[[ECHorizontalEndCell alloc] initWithType:ECCellTypeAddFuture];
        case ECCellTypeAddPast:
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
        [(KLHorizontalSelectCell*)cell updateWithCellData:cellData];
    }
    
    if (cellType == ECCellTypeFutureShows || cellType == ECCellTypePastShows) {
        if ([indexPath row] % 2) {
            [[(KLHorizontalSelectCell*)cell contentView] setBackgroundColor:[UIColor whiteColor]];
        } else {
            [[(KLHorizontalSelectCell*)cell contentView] setBackgroundColor:[UIColor horizontalSelectGrayCellColor]];
        }
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
            self.cellView = [[ECHorizontalCellView alloc] initWithFrame: self.contentView.frame];
            [self setCellTextAttributes];
            [self addSubview:self.cellView];
            [self  setTransform:CGAffineTransformMakeRotation(M_PI_2)];
            [[self contentView] setBackgroundColor:[UIColor blackColor]];
            [self.dateNumberLabel setTextAlignment:NSTextAlignmentCenter];
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
    
    //self.contentView.backgroundColor = self.cellType == ECCellTypePastShows ? [UIColor colorWithRed:240.0/255.0 green:1.0 blue:240.0/255.0 alpha:1.0] : [UIColor clearColor];
    ECHorizontalCellView * view =  self.cellView;
    NSDictionary * data = self.cellData;
    view.yearLabel.text = [data year];
    view.monthLabel.text = [data month];
    view.dayNumberLabel.text = [data day];

}

-(void) setCellTextAttributes {
    ECHorizontalCellView * view =  self.cellView;
    UIColor* color = [UIColor horizontalSelectTextColor];
    view.yearLabel.font = [UIFont heroFontWithSize: 12.0];
    view.yearLabel.textColor = color;
    view.monthLabel.font = [UIFont heroFontWithSize:12.0];
    view.monthLabel.textColor = color;
    view.dayNumberLabel.font = [UIFont heroFontWithSize:28.0];
    view.dayNumberLabel.textColor = color;
}

@end

@implementation ECTodayCell
-(id) init {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierForCellType(ECCellTypeToday)]){
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECTodayCellView" owner:self options:nil];
        UIView *todayView = [subviewArray objectAtIndex:0];
        self.todayLabel = [[todayView subviews] objectAtIndex:0];
        self.todayLabel.text = NSLocalizedString(@"today", nil);
        self.todayLabel.backgroundColor = [UIColor clearColor];
        self.todayLabel.font = [UIFont heroFontWithSize: 12.0];
        self.todayLabel.textColor = [UIColor whiteColor];

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [todayView setBackgroundColor:[UIColor horizontalSelectTodayCellColor]];
//        [[self contentView] setBackgroundColor:[UIColor horizontalSelectTodayCellColor]];
        todayView.frame = self.contentView.frame;
        [self.contentView addSubview:todayView];
        [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    }

    return self;
}
@end

#import "ECEndCellView.h"
@implementation ECHorizontalEndCell

-(id) initWithType:(ECCellType)type {
    if (self=[super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierForCellType(type)]) {
        ECEndCellView * cellView = [[ECEndCellView alloc] initWithFrame: self.contentView.frame];
        cellView.backgroundColor = [UIColor clearColor];
        NSString * text = type == ECCellTypeAddPast ? NSLocalizedString(@"AddPast", nil): NSLocalizedString(@"AddFuture", nil);
        cellView.textLabel.text = [text uppercaseString];
        cellView.textLabel.font = [UIFont heroFontWithSize: 16.0];
        cellView.textLabel.textColor = type == ECCellTypeAddPast ? [UIColor whiteColor] : [UIColor horizontalSelectTodayCellColor];
        cellView.textLabel.textAlignment = type == ECCellTypeAddPast ? NSTextAlignmentRight : NSTextAlignmentLeft;
        
        [self addSubview:cellView];
        
        [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        
        cellView.textLabel.center = cellView.center;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
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
        [shapeLayer setFillColor:[color CGColor]];
        
        
        
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
            [UIView animateWithDuration:0.05 animations:^{
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
