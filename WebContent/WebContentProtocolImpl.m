#import "WebContentProtocol.h"
#import "DOMParser.h"

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface WebContentProtocolImpl : NSObject <WebContentProtocol> {
    Element* documentElement;
}
@end

@implementation WebContentProtocolImpl

-(instancetype)init {
    documentElement = nil;
    return [super init];
}

- (nonnull NSObject<WebContentProtocolHost> *)host { 
    return [[NSXPCConnection currentConnection] remoteObjectProxy];
}

- (void)setSource:(NSString *)source {
    documentElement = (Element*)[[[DOMParser alloc] init] parse:source];
    NSLog(@"%@", [documentElement textContent]);
}

-(void)tap:(CGPoint)point {
    NSLog(@"tap");
}

- (void)resize:(CGSize)size {
    NSLog(@"resize");
}

@end

@interface EXConcreteExtensionContextVendor : NSObject
-(BOOL)listener:(id)arg1 shouldAcceptNewConnection:(id)arg2 ;
@end


@implementation NSXPCConnection (Swizzling)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("EXConcreteExtensionContextVendor");
        SEL originalSelector = @selector(listener:shouldAcceptNewConnection:);
        SEL swizzledSelector = @selector(my_listener:shouldAcceptNewConnection:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod([NSXPCConnection class], swizzledSelector);
        IMP swizzledImp = method_getImplementation(swizzledMethod);
        IMP originalImp = method_getImplementation(originalMethod);
        const char* typeEncoding = method_getTypeEncoding(originalMethod);
        class_replaceMethod(class,originalSelector, swizzledImp, typeEncoding);
        class_replaceMethod(class,swizzledSelector, originalImp, typeEncoding);
    });
}
-(BOOL)my_listener:(NSXPCListener*)listener shouldAcceptNewConnection:(NSXPCConnection*)connection {
    WebContentProtocolImpl* protocolImpl = [[WebContentProtocolImpl alloc] init];
    [connection setExportedInterface:[NSXPCInterface interfaceWithProtocol:@protocol(WebContentProtocol)]];
    [connection setExportedObject:protocolImpl];
    [connection setRemoteObjectInterface:[NSXPCInterface interfaceWithProtocol:@protocol(WebContentProtocolHost)]];
    [connection activate];
    return YES;
}

@end
