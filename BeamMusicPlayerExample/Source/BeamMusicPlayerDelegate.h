//
//  BeamMusicPlayerDelegate.h
//  BeamMusicPlayerExample
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BeamMusicPlayerViewController;


/**
 * The Delegate of the BeamMusicPlayerViewController must adopt the BeamMusicPlayerDelegate protocol to track changes
 * in the state of the music player.
 */
@protocol BeamMusicPlayerDelegate <NSObject>

@optional

/**
 * Called by the player after the player started playing a song.
 */
-(void)playerDidStartPlaying:(BeamMusicPlayerViewController*)player;

/**
 * Called after a user presses the "play"-button but before the player actually starts playing.
 * If the value returned is NO, the player won't start playing, if you don't implement this method or
 * return YES, the player starts.
 */
-(BOOL)playerShouldStartPlaying:(BeamMusicPlayerViewController*)player;

/**
 * Called after the player stopped playing. This method is called both when the current song ends 
 * and if the user stops the playback. 
 */
-(void)playerDidStopPlaying:(BeamMusicPlayerViewController*)player;

/**
 * Called after the player stopped playing the last track.
 */
-(void)playerDidStopPlayingLastTrack:(BeamMusicPlayerViewController*)player;


/**
 * Called before the player stops playing but after the user initiated the stop action. By returning NO here,
 * the delegate may prevent the player from stopping the playback. 
 */
-(BOOL)playerShouldStopPlaying:(BeamMusicPlayerViewController*)player;

/**
 * Called after the player seeked or scrubbed to a new position. This is mostly the result of a user interaction.
 */
-(void)player:(BeamMusicPlayerViewController*)player DidSeekToPosition:(CGFloat)position ;

/**
 * Called before the player actually skips to the next song, but after the user initiated that action.
 */
-(BOOL)playerShouldSkipForward:(BeamMusicPlayerViewController*)player;

/**
 * Called after the player skipped to the next track, but before playback began.
 */
-(void)playerDidSkipForward:(BeamMusicPlayerViewController*)player;

/**
 * Called before the player actually skips to the previous song, but after the user initiated that action.
 */
-(BOOL)playerShouldSkipBackwards:(BeamMusicPlayerViewController*)player;

/**
 * Called after the player skipped to the previous track, but before playback begins.
 */
-(void)playerDidSkipBackwards:(BeamMusicPlayerViewController*)player;

/**
 * Called when the player's volume changed
 */
-(void)player:(BeamMusicPlayerViewController*)player didChangeVolume:(CGFloat)volume;

@end

