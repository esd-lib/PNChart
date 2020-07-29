//
//  PNCircleChart.m
//  PNChartDemo
//
//  Created by kevinzhow on 13-11-30.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import "PNCircleChart.h"

@interface PNCircleChart ()
@end

@implementation PNCircleChart

- (id)initWithFrame:(CGRect)frame total:(NSNumber *)total current:(NSNumber *)current clockwise:(BOOL)clockwise shadow:(BOOL)hasBackgroundShadow {
	
	return [self initWithFrame:frame
						 total:total
					   current:current
					 clockwise:clockwise
						shadow:shadow
				   shadowColor:[UIColor clearColor]
		  displayCountingLabel:YES
			 overrideLineWidth:[NSNumber numberWithFloat:frame.size.width/5.7f]];
	
}

- (id)initWithFrame:(CGRect)frame total:(NSNumber *)total current:(NSNumber *)current clockwise:(BOOL)clockwise shadow:(BOOL)hasBackgroundShadow shadowColor:(UIColor *)backgroundShadowColor {
	
	return [self initWithFrame:frame
						 total:total
					   current:current
					 clockwise:clockwise
						shadow:shadow
				   shadowColor:backgroundShadowColor
		  displayCountingLabel:YES
			 overrideLineWidth:[NSNumber numberWithFloat:frame.size.width/5.7f]];
	
}

- (id)initWithFrame:(CGRect)frame total:(NSNumber *)total current:(NSNumber *)current clockwise:(BOOL)clockwise shadow:(BOOL)hasBackgroundShadow shadowColor:(UIColor *)backgroundShadowColor displayCountingLabel:(BOOL)displayCountingLabel {
	
	return [self initWithFrame:frame
						 total:total
					   current:current
					 clockwise:clockwise
						shadow:shadow
				   shadowColor:PNGreen
		  displayCountingLabel:displayCountingLabel
			 overrideLineWidth:[NSNumber numberWithFloat:frame.size.width/5.7f]];
	
}

- (id)initWithFrame:(CGRect)frame
			  total:(NSNumber *)total
			current:(NSNumber *)current
		  clockwise:(BOOL)clockwise
			 shadow:(BOOL)hasBackgroundShadow
		shadowColor:(UIColor *)backgroundShadowColor
