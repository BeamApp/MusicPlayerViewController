//
//  BeamMusicPlayerViewControllerTests.m
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Heiko Behrens on 01.06.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import "BeamMusicPlayerViewControllerTests.h"
#import <OCMock.h>

@implementation BeamMusicPlayerViewControllerTests
@synthesize viewController;

- (void)setUp
{
    [super setUp];
    self.viewController = [[BeamMusicPlayerViewController alloc] initWithNibName:nil bundle:nil];
    // force view controler to load from nib
    [self.viewController performSelector:@selector(view)];
}

- (void)tearDown
{
    self.viewController = nil;
    [super tearDown];
}

- (void)testViewControllerLoadedFromNib {
    STAssertNotNil([viewController performSelector:@selector(navigationItem)], @"outlets loaded");
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


- (void)testActionButtonVisibility {
    STAssertNil(viewController.navigationItem.rightBarButtonItem, @"action button invisible");
    viewController.actionBlock = ^{};
    STAssertNotNil(viewController.navigationItem.rightBarButtonItem, @"action button visible");
    viewController.actionBlock = nil;
    STAssertNil(viewController.navigationItem.rightBarButtonItem, @"action button invisible, again");
}

- (void)testBackButtonInvisibleIfNoDelegateMethod {
    STAssertNil(viewController.navigationItem.leftBarButtonItem, @"back button invisible");
    viewController.backBlock = ^{};
    STAssertNotNil(viewController.navigationItem.leftBarButtonItem, @"back button visible");
    viewController.backBlock = nil;
    STAssertNil(viewController.navigationItem.leftBarButtonItem, @"back button invisible, again");
}


@end
