#import <Foundation/Foundation.h>
#import "WebContentProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface VBScript : NSObject
-(void)runScript: (NSString*) source host:(NSObject<WebContentProtocolHost>*) host;
@end

NS_ASSUME_NONNULL_END
