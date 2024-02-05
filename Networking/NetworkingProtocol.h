#import <Foundation/Foundation.h>

@protocol NetworkingProtocol <NSObject>
-(void)fetchURL:(NSString*) url complete:(void(^)(NSData*)) complete;
@end

@protocol NetworkingProtocolHost <NSObject>
@end
