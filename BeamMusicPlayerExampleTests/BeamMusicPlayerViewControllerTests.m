//
//  BeamMusicPlayerViewControllerTests.m
//  BeamMusicPlayerExample
//
//  Created by Heiko Behrens on 01.06.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "BeamMusicPlayerViewControllerTests.h"
#import <OCMock.h>

@implementation BeamMusicPlayerViewControllerTests
@synthesize viewController;

- (void)setUp
{
    [super setUp];
    self.viewController = [BeamMusicPlayerViewController new];
}

- (void)tearDown
{
    self.viewController = nil;
    [super tearDown];
}



- (void)testMockedDataSourceWorksInGeneral
{
    id ds = [OCMockObject mockForProtocol:@protocol(BeamMusicPlayerDataSource)];
    
    float expected = 123;
    [[[ds expect] andReturnValue:OCMOCK_VALUE(expected)] musicPlayer:viewController lengthForTrack:0];
    

    float actual = [ds musicPlayer:viewController lengthForTrack:0];

    STAssertEquals(expected, actual, @"mocked length");
    [ds verify];
}


@end
