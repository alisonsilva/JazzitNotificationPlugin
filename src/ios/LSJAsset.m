//
//  LSJAsset.m
//  JazzIT
//
//  Created by Alison Rodrigues Silva on 03/12/14.
//
//
#import "LSJAsset.h"

@interface LSJAsset()

- (BOOL) isApplicationSentToBackground;


@end

@implementation LSJAsset

- (void) goHome : (CDVInvokedUrlCommand *) command {

    // Create an object with a simple success property.
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             @"true", @"success",
                             nil
                             ];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) goBackground : (CDVInvokedUrlCommand *) command {
    // Create an object with a simple success property.
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             @"true", @"success",
                             nil
                             ];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) retrieveAndShowFile : (CDVInvokedUrlCommand *) command {
    // Create an object with a simple success property.
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             @"true", @"success",
                             nil
                             ];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) storeFile : (CDVInvokedUrlCommand *) command {
    // Create an object with a simple success property.
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             @"true", @"success",
                             nil
                             ];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) openFile : (CDVInvokedUrlCommand *) command {
    // Create an object with a simple success property.
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             @"true", @"success",
                             nil
                             ];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) encrypt : (CDVInvokedUrlCommand *) command {
    // Create an object with a simple success property.
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             @"true", @"success",
                             nil
                             ];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

/*  showMessage arguments:
 * INDEX   ARGUMENT
 *  0       title of the message
 *  1       message body
 *  2       priority
 *  3       eventTime in milliseconds
 *  4       type
 *  5       iconUrl
 */
- (void) showMessage : (CDVInvokedUrlCommand *) command {
    BOOL isInBackground = [self isApplicationSentToBackground];
    
    if(isInBackground == YES) {
        NSString *callbackId = command.callbackId;
        NSArray* arguments = command.arguments;
        
        NSString *iconName = [arguments objectAtIndex: 5];
        NSString *msgTitle = [arguments objectAtIndex:0];
        NSString *msgBody = [arguments objectAtIndex:1];
        NSString *time = [arguments objectAtIndex:3];
        
        NSLog(@"iconName %@", iconName);
        NSLog(@"msgTitle %@", msgTitle);
        NSLog(@"msgBody %@", msgBody);
        NSLog(@"time %@", time);
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        NSDate *now = [NSDate date];
        NSDate *timeToFire = [now dateByAddingTimeInterval:2];
        
        localNotification.fireDate = timeToFire;
        localNotification.alertBody = msgBody;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = 1;
        
        
//        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
//        localNotification.userInfo = infoDict;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    // Create an object with a simple success property.
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             @"true", @"success",
                             nil
                             ];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (BOOL)isApplicationSentToBackground {
    BOOL ret = NO;
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        ret = YES;
    }
    
    return ret;
}

@end
