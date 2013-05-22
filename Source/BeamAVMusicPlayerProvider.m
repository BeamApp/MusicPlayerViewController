//
//  BeamAVMusicPlayerProvider.m
//  BeamMusicPlayerExample
//
//  Created by Heiko Behrens on 13.11.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "BeamAVMusicPlayerProvider.h"
#import <MediaPlayer/MediaPlayer.h>

const NSString* BeamAVMusicPlayerProviderTrackDescriptionTitle = @"trackName";
const NSString* BeamAVMusicPlayerProviderTrackDescriptionArtist = @"artistName";
const NSString* BeamAVMusicPlayerProviderTrackDescriptionAlbum = @"collectionName";
const NSString* BeamAVMusicPlayerProviderTrackDescriptionLengthInMilliseconds = @"trackTimeMillis";
const NSString* BeamAVMusicPlayerProviderTrackDescriptionArtworkUrl = @"artworkUrl100";

@implementation BeamAVMusicPlayerProvider

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.controller stop];
}

-(void)setAudioPlayer:(AVAudioPlayer *)audioPlayer {
    _audioPlayer = audioPlayer;
    _audioPlayer.delegate = self;
}

-(NSString *)musicPlayer:(BeamMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
    return self.trackDescription[BeamAVMusicPlayerProviderTrackDescriptionTitle];
}

-(NSString *)musicPlayer:(BeamMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
    return self.trackDescription[BeamAVMusicPlayerProviderTrackDescriptionArtist];
}

-(NSString *)musicPlayer:(BeamMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
    return self.trackDescription[BeamAVMusicPlayerProviderTrackDescriptionAlbum];
}

-(CGFloat)musicPlayer:(BeamMusicPlayerViewController *)player lengthForTrack:(NSUInteger)trackNumber {
    if(self.audioPlayer)
        return self.audioPlayer.duration;
    
    return [self.trackDescription[BeamAVMusicPlayerProviderTrackDescriptionLengthInMilliseconds] floatValue] / 1000.0f;
}

-(void)musicPlayerDidStartPlaying:(BeamMusicPlayerViewController *)player {
    [self.audioPlayer play];
}

-(void)musicPlayerDidStopPlaying:(BeamMusicPlayerViewController *)player {
    [self.audioPlayer pause];
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player didSeekToPosition:(CGFloat)position {
    self.audioPlayer.currentTime = position;
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player didChangeVolume:(CGFloat)volume {
    MPMusicPlayerController.iPodMusicPlayer.volume = volume;
}

-(CGFloat)volumeForMusicPlayer:(BeamMusicPlayerViewController*)player{
    return MPMusicPlayerController.iPodMusicPlayer.volume;
}


-(NSURL*)artworkUrl {
    // TODO: derive higher-res image from artwork url
    return [NSURL URLWithString:self.trackDescription[BeamAVMusicPlayerProviderTrackDescriptionArtworkUrl]];
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(BeamMusicPlayerReceivingBlock)receivingBlock {
    NSURL *url = self.artworkUrl;
    if(url)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData* urlData = [NSData dataWithContentsOfURL:url];
            
            UIImage* image = [UIImage imageWithData:urlData];
            receivingBlock(image,nil);
        });
    
}


@end
