//
//  BeamAppDelegate.m
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

#import "BeamAppDelegate.h"

#import "BeamMusicPlayerViewController.h"

@implementation BeamAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[BeamMusicPlayerViewController alloc] initWithNibName:@"BeamMusicPlayerViewController_iPhone" bundle:nil];
        

        
        
        
    } else {
        self.viewController = [[BeamMusicPlayerViewController alloc] initWithNibName:@"BeamMusicPlayerViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    self.viewController.dataSource = self;
    self.viewController.delegate = self;
    
    [self.viewController preparePlayer];
    
    return YES;
}

# pragma mark - BeamMusicPlayer Delegate

-(NSString*)musicPlayer:(BeamMusicPlayerViewController*)player titleForTrack:(NSUInteger)trackNumber {
    return @"Some Title";
}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController*)player albumForTrack:(NSUInteger)trackNumber {
    return @"Album"
    ;}

-(NSString*)musicPlayer:(BeamMusicPlayerViewController*)player  artistForTrack:(NSUInteger)trackNumber{
    NSArray* artists = [NSArray arrayWithObjects:@"Michael Jackson", @"Metallica",@"Metric", @"Guns'n'Roses", nil];
    return [artists objectAtIndex:trackNumber%artists.count];
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber receivingBlock:(BeamMusicPlayerReceivingBlock)receivingBlock {
    
    NSArray* urls = [NSArray arrayWithObjects:@"http://a3.mzstatic.com/us/r1000/045/Features/7f/50/ee/dj.zygromnm.600x600-75.jpg",
                     @"http://1.bp.blogspot.com/-On89IVASeEY/T6qmvCPoplI/AAAAAAAADdY/EMfLc0d0Zrc/s1600/Metallica-The_Black_Album-Front.jpg", @"http://bighassle.com/wp-content/files_mf/1323966289metric_cover_hires.jpg", @"http://4.bp.blogspot.com/_Sowy7lo69Wo/TIb42GfHtAI/AAAAAAAAADM/x8nqGY3IpE8/s1600/Appetite%2Bfor%2BDestruction%2BCover.JPG", nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString* urlString = [urls objectAtIndex:trackNumber%urls.count];
        NSData* urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        UIImage* image = [UIImage imageWithData:urlData];
        receivingBlock(image,nil);
    });
}



-(CGFloat)musicPlayer:(BeamMusicPlayerViewController*)player lengthForTrack:(NSUInteger)trackNumber{
    return 124;
}

@end
