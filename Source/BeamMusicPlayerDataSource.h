//
//  BeamMusicPlayerDataSource.h
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Block Type used to receive images from the BeamMusicPlayerDataSource
 */
typedef void(^BeamMusicPlayerReceivingBlock)(UIImage* image, NSError** error);


@class BeamMusicPlayerViewController;

/**
 * The DataSource for the BeamMusicPlayerViewController provides all data necessary to display
 * a player UI filled with the appropriate information. 
 */
@protocol BeamMusicPlayerDataSource <NSObject>

/**
 * Returns the title of the given track and player as a NSString. You can return nil for no title.
 * @param player the BeamMusicPlayerViewController that is making this request.
 * @param trackNumber the track number this request is for.
 * @return A string to use as the title of the track. If you return nil, this track will have no title.
 */
-(NSString*)musicPlayer:(BeamMusicPlayerViewController*)player titleForTrack:(NSUInteger)trackNumber;

/**
 * Returns the artist for the given track in the given BeamMusicPlayerViewController.
 * @param player the BeamMusicPlayerViewController that is making this request.
 * @param trackNumber the track number this request is for.
 * @return A string to use as the artist name of the track. If you return nil, this track will have no artist name.
 */
-(NSString*)musicPlayer:(BeamMusicPlayerViewController*)player artistForTrack:(NSUInteger)trackNumber;

/**
* Returns the album for the given track in the given BeamMusicPlayerViewController.
 * @param player the BeamMusicPlayerViewController that is making this request.
 * @param trackNumber the track number this request is for.
 * @return A string to use as the album name of the track. If you return nil, this track will have no album name.
*/
-(NSString*)musicPlayer:(BeamMusicPlayerViewController*)player albumForTrack:(NSUInteger)trackNumber;

/**
 * Returns the length for the given track in the given BeamMusicPlayerViewController. Your implementation must provide a 
 * value larger than 0.
 * @param player the BeamMusicPlayerViewController that is making this request.
 * @param trackNumber the track number this request is for.
 * @return length in seconds
 */
-(CGFloat)musicPlayer:(BeamMusicPlayerViewController*)player lengthForTrack:(NSUInteger)trackNumber;

@optional

/**
 * Returns the volume for the given BeamMusicPlayerViewController
 * @param player the BeamMusicPlayerViewController that is making this request.
 * @return volume A float holding the volume on a range from 0.0f to 1.0f
 */
-(CGFloat)volumeForMusicPlayer:(BeamMusicPlayerViewController*)player;

/**
 * Returns the number of tracks for the given player. If you do not implement this method
 * or return anything smaller than 2, one track is assumed and the skip-buttons are disabled.
 * @param player the BeamMusicPlayerViewController that is making this request.
 * @return number of available tracks, -1 if unknown
 */
-(NSInteger)numberOfTracksInPlayer:(BeamMusicPlayerViewController*)player;

/**
 * Returns the artwork for a given track.
 *
 * The artwork is returned using a receiving block ( BeamMusicPlayerReceivingBlock ) that takes an UIImage and an optional error. If you supply nil as an image, a placeholder will be shown.
 * @param player the BeamMusicPlayerViewController that needs artwork.
 * @param trackNumber the index of the track for which the artwork is requested.
 * @param receivingBlock a block of type BeamMusicPlayerReceivingBlock that needs to be called when the image is prepared by the receiver.
 * @see [BeamMusicPlayerViewController preferredSizeForCoverArt]
 */
-(void)musicPlayer:(BeamMusicPlayerViewController*)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(BeamMusicPlayerReceivingBlock)receivingBlock;

@end
