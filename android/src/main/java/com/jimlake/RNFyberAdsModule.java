package com.jimlake.fyberads;

import javax.annotation.Nullable;
import androidx.annotation.NonNull;

import android.app.Activity;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter;

import com.fyber.FairBid;
import com.fyber.fairbid.user.UserInfo;
import com.fyber.fairbid.ads.ImpressionData;
import com.fyber.fairbid.ads.ImpressionData.PriceAccuracy;
import com.fyber.fairbid.ads.Interstitial;
import com.fyber.fairbid.ads.interstitial.InterstitialListener;
import com.fyber.fairbid.ads.Rewarded;
import com.fyber.fairbid.ads.rewarded.RewardedListener;
import com.fyber.fairbid.ads.PlacementType;

public class RNFyberAdsModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNFyberAdsModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNFyberAds";
  }

  private final InterstitialListener interstitialListener = new InterstitialListener() {
    @Override
    public void onShow(String placementId, ImpressionData impressionData) {
      sendReactEvent("onShow",placementId,impressionData);
    }
    @Override
    public void onClick(String placementId) {
      sendReactEvent("onClick",placementId);
    }
    @Override
    public void onHide(String placementId) {
      sendReactEvent("onHide",placementId);
    }
    @Override
    public void onShowFailure(String placementId, ImpressionData impressionData) {
      sendReactEvent("onShowFailure",placementId,impressionData);
    }
    @Override
    public void onAvailable(String placementId) {
      sendReactEvent("onAvailable",placementId);
    }
    @Override
    public void onUnavailable(String placementId) {
      sendReactEvent("onUnavailable",placementId);
    }
  };
  private final RewardedListener rewardedListener = new RewardedListener() {
    @Override
    public void onShow(String placementId, ImpressionData impressionData) {
      sendReactEvent("onShow",placementId,impressionData);
    }
    @Override
    public void onClick(String placementId) {
      sendReactEvent("onClick",placementId);
    }
    @Override
    public void onHide(String placementId) {
      sendReactEvent("onHide",placementId);
    }
    @Override
    public void onShowFailure(String placementId, ImpressionData impressionData) {
      sendReactEvent("onShowFailure",placementId,impressionData);
    }
    @Override
    public void onAvailable(String placementId) {
      sendReactEvent("onAvailable",placementId);
    }
    @Override
    public void onUnavailable(String placementId) {
      sendReactEvent("onUnavailable",placementId);
    }
    @Override
    public void onCompletion(@NonNull String placementId, boolean userRewarded) {
      sendReactEvent("onCompletion",placementId);
    }
  };

  private void sendReactEvent(final String eventName,final String placementId) {
    final WritableMap params = new WritableNativeMap();
    params.putString("name",eventName);
    params.putString("placementId",placementId);
    sendReactEvent(eventName,params);
  }
  private void sendReactEvent(final String eventName,final String placementId,final ImpressionData impressionData) {
    final WritableMap params = new WritableNativeMap();
    params.putString("name",eventName);
    params.putString("placementId",placementId);

    final WritableMap impressionDataMap = new WritableNativeMap();
    if (impressionData != null) {
      String priceAccuracy = "";
      String placementType = "";
      switch (impressionData.getPriceAccuracy()) {
        case UNDISCLOSED:
          priceAccuracy = "UNDISCLOSED";
          break;
        case PREDICTED:
          priceAccuracy = "PREDICTED";
          break;
        case PROGRAMMATIC:
          priceAccuracy = "PROGRAMMATIC";
          break;
      }

      switch(impressionData.getPlacementType()) {
        case BANNER: {
          placementType = "BANNER";
          break;
        }
        case INTERSTITIAL: {
          placementType = "INTERSTITIAL";
          break;
        }
        case REWARDED: {
          placementType = "REWARDED";
          break;
        }
      }

      impressionDataMap.putString("priceAccuracy",priceAccuracy);
      impressionDataMap.putString("advertiserDomain",impressionData.getAdvertiserDomain());
      impressionDataMap.putDouble("netPayout",impressionData.getNetPayout());
      impressionDataMap.putString("currency",impressionData.getCurrency());
      impressionDataMap.putString("demandSource",impressionData.getDemandSource());
      impressionDataMap.putString("renderingSdk",impressionData.getRenderingSdk());
      impressionDataMap.putString("renderingSdkVersion",impressionData.getRenderingSdkVersion());
      impressionDataMap.putString("networkInstanceId",impressionData.getNetworkInstanceId());
      impressionDataMap.putString("placementType",placementType);
      impressionDataMap.putString("countryCode",impressionData.getCountryCode());
      impressionDataMap.putString("impressionId",impressionData.getImpressionId());
      impressionDataMap.putString("advertiserDomain",impressionData.getAdvertiserDomain());
      impressionDataMap.putString("advertiserDomain",impressionData.getAdvertiserDomain());
      impressionDataMap.putString("creativeId",impressionData.getCreativeId());
      impressionDataMap.putString("campaignId",impressionData.getCampaignId());
    }

    params.putMap("impressionData",impressionDataMap);
    sendReactEvent(eventName,params);
  }

  private void sendReactEvent(final String eventName, @Nullable WritableMap params) {
    if (params == null) {
      params = new WritableNativeMap();
      params.putString("name",eventName);
    }
    getReactApplicationContext()
      .getJSModule(RCTDeviceEventEmitter.class)
      .emit("FyberEvent",params);
  }

  @ReactMethod
  public void initWithAppId(final String appId,final Callback callback) {
    final Activity activity = getCurrentActivity();
    if (activity != null) {
      FairBid.start(appId,activity);
      if (FairBid.hasStarted()) {
        Interstitial.setInterstitialListener(interstitialListener);
        Rewarded.setRewardedListener(rewardedListener);
        callback.invoke((Object)null);
      } else {
        callback.invoke("not_started");
      }
    } else {
        callback.invoke("no_activity");
    }
  }

  @ReactMethod
  public void setUserId(final String userId) {
    UserInfo.setUserId(userId);
  }

  @ReactMethod
  public void presentTestSuite() {
    final Activity activity = getCurrentActivity();
    if (activity != null) {
      FairBid.showTestSuite(activity);
    }
  }

  @ReactMethod
  public void fetchInterstitial(final String placementId,final Callback callback) {
    Interstitial.request(placementId);
    callback.invoke((Object)null);
  }

  @ReactMethod
  public void isInterstitialAvailable(final String placementId,final Callback callback) {
    callback.invoke((Object)null,Interstitial.isAvailable(placementId));
  }

  @ReactMethod
  public void showInterstitial(final String placementId,final Callback callback) {
    if (Interstitial.isAvailable(placementId)) {
      Interstitial.show(placementId,getCurrentActivity());
      callback.invoke((Object)null);
    } else {
      callback.invoke("no_interstitial_ad_available");
    }
  }

  @ReactMethod
  public void fetchRewarded(final String placementId,final Callback callback) {
    Rewarded.request(placementId);
    callback.invoke((Object)null);
  }

  @ReactMethod
  public void isRewardedAdAvailable(final String placementId,final Callback callback) {
    callback.invoke((Object)null,Rewarded.isAvailable(placementId));
  }

  @ReactMethod
  public void showRewardedAd(final String placementId,final Callback callback) {
    if (Rewarded.isAvailable(placementId)) {
      Rewarded.show(placementId,getCurrentActivity());
      callback.invoke((Object)null);
    } else {
      callback.invoke("no_rewarded_ad_available");
    }
  }

}
