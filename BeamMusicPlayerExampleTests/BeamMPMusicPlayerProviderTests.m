//
//  BeamMPMusicPlayerProvider.m
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Heiko Behrens on 18.07.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import "BeamMPMusicPlayerProviderTests.h"
#import <OCMock.h>

// needed to link for simulator where real class does not exist
@protocol MPMusicPlayerControllerProtocol <NSObject>

- (void)beginGeneratingPlaybackNotifications;
- (void)endGeneratingPlaybackNotifications;

@end

@implementation BeamMPMusicPlayerProviderTests

- (void)testMusicPlayer {
    BeamMPMusicPlayerProvider *provider = [BeamMPMusicPlayerProvider new];
    id musicPlayer = [OCMockObject mockForProtocol:@protocol(MPMusicPlayerControllerProtocol)];
    [[musicPlayer expect] beginGeneratingPlaybackNotifications];
    provider.musicPlayer = musicPlayer;
    [musicPlayer verify];
    
    [[musicPlayer expect] endGeneratingPlaybackNotifications];
    provider = nil;
    // deallocating provider should deregister from notifications
    [musicPlayer verify];
}


@end
