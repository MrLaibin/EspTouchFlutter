#import "EsptouchFlutterPlugin.h"
#import "ESPTools.h"
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import "ESPAES.h"
#import <CoreLocation/CoreLocation.h>
@implementation EsptouchFlutterPlugin{
    CLLocationManager *_locationManagerSystem;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"esptouch_flutter"
            binaryMessenger:[registrar messenger]];
  EsptouchFlutterPlugin* instance = [[EsptouchFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  
}
-(instancetype)init{
    self._condition = [[NSCondition alloc]init];
    return [super init];
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if([@"getWifiInfo" isEqualToString:call.method]){
      _locationManagerSystem = [[CLLocationManager alloc]init];
      
      [_locationManagerSystem requestWhenInUseAuthorization];
      NSDictionary *wifiDic = [self fetchNetInfo];
      result(wifiDic);
  } else if([@"cancelConnect" isEqualToString:call.method]){
      if(self._esptouchTask!=nil){
          [self._esptouchTask setIsCancelled:YES];
      }
      result(@(YES));
  } else if([@"connectWifi" isEqualToString:call.method]){
      NSDictionary *dic = call.arguments;
      NSString* mSsid = dic[@"mSsid"];
      NSString* pwd = dic[@"pwd"];
      NSString* mBssid = dic[@"mBssid"];
      NSString* devCountStr = dic[@"devCountStr"];
      if(devCountStr==nil){
          devCountStr=@"1";
      }
      BOOL modeGroup = dic[@"modeGroup"];
      
      NSArray* results = [self executeForResultsWithSsid:mSsid bssid:mBssid password:pwd taskCount:[devCountStr intValue] broadcast:modeGroup];
      ESPTouchResult *espResult=  results[0];
      NSDictionary * dic2 = @{@"success":@(espResult.isSuc),@"cancel":@(espResult.isCancelled)};
      result(dic2);
      NSLog(@"==skldfjklj === ");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSDictionary *)fetchNetInfo
{
    NSMutableDictionary *wifiDic = [NSMutableDictionary dictionaryWithCapacity:0];
    wifiDic[@"mSsid"] = ESPTools.getCurrentWiFiSsid;
    wifiDic[@"mBssid"] = ESPTools.getCurrentBSSID;
    return wifiDic;
}

#pragma mark - the example of how to use executeForResults
- (NSArray *) executeForResultsWithSsid:(NSString *)apSsid bssid:(NSString *)apBssid password:(NSString *)apPwd taskCount:(int)taskCount broadcast:(BOOL)broadcast
{
    [self._condition lock];
    self._esptouchTask = [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd];
    // set delegate
    [self._esptouchTask setEsptouchDelegate:self];
    [self._esptouchTask setPackageBroadcast:broadcast];
    [self._condition unlock];
//    ESPTouchResult *ESPTR = self._esptouchTask.executeForResult;
    NSArray * esptouchResults = [self._esptouchTask executeForResults:taskCount];
    NSLog(@"ESPViewController executeForResult() result is: %@",esptouchResults);
    return esptouchResults;
}
-(void) dismissAlert:(UIAlertView *)alertView
{
    [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
}

-(void) showAlertWithResult: (ESPTouchResult *) result
{
    NSString *title = nil;
    NSString *message = [NSString stringWithFormat:@"%@ %@" , result.bssid, NSLocalizedString(@"EspTouch-result-one", nil)];
    NSTimeInterval dismissSeconds = 3.5;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView show];
    [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:dismissSeconds];
}

-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    NSLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithResult:result];
    });
    NSString *message = [NSString stringWithFormat:@"%@ %@" , result.bssid, NSLocalizedString(@"EspTouch-result-one", nil)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceConfigResult" object:message];
}
@end
