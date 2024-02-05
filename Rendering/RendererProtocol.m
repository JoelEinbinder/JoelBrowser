#import "RenderingProtocol.h"
#import "../WebContent/JBDOMNode.h"
#import "CommandList.h"

@interface JBWebView : UIView {
    CommandList* _list;
}
-(instancetype)initWithCommandList:(CommandList*) node;
@end

@implementation JBWebView
-(instancetype)initWithCommandList:(CommandList *)list {
    self = [self initWithFrame:CGRectMake(0, 0, list.width, list.height)];
    if (!self)
        return self;
    _list = list;
    return self;
}
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    [_list render];
    [super drawRect:rect];
}

- (BOOL)isOpaque {
    return NO;
}
@end

@implementation RenderingProtocolImpl
- (UIView *)renderCommandList:(CommandList *)list {
    return [[JBWebView alloc] initWithCommandList:list];
}
@end
