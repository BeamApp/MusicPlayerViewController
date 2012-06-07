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

@class BeamIpodExampleProvider;

typedef void (^BeamIpodExampleProviderVCBlock)(BeamMusicPlayerViewController*);
typedef void (^BeamIpodExampleProviderSelfBlock)(BeamIpodExampleProvider*);

@interface BeamIpodExampleProvider : NSObject<BeamMusicPlayerDelegate, BeamMusicPlayerDataSource> {
    BOOL propagatingData;
}

@property (nonatomic,strong) MPMusicPlayerController* musicPlayer; // An instance of an ipod music player
//@property (nonatomic,assign) BeamMusicPlayerViewController* controller; // the BeamMusicPlayerViewController
@property (copy,readonly) NSArray* mediaItems; // An array holding items in the playback queue
@property (nonatomic,strong) MPMediaQuery *query;
@property (nonatomic, copy) BeamIpodExampleProviderVCBlock backBlock;
@property (nonatomic, copy) BeamIpodExampleProviderVCBlock actionBlock;
@property (nonatomic, copy) BeamIpodExampleProviderSelfBlock onAskingForDataPropagationBlock;

-(void)propagateDataTo:(BeamMusicPlayerViewController*) controller;


@end
