//
//  LSJAsset.m
//  JazzIT
//
//  Created by Alison Rodrigues Silva on 03/12/14.
//
//
#import "LSJAsset.h"

enum
{
    DirectoryLocationErrorNoPathFound,
    DirectoryLocationErrorFileExistsAtLocation
};

NSString * const DirectoryLocationDomain = @"DirectoryLocationDomain";


@implementation NSFileManager (DirectoryLocations)

//
// findOrCreateDirectory:inDomain:appendPathComponent:error:
//
// Method to tie together the steps of:
//	1) Locate a standard directory by search path and domain mask
//  2) Select the first path in the results
//	3) Append a subdirectory to that path
//	4) Create the directory and intermediate directories if needed
//	5) Handle errors by emitting a proper NSError object
//
// Parameters:
//    searchPathDirectory - the search path passed to NSSearchPathForDirectoriesInDomains
//    domainMask - the domain mask passed to NSSearchPathForDirectoriesInDomains
//    appendComponent - the subdirectory appended
//    errorOut - any error from file operations
//
// returns the path to the directory (if path found and exists), nil otherwise
//
- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut
{
    //
    // Search for the path
    //
    NSArray* paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory, domainMask, YES);
    if ([paths count] == 0)
    {
        if (errorOut)
        {
            NSDictionary *userInfo =
            [NSDictionary dictionaryWithObjectsAndKeys:
             NSLocalizedStringFromTable(
                                        @"No path found for directory in domain.",
                                        @"Errors",
                                        nil),
             NSLocalizedDescriptionKey,
             [NSNumber numberWithInteger:searchPathDirectory],
             @"NSSearchPathDirectory",
             [NSNumber numberWithInteger:domainMask],
             @"NSSearchPathDomainMask",
             nil];
            *errorOut =
            [NSError
             errorWithDomain:DirectoryLocationDomain
             code:DirectoryLocationErrorNoPathFound
             userInfo:userInfo];
        }
        return nil;
    }
    
    //
    // Normally only need the first path returned
    //
    NSString *resolvedPath = [paths objectAtIndex:0];
    
    //
    // Append the extra path component
    //
    if (appendComponent)
    {
        resolvedPath = [resolvedPath stringByAppendingPathComponent:appendComponent];
    }
    
    //
    // Create the path if it doesn't exist
    //
    NSError *error = nil;
    BOOL success = [self
                    createDirectoryAtPath:resolvedPath
                    withIntermediateDirectories:YES
                    attributes:nil
                    error:&error];
    if (!success)
    {
        if (errorOut)
        {
            *errorOut = error;
        }
        return nil;
    }
    
    //
    // If we've made it this far, we have a success
    //
    if (errorOut)
    {
        *errorOut = nil;
    }
    return resolvedPath;
}

//
// applicationSupportDirectory
//
// Returns the path to the applicationSupportDirectory (creating it if it doesn't
// exist).
//
- (NSString *)applicationSupportDirectory
{
    NSString *executableName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSError *error;
    NSString *result =
    [self
     findOrCreateDirectory:NSApplicationSupportDirectory
     inDomain:NSUserDomainMask
     appendPathComponent:executableName
     error:&error];
    if (!result)
    {
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    }
    return result;
}

@end



@interface ArquivoXMLParser()
{
    NSMutableData *_responseData;
    NSXMLParser *_xmlParser;
}
@property NSMutableString *currentXMLValue;
@property NSMutableArray *objetos;
@property NSString *currentElement;
@property NSDictionary *attributes;
@property UIDocumentInteractionController *documentInteractionController;

-(void) escreveArquivo;
-(void) exibeArquivo:(NSString *)path;
@end


@interface LSJAsset(){
    NSURLConnection *currentConnection;
    ArquivoXMLParser *arquivoParser;
}
@property (nonatomic) BOOL isDataSourceAvailable;


- (BOOL) isApplicationSentToBackground;


@end


@implementation ArquivoXMLParser


#pragma mark NSXMLParser Delegate Methods
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //each time part of string is found append it to current string
    [self.currentXMLValue appendString:string];
}

