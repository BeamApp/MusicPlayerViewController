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
#import "BeamMinimalExampleProvider.h"

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
    self.exampleProvider = [BeamMinimalExampleProvider new];

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
