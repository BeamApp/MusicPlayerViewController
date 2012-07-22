//
//  NSDateFormatter+Duration.h
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 31.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Duration)
+(NSString*)formattedDuration:(long)duration;
@end
