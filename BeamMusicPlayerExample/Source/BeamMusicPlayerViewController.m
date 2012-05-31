//
//  BeamMusicPlayerViewController.m
//  Part of MusicPlayerViewController
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// 
// Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
// 
// Neither the name of the project's author nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
// TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "BeamMusicPlayerViewController.h"
#import "UIImageView+Reflection.h"

@interface BeamMusicPlayerViewController()

@property (nonatomic,weak) IBOutlet UISlider* volumeSlider; // Volume Slider
@property (nonatomic,weak) IBOutlet UISlider* progressSlider; // Progress Slider buried in the Progress View

@property (nonatomic,weak) IBOutlet UILabel* trackTitleLabel; // The Title Label
@property (nonatomic,weak) IBOutlet UILabel* albumTitleLabel; // Album Label
@property (nonatomic,weak) IBOutlet UILabel* artistNameLabel; // Artist Name Label

@property (nonatomic,weak) IBOutlet UIToolbar* controlsToolbar; // Encapsulates the Play, Forward, Rewind buttons


@property (nonatomic,weak) IBOutlet UIBarButtonItem* rewindButton; // Previous Track
@property (nonatomic,weak) IBOutlet UIBarButtonItem* fastForwardButton; // Next Track
@property (nonatomic,weak) IBOutlet UIBarButtonItem* playButton; // Play

@property (nonatomic,weak) IBOutlet UIImageView* albumArtImageView; // Album Art Image View
@property (nonatomic,weak) IBOutlet UIImageView* albumArtReflection; // It's reflection

@property (nonatomic,strong) NSTimer* playbackTickTimer; // Ticks each seconds when playing.

@property (nonatomic,strong) NSDateFormatter* durationFormatter; // Formatter used for the elapsed / remaining time.
@property (nonatomic,strong) UITapGestureRecognizer* coverArtGestureRecognizer; // Tap Recognizer used to dim in / out the scrobble overlay.

@property (nonatomic,weak) IBOutlet UIView* scrobbleOverlay; // Overlay that serves as a container for all components visible only in scrobble-mode
@property (nonatomic,weak) IBOutlet UILabel* timeElapsedLabel; // Elapsed Time Label
@property (nonatomic,weak) IBOutlet UILabel* timeRemainingLabel; // Remaining Time Label
@property (nonatomic,weak) IBOutlet UIButton* shuffleButton; // Shuffle Button
@property (nonatomic,weak) IBOutlet UIButton* repeatButton; // Repeat button 

@end

@implementation BeamMusicPlayerViewController

