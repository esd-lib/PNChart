//
//  PNBarChart.m
//  PNChartDemo
//
//  Created by kevin on 11/7/13.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import "PNBarChart.h"
#import "PNColor.h"
#import "PNChartLabel.h"


@interface PNBarChart () {
	NSMutableArray *_xChartLabels;
	NSMutableArray *_yChartLabels;
}

- (UIColor *)barColorAtIndex:(NSUInteger)index;

@end

@implementation PNBarChart

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self setupDefaultValues];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setupDefaultValues];
	}
	
	return self;
}

- (void)setupDefaultValues
{
	self.backgroundColor = [UIColor whiteColor];
	self.clipsToBounds   = YES;
	_showLabel           = YES;
	_barBackgroundColor  = [UIColor clearColor];
	_labelTextColor      = [UIColor grayColor];
	_labelFont           = [UIFont systemFontOfSize:11.0f];
	_headerLabels        = [NSMutableArray array];
	_xChartLabels        = [NSMutableArray array];
	_yChartLabels        = [NSMutableArray array];
	_bars                = [NSMutableArray array];
	_xLabelSkip          = 1;
	_targetColor         = [UIColor greenColor]; // color line
	_yLabelSum           = 5;
	_labelMarginTop      = 0;
	_chartMargin         = 15.0;
	_barRadius           = 2.0;
	_showChartBorder     = NO;
	_yChartLabelWidth    = 35;
	_rotateForXAxisText  = false;
	_indexLeftMargin     = _yChartLabelWidth-20;
}

-(float)getMaxValue:(float)targetValue{
	float MaxValue = 0;
	
	NSArray *arr_maxValue = @[@1000000000,@100000000,@10000000,@1000000,@100000,@80000,@60000,@40000,@20000,@10000,@5000,@1000,@100];
	for(NSNumber *i in arr_maxValue){
		if (targetValue <= [i floatValue] ){
			MaxValue =  [i floatValue];
		}
	}
	return MaxValue;
}

- (void)setYValues:(NSArray *)yValues
{
	_yValues = yValues;
	
	[self getYValueMax:yValues];
	
	if (_yValueMax > _yMaxValue) _yValueMax = [self getMaxValue:_yValueMax]; else _yValueMax = _yMaxValue ;
	
	if (_yChartLabels) {
		[self viewCleanupForCollection:_yChartLabels];
	}else{
		_yLabels = [NSMutableArray new];
	}
	
	if (_showLabel) {
		//Add y labels
		
		float yLabelSectionHeight = (self.frame.size.height - _chartMargin * 2 - xLabelHeight) / _yLabelSum;
		
		for (int index = 0; index < _yLabelSum; index++) {
			
			NSString *labelText = _yLabelFormatter((float)(_yValueMax-_yMinValue) * ( (_yLabelSum - index) / (float)_yLabelSum )+_yMinValue);
			
			PNChartLabel * label = [[PNChartLabel alloc] initWithFrame:CGRectMake(0,
																				  yLabelSectionHeight * index + _chartMargin - yLabelHeight/2.0,
																				  _yChartLabelWidth,
																				  yLabelHeight)];
			
			label.font = _labelFont;
			label.textColor = _labelTextColor;
			[label setTextAlignment:NSTextAlignmentRight];
			label.text = [self returnYValues:labelText];
			
			UIView *view_line = [[UIView alloc]initWithFrame:CGRectMake(_indexLeftMargin+25, yLabelSectionHeight * index + _chartMargin , self.frame.size.width-50, 1)];
			[view_line setBackgroundColor:[UIColor grayColor]];
			[self addSubview:view_line];
			
			[_yChartLabels addObject:label];
			[self addSubview:label];
			
			if (index == 0){
				PNChartLabel * label = [[PNChartLabel alloc] initWithFrame:CGRectMake(0, yLabelSectionHeight *(_yLabelSum) + _chartMargin - yLabelHeight/2.0, _yChartLabelWidth, yLabelHeight)];
				label.font = _labelFont;
				label.textColor = _labelTextColor;
				[label setTextAlignment:NSTextAlignmentRight];
				//[label setAdjustsFontSizeToFitWidth:YES];
				label.text = [NSString stringWithFormat:@"%i",(int)_yMinValue];
				[self addSubview:label];
			}
		}
	}
}

