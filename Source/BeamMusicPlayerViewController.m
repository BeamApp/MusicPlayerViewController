//
//  BeamMusicPlayerViewController.m
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import "BeamMusicPlayerViewController.h"
#import "NSDateFormatter+Duration.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AutoScrollLabel/AutoScrollLabel.h>
#import <QuartzCore/QuartzCore.h>
#import "BeamPlaylistViewController.h"

@interface BeamMusicPlayerViewController()

-(IBAction)nextAction:(id)sender;
-(IBAction)playAction:(id)sender;
-(IBAction)sliderValueChanged:(id)slider;

@property (nonatomic, weak) IBOutlet UIView *volumeViewContainer; // Parent of MPVolumeView (Outlet to change background color if needed)
@property (nonatomic, weak) IBOutlet MPVolumeView *volumeView; // Volume slider (at bottom on iPhone, at top on iPad)

@property (nonatomic,weak) IBOutlet OBSlider* progressSlider; // Progress Slider buried in the Progress View

@property (nonatomic,weak) IBOutlet AutoScrollLabel* trackTitleLabel; // The Title Label
@property (nonatomic,weak) IBOutlet AutoScrollLabel* albumTitleLabel; // Album Label
@property (nonatomic,weak) IBOutlet AutoScrollLabel* artistNameLabel; // Artist Name Label

@property (nonatomic,weak) IBOutlet UIToolbar* controlsToolbar; // Encapsulates the Play, Forward, Rewind buttons

@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionButton; // retain, since controller keeps a reference while it might be detached from view hierarchy
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton; // retain, since controller keeps a reference while it might be detached from view hierarchy
@property (nonatomic, retain) UIBarButtonItem *playlistButton; // Button which is shown, when actionBlock is nil (the default)

@property (nonatomic,weak) IBOutlet UIBarButtonItem* rewindButton; // Previous Track
@property (nonatomic,weak) IBOutlet UIBarButtonItem* fastForwardButton; // Next Track
@property (nonatomic,weak) IBOutlet UIBarButtonItem* playButton; // Play

@property (nonatomic,weak) IBOutlet UIButton* rewindButtonIPad; // Previous Track
@property (nonatomic,weak) IBOutlet UIButton* fastForwardButtonIPad; // Next Track
@property (nonatomic,weak) IBOutlet UIButton* playButtonIPad; // Play

@property (nonatomic, weak) IBOutlet UIView *artworkPlaylistContainer; // Container for albumArtImageView and playlistTableView (not present on iPad)
@property (nonatomic,weak) IBOutlet UIImageView* albumArtImageView; // Album Art Image View

@property (nonatomic,strong) NSTimer* playbackTickTimer; // Ticks each seconds when playing.

@property (nonatomic,strong) UITapGestureRecognizer* coverArtGestureRecognizer; // Tap Recognizer used to dim in / out the scrobble overlay.

@property (nonatomic,weak) IBOutlet UIView* scrobbleOverlay; // Overlay that serves as a container for all components visible only in scrobble-mode
@property (nonatomic,weak) IBOutlet UILabel* timeElapsedLabel; // Elapsed Time Label
@property (nonatomic,weak) IBOutlet UILabel* timeRemainingLabel; // Remaining Time Label
@property (nonatomic,weak) IBOutlet UIButton* shuffleButton; // Shuffle Button
@property (nonatomic,weak) IBOutlet UIButton* repeatButton; // Repeat button
@property (nonatomic,weak) IBOutlet UILabel* scrobbleHelpLabel; // The Scrobble Usage hint Label
@property (nonatomic,weak) IBOutlet UILabel* numberOfTracksLabel; // Track x of y or the scrobble speed
@property (nonatomic,weak) IBOutlet UIImageView* scrobbleHighlightShadow; // It's reflection
@property (nonatomic,weak) IBOutlet UIImageView *scrobbleBackgroundImage;

@property(nonatomic,weak) IBOutlet UIView* controlView;

@property (nonatomic) CGFloat currentTrackLength; // The Length of the currently playing track
@property (nonatomic) NSInteger numberOfTracks; // Number of tracks, <0 if unknown
@property (readonly) BOOL numberOfTracksAvailable;

@property (nonatomic) BOOL scrobbling; // Whether the player is currently scrobbling

@property (nonatomic) BOOL lastDirectionChangePositive; // Whether the last direction change was positive.

@property (nonatomic,weak) IBOutlet UINavigationItem* navigationItem;
@property (nonatomic,weak) IBOutlet UINavigationBar* navigationBar;

