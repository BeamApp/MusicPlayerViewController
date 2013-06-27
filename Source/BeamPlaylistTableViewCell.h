//
//  BeamPlaylistTableViewCell.h
//  BeamMusicPlayerExample
//
//  Created by Dominik Alexander on 26.06.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A subclass of UITableViewCell to display details of a song. It contains three labels to display track, title and duration of a song.
 */
@interface BeamPlaylistTableViewCell : UITableViewCell

/// The font used for the 3 labels. The default is a bold system font of size 15.0f.
@property (nonatomic, strong) UIFont *font;

/// The text color used for the 3 labels. The default is white.
@property (nonatomic, strong) UIColor *textColor;

/// The label to show the track.
@property (nonatomic, readonly, strong) UILabel *trackLabel;

/// The label to show the title.
@property (nonatomic, readonly, strong) UILabel *titleLabel;

/// The label to show the duration
@property (nonatomic, readonly, strong) UILabel *durationLabel;

/// Specifies if the song described by this cell is the current song. The default is NO. If this property is set to YES the cell displays a blue "play icon" on the left.
@property (nonatomic, getter = isCurrentSong) BOOL currentSong;

@end