-(void)updateChartData:(NSArray *)data{
	self.yValues = data;
	[self updateBar];
}

- (void)getYValueMax:(NSArray *)yLabels
{
	int max = [[yLabels valueForKeyPath:@"@max.intValue"] intValue];
	
	_yValueMax = (int)max;
	
	if (_yValueMax == 0) {
		_yValueMax = _yMinValue;
	}
}

- (void)setXLabels:(NSArray *)xLabels
{
	_xLabels = xLabels;
	
	if (_xChartLabels) {
		[self viewCleanupForCollection:_xChartLabels];
	}else{
		_xChartLabels = [NSMutableArray new];
	}
	
	if (_showLabel) {
		_xLabelWidth = (self.frame.size.width - _chartMargin * 2) / [xLabels count];
		int labelAddCount = 0;
		for (int index = 0; index < _xLabels.count; index++) {
			labelAddCount += 1;
			
			if (labelAddCount == _xLabelSkip) {
				NSString *labelText = [_xLabels[index] description];
				PNChartLabel * label = [[PNChartLabel alloc] initWithFrame:CGRectMake(_indexLeftMargin, 0, _xLabelWidth, xLabelHeight)];
				label.font = _labelFont;
				label.textColor = _labelTextColor;
				[label setTextAlignment:NSTextAlignmentCenter];
				label.text = labelText;
				//[label sizeToFit];
				CGFloat labelXPosition;
				if (_rotateForXAxisText){
					label.transform = CGAffineTransformMakeRotation(M_PI / 4);
					labelXPosition = (index *  _xLabelWidth + _chartMargin + _xLabelWidth /1.5);
				}
				else{
					labelXPosition = (index *  _xLabelWidth + _chartMargin + _xLabelWidth /2.0 );
				}
				label.center = CGPointMake(labelXPosition+_indexLeftMargin,
										   self.frame.size.height - xLabelHeight - _chartMargin + label.frame.size.height /2.0 + _labelMarginTop);
				labelAddCount = 0;
				
				[_xChartLabels addObject:label];
				[self addSubview:label];
			}
		}
	}
}


- (void)setStrokeColor:(UIColor *)strokeColor
{
	_strokeColor = strokeColor;
}

- (void)updateBar
{
	
	//Add bars
	CGFloat chartCavanHeight = self.frame.size.height - _chartMargin * 2 - xLabelHeight;
	NSInteger index = 0;
	
	//debug
	//    _xLabelWidth = (self.frame.size.width - _chartMargin * 2) / [_bars count];
	//    int labelAddCount = 0;
	
	for (NSNumber *valueString in _yValues) {
		
		PNBar *bar;
		
		if (_bars.count == _yValues.count) {
			bar = [_bars objectAtIndex:index];
		}else{
			CGFloat barWidth;
			CGFloat barXPosition;
			
			if (_barWidth) {
				barWidth = _barWidth;
				barXPosition = index *  _xLabelWidth + _chartMargin + _xLabelWidth /2.0 - _barWidth /2.0;
			}else{
				barXPosition = index *  _xLabelWidth + _chartMargin + _xLabelWidth * 0.25;
				if (_showLabel) {
					barWidth = _xLabelWidth * 0.5;
					
				}
				else {
					barWidth = _xLabelWidth * 0.6;
					
				}
			}
			
			bar = [[PNBar alloc] initWithFrame:CGRectMake(barXPosition+_indexLeftMargin, //Bar X position
														  self.frame.size.height - chartCavanHeight - xLabelHeight - _chartMargin, //Bar Y position
														  barWidth, // Bar witdh
														  chartCavanHeight)]; //Bar height
			
			//Change Bar Radius
			bar.barRadius = _barRadius;
			
			//Change Bar Background color
			bar.backgroundColor = _barBackgroundColor;
			
			//Bar StrokColor First
			if (self.strokeColor) {
				bar.barColor = self.strokeColor;
			}else{
				bar.barColor = [self barColorAtIndex:index];
			}
			// Add gradient
			bar.barColorGradientStart = _barColorGradientStart;
			
			//For Click Index
			bar.tag = index;
			
			[_bars addObject:bar];
			[self addSubview:bar];
		}
		
		//Height Of Bar
		float value = [valueString floatValue] - _yMinValue;//modify
		
		float grade = (float)value / ((float)_yValueMax  - _yMinValue);//modify
		
		UILabel *lbl_lbl = [[UILabel alloc]initWithFrame:CGRectMake(bar.frame.origin.x-bar.frame.size.width*0.25, //Bar X position
																	(chartCavanHeight * (1-grade))-xLabelHeight/3 , //Bar Y position
																	bar.frame.size.width*1.5f, // Bar witdh
																	xLabelHeight)]; //Bar height
		
		[self returnCurrencyValues:value];
		
		lbl_lbl.font = _labelFont;
		[lbl_lbl setTextColor:_labelTextColor];
		[lbl_lbl setTextAlignment:NSTextAlignmentCenter];
		[lbl_lbl setText:[self returnCurrencyValues:value]];//[numberAsString substringToIndex:3]];
		[lbl_lbl setAdjustsFontSizeToFitWidth:YES];
		[self addSubview:lbl_lbl];
		
		if (isnan(grade)) {
			grade = 0;
		}
		bar.grade = grade;
		index += 1;
	}
	float fff =((float)_targetValue - _yMinValue )/ ((float)_yValueMax  - _yMinValue);
	_targetY =self.frame.size.height - chartCavanHeight - xLabelHeight - _chartMargin + chartCavanHeight * (1-fff);
	
}

