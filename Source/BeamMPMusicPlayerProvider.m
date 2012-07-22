//
//  BeamIpodExampleProvider.m
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 31.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import "BeamMPMusicPlayerProvider.h"


@implementation BeamMPMusicPlayerProvider

@synthesize musicPlayer;
@synthesize controller;
@synthesize mediaItems;

-(id)init {
    self = [super init];
    if ( self ){
        // This HACK hides the volume overlay when changing the volume.
        // It's insipired by http://stackoverflow.com/questions/3845222/iphone-sdk-how-to-disable-the-volume-indicator-view-if-the-hardware-buttons-ar
        MPVolumeView* view = [MPVolumeView new];
        // Put it far offscreen
        view.frame = CGRectMake(1000, 1000, 120, 12);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
    
    return self;
}

-(void)handleVolumeDidChangeNotification {
    self.controller.volume = self.musicPlayer.volume;
}

-(void)setMusicPlayer:(MPMusicPlayerController *)value {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:musicPlayer];
    [nc removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:musicPlayer];
    [nc removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:musicPlayer];
    [musicPlayer endGeneratingPlaybackNotifications];
    
    musicPlayer = value;

    [nc addObserver: self
           selector: @selector (propagateMusicPlayerState)
               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
             object: musicPlayer];
    [nc addObserver: self
           selector: @selector (propagateMusicPlayerState)
               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
             object: musicPlayer];
    [nc addObserver: self
           selector: @selector (handleVolumeDidChangeNotification)
               name: MPMusicPlayerControllerVolumeDidChangeNotification
             object: musicPlayer];

    [musicPlayer beginGeneratingPlaybackNotifications];
    
    [self propagateMusicPlayerState];
}

-(void)setController:(BeamMusicPlayerViewController *)value {
    controller.delegate = nil;
    controller.dataSource = nil;
    controller = value;
    controller.delegate = self;
    controller.dataSource = self;
    [self propagateMusicPlayerState];
}

-(void)setMediaItems:(NSArray *)value {
    mediaItems = [value copy];
    [self.controller reloadData];
}

-(MPMediaItem*)mediaItemAtIndex:(NSUInteger)index {
    if(self.mediaItems == nil || self.mediaItems.count == 0) 
        return self.musicPlayer.nowPlayingItem;
    else 
        return [self.mediaItems objectAtIndex:index];
}

- (void)dealloc
{
    // explicit call of setters with nil to deregister from objects
    self.musicPlayer = nil;
    self.controller = nil;
}

-(void)propagateMusicPlayerState {
    if(self.controller && self.musicPlayer) {
        self.controller.delegate = nil;
        
        // refactor: playing property in musicplayer? and/or setter method differently
        [self.controller playTrack:self.musicPlayer.indexOfNowPlayingItem atPosition:self.musicPlayer.currentPlaybackTime volume:self.musicPlayer.volume];
        if(self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
            [self.controller play];
        } else {
            [self.controller pause];
        }

        self.controller.delegate = self;
    }
}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self mediaItemAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyAlbumTitle];
}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self mediaItemAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyArtist];
}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self mediaItemAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyTitle];
}

-(CGFloat)musicPlayer:(BeamMusicPlayerViewController *)player lengthForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self mediaItemAtIndex:trackNumber];
    return [[item valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
    
}

-(NSInteger)numberOfTracksInPlayer:(BeamMusicPlayerViewController *)player {
    return self.mediaItems ? self.mediaItems.count : -1;
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(BeamMusicPlayerReceivingBlock)receivingBlock {
    MPMediaItem* item = [self mediaItemAtIndex:trackNumber];
    MPMediaItemArtwork* artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    if ( artwork ){
        UIImage* foo = [artwork imageWithSize:player.preferredSizeForCoverArt];
        receivingBlock(foo, nil);
    } else {
        receivingBlock(nil,nil);
    }
}

#pragma mark Delegate Methods ( Used to control the music player )

-(NSInteger)musicPlayer:(BeamMusicPlayerViewController *)player didChangeTrack:(NSUInteger)track {
    if(self.mediaItems) {
        [self.musicPlayer setNowPlayingItem:[self mediaItemAtIndex:track]];
    } else {
        int delta = track - self.musicPlayer.indexOfNowPlayingItem;
        if(delta > 0)
            [self.musicPlayer skipToNextItem];
        if(delta == 0)
            [self.musicPlayer skipToBeginning];
        if(delta < 0)
            [self.musicPlayer skipToPreviousItem];
    }
    return self.musicPlayer.indexOfNowPlayingItem;
}

-(void)musicPlayerDidStartPlaying:(BeamMusicPlayerViewController *)player {
    [self.musicPlayer play];
}

-(void)musicPlayerDidStopPlaying:(BeamMusicPlayerViewController *)player {
    [self.musicPlayer pause];
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player didChangeVolume:(CGFloat)volume {
    [self.musicPlayer setVolume:volume];
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player didSeekToPosition:(CGFloat)position {
    [self.musicPlayer setCurrentPlaybackTime:position];
}

@end
