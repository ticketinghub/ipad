//
//  HeftClient.h
//  headstart
//

/**
 *  @file   HeftClient.h
 *
 *  @brief  Heft protocol
 *
 *
 */

/**
 @brief param values for HeftClient -(BOOL)logSetLevel:(eLogLevel)level.
 */
typedef enum{
	eLogNone
	, eLogInfo
	, eLogFull
	, eLogDebug
} eLogLevel;

/** 
@brief HeftClient protocol methods.
 */
@protocol HeftClient<NSObject>
/** @defgroup HC_DELEGATE HeftClient Methods
 High level interface for Headstart API.
 @{
 */

//- (void)setDelegate:(NSObject<HeftClientDelegate>*)aDelegate;

/**
 Cancels current operation if it's possible.
 That is financial transaction or scanner mode. 
 */
- (void)cancel;

/** 
 Performs SALE transaction.
 @param amount - The amount - in the smallest unit for the given CurrencyCode -
 for the transaction. ISO 4217 defines number of digits in
 fractional part of currency for every currency code. Example
 1000 in the case where CurrencyCode is "0826" (GBP) the amount
 would be 10.00 pounds or 1000 pense.
 @param currency - The currency to use for the transaction. Code is four
 characters string containing ISO 4217 numeric value with
 leading zero(s). Examples: GPB = "0826", USD = "0840", EUR = "0978".
 There are three special cases for "USD", "EUR" and "GBP"
 which can be set instead of numeric values.
 @param present	Indicates whether the cardholder is present or not during the transaction.
 @param reference An optional reference id (max 25 characters) that can be associated with the authorization. Example value: 45678135.
 @param months Budget facility indicator. Decides how many months a payment can be divided into. Is required for budget transactions. Accepted values are:  03, 06, 12, 18, 24, 30, 36, 42, 48, 54, 60 
 @return YES if request is sent and NO if there is active transaction already.
 */
- (BOOL)saleWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present reference:(NSString*)reference divideBy:(NSString*)months;
- (BOOL)saleWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present reference:(NSString*)reference;
- (BOOL)saleWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present;

/** 
 Performs REFUND transaction.
 @param amount - The amount - in the smallest unit for the given CurrencyCode -
 for the transaction. ISO 4217 defines number of digits in
 fractional part of currency for every currency code. Example
 1000 in the case where CurrencyCode is "0826" (GBP) the amount
 would be 10.00 pounds or 1000 pense.
 @param currency - The currency to use for the transaction. Code is four
 characters string containing ISO 4217 numeric value with
 leading zero(s). Examples: GPB = "0826", USD = "0840", EUR = "0978".
 There are three special cases for "USD", "EUR" and "GBP"
 which can be set instead of numeric values.
 @param present - Indicates whether the cardholder is present or not during the transaction.
 @param reference An optional reference id (max 25 characters) that can be associated with the authorization. Example value: 45678135.
 @return YES if request is sent and NO if there is active transaction already.
 */
- (BOOL)refundWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present reference:(NSString*)reference;
- (BOOL)refundWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present;

/**
 Voids SALE transaction.
 @param amount - The amount - in the smallest unit for the given CurrencyCode -
 for the transaction. ISO 4217 defines number of digits in
 fractional part of currency for every currency code. Example
 1000 in the case where CurrencyCode is "0826" (GBP) the amount
 would be 10.00 pounds or 1000 pense.
 @param currency - The currency to use for the transaction. Code is four
 characters string containing ISO 4217 numeric value with
 leading zero(s). Examples: GPB = "0826", USD = "0840", EUR = "0978".
 There are three special cases for "USD", "EUR" and "GBP"
 which can be set instead of numeric values.
 @param present - Indicates whether the cardholder is present or not during the transaction.
 @param transaction - The id of transaction to void.
 @return YES if request is sent and NO if there is active transaction already.
 */
- (BOOL)saleVoidWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present transaction:(NSString*)transaction;

