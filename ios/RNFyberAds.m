
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <FairBidSDK/FairBid.h>

@interface RNFyberAds : RCTEventEmitter <RCTBridgeModule,FYBInterstitialDelegate,FYBRewardedDelegate>

@end

@implementation RNFyberAds
{
  bool _hasListeners;
}

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (void)startObserving {
  _hasListeners = true;
}

- (void)stopObserving {
  _hasListeners = false;
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"FyberEvent"];
}

- (void)sendEvent:(NSString *)name body:(NSDictionary *)body {
  if (_hasListeners && super.bridge != nil) {
    [self sendEventWithName:@"FyberEvent" body:@{@"name": name, @"body": body}];
  }
}

RCT_EXPORT_METHOD(initWithAppId:(NSString *)appId
  callback:(RCTResponseSenderBlock)callback) {

  [FairBid startWithAppId:appId];
  if ([FairBid isStarted]) {
    FYBInterstitial.delegate = self;
    FYBRewarded.delegate = self;
    callback(@[[NSNull null]]);
  } else {
    callback(@[@"start_failed"]);
  }
}
RCT_EXPORT_METHOD(isStarted:(RCTResponseSenderBlock)callback) {
  callback(@[[NSNull null],@([FairBid isStarted])]);
}

RCT_EXPORT_METHOD(setUserId:(NSString *)userId) {
  [FairBid user].userId = userId;
}

RCT_EXPORT_METHOD(presentTestSuite) {
  [FairBid presentTestSuite];
}

RCT_EXPORT_METHOD(isInterstitialAvailable:(NSString *)placementId
                                       callback:(RCTResponseSenderBlock)callback) {
  callback(@[[NSNull null],@([FYBInterstitial isAvailable:placementId])]);
}
RCT_EXPORT_METHOD(fetchInterstitial:(NSString *)placementId) {
  [FYBInterstitial request:placementId];
}
RCT_EXPORT_METHOD(showInterstitial:(NSString *)placementId
                  customParameters:(NSDictionary *)customParameters) {
  FYBShowOptions *options = [FYBShowOptions new];
  options.customParameters = customParameters;
  [FYBInterstitial show:placementId options:options];
}

RCT_EXPORT_METHOD(fetchRewardedAd:(NSString *)placementId) {
  [FYBRewarded request:placementId];
}
RCT_EXPORT_METHOD(isRewardedAdAvailable:(NSString *)placementId
                                    callback:(RCTResponseSenderBlock)callback) {
  callback(@[[NSNull null],@([FYBRewarded isAvailable:placementId])]);
}
RCT_EXPORT_METHOD(showRewardedAd:(NSString *)placementId
                      customParameters:(NSDictionary *)customParameters) {
  FYBShowOptions *options = [FYBShowOptions new];
  options.customParameters = customParameters;
  [FYBRewarded show:placementId options:options];
}

#define DICT_DEFAULT(val,def) val != nil ? val : def

- (NSDictionary *)_impressionDataToDict:(FYBImpressionData *)data {
  NSString *priceAccuracy = @"";
  NSString *placementType = @"";

  switch (data.priceAccuracy) {
    case FYBImpressionDataPriceAccuracyUndisclosed:
      priceAccuracy = @"UNDISCLOSED";
      break;
    case FYBImpressionDataPriceAccuracyPredicted:
      priceAccuracy = @"PREDICTED";
      break;
    case FYBImpressionDataPriceAccuracyProgrammatic:
      priceAccuracy = @"PROGRAMMATIC";
      break;
  }
  switch (data.placementType) {
    case FYBPlacementTypeBanner:
      placementType = @"BANNER";
      break;
    case FYBPlacementTypeInterstitial:
      placementType = @"INTERSTITIAL";
      break;
    case FYBPlacementTypeRewarded:
      placementType = @"REWARDED";
      break;
  }

  return @{
    @"advertiserDomain": DICT_DEFAULT(data.advertiserDomain,[NSNull null]),
    @"campaignId": DICT_DEFAULT(data.campaignId,[NSNull null]),
    @"countryCode": DICT_DEFAULT(data.countryCode,[NSNull null]),
    @"creativeId": DICT_DEFAULT(data.creativeId,[NSNull null]),
    @"currency": DICT_DEFAULT(data.currency,[NSNull null]),
    @"demandSource": DICT_DEFAULT(data.demandSource,[NSNull null]),
    @"netPayout": DICT_DEFAULT(data.netPayout,[NSNull null]),
    @"networkInstanceId": DICT_DEFAULT(data.networkInstanceId,[NSNull null]),
    @"renderingSDK": DICT_DEFAULT(data.renderingSDK,[NSNull null]),
    @"renderingSDKVersion": DICT_DEFAULT(data.renderingSDKVersion,[NSNull null]),
    @"priceAccuracy": priceAccuracy,
    @"placementType": placementType,
  };
}
//**************** INSTERSTITIAL ****************

- (void)interstitialIsAvailable:(NSString *)placementId {
  [self sendEvent:@"available"
    body:@{ @"placementId": placementId, }];
}

- (void)interstitialIsUnavailable:(NSString *)placementId {
  [self sendEvent:@"unavailable"
    body:@{ @"placementId": placementId, }];
}

- (void)interstitialDidShow:(NSString *)placementId
             impressionData:(FYBImpressionData *)impressionData {
  [self sendEvent:@"show"
    body:@{
      @"placementId": placementId,
      @"impressionData": [self _impressionDataToDict:impressionData],
    }];
}

- (void)interstitialDidFailToShow:(NSString *)placementId
                        withError:(NSError *)error
                   impressionData:(FYBImpressionData *)impressionData {
  [self sendEvent:@"showFailure"
    body:@{
      @"placementId": placementId,
      @"error": error,
      @"impressionData": [self _impressionDataToDict:impressionData],
  }];
}

- (void)interstitialDidClick:(NSString *)placementId {
  [self sendEvent:@"click"
    body:@{ @"placementId": placementId, }];
}

- (void)interstitialDidDismiss:(NSString *)placementId {
  [self sendEvent:@"hide"
    body:@{ @"placementId": placementId, }];
}

//**************** REWARDED ****************

- (void)rewardedIsAvailable:(NSString *)placementId {
  [self sendEvent:@"available"
    body:@{ @"placementId": placementId, }];
}

- (void)rewardedIsUnavailable:(NSString *)placementId {
  [self sendEvent:@"unavailable"
    body:@{ @"placementId": placementId, }];
}

- (void)rewardedDidShow:(NSString *)placementId
         impressionData:(FYBImpressionData *)impressionData {
  [self sendEvent:@"show"
    body:@{
      @"placementId": placementId,
      @"impressionData": [self _impressionDataToDict:impressionData],
  }];
}

- (void)rewardedDidFailToShow:(NSString *)placementId
                    withError:(NSError *)error
               impressionData:(FYBImpressionData *)impressionData {
  [self sendEvent:@"showFailure"
    body:@{
      @"placementId": placementId,
      @"error": error,
      @"impressionData": [self _impressionDataToDict:impressionData],
  }];
}

- (void)rewardedDidClick:(NSString *)placementId {
  [self sendEvent:@"click"
    body:@{ @"placementId": placementId, }];
}

- (void)rewardedDidDismiss:(NSString *)placementId {
  [self sendEvent:@"hide"
    body:@{ @"placementId": placementId, }];
}

- (void)rewardedDidComplete:(NSString *)placementId
               userRewarded:(BOOL)userRewarded {
  [self sendEvent:@"completion"
    body:@{
      @"placementId": placementId,
      @"userRewarded": @(userRewarded),
  }];
}

@end