displayCountingLabel:(BOOL)displayCountingLabel
  overrideLineWidth:(NSNumber *)overrideLineWidth
{
	self = [super initWithFrame:frame];
	
	if (self) {
		_total = total;
		_current = current;
		_strokeColor = PNFreshGreen;
		_duration = 1.0;
		_chartType = PNChartFormatTypePercent;
		
		_displayCountingLabel = displayCountingLabel;
		
		CGFloat startAngle =  135.0f;  //Angle
		CGFloat endAngle = 45.0f;
		
		_lineWidth = overrideLineWidth;
		
		UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:
									CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f)
																  radius:(self.frame.size.height * 0.5) - ([_lineWidth floatValue]/2.0f)
															  startAngle:DEGREES_TO_RADIANS(startAngle)
																endAngle:DEGREES_TO_RADIANS(endAngle)
															   clockwise:clockwise];
		
		_circle               = [CAShapeLayer layer];
		_circle.path          = circlePath.CGPath;
		_circle.lineCap       = kCALineCapButt;
		_circle.fillColor     = [UIColor clearColor].CGColor;
		_circle.lineWidth     = [_lineWidth floatValue];
		_circle.zPosition     = 1;
		
		_circleBackground             = [CAShapeLayer layer];
		_circleBackground.path        = circlePath.CGPath;
		_circleBackground.lineCap     = kCALineCapButt;
		_circleBackground.fillColor   = [UIColor clearColor].CGColor;
		_circleBackground.lineWidth   = [_lineWidth floatValue];
		_circleBackground.strokeColor = (hasBackgroundShadow ? backgroundShadowColor.CGColor : [UIColor clearColor].CGColor);
		_circleBackground.strokeEnd   = 1.0;
		_circleBackground.zPosition   = -1;
		
		[self.layer addSublayer:_circle];
		[self.layer addSublayer:_circleBackground];
		
		//*************************************************arrow
		_arrow = [CAShapeLayer layer];
		_arrow.fillColor = [UIColor blackColor].CGColor;
		_arrow.zPosition     = 2;
		CGRect bounds = self.bounds;
		CGFloat radius = [_lineWidth floatValue]/3;
		CGFloat a = radius*sqrt((CGFloat)3.0)/2;
		CGFloat b = radius/3;
		CGFloat padding = (self.frame.size.height * 0.5f)-([_lineWidth floatValue]/3.f)*2;
		
		UIBezierPath *path = [UIBezierPath bezierPath];
		[path moveToPoint:CGPointMake(-a, -radius+ padding-2)];
		[path addLineToPoint:CGPointMake(a, -radius + padding-2)];
		[path addLineToPoint:CGPointMake(0, b + padding)];
		[path moveToPoint:CGPointMake(-1, -radius+ padding)];
		[path addLineToPoint:CGPointMake(-1, -radius+ padding)];
		[path addLineToPoint:CGPointMake(1, -radius+ padding)];
		[path addLineToPoint:CGPointMake(1, (self.frame.size.height * 0.5))];
		[path addLineToPoint:CGPointMake(-1, (self.frame.size.height * 0.5))];
		[path closePath];
		
		[path applyTransform:CGAffineTransformMakeTranslation(CGRectGetMidX(bounds), CGRectGetMidY(bounds))];
		_arrow.path = path.CGPath;
		
		_arrow.frame = bounds;
		
		[self.layer addSublayer:_arrow];
		//*************************************************************
		
		_countingLabel = [[UICountingLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height - [_lineWidth floatValue]*1.5f * 2, 40.0)];
		[_countingLabel setAdjustsFontSizeToFitWidth:YES];
		[_countingLabel setTextAlignment:NSTextAlignmentCenter];
		[_countingLabel setFont:[UIFont systemFontOfSize:32.0f]];
		[_countingLabel setMinimumScaleFactor:0.01];
		[_countingLabel setTextColor:[UIColor blackColor]];
		[_countingLabel setBackgroundColor:[UIColor clearColor]];
		[_countingLabel setCenter:CGPointMake(frame.size.width /2 , frame.size.height /2 - _countingLabel.frame.size.height/4 )];
		_countingLabel.method = UILabelCountingMethodEaseInOut;
		if (_displayCountingLabel) {
			[self addSubview:_countingLabel];
		}
		
		_display_spendingLabel = [[UILabel alloc]initWithFrame:CGRectMake(
																		  self.frame.size.width/2 - (self.frame.size.width/2.f - [_lineWidth floatValue]*1.5f ) ,
																		  self.frame.size.height-[_lineWidth floatValue]*2.5f,
																		  self.frame.size.width - [_lineWidth floatValue]*1.5f * 2.f,
																		  40.f)];
		[_display_spendingLabel setAdjustsFontSizeToFitWidth:YES];
		[_display_spendingLabel setTextAlignment:NSTextAlignmentCenter];
		[_display_spendingLabel setFont:[UIFont systemFontOfSize:20.0f]];
		[_display_spendingLabel setMinimumScaleFactor:0.01];
		[_display_spendingLabel setTextColor:[UIColor grayColor]];
		[_display_spendingLabel setBackgroundColor:[UIColor clearColor]];
		[_display_spendingLabel setText:@"已消費"];
		if (_displayCountingLabel) {
			[self addSubview:_display_spendingLabel];
		}
		
		
		_spendingLabel = [[UICountingLabel alloc]initWithFrame:CGRectMake(
																		  self.frame.size.width/2 - (self.frame.size.width/2.f - [_lineWidth floatValue]*1.5f ) ,
																		  self.frame.size.height-[_lineWidth floatValue]*1.5f,
																		  self.frame.size.width - [_lineWidth floatValue]*1.5f * 2.f,
																		  [_lineWidth floatValue])];
		[_spendingLabel setAdjustsFontSizeToFitWidth:YES];
		[_spendingLabel setTextAlignment:NSTextAlignmentCenter];
		[_spendingLabel setFont:[UIFont systemFontOfSize:36.0f]];
		[_spendingLabel setMinimumScaleFactor:0.01];
		[_spendingLabel setTextColor:[UIColor blackColor]];
		[_spendingLabel setBackgroundColor:[UIColor clearColor]];
		_spendingLabel.method = UILabelCountingMethodEaseInOut;
		if (_displayCountingLabel) {
			[self addSubview:_spendingLabel];
		}
		
		//ajust font size;
		[_countingLabel setFont:[UIFont systemFontOfSize:(_spendingLabel.font.pointSize * 1.3f)]];
	}
	
	return self;
}


