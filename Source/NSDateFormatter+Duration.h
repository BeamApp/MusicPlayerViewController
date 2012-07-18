//
//  NSDateFormatter+Duration.h
//  BeamMusicPlayerExample
//
//  Created by Moritz Haarmann on 31.05.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Duration)
+(NSString*)formattedDuration:(long)duration;
@end
