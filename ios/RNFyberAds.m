
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
                  customParameters:(NSDictionary *)customParameters
                          callback:(RCTResponseSenderBlock)callback) {
  if ([FYBInterstitial isAvailable:placementId]) {
    FYBShowOptions *options = [FYBShowOptions new];
    options.customParameters = customParameters;
    [FYBInterstitial show:placementId options:options];
  } else {
    callback(@[@"no_interstitial_available"]);
  }
}

RCT_EXPORT_METHOD(fetchRewardedAd:(NSString *)placementId) {
  [FYBRewarded request:placementId]
}
RCT_EXPORT_METHOD(isRewardedAdAvailable:(NSString *)placementId
                                    callback:(RCTResponseSenderBlock)callback) {
  callback(@[[NSNull null],@([FYBRewarded isAvailable:placementId])]);
}
RCT_EXPORT_METHOD(showRewardedAd:(NSString *)placementId
                      customParameters:(NSDictionary *)customParameters
                              callback:(RCTResponseSenderBlock)callback) {
  if ([FYBRewarded isAvailable:placementId]) {
    FYBShowOptions *options = [FYBShowOptions new];
    options.customParameters = customParameters;
    [FYBRewarded show:placementId options:options];
  } else {
    callback(@[@"no_incentivized_ad_available"]);
  }
}

- (NSDictionary *)_impressionDataToDict:(FYBImpressionData)data {
  NSString *priceAccuracy = nil;
  NSString *placementType = nil;

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
    @"advertiserDomain": data.advertiserDomain,
    @"campaignId": data.campaignId,
    @"countryCode": data.countryCode,
    @"creativeId": data.creativeId,
    @"currency": data.currency,
    @"demandSource": data.demandSource,
    @"netPayout": data.netPayout,
    @"networkInstanceId": data.networkInstanceId,
    @"renderingSDK": data.renderingSDK,
    @"renderingSDKVersion": data.renderingSDKVersion,
    @"priceAccuracy": priceAccuracy,
    @"placementType": placementType,
  };
}
//**************** INSTERSTITIAL ****************

- (void)interstitialIsAvailable:(NSString *)placementId {
  [self sendEvent:@"interstitialIsAvailable"
    body:@{ @"placementId": placementId, }];
}

- (void)interstitialIsUnavailable:(NSString *)placementId {
  [self sendEvent:@"interstitialIsUnavailable"
    body:@{ @"placementId": placementId, }];
}

- (void)interstitialDidShow:(NSString *)placementId
             impressionData:(FYBImpressionData *)impressionData {
  [self sendEvent:@"interstitialDidShow"
    body:@{
      @"placementId": placementId,
      @"impressionData": _impressionDataToDict(impressionData),
    }];
}

- (void)interstitialDidFailToShow:(NSString *)placementId
                        withError:(NSError *)error
                   impressionData:(FYBImpressionData *)impressionData {
  [self sendEvent:@"interstitialDidFailToShow"
    body:@{
      @"placementId": placementId,
      @"error": error,
      @"impressionData": _impressionDataToDict(impressionData),
  }];
}

- (void)interstitialDidClick:(NSString *)placementId {
  [self sendEvent:@"interstitialDidClick"
    body:@{ @"placementId": placementId, }];
}

- (void)interstitialDidDismiss:(NSString *)placementId {
  [self sendEvent:@"interstitialDidDismiss"
    body:@{ @"placementId": placementId, }];
}

//**************** REWARDED ****************

- (void)rewardedIsAvailable:(NSString *)placementId {
  [self sendEvent:@"rewardedIsAvailable"
    body:@{ @"placementId": placementId, }];
}

- (void)rewardedIsUnavailable:(NSString *)placementId {
  [self sendEvent:@"rewardedIsUnavailable"
    body:@{ @"placementId": placementId, }];
}

- (void)rewardedDidShow:(NSString *)placementId
         impressionData:(FYBImpressionData *)impressionData {
  [self sendEvent:@"rewardedDidShow"
    body:@{
      @"placementId": placementId,
      @"impressionData": _impressionDataToDict(impressionData),
  }];
}

- (void)rewardedDidFailToShow:(NSString *)placementId
                    withError:(NSError *)error
               impressionData:(FYBImpressionData *)impressionData {
  [self sendEvent:@"rewardedDidFailToShow"
    body:@{
      @"placementId": placementId,
      @"error": error,
      @"impressionData": _impressionDataToDict(impressionData),
  }];
}

- (void)rewardedDidClick:(NSString *)placementId {
  [self sendEvent:@"rewardedDidClick"
    body:@{ @"placementId": placementId, }];
}

- (void)rewardedDidDismiss:(NSString *)placementId {
  [self sendEvent:@"rewardedDidDismiss"
    body:@{ @"placementId": placementId, }];
}

- (void)rewardedDidComplete:(NSString *)placementId
               userRewarded:(BOOL)userRewarded {
  [self sendEvent:@"rewardedDidComplete"
    body:@{
      @"placementId": placementId,
      @"userRewarded": @(userRewarded),
  }];
}

@end
