#import "CommandList.h"
#import <UIKit/UIKit.h>

@implementation CommandList
-(instancetype)initWithSize:(CGSize) size {
    _size = size;
    _commands = [[NSMutableArray alloc] init];
    return [self init];
}
- (void)addChildViews: (UIView*) toView {
    NSLog(@"TODO addChildViews");
}
- (void)render {
    for (NSDictionary* command in _commands) {
        NSString* text = command[@"text"];
        NSNumber* x = command[@"point"][@"x"];
        NSNumber* y = command[@"point"][@"y"];
        CGPoint point = CGPointMake([x floatValue], [y floatValue]);
        NSDictionary* attributes = command[@"attributes"];
        [text drawAtPoint:point withAttributes:attributes];
    }
}

- (float)width {
    return _size.width;
}

- (float)height {
    return _size.height;
}
- (void)drawText:(NSString*)text atPoint:(CGPoint) point withAttributes: (NSDictionary<NSAttributedStringKey, id>*) attributes {
    [_commands addObject:@{
        @"text": text,
        @"point": @{ @"x": @(point.x), @"y": @(point.y) },
        @"attributes": attributes,
    }];
}
-(void)drawButton:(NSString*)text inRect:(CGRect) rect {
    NSLog(@"TODO drawButton");
}
- (void)drawImage:(UIImage *)image inRect:(CGRect)rect {
    NSLog(@"TODO drawImage");
}
- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:_commands forKey:@"commands"];
    [coder encodeFloat:self.width forKey:@"width"];
    [coder encodeFloat:self.height forKey:@"height"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    NSSet* allowedClasses = [NSSet setWithObjects: [NSMutableArray class], [NSDictionary class], [NSNumber class], [NSString class], [UIColor class], [UIFont class], [UIImage class], [NSMutableParagraphStyle class], nil];
    CGSize size;
    size.width = [coder decodeFloatForKey:@"width"];
    size.height = [coder decodeFloatForKey:@"height"];
    self = [self initWithSize:size];
    _commands = [coder decodeObjectOfClasses:allowedClasses forKey:@"commands"];
    if (!self)
        return self;
    return self;
}
+(BOOL) supportsSecureCoding {
    return YES;
}
@end