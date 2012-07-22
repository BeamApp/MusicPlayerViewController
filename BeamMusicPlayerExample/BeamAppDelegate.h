//
//  BeamAppDelegate.h
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BeamMusicPlayerViewController.h"
#import "BeamMPMusicPlayerProvider.h"

@class BeamMusicPlayerViewController;

@interface BeamAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BeamMusicPlayerViewController *viewController;
@property (strong, nonatomic) id<BeamMusicPlayerDataSource,BeamMusicPlayerDelegate> exampleProvider;

@end
