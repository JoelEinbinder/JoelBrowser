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
    NSMutableDictionary* style = [[NSMutableDictionary alloc] init];
    if (_attributes[@"style"]) {
        NSString *styleText = _attributes[@"style"];
        NSArray *lines = [styleText componentsSeparatedByString:@";"];
        
        for (NSString *line in lines) {
            NSArray *parts = [line componentsSeparatedByString:@":"];
            if ([parts count] == 2) {
                NSString *property = [parts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *value = [parts[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                style[property] = value;
            }
        }
    }
    _style = style;
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
        return _parentElement.fontSize * 2;
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
    if (_style[@"font-family"]) {
        if ([_style[@"font-family"] isEqualToString:@"sans-serif"])
            return @"Helvetica";
        return _style[@"font-family"];
    }
    if ([@"code" isEqualToString:_tagName])
        return @"Menlo";
    if (_parentElement)
        return [_parentElement fontFamily];
    return @"Times New Roman";
}
- (BOOL)isInline {
    if ([@"block" isEqualToString:_style[@"display"]])
        return NO;
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
    if ([@"html" isEqualToString:_tagName])
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
    if (_style[@"margin"]) {
        // This is a hack because I don't feel like parsing margins
        if ([_style[@"margin"] isEqualToString:@"3em 1em"])
            return UIEdgeInsetsMake(self.fontSize, self.fontSize, self.fontSize, self.fontSize);
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }
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
    if (_style[@"line-height"])
        return [_style[@"line-height"] floatValue];
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

-(NSString*)whiteSpace {
    if (_style[@"white-space"])
        return _style[@"white-space"];
    if (_parentElement)
        return [_parentElement whiteSpace];
    return @"normal";
}

-(NSUInteger)charactersBeforeWrapping:(NSString*)text width:(float)width {
    if ([[self whiteSpace] isEqualToString:@"pre"])
        return text.length;
    NSUInteger low = 0;
    NSUInteger high = text.length;
    while (high > low) {
        NSUInteger index = (1 + high + low) / 2;
        NSUInteger initialIndex = index;
        if (![@"anywhere" isEqualToString:_style[@"overflow-wrap"]]) {
            while (index < text.length && (!index || [text characterAtIndex:index-1] != ' '))
                index++;
        }
        CGSize size = [[text substringToIndex:index] sizeWithAttributes:[self textAttributes]];
        if (size.width > width)
            high = initialIndex - 1;
        else
            low = index;
    }
    return low;
}

-(void) layout: (CGRect) container {
    if ([@"br" isEqual:_tagName]) {
        _size.width = 0.0;
        _size.height = 0.0;
        _lastTextX = _origin.x + _size.width;
        _hasTrailingWhiteSpace = YES;
        return;
    }
    
    __block CGSize bounds = CGSizeMake(0.0, 0.0);
    __block CGPoint point = _origin;
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
    __block float nextLineY = point.y;
    float collapsibleMargin = 0.0;
    __block NSMutableString* currentText = [[NSMutableString alloc] init];
    void (^flushTextSpan)(void) = ^(void) {
        while(currentText.length) {
            NSUInteger index = [self charactersBeforeWrapping:currentText width:innerContainer.size.width - point.x];
            NSString* slice = [currentText substringToIndex:index];
            if (!slice) {
                point.y = nextLineY;
                point.x = innerContainer.origin.x;
                continue;
            }
            CGSize size = [slice sizeWithAttributes:[self textAttributes]];
            self->_hasTrailingWhiteSpace = [slice length] && [slice characterAtIndex:slice.length - 1] == ' ';
            self->_textLayout = [self->_textLayout arrayByAddingObject:[[TextSpan alloc] initWithText:slice location:point]];
            if (point.x < self->_origin.x) {
                bounds.width += self->_origin.x - point.x;
                self->_origin.x = point.x;
            }
            bounds.width = MAX(bounds.width, point.x + size.width - self->_origin.x);
            bounds.height = MAX(bounds.height, point.y + size.height - self->_origin.y);
            nextLineY = MAX(nextLineY, point.y + size.height);
            [currentText deleteCharactersInRange:NSMakeRange(0, slice.length)];
            point.x += size.width;
            if (currentText.length) {
                point.y = nextLineY;
                point.x = innerContainer.origin.x;
            }
        }
    };
    for (JBDOMNode* childNode in _childNodes) {
        if ([childNode isKindOfClass:[Element class]]) {
            flushTextSpan();
            Element* child = (Element*)childNode;
            if (![child shouldRender])
                continue;
            if (![child isInline]) {
                point.y = nextLineY;
                point.x = innerContainer.origin.x;
                point.y -= MIN(child.margin.top, collapsibleMargin);
            }
            child->_origin = point;
            child->_hasTrailingWhiteSpace = _hasTrailingWhiteSpace;
            [child layout: innerContainer];
            // TODO this is wrong, because it doesn't move the grandchildren of this element.
            // Should switch to a relative coordinate system.
            if (![child isInline] && [child->_style[@"margin"] isEqualToString: @"auto"]) {
                child->_origin.x += (innerContainer.size.width - child->_size.width) / 2.0f;
            }
            _hasTrailingWhiteSpace = child->_hasTrailingWhiteSpace;
            bounds.width = MAX(bounds.width, point.x + child.size.width - _origin.x);
            bounds.height = MAX(bounds.height, point.y + child.size.height - _origin.y);
            nextLineY = MAX(nextLineY, point.y + child.size.height);
            if ([child isInline]) {
                point.x = child->_lastTextX;
                point.y += child->_size.height - [self font].lineHeight * [self lineHeight];
                collapsibleMargin = 0.0;
            } else {
                point.y = nextLineY;
                collapsibleMargin = child.margin.bottom;
                point.x = innerContainer.origin.x;
                _hasTrailingWhiteSpace = YES;
            }
        } else {
            NSString* text = [childNode textContent];
            if ([[self whiteSpace] isEqualToString:@"normal"]) {
                for (NSUInteger i = 0; i < text.length; i++) {
                    unichar c = [text characterAtIndex:i];
                    if (c == ' ' || c == '\n' || c == '\t') {
                        if (currentText.length) {
                            if ([currentText characterAtIndex:currentText.length - 1] != ' ')
                                [currentText appendString:@" "];
                        } else if (!_hasTrailingWhiteSpace) {
                            [currentText appendString:@" "];
                        }
                    } else {
                        [currentText appendFormat:@"%c", c];
                    }
                }
            } else {
                [currentText appendString: text];
            }
        }
    }
    flushTextSpan();
    _lastTextX = point.x;
    bounds.height += [self margin].bottom;
    bounds.width += [self margin].right;
    _size = bounds;
}
+(UIColor*) colorFromHexString: (NSString*) hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];

}
-(UIColor*) currentColor {
    if (_style[@"color"]) {
        NSString* hexString = @{
            @"red": @"#FF0000"
        }[_style[@"color"]];
        if (!hexString)
            hexString = _style[@"color"];
        return [Element colorFromHexString:hexString];
    }
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
- (nullable Element *)hitTest:(CGPoint)point {
    if (!CGRectContainsPoint([self rect], point))
        return nil;
    for (Element* child in [self children]) {
        Element* result = [child hitTest:point];
        if (result)
            return result;
    }
    return self;
}
-(void)tap: (NSObject<WebContentProtocolHost>*) sender {
    if ([@"a" isEqualToString:_tagName] && _attributes[@"href"].length) {
        [sender requestNavigation:_attributes[@"href"]];
        return;
    }
    [_parentElement tap: sender];
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
