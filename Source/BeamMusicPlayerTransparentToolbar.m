//
//  BeamMusicPlayerTransparentToolbar.m
//  BeamMusicPlayerExample
//
//  Created by Heiko Behrens on 21.05.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "BeamMusicPlayerTransparentToolbar.h"

@implementation BeamMusicPlayerTransparentToolbar

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [UIColor.clearColor set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

@end
