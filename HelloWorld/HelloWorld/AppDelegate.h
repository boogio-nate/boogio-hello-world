//
//  AppDelegate.h
//  Boogio
//
//  Created by Nate on 11/27/15.
//  Copyright © 2015 REFLX Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoogioPeripheralNetworkManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

- (BoogioPeripheralNetworkManager *)getBoogioPeripheralNetworkReference;


@property (strong, nonatomic) UIWindow *window;


@end

