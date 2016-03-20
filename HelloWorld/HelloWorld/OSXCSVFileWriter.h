//
//  BoogioCSVFileWriter.h
//  SynchronizationApp
//
//  Created by Nate on 2/20/16.
//  Copyright © 2016 REFLX Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoogioGlobals.h"

@interface OSXCSVFileWriter : NSObject

- (void)setFileName:(NSString *)file;
- (void)appendLine:(NSString *)line;
- (void)closeFile;

@end
