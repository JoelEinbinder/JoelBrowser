#import "JBDOMNode.h"
#import <UIKit/UIKit.h>
#import "../Rendering/CommandList.h"

@interface TextSpan : NSObject {
    NSString* _text;
    CGPoint _location;
};
@end
@implementation TextSpan

-(instancetype)initWithText:(NSString*)text location:(CGPoint) location {
    _text = text;
    _location = location;
    return [super init];
}
-(NSString*)text {
    return _text;
}
-(CGPoint)location {
    return _location;
}
@end

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

-(CGSize)size {
    return _size;
}

-(UIFont*) font {
    UIFontDescriptor* fontDescriptor = [[UIFontDescriptor alloc] initWithFontAttributes:@{
        UIFontDescriptorFamilyAttribute: [self fontFamily],
        UIFontDescriptorTraitsAttribute: @{
            UIFontWeightTrait: [NSNumber numberWithFloat:[self fontWeight]],
        },
    }];
    return [UIFont fontWithDescriptor:fontDescriptor size:[self fontSize]];
}

-(CGRect) rect {
    return CGRectMake(_origin.x, _origin.y, _size.width, _size.height);
}
-(float) fontSize {
    if ([@"h1" isEqualToString:_tagName])
        return 38.0;
    if (_parentElement)
        return [_parentElement fontSize];
    return 16.0;
}
-(float) fontWeight {
    if ([@"h1" isEqualToString:_tagName])
        return 1.0;
    if ([@"b" isEqualToString:_tagName])
        return 1.0;
    if (_parentElement)
        return [_parentElement fontWeight];
    return 0.0;
}
-(NSString*) fontFamily {
    if ([@"code" isEqualToString:_tagName])
        return @"Menlo";
    if (_parentElement)
        return [_parentElement fontFamily];
    return @"Times New Roman";
}
- (BOOL)isInline {
    if ([@"h1" isEqualToString:_tagName])
        return NO;
    if ([@"br" isEqualToString:_tagName])
        return NO;
    if ([@"li" isEqualToString:_tagName])
        return NO;
    if ([@"ul" isEqualToString:_tagName])
        return NO;
    if ([@"p" isEqualToString:_tagName])
        return NO;
    if ([@"body" isEqualToString:_tagName])
        return NO;
    return YES;
}

-(BOOL) shouldRender {
    if ([_tagName isEqualToString:@"head"])
        return NO;
    if ([_tagName isEqualToString:@"script"])
        return NO;
    if ([_tagName isEqualToString:@"style"])
        return NO;
    return YES;
}
- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p> %@", [self class], self, _tagName];
}

-(UIEdgeInsets) margin {
    if ([@"h1" isEqualToString:_tagName])
        return UIEdgeInsetsMake([self fontSize] * .67, 0.0, [self fontSize] * .67, 0.0);
    if ([@"ul" isEqualToString:_tagName])
        return UIEdgeInsetsMake([self fontSize], 40.0, [self fontSize], 0.0);
    if ([@"body" isEqualToString:_tagName])
        return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    if ([@"p" isEqualToString:_tagName])
        return UIEdgeInsetsMake([self fontSize], 0.0, [self fontSize], 0.0);
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

-(NSDictionary*)textAttributes {
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineHeightMultiple:[self lineHeight]];
    return @{
        NSFontAttributeName: [self font],
        NSParagraphStyleAttributeName: paragraphStyle,
        NSForegroundColorAttributeName: [self currentColor],
        NSUnderlineStyleAttributeName: [NSNumber numberWithUnsignedInteger:[self underline]],
    };
}

-(float)lineHeight {
    if (_parentElement)
        return [_parentElement lineHeight];
    return 1.0;
}

