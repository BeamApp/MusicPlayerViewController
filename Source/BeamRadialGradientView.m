//
//  BeamRadialGradientView.m
//  BeamMusicPlayerExample
//
//  Created by Dominik Alexander on 26.06.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "BeamRadialGradientView.h"

@implementation BeamRadialGradientView

- (void)drawRect:(CGRect)rect
{
    // Get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Create gradient
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    NSArray *gradientColors = @[(id)[UIColor colorWithWhite:0.4f alpha:1.0f].CGColor,
                                (id)[UIColor colorWithWhite:0.1f alpha:1.0f].CGColor];
    CGFloat colorLocations[2] = {
        0.0f,
        1.0f
    };
    CGGradientRef gradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)(gradientColors), colorLocations);
    
    // Draw gradient
    CGPoint gradientCenter = CGPointMake(rect.size.width / 2.0f, 0.0f);
    CGFloat radius = MAX(rect.size.width, rect.size.height);
    CGContextDrawRadialGradient(context, gradient, gradientCenter, 0.0f, gradientCenter, radius, kCGGradientDrawsAfterEndLocation);
    
    // Clean up
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgb);
}


@end