- (void)strokeChart
{
	[self stroke_BGChart]; //gray background
	
	
	// Add circle params
	_circle.lineWidth   = [_lineWidth floatValue];
	_circleBackground.lineWidth = [_lineWidth floatValue];
	_circleBackground.strokeEnd = 1.0;
	_circle.strokeColor = _strokeColor.CGColor;
	
	// Add Animation
	CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	pathAnimation.duration = self.duration;
	pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	pathAnimation.fromValue = @0.0f;
	pathAnimation.toValue = @((([_current floatValue] > 99)?100.0f:[_current floatValue]) / [_total floatValue]);
	[_circle addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
	_circle.strokeEnd   = (([_current floatValue] > 99)?100.0f:[_current floatValue])/ [_total floatValue];
	
	//**************************************************************arrow
	float beginDegree = DEGREES_TO_RADIANS(45);
	float endDegree = (((([_current floatValue]>99)?100.0f:[_current floatValue])/[_total floatValue])*DEGREES_TO_RADIANS(270))+beginDegree;
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:beginDegree];
	animation.toValue = [NSNumber numberWithFloat:((endDegree<=0)?beginDegree:endDegree)];
	animation.duration = self.duration;
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[_arrow addAnimation:animation forKey:@"transform.rotation.z"];
	//**************************************************************
	
	[self addSubview:self.countingLabel];
	[_spendingLabel setTextColor:_strokeColor];
	
	if ([_current floatValue] > 299){
		self.countingLabel.format = @"%d%%+";
		[_countingLabel countFrom:0 to:300.0f withDuration:1.0];
		self.spendingLabel.format = @"$%.02f";
		[_spendingLabel countFrom:0 to:_currentSpending withDuration:1.0];
	}else{
		self.countingLabel.format = @"%d%%";
		[_countingLabel countFrom:0 to:[_current floatValue] withDuration:1.0];
		self.spendingLabel.format = @"$%.02f";
		[_spendingLabel countFrom:0 to:_currentSpending withDuration:1.0];
	}
	
	
	// Check if user wants to add a gradient from the start color to the bar color
	if (_strokeColorGradientStart) {
		
		// Add gradient
		self.gradientMask = [CAShapeLayer layer];
		self.gradientMask.fillColor = [[UIColor clearColor] CGColor];
		self.gradientMask.strokeColor = [[UIColor blackColor] CGColor];
		self.gradientMask.lineWidth = _circle.lineWidth;
		self.gradientMask.lineCap = kCALineCapButt;
		CGRect gradientFrame = CGRectMake(0, 0, 2*self.bounds.size.width, 2*self.bounds.size.height);
		self.gradientMask.frame = gradientFrame;
		self.gradientMask.path = _circle.path;
		
		CAGradientLayer *gradientLayer = [CAGradientLayer layer];
		gradientLayer.startPoint = CGPointMake(0.5,1.0);
		gradientLayer.endPoint = CGPointMake(0.5,0.0);
		gradientLayer.frame = gradientFrame;
		UIColor *endColor = (_strokeColor ? _strokeColor : [UIColor greenColor]);
		NSArray *colors = @[
							(id)endColor.CGColor,
							(id)_strokeColorGradientStart.CGColor
							];
		gradientLayer.colors = colors;
		
		[gradientLayer setMask:self.gradientMask];
		
		[_circle addSublayer:gradientLayer];
		
		self.gradientMask.strokeEnd = [_current floatValue] / [_total floatValue];
		
		[self.gradientMask addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
		
	}
}

-(void)stroke_BGChart{
	// Add circle params
	_circle.lineWidth   = [_lineWidth floatValue];
	_circleBackground.lineWidth = [_lineWidth floatValue];
	_circleBackground.strokeEnd = 1.0;
	_circle.strokeColor = _strokeColor.CGColor ;
	_circle.strokeEnd   = 1;
	
	if (_strokeColorGradientStart) {
		// Add gradientk
		self.gradientMask = [CAShapeLayer layer];
		self.gradientMask.fillColor = [[UIColor clearColor] CGColor];
		self.gradientMask.strokeColor = [[UIColor blackColor] CGColor];
		self.gradientMask.lineWidth = _circle.lineWidth;
		self.gradientMask.lineCap = kCALineCapButt;
		self.gradientMask.lineJoin = kCALineCapButt;
		CGRect gradientFrame = CGRectMake(0, 0, 2*self.bounds.size.width, 2*self.bounds.size.height);
		self.gradientMask.frame = gradientFrame;
		self.gradientMask.path = _circle.path;
		self.gradientMask.strokeStart = (0.f / 100.f );
		self.gradientMask.strokeEnd = (61.f / 100.f );
		
		CAGradientLayer *gradientLayer = [CAGradientLayer layer];
		gradientLayer.startPoint = CGPointMake(0.5,1.0);
		gradientLayer.endPoint = CGPointMake(0.5,0.0);
		gradientLayer.frame = gradientFrame;
		UIColor *endColor = ([UIColor colorWithRed:164.f/255.f green:242.f/255.f blue:207.f/255.f alpha:1]);
		NSArray *colors = @[
							(id)endColor.CGColor,
							(id)endColor.CGColor
							];
		gradientLayer.colors = colors;
		[gradientLayer setMask:self.gradientMask];
		[_circle addSublayer:gradientLayer];
		
		self.gradientMask = [CAShapeLayer layer];
		self.gradientMask.fillColor = [[UIColor clearColor] CGColor];
		self.gradientMask.strokeColor = [[UIColor blackColor] CGColor];
		self.gradientMask.lineWidth = _circle.lineWidth;
		self.gradientMask.lineCap = kCALineCapButt;
		self.gradientMask.lineJoin = kCALineCapButt;
		self.gradientMask.frame = gradientFrame;
		self.gradientMask.path = _circle.path;
		self.gradientMask.strokeStart = (61.f / 100.f );
		self.gradientMask.strokeEnd = (91.f / 100.f );
		
		CAGradientLayer *gradientLayer2 = [CAGradientLayer layer];
		gradientLayer2.startPoint = CGPointMake(0.5,1.0);
		gradientLayer2.endPoint = CGPointMake(0.5,0.0);
		gradientLayer2.frame = gradientFrame;
		UIColor *endColor2 = ([UIColor colorWithRed:255.f/255.f green:237.f/255.f blue:176.f/255.f alpha:1]);
		NSArray *colors2 = @[
							 (id)endColor2.CGColor,
							 (id)endColor2.CGColor
							 ];
		gradientLayer2.colors = colors2;
		[gradientLayer2 setMask:self.gradientMask];
		[_circle addSublayer:gradientLayer2];
		
		self.gradientMask = [CAShapeLayer layer];
		self.gradientMask.fillColor = [[UIColor clearColor] CGColor];
		self.gradientMask.strokeColor = [[UIColor blackColor] CGColor];
		self.gradientMask.lineWidth = _circle.lineWidth;
		self.gradientMask.lineCap = kCALineCapButt;
		self.gradientMask.lineJoin = kCALineCapButt;
		self.gradientMask.frame = gradientFrame;
		self.gradientMask.path = _circle.path;
		self.gradientMask.strokeStart = (91.f / 100.f );
		self.gradientMask.strokeEnd = (100.f / 100.f );
		
		CAGradientLayer *gradientLayer3 = [CAGradientLayer layer];
		gradientLayer3.startPoint = CGPointMake(0.5,1.0);
		gradientLayer3.endPoint = CGPointMake(0.5,0.0);
		gradientLayer3.frame = gradientFrame;
		UIColor *endColor3 = ([UIColor colorWithRed:255.f/255.f green:199.f/255.f blue:199.f/255.f alpha:1]);
		NSArray *colors3 = @[
							 (id)endColor3.CGColor,
							 (id)endColor3.CGColor
							 ];
		gradientLayer3.colors = colors3;
		[gradientLayer3 setMask:self.gradientMask];
		[_circle addSublayer:gradientLayer3];
	}
}

- (void)growChartByAmount:(NSNumber *)growAmount
{
	NSNumber *updatedValue = [NSNumber numberWithFloat:[_current floatValue] + [growAmount floatValue]];
	
	// Add animation
	[self updateChartByCurrent:updatedValue];
}


-(void)updateChartByCurrent:(NSNumber *)current{
	// Add animation
	CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	pathAnimation.duration = self.duration;
	pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	pathAnimation.fromValue = @([_current floatValue] / [_total floatValue]);
	pathAnimation.toValue = @([current floatValue] / [_total floatValue]);
	_circle.strokeEnd   = [current floatValue] / [_total floatValue];
	
	if (_strokeColorGradientStart) {
		self.gradientMask.strokeEnd = _circle.strokeEnd;
		[self.gradientMask addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
	}
	[_circle addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
	
	if (_displayCountingLabel) {
		[self.countingLabel countFrom:fmin([_current floatValue], [_total floatValue]) to:fmin([current floatValue], [_total floatValue]) withDuration:self.duration];
	}
	
	_current = current;
}

@end
