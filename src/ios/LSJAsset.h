//
//  LSJAsset.h
//  JazzIT
//
//  Created by Alison Rodrigues Silva on 03/12/14.
//
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <Cordova/CDVPlugin.h>


//
// DirectoryLocations is a set of global methods for finding the fixed location
// directoriess.
//
@interface NSFileManager (DirectoryLocations)

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut;
- (NSString *)applicationSupportDirectory;

@end


@interface ArquivoXMLParser : NSObject<NSXMLParserDelegate, NSURLConnectionDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic) NSInteger codigo;
@property (nonatomic) NSString *mensagem;
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *nomeArquivo;
@property (nonatomic) NSString *dhInclusao;
@property (nonatomic) NSString *urlSite;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *arqAnexo;
@property (nonatomic) UIViewController *viewController;

@end

@interface LSJAsset : CDVPlugin <UIAlertViewDelegate>
{}



// exec API
- (void) goHome : (CDVInvokedUrlCommand *) command;
- (void) goBackground : (CDVInvokedUrlCommand *) command;
- (void) retrieveAndShowFile : (CDVInvokedUrlCommand *) command;
- (void) storeFile : (CDVInvokedUrlCommand *) command;
- (void) openFile : (CDVInvokedUrlCommand *) command;
- (void) encrypt : (CDVInvokedUrlCommand *) command;
- (void) showMessage : (CDVInvokedUrlCommand *) command;
- (void) exibirMensagem : (CDVInvokedUrlCommand *) command;

@end
