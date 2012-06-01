//
//  BeamIpodExampleProvider.m
//  BeamMusicPlayerExample
//
//  Created by Moritz Haarmann on 31.05.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "BeamIpodExampleProvider.h"


@implementation BeamIpodExampleProvider

@synthesize musicPlayer;
@synthesize controller;
@synthesize mediaItems;

-(id)init {
    self = [super init];
    if ( self ){
        
        self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
        
        // Using an unspecific query we extract all files from the library for playback.
        MPMediaQuery *everything = [[MPMediaQuery alloc] init];

        self.mediaItems = [everything items];
        
        [self.musicPlayer setQueueWithQuery:everything];
        
        [self.controller reloadData];
        [self.controller play];
        // This HACK hides the volume overlay when changing the volume.
        // It's insipired by http://stackoverflow.com/questions/3845222/iphone-sdk-how-to-disable-the-volume-indicator-view-if-the-hardware-buttons-ar
        MPVolumeView* view = [MPVolumeView new];
        // Put it far offscreen
        view.frame = CGRectMake(1000, 1000, 120, 12);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
    
    return self;
}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyAlbumTitle];
}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyArtist];
}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyTitle];
}

-(CGFloat)musicPlayer:(BeamMusicPlayerViewController *)player lengthForTrack:(NSUInteger)trackNumber {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    return [[item valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
    
}

-(NSUInteger)numberOfTracksInPlayer:(BeamMusicPlayerViewController *)player
{
    return self.mediaItems.count;
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(BeamMusicPlayerReceivingBlock)receivingBlock {
    MPMediaItem* item = [self.mediaItems objectAtIndex:trackNumber];
    MPMediaItemArtwork* artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    if ( artwork ){
        UIImage* foo = [artwork imageWithSize:CGSizeMake(500, 500)];
        receivingBlock(foo, nil);
    } else {
        receivingBlock(nil,nil);
    }
}

#pragma mark Delegate Methods ( Used to control the music player )

-(void)musicPlayer:(BeamMusicPlayerViewController *)player didChangeTrack:(NSUInteger)track {
    [self.musicPlayer setNowPlayingItem:[self.mediaItems objectAtIndex:track]];
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

-(void)musicPlayerActionRequested:(BeamMusicPlayerViewController *)musicPlayer {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Action" message:@"The Player's action button was pressed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
    
}

@end
