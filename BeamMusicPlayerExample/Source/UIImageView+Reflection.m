//
//  UIImageView+Reflection.m
//  BeamMusicPlayerExample
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "UIImageView+Reflection.h"

static const CGFloat kDefaultReflectionFraction = 0.65;
static const CGFloat kDefaultReflectionOpacity = 0.40;

@implementation UIImageView (Reflection)

#pragma mark - Image Reflection

CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
    CGImageRef theCGImage = NULL;
    
    // gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
                                                               8, 0, colorSpace, kCGImageAlphaNone);
    
    // define the start and end grayscale values (with the alpha, even though
    // our bitmap context doesn't support alpha the gradient requires it)
    
    // create the CGGradient and then release the gray color space
    CGColorSpaceRelease(colorSpace);
    
    CGContextSetFillColorWithColor(gradientBitmapContext, [UIColor blackColor].CGColor);
    CGContextFillRect(gradientBitmapContext, CGContextGetClipBoundingBox(gradientBitmapContext));
    // draw the gradient into the gray bitmap context
   // CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
   //                             gradientEndPoint, kCGGradientDrawsAfterEndLocation);
   // CGGradientRelease(grayScaleGradient);
    
    // convert the context into a CGImageRef and release the context
    theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);
    
    // return the imageref containing the gradient
    return theCGImage;
}

- (UIImage *)reflectedImageWithHeight:(NSUInteger)height
{
    if(height == 0)
        return nil;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create the bitmap context
    CGContextRef bitmapContext = CGBitmapContextCreate (NULL, self.frame.size.width, height, 8,
                                                        0, colorSpace,
                                                        // this will give us an optimal BGRA format for the device:
                                                        (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    CGColorSpaceRelease(colorSpace);
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = bitmapContext;
    // create a 2 bit CGImage containing a gradient that will be used for masking the 
    // main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
    // function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
    CGImageRef gradientMaskImage = CreateGradientImage(1, height);
    
    // create an image by masking the bitmap of the mainView content with the gradient view
    // then release the  pre-masked content bitmap and the gradient bitmap
    //CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, self.bounds.size.width, height), gradientMaskImage);
    CGImageRelease(gradientMaskImage);
    
    // In order to grab the part of the image that we want to render, we move the context origin to the
    // height of the image that we want to capture, then we flip the context so that the image draws upside down.
    CGContextTranslateCTM(mainViewContentContext, 0.0, height);
    CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
    
    // draw the image into the bitmap context
    CGContextDrawImage(mainViewContentContext, self.bounds, self.image.CGImage);
    
    // create CGImageRef of the main view bitmap content, and then release that bitmap context
    CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    // convert the finished reflection image to a UIImage 
    UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
    
    // image is retained by the property setting above, so we can release the original
    CGImageRelease(reflectionImage);
    
    return theImage;
}

@end
