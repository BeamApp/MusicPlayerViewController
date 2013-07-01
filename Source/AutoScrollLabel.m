//
//  AutoScrollLabel.m
//  AutoScrollLabel
//
//  Created by Brian Stormont on 10/21/09.
//  Copyright 2009 Stormy Productions. 
//
//  Permission is granted to use this code free of charge for any project.
//

#import "AutoScrollLabel.h"
#import <QuartzCore/QuartzCore.h>

#define LABEL_BUFFER_SPACE 20   // pixel buffer space between scrolling label
#define DEFAULT_PIXELS_PER_SECOND 30
#define DEFAULT_PAUSE_TIME 2.0f

@implementation AutoScrollLabel
@synthesize pauseInterval;
@synthesize bufferSpaceBetweenLabels;
@synthesize leftFade;
@synthesize rightFade;
@synthesize scrollView;
@synthesize maskLayer;
@synthesize rightShadowMask;
@synthesize leftShadowMask;

- (void) commonInit
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:self.scrollView];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    self.backgroundColor = [UIColor clearColor];
	for (int i=0; i< NUM_LABELS; ++i){
		label[i] = [[UILabel alloc] init];
		label[i].textColor = [UIColor whiteColor];
		label[i].backgroundColor = [UIColor clearColor];
		[self.scrollView addSubview:label[i]];
	}
	
	scrollDirection = AUTOSCROLL_SCROLL_LEFT;
	scrollSpeed = DEFAULT_PIXELS_PER_SECOND;
	pauseInterval = DEFAULT_PAUSE_TIME;
	bufferSpaceBetweenLabels = LABEL_BUFFER_SPACE;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.userInteractionEnabled = NO;
    


}

-(id) init
{
	if (self = [super init]){
        // Initialization code
		[self commonInit];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // Initialization code
		[self commonInit];
    }
    return self;
	
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		[self commonInit];
    }
    return self;
}

-(void)awakeFromNib {
    UIImage* fadeImage = [UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/fade_overlay.png"];

    // Set the frame
    
    CGRect leftShadowRect = CGRectMake(0, 0, fadeImage.size.width, 200);
    CGRect rightFadeRect = CGRectMake(self.frame.size.width-fadeImage.size.width, 0, fadeImage.size.width, 200);
    
    CALayer *maskingLayer = [CALayer layer];
    maskingLayer.frame = self.bounds;
    
    CALayer* rightShadowLayer = [CALayer layer];
    rightShadowLayer.contents = (id)fadeImage.CGImage;
    rightShadowLayer.frame = rightFadeRect;
    
    self.rightShadowMask = rightShadowLayer;
    
    [maskingLayer addSublayer:self.rightShadowMask];
    self.rightShadowMask.backgroundColor = [UIColor whiteColor].CGColor;
    
    CALayer* leftFadeLayer = [CALayer layer];
    leftFadeLayer.contents = (id)fadeImage.CGImage;
    leftFadeLayer.frame = leftShadowRect;
    leftFadeLayer.transform = CATransform3DMakeScale(-1, 1, 1);

    self.leftShadowMask = leftFadeLayer;
    [maskingLayer addSublayer:leftFadeLayer];
    //self.leftShadowMask.backgroundColor = [UIColor whiteColor].CGColor;
    CALayer* centerPiece = [CALayer layer];
    centerPiece.frame = CGRectMake(fadeImage.size.width,0,self.frame.size.width-fadeImage.size.width*2, self.frame.size.height);
    centerPiece.backgroundColor = [UIColor whiteColor].CGColor;
    
    [maskingLayer addSublayer:centerPiece];

    self.maskLayer = maskingLayer;
    
    self.layer.mask = maskingLayer;
    
    [self showLeftShadow:[NSNumber numberWithBool:NO]];

}


#if 0
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[NSThread sleepForTimeInterval:pauseInterval];

	isScrolling = NO;
	
	if ([finished intValue] == 1 && label[0].frame.size.width > self.frame.size.width){
		[self scroll];
	}	
}
#else
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	isScrolling = NO;


	if ([finished intValue] == 1 && label[0].frame.size.width > self.frame.size.width){

		[NSTimer scheduledTimerWithTimeInterval:pauseInterval target:self selector:@selector(scroll) userInfo:nil repeats:NO];
	}
} 
#endif


