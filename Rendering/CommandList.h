#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class UIView;
@class UIImage;
@interface CommandList : NSObject <NSSecureCoding> {
    CGSize _size;
    NSMutableArray* _commands;
}
-(void)render;
-(float)width;
-(float)height;
-(instancetype)initWithSize:(CGSize) size;
-(void)drawText:(NSString*)text atPoint:(CGPoint) point withAttributes: (NSDictionary<NSAttributedStringKey, id>*) attributes;
-(void)drawButton:(NSString*)text inRect:(CGRect) rect;
-(void)drawImage:(UIImage*)image inRect:(CGRect) rect;
@end

NS_ASSUME_NONNULL_END