-(NSString*)returnCurrencyValues:(float)value{
	NSString *return_value = [[NSString alloc]init];
	return_value = @"";
	
	double int_value = [[NSString stringWithFormat:@"%.1f",(double)value]doubleValue];
	double int_length = (int_value == 0 ? 1 : ((int)(log10(fabs((double)int_value))+1) + (int_value < 0 ? 1 : 0)));
	
	BOOL bool_k = false;
	BOOL bool_m = false;
	
	if (int_length > 3) bool_k = true;
	if (int_length > 6) bool_m = true;
	
	if (bool_m){
		return_value = [[NSString stringWithFormat:@"%.1f",int_value]substringToIndex:int_length-6];
	}else if (bool_k){
		return_value = [[NSString stringWithFormat:@"%.1f",int_value]substringToIndex:int_length-3];
	}else{
		return_value = [NSString stringWithFormat:@"%.1f",int_value];
	}
	
	return [NSString stringWithFormat:@"$%@%@",return_value,(bool_m)?@"M":(bool_k)?@"K":@""];
}

-(NSString*)returnYValues:(NSString*)value{
	NSString *return_value = [[NSString alloc]init];
	return_value = @"";
	
	int int_value = [[NSString stringWithFormat:@"%.0f",round((double)[value doubleValue])]intValue];
	int int_length = (int_value == 0 ? 1 : ((int)(log10(fabs((double)int_value))+1) + (int_value < 0 ? 1 : 0)));
	
	BOOL bool_k = false;
	BOOL bool_m = false;
	
	if (int_length > 3) bool_k = true;
	if (int_length > 6) bool_m = true;
	
	if (bool_m){
		return_value = [[NSString stringWithFormat:@"%d",int_value]substringToIndex:int_length-6];
	}else if (bool_k){
		return_value = [[NSString stringWithFormat:@"%d",int_value]substringToIndex:int_length-3];
	}else{
		return_value = [NSString stringWithFormat:@"%d",int_value];
	}
	
	NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
	f.numberStyle = NSNumberFormatterDecimalStyle;
	NSNumber *myNumber = [f numberFromString:return_value];
	
	NSString * formattedAmount = [f stringFromNumber:myNumber];
	
	return [NSString stringWithFormat:@"$%@%@",formattedAmount,(bool_m)?@"M":(bool_k)?@"K":@""];
}

