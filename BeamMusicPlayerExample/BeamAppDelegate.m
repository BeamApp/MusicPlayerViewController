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

-(BOOL)isUnderUnitTest {
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    return [arguments containsObject:@"-SenTest"];
}

+(NSArray*)trackDescriptions {
    return @[
        @{
          @"artistName": @"Lana Del Rey",
          @"trackName": @"Summertime Sadness",
          @"collectionName": @"Born to Die",
          @"trackTimeMillis": @265502,
          @"previewUrl": @"http://a1525.phobos.apple.com/us/r1000/073/Music/4d/7e/85/mzm.rkneragg.aac.p.m4a",
          @"artworkUrl100": @"http://a4.mzstatic.com/us/r1000/092/Music/6c/ed/86/mzi.oltlbval.100x100-75.jpg",
          @"artworkUrl400": @"http://a4.mzstatic.com/us/r1000/092/Music/6c/ed/86/mzi.oltlbval.400x400-75.jpg",
          @"artworkUrl600": @"http://a4.mzstatic.com/us/r1000/092/Music/6c/ed/86/mzi.oltlbval.600x600-75.jpg",
          @"artworkUrl1200": @"http://a4.mzstatic.com/us/r1000/092/Music/6c/ed/86/mzi.oltlbval.1200x1200-75.jpg"
          },

        @{
          @"artistName": @"The Jacksons",
          @"trackName": @"Shake Your Body (Down to the Ground)",
          @"collectionName": @"The Essential Michael Jackson",
          @"trackTimeMillis": @224893,
          @"previewUrl": @"http://a543.phobos.apple.com/us/r1000/064/Music/5a/a6/53/mzm.yowexdfs.aac.p.m4a",
          @"artworkUrl100": @"http://a3.mzstatic.com/us/r1000/045/Features/7f/50/ee/dj.zygromnm.100x100-75.jpg",
          @"artworkUrl400": @"http://a3.mzstatic.com/us/r1000/045/Features/7f/50/ee/dj.zygromnm.400x400-75.jpg",
          @"artworkUrl600": @"http://a3.mzstatic.com/us/r1000/045/Features/7f/50/ee/dj.zygromnm.600x600-75.jpg",
          @"artworkUrl1200": @"http://a3.mzstatic.com/us/r1000/045/Features/7f/50/ee/dj.zygromnm.1200x1200-75.jpg"
          },
        @{
          @"artistName": @"Daft Punk",
          @"trackName": @"Lose Yourself to Dance (feat. Pharrell Williams)",
          @"collectionName": @"Random Access Memories",
          @"trackTimeMillis": @353896,
          @"previewUrl": @"http://a1186.phobos.apple.com/us/r1000/071/Music/v4/7e/f7/29/7ef729e1-cb34-48ba-ebcf-5c9b317ef804/mzaf_246350052816247711.aac.m4a",
          @"artworkUrl100": @"http://a4.mzstatic.com/us/r1000/096/Music2/v4/52/aa/50/52aa5008-4934-0c27-a08d-8ebd7d13c030/886443919266.100x100-75.jpg",
          @"artworkUrl400": @"http://a4.mzstatic.com/us/r1000/096/Music2/v4/52/aa/50/52aa5008-4934-0c27-a08d-8ebd7d13c030/886443919266.400x400-75.jpg",
          @"artworkUrl600": @"http://a4.mzstatic.com/us/r1000/096/Music2/v4/52/aa/50/52aa5008-4934-0c27-a08d-8ebd7d13c030/886443919266.600x600-75.jpg",
          @"artworkUrl1200": @"http://a4.mzstatic.com/us/r1000/096/Music2/v4/52/aa/50/52aa5008-4934-0c27-a08d-8ebd7d13c030/886443919266.1200x1200-75.jpg"
          }
    ];
}

-(void)initViewMusicPlayerViewControllerWithDescription:(NSDictionary*)description {
#if true || TARGET_IPHONE_SIMULATOR
    //self.exampleProvider = [BeamMinimalExampleProvider new];
    BeamAVMusicPlayerProvider *provider = [BeamAVMusicPlayerProvider new];
    self.exampleProvider = provider;
    
    //https://itunes.apple.com/search?term=Greatest+Hits+II+I+Want+It+All&entity=song
    
    provider.trackDescription = description;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURL *previewURL = [NSURL URLWithString:provider.trackDescription[@"previewUrl"]];
        NSData* previewData = [NSData dataWithContentsOfURL:previewURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError* error;
            provider.audioPlayer = [[AVAudioPlayer alloc] initWithData:previewData error:&error];
            [provider.audioPlayer play];
            [self.viewController reloadData];
        });
    });
    
    self.viewController.dataSource = self.exampleProvider;
    self.viewController.delegate = self.exampleProvider;
    provider.controller = self.viewController;
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
}

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

    if(self.isUnderUnitTest)
        return YES;

    NSDictionary* description = self.class.trackDescriptions[arc4random() % self.class.trackDescriptions.count];
    [self initViewMusicPlayerViewControllerWithDescription:description];
    [self.viewController play];
    return YES;
}


@end
