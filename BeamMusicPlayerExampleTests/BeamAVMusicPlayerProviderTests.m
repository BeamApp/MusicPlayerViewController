//
//  BeamAVMusicPlayerProviderTests.m
//  BeamMusicPlayerExample
//
//  Created by Heiko Behrens on 23.05.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BeamAVMusicPlayerProvider.h"

@interface BeamAVMusicPlayerProviderTests : SenTestCase {
    NSDictionary *description;
}

@end


@implementation BeamAVMusicPlayerProviderTests

- (void)setUp {
    [super setUp];
    description = @{
            @"artworkUrl10" : @"10",
            @"artworkUrl100" : @"100",
            @"artworkUrl200" : @"200",
            @"artworkUrl300" : @"300"
    };
}


-(void)testArtworkUrl_noDesciption {
    STAssertNil([BeamAVMusicPlayerProvider artworkUrlValueForSize:100 inDescription:@{}], @"no url on empty description");
}

-(void)testArtWorkUrl_perfectSize {
    NSURL *actual = [BeamAVMusicPlayerProvider artworkUrlValueForSize:100 inDescription:description];
    STAssertEqualObjects(@"100", actual, @"foo");
}

-(void)testArtWorkUrl_slightlyTooSmall {
    NSURL *actual = [BeamAVMusicPlayerProvider artworkUrlValueForSize:110 inDescription:description];
    STAssertEqualObjects(@"100", actual, @"foo");
}

-(void)testArtWorkUrl_wayTooSmall {
    NSURL *actual = [BeamAVMusicPlayerProvider artworkUrlValueForSize:80 inDescription:description];
    STAssertEqualObjects(@"100", actual, @"foo");
}

-(void)testArtWorkUrl_onlyTooSmall {
    NSURL *actual = [BeamAVMusicPlayerProvider artworkUrlValueForSize:1000 inDescription:description];
    STAssertEqualObjects(@"300", actual, @"foo");
}

-(void)testArtWorkUrl_onlyLarger {
    NSURL *actual = [BeamAVMusicPlayerProvider artworkUrlValueForSize:2 inDescription:description];
    STAssertEqualObjects(@"10", actual, @"foo");
}


@end
