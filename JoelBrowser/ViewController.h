//
//  ViewController.h
//  JoelBrowser
//
//  Created by Joel Einbinder on 2/5/24.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak) IBOutlet UITextField* addressBar;

-(IBAction)goToAddressBarURL:(id)sender;

@end

