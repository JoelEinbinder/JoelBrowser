#import <Foundation/Foundation.h>
#import "WebContentProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class Element;

@interface JBDOMNode : NSObject {
    Element* _parentElement;
}
-(NSString*)textContent;
-(void)setParentElement:(nullable Element*)element;
-(nullable Element*)parentElement;
@end

@class TextSpan;

@interface Element : JBDOMNode {
    NSArray<JBDOMNode*>* _childNodes;
    NSString* _tagName;
    NSDictionary<NSString *,NSString *> * _attributes;
}
-(instancetype)initWithTagName:(NSString*) tagName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict;
-(void)append:(JBDOMNode*) node;
-(NSDictionary<NSString *,NSString *> *)attributes;
-(NSString*)tagName;
-(NSArray<JBDOMNode*>*) childNodes;
@end

@interface TextNode : JBDOMNode {
    NSString* _text;
}
-(instancetype)initWithText:(NSString*) text;
@end

NS_ASSUME_NONNULL_END
