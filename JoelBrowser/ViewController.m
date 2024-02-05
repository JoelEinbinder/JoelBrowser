//
//  ViewController.m
//  JoelBrowser
//
//  Created by Joel Einbinder on 2/5/24.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadURL:@"https://joel.tools/"];
}

-(void)loadURL:(NSString*)url {
    [_addressBar setText:url];
    NSLog(@"loadURL: %@", url);
}

- (void)goToAddressBarURL:(id)sender __attribute__((ibaction)) {
    [self loadURL:[self addressBar].text];
    [[self addressBar] endEditing:YES];
}


@end
