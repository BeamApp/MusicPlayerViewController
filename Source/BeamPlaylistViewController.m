//
//  BeamPlaylistViewController.m
//  BeamMusicPlayerExample
//
//  Created by Dominik Alexander on 26.06.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "BeamPlaylistViewController.h"
#import "BeamPlaylistTableViewCell.h"
#import "BeamRadialGradientView.h"
#import "BeamPlaylistTableViewCell.h"

@implementation BeamPlaylistViewController

@synthesize playerViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Customize table view
    UITableView *tableView = self.tableView;
    tableView.separatorColor = [UIColor colorWithRed:0.986 green:0.933 blue:0.994 alpha:0.10];
    tableView.showsVerticalScrollIndicator = NO;
    
    // Add gradient as background
    BeamRadialGradientView *playlistBackground = [[BeamRadialGradientView alloc] initWithFrame:tableView.frame];
    tableView.backgroundView = playlistBackground;
    
    // Remove separators
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    [tableView setTableFooterView:footer];
}

#pragma mark - UITableView Delegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([playerViewController.dataSource respondsToSelector:@selector(numberOfTracksInPlayer:)])
        return [playerViewController.dataSource numberOfTracksInPlayer:playerViewController];
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaylistCell";
    
    BeamPlaylistTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[BeamPlaylistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *track = [NSString stringWithFormat:@"%d.", indexPath.row + 1];
    NSString *title = [playerViewController.dataSource musicPlayer:playerViewController titleForTrack:indexPath.row];
    CGFloat duration = [playerViewController.dataSource musicPlayer:playerViewController lengthForTrack:indexPath.row];
    NSString *durationString = duration != 0.0f ? [NSString stringWithFormat:@"%d:%02d", (int)duration / 60, (int)duration % 60] : nil;
    
    cell.trackLabel.text = track;
    cell.titleLabel.text = title;
    cell.durationLabel.text = durationString;
    
    cell.currentSong = (indexPath.row == playerViewController.currentTrack);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Inform playerViewController to change the current track
    if (indexPath.row != playerViewController.currentTrack)
    {
        [playerViewController changeTrack:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Color every odd cell to transparent black.
    if (indexPath.row % 2 == 0)
    {
        cell.backgroundView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        cell.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    }
}

#pragma mark - Public methods

- (void)updateUI
{
    // (Re)calculate popoverSize
    NSInteger numberOfSongs = 1;
    if ([playerViewController.dataSource respondsToSelector:@selector(numberOfTracksInPlayer:)])
    {
        numberOfSongs = [playerViewController.dataSource numberOfTracksInPlayer:playerViewController];
    }
    self.contentSizeForViewInPopover = CGSizeMake(320.0f, numberOfSongs * 44.0f);
    
    // Reload the table view
    [self.tableView reloadData];
}

@end
