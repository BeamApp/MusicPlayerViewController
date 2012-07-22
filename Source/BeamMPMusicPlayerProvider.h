//
//  BeamIpodExampleProvider.h
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 31.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BeamMusicPlayerViewController.h"

@interface BeamMPMusicPlayerProvider : NSObject<BeamMusicPlayerDelegate, BeamMusicPlayerDataSource>

@property (nonatomic,strong) MPMusicPlayerController* musicPlayer; // An instance of an ipod music player
@property (nonatomic,strong) BeamMusicPlayerViewController* controller; // the BeamMusicPlayerViewController
@property (nonatomic,copy) NSArray *mediaItems;

-(void)propagateMusicPlayerState;

@end
