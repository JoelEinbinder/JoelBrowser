//
//  ViewController.h
//  JoelBrowser
//
//  Created by Joel Einbinder on 2/5/24.
//

#import <UIKit/UIKit.h>
#import "../Networking/NetworkingProtocol.h"
#import "../WebContent/WebContentProtocol.h"
#import "../Rendering/RenderingProtocol.h"
#import <BrowserEngineKit/BEScrollView.h>

@interface ViewController : UIViewController <NetworkingProtocolHost, WebContentProtocolHost, RenderingProtocolHost> {
    NSObject<NetworkingProtocol>* _network;
    NSObject<WebContentProtocol>* _webContent;
    NSObject<RenderingProtocol>* _rendering;
    BEScrollView* _scrollView;
}

@property (weak) IBOutlet UITextField* addressBar;

-(IBAction)goToAddressBarURL:(id)sender;

@end

