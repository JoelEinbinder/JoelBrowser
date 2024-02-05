//
//  ViewController.h
//  JoelBrowser
//
//  Created by Joel Einbinder on 2/5/24.
//

#import <UIKit/UIKit.h>
#import "../Networking/NetworkingProtocol.h"

@interface ViewController : UIViewController <NetworkingProtocolHost> {
    NSObject<NetworkingProtocol>* _network;
}

@property (weak) IBOutlet UITextField* addressBar;

-(IBAction)goToAddressBarURL:(id)sender;

@end

