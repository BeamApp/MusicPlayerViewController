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
    self.viewController = [[BeamMusicPlayerViewController alloc] initWithNibName:@"BeamMusicPlayerViewController_iPhone" bundle:nil];
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


- (void)testActionButtonInvisibleIfNoDelegateMethod {
    id delegateWithoutAnyMethods = [NSObject new];
    viewController.delegate = delegateWithoutAnyMethods;
    STAssertFalse([viewController.delegate respondsToSelector:@selector(musicPlayerActionRequested:)], @"mock does not provide method");
    STAssertNil(viewController.navigationItem.rightBarButtonItem, @"action button invisible");
    
    id delegateWithAllMethods = [OCMockObject mockForProtocol:@protocol(BeamMusicPlayerDelegate)];
    viewController.delegate = delegateWithAllMethods;
    STAssertTrue([viewController.delegate respondsToSelector:@selector(musicPlayerActionRequested:)], @"mock does provide method");
    STAssertNotNil(viewController.navigationItem.rightBarButtonItem, @"action button visible");
}

- (void)testBackButtonInvisibleIfNoDelegateMethod {
    id delegateWithoutAnyMethods = [NSObject new];
    viewController.delegate = delegateWithoutAnyMethods;
    STAssertFalse([viewController.delegate respondsToSelector:@selector(musicPlayerBackRequested:)], @"mock does not provide method");
    STAssertNil(viewController.navigationItem.rightBarButtonItem, @"Back button invisible");
    
    id delegateWithAllMethods = [OCMockObject mockForProtocol:@protocol(BeamMusicPlayerDelegate)];
    viewController.delegate = delegateWithAllMethods;
    STAssertTrue([viewController.delegate respondsToSelector:@selector(musicPlayerBackRequested:)], @"mock does provide method");
    STAssertNotNil(viewController.navigationItem.rightBarButtonItem, @"Back button visible");
}


@end
