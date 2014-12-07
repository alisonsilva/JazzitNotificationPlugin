//
//  LSJAsset.h
//  JazzIT
//
//  Created by Alison Rodrigues Silva on 03/12/14.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface LSJAsset : CDVPlugin
{}



// exec API
- (void) goHome : (CDVInvokedUrlCommand *) command;
- (void) goBackground : (CDVInvokedUrlCommand *) command;
- (void) retrieveAndShowFile : (CDVInvokedUrlCommand *) command;
- (void) storeFile : (CDVInvokedUrlCommand *) command;
- (void) openFile : (CDVInvokedUrlCommand *) command;
- (void) encrypt : (CDVInvokedUrlCommand *) command;
- (void) showMessage : (CDVInvokedUrlCommand *) command;

@end
