//
//  NSDateFormatter+Duration.m
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 31.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import "NSDateFormatter+Duration.h"

@implementation NSDateFormatter (Duration)

+(NSString*)formattedDuration:(long)duration {
    NSString* prefix = @"";
    if ( duration < 0  )
        prefix = @"-";

    duration = abs(duration);
    
    NSMutableArray* comps = [NSMutableArray new];
    
    while ( duration > 59 ){
        [comps addObject:[NSString stringWithFormat:@"%ld", duration/60]];
        duration = duration % 60;
    }
    
    // Minute indicator needs to be there at all times.
    if ( comps.count == 0 )
        [comps addObject:@"0"];
    
    [comps addObject:[NSString stringWithFormat:@"%02ld", duration]];

    return [prefix stringByAppendingString:[comps componentsJoinedByString:@":"]];
        
}

@end
