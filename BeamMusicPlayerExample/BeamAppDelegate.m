//
//  BeamAppDelegate.m
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import "BeamAppDelegate.h"

#import "BeamMusicPlayerViewController.h"
#import "BeamAVMusicPlayerProvider.h"

@implementation BeamAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize exampleProvider;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [BeamMusicPlayerViewController new];
    self.viewController.backBlock = ^{
        [[[UIAlertView alloc] initWithTitle:@"Action" message:@"The Player's back button was pressed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    };
    self.viewController.actionBlock = ^{
        [[[UIAlertView alloc] initWithTitle:@"Action" message:@"The Player's action button was pressed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    };
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

#if TARGET_IPHONE_SIMULATOR
    //self.exampleProvider = [BeamMinimalExampleProvider new];
    BeamAVMusicPlayerProvider *provider = [BeamAVMusicPlayerProvider new];
    self.exampleProvider = provider;
    
    //https://itunes.apple.com/search?term=Greatest+Hits+II+I+Want+It+All&entity=song
    
    provider.trackDescription = @{
        @"artistName": @"Queen",
        @"trackName": @"I Want It All",
        @"collectionName": @"Greatest Hits II",
        @"trackTimeMillis":@241253,
        @"previewUrl": @"http://a1508.phobos.apple.com/us/r1000/076/Music/9e/86/af/mzm.lpvqrikt.aac.p.m4a",
        @"artworkUrl100": @"http://a1132.phobos.apple.com/us/r1000/020/Features/2a/e3/90/dj.xjaszmmz.100x100-75.jpg"
    };
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        NSURL *previewURL = [NSURL URLWithString:provider.trackDescription[@"previewUrl"]];
//        NSData* previewData = [NSData dataWithContentsOfURL:previewURL];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSError* error;
//            provider.audioPlayer = [[AVAudioPlayer alloc] initWithData:previewData error:&error];
//            [provider.audioPlayer play];
//        });
//    });
    
    self.viewController.dataSource = self.exampleProvider;
    self.viewController.delegate = self.exampleProvider;
    [self.viewController reloadData];
#else
    BeamMPMusicPlayerProvider *mpMusicPlayerProvider = [BeamMPMusicPlayerProvider new];
    mpMusicPlayerProvider.controller = self.viewController;
    NSAssert(self.viewController.delegate == mpMusicPlayerProvider, @"setController: sets itself as delegate");
    NSAssert(self.viewController.dataSource == mpMusicPlayerProvider, @"setController: sets itself as datasource");
    
    mpMusicPlayerProvider.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];

    MPMediaQuery *mq = [MPMediaQuery songsQuery];
    [MPMusicPlayerController.iPodMusicPlayer setQueueWithQuery:mq];
    mpMusicPlayerProvider.mediaItems = mq.items;
    self.exampleProvider = mpMusicPlayerProvider;
//    mpMusicPlayerProvider.musicPlayer.nowPlayingItem = [mpMusicPlayerProvider.mediaItems objectAtIndex:mpMusicPlayerProvider.mediaItems.count-3];
    mpMusicPlayerProvider.musicPlayer.nowPlayingItem = [mpMusicPlayerProvider.mediaItems objectAtIndex:2];
    
#endif

    self.viewController.shouldHideNextTrackButtonAtBoundary = YES;
    self.viewController.shouldHidePreviousTrackButtonAtBoundary = YES;

    [self.viewController play];
    return YES;
}


@end
