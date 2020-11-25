#import "MARKCircularSlider.h"

@interface MARKCircularSlider ()

@property (nonatomic, assign) CGPoint centerPoint;
@property(nonatomic, assign) CGFloat radius;
@property(nonatomic, strong) UIImageView *pointIndicator;
@end

@implementation MARKCircularSlider

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

#pragma mark - Configuration

- (void)setDefaults
{
    // Set initial values
    self.value = 0.0f;
    self.minimumValue = 0.0f;
    self.maximumValue = 1.0f;
    self.radius = 0.0f;

    // Set colors
    self.backgroundColor = [UIColor clearColor];
    self.filledColor = [UIColor blueColor];
    self.unfilledColor = [UIColor lightGrayColor];
    
    [self addSubview:self.pointIndicator];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    CGFloat halfWidth = CGRectGetWidth(self.frame) / 2;
    CGFloat halfHeight = CGRectGetHeight(self.frame) / 2;

    self.radius = halfWidth > halfHeight ? halfHeight : halfWidth;
    self.centerPoint = CGPointMake(halfWidth, halfHeight);
    
    CGFloat degrees = 360.0f * self.value / [self valueRange];
    CGPoint indicatorCenter = [self getIndicateLocation:degrees];
    self.pointIndicator.center = indicatorCenter;
}

#pragma mark - UI

- (void)drawRect:(CGRect)rect
{
    CGFloat diameter = self.radius * 2.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Unfilled part
    [self.unfilledColor setFill];
    CGRect contourRect = CGRectMake(
                                    self.centerPoint.x - self.radius,
                                    self.centerPoint.y - self.radius,
                                    diameter, diameter);
    CGContextFillEllipseInRect (context, contourRect);
    CGContextFillPath(context);

    // Filled part
    CGContextBeginPath(context);
    [self.filledColor setFill];
    CGFloat degrees = 360.0f * self.value / [self valueRange];
    CGContextAddArc(context, self.centerPoint.x, self.centerPoint.y,
                    self.radius, 0 - M_PI_2,
                    [self radiansFromDegrees:degrees] - M_PI_2, 0);
    CGContextAddLineToPoint(context, self.centerPoint.x, self.centerPoint.y);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

#pragma mark - Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];

    if ([self containsPoint:point]) {
        [self sendActionsForControlEvents:UIControlEventTouchDown];
        self.value = [self valueForPoint:point];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];

    if ([self containsPoint:point]) {
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];

    [self sendActionsForControlEvents:UIControlEventTouchCancel];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];

    self.value = [self valueForPoint:point];
}

#pragma mark - Helpers

- (CGFloat)valueRange
{
    return self.maximumValue - self.minimumValue;
}

- (BOOL)containsPoint:(CGPoint)point
{   ///勾股定理 a^2 +b^2 = c^2; 开方后得到当前点距离center的直线距离
    CGFloat distance = sqrtf(
                             powf(point.x - self.centerPoint.x, 2) +
                             powf(point.y - self.centerPoint.y, 2));
    return distance <= self.radius;
}

- (CGFloat)radiansFromDegrees:(CGFloat)degrees
{
    return degrees * M_PI / 180.0f;
}

- (CGFloat)degreesFromRadians:(CGFloat)radians
{
    return radians * 180.0f / M_PI;
}

- (CGFloat)valueForPoint:(CGPoint)point{
    /// tan(x) = y/x;  atan获取弧度
    CGFloat atan = atan2f(point.x - self.centerPoint.x, point.y - self.centerPoint.y);
    ///弧度转角度
    CGFloat degrees = -([self degreesFromRadians:atan] - 180.0f);

    if (degrees < 0) {
        degrees = 360.0f + degrees;
    }
    CGPoint indicatorCenter = [self getIndicateLocation:degrees];
    self.pointIndicator.center = indicatorCenter;
    
    ///一圈360度, 当前角度/ 360 * range就是当前value
    return degrees / 360.0f * [self valueRange];
}

- (CGPoint)getIndicateLocation:(CGFloat)degree{
    /// 图中实际Y轴是向下为正, 所以需要减去90度
    CGFloat yLocation = self.radius * sin([self radiansFromDegrees: degree - 90]) + self.centerPoint.y;
    CGFloat xLocation = self.radius * cos([self radiansFromDegrees: degree - 90]) + self.centerPoint.x;

//    NSLog(@"%f %f %f %f %f %f %f", sin([self radiansFromDegrees: degree - 90]), sin([self radiansFromDegrees: degree]), self.centerPoint.x, self.centerPoint.y, self.radius, yLocation, xLocation);
    
    return CGPointMake(xLocation, yLocation);
}

#pragma mark - Setters

- (void)setValue:(CGFloat)value
{
    _value = value;
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Getters
- (UIImageView *)pointIndicator{
    if(!_pointIndicator){
        _pointIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x1"]];
        [_pointIndicator setFrame:CGRectMake(0, 0, 30, 30)];
    }
    return _pointIndicator;
}
@end
