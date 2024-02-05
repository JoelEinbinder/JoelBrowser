#import "NetworkingProtocol.h"

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@interface NetworkProtocolImpl : NSObject <NetworkingProtocol>
@end

@implementation NetworkProtocolImpl
- (void)fetchURL:(NSString *)url complete:(void(^)(NSData*)) complete {
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        complete(data);
    }];
    [task resume];
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
    NetworkProtocolImpl* protocolImpl = [[NetworkProtocolImpl alloc] init];
    [connection setExportedInterface:[NSXPCInterface interfaceWithProtocol:@protocol(NetworkingProtocol)]];
    [connection setExportedObject:protocolImpl];
    [connection setRemoteObjectInterface:[NSXPCInterface interfaceWithProtocol:@protocol(NetworkingProtocolHost)]];
    [connection activate];
    return YES;
}

@end