/**
 Voids REFUND transaction.
 @param amount - The amount - in the smallest unit for the given CurrencyCode -
 for the transaction. ISO 4217 defines number of digits in
 fractional part of currency for every currency code. Example
 1000 in the case where CurrencyCode is "0826" (GBP) the amount
 would be 10.00 pounds or 1000 pense.
 @param currency - The currency to use for the transaction. Code is four
 characters string containing ISO 4217 numeric value with
 leading zero(s). Examples: GPB = "0826", USD = "0840", EUR = "0978".
 There are three special cases for "USD", "EUR" and "GBP"
 which can be set instead of numeric values.
 @param present - Indicates whether the cardholder is present or not during the transaction.
 @param transaction - The id of transaction to void.
 @return YES if request is sent and NO if there is active transaction already.
 */
- (BOOL)refundVoidWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present transaction:(NSString*)transaction;

/**
 Places the card reader in a scan only mode.
 *The card reader then waits for the scan button(s) to be pressed and once detected will activate the scanner hardware.
 *When a scanned code is detected the card reader will emit scan event notifications back to the caller, which the caller application can catch and display to the operator.
 *To cancel scan mode call cancel.
 *Scan mode is automatically disabled after a period of inactivity, on the card reader.
 @param multiScan      true - [default] multiple scan codes can be scanned, resulting in multiple scan events. Scan mode must be esplicitly cancelled.
 *                      false - scan mode will be disabled as soon as one barcode has been detected
 @param buttonMode true - [default] The operator needs to press the scan buttons to activate the scanner (during scan mode).
 *                      false - The scanner will be turned on immediately and kept on for the duration of the scan mode.
 @param timeoutSeconds         0 - [default] The card reader will determine when scanning should time out.
 *                      x - The scanner will time out if x seconds of inactivity occur.
 @return YES if request is sent and No if there is already an active operation running. 
 */
-(BOOL)enableScanner:(BOOL)multiScan buttonMode:(BOOL)buttonMode timeoutSeconds:(NSInteger)timeoutSeconds;
-(BOOL)enableScanner:(BOOL)multiScan buttonMode:(BOOL)buttonMode;
-(BOOL)enableScanner:(BOOL)multiScan;
-(BOOL)enableScanner;

/**
 Performs start of the day request.
 @return YES if request is sent and NO if there is active transaction already.
 */
- (BOOL)financeStartOfDay;

/**
 Performs end of the day request.
 @return YES if request is sent and NO if there is active transaction already.
 */
- (BOOL)financeEndOfDay;

/**
 Performs financial initialization request.
 @return YES if request is sent and NO if there is active transaction already.
 */

- (BOOL)financeInit;

/**
 Set log level for device.
 @return YES if request is sent and NO if there is active transaction already.
 */
- (BOOL)logSetLevel:(eLogLevel)level;

/**
 Reset logging on device.
 @return YES if request is sent and NO if there is active transaction already.
 */
- (BOOL)logReset;

/**
 Performs get log info request.
 @return YES if request is sent and NO if there is active transaction already.
 */
- (BOOL)logGetInfo;

/**
 Indicates information about signature.
 @param flag - Shows signature  was accepted or not.
 */
- (void)acceptSignature:(BOOL)flag;

/**
 Dictionary with MPED info details, obtained by querying it from device on interface creation.
 */
@property(nonatomic, readonly) NSDictionary* mpedInfo;

/**@}*/

@end

/** @defgroup CD_MODULE Characteristics of the Device
 Characteristics of the device from mpedInfo dictionary like serial number, manufacturer code, etc.
 @{
 */
/**
 Serial Number.
 */
extern const NSString* kSerialNumberInfoKey;
/** 
 Public Key Version.
 */
extern const NSString* kPublicKeyVersionInfoKey;
/** 
 EMV Parameter Version.
 */
extern const NSString* kEMVParamVersionInfoKey;
/** 
 General Parameter.
 */
extern const NSString* kGeneralParamInfoKey;
/** 
 Manufacturer Code.
 */
extern const NSString* kManufacturerCodeInfoKey;
/** 
 Model Code.*/
extern const NSString* kModelCodeInfoKey;
/** 
 Application Name.
 */
extern const NSString* kAppNameInfoKey;
/** 
 Application Version.
 */
extern const NSString* kAppVersionInfoKey;
/** 
 XML Details.
 */
extern const NSString* kXMLDetailsInfoKey;

/**@}*/