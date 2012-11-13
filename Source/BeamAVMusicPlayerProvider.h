//
//  BeamAVMusicPlayerProvider.h
//  BeamMusicPlayerExample
//
//  Created by Heiko Behrens on 13.11.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeamMusicPlayerDataSource.h"
#import "BeamMusicPlayerDelegate.h"
#import <AVFoundation/AVFoundation.h>


extern const NSString* BeamAVMusicPlayerProviderTrackDescriptionTitle;
extern const NSString* BeamAVMusicPlayerProviderTrackDescriptionArtist;
extern const NSString* BeamAVMusicPlayerProviderTrackDescriptionAlbum;
extern const NSString* BeamAVMusicPlayerProviderTrackDescriptionLengthInMilliseconds;

@interface BeamAVMusicPlayerProvider : NSObject<BeamMusicPlayerDelegate, BeamMusicPlayerDataSource>

@property (strong) AVAudioPlayer* audioPlayer;
@property (strong) NSDictionary* trackDescription;

@end
