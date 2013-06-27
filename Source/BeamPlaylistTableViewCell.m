//
//  BeamPlaylistTableViewCell.m
//  BeamMusicPlayerExample
//
//  Created by Dominik Alexander on 26.06.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "BeamPlaylistTableViewCell.h"

@interface BeamPlaylistTableViewCell ()
@property (nonatomic, readonly, strong) UIImageView *playingImageView;
@end

@implementation BeamPlaylistTableViewCell

@synthesize playingImageView = _playingImageView;
@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize trackLabel = _trackLabel;
@synthesize titleLabel = _titleLabel;
@synthesize durationLabel = _durationLabel;
@synthesize currentSong = _currentSong;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Add backgroundView
        self.backgroundColor = [UIColor clearColor];
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.frame];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView = backgroundView;
        
        // Calculate the frames of the labels (17.5% | 65% | 17.5%)
        CGFloat width = self.frame.size.width;
        CGFloat inset = 5.0f;
        
        CGFloat trackWidth = width * 0.175f;
        CGFloat durationWidth = width * 0.175f;
        
        CGRect trackFrame;
        CGRect titleDurationFrame;
        CGRectDivide(self.frame, &trackFrame, &titleDurationFrame, trackWidth, CGRectMinXEdge);
        trackFrame = CGRectInset(trackFrame, inset, inset);
        
        CGRect titleFrame;
        CGRect durationFrame;
        
        CGRectDivide(titleDurationFrame, &durationFrame, &titleFrame, durationWidth, CGRectMaxXEdge);
        titleFrame = CGRectInset(titleFrame, inset, inset);
        durationFrame = CGRectInset(durationFrame, inset, inset);
        
        // Add the labels
        _trackLabel = [[UILabel alloc] initWithFrame:trackFrame];
        _titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        _durationLabel = [[UILabel alloc] initWithFrame:durationFrame];
        
        _trackLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _durationLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        _trackLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.backgroundColor = [UIColor clearColor];
        
        // Uncomment to see the frames of the labels (useful for debugging)
//        _trackLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
//        _titleLabel.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5f];
//        _durationLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
        
        _trackLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _durationLabel.textAlignment = NSTextAlignmentRight;
        
        [self addSubview:_trackLabel];
        [self addSubview:_titleLabel];
        [self addSubview:_durationLabel];
        
        // Add vertical separators
        UIView *separator1 = [[UIView alloc] initWithFrame:CGRectMake(trackWidth, 0.0f, 1.0f, self.frame.size.height - 1.0f)];
        UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - durationWidth, 0.0f, 1.0f, self.frame.size.height - 1.0f)];
        separator1.backgroundColor = [UIColor colorWithRed:0.986 green:0.933 blue:0.994 alpha:0.10];
        separator2.backgroundColor = separator1.backgroundColor;
        [self addSubview:separator1];
        [self addSubview:separator2];
        
        // Add image view to indicate the currently playing song
        CGRect playingImageFrame = trackFrame;
        playingImageFrame.size.width = playingImageFrame.size.width / 2;
        playingImageFrame.origin.x = playingImageFrame.origin.x + playingImageFrame.size.width;
        UIImageView *playingImageView = [[UIImageView alloc] initWithFrame:playingImageFrame];
        playingImageView.contentMode = UIViewContentModeCenter;
        _playingImageView = playingImageView;
        [self addSubview:_playingImageView];
        
        // Set default font and textColor
        self.font = [UIFont boldSystemFontOfSize:15.0f];
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Getter / Setter

- (void)setFont:(UIFont *)font
{
    _font = font;
    
    // Update the font of the labels
    self.trackLabel.font = _font;
    self.titleLabel.font = _font;
    self.durationLabel.font = _font;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    
    // Update the textColor of the labels
    self.trackLabel.textColor = textColor;
    self.titleLabel.textColor = textColor;
    self.durationLabel.textColor = textColor;
}

- (void)setCurrentSong:(BOOL)currentSong
{
    _currentSong = currentSong;
    
    // Show playing image if it is the current song
    if (currentSong)
    {
        [self.playingImageView setImage:[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/playing"]];
    }
    else
    {
        [self.playingImageView setImage:nil];
    }
}

@end
