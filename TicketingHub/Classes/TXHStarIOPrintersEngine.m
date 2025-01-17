
//
//  TXHStarIOPrintersEngine.m
//  TicketingHub
//
//  Created by Bartek Hugo Trzcinski on 26/03/14.
//  Copyright (c) 2014 TicketingHub. All rights reserved.
//

#import "TXHStarIOPrintersEngine.h"
#import "TXHStarIOPrinter.h"


#import "NSError+TXHPrinters.h"
#import <UIImage+PDF/UIImage+PDF.h>
#import "UIImage+ImageEffects.h"

#import "RasterDocument.h"
#import "StarBitmap.h"
#import <sys/time.h>
#import <unistd.h>

static NSString * const kPrinterPortSettingsPortable    = @"mini";
static NSString * const kPrinterPortSettingsPOS         = @"";

#define STAR_PRINTER_MAXWIDTH                           576

@implementation TXHStarIOPrintersEngine

#pragma mark - TXHPrintersEngineProtocol

- (void)fetchAvailablePrinters:(void(^)(NSArray *printers, NSError *error))completion
{
    if (!completion) return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *printers = [SMPort searchPrinter:@"BT:"];
        NSMutableArray *starPrinters = @[].mutableCopy;
        
        for (PortInfo *portInfo in printers)
        {
            TXHStarIOPrinter *printer = [[TXHStarIOPrinter alloc] initWithPrintersEngine:self andPortInfo:portInfo];
            [starPrinters addObject:printer];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([starPrinters copy], nil);
        });
    });
}

/**
 * Prints given pdf document
 * if provided printer has
 *
 *
 */
- (void)printPDFDocumentWithURL:(NSURL *)documentURL
                    withPrinter:(TXHPrinter *)printer
                completionBlock:(TXHPrinterCompletionBlock)completionBlock
{
    if (!printer)
    {
        if (completionBlock)
            completionBlock([NSError printerErrorWithCode:kTXHPrinterArgsInconsistencyError],YES);

        return;
    }
    
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)documentURL);
        size_t pageCount = CGPDFDocumentGetNumberOfPages(pdf);
        CGPDFDocumentRelease(pdf);
        
        __block BOOL printAllPages = (printer.printingContinue == nil);
        
        for (int page = 0; page < pageCount; page++)
        {
            __block BOOL printNextPage = YES;
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            void(^askToContinueBlock)(NSError *error) =
            
            ^(NSError *error) {
                
                if (!printAllPages && page + 1 < pageCount)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        printer.printingContinue(^(BOOL continuePrinting, BOOL printAll)
                                                 {
                                                     printAllPages = printAll;
                                                     printNextPage = continuePrinting;
                                                     dispatch_semaphore_signal(semaphore);
                                                 });
                    });
                else
                    dispatch_semaphore_signal(semaphore);
                
            };
            
            [wself printPage:page+1
                formDocument:documentURL
                 withPrinter:printer
             completionBlock:askToContinueBlock];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            if (!printNextPage)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock)
                        completionBlock(nil, YES);
                });
                return;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock)
                completionBlock(nil, NO);
        });
    });
}

- (void)printPage:(int)page formDocument:(NSURL *)documentURL withPrinter:(TXHPrinter *)printer completionBlock:(void(^)(NSError *error))completion
{
    UIImage *img = [UIImage imageWithPDFURL:documentURL atWidth:STAR_PRINTER_MAXWIDTH atPage:page];
    img = [img imageWithBackground:[UIColor whiteColor]];
    [self printImg:img withPrinter:printer completionBlock:completion];
}

- (void)printImg:(UIImage *)image withPrinter:(TXHPrinter *)printer completionBlock:(void(^)(NSError *error))completion
{
    TXHStarIOPrinter *starPrinter = (TXHStarIOPrinter *)printer;
    if (starPrinter.printerType == TXHStarPortablePrinterTypePortable)
    {
        [self printBitmapWithPortName:starPrinter.portInfo.portName
                         portSettings:kPrinterPortSettingsPortable
                          imageSource:image
                         printerWidth:STAR_PRINTER_MAXWIDTH
                    compressionEnable:YES
                       pageModeEnable:NO
                           completion:completion];
    }
    else if (starPrinter.printerType == TXHStarPortablePrinterTypePOS)
    {
        [self printImageWithPortname:starPrinter.portInfo.portName
                        portSettings:kPrinterPortSettingsPOS
                        imageToPrint:image
                            maxWidth:STAR_PRINTER_MAXWIDTH
                   compressionEnable:YES
                          completion:completion];
    }
}

