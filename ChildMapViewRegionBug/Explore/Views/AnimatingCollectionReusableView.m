//
//  AnimatingCollectionReusableView.m
//  ExploreContainer
//
//  Created by Scott Atkinson on 2/10/16.
//

#import "AnimatingCollectionReusableView.h"

@implementation AnimatingCollectionReusableView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    [self layoutIfNeeded];
}

@end