//here you can check when <object> appears in xml and create this object
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName attributes: (NSDictionary *)attributeDict
{
    //each time new element is found reset string
    self.currentXMLValue = [[NSMutableString alloc] init];
    self.currentElement = [[NSString alloc] initWithString:elementName];
    self.attributes = [[NSDictionary alloc] initWithDictionary:attributeDict];
    
}
//this is triggered when there is closing tag </object>, </alias> and so on. Use it to set object's properties. If you get </object> - add object to array.
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"info_anexo"]) {
        NSEnumerator *enumerator = [self.attributes keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) {
            /* code that uses the returned key */
            if([key isEqualToString:@"id"] == YES) {
                self.id = [[self.attributes valueForKey:key] integerValue];
            } else if([key isEqualToString:@"dhInclusao"] == YES) {
                self.dhInclusao = [self.attributes valueForKey:key];
            } else if([key isEqualToString:@"nomeArquivo"] == YES) {
                self.nomeArquivo = [self.attributes valueForKey:key];
            } else if([key isEqualToString:@"urlSite"] == YES) {
                self.urlSite = [self.attributes valueForKey:key];
            } else if([key isEqualToString:@"type"] == YES) {
                self.type = [self.attributes valueForKey:key];
            }
        }
        
        self.attributes = nil;
        self.currentElement = nil;
        self.currentXMLValue = nil;
        
        
        // escrever o arquivo no sistema de arquivos
        [self escreveArquivo];
        
    } else if([elementName isEqualToString:@"arqAnexo"]) {
        self.arqAnexo = [self.currentXMLValue stringByAppendingString:@""];
    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    _xmlParser = [[NSXMLParser alloc]initWithData:_responseData];
    [_xmlParser setDelegate:self];
    [_xmlParser parse];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"Erro ao recuperar arquivo");
}

/*
 * Escreve o arquivo recebido no sistema de arquivos
 */
-(void) escreveArquivo {
    if(self.arqAnexo) {
        NSString *path = [[NSFileManager defaultManager] applicationSupportDirectory];
        
        if (path) {
            path = [path stringByAppendingString:@"/"];
            path = [path stringByAppendingString:self.nomeArquivo];
            
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self.arqAnexo options:0];
//            NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            
            NSFileHandle *filehandle = [NSFileHandle fileHandleForWritingAtPath:path];
            [filehandle seekToEndOfFile];
            [filehandle writeData:decodedData];
            [filehandle closeFile];
            
            [self exibeArquivo:path];
        }
    }
}

-(void) exibeArquivo:(NSString *)path {
    NSURL *targetUrl = [NSURL fileURLWithPath:path];
    
    if (targetUrl) {
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:targetUrl];
        
        self.documentInteractionController.delegate = self;
        
        //self.documentInteractionController.name = @"Title";
        //self.documentInteractionController.UTI = @"com.adobe.pdf";
        [self.documentInteractionController presentOptionsMenuFromRect:CGRectZero
                                                                inView:nil
                                                              animated:YES];
    }
    
}



#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self.viewController;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.viewController.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.viewController.view.frame;
}

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

/*
 * Index argument
 * 0     login usuario
 * 1     senha usuario
 * 2     id da mensagem
 * 3     nome do arquivo
 * 4     tipo do arquivo
 * 5     url chamada arquivo
 */
- (void) retrieveAndShowFile : (CDVInvokedUrlCommand *) command {
    NSString *callbackId = command.callbackId;
    NSArray* arguments = command.arguments;
    NSDictionary *dict = [arguments objectAtIndex:0];
    
    NSString *login = [dict valueForKey:@"usuario"];
    NSString *senha = [dict valueForKey:@"senha"];
    NSNumber *idMensagem = [dict valueForKey:@"idMensagem"];
    NSString *nomeArquivo = [dict valueForKey:@"nomeArquivo"];
    NSString *tipoArquivo = [dict valueForKey:@"type"];
    NSString *myurl = [dict valueForKey:@"url"];
    
    NSString *idMensagemStr = [NSString stringWithFormat:@"%d", [idMensagem intValue]];
    
    myurl = [myurl stringByAppendingString:idMensagemStr];
    myurl = [myurl stringByAppendingString:@"/"];
    myurl = [myurl stringByAppendingString:login];
    
    
    BOOL netAvailable = [self isDataSourceAvailable];
    if(netAvailable == YES) {
        NSURL *url = [NSURL URLWithString:myurl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        if(currentConnection){
            [currentConnection cancel];
            currentConnection = nil;
            arquivoParser = nil;
        }
        
        arquivoParser = [ArquivoXMLParser alloc];
        [arquivoParser setViewController:self.viewController];
        
        
        currentConnection = [[NSURLConnection alloc]initWithRequest:request delegate:arquivoParser];
        
        
//        [NSURLConnection sendAsynchronousRequest:request
//                                           queue:[NSOperationQueue mainQueue]
//                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
//                                   if(data.length > 0 && connectionError == nil) {
//                                       
//                                   }
//                               }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aguarde" message:@"A conexão não está disponível no momento" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
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

- (void) exibirMensagem : (CDVInvokedUrlCommand *) command {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Estou aqui"
                                                    message:@"Estou aqui"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    
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

- (BOOL) isDataSourceAvailable {
    static BOOL checkNetwork = YES;
    if(checkNetwork) {
        checkNetwork = NO;
        Boolean success;
        const char *host_name = "twitter.com"; // your data source host name
        
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
        CFRelease(reachability);
    }
    return _isDataSourceAvailable;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //delete it
    }
}

@end
