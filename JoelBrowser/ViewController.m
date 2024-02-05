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
    _scrollView = [[BEScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_scrollView];
    [self.view sendSubviewToBack:_scrollView];
    [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:@[
        [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTopMargin multiplier:1.0 constant:49.0],
        [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
        [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
        [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]
    ]];
    _network = [self launchChildProcess:@"com.joeleinbinder.JoelBrowser.Networking" clientProtocol:@protocol(NetworkingProtocol) hostProtocol:@protocol(NetworkingProtocolHost)];
    _webContent = [self launchChildProcess:@"com.joeleinbinder.JoelBrowser.WebContent" clientProtocol:@protocol(WebContentProtocol) hostProtocol:@protocol(WebContentProtocolHost)];
    _rendering = [[RenderingProtocolImpl alloc] init];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL* resolved = [NSURL URLWithString:url relativeToURL:[NSURL URLWithString: self->_addressBar.text]];
        
        [self->_network fetchURL:[resolved absoluteString] complete:^(NSData * data) {
            completion(data);
        }];
    });
}

- (void)requestNavigation:(NSString *)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL* resolved = [NSURL URLWithString:url relativeToURL:[NSURL URLWithString: self->_addressBar.text]];
        [self loadURL:[resolved absoluteString]];
    });
}

-(void)webContentTapped: (UITapGestureRecognizer*) recognizer {
    [_addressBar resignFirstResponder];
    CGPoint location = [recognizer locationOfTouch:0 inView:recognizer.view];
    [_webContent tap:location];
}

- (void)requestRepaint:(CommandList *)list {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView* subview in [self->_scrollView subviews])
            [subview removeFromSuperview];
        UIView* webView = [self->_rendering renderCommandList:list];
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webContentTapped:)];
        
        [webView addGestureRecognizer:recognizer];
        [self->_scrollView addSubview:webView];
        [self->_scrollView setContentSize:webView.bounds.size];
    });
}

- (void)showMessageBox:(NSString *)text { 
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:text
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                               }];
        [alert addAction:defaultAction];
        UIViewController *rootViewController = self.view.window.rootViewController;
        [rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

- (void)viewDidLayoutSubviews {
    [_webContent resize:_scrollView.frame.size];
    [super viewDidLayoutSubviews];
}

@end
