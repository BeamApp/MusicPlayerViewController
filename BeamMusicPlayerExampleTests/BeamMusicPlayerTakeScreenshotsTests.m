//
//  BeamAVMusicPlayerProviderTests.m
//  BeamMusicPlayerExample
//
//  Created by Heiko Behrens on 23.05.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BeamAppDelegate.h"

@interface BeamMusicPlayerTakeScreenshotsTests : SenTestCase

@end

CGImageRef UIGetScreenImage(); //private API for getting an image of the entire screen

@interface UIDevice ()
- (void)setOrientation:(UIInterfaceOrientation)orientation;
@end

@implementation BeamMusicPlayerTakeScreenshotsTests

#pragma mark - helper methods

-(NSURL*)screenshotsURL {
    NSURL *result = [NSURL fileURLWithPath:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding]];
    result = [result.URLByDeletingLastPathComponent.URLByDeletingLastPathComponent URLByAppendingPathComponent:@"Documentation/images/"];
    return result;
}

- (CGImageRef)createImageFromImage:(CGImageRef)imageRef orientation:(UIInterfaceOrientation)orientation {
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    CGContextRef bitmap;

    size_t targetWidth = CGImageGetWidth(imageRef);
    size_t targetHeight = CGImageGetHeight(imageRef);
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
    }
    NSAssert(bitmap, @"bitmap must be created");

    if (orientation == UIInterfaceOrientationLandscapeRight) {
        CGContextRotateCTM (bitmap, (CGFloat) (90/ 180.0 * M_PI));
        CGContextTranslateCTM (bitmap, 0, -(int)targetHeight);
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        CGContextRotateCTM (bitmap, (CGFloat) (-90/ 180.0 * M_PI));
        CGContextTranslateCTM (bitmap, -(int)targetWidth, 0);
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // NOTHING
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        CGContextTranslateCTM (bitmap, (int)targetWidth, (int)targetHeight);
        CGContextRotateCTM (bitmap, (CGFloat) (180/ 180.0 * M_PI));
    }

    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    return CGBitmapContextCreateImage(bitmap);;
}

- (void)saveScreenshot:(NSString *)name includeStatusBar:(BOOL)includeStatusBar
{
    //Get image with status bar cropped out
    CGFloat StatusBarHeight = [[UIScreen mainScreen] scale] == 1 ? 20 : 40;
    CGImageRef CGImage = UIGetScreenImage();
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
    CGRect imageRect;

    if (!includeStatusBar) {
        if (isPortrait) {
            imageRect = CGRectMake(0, StatusBarHeight, CGImageGetWidth(CGImage), CGImageGetHeight(CGImage) - StatusBarHeight);
        } else {
            imageRect = CGRectMake(StatusBarHeight, 0, CGImageGetWidth(CGImage) - StatusBarHeight, CGImageGetHeight(CGImage));
        }

        CGImage = (__bridge CGImageRef)CFBridgingRelease(CGImageCreateWithImageInRect(CGImage, imageRect));
    }

    CGImageRef cgImage2 = (__bridge CGImageRef)CFBridgingRelease([self createImageFromImage:CGImage orientation:orientation]);
    UIImage *image = [UIImage imageWithCGImage:cgImage2];
    NSData *data = UIImagePNGRepresentation(image);


    NSString *devicePrefix = nil;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        devicePrefix = [NSString stringWithFormat:@"iphone%.0f", CGRectGetHeight([[UIScreen mainScreen] bounds])];
    } else {
        devicePrefix = @"ipad";
    }

    NSString* orientationPrefix = UIInterfaceOrientationIsPortrait(orientation) ? @"P" : @"L";

    NSString *file = [NSString stringWithFormat:@"%@-%@-%@-%@.png", devicePrefix, [[NSLocale currentLocale] localeIdentifier], orientationPrefix, name];
    NSURL *fileURL = [self.screenshotsURL URLByAppendingPathComponent:file];

    NSLog(@"Saving screenshot: %@", [fileURL path]);

    [data writeToURL:fileURL atomically:YES];
}

-(void)wait {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
}

-(void)waitFor:(BOOL(^)())block {
    [self wait];
    while (!block()) {
        [self wait];
    }
}

-(void)waitForTimeInterval:(NSTimeInterval)interval {
    NSDate *date = NSDate.date;
    [self waitFor:^BOOL {
        return -[date timeIntervalSinceNow] >= interval;
    }];
}

#pragma mark - actual test methods

- (void)setUp {
    [super setUp];
}

+ (NSArray *) testInvocations {
    // hide all these tests unless explicitly called via command line args
    if(NSNotFound == [NSProcessInfo.processInfo.arguments indexOfObjectPassingTest:^BOOL(NSString* arg, NSUInteger idx, BOOL *stop) {
        return [arg hasPrefix:NSStringFromClass(self)];
    }]) return @[];

    return [super testInvocations];
}

-(BeamAppDelegate*)appDelegate {
    return (BeamAppDelegate *) UIApplication.sharedApplication.delegate;
}

-(BeamMusicPlayerViewController *)viewController {
    return self.appDelegate.viewController;
}

-(void)initVCWithDescription:(NSDictionary *)description {
    [self.appDelegate initViewMusicPlayerViewControllerWithDescription:description];
    [self.viewController showScrobbleOverlay:YES animated:NO];
}

-(void)testScreenshotForDescriptionAtIndex:(NSUInteger)index {
    NSDictionary *description = BeamAppDelegate.trackDescriptions[index];
    [self initVCWithDescription:description];
    [self.viewController playTrack:0 atPosition:67 volume:0.6];
    [self waitFor:^BOOL {
        return self.viewController.customCovertArtLoaded;
    }];

    [self saveScreenshot:[NSString stringWithFormat:@"track%d", index] includeStatusBar:YES];
}

-(void)testTakePortraitScreenshotForEachDescription {
    [[UIDevice currentDevice] setOrientation:UIInterfaceOrientationPortraitUpsideDown];
    [self waitForTimeInterval:1];

    for(NSUInteger i=0;i<BeamAppDelegate.trackDescriptions.count;i++)
        [self testScreenshotForDescriptionAtIndex:i];
}


-(void)testTakeLandscapeScreenshotForEachDescription {
    [[UIDevice currentDevice] setOrientation:UIInterfaceOrientationLandscapeRight];
    [self waitForTimeInterval:1];

    for(NSUInteger i=0;i<BeamAppDelegate.trackDescriptions.count;i++)
        [self testScreenshotForDescriptionAtIndex:i];
}

-(void)testArgs {
    NSLog(@"args: %@", NSProcessInfo.processInfo.arguments);
}

@end
