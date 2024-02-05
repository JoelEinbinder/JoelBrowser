#import "VBScript.h"
#import "WebContentProtocol.h"
@implementation VBScript
-(void)runScript: (NSString*) source host:(NSObject<WebContentProtocolHost>*) host {
    [source enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        NSString* trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        BOOL inQuotes = NO;
        NSMutableString* currentToken = [[NSMutableString alloc] init];
        NSArray<NSString*>* tokens = @[];
        for (NSUInteger i = 0; i < [trimmed length]; i++) {
            unichar character = [trimmed characterAtIndex:i];
            if (inQuotes) {
                if (character == '"') {
                   inQuotes = NO;
               }
            } else {
                if (character == ' ') {
                    if ([currentToken length] > 0)
                        tokens = [tokens arrayByAddingObject:currentToken];
                    currentToken = [[NSMutableString alloc] init];
                    continue;
                } else if (character == '"') {
                    inQuotes = YES;
                }
            }
            [currentToken appendFormat:@"%C", character];
        }
        if ([currentToken length] > 0)
            tokens = [tokens arrayByAddingObject:currentToken];
        NSString* command = tokens.count > 0 ? tokens[0] : nil;
        if ([command isEqualToString:@"MsgBox"]) {
            NSString* message = tokens.count > 1 ? [NSJSONSerialization JSONObjectWithData:[tokens[1] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil] : @"";
            [host showMessageBox:message];
        } else if (command) {
            NSLog(@"Unexpected command: %@", command);
        }

    }];
}
@end
