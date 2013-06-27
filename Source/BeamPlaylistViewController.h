//
//  BeamPlaylistViewController.h
//  BeamMusicPlayerExample
//
//  Created by Dominik Alexander on 26.06.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeamMusicPlayerViewController.h"

/**
 * A subclass of UITableViewController to display the playlist. Make sure to set the playerViewController property before the view gets loaded.
 */
@interface BeamPlaylistViewController : UITableViewController

/// An instance of BeamMusicPlayerViewController to get the data for the playlist.
@property (weak, nonatomic) BeamMusicPlayerViewController *playerViewController;

/// Updates the playlist according to the current state of playerViewController.dataSource. Make sure to call this method whenever a change to the playlist or current track is made.
- (void)updateUI;

@end
