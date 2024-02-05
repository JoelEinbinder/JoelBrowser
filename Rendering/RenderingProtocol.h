#import <Foundation/Foundation.h>
#import "../WebContent/JBDOMNode.h"
#import "CommandList.h"
#import <UIKit/UIKit.h>

@protocol RenderingProtocol <NSObject>
-(UIView*)renderCommandList:(CommandList*)list;
@end

@protocol RenderingProtocolHost <NSObject>
@end

// This is exposed because I don't know how to move the UI stuff out of the main process
@interface RenderingProtocolImpl : NSObject <RenderingProtocol>

@end
