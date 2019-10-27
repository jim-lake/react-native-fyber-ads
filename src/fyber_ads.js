
import {
  Platform,
  DeviceEventEmitter,
  NativeEventEmitter,
  NativeModules,
} from 'react-native';
import EventEmitter from 'events';

const { RNFyberAds } = NativeModules;

const g_eventEmitter = new EventEmitter();
if (Platform.OS === 'ios') {
  const g_hzEventEmitter = new NativeEventEmitter(RNFyberAds);

  g_hzEventEmitter.addListener('FyberEvent',e => {
    g_eventEmitter.emit(e.name,e.body);
  });
} else {
  DeviceEventEmitter.addListener('FyberEvent',e => {
    g_eventEmitter.emit(e.name,e);
  });
}

function once(event,callback) {
  g_eventEmitter.once(event,callback);
}
function on(event,callback) {
  g_eventEmitter.on(event,callback);
}
function removeListener(event,callback) {
  g_eventEmitter.removeListener(event,callback);
}

function init(appId,done) {
  if (!done) {
    done = function() {};
  }
  RNFyberAds.initWithAppId(appId,done);
}
function setUserId(userId) {
  RNFyberAds.setUserId(setUserId);
}

function getStatus(done) {
  RNFyberAds.isStarted((err,is_started) => {
    done(null,{ isFyberFairBidInitialized: is_started });
  });
}

const showDebugPanel = RNFyberAds.presentTestSuite;
const presentTestSuite = RNFyberAds.presentTestSuite;

function isVideoAvailable() {
  throw new Error("Use Interstitial");
}
function fetchVideo() {
  throw new Error("Use Interstitial");
}
function showVideo() {
  throw new Error("Use Interstitial");
}

function isInterstitialAvailable(placementId,done) {
  RNFyberAds.isInterstitialAvailable(placementId,done);
}
function fetchInterstitial(placementId) {
  RNFyberAds.fetchInterstitial(placementId);
}
function showInterstitial(opts,done) {
  const { placementId, customParameters } = opts;
  RNFyberAds.showInterstitial(placementId,customParameters || {},err => {
    done && done(err);
  });
}

function isRewardedAvailable(placementId,done) {
  RNFyberAds.isRewardedAvailable(placementId,done);
}
function fetchRewardedAd(placementId) {
  RNFyberAds.fetchRewardedAd(placementId);
}
function showRewardedAd(opts,done) {
  const { placementId, customParameters } = opts;
  RNFyberAds.showRewardedAd(placementId,customParameters || {},err => {
    done && done(err);
  });
}

export default {
  once,
  on,
  removeListener,

  init,
  setUserId,
  getStatus,
  showDebugPanel,
  presentTestSuite,

  isVideoAvailable,
  fetchVideo,
  showVideo,

  isInterstitialAvailable,
  fetchInterstitial,
  showInterstitial,

  isRewardedAvailable,
  fetchRewardedAd,
  showRewardedAd,
  isIncentivizedAdAvailable: isRewardedAvailable,
  fetchIncentivizedAd: fetchRewardedAd,
  showIncentivizedAd: showRewardedAd,
};