-(void)draw: (CommandList*) list {
    if (![self shouldRender])
        return;
    if ([@"li" isEqualToString:_tagName]) {
        NSString* text = @"• ";
        CGSize size = [text sizeWithAttributes:[self textAttributes]];
        CGPoint point = _origin;
        point.x -= size.width;
        [list drawText: text atPoint:point withAttributes:[self textAttributes]];
    }
    for (TextSpan* textSpan in _textLayout) {
        [list drawText: textSpan.text atPoint:textSpan.location withAttributes:[self textAttributes]];
    }
    for (Element* child in [self children])
        [child draw:list];
}

-(void) layout: (CGRect) container {
    if ([@"br" isEqual:_tagName]) {
        _size.width = 0.0;
        _size.height = 0.0;
        return;
    }
    
    CGSize bounds = CGSizeMake(0.0, 0.0);
    CGPoint point = _origin;
    CGRect innerContainer = container;
    self->_textLayout = @[];
    if (![self isInline]) {
        point.y += [self margin].top;
        point.x += [self margin].left;
        innerContainer.size.width -= self.margin.left + self.margin.right;
        innerContainer.origin.x += self.margin.left;
        innerContainer.size.height -= self.margin.top + self.margin.bottom;
        innerContainer.origin.y += self.margin.top;
    }
    float nextLineY = point.y;
    float collapsibleMargin = 0.0;
    for (JBDOMNode* childNode in _childNodes) {
        if ([childNode isKindOfClass:[Element class]]) {
            Element* child = (Element*)childNode;
            if (![child shouldRender])
                continue;
            if (![child isInline]) {
                point.y = nextLineY;
                point.x = innerContainer.origin.x;
                point.y -= MIN(child.margin.top, collapsibleMargin);
            }
            child->_origin = point;
            [child layout: innerContainer];
            // TODO this is wrong, because it doesn't move the grandchildren of this element.
            // Should switch to a relative coordinate system.
            bounds.width = MAX(bounds.width, point.x + child.size.width - _origin.x);
            bounds.height = MAX(bounds.height, point.y + child.size.height - _origin.y);
            nextLineY = MAX(nextLineY, point.y + child.size.height);
            if ([child isInline]) {
                point.x = child->_origin.x + child->_size.width;
                point.y += child->_size.height - [self font].lineHeight * [self lineHeight];
                collapsibleMargin = 0.0;
            } else {
                point.y = nextLineY;
                collapsibleMargin = child.margin.bottom;
                point.x = innerContainer.origin.x;
            }
        } else {
            NSString* text = [[childNode textContent] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![text length])
                continue;
            CGSize size = [text sizeWithAttributes:[self textAttributes]];
            self->_textLayout = [self->_textLayout arrayByAddingObject:[[TextSpan alloc] initWithText:text location:point]];
            if (point.x < self->_origin.x) {
                bounds.width += self->_origin.x - point.x;
                self->_origin.x = point.x;
            }
            bounds.width = MAX(bounds.width, point.x + size.width - self->_origin.x);
            bounds.height = MAX(bounds.height, point.y + size.height - self->_origin.y);
            nextLineY = MAX(nextLineY, point.y + size.height);
            point.x += size.width;
        }
    }
    bounds.height += [self margin].bottom;
    bounds.width += [self margin].right;
    _size = bounds;
}
-(UIColor*) currentColor {
    if ([@"a" isEqualToString:_tagName] && _attributes[@"href"].length)
        return [UIColor blueColor];
    if (_parentElement)
        return [_parentElement currentColor];
    return [UIColor blackColor];
}
-(NSUnderlineStyle) underline {
    if ([@"a" isEqualToString:_tagName] && _attributes[@"href"].length)
        return NSUnderlineStyleSingle;
    if (_parentElement)
        return [_parentElement underline];
    return NSUnderlineStyleNone;
}
-(NSArray<Element*>*)children {
    return (NSArray<Element*>*)[_childNodes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(JBDOMNode*  evaluatedObject, NSDictionary * bindings) {
        return [evaluatedObject isKindOfClass:[Element class]];
    }]];
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