-(void)strokeLine{
	
	UIView *view_line = [[UIView alloc]initWithFrame:CGRectMake(self.frame.origin.x - self.frame.size.width+_indexLeftMargin, _targetY  , self.frame.size.width-50, 2)];
	[view_line setBackgroundColor:_targetColor];
	[self addSubview:view_line];
	
	[UIView animateWithDuration:1.0f
						  delay:0.0f
						options:0
					 animations:^{
						 [view_line setFrame:CGRectMake(25+_indexLeftMargin, _targetY, self.frame.size.width-50, 2)];
					 }
					 completion:nil];
	
}
- (void)strokeChart
{
	//Add Labels
	
	[self viewCleanupForCollection:_bars];
	
	
	//Update Bar
	
	[self updateBar];
	
	//Add chart border lines
	
	if (_showChartBorder) {
		_chartBottomLine = [CAShapeLayer layer];
		_chartBottomLine.lineCap      = kCALineCapButt;
		_chartBottomLine.fillColor    = [[UIColor whiteColor] CGColor];
		_chartBottomLine.lineWidth    = 1.0;
		_chartBottomLine.strokeEnd    = 0.0;
		
		UIBezierPath *progressline = [UIBezierPath bezierPath];
		
		[progressline moveToPoint:CGPointMake(_chartMargin, self.frame.size.height - xLabelHeight - _chartMargin)];
		[progressline addLineToPoint:CGPointMake(self.frame.size.width - _chartMargin,  self.frame.size.height - xLabelHeight - _chartMargin)];
		
		[progressline setLineWidth:1.0];
		[progressline setLineCapStyle:kCGLineCapSquare];
		_chartBottomLine.path = progressline.CGPath;
		
		
		_chartBottomLine.strokeColor = PNLightGrey.CGColor;
		
		
		CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		pathAnimation.duration = 0.5;
		pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		pathAnimation.fromValue = @0.0f;
		pathAnimation.toValue = @1.0f;
		[_chartBottomLine addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
		
		_chartBottomLine.strokeEnd = 1.0;
		
		[self.layer addSublayer:_chartBottomLine];
		
		//Add left Chart Line
		
		_chartLeftLine = [CAShapeLayer layer];
		_chartLeftLine.lineCap      = kCALineCapButt;
		_chartLeftLine.fillColor    = [[UIColor whiteColor] CGColor];
		_chartLeftLine.lineWidth    = 1.0;
		_chartLeftLine.strokeEnd    = 0.0;
		
		UIBezierPath *progressLeftline = [UIBezierPath bezierPath];
		
		[progressLeftline moveToPoint:CGPointMake(_chartMargin, self.frame.size.height - xLabelHeight - _chartMargin)];
		[progressLeftline addLineToPoint:CGPointMake(_chartMargin,  _chartMargin)];
		
		[progressLeftline setLineWidth:1.0];
		[progressLeftline setLineCapStyle:kCGLineCapSquare];
		_chartLeftLine.path = progressLeftline.CGPath;
		
		
		_chartLeftLine.strokeColor = PNLightGrey.CGColor;
		
		
		CABasicAnimation *pathLeftAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		pathLeftAnimation.duration = 0.5;
		pathLeftAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		pathLeftAnimation.fromValue = @0.0f;
		pathLeftAnimation.toValue = @1.0f;
		[_chartLeftLine addAnimation:pathLeftAnimation forKey:@"strokeEndAnimation"];
		
		_chartLeftLine.strokeEnd = 1.0;
		
		[self.layer addSublayer:_chartLeftLine];
	}
}


- (void)viewCleanupForCollection:(NSMutableArray *)array
{
	if (array.count) {
		[array makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[array removeAllObjects];
	}
}


#pragma mark - Class extension methods

- (UIColor *)barColorAtIndex:(NSUInteger)index
{
	if ([self.strokeColors count] == [self.yValues count]) {
		return self.strokeColors[index];
	}
	else {
		return self.strokeColor;
	}
}


#pragma mark - Touch detection

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchPoint:touches withEvent:event];
	[super touchesBegan:touches withEvent:event];
}


- (void)touchPoint:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Get the point user touched
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	UIView *subview = [self hitTest:touchPoint withEvent:nil];
	
	if ([subview isKindOfClass:[PNBar class]] && [self.delegate respondsToSelector:@selector(userClickedOnBarAtIndex:)]) {
		[self.delegate userClickedOnBarAtIndex:subview.tag];
	}
}


@end

