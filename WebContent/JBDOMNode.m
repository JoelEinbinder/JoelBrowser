#import "JBDOMNode.h"
#import <UIKit/UIKit.h>

@implementation JBDOMNode

- (nonnull NSString *)textContent {
    return @"";
}

- (void)setParentElement:(Element *)element {
    _parentElement = element;
}

- (Element *)parentElement {
    return _parentElement;
}

@end

@implementation Element


- (instancetype)initWithTagName:(nonnull NSString *)tagName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    _tagName = tagName;
    _childNodes = [[NSArray alloc] init];
    _attributes = attributeDict;
    return [self init];
}

- (void)append:(nonnull JBDOMNode *)node {
    [node setParentElement:self];
    _childNodes = [_childNodes arrayByAddingObject:node];
}

- (nonnull NSString *)textContent {
    NSMutableString * textContent = [[NSMutableString alloc] init];
    for (JBDOMNode* node in _childNodes)
        [textContent appendString:[node textContent]];
    return textContent;
}

- (nonnull NSArray<JBDOMNode *> *)childNodes {
    return _childNodes;
}
-(NSString*)tagName {
    return _tagName;
}

-(NSDictionary<NSString *,NSString *> *)attributes {
    return _attributes;
}
@end

@implementation TextNode

- (instancetype)initWithText:(NSString *)text {
    _text = text;
    return [self init];
}

- (nonnull NSString *)textContent {
    return _text;
}
- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p> %@", [self class], self, [self textContent]];
}
@end
