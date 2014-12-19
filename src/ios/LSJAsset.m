//
//  LSJAsset.m
//  JazzIT
//
//  Created by Alison Rodrigues Silva on 03/12/14.
//
//
#import "LSJAsset.h"


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
@property UIWebView *myWebView;
@property UINavigationBar *myBar;
@property UIActivityIndicatorView *activityIndicator;

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

    if([elementName isEqualToString:@"info_anexo"]) {
        self.attributes = [[NSDictionary alloc] initWithDictionary:attributeDict];
    }
    
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
    [self hideActivity];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var∫
    NSLog(@"Erro ao recuperar arquivo");
    [self hideActivity];
}

/*
 * Escreve o arquivo recebido no sistema de arquivos
 */
-(void) escreveArquivo {
    if(self.arqAnexo) {
        NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = pathArray[0];
        
        if (path) {
            path = [path stringByAppendingPathComponent:@"JazzIT"];
            path = [path stringByAppendingPathComponent:self.nomeArquivo];
            
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self.arqAnexo options:0];

            self.myWebView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 50, self.viewController.view.frame.size.width,self.viewController.view.frame.size.height - 50 )];
            [self.viewController.view addSubview:self.myWebView];
            
            [self.myWebView loadData:decodedData MIMEType:self.type textEncodingName:nil baseURL:nil];
            
            
            self.myBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
            [self.viewController.view addSubview:self.myBar];
            
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                           initWithTitle:@"voltar"
                                           style:UIBarButtonItemStyleDone
                                           target:self
                                           action:@selector(buttonAction)];
            UINavigationItem *itemBackButton = [[UINavigationItem alloc] initWithTitle:@""];
            itemBackButton.leftBarButtonItem = backButton;
            itemBackButton.hidesBackButton = NO;
            [self.myBar pushNavigationItem:itemBackButton animated:NO];
            
            
            
//            NSFileManager *fManager = [NSFileManager defaultManager];
//            NSError *error;
//            if ([fManager fileExistsAtPath:path]) {
//                BOOL success = [fManager removeItemAtPath:path error:&error];
//                if(success) {
//                    NSLog(@"Arquivo removido");
//                } else {
//                    NSLog(@"Erro ao remover arquivo: %@", [error localizedDescription]);
//                }
//            }
//            if([fManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
//                [fManager createFileAtPath:path contents:decodedData attributes:nil];
//                
//                [self exibeArquivo:path];
//            } else {
//                NSLog(@"Erro ao criar diretório: %@", [error localizedDescription]);
//                
//            }
        }
    }
}

-(void)buttonAction{
    NSLog(@"Button sendo clicado");
    [self.myBar removeFromSuperview];
    [self.myWebView removeFromSuperview];
    [self.myWebView stopLoading];
    self.myWebView.delegate = nil;
    self.myBar.delegate = nil;
}

-(void) exibeArquivo:(NSString *)path {
    NSURL *targetUrl = [NSURL fileURLWithPath:path];
    
    if (targetUrl) {
//        NSURLRequest *pdfReq = [[NSURLRequest alloc] initWithURL:targetUrl];
//        [pdfViewer loadRequest:pdfReq];
        
//        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:targetUrl];
//        
//        self.documentInteractionController.delegate = self;
//        
//        self.documentInteractionController.name = @"Title";
//        self.documentInteractionController.UTI = @"com.adobe.pdf";
//        [self.documentInteractionController presentOptionsMenuFromRect:CGRectZero
//                                                                inView:nil
//                                                              animated:YES];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:targetUrl];
        UIWebView *webView = [[UIWebView alloc] initWithFrame: self.viewController.view.frame];
        [self.viewController.view addSubview:webView];
        
        [webView loadRequest:urlRequest];
    }
    
}

-(void)showActivity {
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect activityFrame = CGRectMake(130,100,50,50);
    [self.activityIndicator setFrame:activityFrame];
    self.activityIndicator.layer.cornerRadius = 05;
    self.activityIndicator.opaque = NO;
    self.activityIndicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    self.activityIndicator.center = self.viewController.view.center;
    self.activityIndicator.hidesWhenStopped = TRUE;
    [self.activityIndicator setColor:[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]];
    [self.activityIndicator startAnimating];
    [self.viewController.view addSubview: self.activityIndicator];
}

-(void)hideActivity {
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
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
//    NSString *callbackId = command.callbackId;
    NSArray* arguments = command.arguments;
    NSDictionary *dict = [arguments objectAtIndex:0];
    
    NSString *login = [dict valueForKey:@"usuario"];
//    NSString *senha = [dict valueForKey:@"senha"];
    NSNumber *idMensagem = [dict valueForKey:@"idMensagem"];
//    NSString *nomeArquivo = [dict valueForKey:@"nomeArquivo"];
//    NSString *tipoArquivo = [dict valueForKey:@"type"];
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
        [arquivoParser showActivity];
        
        currentConnection = [[NSURLConnection alloc]initWithRequest:request delegate:arquivoParser];

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
//        NSString *callbackId = command.callbackId;

        NSArray* arguments = command.arguments;
        NSDictionary *dict = [arguments objectAtIndex:1];
    
        NSString *iconName = [dict valueForKey:@"iconUrl"];
        NSString *msgTitle = [dict valueForKey:@"title"];
        NSString *msgBody = [dict valueForKey:@"message"];
        NSString *time = [dict valueForKey:@"eventTime"];
        
        NSLog(@"iconName %@", iconName);
        NSLog(@"msgTitle %@", msgTitle);
        NSLog(@"msgBody %@", msgBody);
        NSLog(@"time %@", time);
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        NSDate *now = [NSDate date];
        NSDate *timeToFire = [now dateByAddingTimeInterval:5];
        
        localNotification.fireDate = timeToFire;
        localNotification.alertBody = msgBody;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = 1;
        
        
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
        localNotification.userInfo = infoDict;
        
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
