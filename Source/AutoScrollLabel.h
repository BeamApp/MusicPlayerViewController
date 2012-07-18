//
//  AutoScrollLabel.h
//  AutoScrollLabel
//
//  Created by Brian Stormont on 10/21/09.
//  Copyright 2009 Stormy Productions. All rights reserved.
//
//  Permission is granted to use this code free of charge for any project.
//

#import <UIKit/UIKit.h>

#define NUM_LABELS 2

@class CALayer;

enum AutoScrollDirection {
	AUTOSCROLL_SCROLL_RIGHT,
	AUTOSCROLL_SCROLL_LEFT,
};

@interface AutoScrollLabel : UIView <UIScrollViewDelegate>{
	UILabel *label[NUM_LABELS];
	enum AutoScrollDirection scrollDirection;
	float scrollSpeed;
	NSTimeInterval pauseInterval;
	int bufferSpaceBetweenLabels;
	bool isScrolling;
}
@property(nonatomic) enum AutoScrollDirection scrollDirection;
@property(nonatomic) float scrollSpeed;
@property(nonatomic) NSTimeInterval pauseInterval;
@property(nonatomic) int bufferSpaceBetweenLabels;
// normal UILabel properties
@property(nonatomic,retain) UIColor *textColor;
@property (nonatomic,retain) UIScrollView* scrollView;
@property(nonatomic, retain) UIFont *font;
@property (nonatomic,retain) UIImageView* leftFade;
@property (nonatomic,retain) UIImageView* rightFade;
@property (nonatomic,retain) CALayer* maskLayer;
@property (nonatomic,retain) CALayer* rightShadowMask;
@property (nonatomic,retain) CALayer* leftShadowMask;


- (void) readjustLabels;
- (void) setText: (NSString *) text;
- (NSString *) text;
- (void) scroll;
- (void) setShadowOffset:(CGSize)offset;
- (void) setShadowColor:(UIColor *)color;

@end
