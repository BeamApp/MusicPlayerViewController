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

NSString* BeamAVMusicPlayerProviderTrackDescriptionArtworkPattern = @"^artworkUrl(\\d+)$";

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
#if TARGET_IPHONE_SIMULATOR
    return 0.6;
#else
    return MPMusicPlayerController.iPodMusicPlayer.volume;
#endif
}

+(id)artworkUrlValueForSize:(int)size inDescription:(NSDictionary*)description {
    static NSRegularExpression *regex;
    if(!regex) {
        regex = [NSRegularExpression regularExpressionWithPattern:BeamAVMusicPlayerProviderTrackDescriptionArtworkPattern options:0 error:nil];
    }
    
    const int minCorridorSize = (int)(size * 0.9);
    const int maxCorridorSize = size;
    int largestSizeInCorridor = INT_MIN;
    int largestSizeBelowCorridor = INT_MIN;
    int smallestSizeAboveCorridor = INT_MAX;

    for(NSString* key in description.keyEnumerator) {
        NSTextCheckingResult *match = [regex firstMatchInString:key options:0 range:NSMakeRange(0, key.length)];
        if(match) {
            NSRange matchRange = [match rangeAtIndex:1];
            NSString *matchString = [key substringWithRange:matchRange];
            int keySize = matchString.intValue;

            if(keySize > maxCorridorSize)
                smallestSizeAboveCorridor = MIN(smallestSizeAboveCorridor, keySize);
            if(keySize < minCorridorSize)
                largestSizeBelowCorridor = MAX(largestSizeBelowCorridor, keySize);
            if(keySize >= minCorridorSize && keySize <= maxCorridorSize)
                largestSizeInCorridor = MAX(keySize, largestSizeInCorridor);
        }
    }

    int bestSize;
    if(largestSizeInCorridor > INT_MIN)
        bestSize = largestSizeInCorridor;
    else if (smallestSizeAboveCorridor < INT_MAX)
        bestSize = smallestSizeAboveCorridor;
    else if (largestSizeBelowCorridor > INT_MIN)
        bestSize = largestSizeBelowCorridor;
    else
        return nil;

    NSString* key = [NSString stringWithFormat:@"artworkUrl%d", bestSize];
    return description[key];
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(BeamMusicPlayerReceivingBlock)receivingBlock {
    int maxSide =  (int)ceil(MAX(player.preferredSizeForCoverArt.width, player.preferredSizeForCoverArt.height));
    id urlValue = [self.class artworkUrlValueForSize:maxSide inDescription:self.trackDescription];
    if(urlValue) {
        NSURL *url = urlValue ? [NSURL URLWithString:urlValue] : nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData* urlData = [NSData dataWithContentsOfURL:url];
            NSLog(@"loading %@", url);
            UIImage* image = [UIImage imageWithData:urlData];
            receivingBlock(image,nil);
        });
    }
}


@end