- (void)printImgs:(NSArray *)images withPrinter:(TXHPrinter *)printer completionBlock:(void(^)(NSError *error))completion
{
    TXHStarIOPrinter *starPrinter = (TXHStarIOPrinter *)printer;
    if (starPrinter.printerType == TXHStarPortablePrinterTypePortable)
    {
        [self printBitmapsWithPortName:starPrinter.portInfo.portName
                         portSettings:kPrinterPortSettingsPortable
                          images:images
                         printerWidth:STAR_PRINTER_MAXWIDTH
                    compressionEnable:YES
                       pageModeEnable:NO
                           completion:completion];
    }
    else if (starPrinter.printerType == TXHStarPortablePrinterTypePOS)
    {
        [self printImagesWithPortname:starPrinter.portInfo.portName
                        portSettings:kPrinterPortSettingsPOS
                        imagesToPrint:images
                            maxWidth:STAR_PRINTER_MAXWIDTH
                   compressionEnable:YES
                          completion:completion];
    }
}

- (void)printImageWithURL:(NSURL *)url withPrinter:(TXHPrinter *)printer completionBlock:(TXHPrinterCompletionBlock)completion
{
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    [self printImg:image withPrinter:printer completionBlock:^(NSError *error) {
        if (completion) completion(error,NO);
    }];
}

- (void)printImagesWithURLs:(NSArray *)urls
                withPrinter:(TXHPrinter *)printer
            completionBlock:(TXHPrinterCompletionBlock)completion
{
    NSMutableArray *images = [NSMutableArray array];
    for (NSURL *url in urls)
    {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        [images addObject:image];
    }
    
    [self printImgs:images withPrinter:printer completionBlock:^(NSError *error) {
        if (completion) completion(error,NO);
    }];
}

- (void)openDrawerFromPrinter:(TXHPrinter *)printer
                   completion:(TXHPrinterCompletionBlock)completion
{
    TXHStarIOPrinter *starPrinter = (TXHStarIOPrinter *)printer;

    if (starPrinter.printerType == TXHStarPortablePrinterTypePOS)
    {
        [self openCashDrawerWithPortname:starPrinter.portInfo.portName
                            portSettings:kPrinterPortSettingsPOS
                            drawerNumber:1
                              completion:^(NSError *error) {
                                  if (completion)
                                      completion(error, NO);
                              }];
    }
    else if (completion)
    {
        completion([NSError printerErrorWithCode:kTXHPrinterWrongPrinterError],YES);
    }
}


#pragma mark - POS printers

- (void)printImageWithPortname:(NSString *)portName portSettings:(NSString*)portSettings imageToPrint:(UIImage*)imageToPrint maxWidth:(int)maxWidth compressionEnable:(BOOL)compressionEnable completion:(void(^)(NSError *error))completion
{
    NSMutableData *commandsToPrint = [[NSMutableData alloc] init];
    
    if (imageToPrint)
    {
        RasterDocument *rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium
                                                          endOfPageBehaviour:RasPageEndMode_FeedAndFullCut
                                                      endOfDocumentBahaviour:RasPageEndMode_FeedAndFullCut
                                                                   topMargin:RasTopMargin_Standard
                                                                  pageLength:0
                                                                  leftMargin:0
                                                                 rightMargin:0];
        
        StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:imageToPrint :maxWidth :false];
        
        
        NSData *shortcommand = [rasterDoc BeginDocumentCommandData];
        [commandsToPrint appendData:shortcommand];
        
        shortcommand = [starbitmap getImageDataForPrinting:compressionEnable];
        [commandsToPrint appendData:shortcommand];
        
        shortcommand = [rasterDoc EndDocumentCommandData];
        [commandsToPrint appendData:shortcommand];
    }
    
    [self sendCommand:commandsToPrint portName:portName portSettings:portSettings timeoutMillis:10000 completion:completion];
}

