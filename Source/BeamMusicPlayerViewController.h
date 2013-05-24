//
//  BeamMusicPlayerViewController.h
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "BeamMusicPlayerDelegate.h"
#import "BeamMusicPlayerDataSource.h"
#import "OBSlider.h"

/**
 * The Music Player component. This is a drop-in view controller and provides the UI for a music player.
 * It does not actually play music, just visualize music that is played somewhere else. The data to display
 * is provided using the datasource property, events can be intercepted using the delegate-property.
 */
@interface BeamMusicPlayerViewController : UIViewController


/// --------------------------------
/// @name Managing the Delegate and the Data Source
/// --------------------------------

/// The BeamMusicPlayerDelegate object that acts as the delegate of the receiving music player.
@property (nonatomic,assign) id<BeamMusicPlayerDelegate> delegate;

/// The BeamMusicPlayerDataSource object that acts as the data source of the receiving music player.
@property (nonatomic,assign) id<BeamMusicPlayerDataSource> dataSource;

/**
 * Reloads data from the data source and updates the player. If the player is currently playing, the playback is stopped.
 */
-(void)reloadData;


/// --------------------------------
/// @name Controlling Playback and Sound
/// --------------------------------

/// The index of the currently set track
@property (nonatomic) NSInteger currentTrack; 

/// YES, if the player is in play-state
@property (nonatomic,readonly) BOOL playing; 

/// The Current Playback position in seconds
@property (nonatomic) CGFloat currentPlaybackPosition; 

/// The current repeat mode of the player.
@property (nonatomic) MPMusicRepeatMode repeatMode; 

/// YES, if the player is shuffling
@property (nonatomic) BOOL shuffling; 

/// The Volume of the player. Valid values range from 0.0f to 1.0f
@property (nonatomic) CGFloat volume;

/**
 * Plays a given track using the supplied options.
 *
 * @param track the track that's to be played
 * @param position the position in the track at which the playback should begin
 * @param volume the Volume of the playback 
 */
-(void)playTrack:(NSUInteger)track atPosition:(CGFloat)position volume:(CGFloat)volume;


/**
 * Shows or Hides the scrobble overlay in 3.5 inch displays
 *
 * @param show Yes, to show, No to hide overlay
 * @param animated Yes, to smoothly fade overlay
 */
-(void)showScrobbleOverlay:(BOOL)show animated:(BOOL)animated;


/**
 * Starts playback. If the player is already playing, this method does nothing except wasting some cycles.
 */
-(void)play;

/**
 * Starts playing the specified track. If the track is already playing, this method does nothing.
 */
//-(void)playTrack:(NSUInteger)track;

/**
 * Pauses the player. If the player is already paused, this method does nothing except generating some heat.
 */
-(void)pause;

/**
 * Stops the Player. If the player is already stopped, this method does nothing but seeks to the beginning of the current song.
 */
-(void)stop;

/**
 * Skips to the next track. 
 *
 * If there is no next track, this method does nothing, if there is, it skips one track forward and informs the delegate.
 * In case [BeamMusicPlayerDelegate musicPlayer:shouldChangeTrack:] returns NO, the track is not changed.
 */
-(void)next;

/**
 * Skips to the previous track. 
 *
 * If there is no previous track, i.e. the current track number is 0, this method does nothing, if there is, it skips one track backward and informs the delegate.
 * In case the [BeamMusicPlayerDelegate musicPlayer:shouldChangeTrack:] returns NO, the track is not changed.
 */
-(void)previous;


/// --------------------------------
/// @name Controlling User Interaction
/// --------------------------------

/// If set to yes, the Previous-Track Button will be disabled if the first track of the set is played or set.
@property (nonatomic) BOOL shouldHidePreviousTrackButtonAtBoundary; 

/// If set to yes, the Next-Track Button will be disabled if the last track of the set is played or set.
@property (nonatomic) BOOL shouldHideNextTrackButtonAtBoundary; 

/// Block to be executed if the user presses the back button at the top. Button is hidden, if nil.
@property (nonatomic, copy) void (^backBlock)();

/// Block to be executed if the user presses the action button at the top right. Button is hidden, if nil.
@property (nonatomic, copy) void (^actionBlock)();

/// --------------------------------
/// @name Misc
/// --------------------------------

/// The preferred size for cover art in pixels
@property (nonatomic, readonly) CGSize preferredSizeForCoverArt;

/// yes, if data source provided cover art for current song
@property (nonatomic, readonly) BOOL customCovertArtLoaded;

/// Timespan before placeholder for albumart will be set (default is 0.5). Supports long loading times.
@property (nonatomic, assign) float placeholderImageDelay;



@end
