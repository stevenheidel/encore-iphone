//
//  ECCollectionViewFlowLayout.h
//  Encore
//
//  Created by Luis Ramirez on 2013-07-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECCollectionViewFlowLayout : UICollectionViewFlowLayout

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect;
- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound;

@end
