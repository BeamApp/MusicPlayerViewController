//
//  BeamIpodExampleProvider.h
//  BeamMusicPlayerExample
//
//  Created by Moritz Haarmann on 31.05.12.
//  Copyright (c) 2012 n/a. All rights reserved.
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