@property (nonatomic, strong) UIButton *playlistToggleButton; // Button that toggles between artwork and playlist (PopOver on iPad)
@property (nonatomic, readonly, strong) BeamPlaylistViewController *playlistViewController; // View controller that displays the playlist (created lazy)
@property (nonatomic, strong) UIPopoverController *playlistPopoverController; // Popover controller to display the playlist (iPad only)

@end

@implementation BeamMusicPlayerViewController

@synthesize trackTitleLabel;
@synthesize albumTitleLabel;
@synthesize artistNameLabel;
@synthesize actionButton;
@synthesize backButton;
@synthesize rewindButton;
@synthesize fastForwardButton;
@synthesize playButton;
@synthesize rewindButtonIPad;
@synthesize fastForwardButtonIPad;
@synthesize playButtonIPad;
@synthesize volumeViewContainer;
@synthesize progressSlider;
@synthesize controlsToolbar;
@synthesize albumArtImageView;
@synthesize delegate;
@synthesize dataSource;
@synthesize currentTrack;
@synthesize currentPlaybackPosition;
@synthesize playbackTickTimer;
@synthesize playing;
@synthesize scrobbleOverlay;
@synthesize timeElapsedLabel;
@synthesize timeRemainingLabel;
@synthesize shuffleButton;
@synthesize repeatButton;
@synthesize coverArtGestureRecognizer;
@synthesize currentTrackLength;
@synthesize numberOfTracks;
@synthesize scrobbling;
@synthesize scrobbleHelpLabel;
@synthesize numberOfTracksLabel;
@synthesize scrobbleHighlightShadow;
@synthesize repeatMode;
@synthesize shuffling;
@synthesize lastDirectionChangePositive;
@synthesize shouldHideNextTrackButtonAtBoundary;
@synthesize shouldHidePreviousTrackButtonAtBoundary;
@synthesize navigationItem;
@synthesize preferredSizeForCoverArt;
@synthesize backBlock, actionBlock;
@synthesize placeholderImageDelay;
@synthesize playlistViewController = _playlistViewController;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.flipDuration = 0.8;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.flipDuration = 0.8;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.flipDuration = 0.8;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/black_linen_v2"]];
    
    // Scrobble overlay should always be visible on tall phones
    if(self.isTallPhone) {
        self.scrobbleOverlay.alpha = 1;
    } else {
        // on small phones, let tap toggle overlay
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            self.scrobbleOverlay.alpha = 0;
            self.coverArtGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverArtTapped:)];
            [self.albumArtImageView addGestureRecognizer:self.coverArtGestureRecognizer];
        } else {
            if(!self.isIOS7) {
                //on ipad use shadow behind cover art
                self.albumArtImageView.layer.shadowColor = [UIColor blackColor].CGColor;
                self.albumArtImageView.layer.shadowOpacity = 0.8;
                self.albumArtImageView.layer.shadowRadius = 10.0;
                self.albumArtImageView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
                self.albumArtImageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.albumArtImageView.bounds].CGPath;
            }
        }
    }
    
    // Progess Slider
    UIImage* knob = [UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/VolumeKnob"];
    [progressSlider setThumbImage:knob forState:UIControlStateNormal];
    progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIImage* minImg = [[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/speakerSliderMinValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    UIImage* maxImg = [[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/speakerSliderMaxValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    [progressSlider setMinimumTrackImage:minImg forState:UIControlStateNormal];
    [progressSlider setMaximumTrackImage:maxImg forState:UIControlStateNormal];
    
    // Volume Slider
    volumeViewContainer.backgroundColor = [UIColor clearColor];
#if TARGET_IPHONE_SIMULATOR
    if(!self.isIOS5_0) {
        UILabel *notSupportedLabel = [[UILabel alloc] init];
        notSupportedLabel.frame = volumeViewContainer.bounds;
        notSupportedLabel.text = @"No Volume Available";
        notSupportedLabel.backgroundColor = [UIColor clearColor];
        notSupportedLabel.textColor = [UIColor whiteColor];
        notSupportedLabel.textAlignment = NSTextAlignmentCenter;
        notSupportedLabel.font = [UIFont boldSystemFontOfSize:13];
        [volumeViewContainer addSubview:notSupportedLabel];
    }
#else
    // Since there is a bug/glitch in iOS with setting the thumb, we need to use an image with 5pt transparency at the bottom
    UIImage* knobImg = [UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/mpSpeakerSliderKnob.png"];
    [self.volumeView setVolumeThumbImage:knobImg forState:UIControlStateNormal];
    [self.volumeView setVolumeThumbImage:knobImg forState:UIControlStateHighlighted];
    [self.volumeView setMinimumVolumeSliderImage:minImg forState:UIControlStateNormal];
    [self.volumeView setMaximumVolumeSliderImage:maxImg forState:UIControlStateNormal];
#endif
    
    // explicitly tint buttons
    rewindButton.tintColor = UIColor.whiteColor;
    playButton.tintColor = UIColor.whiteColor;
    fastForwardButton.tintColor = UIColor.whiteColor;
    
    // The Original Toolbar is 48px high in the iPod/Music app
    CGRect toolbarRect = self.controlsToolbar.frame;
    toolbarRect.size.height = 48;
    self.controlsToolbar.frame = toolbarRect;

    // Set UI to non-scrobble
    [self setScrobbleUI:NO animated:NO];
    
    // Set up labels. These are autoscrolling and need code-base setup.
    [self.artistNameLabel setShadowColor:[UIColor blackColor]];
    [self.artistNameLabel setShadowOffset:CGSizeMake(0, -1)];
    
    [self.albumTitleLabel setShadowColor:[UIColor blackColor]];
    [self.albumTitleLabel setShadowOffset:CGSizeMake(0, -1)];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [self.artistNameLabel setTextColor:[UIColor lightTextColor]];
        [self.artistNameLabel setFont:[UIFont boldSystemFontOfSize:12]];
        
        [self.albumTitleLabel setTextColor:[UIColor lightTextColor]];
        [self.albumTitleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        
        self.trackTitleLabel.textColor = [UIColor whiteColor];
        [self.trackTitleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    } else {
        self.artistNameLabel.textColor = [UIColor lightTextColor];
        [self.artistNameLabel setFont:[UIFont boldSystemFontOfSize:14]];
        
        self.albumTitleLabel.textColor = [UIColor lightTextColor];
        [self.albumTitleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        
        self.trackTitleLabel.textColor = [UIColor lightGrayColor];
        [self.trackTitleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        
        [self.trackTitleLabel setShadowColor:[UIColor blackColor]];
        [self.trackTitleLabel setShadowOffset:CGSizeMake(0, -1)];
    }
    
    if(self.isIOS7) {
        CGFloat statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
        self.navigationBar.frame = CGRectOffset(self.navigationBar.frame, 0, statusBarHeight);
        self.navigationBar.tintColor = UIColor.whiteColor;
        CGRect f = self.artworkPlaylistContainer.frame;
        f.origin.y += statusBarHeight;
        f.size.height -= statusBarHeight;
        self.artworkPlaylistContainer.frame = f;
        if(self.isTallPhone) {
            self.artworkPlaylistContainer.backgroundColor = UIColor.clearColor;
            self.scrobbleHighlightShadow.hidden = YES;
            self.scrobbleBackgroundImage.hidden = YES;
        }
        
        self.controlsToolbar.tintColor = UIColor.whiteColor;
        self.progressSlider.frame = CGRectOffset(self.progressSlider.frame, 0, -3);
    }
    
    self.placeholderImageDelay = 0.5;

    
    // Create the playlist button
    UIImage *barButtonBackground = [[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/bar_button"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 4.0f, 0.0f, 4.0f)];
    
    UIButton *playlistButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 30.0f)];
    [playlistButton setImage:[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/playlist"] forState:UIControlStateNormal];
    [playlistButton setBackgroundImage:barButtonBackground forState:UIControlStateNormal];
    [playlistButton addTarget:self action:@selector(playlistButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [playlistButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.playlistToggleButton = playlistButton;
    self.playlistButton = [[UIBarButtonItem alloc] initWithCustomView:playlistButton];
    
    // force UI to update properly
    self.actionBlock = self->actionBlock;
    self.backBlock = self->backBlock;
    
    // force re-layout according to interface orientation
    dispatch_after(0, dispatch_get_current_queue(), ^{
        [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
        [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
    });
}

- (void)viewDidUnload
{
    self.actionButton = nil;
    self.backButton = nil;
    [self setScrobbleBackgroundImage:nil];
    [super viewDidUnload];
    self.coverArtGestureRecognizer = nil;
    // Release any retained subviews of the main view.
}

-(NSUInteger)supportedInterfaceOrientations {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    } else {
        return YES;
    }
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGFloat statusBarHeight = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? UIApplication.sharedApplication.statusBarFrame.size.width : UIApplication.sharedApplication.statusBarFrame.size.height;
        CGFloat dy = self.isIOS7 ? statusBarHeight : 0;
        CGRect f = self.albumArtImageView.frame;
        f.origin.x = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 65 + dy : 84;
        f.origin.y = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? (int)((self.view.bounds.size.height-self.navigationBar.bounds.size.height-f.size.height)/2)+self.navigationBar.bounds.size.height : 65 + dy;
        self.albumArtImageView.frame = f;
        
        f = self.controlView.frame;
        f.size.width = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 350 : 600;
        f.origin.x = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 660 + dy : 84;
        f.origin.y = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 220 : 675 + dy;
        self.controlView.frame = f;
        
        // workaround: on iOS7 the progress slider grows while rotating, force size
        f = self.progressSlider.frame;
        f.size.width = self.controlView.bounds.size.width - 2 * f.origin.x;
        self.progressSlider.frame = f;
        
    }
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.albumTitleLabel setNeedsLayout];
    [self.artistNameLabel setNeedsLayout];
    [self.trackTitleLabel setNeedsLayout];
    
}


- (void)setActionBlock:(void (^)())block {
    self->actionBlock = block;
    self.navigationItem.rightBarButtonItem = self.actionBlock ? self.actionButton : self.playlistButton;
}

- (void)setBackBlock:(void (^)())block {
    self->backBlock = block;
    self.navigationItem.leftBarButtonItem = self.backBlock ? self.backButton : nil;
}

-(BOOL)isIOS5_0 {
    return ([UIDevice.currentDevice.systemVersion compare:@"5.1" options:NSNumericSearch]) == NSOrderedAscending;
}

-(BOOL)isIOS7 {
    NSLog(@"__IPHONE_OS_VERSION_MAX_ALLOWED: %d", __IPHONE_OS_VERSION_MAX_ALLOWED);
    NSLog(@"__IPHONE_6_1: %d", __IPHONE_6_1);
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    return ([UIDevice.currentDevice.systemVersion compare:@"7" options:NSNumericSearch]) >= NSOrderedSame;
#else
    return NO;
#endif
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}
#endif


-(BOOL)isTallPhone {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && (screenSize.height > 480.0f);
}

-(BOOL)isSmallPhone {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && (screenSize.height <= 480.0f);
}

- (BeamPlaylistViewController *)playlistViewController
{
    if (!_playlistViewController)
    {
        _playlistViewController = [[BeamPlaylistViewController alloc] initWithStyle:UITableViewStylePlain];
        _playlistViewController.playerViewController = self;
    }
    
    return _playlistViewController;
}

#pragma mark - Playback Management

-(BOOL)numberOfTracksAvailable {
    return self.numberOfTracks >= 0;
}

-(void)setAlbumArtToPlaceholder {
    self.albumArtImageView.image = [UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/noartplaceholder.png"];
    
    // Update the small artwork if present
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.playlistVisible)
    {
        [self.playlistToggleButton setImage:self.albumArtImageView.image forState:UIControlStateNormal];
    }
}

/**
 * Updates the UI to match the current track by requesting the information from the datasource.
 */
-(void)updateUIForCurrentTrack {

    self.artistNameLabel.text = [self.dataSource musicPlayer:self artistForTrack:self.currentTrack];
    self.trackTitleLabel.text = [self.dataSource musicPlayer:self titleForTrack:self.currentTrack];
    self.albumTitleLabel.text = [self.dataSource musicPlayer:self albumForTrack:self.currentTrack];

    // set coverart to placeholder at a later point in time. Might be cancelled if datasource provides different image (see below)
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAlbumArtToPlaceholder) object:nil];
    [self performSelector:@selector(setAlbumArtToPlaceholder) withObject:nil afterDelay:self.placeholderImageDelay];

    // We only request the coverart if the delegate responds to it.
    _customCovertArtLoaded = NO;
    if ( [self.dataSource respondsToSelector:@selector(musicPlayer:artworkForTrack:receivingBlock:)]) {
        
        // TODO: this transition needs to be overhauled before going live
//        CATransition* transition = [CATransition animation];
//        transition.type = kCATransitionPush;
//        transition.subtype = self.lastDirectionChangePositive ? kCATransitionFromRight : kCATransitionFromLeft;
//        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//        [[self.albumArtImageView layer] addAnimation:transition forKey:@"SlideOutandInImagek"];
//
//        [[self.albumArtReflection layer] addAnimation:transition forKey:@"SlideOutandInImagek"];

        // Copy the current track to another variable, otherwise we would just access the current one.
        NSUInteger track = self.currentTrack;
        // Request the image. 
        [self.dataSource musicPlayer:self artworkForTrack:self.currentTrack receivingBlock:^(UIImage *image, NSError *__autoreleasing *error) {
            if ( track == self.currentTrack ){
            
                // If there is no image given, stay with the placeholder
                if ( image  != nil ){

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAlbumArtToPlaceholder) object:nil];
                        self.albumArtImageView.image = image;
                        // Update the small artwork if present
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.playlistVisible)
                        {
                            [self.playlistToggleButton setImage:self.albumArtImageView.image forState:UIControlStateNormal];
                        }
                        _customCovertArtLoaded = YES;
                    });
                }
            
            } else {
                NSLog(@"Discarded CoverArt for track: %d, current track already moved to %d.", track, self.currentTrack);
            }
        }];
    }
}

-(void)play {
    if ( !self.playing ){
        self->playing = YES;

        [self startPlaybackTickTimer];
        
        if ( [self.delegate respondsToSelector:@selector(musicPlayerDidStartPlaying:)] ){
            [self.delegate musicPlayerDidStartPlaying:self];
        }
        [self adjustPlayButtonState];
    }
}

-(void)pause {
    if ( self.playing ){
        self->playing = NO;
        [self stopPlaybackTickTimer];

        if ( [self.delegate respondsToSelector:@selector(musicPlayerDidStopPlaying:)] ){
            [self.delegate musicPlayerDidStopPlaying:self];
        }
        
        [self adjustPlayButtonState];

    }
}

-(void)stop {
    [self pause];
    self.currentPlaybackPosition = 0;
    [self updateSeekUI];
}

-(void)next {
    self.lastDirectionChangePositive = YES;
    [self changeTrack:self->currentTrack+1];
}

-(void)previous {
    self.lastDirectionChangePositive = NO;

    [self changeTrack:self->currentTrack-1];
}

/*
 * Called when the player finished playing the current track. 
 */
-(void)currentTrackFinished {
    // TODO: deactivate automatic actions via additional property
    // overhaul this method
    if ( self.repeatMode != MPMusicRepeatModeOne ){
        // [self next];  - reactivate me

    } else {
        self->currentPlaybackPosition = 0;
        [self updateSeekUI];
    }
}

- (void)playTrack:(NSUInteger)track atPosition:(CGFloat)position {

    [self changeTrack:track];
    self->currentPlaybackPosition = position;
    [self updateSeekUI];
    [self play];
}

-(void)updateUI {
    // Slider
    self.progressSlider.maximumValue = self.currentTrackLength;
    self.progressSlider.minimumValue = 0;
    
    [self updateUIForCurrentTrack];
    [self updateSeekUI];
    [self updateTrackDisplay];
    [self adjustDirectionalButtonStates];
    
    [self.playlistViewController updateUI];
}

/*
 * Changes the track to the new track given.
 */
-(void)changeTrack:(NSInteger)newTrack {
    BOOL shouldChange = YES;
    if ( [self.delegate respondsToSelector:@selector(musicPlayer:shouldChangeTrack:) ]){
        shouldChange = [self.delegate musicPlayer:self shouldChangeTrack:newTrack];
    }
    
    if([self.dataSource respondsToSelector:@selector(numberOfTracksInPlayer:)])
        self.numberOfTracks = [self.dataSource numberOfTracksInPlayer:self];
    else
        self.numberOfTracks = -1;

    if (newTrack < 0 || (self.numberOfTracksAvailable && newTrack >= self.numberOfTracks)){
        shouldChange = NO;
        // If we can't next, stop the playback.
        // TODO: notify delegate about the fact we felt off the playlist
        [self pause];
    }
    
    if ( shouldChange ){
        if ( [self.delegate respondsToSelector:@selector(musicPlayer:didChangeTrack:) ]){
            newTrack = [self.delegate musicPlayer:self didChangeTrack:newTrack];
        }
        if(newTrack == NSNotFound) {
            // TODO: notify delegate about the fact we felt off the playlist
            [self pause];
        } else {
            self->currentPlaybackPosition = 0;
            self.currentTrack = newTrack;
            
            self.currentTrackLength = [self.dataSource musicPlayer:self lengthForTrack:self.currentTrack];
            [self updateUI];
        }
    }
}

/**
 * Reloads data from the data source and updates the player.
 */
-(void)reloadData {
    if([self.dataSource respondsToSelector:@selector(numberOfTracksInPlayer:)])
        self.numberOfTracks = [self.dataSource numberOfTracksInPlayer:self];
    else
        self.numberOfTracks = -1;
    self.currentTrackLength = [self.dataSource musicPlayer:self lengthForTrack:self.currentTrack];
    
    [self updateUI];
}

/**
 * Tick method called each second when playing back.
 */
-(void)playbackTick:(id)unused {
    // Only tick forward if not scrobbling.
    if ( !self.scrobbling ){

        [self syncPlaybackPosition];

        if ( self->currentPlaybackPosition >= self.currentTrackLength ){
            [self currentTrackFinished];
        } else {
            [self updateSeekUI];
        }
    }
}

/**
 * Get the current playback position from the data source
 */
- (void)syncPlaybackPosition {
    self->currentPlaybackPosition = [dataSource musicPlayer:self currentPositionForTrack:self.currentTrack];
}

/*
 * Updates the remaining and elapsed time label, as well as the progress bar's value
 */
-(void)updateSeekUI {
    NSString* elapsed = [NSDateFormatter formattedDuration:(long)self.currentPlaybackPosition];
    NSString* remaining = [NSDateFormatter formattedDuration:(self.currentTrackLength-self.currentPlaybackPosition)*-1];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timeElapsedLabel.text =elapsed;
        self.timeRemainingLabel.text =remaining;
        self.progressSlider.value = self.currentPlaybackPosition;
    });
}

/*
 * Updates the Track Display ( Track 10 of 10 )
 */
-(void)updateTrackDisplay {
    if ( !self.scrobbling ){
        self.numberOfTracksLabel.text = [NSString stringWithFormat:@"Track %d of %d", self.currentTrack+1, self.numberOfTracks];
        self.numberOfTracksLabel.hidden = !self.numberOfTracksAvailable;
    }
}

-(void)updateRepeatButton {
    MPMusicRepeatMode currentMode = self->repeatMode;
    NSString* imageName = nil;
    switch (currentMode) {
        case MPMusicRepeatModeDefault:
            imageName = @"repeat_off.png";
            break;
        case MPMusicRepeatModeOne:
            imageName = @"repeat_on_1.png";
            break;
        case MPMusicRepeatModeAll:
            imageName = @"repeat_on.png";
            break;
    }
    if ( imageName )
        [self.repeatButton setImage:[UIImage imageNamed:[@"BeamMusicPlayerController.bundle/images/" stringByAppendingString:imageName]] forState:UIControlStateNormal];
}

#pragma mark Repeat mode

-(void)setRepeatMode:(int)newRepeatMode {
    self->repeatMode = newRepeatMode;
    [self updateRepeatButton];
}

#pragma mark Shuffling ( Every day I'm )

-(void)setShuffling:(BOOL)newShuffling {
    self->shuffling = newShuffling;
    
    NSString* imageName = ( self.shuffling ? @"shuffle_on.png" : @"shuffle_off.png");
    [self.shuffleButton setImage:[UIImage imageNamed:[@"BeamMusicPlayerController.bundle/images/" stringByAppendingString:imageName]] forState:UIControlStateNormal];
}

#pragma mark - User Interface ACtions

-(IBAction)playAction:(UIBarButtonItem*)sender {
    if ( self.playing ){
        [self pause];
    } else {
        [self play];
    }
}

-(IBAction)nextAction:(id)sender {
    [self next];
}

-(IBAction)previousAction:(id)sender {
    // TODO: handle skipToBeginning if playbacktime <= 3
    [self previous];
}

-(void)showScrobbleOverlay:(BOOL)show animated:(BOOL)animated {
    if(!self.isSmallPhone)
        return;

    [UIView animateWithDuration:animated?0.25:0 animations:^{
        self.scrobbleOverlay.alpha = show ? 1 : 0;
    }];
}


/**
 * Called when the cover art is tapped. Either shows or hides the scrobble-ui
 */
-(IBAction)coverArtTapped:(id)sender {
    [self showScrobbleOverlay:self.scrobbleOverlay.alpha == 0 animated:YES];
}

- (IBAction)playlistButtonTapped:(id)sender
{
    if (self.playlistVisible)
    {
        [self dismissPlaylist];
    }
    else
    {
        [self showPlaylist];
    }
}

#pragma mark - Playlist

- (BOOL)isPlaylistVisible
{
    return (self.playlistViewController.tableView.superview != nil);
}

- (void)showPlaylist
{
    if (self.playlistVisible)
        return;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        // TODO: playlistToggleButton is dimmed even if adjustsImageWhenDisabled is NO.
        self.playlistViewController.tableView.frame = self.artworkPlaylistContainer.bounds;
        
        // Flip to playlist
        [UIView transitionWithView:self.artworkPlaylistContainer
                          duration:self.flipDuration
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            self.albumArtImageView.hidden = YES;
                            self.scrobbleOverlay.hidden = YES;
                            self.scrobbleHighlightShadow.hidden = YES;
                            
                            [self.artworkPlaylistContainer addSubview:self.playlistViewController.tableView];
                        }
                        completion:^(BOOL finished){
                            // Scroll the current song visible
                            if (finished)
                            {
                                NSIndexPath *currentTrackIndexPath = [NSIndexPath indexPathForRow:self.currentTrack inSection:0];
                                NSArray *visibleIndexPaths = [self.playlistViewController.tableView indexPathsForVisibleRows];
                                if (![visibleIndexPaths containsObject:currentTrackIndexPath])
                                {
                                    [self.playlistViewController.tableView scrollToRowAtIndexPath:currentTrackIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                                }
                            }
                            
                            
                        }];
        
        self.playlistToggleButton.adjustsImageWhenDisabled = NO;
        
        // Change playlistButton to artworkButton
        [UIView transitionWithView:self.playlistToggleButton
                          duration:self.flipDuration
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            [self.playlistToggleButton setBackgroundImage:nil forState:UIControlStateNormal];
                            [self.playlistToggleButton setImage:self.albumArtImageView.image forState:UIControlStateNormal];
                        }
                        completion:^(BOOL finished){
                            self.playlistToggleButton.adjustsImageWhenDisabled = YES;
                        }];
        
        
    }
    else
    {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:self.playlistViewController];
        [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        self.playlistPopoverController = popoverController;
    }
}

- (void)dismissPlaylist
{
    if (!self.playlistVisible)
        return;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        // Flip to artwork
        [UIView transitionWithView:self.artworkPlaylistContainer
                          duration:self.flipDuration
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            [self.playlistViewController.tableView removeFromSuperview];
                            
                            self.albumArtImageView.hidden = NO;
                            self.scrobbleOverlay.hidden = NO;
                            self.scrobbleHighlightShadow.hidden = NO;
                        }
                        completion:nil];
        
        self.playlistToggleButton.adjustsImageWhenDisabled = NO;
        
        // Change artworkButton to playlistButton
        [UIView transitionWithView:self.playlistToggleButton
                          duration:self.flipDuration
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            
                            [self.playlistToggleButton setBackgroundImage:[[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/bar_button"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 4.0f, 0.0f, 4.0f)] forState:UIControlStateNormal];
                            [self.playlistToggleButton setImage:[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/playlist"] forState:UIControlStateNormal];
                        }
                        completion:^(BOOL finished){
                            self.playlistToggleButton.adjustsImageWhenDisabled = YES;
                        }];
    }
    else
    {
        [self.playlistPopoverController dismissPopoverAnimated:YES];
        self.playlistPopoverController = nil;
    }
}

#pragma mark - Playback button state management

/*
 * Adjusts the directional buttons to comply with the shouldHide-Button settings.
 */
-(void)adjustDirectionalButtonStates {
    if (self.numberOfTracksAvailable && self.currentTrack+1 == self.numberOfTracks && self.shouldHideNextTrackButtonAtBoundary ){
        self.fastForwardButton.enabled = NO;
    } else {
        self.fastForwardButton.enabled = YES;
    }
    
    if (self.numberOfTracksAvailable && self.currentTrack == 0 && self.shouldHidePreviousTrackButtonAtBoundary ){
        self.rewindButton.enabled = NO;
    } else {
        self.rewindButton.enabled = YES;
    }
}

/*
 * Adjusts the state of the play button to match the current state of the player
 */
-(void)adjustPlayButtonState {
    if ( !self.playing ){
        self.playButton.image = [UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/play.png"];
        [self.playButtonIPad setImage:[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/play.png"] forState:UIControlStateNormal];
    } else {
        self.playButton.image = [UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/pause.png"];
        [self.playButtonIPad setImage:[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/pause.png"] forState:UIControlStateNormal];
    }
}

-(void)setShouldHideNextTrackButtonAtBoundary:(BOOL)newShouldHideNextTrackButtonAtBoundary {
    self->shouldHideNextTrackButtonAtBoundary = newShouldHideNextTrackButtonAtBoundary;
    [self adjustDirectionalButtonStates];
}

-(void)setShouldHidePreviousTrackButtonAtBoundary:(BOOL)newShouldHidePreviousTrackButtonAtBoundary {
    self->shouldHidePreviousTrackButtonAtBoundary = newShouldHidePreviousTrackButtonAtBoundary;
    [self adjustDirectionalButtonStates];
}

#pragma mark - scrubbing slider

/**
 * Called whenever the scrubber changes it's speed. Used to update the display of the scrobble speed.
 */
-(void)updateUIForScrubbingSpeed:(CGFloat)speed {
    if ( speed == 1.0 ){
        self.numberOfTracksLabel.text = @"Hi-Speed Scrubbing";
    } else if ( speed == 0.5 ){
        self.numberOfTracksLabel.text = @"Half-Speed Scrubbing";
        
    }else if ( speed == 0.25 ){
        self.numberOfTracksLabel.text = @"Quarter-Speed Scrubbing";
        
    } else {
        self.numberOfTracksLabel.text = @"Fine Scrubbing";
    }
}

/**
 * Dims away the repeat and shuffle button
 */
- (IBAction)sliderDidBeginScrubbing:(id)sender {
    self.scrobbling = YES;
    [self setScrobbleUI:YES animated:YES];
}

/**
 * Shows the repeat and shuffle button and hides the scrobble help
 */
- (IBAction)sliderDidEndScrubbing:(id)sender {
    self.scrobbling = NO;
    [self setScrobbleUI:NO animated:YES];
    [self updateTrackDisplay];
}


/*
 * Updates the UI according to the current scrobble state given.
 */
-(void)setScrobbleUI:(BOOL)scrobbleState animated:(BOOL)animated{
    float alpha = ( scrobbleState ? 1 : 0 );
    [UIView animateWithDuration:animated?0.25:0 animations:^{
        self.repeatButton.alpha = 1-alpha;
        self.shuffleButton.alpha = 1-alpha;
        self.scrobbleHelpLabel.alpha = alpha;
        self.scrobbleHighlightShadow.alpha = alpha;
    }];
}

/*
 * Action triggered by the continous track progress slider
 */
-(IBAction)sliderValueChanged:(UISlider*)slider {
    self->currentPlaybackPosition = self.progressSlider.value;
    NSLog(@"slider.controlState: %@", slider.currentMinimumTrackImage);
    [self updateUIForScrubbingSpeed: self.progressSlider.scrubbingSpeed];
    
    if ( [self.delegate respondsToSelector:@selector(musicPlayer:didSeekToPosition:)]) {
        [self.delegate musicPlayer:self didSeekToPosition:self->currentPlaybackPosition];
    }
    
    [self updateSeekUI];
    
}

/*
 * Action triggered by the repeat mode button
 */
-(IBAction)repeatModeButtonAction:(id)sender{
    MPMusicRepeatMode currentMode = self.repeatMode;
    switch (currentMode) {
        case MPMusicRepeatModeDefault:
            self.repeatMode = MPMusicRepeatModeAll;
            break;
        case MPMusicRepeatModeOne:
            self.repeatMode = MPMusicRepeatModeDefault;
            break;
        case MPMusicRepeatModeAll:
            self.repeatMode = MPMusicRepeatModeOne ;
            break;
        default:
            self.repeatMode = MPMusicRepeatModeOne;
            break;
    }
    if ( [self.delegate respondsToSelector:@selector(musicPlayer:didChangeRepeatMode:)]) {
        [self.delegate musicPlayer:self didChangeRepeatMode:self.repeatMode];
    }
}

/*
 * Changes the shuffle mode and calls the delegate
 */
-(IBAction)shuffleButtonAction:(id)sender {
    self.shuffling = !self.shuffling;
    if ( [self.delegate respondsToSelector:@selector(musicPlayer:didChangeShuffleState:)]) {
        [self.delegate musicPlayer:self didChangeShuffleState:self.shuffling];
    }
}

- (IBAction)backButtonAction:(id)sender {
    if (self.backBlock)
        self.backBlock();
}

/*
 * Just forward the action message to the delegate
 */
-(IBAction)actionButtonAction:(id)sender {
    if(self.actionBlock)
        self.actionBlock();
}

#pragma mark Cover Art resolution handling

-(CGSize)preferredSizeForCoverArt {
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize points = self.albumArtImageView.frame.size;
    return  CGSizeMake(points.width * scale, points.height * scale);
}

-(CGFloat)displayScale {
    return [UIScreen mainScreen].scale;
}

/*
 * Manage the timer interval
 */
-(void)setTimerInterval:(float)timerInterval {
    BOOL playbackTimerExists = !!self.playbackTickTimer;

    if (playbackTimerExists) {
        [self stopPlaybackTickTimer];
    }

    _timerInterval = timerInterval;

    if (playbackTimerExists) {
        [self startPlaybackTickTimer];
    }
}

/*
 * Start the scrubbing slider update timer
 */
- (void)startPlaybackTickTimer {
    self.playbackTickTimer = [NSTimer scheduledTimerWithTimeInterval:self.timerInterval target:self selector:@selector(playbackTick:) userInfo:nil repeats:YES];
}

/*
 * Stop the scrubbing slider update timer
 */
- (void)stopPlaybackTickTimer {
    [self.playbackTickTimer invalidate];
    self.playbackTickTimer = nil;
}

@end