- (void) scroll
{
    //nothing to scroll
    if (label[0].frame.size.width <= self.scrollView.frame.size.width){
        return;
    }
    
    
	// Prevent multiple calls
	if (isScrolling){
//		return;
	}
	isScrolling = YES;
	
	if (scrollDirection == AUTOSCROLL_SCROLL_LEFT){
		self.scrollView.contentOffset = CGPointMake(0,0);
	}else{
		self.scrollView.contentOffset = CGPointMake(label[0].frame.size.width+LABEL_BUFFER_SPACE,0);
	}

    
    CGFloat duration= label[0].frame.size.width/(float)scrollSpeed;

	[UIView beginAnimations:@"scroll" context:nil];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:duration];

	if (scrollDirection == AUTOSCROLL_SCROLL_LEFT){
		self.scrollView.contentOffset = CGPointMake(label[0].frame.size.width+LABEL_BUFFER_SPACE,0);
	}else{
		self.scrollView.contentOffset = CGPointMake(0,0);
	}
    
    [self showLeftShadow:[NSNumber numberWithBool:YES]];
    
    [self performSelector:@selector(showLeftShadow:) withObject:[NSNumber numberWithBool:NO] afterDelay:duration-0.3];
    

	[UIView commitAnimations];


}

-(void)showLeftShadow:(NSNumber*)show {
    BOOL shouldShow = show.boolValue;
    UIColor* color = shouldShow? [UIColor clearColor] : [UIColor whiteColor];
    self.leftShadowMask.backgroundColor = color.CGColor;
    
    
}

- (void) readjustLabels
{
	float offset = 0.0f;
	
	for (int i = 0; i < NUM_LABELS; ++i){
		[label[i] sizeToFit];
		
		// Recenter label vertically within the scroll view
		CGPoint center;
		center = label[i].center;
		center.y = self.center.y - self.frame.origin.y;
		label[i].center = center;
		
		CGRect frame;
		frame = label[i].frame;
		frame.origin.x = offset;
		label[i].frame = frame;
		
		offset += label[i].frame.size.width + LABEL_BUFFER_SPACE;
	}
	
	CGSize size;
	size.width = label[0].frame.size.width + self.scrollView.frame.size.width + LABEL_BUFFER_SPACE;
	size.height = self.frame.size.height;
	self.scrollView.contentSize = size;

	[self.scrollView setContentOffset:CGPointMake(0,0) animated:NO];
	
	// If the label is bigger than the space allocated, then it should scroll
	if (label[0].frame.size.width > self.scrollView.frame.size.width){
		for (int i = 1; i < NUM_LABELS; ++i){
			label[i].hidden = NO;
		}
        
        self.rightShadowMask.backgroundColor = [UIColor clearColor].CGColor;
        
        // Start Scroll only after the delay
		[NSTimer scheduledTimerWithTimeInterval:pauseInterval target:self selector:@selector(scroll) userInfo:nil repeats:NO];
	}else{
		// Hide the other labels out of view
		for (int i = 1; i < NUM_LABELS; ++i){
			label[i].hidden = YES;
		}
		// Center this label
		CGPoint center;
		center = label[0].center;
		center.x = self.center.x - self.scrollView.frame.origin.x;
		label[0].center = center;
	}

}


- (void) setText: (NSString *) text
{
	// If the text is identical, don't reset it, otherwise it causes scrolling jitter
	if ([text isEqualToString:label[0].text]){
		// But if it isn't scrolling, make it scroll
		// If the label is bigger than the space allocated, then it should scroll
		if (label[0].frame.size.width > self.frame.size.width){
			[self scroll];
		}
		return;
	}
	
	for (int i=0; i<NUM_LABELS; ++i){
		label[i].text = text;
	}
	[self readjustLabels];
}	
- (NSString *) text
{
	return label[0].text;
}

- (void) setTextColor:(UIColor *)color
{
	for (int i=0; i<NUM_LABELS; ++i){
		label[i].textColor = color;
	}
}

- (UIColor *) textColor
{
	return label[0].textColor;
}


- (void) setFont:(UIFont *)font
{
	for (int i=0; i<NUM_LABELS; ++i){
		label[i].font = font;
	}
	[self readjustLabels];
}

- (UIFont *) font
{
	return label[0].font;
}

- (void) setShadowColor:(UIColor *)color
{
	for (int i=0; i<NUM_LABELS; ++i){
		label[i].shadowColor = color;
	}
	//[self readjustLabels];
}

- (UIColor *) shadowColor
{
	return label[0].shadowColor;
}

- (void) setShadowOffset:(CGSize)offset
{
	for (int i=0; i<NUM_LABELS; ++i){
		label[i].shadowOffset = offset;
	}
	//[self readjustLabels];
}

- (CGSize) shadowOffset
{
	return label[0].shadowOffset;
}

- (void) setScrollSpeed: (float)speed
{
	scrollSpeed = speed;
	[self readjustLabels];
}

- (float) scrollSpeed
{
	return scrollSpeed;
}

- (void) setScrollDirection: (enum AutoScrollDirection)direction
{
	scrollDirection = direction;
	[self readjustLabels];
}

- (enum AutoScrollDirection) scrollDirection
{
	return scrollDirection;
}

-(void)layoutSubviews {
    [self readjustLabels];
}

- (void)dealloc {
	for (int i=0; i<NUM_LABELS; ++i){
		label[i] = nil;
	}
}


@end