- (void)printImagesWithPortname:(NSString *)portName portSettings:(NSString*)portSettings imagesToPrint:(NSArray*)imagesToPrint maxWidth:(int)maxWidth compressionEnable:(BOOL)compressionEnable completion:(void(^)(NSError *error))completion
{
    if (![imagesToPrint count]) return;
    
    NSMutableData *commandsToPrint = [[NSMutableData alloc] init];

    RasterDocument *rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium
                                                      endOfPageBehaviour:RasPageEndMode_FeedAndFullCut
                                                  endOfDocumentBahaviour:RasPageEndMode_FeedAndFullCut
                                                               topMargin:RasTopMargin_Standard
                                                              pageLength:0
                                                              leftMargin:0
                                                             rightMargin:0];
    
    NSData *shortcommand = [rasterDoc BeginDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    for (UIImage *image in imagesToPrint)
    {

        StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:image :maxWidth :false];
    
        shortcommand = [starbitmap getImageDataForPrinting:compressionEnable];
        [commandsToPrint appendData:shortcommand];
        
        
        [commandsToPrint appendData:[rasterDoc PageBreakCommandData]];
    }
    
    shortcommand = [rasterDoc EndDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    [self sendCommand:commandsToPrint portName:portName portSettings:portSettings timeoutMillis:10000 completion:completion];
}

- (void)openCashDrawerWithPortname:(NSString *)portName portSettings:(NSString *)portSettings drawerNumber:(NSUInteger)drawerNumber completion:(void(^)(NSError *error))completion
{
    unsigned char opencashdrawer_command = 0x00;
    
    if (drawerNumber == 1) {
        opencashdrawer_command = 0x07; //BEL
    }
    else if (drawerNumber == 2) {
        opencashdrawer_command = 0x1a; //SUB
    }
    
    NSData *commands = [NSData dataWithBytes:&opencashdrawer_command length:1];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000 completion:completion];
}

#pragma mark - portable printer

- (void)printBitmapWithPortName:(NSString*)portName portSettings:(NSString*)portSettings imageSource:(UIImage*)source printerWidth:(int)maxWidth compressionEnable:(BOOL)compressionEnable pageModeEnable:(BOOL)pageModeEnable completion:(void(^)(NSError *error))completion
{
    StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:source :maxWidth :false];
    NSData *commands = [starbitmap getImageMiniDataForPrinting:compressionEnable pageModeEnable:pageModeEnable];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000 completion:completion];
}

- (void)printBitmapsWithPortName:(NSString*)portName portSettings:(NSString*)portSettings images:(NSArray*)images printerWidth:(int)maxWidth compressionEnable:(BOOL)compressionEnable pageModeEnable:(BOOL)pageModeEnable completion:(void(^)(NSError *error))completion
{
    NSMutableData *commandsToPrint = [[NSMutableData alloc] init];
    for (UIImage *image in images)
    {
        StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:image :maxWidth :false];
        NSData *commands = [starbitmap getImageMiniDataForPrinting:compressionEnable pageModeEnable:pageModeEnable];
        
        [commandsToPrint appendData:commands];
    }
    
    [self sendCommand:commandsToPrint portName:portName portSettings:portSettings timeoutMillis:10000 completion:completion];
}

#pragma mark - Printer Communication

- (void)sendCommand:(NSData *)commandsToPrint portName:(NSString *)portName portSettings:(NSString *)portSettings timeoutMillis:(u_int32_t)timeoutMillis completion:(void(^)(NSError *error))completion
{
    int commandSize = (int)[commandsToPrint length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commandsToPrint getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    NSError *error = nil;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :timeoutMillis];
        if (starPort == nil)
        {
            
            error = [NSError printerErrorWithCode:kTXHPrinterFailToOpenPortError];
            return;
        }
        
        StarPrinterStatus_2 status;
        [starPort beginCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            error = [NSError printerErrorWithCode:kTXHPrinterOfflineError];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :remaining];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        if (totalAmountWritten < commandSize)
        {
            error = [NSError printerErrorWithCode:kTXHPrinterTimedOutError];
            return;

        }
        
        starPort.endCheckedBlockTimeoutMillis = 30000;
        [starPort endCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            error = [NSError printerErrorWithCode:kTXHPrinterOfflineError];
            return;
        }
    }
    @catch (PortException *exception)
    {
        error = [NSError printerErrorWithCode:kTXHPrinterTimedOutError];
        return;

    }
    @finally
    {
        free(dataToSentToPrinter);
        [SMPort releasePort:starPort];

        if (completion)
            completion(error);
        
        return;
    }
}

@end
