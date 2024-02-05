//
//  ViewController.m
//  JoelBrowser
//
//  Created by Joel Einbinder on 2/5/24.
//

#import "ViewController.h"

@interface PKHostPlugIn
- (void) beginUsing:(void(^)(void))arg1;
@end

@interface NSExtension : NSObject

+ (instancetype)extensionWithIdentifier:(NSString *)identifier error:(NSError **)error;

- (NSXPCConnection*)_bareExtensionServiceConnection;

- (PKHostPlugIn*)_plugIn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _network = [self launchChildProcess:@"com.joeleinbinder.JoelBrowser.Networking" clientProtocol:@protocol(NetworkingProtocol) hostProtocol:@protocol(NetworkingProtocolHost)];
    _webContent = [self launchChildProcess:@"com.joeleinbinder.JoelBrowser.WebContent" clientProtocol:@protocol(WebContentProtocol) hostProtocol:@protocol(WebContentProtocolHost)];
    [self loadURL:@"https://joel.tools/"];
}

-(void)loadURL:(NSString*)url {
    [_addressBar setText:url];
    [_network fetchURL:url complete:^(NSData * content) {
        [self->_webContent setSource:[[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding]];
    }];
}

- (void)goToAddressBarURL:(id)sender __attribute__((ibaction)) {
    [self loadURL:[self addressBar].text];
    [[self addressBar] endEditing:YES];
}

-(id)launchChildProcess: (NSString*) identifier clientProtocol: (Protocol*) clientProtocol hostProtocol: (Protocol*) hostProtocol {
    NSExtension* extension = [NSExtension extensionWithIdentifier:identifier error:nil];
    NSXPCConnection* connection = [extension _bareExtensionServiceConnection];
    [connection setExportedInterface:[NSXPCInterface interfaceWithProtocol:hostProtocol]];
    [connection setExportedObject:self];
    [connection setRemoteObjectInterface:[NSXPCInterface interfaceWithProtocol:clientProtocol]];
    [[extension _plugIn] beginUsing:^{
        [connection activate];
    }];
    return [connection remoteObjectProxy];
}

- (void)requestData:(NSString *)url completion:(void (^)(NSData *))completion { 
    NSLog(@"Web content requests data: %@", url);
}

- (void)requestNavigation:(NSString *)url { 
    NSLog(@"Web content requests navigation: %@", url);
}

- (void)requestRepaint:(CommandList *)list { 
    NSLog(@"Web content requests repaint: %@", list);
}

- (void)showMessageBox:(NSString *)text { 
    NSLog(@"Web content shows message box: %@", text);
}

@end
