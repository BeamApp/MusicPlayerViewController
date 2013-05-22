//
//  BeamMusicPlayerDelegate.h
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
@class BeamMusicPlayerViewController;


/**
 * The Delegate of the BeamMusicPlayerViewController must adopt the BeamMusicPlayerDelegate protocol to track changes
 * in the state of the music player.
 */
@protocol BeamMusicPlayerDelegate <NSObject>

@optional

/**
 * Called by the player after the player started playing a song.
 * @param player the BeamMusicPlayerViewController sending the message
 */
-(void)musicPlayerDidStartPlaying:(BeamMusicPlayerViewController*)player;

/**
 * Called after a user presses the "play"-button but before the player actually starts playing.
 * @param player the BeamMusicPlayerViewController sending the message
 * @return  If the value returned is NO, the player won't start playing. YES, tells the player to starts. Default is YES.
 */
-(BOOL)musicPlayerShouldStartPlaying:(BeamMusicPlayerViewController*)player;

/**
 * Called after the player stopped playing. This method is called both when the current song ends 
 * and if the user stops the playback. 
 * @param player the BeamMusicPlayerViewController sending the message
 */
-(void)musicPlayerDidStopPlaying:(BeamMusicPlayerViewController*)player;

/**
 * Called after the player stopped playing the last track.
 * @param player the BeamMusicPlayerViewController sending the message
 */
-(void)musicPlayerDidStopPlayingLastTrack:(BeamMusicPlayerViewController*)player;


/**
 * Called before the player stops playing but after the user initiated the stop action.
 * @param player the BeamMusicPlayerViewController sending the message
 * @return By returning NO here, the delegate may prevent the player from stopping the playback. Default YES.
 */
-(BOOL)musicPlayerShouldStopPlaying:(BeamMusicPlayerViewController*)player;

/**
 * Called after the player seeked or scrubbed to a new position. This is mostly the result of a user interaction.
 * @param player the BeamMusicPlayerViewController sending the message
 * @param position new position in seconds
 */
-(void)musicPlayer:(BeamMusicPlayerViewController*)player didSeekToPosition:(CGFloat)position;

/**
 * Called before the player actually skips to the next song, but after the user initiated that action.
 *
 * If an implementation returns NO, the track will not be changed, if it returns YES the track will be changed. If you do not implement this method, YES is assumed. 
 * @param player the BeamMusicPlayerViewController sending the message
 * @param track a NSUInteger containing the number of the new track
 * @return YES if the track can be changed, NO if not. Default YES.
 */
-(BOOL)musicPlayer:(BeamMusicPlayerViewController*)player shouldChangeTrack:(NSUInteger)track;

/**
 * Called after the music player changed to a new track
 *
 * You can implement this method if you need to react to the player changing tracks.
 * @param player the BeamMusicPlayerViewController changing the track
 * @param track a NSUInteger containing the number of the new track
 * @return the actual track the delegate has changed to
 */
-(NSInteger)musicPlayer:(BeamMusicPlayerViewController*)player didChangeTrack:(NSUInteger)track;

/**
 * Called when the player's volume changed
 *
 * Note that this not actually change the volume of anything, but is rather a result of a change in the internal state of the BeamMusicPlayerViewController. If you want to change the volume of a playback module, you can implement this method.
 * @param player The BeamMusicPlayerViewController changing the volume
 * @param volume A float holding the volume on a range from 0.0f to 1.0f
 */
-(void)musicPlayer:(BeamMusicPlayerViewController*)player didChangeVolume:(CGFloat)volume;

/**
 * Called when the player changes it's shuffle state.
 *
 * YES indicates the player is shuffling now, i.e. randomly selecting a next track from the valid range of tracks, NO
 * means there is no shuffling.
 * @param player The BeamMusicPlayerViewController that changes the shuffle state
 * @param shuffling YES if shuffling, NO if not
 */
-(void)musicPlayer:(BeamMusicPlayerViewController*)player didChangeShuffleState:(BOOL)shuffling;

/**
 * Called when the player changes it's repeat mode.
 *
 * The repeat modes are taken from MediaPlayer framework and indicate whether the player is in No Repeat, Repeat Once or Repeat All mode.
 * @param player The BeamMusicPlayerViewController that changes the repeat mode.
 * @param repeatMode a MPMusicRepeatMode indicating the currently active mode.
 */
-(void)musicPlayer:(BeamMusicPlayerViewController*)player didChangeRepeatMode:(MPMusicRepeatMode)repeatMode;

@end

