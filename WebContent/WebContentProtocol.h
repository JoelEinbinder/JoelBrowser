#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CommandList;

@protocol WebContentProtocol <NSObject>
-(void)setSource:(NSString*) source;
-(void)resize:(CGSize)size;
-(void)tap:(CGPoint)point;
@end

@protocol WebContentProtocolHost <NSObject>
-(void)requestRepaint:(CommandList*) list;
-(void)requestNavigation:(NSString*) url;
-(void)showMessageBox:(NSString*) text;
-(void)requestData:(NSString*)url completion:(void (^)(NSData* data))completion;
@end
