'use strict';

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

function init(publisherId,done) {
  if (!done) {
    done = function() {};
  }
  RNFyberAds.initWithPublisherID(publisherId,done);
}

const getStatus = RNFyberAds.getStatus;
const showDebugPanel = RNFyberAds.showDebugPanel;

const isInterstitialAvailable = RNFyberAds.isInterstitialAvailable;
const isVideoAvailable = RNFyberAds.isVideoAvailable;
const isIncentivizedAdAvailable = RNFyberAds.isIncentivizedAdAvailable;

function wrapMethod(method) {
  return (done) => {
    if (!done) {
      done = function() {};
    }
    method(done);
  }
}

const fetchInterstitial = wrapMethod(RNFyberAds.fetchInterstitial);
const showInterstitial = wrapMethod(RNFyberAds.showInterstitial);

const fetchVideo = wrapMethod(RNFyberAds.fetchVideo);
const showVideo = wrapMethod(RNFyberAds.showVideo);

const fetchIncentivizedAd = wrapMethod(RNFyberAds.fetchIncentivizedAd);
const showIncentivizedAd = wrapMethod(RNFyberAds.showIncentivizedAd);

export default {
  once,
  on,
  removeListener,
  init,

  getStatus,
  showDebugPanel,

  isInterstitialAvailable,
  isVideoAvailable,
  isIncentivizedAdAvailable,

  fetchInterstitial,
  showInterstitial,

  fetchVideo,
  showVideo,

  fetchIncentivizedAd,
  showIncentivizedAd,
};
