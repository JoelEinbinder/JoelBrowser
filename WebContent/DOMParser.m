#import "DOMParser.h"

@implementation DOMParser
-(instancetype)init {
    _elementStack = [[NSMutableArray alloc] init];
    return [super init];
}
- (JBDOMNode*)parse:(NSString *)source {
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:[source dataUsingEncoding:NSUTF8StringEncoding]];
    [parser setDelegate:self];
    BOOL result = [parser parse];
    // Show the source code if we fail to parse
    if (!result) {
        _root = [[Element alloc] initWithTagName:@"#text-document" attributes:@{}];
        [_root append:[[TextNode alloc] initWithText:[source substringToIndex:MIN(30, source.length - 1)]]];
    }
    return _root;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    Element* parent = [_elementStack lastObject];
    Element* element = [[Element alloc] initWithTagName:elementName attributes: attributeDict];
    [parent append:element];
    [_elementStack addObject:element];
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    [_elementStack removeLastObject];
}
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    _root = [[Element alloc] initWithTagName:@"#document" attributes:@{}];
    [_elementStack addObject:_root];
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [_elementStack removeLastObject];
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    TextNode* node = [[TextNode alloc] initWithText:string];
    [[_elementStack lastObject] append:node];
}
@end
