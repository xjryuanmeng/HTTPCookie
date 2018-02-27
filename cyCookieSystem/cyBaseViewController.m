//
//  cyBaseViewController.m
//  cyCookieSystem
//
//  Created by 叶子 on 2018/2/27.
//  Copyright © 2018年 叶子. All rights reserved.
//

#import "cyBaseViewController.h"
#include <WebKit/WebKit.h> // 协议头文件
@interface cyBaseViewController ()<WKNavigationDelegate>
@property(nonatomic,strong) WKWebView * webView;
@property(nonatomic,strong) UIView  * backView;
@property(nonatomic,strong) UIProgressView  * progessView;


@end

@implementation cyBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildBackViewAndProgressView];
    [self buildWKWebivew];
}
#pragma mark - 创建背景和添加进度条
-(void)buildBackViewAndProgressView
{
    cyWeakSelf(weakSelf)
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    backView.backgroundColor = [UIColor clearColor];
    _backView = backView;
    [weakSelf.view addSubview:backView];
    
    UIProgressView * progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, 1)];
    progressView.progress = 1;
    _progessView = progressView;
    [weakSelf.backView addSubview:_progessView];
    
}
#pragma mark - 创建WKWebview
-(void)buildWKWebivew
{
    cyWeakSelf(weakSelf)
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _webView.navigationDelegate = weakSelf;
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.scrollView.bounces = NO;
    [weakSelf.backView addSubview:_webView];
    
    //添加监听者 观察webview加载的进度和标题
    [_webView addObserver:weakSelf forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [_webView addObserver:weakSelf forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
}
#pragma mark - 来自外部的调用url
-(void)setUrl:(NSURL *)url
{
    
    _url = url;
    
    cyWeakSelf(weakSelf) //设置弱引用
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSMutableDictionary * cookieDic = [NSMutableDictionary dictionary];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:weakSelf.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1];
    
    //    // 获取本地所有的Cookie
    //    NSArray *cookieJar = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    //    for (NSHTTPCookie * cookie in cookieJar) {
    //        [cookieDic setObject:cookie.value forKey:cookie.name];
    //    }
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSLog(@"cookies = %@",[cookieJar cookies]);
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        [cookieDic setObject:[NSString stringWithFormat:@"%lu",(unsigned long)cookie.version] forKey:NSHTTPCookieVersion];
        [cookieDic setObject:cookie.name forKey:NSHTTPCookieName];
        [cookieDic setObject:cookie.value forKey:NSHTTPCookieValue];
        //        [cookieDic setObject:cookie.expiresDate forKey:@"expiresDate"];
        [cookieDic setObject:[NSString stringWithFormat:@"%d",cookie.isSecure]  forKey:NSHTTPCookieSecure];
        [cookieDic setObject:cookie.domain forKey:NSHTTPCookieDomain];
        [cookieDic setObject:cookie.path forKey:NSHTTPCookiePath];
        [cookieDic setObject:[NSString stringWithFormat:@"%d",cookie.sessionOnly] forKey:@"sessionOnly"];
    }
    //    NSLog(@"cookieValue == %@",cookieDic);
    // cookie重复，放到字典里去拼接
    for (NSString * key in cookieDic) {
        NSString * appendString = [NSString stringWithFormat:@"%@ = %@",key,[cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    
    
    // 注入Cookie
    [request setValue:cookieValue forHTTPHeaderField:@"Cookie"];
    
    [_webView loadRequest:request];
    
}
#pragma mark -webViewNavigationDelegate
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    // 页面加载失败时调用
    NSLog(@"%@",error);
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    // 页面加载完毕时调用
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    cyWeakSelf(weakSelf)
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == _webView) {
            [weakSelf.progessView setAlpha:1];
            [weakSelf.progessView setProgress:weakSelf.webView.estimatedProgress animated:YES];// 设置需要动画
            if (weakSelf.webView.estimatedProgress>=1.0f) {
                
                [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [weakSelf.progessView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [weakSelf.progessView setProgress:0.0 animated:YES];
                }];
            }
            
        }
        else
        {
            // 不能处理的其他key交给super observeValueForKeyPath来处理
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else if ([keyPath isEqualToString:@"title"]) {
        CYLog(@"%@",weakSelf.webView.title);
        if (object == weakSelf.webView) {
            weakSelf.title = weakSelf.webView.title;
            
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
-(void)dealloc
{
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
    _webView.navigationDelegate = nil;
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // 截取当前加载的url,在发送跳转之前决定是否跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    // 拿到response
    NSHTTPURLResponse * response = (NSHTTPURLResponse*)navigationResponse.response;
    // 根据返回的respnse拿到cookies
    NSArray * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    // 存到本地
    for (NSHTTPCookie * cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}
#pragma mark - 获取cookie
-(void)getCookie
{
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        NSLog(@"%@", cookie);
    }
}
#pragma mark - 设置指定的cookie
-(void)setSpecilCookie
{
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"username" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"rainbird" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"cnrainbird.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"cnrainbird.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}
#pragma mark - 当前cookie为空，只要重新请求一个url
-(void)redoRequestUrl
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://blog.cnrainbird.com"]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:3];
    
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:nil
                                      error:nil];
    
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        NSLog(@"%@", cookie);
    }
}
#pragma mark - 清空cookie
-(void)deleCookie
{
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *_tmpArray = [NSArray arrayWithArray:[cookieJar cookies]];
    for (id obj in _tmpArray) {
        [cookieJar deleteCookie:obj];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
