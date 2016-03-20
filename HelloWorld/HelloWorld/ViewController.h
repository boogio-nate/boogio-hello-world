//
//  ViewController.h
//  BoogioDiagnosticApp
//
//  Created by Nate on 10/21/14.
//  Copyright (c) 2014 Reflx Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoogioPeripheralNetworkManager.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface ViewController : UIViewController <BoogioPeripheralNetworkManagerDelegate, MFMailComposeViewControllerDelegate>


@end

