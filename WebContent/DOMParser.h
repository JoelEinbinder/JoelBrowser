#import <Foundation/Foundation.h>
#import "JBDOMNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface DOMParser : NSObject <NSXMLParserDelegate> {
    Element* _root;
    NSMutableArray<Element*>* _elementStack;
}
-(JBDOMNode*)parse:(NSString*) source;
@end

NS_ASSUME_NONNULL_END
