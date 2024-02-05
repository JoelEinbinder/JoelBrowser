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
    CGSize _size;
    CGPoint _origin;
    float _lastTextX;
    bool _hasTrailingWhiteSpace;
    NSArray<TextSpan*>* _textLayout;
    NSDictionary<NSString*, NSString*>* _style;
}
-(instancetype)initWithTagName:(NSString*) tagName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict;
-(void)append:(JBDOMNode*) node;
-(NSDictionary<NSString *,NSString *> *)attributes;
-(NSString*)tagName;
-(NSArray<JBDOMNode*>*) childNodes;
-(void)layout: (CGRect) container;
-(void)draw: (CommandList*) list;
-(nullable Element*)hitTest: (CGPoint) point;
-(CGSize)size;
-(void)tap: (NSObject<WebContentProtocolHost>*) sender;
@end

@interface TextNode : JBDOMNode {
    NSString* _text;
}
-(instancetype)initWithText:(NSString*) text;
@end

NS_ASSUME_NONNULL_END
