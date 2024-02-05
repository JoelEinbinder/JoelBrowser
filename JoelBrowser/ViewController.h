//
//  ViewController.h
//  JoelBrowser
//
//  Created by Joel Einbinder on 2/5/24.
//

#import <UIKit/UIKit.h>
#import "../Networking/NetworkingProtocol.h"
#import "../WebContent/WebContentProtocol.h"

@interface ViewController : UIViewController <NetworkingProtocolHost, WebContentProtocolHost> {
    NSObject<NetworkingProtocol>* _network;
    NSObject<WebContentProtocol>* _webContent;
}

@property (weak) IBOutlet UITextField* addressBar;

-(IBAction)goToAddressBarURL:(id)sender;

@end