@synthesize trackTitleLabel;
@synthesize albumTitleLabel;
@synthesize artistNameLabel;
@synthesize rewindButton;
@synthesize fastForwardButton;
@synthesize playButton;
@synthesize volumeSlider;
@synthesize progressSlider;
@synthesize controlsToolbar;
@synthesize albumArtImageView;
@synthesize albumArtReflection;
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
@synthesize durationFormatter;
@synthesize coverArtGestureRecognizer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Scrobble Ovelray alpha should be 0, initialize the gesture recognizer
    self.scrobbleOverlay.alpha = 0;
    self.coverArtGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverArtTapped:)];
    [self.albumArtImageView addGestureRecognizer:self.coverArtGestureRecognizer];
    
    // Knobs for the sliders
    
    UIImage* sliderBlueTrack = [[UIImage imageNamed:@"VolumeBlueTrack.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0];
    UIImage* slideWhiteTrack = [[UIImage imageNamed:@"VolumeWhiteTrack.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0];
    UIImage* knob = [UIImage imageNamed:@"VolumeKnob"];
    knob = [UIImage imageWithCGImage:knob.CGImage scale:2.0 orientation:UIImageOrientationUp];
    [[UISlider appearanceWhenContainedIn:[self class], nil] setThumbImage:knob forState:UIControlStateNormal];
    
   // [[UISlider appearanceWhenContainedIn:[self class], nil] setMinimumValueImage:[UIImage imageNamed:@"VolumeBlueMusicCap.png"]];
   // [[UISlider appearanceWhenContainedIn:[self class], nil] setMaximumValueImage:[UIImage imageNamed:@"VolumeWhiteMusicCap.png"]];
    [[UISlider appearance] setMinimumTrackImage:sliderBlueTrack forState:UIControlStateNormal];
    [[UISlider appearance] setMaximumTrackImage:slideWhiteTrack forState:UIControlStateNormal];

    // The Original Toolbar is 48px high in the iPod/Music app
    
    CGRect toolbarRect = self.controlsToolbar.frame;
    toolbarRect.size.height = 48;
    self.controlsToolbar.frame = toolbarRect;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.coverArtGestureRecognizer = nil;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void)awakeFromNib {
}

#pragma mark - Playback Management

/**
 * Updates the UI to match the current track by requesting the information from the datasource.
 */
-(void)updateUIForCurrentTrack {
    
    self.artistNameLabel.text = [self.dataSource musicPlayer:self artistForTrack:self.currentTrack];
    self.trackTitleLabel.text = [self.dataSource musicPlayer:self titleForTrack:self.currentTrack];
    self.albumTitleLabel.text = [self.dataSource musicPlayer:self albumForTrack:self.currentTrack];
    
    // We only request the coverart if the delegate responds to it.
    if ( self.dataSource && [self.dataSource respondsToSelector:@selector(artworkForTrack:preferredSize:player:)]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // Pixels would be nice 
            UIImage* albumArt =  [self.dataSource musicPlayer:self artworkForTrack:self.currentTrack preferredSize:self.albumArtImageView.frame.size];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.albumArtImageView.image = albumArt;
                self.albumArtReflection.image = [self.albumArtImageView reflectedImageWithHeight:self.albumArtReflection.frame.size.height];
            });
            
        });
    } else {
        // Otherwise, we'll stick with the placeholder.
        self.albumArtImageView.image = [UIImage imageNamed:@"noartplaceholder.png"];
        self.albumArtReflection.image = [self.albumArtImageView reflectedImageWithHeight:self.albumArtReflection.frame.size.height];
    }
}

/**
 * Prepares the player for track 0.
 */
-(void)preparePlayer {
    self.currentTrack = 0;
    [self updateUIForCurrentTrack];
}


-(void)play {
    if ( !self.playing ){
        self->playing = YES;
        self->currentPlaybackPosition = 0;
        
        [self updateUIForCurrentTrack];
        self.playbackTickTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playbackTick:) userInfo:nil repeats:YES];
        
        if ( self.delegate && [self.delegate respondsToSelector:@selector(playerDidStartPlaying:)] ){
            [self.delegate musicPlayerDidStartPlaying:self];
        }
        
    }
}

-(void)pause {
    if ( self.playing ){
        self->playing = NO;
        [self.playbackTickTimer invalidate];
        self.playbackTickTimer = nil;
        
        if ( self.delegate && [self.delegate respondsToSelector:@selector(playerDidStopPlaying:)] ){
            [self.delegate musicPlayerDidStartPlaying:self];
        }
    }
}

/**
 * Reloads data from the data source and updates the player. If the player is currently playing, the playback is stopped.
 */
-(void)reloadData {
    
}

/**
 * Tick method called each second when playing back.
 */
-(void)playbackTick:(id)unused {
    
}

-(void)updateSeekUI {
    
}

#pragma mark - User Interface ACtions

-(IBAction)playAction:(UIBarButtonItem*)sender {
    if ( self.playing ){
        [self pause];
        self.playButton.image = [UIImage imageNamed:@"play.png"];
    } else {
        [self play];
        self.playButton.image = [UIImage imageNamed:@"pause.png"];
    }
}

/**
 * Called when the cover art is tapped. Either shows or hides the scrobble-ui
 */
-(IBAction)coverArtTapped:(id)sender {
    if ( self.scrobbleOverlay.alpha == 0 ){
        [self.scrobbleOverlay setAlpha:1];
    } else {
        [self.scrobbleOverlay setAlpha:0];
    }
}

-(void)adjustButtonStates {
    
}

@end
