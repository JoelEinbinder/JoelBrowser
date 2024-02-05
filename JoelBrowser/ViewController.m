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
    [self loadURL:@"https://joel.tools/"];
}

-(void)loadURL:(NSString*)url {
    [_addressBar setText:url];
    [_network fetchURL:url complete:^(NSData * content) {
        NSLog(@"%@", [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding]);
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

@end
