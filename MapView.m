//
//  mapScrollView.m
//  mapScrollView
//
//  Created by ailvgo on 15/10/21.
//  Copyright © 2015年 ailvgo. All rights reserved.
//
#import "MapView.h"
#import "MapScrollView.h"
#import "ZZLingHelp.h"
#import "AllDateModel.h"
#import "flowListModel.h"
#import "PointListModel.h"
#import "mapMusicTableCell.h"
#import "ZZLingHelp.h"
#import <Masonry.h>
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGTH [UIScreen mainScreen].bounds.size.height
#import "MapViewController.h"
#import "AiLvURLRequest.h"
#import "PulsingHaloLayer.h"
#import "UIImageView+WebCache.h"
#import "Mp3PlayerButton.h"
#import "NCMusicEngine.h"
#import "Common.h"
#import "ProgressView.h"

@interface MapView()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,NCMusicEngineDelegate,NSURLSessionDownloadDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>
{
    NCMusicEngine *_player;
    NSTimer *_timer;
    float percent;
    //是否已经登录
    BOOL _isDown;
    int open[100];
    BOOL _isAuto;
    
    int _index;
    int _currentIndex;
    
    NSString * _BssidNum;
    
    BOOL _isMyPosition;
    
    int first;
    
    int myPositionFirst;
    
    int CGS_First;
    
    int openLocation;
    //离线下载任务
     NSURLSessionDownloadTask * _task;
    //离线下载数据
    NSData *_data;
    //离线网络请求
    NSURLRequest * _request;
    
    
}

@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic, strong)Mp3PlayerButton * mp3PalyBtn;

 //顶部多功能控制器
@property (nonatomic,strong) UIScrollView * ScrollView;
@property (nonatomic, strong) UIPageControl * pageControl;
@property (nonatomic, strong) UIView * slideBarView;
//侧边上的按钮父视图
@property (nonatomic, strong) UIView * superSiderView;
//用于展示顶部多功能栏
@property (nonatomic, strong) UIButton * showBtn;
//用于侧栏三个按钮不能被同时选中
@property (nonatomic, strong) UIButton * tmpBtn;
@property (nonatomic, assign) BOOL showTheView;
@property (nonatomic, strong) UIImageView * mapView;
@property (nonatomic,assign) NSInteger *btntag;
@property (nonatomic, strong) UIView * roadView;
@property (nonatomic, strong) UIButton * roadTmpBtn;

//地图的滚动视图
@property (nonatomic, strong) MapScrollView * mapScrollView;
//地图图片
@property (nonatomic,strong) UIImageView * mapImageView;
//mapScrollView的原始比例
@property (nonatomic ,assign) double mapScrollScale;
//图片的宽高比
@property (nonatomic, assign) double mapImageScale;

@property (nonatomic, assign) double ScaleX;
@property (nonatomic, assign) double ScaleY;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, assign) int i ;

//所有景区按钮数组
@property (nonatomic, strong) NSMutableArray * allBtnArr;
//按钮动画2
@property (nonatomic, strong) UIView *highLightView;

//客流量的请求状态
@property (nonatomic, strong) NSString * statusStr;
//客流量信息
@property (nonatomic, strong) NSMutableArray *  spotArr;
//放大倍数
@property (nonatomic, assign) double zoomScale;

@property (nonatomic, assign) NSInteger RoadBtnTag;
//动画效果
@property (nonatomic,strong) PulsingHaloLayer * halo;
//播放按钮的父视图
@property (nonatomic, strong) UIView * PlayView;
@property (nonatomic, strong) UIButton* singleTempBtn;
//图片网址
@property (nonatomic, strong) NSString * ImageUrl;

@property (nonatomic, strong) NSMutableArray * roadBtnArr;
//GPS坐标
@property (nonatomic, strong)  NSDictionary * loacationDic;
//景区点数组
@property (nonatomic, strong) NSMutableArray * pointListArr;


//我的位置
@property (nonatomic, strong) UIButton * myLocationBtn;

@property (nonatomic, strong) CLLocation * postionLocation;

@property (nonatomic, strong) NSString * pathStr;
//缓存地图时的名称
@property (nonatomic, strong) NSString * mapName;

@property (nonatomic, strong) NSMutableDictionary * mapDic;

@property(nonatomic,weak) ProgressView *progressView;


//音频下载按钮
@property (nonatomic,weak)UIButton *downBtn;
@property (nonatomic,weak)UILabel *downLabel;


@property (nonatomic, strong) NSMutableArray * AboutNumBssidArr;

@property (nonatomic, strong) AllDateModel * model1;

@property (nonatomic, weak) UIView * topView;

//底部view
@property (nonatomic, weak) UIView * footView;

@property (nonatomic, strong)MBProgressHUD * hud;
//商业背景view
@property (nonatomic, strong) UIView * bussinessView;
@property (nonatomic, strong) UIView * bgBuView;
@property (nonatomic, strong) UIImageView * logoImage;
@property (nonatomic, strong) UILabel * logoTitle;


@end
@implementation MapView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _currentIndex = -100;
        
        _isDown=NO;
        if (!self.mapDic) {
            self.mapDic = [NSMutableDictionary dictionaryWithCapacity:0];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveBssidNoti:) name:@"BssidNoti" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveLocationNoti:) name:@"locationNoti" object:nil];
        
        
        self.loacationDic = [NSKeyedUnarchiver unarchiveObjectWithFile:LOCATION];
        NSLog(@"self.loacationDic %@",self.loacationDic);
        NSLog(@"++++++++++++%@",[NSKeyedUnarchiver unarchiveObjectWithFile:LOCATION]);
        
        
        
        _roadBtnArr = [NSMutableArray arrayWithCapacity:0];
        _spotArr = [NSMutableArray array];
        _ImageUrl = [NSString string];
        _showTheView = NO;
        _i = 1;
        _BssidNum = @"-100";
        self.zoomScale = 1;
        _isMyPosition = YES;

        //限定“不在景区”只有一次
        //GPS只是一次
        first = 1;
        //我的位置函数，限定“不在景区”只有一次
        myPositionFirst = 1;
        //CGS 限定“不在景区”只有一次
        CGS_First = 1;
        //开启定位
        openLocation = 1;
        _stop = YES;
        [self createMapScrollView];
        //顶部10个按钮
        [self createTopView];
        //右侧按钮
        [self createSideBar];
        //底部按钮
        [self createBottomBar];
  
        //消息
        [self createMesssge];
        
        
        
//        _allBtnArr = [NSMutableArray array];
        
//        [self createSpotsList];
        
#pragma mark------------------展示多功能顶部栏的按钮
        _showBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _showBtn.alpha = 0.4;
        [_showBtn setBackgroundImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
        [_showBtn addTarget:self action:@selector(showOrHiddenTheView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_showBtn];
        
        //加载转圈
        self.hud = [[MBProgressHUD alloc] init];
        [self addSubview:self.hud];
        [self.hud bringSubviewToFront:_mapScrollView];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.delegate = self;
        self.hud.labelText = @"地图加载中...";
        [self.hud show:YES];
        
        //商业
        self.bussinessView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)];
        self.bussinessView.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.5];
        [self addSubview:self.bussinessView];
        [self.bussinessView bringSubviewToFront:_ScrollView];
        self.bussinessView.hidden = YES;
        
        
        UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bussinessTapClick:)];
        [self.bussinessView addGestureRecognizer:tap1];
        
        self.bgBuView = [[UIView alloc] initWithFrame:CGRectMake(10, (kScreenHeight-64-100)/2, kScreenWidth-20, 100)];
        self.bgBuView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [self.bussinessView addSubview:self.bgBuView];
        self.bgBuView.layer.cornerRadius = 5;
        self.bgBuView.layer.masksToBounds = YES;
        //logo图
        self.logoImage  = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 90, 90)];
        self.logoImage.image = [UIImage imageNamed:@"icon-60"];
        [self.bgBuView addSubview:self.logoImage];
        self.logoImage.layer.cornerRadius = 5;
        self.logoImage.layer.masksToBounds = YES;
        //商业标题
        self.logoTitle = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, self.bgBuView.frame.size.width-100, 100)];
        [self.bgBuView addSubview:self.logoTitle];
        
        
        
        
        
    
    }
    
    return self;

 
}
-(void)createMapScrollView{

    _mapScrollView = [[MapScrollView alloc] initWithFrame:CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height)];
    

    NSLog(@"%f width%f  height%f  %f",self.frame.size.width,WIDTH,HEIGTH, self.frame.size.height);
    
    _mapScrollView.backgroundColor = [UIColor lightGrayColor];
    _mapScrollView.delegate = self;
    _mapScrollView.tag = 110;
    _mapScrollView.contentSize = _mapScrollView.frame.size;
    _mapScrollView.showsVerticalScrollIndicator = NO;
    _mapScrollView.showsHorizontalScrollIndicator = NO ;
    _mapScrollView.minimumZoomScale = 1;
    _mapScrollView.maximumZoomScale = 8;
    _mapScrollView.bounces = NO;

    [self addSubview:_mapScrollView];
    
    _mapScrollScale = _mapScrollView.frame.size.width / _mapScrollView.frame.size.height;
    
    
    _mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.mapScrollView.frame.size.width, self.mapScrollView.frame.size.height)];
    _mapImageView.userInteractionEnabled = YES;
    [_mapScrollView addViewForZooming:_mapImageView];
    
#pragma mark   -------------添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [_mapImageView.superview addGestureRecognizer:tap];
    NSLog(@"2");
    
//    //小菊花
//    self.activityView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2.0, (kScreenHeight-100)/2.0-64, 100, 100)];
//    self.activityView.backgroundColor = [UIColor redColor];
//    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    self.activity.color = [UIColor whiteColor];
//    self.activity.center = CGPointMake(50, 50);
//    [self.activityView addSubview:self.activity];
//    [_mapScrollView addSubview:self.activityView];
////    [self.activityView bringSubviewToFront:_mapScrollView];
//    self.activityView.hidden = YES;

    
#pragma mark ----------------数据请求
    
//    AllDateModel * spotInfoModel = self.spotInfoArr[0];
//    
//    _player.cacheFolderName= spotInfoModel.name;
//  
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"imageUrl"] != nil) {
//        _ImageUrl = spotInfoModel.mapUrl;
//        
//    }else{
//    _ImageUrl = spotInfoModel.mapUrl;
//    }
    //现在为空
//    NSString * mapImageUrl =spotInfoModel.mapUrl;
//    _ImageUrl = spotInfoModel.mapUrl;
    //开辟线程,用于下载图片
//    [NSThread detachNewThreadSelector:@selector(loadTheImageOfUrl:) toTarget:self withObject:mapImageUrl];
//    [self setJqid:self.jqid];
    //客流量的数据请求
//    NSDictionary * parameters = @{@"jqid":self.jqid};
//    [AiLvURLRequest JsonDatawithUrl:@"http://ailv3.ailvgocloud.com/ailv3/index.php/app/Scenicspot/flowList" andDataWithDictionary:parameters success:^(id json) {
//        NSLog(@"客流量  %@",json);
//        if ([json[@"status"] isEqualToString:@"ok"]) {
//            _statusStr = json[@"status"];
//            
//            NSDictionary * msgDic = json[@"msg"];
//            NSArray * flowListArr = msgDic[@"flowList"];
//            
//            for (NSDictionary * dic  in flowListArr) {
//                
//                flowListModel * model = [[flowListModel alloc] init];
//                [model setValuesForKeysWithDictionary:dic];
//                
//                [_spotArr addObject:model];
//            }
//        }else{
//            //json状态不是ok时调
//        }
//        
//    } fail:^(NSError * error ) {
//        
//        NSLog(@"-------%@",error);
//    }];
//
    
    
    
//    //地图图片地址
//    //http://www.ailvgoserver.com/resource/B/B04/B0401/offline/B0401/map/map.lvjpg
//    NSString * mapImageUrl = [NSString stringWithFormat:@"%@",@"http://www.ailvgoserver.com/resource/B/B04/B0401/offline/B0401/map/map.lvjpg"];
//    //开辟线程,用于下载图片
//    [NSThread detachNewThreadSelector:@selector(loadTheImageOfUrl:) toTarget:self withObject:mapImageUrl];
    
}

-(void) setJqid:(NSString *)jqid{
    _jqid=jqid;
    NSLog(@"JQID  %@",jqid);
    self.mapName = jqid;
    
    //客流量
    [self loadScenicspot];
    
//    NSDictionary * parameters = @{@"jqid":jqid};
//    
//    [AiLvURLRequest JsonDatawithUrl:@"http://ailv3.ailvgocloud.com/ailv3/index.php/app/Scenicspot/flowList" andDataWithDictionary:parameters success:^(id json) {
//        NSLog(@"客流量  %@",json);
//        if ([json[@"status"] isEqualToString:@"ok"]) {
//            _statusStr = json[@"status"];
//            
//            NSDictionary * msgDic = json[@"msg"];
//            NSArray * flowListArr = msgDic[@"flowList"];
//            
//            for (NSDictionary * dic  in flowListArr) {
//                
//                flowListModel * model = [[flowListModel alloc] init];
//                [model setValuesForKeysWithDictionary:dic];
//                
//                [_spotArr addObject:model];
//            }
//        }else{
//            //json状态不是ok时调
//        }
//        
//    } fail:^(NSError * error ) {
//        
//        NSLog(@"-------%@",error);
//    }];
    
    
    NSLog(@"%@",self.spotInfoArr);
    
    
    NSArray * arr = [self getAllMapNames];
    NSLog(@"++++++++++%@",arr);

    for (int i = 0; i < arr.count; i ++) {
        
        if ([self.mapName isEqualToString:arr[i]]) {
            UIImage *image = [UIImage imageWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:jqid]];
            
            //回到主线程刷新UI
            [self performSelectorOnMainThread:@selector(setMapImage:) withObject:image waitUntilDone:YES];
            
            break;
        }
    }
    

    //判断离线包是否下载
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:DOWNSTATE];
    NSMutableArray *muarry = [NSMutableArray arrayWithArray:array];
    NSLog(@"array%@",muarry);
    for (NSDictionary *dict in muarry) {
        NSLog(@"--%@----%@",[dict objectForKey:@"down"],self.jqid);
        if ([[dict objectForKey:@"down"] isEqualToString:self.jqid]) {
            _isDown=YES;
            NSLog(@"zd%d",_isDown);
            
            
        }
        
    }
    if (_isDown) {
        _downBtn.selected=YES;
        _downLabel.text=@"删除音频包";
    }
    

}

-(void)loadScenicspot{
    
    NSDictionary * parameters = @{@"jqid":self.mapName};
    
    [AiLvURLRequest JsonDatawithUrl:@"http://ailv3.ailvgocloud.com/ailv3/index.php/app/Scenicspot/flowList" andDataWithDictionary:parameters success:^(id json) {
        NSLog(@"客流量  %@",json);
        if ([json[@"status"] isEqualToString:@"ok"]) {
            _statusStr = json[@"status"];
            
            if (_spotArr.count>0) {
                [_spotArr removeAllObjects];
            }
            
            NSDictionary * msgDic = json[@"msg"];
            NSArray * flowListArr = msgDic[@"flowList"];
            
            for (NSDictionary * dic  in flowListArr) {
                
                flowListModel * model = [[flowListModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                
                [_spotArr addObject:model];
            }
        }else{
            //json状态不是ok时调
        }
    } fail:^(NSError * error ) {
        
        NSLog(@"-------%@",error);
    }];

}


-(void) setSpotInfoArr:(NSMutableArray *)spotInfoArr {
    
    _spotInfoArr=spotInfoArr;
    
//    if ((spotInfoArr.count < 1)&& ([[NSUserDefaults standardUserDefaults] objectForKey:@"imageUrl"] != nil)) {
//        _ImageUrl = self.imageUrl;
//    }
//    else{
    
    AllDateModel * spotInfoModel = spotInfoArr[0];
    
    self.pathStr =spotInfoModel.ID;
    
    _ImageUrl = spotInfoModel.mapUrl;
//    }
    
    NSLog(@"self.jqid----=-===-=-=-=-=-=-%@",self.jqid);
    
    NSLog(@"jqid===%@",[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@MapName",spotInfoModel.ID]]);
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@MapName",spotInfoModel.ID]] isEqualToString:spotInfoModel.subversion]){
        NSArray * mapArr = [self getAllMapNames];
        
        BOOL stop = YES;
        
        for (int i = 0; i < mapArr.count; i ++) {
            
            if ([spotInfoModel.ID isEqualToString:mapArr[i]]) {
                
                stop = NO;
            }
            
        }
        
        
        if (stop) {
            
            [NSThread detachNewThreadSelector:@selector(loadTheImageOfUrl:) toTarget:self withObject:_ImageUrl];

        }else{
        
            UIImage *image = [UIImage imageWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:spotInfoModel.ID ]];
            //回到主线程刷新UI
            [self performSelectorOnMainThread:@selector(setMapImage:) withObject:image waitUntilDone:YES];
        }
        
    }else{
    
        //清除对应景区的音频
        NSFileManager * fileManager = [NSFileManager defaultManager];
        // 获取Caches目录路径
        NSString *cacheDir = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
        
        NSString *  cacheFolder = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"音乐/%@",_jqid]];
        [fileManager removeItemAtPath:cacheFolder error:nil];
        
        UIButton * button = (UIButton*) [_topView viewWithTag:105];
        [button setImage:[UIImage imageNamed:@"top_btn7_nor.png"] forState:UIControlStateNormal];
        UILabel * label = (UILabel *) [_topView viewWithTag:205];
        label.text = @"音频下载";
        
        NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:DOWNSTATE];
        NSMutableArray *muarry = [NSMutableArray arrayWithArray:array];
        for (int i=0; i<muarry.count; i++) {
            NSDictionary *dict=muarry[i];
            if ([[dict objectForKey:@"down"] isEqualToString:self.jqid]) {
                [muarry removeObjectAtIndex:i];
            }
        }
        
        [NSKeyedArchiver archiveRootObject:muarry toFile:DOWNSTATE];
        
        
        
        
        [NSThread detachNewThreadSelector:@selector(loadTheImageOfUrl:) toTarget:self withObject:_ImageUrl];
    
    
    }
    
    
    
    
    
    
//    NSString * mapImageUrl =spotInfoModel.mapUrl;
    
 
}


#pragma mark -- 异步请求数据
-(void)loadTheImageOfUrl:(NSString *) imageUrl
{
   
//    self.hud.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:2.0];
    
    
    
     [self.hud show:YES];
    

        NSString * idStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
#pragma mark   --------- 图片缓存路径
    NSString * mapFile = [NSString stringWithFormat:@"%@",idStr];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:mapFile]];
    
    NSLog(@"------%@",[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:mapFile]);
    
    if (image == nil) {
        
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImage * image = [UIImage imageWithData:data];
        
        [UIImagePNGRepresentation(image) writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:mapFile ] atomically:YES];
        
        NSLog(@"spotInfoArr----%@",self.spotInfoArr);
        AllDateModel * model = self.spotInfoArr[0];
        NSLog(@"subversion---%@",model.subversion);
        //jqidMapName对应着地图更新
        [[NSUserDefaults standardUserDefaults] setObject:model.subversion forKey:[NSString stringWithFormat:@"%@MapName",self.jqid]];
        
        
    }
    //    NSLog(@"%@",[NSKeyedUnarchiver unarchiveObjectWithFile:mapImagesPath]);
    
    
    image = [UIImage imageWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:self.jqid]];
    if (!image) {
        
        self.hud.labelText = @"地图加载失败，请检查网络";
        sleep(1);
        [self.hud hide:YES];
        
       
    }else{
        
        [self.hud hide:YES];
        //回到主线程刷新UI
        [self performSelectorOnMainThread:@selector(setMapImage:) withObject:image waitUntilDone:YES];
    }
    
 
}

-(void)setMapImage:(UIImage *) image{
    
    [self.hud hide:YES];
    
       if (image.size.width == 0) {
        _ScaleX = 1;
        _ScaleY = 1;
        
    }
    else{
        
       _mapImageScale = image.size.width/ image.size.height;
        
        //做图片和屏幕的适配
        if (_mapImageScale > _mapScrollScale) {
            _mapImageView.frame = CGRectMake(0, 0, self.mapScrollView.frame.size.height * _mapImageScale, self.mapScrollView.frame.size.height);
            NSLog(@"%f, ---------=====%f",self.mapScrollView.frame.size.height * _mapImageScale, self.mapScrollView.frame.size.height);
            
        }
        else{
        
            _mapImageView.frame = CGRectMake(0, 0, self.mapScrollView.frame.size.width, self.mapScrollView.frame.size.width/ _mapImageScale);
            
        
        }NSLog(@"111122222");
        _mapScrollView.contentSize = _mapImageView.frame.size;
        self.mapScrollView.contentOffset = CGPointMake((_mapImageView.frame.size.width - _mapScrollView.frame.size.width) / 2.0, (_mapImageView.frame.size.height - _mapScrollView.frame.size.height)/ 2.0);
        _ScaleX = self.mapImageView.frame.size.width / image.size.width;
        _ScaleY = self.mapImageView.frame.size.height/ image.size.height;

    }
    NSArray * subViews = [_mapImageView subviews];
    if ([subViews count]!= 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }

    NSLog(@"----111111111");
    
    [_mapImageView setImage:image];
    
//    [self loadTheDataOfTheMap];
    
    
#pragma mark ------------添加全部景点
    NSLog(@"---222222222222");
    NSLog(@"self.class_A_Arr--------====-%@",self.class_A_Arr);
    [self addAttractionsButton];
    
#pragma mark ----------- 创建全部景点的表
    
    [self createSpotsList];
    

}


-(void)createPlayView:(AllDateModel*)model{

    _model1 = model;
    NSArray *subViews = [_PlayView subviews];
    NSLog(@"---%@",subViews);
//    if([subViews count] != 0) {
//        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    }
    
//    NSLog(@"-_player.playState-----========%u",_player.playState);
    
    
    for (int i= 0 ; i<subViews.count; i++) {
        
        
            UIButton * colseBtn = (UIButton*)[_PlayView viewWithTag:101];
            UIButton * detialBtn= (UIButton*)[_PlayView viewWithTag:102];
            [colseBtn removeFromSuperview];
            [detialBtn removeFromSuperview];

    }
    
    //播放按钮父视图
    if (!_PlayView) {
        _PlayView  = [[UIView alloc] initWithFrame:CGRectZero];
        [_mapImageView bringSubviewToFront:_PlayView];
    }
    
    //+25.0
    _PlayView.bounds = CGRectMake(0, 0, 70*self.zoomScale, 50*self.zoomScale);
    _PlayView.center= CGPointMake([model.map_X doubleValue]*_ScaleX+2, [model.map_Y doubleValue]* _ScaleY-(50*self.zoomScale)/2.0);
    
    
    if (_mp3PalyBtn==nil) {
        _mp3PalyBtn = [[Mp3PlayerButton alloc] initWithFrame:CGRectZero];

    }
    
    
    _mp3PalyBtn.bounds = CGRectMake(0, 0, 50*self.zoomScale, 50*self.zoomScale);
    _mp3PalyBtn.center = CGPointMake(25*self.zoomScale, 25*self.zoomScale);
//    _player.button = _mp3PalyBtn;
    
    _mp3PalyBtn.tag = 100;
    [_mp3PalyBtn addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [_PlayView addSubview:_mp3PalyBtn];
    
    UIButton * colseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    colseBtn.tag = 101;
    colseBtn.bounds = CGRectMake(0, 0, 20*self.zoomScale, 20*self.zoomScale);
    colseBtn.center = CGPointMake(60*self.zoomScale, 10*self.zoomScale);
    [colseBtn setBackgroundImage:[UIImage imageNamed:@"map_icon_close"] forState:UIControlStateNormal];
    [colseBtn addTarget:self action:@selector(stopTheMusic:) forControlEvents:UIControlEventTouchUpInside];
    [_PlayView addSubview:colseBtn];
    
    UIButton * deataileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deataileBtn.tag = 102;
    deataileBtn.bounds = CGRectMake(0, 0, 20*self.zoomScale, 20*self.zoomScale);
    deataileBtn.center = CGPointMake(60*self.zoomScale, 40*self.zoomScale);
    
    [deataileBtn setBackgroundImage:[UIImage imageNamed:@"map_icon_details"] forState:UIControlStateNormal];
    [deataileBtn addTarget:self action:@selector(musicDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_PlayView addSubview:deataileBtn];
    
    if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
        [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:model];
        
    }
 
}


-(void)addAttractionsButton{
    
    if (_allBtnArr == nil) {
        _allBtnArr = [NSMutableArray array];
    }else{
        
        for (UIButton * btn  in _allBtnArr) {
            [btn removeFromSuperview];
        }
        
        [_allBtnArr removeAllObjects];
        
    }
//
//    NSArray * subViews = [_mapImageView subviews];
//    if ([subViews count]!= 0) {
//        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    }

    //原来是在这里创建播放器的
    
    
    NSLog(@"class_A_Arr  ==== %@",self.class_A_Arr);
//    if (_allBtnArr.count<1) {
    
        for (int i = 0; i < _class_A_Arr.count; i ++) {
            
            AllDateModel * guideModel = _class_A_Arr[i];
            //        [guideModel.map_X floatValue]* _ScaleX-15, [guideModel.map_Y floatValue]* _ScaleY -20
            UIButton * JIQuBtn = [ZZLingHelp createButtonWithFrame:CGRectMake(0,0,20 * self.zoomScale, 25 * self.zoomScale) target:self methed:@selector(attractionsBtn:)normalImageName:@"map_icon_locked" hightImageName:@"map_icon_locked" title:nil];
            
            JIQuBtn.center = CGPointMake([guideModel.map_X floatValue]* _ScaleX, [guideModel.map_Y floatValue]* _ScaleY-(25*self.zoomScale)/2);
            JIQuBtn.selected = YES;
//            JIQuBtn.tag = [guideModel.guide_id integerValue];
            [JIQuBtn setTitle:guideModel.guide_id forState:UIControlStateDisabled];
            
            NSLog(@"text===%@",JIQuBtn.titleLabel.text);
            NSLog(@"%@",[JIQuBtn titleForState:UIControlStateDisabled]);
            NSLog(@"guide_id--=-=-=---%@",guideModel.guide_id);
            NSLog(@"----=-=-=-=-=-------%ld",(long)[guideModel.guide_id floatValue]);
            

            JIQuBtn.layer.cornerRadius = JIQuBtn.frame.size.height/2;
            JIQuBtn.layer.masksToBounds = YES;
            JIQuBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            JIQuBtn.layer.borderWidth = 0.0f;
            
            [_mapImageView addSubview:JIQuBtn];
            
            [_mapImageView insertSubview:JIQuBtn belowSubview:_PlayView];
            [_allBtnArr addObject:JIQuBtn];
            
            NSLog(@"tag=-=-=-=-=- %ld",JIQuBtn.tag);
            
        }

    if (_class_A_Arr.count <1) {
        
    }else{
        
//    AllDateModel *  model = _class_A_Arr[0];
//    [_NameBtn setTitle:model.name forState:UIControlStateNormal];
        if (_model1.name) {
            [_NameBtn setTitle:_model1.name forState:UIControlStateNormal];
            }else{
                AllDateModel *  model = _class_A_Arr[0];
                [_NameBtn setTitle:model.name forState:UIControlStateNormal];
        }
        
        
        
    }
    
    NSLog(@"allBtnArr1");

}

#pragma mark ------初始化景点按钮点击事件

-(void)attractionsBtn:(UIButton *) sender{
    NSLog(@"-=-=-===-=-=-=--%@",sender.titleLabel.text);
    
    if (_player != nil) {
        [_player stop];
        _player = nil;
    }
    
    AllDateModel * model = [[AllDateModel alloc] init];
   
    for (int i = 0; i< _class_A_Arr.count; i++) {
        
        AllDateModel * guideModel = _class_A_Arr[i];
        NSLog(@"sender.tag=====%@",[sender titleForState:UIControlStateDisabled]);
        
        if ([[sender titleForState:UIControlStateDisabled] isEqualToString:guideModel.guide_id]) {
            
            model = guideModel;
            _model1 = model;
            
        }
    }
    [_NameBtn setTitle:model.name forState:UIControlStateNormal];
//    
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:model.name message:[NSString stringWithFormat:@"audioURL:%@\n\nbox_id:%@\n\nbox_mac:%@\n\nguide_id:%@\n\np_id:%@\n\nlatitude:%@ \n\n longitude:%@\n\n ",model.audioURL,model.box_id,model.box_mac,model.guide_id,model.p_id,model.latitude,model.longitude] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
//    [alert show];
    
    if (_singleTempBtn == nil) {
        sender.selected = YES;
        _singleTempBtn = sender;
        if (sender.selected== YES) {
            NSLog(@"1");
            
             [_PlayView removeFromSuperview];
            //+ 10       - 40
            
//            _PlayView.frame = CGRectMake(0, 0, 80, 80);
//            _PlayView.center= CGPointMake([model.map_X doubleValue], [model.map_Y doubleValue]);

            [self  createPlayView:model];
            
//            _PlayView.frame = CGRectMake(0,0, 87*self.zoomScale, 71*self.zoomScale);
//            _PlayView.center = CGPointMake([model.map_X doubleValue]*_ScaleX, [model.map_Y doubleValue]*_ScaleY+(71/2.0)-(71*self.zoomScale)/2.0);
            
            
            [_mapImageView addSubview:_PlayView];
            _mp3PalyBtn.musicName = model.guide_id;
            _mp3PalyBtn.secondCacheFolderName = model.guide_id;

            _mp3PalyBtn.mp3URL = [NSURL URLWithString:model.audioURL];
            
            if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
                [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:model];
                
            }
            sender.selected = NO;
            
        }
    }else if (_singleTempBtn != nil&& _singleTempBtn == sender){
        if (sender.selected== YES) {
            NSLog(@"3");
             [_PlayView removeFromSuperview];
//            _PlayView.frame = CGRectMake(sender.center.x  -62/2.0, sender.center.y - 78/2.0, 87, 71);
            
//            _PlayView.frame = CGRectMake(0,0, 87*self.zoomScale, 71*self.zoomScale);
//            _PlayView.center = CGPointMake([model.map_X doubleValue]*_ScaleX, [model.map_Y doubleValue]*_ScaleY+(71/2.0)-(71*self.zoomScale)/2.0);
            
            [self  createPlayView:model];
            
            [_mapImageView addSubview:_PlayView];
            _mp3PalyBtn.musicName = model.guide_id;
            _mp3PalyBtn.secondCacheFolderName = model.guide_id;
            _mp3PalyBtn.mp3URL = [NSURL URLWithString:model.audioURL];
            NSLog(@"_PlayView.frame.size.width%f",_PlayView.frame.size.width);
            
            if (_player.playState == NCMusicEnginePlayStateError){
                [_player playUrl:_mp3PalyBtn.mp3URL];
                
            }
            sender.selected = NO;
            
        }else{
            if (_player.playState == NCMusicEnginePlayStatePlaying || _player.playState == NCMusicEnginePlayStatePaused || _player.playState == NCMusicEnginePlayStateEnded) {
                [_player stop];
            }else if (_player.playState == NCMusicEnginePlayStateError){
                [_player playUrl:_mp3PalyBtn.mp3URL];
                
            }else{
                [_player stop];
            
            }
            if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
                [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:_model1];
                
            }
            
            [_PlayView removeFromSuperview];
    
            sender.selected = YES;
        }
    
    }else if (_singleTempBtn != nil && _singleTempBtn != sender){
        sender.selected = YES;
        _singleTempBtn = sender;
        if (sender.selected== YES) {
            NSLog(@"5");
             [_PlayView removeFromSuperview];
            [_player stop];
            [self  createPlayView:model];
            [_mapImageView addSubview:_PlayView];
            _mp3PalyBtn.musicName = model.guide_id;
            _mp3PalyBtn.secondCacheFolderName = model.guide_id;

            _mp3PalyBtn.mp3URL = [NSURL URLWithString:model.audioURL];

            
            if (_player.playState == NCMusicEnginePlayStateError){
                [_player playUrl:_mp3PalyBtn.mp3URL];
                
            }

            if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
                [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:model];
                
            }
            sender.selected = NO;
            
        }
   }
}


-(void)playMusic:(Mp3PlayerButton*) button{

    if (_player == nil) {
        
        _player = [[NCMusicEngine alloc] initWithSetBackgroundPlaying:YES];
        _player.delegate = self;
        _player.cacheFolderName= self.pathStr;
        _player.secondCacheFolderName = button.secondCacheFolderName;
        _player.musicName = button.musicName;
        
    }else{
        
    _player.cacheFolderName= self.pathStr;
    _player.musicName = button.musicName;
    _player.secondCacheFolderName = button.secondCacheFolderName;
        
    }
    
    if ([_player.button isEqual:button]) {
        if (_player.playState == NCMusicEnginePlayStatePlaying) {
            
            [_player pause];
        }
        else if(_player.playState==NCMusicEnginePlayStatePaused){
            //            继续
            [_player resume];
        }else if (_player.playState == NCMusicEnginePlayStateEnded){
            
            [_player stop];
            [_PlayView removeFromSuperview];
        
        }
        else{
            
            [_player playUrl:button.mp3URL];
            
        }
    } else {
        [_player stop];
        _player.button = button;
        [_player playUrl:button.mp3URL];
        
    }
    
    
#pragma mark ----------11111111111111111111111111111111111111111111
    
    if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
        [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:_model1];
    }
    

}

-(void)stopTheMusic:(UIButton *) sender{
    if(_player.playState == NCMusicEnginePlayStatePlaying ){
    [_player stop];
    }else{
    [_player stop];
    }
    
    _player = nil;
    _model1 = nil;
    [_PlayView removeFromSuperview];
    
}
-(void)musicDetail:(UIButton *) sender{
//详情
     self.mp3PalyBtn =(Mp3PlayerButton *)[_PlayView viewWithTag:100];
    if ([self.delegate respondsToSelector:@selector(soptDetailAboutGuideId:)]) {
        [self.delegate soptDetailAboutGuideId:self.mp3PalyBtn.musicName];
        
    }
    
   
    NSLog(@"self.mp3PalyBtn.musicName----%@",self.mp3PalyBtn.musicName);
    
    NSLog(@"详情");

}
#pragma mark-----------------设置顶部按钮(导览，景区概况，微游记，我来讲等 10 个按钮)

-(void)createTopView
{
    
    _ScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 100)];
    _ScrollView.tag = 111;
    _ScrollView.contentSize = CGSizeMake(WIDTH  + WIDTH/5.0 * 2 , 0);
    _ScrollView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.8];
    _ScrollView.showsHorizontalScrollIndicator = NO;
    _ScrollView.showsVerticalScrollIndicator = NO;
//    _ScrollView.pagingEnabled = YES;
    _ScrollView.delegate = self;
    [self addSubview:_ScrollView];
    
//    _pageControl = [[UIPageControl alloc] init];
//    CGSize size = [_pageControl sizeForNumberOfPages:2];
//    _pageControl.frame = CGRectMake((WIDTH - size.width)/2.0, -11, size.width, size.height);
//    _pageControl.numberOfPages = 2;
//    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.9961 green:0.7725 blue:0.0471 alpha:1.0];
//    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.6941 green:0.7294 blue:0.749 alpha:1.0];
//    _pageControl.currentPage = 0;
//    [self addSubview:_pageControl];
    
    CGFloat ViewWidth = WIDTH/5;
    CGFloat  BtnWidth = ViewWidth * 2 / 3;
    CGFloat BtnHeight = BtnWidth;
    CGFloat Padding = (ViewWidth - BtnWidth) / 2;
    
#pragma mark---------------两个数组的图片有错误，后续修改
//    NSArray * UnSelectBtnImageArr = @[@"top_btn1_nor.png",@"top_btn2_nor.png",@"top_btn3_nor.png",@"top_btn4_nor.png",@"top_btn5_nor.png",@"top_btn6_nor.png",@"top_btn7_nor.png",@"top_btn8_nor.png",@"top_btn9_nor.png",@"top_btn10.png"];
//    NSArray * SelectBtnImageArr = @[@"top_btn1_down.png",@"top_btn2_down.png",@"top_btn3_down.png",@"top_btn4_down.png",@"top_btn5_down.png",@"top_btn6_down.png",@"top_btn7_down.png",@"top_btn8_down.png",@"top_btn9_nor.png",@"top_btn10.png"];
    //NSMutableArray * Arr = [NSMutableArray arrayWithCapacity:0];
//    NSArray * titleArr = @[@"导览",@"景区概况",@"微游记",@"脱口秀",@"涂鸦",@"知乎",@"评论",@"求助",@"离线下载",@"敬请期待"];
    
    NSArray * UnSelectBtnImageArr = @[@"top_btn1_nor.png",@"top_btn2_nor.png",@"top_btn3_nor.png",@"top_btn4_nor.png",@"top_btn7_nor.png",@"top_btn9_nor.png",@"top_btn10.png"];
    NSArray * SelectBtnImageArr = @[@"top_btn1_down.png",@"top_btn2_down.png",@"top_btn3_down.png",@"top_btn4_down.png",@"top_btn7_down.png",@"top_btn9_nor.png",@"top_btn10.png"];

    NSArray * titleArr = @[@"导览",@"景区概况",@"微游记",@"脱口秀",@"评论",@"音频下载",@"敬请期待"];
    
    for (int i = 0; i < 7; i ++) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(i * ViewWidth, 0, ViewWidth, 100)];
        //view.backgroundColor = [UIColor blueColor];
        [_ScrollView addSubview:view];
        _topView = view;
        
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.frame = CGRectMake(Padding, 15, BtnWidth, BtnHeight);
        [button setBackgroundImage:[UIImage imageNamed:UnSelectBtnImageArr[i]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:SelectBtnImageArr[i]] forState:UIControlStateHighlighted ];
        if (i==5) {
            [button setBackgroundImage:[UIImage imageNamed:@"top_btn9_delete_nor"] forState:UIControlStateSelected];
            NSLog(@"%d",_isDown);
            if (_isDown) {
                
                button.selected=YES;
            }
          
        }
        button.tag = i  + 100;
        [button addTarget:self action:@selector(multifunctionalButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:button];
        
        UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 77, ViewWidth, 13)];
        titleLable.tag=i+200;
        titleLable.text = titleArr[i];
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.textColor = [UIColor blackColor];
//        titleLable.adjustsFontSizeToFitWidth = YES;
        titleLable.font = [UIFont systemFontOfSize:13];
        [view addSubview:titleLable];
        
        
        if (i==5) {
            //设置离线下载的进度条
            UIButton *downBtn=(UIButton *)[view viewWithTag:105];
//             [downBtn setBackgroundImage:[UIImage imageNamed:@"top_btn9_delete_nor"] forState:UIControlStateSelected];
            _downBtn=downBtn;
            
            UILabel *downLabel=(UILabel *)[view viewWithTag:205];
            _downLabel=downLabel;
            
            ProgressView *progress = [[ProgressView alloc]init];
            progress.center=CGPointMake(downBtn.center.x, downBtn.center.y);
            progress.bounds=CGRectMake(0, 0, BtnWidth, BtnHeight);
            progress.backgroundColor=[UIColor clearColor];
            progress.centerColor=[[UIColor whiteColor]colorWithAlphaComponent:1];
            progress.arcFinishColor = [UIColor colorWithRed:117/255.0 green:171/255.0 blue:51/255.0 alpha:0.5];
            progress.arcUnfinishColor = [UIColor colorWithRed:0.1176 green:0.8118 blue:1.0 alpha:1.0];
            progress.hidden=YES;
            progress.arcBackColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1.0];
            progress.percent = 0;
            [view addSubview:progress];
            _progressView=progress;
        }
        
        
        
    }
  
    
}


#pragma mark-----------------侧边上的按钮 （客流量，卫生间，线路） 其中卫生间的图片在高亮状态下没有@3x的图片

-(void)createSideBar{
    UIView * superSiderView = [[UIView alloc] initWithFrame:CGRectMake(WIDTH - 10 -35, 30 + 100, 35, 80)];
    [self addSubview:superSiderView];
    _superSiderView = superSiderView;
    
    UIButton * roadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    roadButton.frame = CGRectMake(0, 0, 35, 35);
    roadButton.tag = 998;
    roadButton.alpha = 0.7;
    roadButton.selected = YES;
    [roadButton setImage:[UIImage imageNamed:@"map_btn3_nor"] forState:UIControlStateNormal];
    [roadButton addTarget:self action:@selector(btnClickOfSlider:) forControlEvents:UIControlEventTouchUpInside];
    [_superSiderView addSubview:roadButton];
    
    UIButton * otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    otherButton.frame = CGRectMake(0, 45, 35, 35);
    otherButton.tag = 999;
    otherButton.alpha = 0.7;
    otherButton.selected = YES;
    [otherButton setImage:[UIImage imageNamed:@"map_btn_message_nor"] forState:UIControlStateNormal];
    [otherButton addTarget:self action:@selector(btnClickOfSlider:) forControlEvents:UIControlEventTouchUpInside];
    [_superSiderView addSubview:otherButton];

}



#pragma mark-------------------底部按钮   （  定位    风景点名称    自动导览  ）
-(void)createBottomBar{
    
    UIView * footView = [ZZLingHelp createViewWithFrame:CGRectZero backGroudColor:[[UIColor colorWithRed:0.9882 green:0.9882 blue:0.9882 alpha:1.0]colorWithAlphaComponent:0.7] backGroudImage:nil RoundOftheDegree:4.0];
    
    [self addSubview:footView];
    _footView = footView;
    
    //footView适配
    [footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(10);
        make.right.equalTo(self.mas_right).offset(-10);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(@45);
        
    }];
    
#pragma mark--------------------底部 定位 按钮     正常状态下得图片没有，需改动
    //自动定位按钮
    UIButton * locationBtn = [ZZLingHelp createButtonWithFrame:CGRectZero target:self methed:@selector(lacationButtonClick:) normalImageName:@"foot_icon_location.png" hightImageName:@"foot_icon_location.png" title:nil];
    [footView addSubview:locationBtn];
    
    locationBtn.selected = YES;
    self.AutoLocation = locationBtn.selected;
    
    
    [locationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footView.mas_left);
        make.top.equalTo(footView.mas_top);
        make.width.equalTo(@45);
        make.height.equalTo(@45);
    }];
    
    UIView * LineView = [ZZLingHelp createViewWithFrame:CGRectZero backGroudColor:nil backGroudImage:@"foot_cutline.png" RoundOftheDegree:0.0];
    [footView addSubview:LineView];
    [LineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(locationBtn.mas_right);
        make.top.equalTo(footView.mas_top).offset(10);
        make.width.equalTo(@2);
        make.height.equalTo(@25);
        
    }];
    
    UIView * senicView = [ZZLingHelp createViewWithFrame:CGRectZero backGroudColor:nil backGroudImage:@"foot_icon_locked" RoundOftheDegree:10.0];
    [footView addSubview:senicView];
    [senicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(LineView.mas_right).offset(10);
        make.top.equalTo(footView.mas_top).offset(12);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    
    
    //景区名称
    //默认为景区列表的第一个景点
    _NameBtn = [ZZLingHelp createButtonWithFrame:CGRectZero target:self methed:@selector(NameClick:) normalImageName:nil hightImageName:nil title:nil];
    _NameBtn.tag = 11111;
//    [_NameBtn setTitle:@"风月江天贮楼" forState:UIControlStateNormal];
    [_NameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _NameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [footView addSubview:_NameBtn];
    

    
    //竖线2
    UIView * lineView2 = [ZZLingHelp createViewWithFrame:CGRectZero backGroudColor:nil backGroudImage:@"foot_cutline.png" RoundOftheDegree:0.0];
    [footView addSubview:lineView2];
    
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(footView.mas_right).offset(-58);
        make.top.equalTo(footView.mas_top).offset(10);
        make.width.equalTo(@2);
        make.height.equalTo(@25);
    }];
    
    [_NameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(senicView.mas_right).offset(5);
        make.right.equalTo(lineView2.mas_left).offset(-2);
        make.top.equalTo(footView);
        make.bottom.equalTo(footView);
    }];
    
    
    
    //自动导航  AutoNavigate
    
    UIButton * AutoNavigateBtn = [ZZLingHelp createButtonWithFrame:CGRectZero target:self methed:@selector(autoNavigate:) normalImageName:@"foot_swith_off.png" hightImageName:@"foot_swith_on.png" title:@"手动导航"];
    AutoNavigateBtn.tag = 700;
    
    [footView addSubview:AutoNavigateBtn];
    [AutoNavigateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footView.mas_top).offset(0);
        make.right.equalTo(footView.mas_right).offset(0);
        make.width.equalTo(@58);
        make.height.equalTo(@45);
    }];
    //    UIEdgeInsetsMake(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
    //    设置  自动导航  文字
    AutoNavigateBtn.imageEdgeInsets= UIEdgeInsetsMake(8, 16, 25, 17);
    AutoNavigateBtn.titleEdgeInsets = UIEdgeInsetsMake(28, -30,10, -6);
    AutoNavigateBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [AutoNavigateBtn setTitleColor:[UIColor colorWithRed:0.549 green:0.549 blue:0.549 alpha:1.0] forState:UIControlStateNormal];
    
    
#pragma mark-----------------消息的按钮
    UIButton * MassegeBtn = [ZZLingHelp createButtonWithFrame:CGRectZero target:self methed:@selector(MassegeBtnClick:) normalImageName:@"btn_chat.png" hightImageName:@"btn_chat.png" title:nil];
    MassegeBtn.hidden = YES;
    [self addSubview:MassegeBtn];
    [MassegeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-10);
        make.bottom.equalTo(footView.mas_top).offset(-20);
        make.width.equalTo(@35);
        make.height.equalTo(@35);
    }];
    
    _massgeBtn = MassegeBtn;
#pragma ---------------------------消息来时的小红点，自定义小红点的状态
    
    UIImageView  * MassegeDot = [[UIImageView alloc] initWithFrame:CGRectZero];
    UIImage * image = [UIImage imageNamed:@"top_circle_y.png"];
    MassegeDot.image = image;
    [MassegeBtn addSubview:MassegeDot];
    [MassegeDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(MassegeBtn);
        make.top.equalTo(MassegeBtn.mas_top).offset(5);
        make.width.equalTo(@6);
        make.height.equalTo(@6);
    }];

}
#pragma mark --------  消息来时调用
-(void)createMesssge{
 
    
    
}

//自动导览
-(void)autoNavigate:(UIButton*) sender {
    if (!sender.selected) {
        sender.selected=YES;
        [sender setTitleColor:[UIColor colorWithRed:0.9961 green:0.7647 blue:0.1569 alpha:1.0] forState:UIControlStateSelected];
        [sender setTitle:@"自动导航" forState:UIControlStateSelected];

//        [self findCurrentSoptScence];
        
    }else
    {
        
        sender.selected=NO;
        [sender setTitleColor:[UIColor colorWithRed:0.549 green:0.549 blue:0.549 alpha:1.0] forState:UIControlStateNormal];
        _isAuto = sender.selected;
        
    }
    
    _isAuto = sender.selected;
    openLocation = 1;
    if ([self.delegate respondsToSelector:@selector(openTheAuto:)]) {
        [self.delegate openTheAuto:_isAuto];
        
    }

    
    
    
}


-(void)recieveBssidNoti:(NSNotification*) noti{

    NSLog(@"----%@",noti.object);
    
//    if ([noti.object isEqualToString:@""]) {
//        _isAuto = YES;
//        
//    }else{
//        _isAuto = NO;
    
    NSString * BssidNum = noti.object;
    NSInteger i = [BssidNum integerValue];
    NSLog(@"--=========--=-==-=-=-=-= %ld",(long)i);
    if (!self.AboutNumBssidArr) {
        
        self.AboutNumBssidArr = [NSMutableArray arrayWithCapacity:0];
        [self.AboutNumBssidArr addObject:BssidNum];
        
        AllDateModel * model = _class_A_Arr[i];
        _model1 = model;
        [self createPlayView:model];
        [_mapImageView addSubview:_PlayView];
        [_mapImageView bringSubviewToFront:_PlayView];

    }else{
    
        for (int j = 0; j < self.AboutNumBssidArr.count; j++) {
            
            if ([BssidNum isEqualToString:self.AboutNumBssidArr[j]]) {
                
            }else{
                
                NSArray *subViews = [_PlayView subviews];
                NSLog(@"---%@",subViews);
                if([subViews count] != 0) {
                    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }
                AllDateModel * model = self.class_A_Arr[i];
                _model1 = model;
                [self createPlayView:model];
                [_mapImageView addSubview:_PlayView];
                [_mapImageView bringSubviewToFront:_PlayView];
                
                [self.AboutNumBssidArr removeAllObjects];
                [self.AboutNumBssidArr addObject:BssidNum];
                

                }
        }
    }
    
    
    if ([_BssidNum isEqualToString:BssidNum] ) {
        
    }else{
     
    _mp3PalyBtn =(Mp3PlayerButton *) [_PlayView viewWithTag:100];
    AllDateModel * classAModel = self.class_A_Arr[i];
        
//    UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:classAModel.name message:[NSString stringWithFormat:@"audioURL:%@\n\nbox_id:%@\n\nbox_mac:%@\n\nguide_id:%@\n\np_id:%@\n\n",classAModel.audioURL,classAModel.box_id,classAModel.box_mac,classAModel.guide_id,classAModel.p_id] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
//    [alert1 show];
//    alert1.tag = 888;
//    [self addSubview:alert1];
        
        
//    底部按钮
    [_NameBtn setTitle:classAModel.name forState:UIControlStateNormal];
        
    NSLog(@"===-=======%@",classAModel.audioURL);
    NSLog(@"======--====%@",classAModel.guide_id);
    NSURL * audioUrl = [NSURL URLWithString:classAModel.audioURL];
    _mp3PalyBtn.mp3URL = audioUrl;
    _mp3PalyBtn.secondCacheFolderName = classAModel.guide_id;
    _mp3PalyBtn.musicName = classAModel.guide_id;
    
//    [self playMusic:_mp3PalyBtn];
    if (_player.playState == NCMusicEnginePlayStatePlaying) {
        NSLog(@"12345678900987654321");
        [_player stop];
        _player = nil;
    }
    if (_player == nil) {
        
        _player = [[NCMusicEngine alloc] initWithSetBackgroundPlaying:YES];
        _player.delegate = self;
        _player.cacheFolderName = self.jqid;
        _player.secondCacheFolderName = classAModel.guide_id;
        _player.musicName = classAModel.guide_id;
        _player.button = _mp3PalyBtn;
        [_player.button setBackgroundImage:_mp3PalyBtn.pauseImage forState:UIControlStateNormal];
    }
    
    if ([_player.button isEqual:_mp3PalyBtn]) {
        _player.cacheFolderName = self.jqid;
        _player.secondCacheFolderName = classAModel.guide_id;
        _player.musicName = classAModel.guide_id;
        [_player.button setBackgroundImage:_mp3PalyBtn.pauseImage forState:UIControlStateNormal];
        [_player playUrl:audioUrl];
        if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
            NSLog(@"8765432");
            [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:classAModel];
            
        }
        
    }
        
        _BssidNum = BssidNum;
        
 }
    
    
    if ([_BssidNum isEqualToString:BssidNum] ) {
        
    }else{
    
    if(_player.playState == NCMusicEnginePlayStateEnded|| _player.playState ==NCMusicEnginePlayStateStopped){
        
        _mp3PalyBtn =(Mp3PlayerButton *) [_PlayView viewWithTag:100];
        AllDateModel * classAModel = self.class_A_Arr[i];
        NSURL * audioUrl = [NSURL URLWithString:classAModel.audioURL];
        _mp3PalyBtn.mp3URL = audioUrl;
        _mp3PalyBtn.secondCacheFolderName = classAModel.guide_id;
        _mp3PalyBtn.musicName = classAModel.guide_id;


        if (_player.playState == NCMusicEnginePlayStatePlaying) {
            NSLog(@"12345678900987654321");
            [_player stop];
            _player = nil;
        }
        if (_player == nil) {
            
            _player = [[NCMusicEngine alloc] initWithSetBackgroundPlaying:YES];
            _player.delegate = self;
            _player.cacheFolderName = self.jqid;
            _player.secondCacheFolderName = classAModel.guide_id;
            _player.musicName = classAModel.guide_id;
            _player.button = _mp3PalyBtn;
            [_player.button setBackgroundImage:_mp3PalyBtn.pauseImage forState:UIControlStateNormal];
        }
        
        if ([_player.button isEqual:_mp3PalyBtn]) {
            _player.cacheFolderName = self.jqid;
            _player.secondCacheFolderName = classAModel.guide_id;
            _player.musicName = classAModel.guide_id;
            [_player.button setBackgroundImage:_mp3PalyBtn.pauseImage forState:UIControlStateNormal];
            [_player playUrl:audioUrl];
            if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
                NSLog(@"8765432");
                [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:classAModel];
                
            }
            
        }
        
        _BssidNum = BssidNum;
    }
    
    }
    
    if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
        NSLog(@"8765432");
        [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:_model1];
        
    }
    

}


-(void)recieveLocationNoti:(NSNotification*) noti {
    
    NSDictionary * locationDic = noti.object;
    NSLog(@"locationDic %@",locationDic);
    self.loacationDic = locationDic;
//    [self findMyPosition];
    NSLog(@"%d",_isLocation);
    
    
    if (_isLocation) {
        
        [self findCurrentSoptScence];
    }
    
    if (_BssicFindMy) {
        [self findMyPosition];
        
    }
    
    
}


//底部定位的按钮
-(void)lacationButtonClick:(UIButton*)sender{
    NSLog(@"%s",__func__);

    if (sender.selected) {
        NSLog(@"yes");
        
//        在不点击的情况下会显示我的位置，故在sender.selected==YES时，我的位置消失，为NO时，出现
        
        _isMyPosition = NO;
        _BssicFindMy = NO;
        [_myLocationBtn removeFromSuperview];
        sender.selected = NO;
        
        
    }else{
        NSLog(@"no");
        
        _isMyPosition = YES;
        //限定
        myPositionFirst = 1;
        _BssicFindMy = YES;
        openLocation = 1;
        
        [self findMyPosition];
        sender.selected = YES;
        
    
    }
    

}

#pragma mark -------------------------我的位置

-(void)findMyPosition{
    
    NSLog(@"%@",self.loacationDic);
    NSLog(@"==%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"location"]);
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"location"] isEqualToString:@"unabled"]) {
        if ([self.delegate respondsToSelector:@selector(openThelocation:)]) {
            [self.delegate openThelocation:openLocation];
        }
        openLocation ++;
        
    }else{
    
    if (self.loacationDic != nil) {
        
    _postionLocation = [[CLLocation alloc] initWithLatitude:[[self.loacationDic objectForKey:@"latitude"]doubleValue ] longitude:[[self.loacationDic objectForKey:@"longitude"] doubleValue]];
    NSLog(@"postionLocation  %@",_postionLocation);
    }
    
        int index = [self pointListArrWithTheLocationMessage:_postionLocation];
    
//        NSLog(@"%f %f",[[self.pointListArr[index] objectForKey:@"latitude"] doubleValue],[[self.pointListArr[index] objectForKey:@"longitude"]doubleValue]);
    
       NSLog(@"-index======%d",index);
    
        if (index < 0) {
            
            if(myPositionFirst==1 || CGS_First == 1){
            if ([self.delegate respondsToSelector:@selector(pointOutTheAlerView:)]) {
                [self.delegate pointOutTheAlerView:index];
            }
                myPositionFirst++;
                
            }
            
            UIButton * sender = (UIButton*)[_footView viewWithTag:700];
            sender.selected=NO;
            [sender setTitleColor:[UIColor colorWithRed:0.549 green:0.549 blue:0.549 alpha:1.0] forState:UIControlStateNormal];
            if ([self.delegate respondsToSelector:@selector(closeTheTimer)]) {
                [self.delegate closeTheTimer];
                
            }
            NSLog(@"不在景区");
            
        }else{
    
            NSLog(@"----=========-------%ld",self.pointListArr.count);
            
            
            if (self.pointListArr.count<=0) {
#pragma mark ------------当pointList为0时
                
                
                AllDateModel * modelA = self.class_A_Arr[index];
                if (_myLocationBtn != nil) {
                    [_myLocationBtn removeFromSuperview];
                }
                _myLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _myLocationBtn.frame = CGRectMake([modelA.map_X floatValue]* _ScaleX-15 , [modelA.map_Y floatValue]* _ScaleY -20 , 30 * self.zoomScale, 33 * self.zoomScale);
                [_myLocationBtn setImage:[UIImage imageNamed:@"map_icon_me"] forState:UIControlStateNormal];
                NSLog(@"---%@,----- %@",modelA.map_X, modelA.map_Y);
                [_mapImageView addSubview:_myLocationBtn];

                
                
            }else{
                
            PointListModel * pointModel = self.pointListArr[index];
            
            if (_myLocationBtn != nil) {
                [_myLocationBtn removeFromSuperview];
            }
            
            _myLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _myLocationBtn.frame = CGRectMake([pointModel.map_X floatValue]* _ScaleX-15 , [pointModel.map_Y floatValue]* _ScaleY -20 , 30 * self.zoomScale, 33 * self.zoomScale);
            [_myLocationBtn setImage:[UIImage imageNamed:@"map_icon_me"] forState:UIControlStateNormal];
            NSLog(@"---%@,----- %@",pointModel.map_X, pointModel.map_Y);
            [_mapImageView addSubview:_myLocationBtn];
//            移动位置
//            self.mapScrollView.contentOffset = CGPointMake((_mapImageView.frame.size.width - _mapScrollView.frame.size.width) / 2.0, (_mapImageView.frame.size.height - _mapScrollView.frame.size.height)/ 2.0);
//            [self moveTheBtnPosition:_myLocationBtn];
         }
        }
    }
}

#pragma mark --------按钮偏移至屏幕中间
-(void)moveTheBtnPosition:(UIButton *) sender{

    float x , y;
    if ((sender.center.x /self.zoomScale- _mapScrollView.center.x)<0) {
        x=0;
    }else if ((sender.center.x / self.zoomScale- _mapScrollView.center.x) >( _mapImageView.frame.size.width  -_mapScrollView.frame.size.width))
    {
       x= _mapImageView.frame.size.width  -_mapScrollView.frame.size.width;
        
    }else{
       x=(sender.center.x / self.zoomScale - _mapScrollView.center.x) ;
    }
    
    if ((sender.center.y  /self.zoomScale- _mapScrollView.center.y) < 0) {
        y = 0;
    }else if((sender.center.y / self.zoomScale- _mapScrollView.center.y) >( _mapImageView.frame.size.height -_mapScrollView.frame.size.height )){
        
        y = _mapImageView.frame.size.height -_mapScrollView.frame.size.height;
    }else{
        
        y = (sender.center.y  /self.zoomScale - _mapScrollView.center.y);
    }
    
    self.mapScrollView.contentOffset = CGPointMake(x , y);


}


-(int) pointListArrWithTheLocationMessage:(CLLocation * ) postionLocation{
    
//    相隔的最小距离
    
    if (!self.pointListArr) {
        self.pointListArr = [NSKeyedUnarchiver unarchiveObjectWithFile:POINTLIST];
        NSLog(@"%@",self.pointListArr);
    }
    
    double min = MAXFLOAT;
    int j = 0;
    for (int i = 0; i < self.pointListArr.count; i++) {
       PointListModel *  pointListModel = self.pointListArr[i];
        CLLocation * Location = [[CLLocation alloc] initWithLatitude:[pointListModel.GPS_X doubleValue] longitude:[pointListModel.GPS_Y doubleValue]];
        
        
//        CLLocationDistance kilometers = [postionLocation distanceFromLocation:Location] / 1000;
        CLLocationDistance kilometers = [postionLocation distanceFromLocation:Location];
        NSLog(@"%f",kilometers);
        
        if (kilometers<min) {
            min=kilometers;
            if (min>500) {
                
                j=-1;
                
            }else{
                
                j=i;
                
            }
        }
        
    }
    
    if (j == -1) {
        int index = [self guideListWithTheLoctionMession:postionLocation];
        j = index;
    }
    
    //pointList为空
    if(self.pointListArr.count<1){
        int index1 = [self guideListWithTheLoctionMession:postionLocation];
        j=index1;
        
    }
        return j;

}

-(int)guideListWithTheLoctionMession:(CLLocation*)postionLocation{

    double min = MAXFLOAT;
    int j = 0;
    for (int i = 0; i < self.class_A_Arr.count; i++) {
        AllDateModel *  A_Model = self.class_A_Arr[i];
        CLLocation * Location = [[CLLocation alloc] initWithLatitude:[A_Model.latitude doubleValue] longitude:[A_Model.longitude doubleValue]];
        
        //        CLLocationDistance kilometers = [postionLocation distanceFromLocation:Location] / 1000;
        CLLocationDistance kilometers = [postionLocation distanceFromLocation:Location];
        
        if (kilometers<min) {
            min=kilometers;
            if (min>500) {
                
                j=-1;
                
            }else{
                j=i;
                
            }
        }
        
    }
    if (self.class_A_Arr.count<1) {
        
        j = -1;
    }
    return j;
    
}

#pragma mark ---- -------------------CPS导览
-(void) findCurrentSoptScence{
    
    pause1: sleep(2);
    
    NSLog(@"%@",self.loacationDic);
    //没有开启定位
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"location"] isEqualToString:@"unabled"]) {
//        提示开启定位
        if ([self.delegate respondsToSelector:@selector(openThelocation:)]) {
            [self.delegate openThelocation:openLocation];
        }
//        自动导览变换为手动导览
        UIButton * sender = (UIButton*)[_footView viewWithTag:700];
        sender.selected=NO;
        [sender setTitleColor:[UIColor colorWithRed:0.549 green:0.549 blue:0.549 alpha:1.0] forState:UIControlStateNormal];
//        关闭定时器
        if ([self.delegate respondsToSelector:@selector(closeTheTimer)]) {
            [self.delegate closeTheTimer];
        }
        openLocation ++;
        
    }else{
    
    if (self.loacationDic != nil) {
        
        _postionLocation = [[CLLocation alloc] initWithLatitude:[[self.loacationDic objectForKey:@"latitude"]doubleValue ] longitude:[[self.loacationDic objectForKey:@"longitude"] doubleValue]];
        NSLog(@"postionLocation  %@",_postionLocation);
        
        if([[self.loacationDic objectForKey:@"latitude"]isEqualToString:@"0.0"] && [[self.loacationDic objectForKey:@"longitude"] isEqualToString:@"0.0"]){
            
            NSLog(@"12345678o");
            
            goto pause1;
        }
        
    int index = [self pointListArrWithTheLocationMessage:_postionLocation];
    NSLog(@"index======%d",index);
    
    if (index < 0) {
        
        if (first == 1) {
//            if ([self.delegate respondsToSelector:@selector(pointOutTheAlerView:)]) {
//                [self.delegate pointOutTheAlerView:index];
//            }
            NSLog(@"不在景区");
            first++;
            CGS_First ++;
            
            UIButton * sender = (UIButton*)[_footView viewWithTag:700];
            sender.selected=NO;
            [sender setTitleColor:[UIColor colorWithRed:0.549 green:0.549 blue:0.549 alpha:1.0] forState:UIControlStateNormal];
            if ([self.delegate respondsToSelector:@selector(closeTheTimer)]) {
                [self.delegate closeTheTimer];
                
            }

            
        }
        
    }else{
        
        if (_isMyPosition) {
            [self findMyPosition];
            if (CGS_First == 1) {
                
                CGS_First++;
            }
            
        }
        int min = 30;
        
        for (int i = 0; i < self.class_A_Arr.count; i++) {
            
            AllDateModel * classAModel = self.class_A_Arr[i];
            CLLocation * location = [[CLLocation alloc] initWithLatitude:[classAModel.latitude doubleValue] longitude:[classAModel.longitude doubleValue]];
            CLLocationDistance meters = [_postionLocation distanceFromLocation:location];
            if (meters <= min) {
                min = meters;
                _index = i;
                continue;
            }
        }
        
        if (_currentIndex != _index) {
            
            _currentIndex = _index;
            
            AllDateModel * classAModel = self.class_A_Arr[_currentIndex];
            
//            UIAlertView * alert2 = [[UIAlertView alloc] initWithTitle:classAModel.name message:[NSString stringWithFormat:@"audioURL:%@\n\nbox_id:%@\n\nbox_mac:%@\n\nguide_id:%@\n\np_id:%@\n\n",classAModel.audioURL,classAModel.box_id,classAModel.box_mac,classAModel.guide_id,classAModel.p_id] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
//            [alert2 show];
//            alert2.tag = 887;
//            [self addSubview:alert2];

            
            
            [_NameBtn setTitle:classAModel.name forState:UIControlStateNormal];
            
//            UIButton * button = _allBtnArr[_currentIndex];
            _PlayView.hidden = NO;
            _model1 = classAModel;
            [self createPlayView:classAModel];
            [_mapImageView addSubview:_PlayView];
            [_mapImageView bringSubviewToFront:_PlayView];
            _mp3PalyBtn =(Mp3PlayerButton *) [_PlayView viewWithTag:100];
            
            NSLog(@"classAModel.audioURL===-=======%@",classAModel.audioURL);
            NSLog(@"classAModel.guide_id======--====%@",classAModel.guide_id);
            NSURL * audioUrl = [NSURL URLWithString:classAModel.audioURL];
            _mp3PalyBtn.mp3URL = audioUrl;
            _mp3PalyBtn.secondCacheFolderName = classAModel.guide_id;
            _mp3PalyBtn.musicName = classAModel.guide_id;
            
//            [self playMusic:_mp3PalyBtn];
            if (_player.playState == NCMusicEnginePlayStatePlaying) {
                [_player stop];
                _player = nil;
            }
            if (_player == nil) {
                _player = [[NCMusicEngine alloc] initWithSetBackgroundPlaying:YES];
                _player.delegate = self;
                _player.cacheFolderName = self.jqid;
                _player.secondCacheFolderName = classAModel.guide_id;
                _player.musicName = classAModel.guide_id;
                _player.button = _mp3PalyBtn;
                [_player.button setBackgroundImage:_mp3PalyBtn.pauseImage forState:UIControlStateNormal];
//                [_player playUrl:_mp3PalyBtn.mp3URL];
//                [_mp3PalyBtn setBackgroundImage:_mp3PalyBtn.pauseImage forState:UIControlStateSelected];
                
            }
            
            if ([_player.button isEqual:_mp3PalyBtn]) {
                _player.cacheFolderName = self.jqid;
                _player.secondCacheFolderName = classAModel.guide_id;
                _player.musicName = classAModel.guide_id;
                [_player.button setBackgroundImage:_mp3PalyBtn.pauseImage forState:UIControlStateNormal];
                [_player playUrl:audioUrl];
                
                
                if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
                    NSLog(@"123456789");
                    [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:classAModel];
                    
                }
            }
            
            
            
            if(_player.playState == NCMusicEnginePlayStateEnded|| _player.playState ==NCMusicEnginePlayStateStopped){
                _mp3PalyBtn =(Mp3PlayerButton *) [_PlayView viewWithTag:100];
                if (_player.playState == NCMusicEnginePlayStatePlaying) {
                    [_player stop];
                    _player = nil;
                }
                
                if (_player == nil) {
                    _player = [[NCMusicEngine alloc] initWithSetBackgroundPlaying:YES];
                    _player.delegate = self;
                    _player.cacheFolderName = self.jqid;
                    _player.secondCacheFolderName = classAModel.guide_id;
                    _player.musicName = classAModel.guide_id;
                    _player.button = _mp3PalyBtn;
                    [_player.button setBackgroundImage:_mp3PalyBtn.pauseImage forState:UIControlStateNormal];
                  //[_player playUrl:_mp3PalyBtn.mp3URL];
                  //[_mp3PalyBtn setBackgroundImage:_mp3PalyBtn.pauseImage forState:UIControlStateSelected];
                }
                
                _player.button = _mp3PalyBtn;
                if ([_player.button isEqual:_mp3PalyBtn]) {
                    _player.cacheFolderName = self.jqid;
                    _player.secondCacheFolderName = classAModel.guide_id;
                    _player.musicName = classAModel.guide_id;
                    [_player.button setBackgroundImage:_mp3PalyBtn.pauseImage forState:UIControlStateNormal];
                    [_player playUrl:audioUrl];
                    
                    
                    if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
                        NSLog(@"123456789");
                        [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:classAModel];
                        
                    }
                    
                }
            
            }

            
        }
        
    }
    
    }
    
    if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
        [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:_model1];
        
    }
    
    }


}

//-(int)guideListArrWithTheLocationMessage:(CLLocation * ) postionLocation{
//    
////最小距离
//    
//    double min = 500;
//    int j = 0;
//    for (int i = 0; i < self.class_A_Arr.count; i++) {
//        AllDateModel *  classAModel = self.class_A_Arr[i];
//        CLLocation * Location = [[CLLocation alloc] initWithLatitude:[classAModel.latitude doubleValue] longitude:[classAModel.longitude doubleValue]];
//        
//        CLLocationDistance kilometers = [postionLocation distanceFromLocation:Location] / 1000;
//        if (kilometers < min) {
//            
//            min = kilometers;
//            
//            j = i;
//        }else{
//            j = -1;
//        }
//    }
//    
//    return j;
//
//
//
//
//
//}



//底部景点名称
-(void)NameClick:(UIButton *) NameButtn{
    
    
    if (_i % 2 ) {
        _tableView.hidden = NO;
        _i = _i+1;
        
    }else {
        _tableView.hidden = YES;
    
        _i= _i + 1;
    }
    
}

//单击手势，用于顶部多功能的ScrollView 缩
-(void)tap:(UITapGestureRecognizer* )tap{
    NSLog(@"%s",__func__);
    
    if (!_showTheView) {
        
        [self hiddenTheScrollView];
        
    }
    
    _tableView.hidden = YES;
    
}
//展示  顶部多功能的ScrollView 放
-(void)showOrHiddenTheView{
    
    [self showTheScrollView];
    
    
}
//顶部多功能按钮
-(void)multifunctionalButtonClick:(UIButton *) sender{
    
    //    UIButton * button = sender.tag;
    NSLog(@"===============%lu",sender.tag);
    switch (sender.tag) {
            //            导览
        case 100:
            if (!_showTheView) {
                [self hiddenTheScrollView];
            }
            if(self.class_A_Arr.count >0){
                
                NSArray * subViews = [_mapImageView subviews];
                if ([subViews count]!= 0) {
                    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }
                _slideBarView.hidden = YES;
                UIButton * OtherBtn = (UIButton*)[_superSiderView viewWithTag:999];
                [OtherBtn setImage:[UIImage imageNamed:@"map_btn_message_nor"] forState:UIControlStateNormal];
                OtherBtn.selected = YES;
                
                _roadView.hidden = YES;
                UIButton * roadBtn = (UIButton*)[_superSiderView viewWithTag:998];
                [roadBtn setImage:[UIImage imageNamed:@"map_btn3_nor"] forState:UIControlStateNormal];
                roadBtn.selected = YES;
                
                [self returnToOriginalImage];
                
                
                [self addAttractionsButton];
                
                
            }
            
            break;
            //            景区概况
        case 101:
            if (!_showTheView) {
                [self hiddenTheScrollView];
                if ([self.delegate respondsToSelector:@selector(enterSceneGenetalViewController)]) {
                    [self.delegate enterSceneGenetalViewController];
                }
                
            }
            break;
            //            微游记
        case 102:
            if (!_showTheView) {
                [self hiddenTheScrollView];
                if ([self.delegate respondsToSelector:@selector(enterTravelViewController)]) {
                    [self.delegate enterTravelViewController];
                }
                
            }
            break;
            //            脱口秀
        case 103:
            if (!_showTheView) {
                [self hiddenTheScrollView];
                if ([self.delegate respondsToSelector:@selector(enterSpeechViewController)]) {
                    [self.delegate enterSpeechViewController];
                }
            }
            break;
//            //            涂鸦
//        case 104:
//            if (!_showTheView) {
//                [self hiddenTheScrollView];
//            }
//            break;
//            //            知乎
//        case 105:
//            if (!_showTheView) {
//                [self hiddenTheScrollView];
//               
//
//            }
//            break;
            //            评论
        case 104:
            if (!_showTheView) {
                [self hiddenTheScrollView];
                if ([self.delegate respondsToSelector:@selector(enterCommetViewController)]) {
                    [self.delegate enterCommetViewController];
                }
            }
            break;
//            //            求助
//        case 107:
//            if (!_showTheView) {
//                [self hiddenTheScrollView];
//            }
//            break;
            //            离线下载
        case 105:
            if (!_showTheView) {
                
                NSLog(@"maasd%@",_spotInfoArr);
                if (_downBtn.selected) {
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"是否删除离线包" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [alertView show];
                    alertView.tag=111;
                    [self addSubview:alertView];
                   
                    
                     }else{
                  
                         AllDateModel *model=_spotInfoArr[0];
                        
                         
                        float size = [model.zipUrlSize floatValue];
                         NSString *title=[NSString stringWithFormat:@"下载离线包需消耗%.2fM流量,建议在WiFi环境下下载",(size/1024)/1024];
                         
                         UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                         [alertView show];
                         alertView.tag=222;
                         [self addSubview:alertView];
                }
                
               
            }
            break;
            //            敬请期待
        case 106:
            if (!_showTheView) {
                [self hiddenTheScrollView];
            }
            break;
        default:
            break;
    }
    
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==111) {
        if (buttonIndex==1) {
            NSLog(@"删除离线bao");
            
            NCMusicEngine *music=[[NCMusicEngine alloc]init];
            
            NSString *path=[music cacheFolderZip];
            NSString *file2=[NSString stringWithFormat:@"/%@",self.jqid];
            
           
            NSString *filePath2=[path stringByAppendingString:file2];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:filePath2];
            if (bRet) {
                //删除zip包
                NSError *err;
               BOOL su =  [fileMgr removeItemAtPath:filePath2 error:&err];
             
                if (su) {
                    //删除状态
                    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:DOWNSTATE];
                    NSMutableArray *muarry = [NSMutableArray arrayWithArray:array];
                    for (int i=0; i<muarry.count; i++) {
                        NSDictionary *dict=muarry[i];
                        if ([[dict objectForKey:@"down"] isEqualToString:self.jqid]) {
                            [muarry removeObjectAtIndex:i];
                        }
                    }
                    
                    [NSKeyedArchiver archiveRootObject:muarry toFile:DOWNSTATE];
                    
                    
                    NSMutableArray *a = [NSKeyedUnarchiver unarchiveObjectWithFile:DOWNSTATE];
                    NSLog(@"---------%@",a);
                    
                    
                    _downBtn.selected=NO;
                    _downLabel.text=@"音频下载";

                }
                
            }

            
            
        }
    }else if (alertView.tag==222)
    {
        if (buttonIndex==1) {
            
            NSFileManager * fileManager = [NSFileManager defaultManager];
            // 获取Caches目录路径
            NSString *cacheDir = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
            
            NSString *  cacheFolder = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"音乐/%@",_jqid]];
            
            [fileManager removeItemAtPath:cacheFolder error:nil];
            
            
            
            percent=0;
            _progressView.percent=0;
             _progressView.hidden=NO;
            AllDateModel *model=_spotInfoArr[0];
            [self downloadFile2WithUrl:model.zipUrl];
            _timer=[NSTimer scheduledTimerWithTimeInterval:0.01
                                                    target:self
                                                  selector:@selector(changeTime)
                                                  userInfo:nil
                                                   repeats:YES];

        }
    
    }else if (alertView.tag == 888){
    
        if (buttonIndex == 0) {
            
        }
    
    
    
    }else if (alertView.tag == 887){
    
        if (buttonIndex == 0) {
            
        }
    
    }

}

//- (void)downloadFile
//{
//    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/post/abc/07.mp4"] cachePolicy:1 timeoutInterval:6];
//    
//    [[manger downloadTaskWithRequest:request progress:NULL destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
//        NSURL *url = [NSURL fileURLWithPath:filePath];
//        return url;
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        NSLog(@"%@",error.localizedDescription);
//    }] resume];
//}

#pragma mark - 懒加载NSURLSession网络下载接口
// 懒加载NSURLSession
- (NSURLSession *)session
{
    if(_session == nil)
    {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return _session;
}

/**
 *  使用代理监控下载进度
 */
#pragma mark - 离线下载
- (void)downloadFile2WithUrl:(NSString *)zipUrl
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:zipUrl] cachePolicy:1 timeoutInterval:60];
    _request=request;
    [[self.session downloadTaskWithRequest:request]resume];
}

#pragma mark - 离线下载的代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
//    NSString *pathFile = [NSTemporaryDirectory() stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSFileManager *manger = [NSFileManager defaultManager];
    NSLog(@"---location---%@",location.path);
   
    NCMusicEngine *music=[[NCMusicEngine alloc]init];
    //NSString *path=[music zipFilePathWithCacheKey:self.jqid];
    //NSString *zipPath=[path  stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSString *path=[music cacheFolderZip];
    NSString *fileName=[NSString stringWithFormat:@"/%@.zip",self.jqid];

    NSString *zippath=[path stringByAppendingString:fileName];
    NSLog(@"zippath--%@",zippath);
    //[manger copyItemAtPath:location.path toPath:zippath error:NULL];
    [manger moveItemAtPath:location.path toPath:zippath error:NULL];
    //解压
    ZipArchive *za = [[ZipArchive alloc] init];
    
    if([za UnzipOpenFile:zippath])
    {
        
        //压缩包释放到的位置，需要一个完整路径
        //-(BOOL) UnzipFileTo:(NSString*) path overWrite:(BOOL) overwrite;
//        NSString *file=[NSString stringWithFormat:@"/%@",self.jqid];
//        NSString *outpath=[path stringByAppendingString:file];
        
        BOOL ret = [za UnzipFileTo:path overWrite:YES];
        if( NO==ret )
        {
        
        }
        BOOL success =  [za UnzipCloseFile];
        NSLog(@"Zipped file with result %d",success);
        
        if (success) {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:zippath];
            if (bRet) {
                //删除zip包
                NSError *err;
                [fileMgr removeItemAtPath:zippath error:&err];
            }
            //重命名
            NSString *file1=@"/a";
            NSString *file2=[NSString stringWithFormat:@"/%@",self.jqid];

            NSString *filePath1=[path stringByAppendingString:file1];
            NSString *filePath2=[path stringByAppendingString:file2];
            if ([fileMgr moveItemAtPath:filePath1 toPath:filePath2 error:nil] != YES)
            {
                NSLog(@"重命名失败");
                
                BOOL bRet = [fileMgr fileExistsAtPath:filePath1];
                if (bRet) {
                    //删除zip包
                    NSError *err;
                    [fileMgr removeItemAtPath:filePath1 error:&err];
                }

                
            }
            

        }
        
    }
    

}
// 进度数据
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    //
    NSLog(@"sd%f",progress);
   // percent=progress;
    if (progress==1) {
        
         [self finishDown];
        
    }
//    int per=progress*1000;
//    NSLog(@"int%d",per);
//    NSLog(@"=%f",percent);
//    if (per>percent) {
//        [self changeTime];
//        percent=per;
//    }
   percent=progress;
    
}
#pragma mark -暂停下载
- (void) pause{
    //暂停
    NSLog(@"暂停下载");
    [_task cancelByProducingResumeData:^(NSData *resumeData) {
        _data=resumeData;
    }];
    _task=nil;
}
- (void) resume{
    //恢复
    NSLog(@"恢复下载");
    if(!_data){
        AllDateModel *model=_spotInfoArr[0];
        NSURL *url=[NSURL URLWithString:model.zipUrl];
        _request=[NSURLRequest requestWithURL:url];
        _task=[_session downloadTaskWithRequest:_request];
    }else{
        _task=[_session downloadTaskWithResumeData:_data];
    }
    [_task resume];
}

-(void)changeTime
{
//    float per=percent/1000;
//    NSLog(@"%f",per);
    if (percent==1) {
        _downBtn.selected=YES;
        _downLabel.text=@"删除音频包";
        
        _progressView.hidden=YES;
        [_timer invalidate];
    }
    NSLog(@"---percent---%f",percent);
    _progressView.percent=percent;
    
}

-(void)finishDown
{
    
    
//    _downBtn.selected=YES;
//   _progressView.hidden=YES;
    
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:DOWNSTATE];
    NSMutableArray *muarry = [NSMutableArray arrayWithArray:array];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:self.jqid forKey:@"down"];
    [muarry addObject:dict];
    
    [NSKeyedArchiver archiveRootObject:muarry toFile:DOWNSTATE];
    
    
     NSMutableArray *a = [NSKeyedUnarchiver unarchiveObjectWithFile:DOWNSTATE];
                          NSLog(@"---------%@",a);

}



-(void)btnClickOfSlider:(UIButton *)sender{

    //线路
    if(sender.tag == 998){
            if(sender.selected == NO){
                [sender setImage:[UIImage imageNamed:@"map_btn3_nor"] forState:UIControlStateNormal];
                NSArray * subViews = [_mapImageView subviews];
                if ([subViews count]!= 0) {
                    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }
                [_roadView removeFromSuperview];
                
                //恢复原来的地图
                [self returnToOriginalImage];
            
                //添加所有的景点按钮
                [self addAttractionsButton];
                sender.selected = YES;
            }else{
                UIButton * button = (UIButton *) [_superSiderView viewWithTag:999];
                button.selected = YES;
                [button setImage:[UIImage imageNamed:@"map_btn_message_nor"] forState:UIControlStateNormal];
                [_slideBarView removeFromSuperview];
                
                
                [sender setImage:[UIImage imageNamed:@"map_btn3_down"] forState:UIControlStateNormal];
            
                if (_routeArr.count == 1) {
                   
//                    NSArray * subViews = [_mapImageView subviews];
//                    if ([subViews count]!= 0) {
//                        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//                    }
                    [self addAboutTheRoadImage];
                
                }
                else if(_routeArr.count>1){
                
#pragma mark  -------线路问题未完待续
                 [self addTheRoads];
                    
                }else{
                
                    NSLog(@"暂时没有数据");
                }

            
            sender.selected = NO;
        }
        
    
    }
    
    //感叹号
    if (sender.tag == 999) {
        
        if (sender.selected == NO) {
            [sender setImage:[UIImage imageNamed:@"map_btn_message_nor"] forState:UIControlStateNormal];
            NSArray * subViews = [_mapImageView subviews];
            if ([subViews count]!= 0) {
                [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            }
            
            [self returnToOriginalImage];
            
            
            [self addAttractionsButton];

            if (_slideBarView !=nil) {
                [_slideBarView removeFromSuperview];
            }
            sender.selected = YES;
            
        }else{
            
            UIButton * button = (UIButton *) [_superSiderView viewWithTag:998];
            button.selected = YES;
            [button setImage:[UIImage imageNamed:@"map_btn3_nor"] forState:UIControlStateNormal];
            [_roadView removeFromSuperview];
            
//            NSArray * subViews = [_mapImageView subviews];
//            if ([subViews count]!= 0) {
//                [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//            }
            
            [self addAttractionsButton];

            if (_slideBarView != nil ) {
                [_slideBarView removeFromSuperview];
            }
            [sender setImage:[UIImage imageNamed:@"map_btn_message_down"] forState:UIControlStateNormal];
            [self createThreeSiderBtn];
        
            sender.selected = NO;
        }
        
    }
    

}

-(void)addTheRoads{
    
//    UIView * rodaView = [[UIView alloc] initWithFrame:CGRectMake(WIDTH - 20-70, 220, 35, (_routeArr.count - 1)*10 + 35* _routeArr.count )];
    UIView * rodaView  = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:rodaView];
    _roadView = rodaView;
    NSInteger height = (_routeArr.count - 1)*10 + 35* _routeArr.count;
    __block NSInteger H = height;
    [_roadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo (_superSiderView.mas_top);
        make.right.equalTo(_superSiderView.mas_left).offset(-10);
        make.width.equalTo(@35);
        make.height.equalTo(@(H));

    }];
    if (_roadBtnArr != nil) {
        [_roadBtnArr removeAllObjects];
    }
    
    NSDictionary * numDic = @{@"1":@"一",@"2":@"二",@"3":@"三",@"4":@"四",@"5":@"五",@"6":@"六",@"7":@"七",@"8":@"八",@"9":@"九",@"10":@"十"};
    NSLog(@"numDic:%@",numDic);
    NSLog(@"%@",numDic[@"1"]);
#pragma mark ----未完待续
    for (int i = 0; i < _routeArr.count; i ++) {
        NSString * str = [NSString stringWithFormat:@"%d",i+1];
        UIButton * btn = [ZZLingHelp createButtonWithFrame:CGRectMake(0, i*45, 35, 35) target:self methed:@selector(roadBtnCilck:) normalImageName:nil hightImageName:nil title:[NSString stringWithFormat:@"线路%@",numDic[str]]];
        [btn setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
        btn.alpha = 0.7;
        [btn setBackgroundImage:[UIImage imageNamed:@"map_btn_road_bg"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:11];
        btn.tag = 150+i;
        [rodaView addSubview:btn];
        [_roadBtnArr addObject:btn];
    }
    
}



-(void)roadBtnCilck:(UIButton *)sender{
    

    for (int i = 0; i < _roadBtnArr.count; i++) {
       
        UIButton * button = _roadBtnArr[i];
        if ([button isEqual:sender]) {
            sender.selected = YES;
            button.selected = YES;
            NSLog(@"%ld",sender.tag);
            NSArray * subViews = [_mapImageView subviews];
            if ([subViews count]!= 0) {
                [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            }
            //改变地图饱和度
            [self changeImageColor];

            AllDateModel * model = _routeArr[i];
            UIImageView * imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:[NSURL URLWithString:model.routeURL]];
            imageView.frame = _mapImageView.bounds;
            [_mapImageView addSubview:imageView];
            
            if (imageView != nil) {
//                for (int i = 0; i < _class_A_Arr.count; i ++) {
//                    AllDateModel * model = _class_A_Arr[i];
//                    
//                    UIButton * JIQuBtn = [ZZLingHelp createButtonWithFrame:CGRectMake([model.map_X floatValue]* _ScaleX-15, [model.map_Y floatValue]* _ScaleY -20 , 30, 30) target:self methed:@selector(attractionsBtn:)normalImageName:@"map_icon_senic" hightImageName:@"map_icon_senic" title:nil];
//                    JIQuBtn.tag = [model.p_id integerValue] ;
//                    JIQuBtn.layer.cornerRadius = JIQuBtn.frame.size.height/2;
//                    JIQuBtn.layer.masksToBounds = YES;
//                    JIQuBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//                    JIQuBtn.layer.borderWidth = 0.0f;
//                    
//                    [imageView addSubview:JIQuBtn];
//                    
//                    
//                }
                [self addAttractionsButton];
                
            }else{
            
            }
            

            
        }else{
            button.selected = NO;
            NSLog(@"不是当前btn");
        }
        
    }
    
}

-(void)addAboutTheRoadImage{
    
    if (_routeArr.count == 1) {
        
        NSArray * subViews = [_mapImageView subviews];
        if ([subViews count]!= 0) {
            [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }

        AllDateModel * model = _routeArr[0];
        
        NSLog( @"%ld",(long)_RoadBtnTag);
        //改变地图饱和度
        [self changeImageColor];
        
        
        //线路图片添加
        UIImageView * imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:[NSURL URLWithString:model.routeURL]];
        
        //    imageView.frame = CGRectMake(0, 0, _mapImageView.frame.size.width, _mapImageView.frame.size.height);
        imageView.frame = _mapImageView.bounds;
        
        [_mapImageView addSubview:imageView];
        
        
        if (imageView != nil) {
//            for (int i = 0; i < _class_A_Arr.count; i ++) {
//                
//                
//                AllDateModel * model = _class_A_Arr[i];
//                
//                UIButton * JIQuBtn = [ZZLingHelp createButtonWithFrame:CGRectMake(0, 0 , 30, 40) target:self methed:@selector(attractionsBtn:)normalImageName:@"map_icon_senic" hightImageName:@"map_icon_senic" title:nil];
//                JIQuBtn.center = CGPointMake([model.map_X floatValue]* _ScaleX, [model.map_Y floatValue]* _ScaleY +20-(40*self.zoomScale)/2);
//                JIQuBtn.tag = i;
//                JIQuBtn.layer.cornerRadius = JIQuBtn.frame.size.height/2;
//                JIQuBtn.layer.masksToBounds = YES;
//                JIQuBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//                JIQuBtn.layer.borderWidth = 0.0f;
//                
//                [imageView addSubview:JIQuBtn];
//                
//                
//            }
//
            [self addAttractionsButton];
           
            
        }
    }
    
    
}

#pragma mark ------ 线路的点击事件
#if 0
-(void) setRoadTag:(NSInteger)roadTag{
    
    NSLog(@"roadTag%ld",(long)roadTag);
    NSLog(@"roadBtnSeleted%d",_roadBtnSeleted);
    
#pragma mark ------------------线路问题
    
    if (_roadView.hidden == NO) {
        if (_RoadBtnTag == 0) {
            _RoadBtnTag= roadTag;
            if (_roadBtnSeleted == YES) {
                NSArray * subViews = [_mapImageView subviews];
                if ([subViews count]!= 0) {
                    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }
                
                [self addAboutTheRoadImage];
            }else{
                NSArray * subViews = [_mapImageView subviews];
                if ([subViews count]!= 0) {
                    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }
                
            }
            
        }else if (_RoadBtnTag != 0 && _RoadBtnTag == roadTag){
            if ( _roadBtnSeleted == YES) {
                NSArray * subViews = [_mapImageView subviews];
                if ([subViews count]!= 0) {
                    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }
                
                [self addAboutTheRoadImage];
                
            }else{
                
                NSArray * subViews = [_mapImageView subviews];
                if ([subViews count]!= 0) {
                    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }
                
                [self addAttractionsButton];
                
            }
            
            
        }else if (_RoadBtnTag != 0 && _RoadBtnTag != roadTag){
            
            if (_roadBtnSeleted == YES) {
                NSArray * subViews = [_mapImageView subviews];
                if ([subViews count]!= 0) {
                    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }
                
                [self addAboutTheRoadImage];
            }else{
                NSArray * subViews = [_mapImageView subviews];
                if ([subViews count]!= 0) {
                    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }
                
                [self addAttractionsButton];
            }
        }
        
        
        
        
    }
}

#endif
#pragma mark -----创建侧边上   客流量、卫生间、商业
-(void)createThreeSiderBtn{

//    UIView * superView = [[UIView alloc] initWithFrame:CGRectMake(WIDTH - 20 -70, 30+100+35+10, 35, 125)];
    
    UIView * superView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:superView];
    _slideBarView = superView;
    [superView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_superSiderView.mas_top).offset(45);
        make.right.equalTo (_superSiderView.mas_left).offset(-10);
        make.width.equalTo(@35);
        make.height.equalTo(@125);
        
    }];
    
    NSLog(@"111111111-----%lu",(unsigned long)self.spotArr.count);
    NSLog(@"222222222=====%lu",(unsigned long)self.bussinessArr.count);
    NSLog(@"333333333######%lu",self.WcArr.count);
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"has_ibox"] isEqualToString:@"1"]) {
        
        [self loadScenicspot];
    }
    

    if(self.spotArr.count>0){
        //客流量>0
        UIButton * flowBtn = [ZZLingHelp createButtonWithFrame:CGRectMake(0 , 0, 35, 35) target:self methed:@selector(slidBarClick:) normalImageName:@"map_btn1_nor.png" hightImageName:@"map_btn1_down.png" title:nil];
        flowBtn.tag = 1001;
        flowBtn.alpha = 0.7;
        [_slideBarView addSubview:flowBtn];
        
        if (self.WcArr.count > 0) {
            //厕所>0
            UIButton * toiletBtn =[ZZLingHelp createButtonWithFrame:CGRectZero target:self methed:@selector(slidBarClick:) normalImageName:@"map_btn2_nor.png" hightImageName:@"map_btn2_down.png" title:nil ];
            toiletBtn.tag =1002;
            toiletBtn.alpha = 0.7;
            [_slideBarView addSubview:toiletBtn];
            //卫生间适配
            [toiletBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(flowBtn.mas_bottom).offset(10);
                make.right.equalTo(superView.mas_right);
                make.width.equalTo(flowBtn);
                make.height.equalTo(flowBtn);
            }];
            
            
            if (self.bussinessArr.count>0) {
                //商业>0
                UIButton * roadBtn = [ZZLingHelp createButtonWithFrame:CGRectZero target:self methed:@selector(slidBarClick:) normalImageName:@"map_btn_business_nor.png"hightImageName:@"map_btn_business_down.png" title:nil];
                roadBtn.tag = 1003;
                roadBtn.alpha = 0.7;
                [_slideBarView addSubview:roadBtn];
                //路线适配
                [roadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(toiletBtn.mas_bottom).offset(10);
                    make.right.equalTo(superView.mas_right);
                    make.width.equalTo(flowBtn);
                    make.height.equalTo(flowBtn);
                }];
                
            }else{
                
                
            }
            
        }else{
            
            if (self.bussinessArr.count>0) {
                //商业>0
                UIButton * roadBtn = [ZZLingHelp createButtonWithFrame:CGRectZero target:self methed:@selector(slidBarClick:) normalImageName:@"map_btn_business_nor.png"hightImageName:@"map_btn_business_down.png" title:nil];
                roadBtn.tag = 1003;
                roadBtn.alpha = 0.7;
                [_slideBarView addSubview:roadBtn];
                //路线适配
                [roadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(flowBtn.mas_bottom).offset(10);
                    make.right.equalTo(superView.mas_right);
                    make.width.equalTo(flowBtn);
                    make.height.equalTo(flowBtn);
                }];
                
            }else{
                
                
            }
            
        }
        
        
    }else{
        
        if (self.WcArr.count > 0) {
            //厕所>0
            UIButton * toiletBtn =[ZZLingHelp createButtonWithFrame:CGRectMake(0 , 0, 35, 35) target:self methed:@selector(slidBarClick:) normalImageName:@"map_btn2_nor.png" hightImageName:@"map_btn2_down.png" title:nil ];
            toiletBtn.tag =1002;
            toiletBtn.alpha = 0.7;
            [_slideBarView addSubview:toiletBtn];
            
            if (self.bussinessArr.count>0) {
                //商业>0
                UIButton * roadBtn = [ZZLingHelp createButtonWithFrame:CGRectZero target:self methed:@selector(slidBarClick:) normalImageName:@"map_btn_business_nor.png"hightImageName:@"map_btn_business_down.png" title:nil];
                roadBtn.tag = 1003;
                roadBtn.alpha = 0.7;
                [_slideBarView addSubview:roadBtn];
                //路线适配
                [roadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(toiletBtn.mas_bottom).offset(10);
                    make.right.equalTo(superView.mas_right);
                    make.width.equalTo(toiletBtn);
                    make.height.equalTo(toiletBtn);
                }];
                
            }else{
                
                
            }
            
        }else{
            
            if (self.bussinessArr.count>0) {
                //商业>0
                UIButton * roadBtn = [ZZLingHelp createButtonWithFrame:CGRectMake(0 , 0, 35, 35) target:self methed:@selector(slidBarClick:) normalImageName:@"map_btn_business_nor.png"hightImageName:@"map_btn_business_down.png" title:nil];
                roadBtn.tag = 1003;
                roadBtn.alpha = 0.7;
                [_slideBarView addSubview:roadBtn];
                
            }else{
                
                
            }
            
            
        }
        
        
    }

    
//    UIButton * flowBtn = [ZZLingHelp createButtonWithFrame:CGRectMake(0 , 0, 35, 35) target:self methed:@selector(slidBarClick:) normalImageName:@"map_btn1_nor.png" hightImageName:@"map_btn1_down.png" title:nil];
//    flowBtn.tag = 1001;
//    flowBtn.alpha = 0.7;
//    [_slideBarView addSubview:flowBtn];
//    
//    UIButton * toiletBtn =[ZZLingHelp createButtonWithFrame:CGRectZero target:self methed:@selector(slidBarClick:) normalImageName:@"map_btn2_nor.png" hightImageName:@"map_btn2_down.png" title:nil ];
//    toiletBtn.tag =1002;
//    toiletBtn.alpha = 0.7;
//    [_slideBarView addSubview:toiletBtn];
//    //卫生间适配
//    [toiletBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(flowBtn.mas_bottom).offset(10);
//        make.right.equalTo(superView.mas_right);
//        make.width.equalTo(flowBtn);
//        make.height.equalTo(flowBtn);
//    }];
//    
//    UIButton * roadBtn = [ZZLingHelp createButtonWithFrame:CGRectZero target:self methed:@selector(slidBarClick:) normalImageName:@"map_btn_business_nor.png"hightImageName:@"map_btn_business_down.png" title:nil];
//    roadBtn.tag = 1003;
//    roadBtn.alpha = 0.7;
//    [_slideBarView addSubview:roadBtn];
//    //路线适配
//    [roadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(toiletBtn.mas_bottom).offset(10);
//        make.right.equalTo(superView.mas_right);
//        make.width.equalTo(flowBtn);
//        make.height.equalTo(flowBtn);
//    }];


}

#pragma mark ----- 右侧功能按钮点击事件
-(void)slidBarClick:(UIButton *) slideButton{
    
    
    if (_tmpBtn == nil){
        slideButton.selected = YES;
        self.btnSelected = slideButton.selected;
        _tmpBtn = slideButton;
    }
    else if (_tmpBtn !=nil && _tmpBtn == slideButton){
        if (slideButton.selected == YES) {
            slideButton.selected = NO;
            self.btnSelected = slideButton.selected;
        }else{
            slideButton.selected = YES;
            self.btnSelected = slideButton.selected;
        }
        //        slideButton.selected = YES;
    }
    else if (_tmpBtn!= slideButton && _tmpBtn!=nil){
        _tmpBtn.selected = NO;
        slideButton.selected = YES;
        _tmpBtn = slideButton;
        self.btnSelected = slideButton.selected;
        
    }
    self.btnTag = slideButton.tag;
}



#pragma mark ------ 点击 客流量   卫生间    线路
-(void)setBtnTag:(NSInteger)btnTag
{
    NSLog(@"btn%ld",(long)btnTag);
    NSLog(@"btnSelected%d",_btnSelected);
    //客流量
    if (btnTag ==1001 ) {
        
        if(self.btnSelected == YES){
           
#pragma mark ---客流量修改
            
            //移除所有的子视图
            NSArray * subViews = [_mapImageView subviews];
            if ([subViews count]!= 0) {
                [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            }
            
            [self returnToOriginalImage];

            if (_spotArr != nil && [_statusStr isEqualToString:@"ok"]) {
//                [self addAttractionsButton];
                
                for (int i = 0 ; i < _spotArr.count; i ++) {
                    flowListModel * model = _spotArr[i];
                    NSLog(@"allBtnArr2");
                    for (int j = 0; j < _allBtnArr.count; j ++) {
                        UIButton * btn = _allBtnArr[j];
                        NSString * tagStr = [btn titleForState:UIControlStateDisabled];
                        
                        NSLog(@"---%@",tagStr);
                        if ( [tagStr isEqualToString:model.guide_id]) {
                            AllDateModel * guideModel = _class_A_Arr[j];
                            
                            UIButton * spotBnt = [UIButton buttonWithType:UIButtonTypeCustom];
                            spotBnt.center = CGPointMake([guideModel.map_X doubleValue]* _ScaleX, [guideModel.map_Y doubleValue]* _ScaleY+(30/2)-(30*self.zoomScale)/2);
                            spotBnt.bounds = CGRectMake(0, 0, 30*self.zoomScale, 30*self.zoomScale);
//                            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(btn.frame.origin.x+10, btn.frame.origin.y,30, 30)];
                            
                            if ([model.density isEqualToString:@"舒适"]) {
//                                imageView.image = [UIImage imageNamed:@"icon_comfortable"];
                                [spotBnt setImage:[UIImage imageNamed:@"icon_comfortable"] forState:UIControlStateNormal];
                                
                                
                            }else if ([model.density isEqualToString:@"拥挤"]){
//                                imageView.image = [UIImage imageNamed:@"icon_crowded"];
                            [spotBnt setImage:[UIImage imageNamed:@"icon_crowded"] forState:UIControlStateNormal];
                            
                            }else{
                            //一般
//                               imageView.image = [UIImage imageNamed:@"icon_general"];
                                [spotBnt setImage:[UIImage imageNamed:@"icon_general"] forState:UIControlStateNormal];
                            }
                            
                            [_mapImageView addSubview:spotBnt];
                            
                        }
                    }
                }
                
            }else {
            
                NSLog(@"出现错误，请检查");
                
            }
            
        }
        else{
            
            NSArray * subViews = [_mapImageView subviews];
            if ([subViews count]!= 0) {
                
                [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                
            }
            
            [self addAttractionsButton];
        
        }
        
        
    }
    //卫生间
    else if (btnTag == 1002){
        http://ailv3.ailvgocloud.com/ailv3/index.php/app/Scenicspot/mapList
        if(self.btnSelected == YES){
            
            //移除所有的子视图
            NSArray * subViews = [_mapImageView subviews];
            if ([subViews count]!= 0) {
                [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            }
            
            [self changeImageColor];
            
            for (int i = 0; i < _WcArr.count; i ++) {
                AllDateModel * wcModel = _WcArr[i];
                
//                [wcModel.map_X floatValue]* _ScaleX      [wcModel.map_Y floatValue]* _ScaleY
                UIButton * JIQuBtn = [ZZLingHelp createButtonWithFrame:CGRectMake(0,0 , 20 * self.zoomScale,  25* self.zoomScale) target:self methed:@selector(toiletClick) normalImageName:@"map_icon_washroom" hightImageName:@"map_icon_washroom" title:nil];
                //+20
                JIQuBtn.center = CGPointMake([wcModel.map_X floatValue]* _ScaleX, [wcModel.map_Y floatValue]* _ScaleY-(25*self.zoomScale)/2);
                
                [_mapImageView addSubview:JIQuBtn];
                
            }

            
        }else{
            
            NSArray * subViews = [_mapImageView subviews];
            if ([subViews count]!= 0) {
                [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            }
            [self returnToOriginalImage];
            
            [self addAttractionsButton];
            
        }

        
    }
    
    
    // 商业
    else if(btnTag == 1003){
        
        if(self.btnSelected == YES){
            
            ///移除所有的子视图
            NSArray * subViews = [_mapImageView subviews];
            if ([subViews count]!= 0) {
                [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            }
            
            
            [self changeImageColor];
            
            for (int i = 0; i < _bussinessArr.count; i ++) {
                AllDateModel * bussinessModel = _bussinessArr[i];
//                [bussinessModel.map_X floatValue]* _ScaleX   [bussinessModel.map_Y floatValue]* _ScaleY
                
                
                UIButton * JIQuBtn = [ZZLingHelp createButtonWithFrame:CGRectMake(0, 0, 20*self.zoomScale, 25*self.zoomScale) target:self methed:@selector(businessClick:) normalImageName:@"map_icon_business" hightImageName:@"map_icon_business" title:nil];
//                JIQuBtn setTitle:<#(nullable NSString *)#> forState:UIControlStateDisabled];
                
                JIQuBtn.tag = i+20;
                
                //+25
                JIQuBtn.center = CGPointMake([bussinessModel.map_X doubleValue]* _ScaleX, [bussinessModel.map_Y doubleValue]* _ScaleY-(25*self.zoomScale)/2);
                
//               JIQuBtn.center.x - 18       JIQuBtn.center.y - 37
                
//                UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 35 *self.zoomScale, 15 *self.zoomScale)];
//                label.center = CGPointMake([bussinessModel.map_X doubleValue]* _ScaleX, [bussinessModel.map_Y doubleValue]* _ScaleY-35*self.zoomScale );
//                label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
//                label.text  = bussinessModel.title;
//                label.textAlignment = NSTextAlignmentCenter;
////                label.adjustsFontSizeToFitWidth = YES;
//                label.font = [UIFont systemFontOfSize:8*self.zoomScale];
//                label.layer.cornerRadius = 3;
//                label.layer.masksToBounds = YES;
//                
//                [_mapImageView addSubview:label];
                
                [_mapImageView addSubview:JIQuBtn];
                
            }
//
        }else{
            NSLog(@"166666");
            
            NSArray * subViews = [_mapImageView subviews];
            if ([subViews count]!= 0) {
                [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            }
            
            
            [self returnToOriginalImage];
            
            
            [self addAttractionsButton];
            
            
        }

    
    }

}



#pragma mark --- 景点的btn的点击事件
//卫生间
-(void)toiletClick{

}

#pragma mark --- 商业点击事件点击事件
-(void)businessClick:(UIButton*) sender{
    
    AllDateModel  * model = self.bussinessArr[sender.tag-20];
    self.bussinessView.hidden = NO;
    self.logoTitle.text = model.title;
   
}

-(void)bussinessTapClick:(UITapGestureRecognizer*)tap{

    self.bussinessView.hidden= YES;
}

#pragma mark ---- 消息按钮
-(void)MassegeBtnClick:(UIButton *) sender{
    
    if ([self.delegate respondsToSelector:@selector(enterChatViewController)]) {
        [self.delegate enterChatViewController];
    }

    
}

//展示功能栏
-(void)showTheScrollView{
    [UIView animateWithDuration:0.5 animations:^{
        _ScrollView.center = CGPointMake(_ScrollView.center.x, _ScrollView.center.y+100);
        _pageControl.center= CGPointMake(_pageControl.center.x, _pageControl.center.y + 100);
        _superSiderView.center = CGPointMake(_superSiderView.center.x, _superSiderView.center.y + 100);
        _slideBarView.center = CGPointMake(_slideBarView.center.x, _slideBarView.center.y + 100);
        _showBtn.frame = CGRectMake((WIDTH - 40)/2.0 , -35, 40, 30);
        _showTheView = NO;
        
        _roadView.center = CGPointMake(_roadView.center.x, _roadView.center.y + 100);
        
    } completion:^(BOOL finished) {
        
        
    }];
    
    
    
}

//隐藏多功能栏
-(void)hiddenTheScrollView{
    
    [UIView animateWithDuration:0.5 animations:^{
        _ScrollView.center = CGPointMake(_ScrollView.center.x, _ScrollView.center.y-100);
        _pageControl.center = CGPointMake(_pageControl.center.x, _pageControl.center.y - 100);
         _superSiderView.center = CGPointMake(_superSiderView.center.x, _superSiderView.center.y - 100);
        _slideBarView.center = CGPointMake(_slideBarView.center.x, _slideBarView.center.y - 100);
        _showBtn.frame = CGRectMake((WIDTH - 40)/2.0 , 5, 40, 30);
        _showTheView= YES;
        
        _roadView.center = CGPointMake(_roadView.center.x, _roadView.center.y - 100);
        
    } completion:^(BOOL finished) {
        NSLog(@"动画已完成");
        
    }];
}


-(void)createSpotsList{
    if (_class_A_Arr.count <= 7 ) {
        CGFloat heigth = _class_A_Arr.count * 40;
        
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.frame.size.height-55 - _class_A_Arr.count * 40, self.frame.size.width - 20, heigth) style:UITableViewStylePlain];
        _tableView = tableView;
    }
    else if (_class_A_Arr.count > 7){
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.frame.size.height-55 - 7 * 40, self.frame.size.width - 20, 7*40) style:UITableViewStylePlain];
        _tableView = tableView;
    }
    
    _tableView.hidden =YES;
    _tableView.delegate = self;
    _tableView.dataSource= self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.alpha = 0.7;
    _tableView.bounces=NO;
    _tableView.layer.cornerRadius = 5;
    _tableView.layer.masksToBounds = YES;
    [self addSubview:_tableView];
    
}


#pragma mark ----UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    //用于折叠
    if(open[section] != 1){
        return 0;
    }
    //返回
    return [self.class_B_Arr[section] count];


}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return self.class_A_Arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    mapMusicTableCell * cell = [mapMusicTableCell cellWithTableView:tableView];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    
    NSArray * cellArr = self.class_B_Arr[indexPath.section];
    
    cell.guideModel = cellArr[indexPath.row];
    
    return cell;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
       static NSString * identifer = @"header";
    
       UITableViewHeaderFooterView * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifer];
    
//    if(headerView==nil){
    
        headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:identifer];
        headerView.contentView.backgroundColor = [UIColor whiteColor];
        
        //        添加lable
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, tableView.bounds.size.width-70, 40)];
        label.tag = section+1;
        label.backgroundColor = [UIColor whiteColor];
        [headerView.contentView addSubview:label];
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClicked:)];
        [label addGestureRecognizer:tap];
        
        
        UIImageView * headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 20, 20)];
        headerImage.image = [UIImage imageNamed:@"foot_icon_locked"];
        [headerView.contentView addSubview:headerImage];
        
        //        给Label添加手势
        //      [label addGestureRecognizer:tap];
        NSLog(@"class_B_Arr===----===%@",self.class_B_Arr);
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((tableView.bounds.size.width - 35), 15, 30, 10)];
        imageView.userInteractionEnabled = YES;
        imageView.tag = section + 100000;
        NSLog(@"===========---------%ld",imageView.tag);
        [headerView.contentView addSubview:imageView];
        
        UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
        [imageView addGestureRecognizer:tap2];
        
        if ([self.class_B_Arr[section] count] >0) {
            imageView.hidden = NO;
        }else{
            imageView.hidden = YES;
        }
    
//    }
    
//    headerView.contentView.tag = section+ 100;
    
    //    刷新页头
//    UILabel * label =(UILabel*) [headerView.contentView viewWithTag:(section+1)];
    NSLog(@"label.tag=====%ld",(long)label.tag);
    AllDateModel * model = self.class_A_Arr[section];
    
    label.text = model.name;
    
//    UIImageView * imageView = (UIImageView*)[headerView viewWithTag:(section + 100000)];
   
////    UIImageView * imageView = (UIImageView*)[superView2 viewWithTag:501];
//    UIImageView * imageView = subviews[0];
    
    NSString * imageName = open[section]?@"arrow_up":@"arrow_down";
    imageView.image = [UIImage imageNamed:imageName];
    
    [headerView.contentView addSubview:imageView];
    
    
    return headerView;
    
}

// 手势触发的方法
-(void)tapClicked:(UITapGestureRecognizer *)tap{
//    
    if (_player.playState == NCMusicEnginePlayStatePlaying) {
        [_player stop];
         _player = nil;
    }
    
    UIView * view = tap.view;
    NSLog(@"-------%ld",(long)view.tag);
    
    //    当前的分组
    
    NSInteger section = view.tag - 1;
    AllDateModel * modelA = self.class_A_Arr[section];
    NSLog(@"%@",modelA.audioURL);
    //异或。两个值都为0 ，结果为0  一个为1，一个0，结果为1
//    open[section] ^= 1;
//    
//    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    int repeatCount = 5;
    NSString * NameStr = modelA.name;
    [_NameBtn setTitle:NameStr forState:UIControlStateNormal];
//    _tableView.hidden = YES;
    if (_allBtnArr == nil) {
        NSLog(@"数组为空");
    }else{
        UIButton * btn = _allBtnArr[section];
        
        [self moveTheBtnPosition:btn];
        //    动画1
        //    [self triggerAnimateTapWithButton:_allBtnArr[indexPath.row]];
        //     动画2
        [self triggerAnimateTap:_allBtnArr[section] repeatCount:repeatCount];
        
         _PlayView.hidden = NO;
        _model1 = modelA;
        
        [self createPlayView:modelA];
        [_mapImageView addSubview:_PlayView];
        [_mapImageView bringSubviewToFront:_PlayView];
        
        _mp3PalyBtn =(Mp3PlayerButton *) [_PlayView viewWithTag:100];
        _mp3PalyBtn.musicName = modelA.guide_id;
        _player.button = _mp3PalyBtn;

        NSURL *url = [NSURL URLWithString:modelA.audioURL];
        _mp3PalyBtn.mp3URL = url;
        
        if (_player == nil) {
            _player = [[NCMusicEngine alloc] initWithSetBackgroundPlaying:YES];
            //_player.button = button;
            _player.delegate = self;
            _player.cacheFolderName= self.pathStr;
            _player.secondCacheFolderName = modelA.guide_id;
            _player.musicName = modelA.guide_id;
            
            
            
        }else{
            
            _player.cacheFolderName= self.pathStr;
            _player.musicName = modelA.guide_id;
            _player.secondCacheFolderName = modelA.guide_id;
            
        }

        
        if ([_player.button isEqual:_mp3PalyBtn]) {
//            [_player stop];
            if (_player.playState == NCMusicEnginePlayStatePlaying) {
                
                [_player stop];
               
            }
            _player.button = _mp3PalyBtn;
            _player.musicName = modelA.guide_id;
            _player.secondCacheFolderName = modelA.guide_id;
            [_player playUrl:url];
            
            
        }else {
            if (_player.playState == NCMusicEnginePlayStatePlaying) {
                
                [_player stop];
            }

//            [_player stop];
            _player.button = _mp3PalyBtn;
            [_player playUrl:_mp3PalyBtn.mp3URL];
            
        }

        if ([self.delegate respondsToSelector:@selector(goBackMapViewControllerTheAudio:andAllDataModel:)]) {
            [self.delegate goBackMapViewControllerTheAudio:_player andAllDataModel:modelA];
            
        }
        
    }
    
    _i = _i + 1;
    self.tableView.hidden = YES;

    
}


-(void)imageClick:(UITapGestureRecognizer*)tap{
    
    NSLog(@"098765432");
    
    UIView * view = tap.view;
    NSLog(@"-------%ld",(long)view.tag);
    
    //    当前的分组
    
    NSInteger section = view.tag-100000;
    
    NSLog(@"section==%ld",(long)section);
    
    
//    guideListModel * modelA = self.class_A_Arr[section];
//    NSLog(@"%@",modelA.audioURL);
    //异或。两个值都为0 ，结果为0  一个为1，一个0，结果为1
    open[section] ^= 1;
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    
    
    
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexPath.row123 ------ %ld ---- %ld",indexPath.section,(long)indexPath.row);
    
    _i = _i + 1;
    int repeatCount = 5;
    
    NSArray * sectionArr = _class_B_Arr[indexPath.section];
    
    AllDateModel * JingDianModel = sectionArr[indexPath.row];
    NSString * NameStr = JingDianModel.name;
    [_NameBtn setTitle:NameStr forState:UIControlStateNormal];
    tableView.hidden = YES;
    if (_allBtnArr.count<1&&self.class_A_Arr.count<1) {
        NSLog(@"数组为空");
    }else{
        UIButton * btn = _allBtnArr[indexPath.section];
        
        AllDateModel * FirstModel = self.class_A_Arr[indexPath.section];
        
        [self moveTheBtnPosition:btn];
        
//    动画1
//    [self triggerAnimateTapWithButton:_allBtnArr[indexPath.row]];
//     动画2
        [self triggerAnimateTap:_allBtnArr[indexPath.section] repeatCount:repeatCount];
    
        _PlayView.hidden = NO;
//        UIButton * button = _allBtnArr[indexPath.section];
//        _PlayView.frame = CGRectMake(button.center.x -62/2.0, button.center.y - 78/2.0, 87, 71);
        _model1 = FirstModel;
        [self createPlayView:FirstModel];
        [_mapImageView bringSubviewToFront:_PlayView];
        [_mapImageView addSubview:_PlayView];
        [_mapImageView insertSubview:btn belowSubview:_PlayView];
        
        _mp3PalyBtn =(Mp3PlayerButton *) [_PlayView viewWithTag:100];
        _mp3PalyBtn.musicName = JingDianModel.guide_id;
        
        
        
        NSURL *url = [NSURL URLWithString:JingDianModel.audioURL];
        _mp3PalyBtn.mp3URL = url;
        if (_player.playState == NCMusicEnginePlayStatePlaying) {
            [_player stop];
        }
        
        if (_player == nil) {
            _player = [[NCMusicEngine alloc] initWithSetBackgroundPlaying:YES];
            _player.delegate = self;
            
//            _mp3PalyBtn.musicName = JingDianModel.guide_id;
            _player.musicName = JingDianModel.guide_id;
            
            _player.secondCacheFolderName = JingDianModel.guide_id;
            
        }
        
        if ([_player.button isEqual:_mp3PalyBtn]) {
            
//            _mp3PalyBtn.musicName = JingDianModel.guide_id;
            _player.musicName = JingDianModel.guide_id;
            _player.secondCacheFolderName = JingDianModel.guide_id;
            [_player playUrl:url];
            
        }
    }


}

#pragma  mark  -------UIScrollViewDelegate
//滚动，小圆点跟着动
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == 111) {
        int page = _ScrollView.contentOffset.x / _ScrollView.frame.size.width;
        _pageControl.currentPage = page;
        
    }
}

//开始缩放时调用的方法
-(void) scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{

    NSLog(@"%s",__func__);
}
-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{

    self.zoomScale = 1 / scale;
    NSLog(@"self.zoomScale:--%f",self.zoomScale);
    
    NSArray * sliderSubViews = [_superSiderView subviews];
    
    for (int i = 0 ;i<sliderSubViews.count; i++) {
        UIButton * sliderBtn = sliderSubViews[i];
        
        if (sliderBtn.tag == 999) {
            
            if(!sliderBtn.selected){

                NSArray * sliderThreeBtn = [_slideBarView subviews];
                for (int j = 0; j < sliderThreeBtn.count; j++) {
                    UIButton * ThreeBtn = sliderThreeBtn[j];
                    if (ThreeBtn.tag == 1001) {
                    
                        if (ThreeBtn.selected == YES) {
                            NSLog(@"yes");
                            [self setBtnTag:1001];
                            break;
                         }
                        
                    }else if (ThreeBtn.tag == 1002){
                        if (ThreeBtn.selected == YES) {
                             NSLog(@"yes");
                            [self setBtnTag:1002];
                             break;
                        }
                       
                    }else{
                        if (ThreeBtn.selected == YES) {
                            NSLog(@"yes");
                            [self setBtnTag:1003];
                            break;
                        }
                    }
                    
                    if (ThreeBtn.selected == NO) {
                        [self addAttractionsButton];
                    }
                }
            }
        }else{
            if (sliderBtn.selected == NO) {
                NSLog(@"123456");
                if (_routeArr.count ==1) {
                    [self addAttractionsButton];
                }else{
                
                    [self addAttractionsButton];
                    
                }
                break;
            }
            
        }

    }
    
    UIButton * sliderBtnRoad = sliderSubViews[0];
    UIButton * sliderBtnOther= sliderSubViews[1];
    
    
    
    
//    if (_PlayView.hidden == NO) {
//        _model1 = nil;
//        
//    }
    
    [self createPlayView:_model1];
    NSLog(@"_PlayView----%@",_PlayView);
    NSLog(@"_PlayView.hidden-----%d",_PlayView.hidden);

    
    
    if (_model1.name) {
        [_NameBtn setTitle:_model1.name forState:UIControlStateNormal];
    }
    
    
    if (sliderBtnRoad.selected == YES && sliderBtnOther.selected == YES) {
        [self addAttractionsButton];
    }
    NSLog(@"name ==---===--=- %@",_model1.name);
    //    底部按钮
//    [_NameBtn setTitle:_model1.name forState:UIControlStateNormal];
    
}




//缩放时，设置具体是哪一个view进行缩放
-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return self.mapScrollView.viewForZooming;

}
#pragma mark -------按钮的动画  1
-(void)triggerAnimateTap:(UIButton*)sender repeatCount:(int)repeatCount{

    self.halo = [PulsingHaloLayer layer];
    self.halo.position= sender.center;
    self.halo.color = [UIColor blueColor];
    if (repeatCount==0) {
        self.halo.repeatCount = repeatCount;
    }else{
        self.halo.repeatCount = 0;
        self.halo.repeatCount = repeatCount;
    
    }
    
    
//    [_mapImageView.layer insertSublayer:self.halo below:sender.layer];
    
    [_mapImageView.layer insertSublayer:self.halo above:sender.layer];

}

//按钮动画2
- (void)triggerAnimateTapWithButton:(UIButton*) sender{
    
    self.highLightView.alpha = 1;
    
    __weak typeof(self) this = self;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        this.highLightView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(sender.bounds), -CGRectGetMidY(sender.bounds), sender.bounds.size.width, sender.bounds.size.height);
    
//    根据矩形画带圆角的曲线
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:sender.layer.cornerRadius];
    
//    根据矩形的内切圆话曲线
    UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:pathFrame];
    
    // accounts for left/right offset and contentOffset of scroll view
    CGPoint shapePosition = [sender.superview convertPoint:sender.center fromView:sender.superview];
    
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = sender.layer.borderColor;
    //    sender.borderColor.CGColor;
    //改变波纹宽度
    circleShape.lineWidth = 3.0;
    
    [sender.superview.layer addSublayer:circleShape];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = 0.5f;
    animation.autoreverses = YES;
    animation.repeatCount= 4.0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circleShape addAnimation:animation forKey:nil];
    
}

//寻找缓存中是否有
- (NSArray *) getAllMapNames
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    // 获取Caches目录路径
    NSString *cacheDir = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
    
//    NSString *  cacheFolder = [cacheDir stringByAppendingPathComponent:self.cacheFolderName];
    NSLog(@"cacheDir----%@",cacheDir);
    
    NSArray * tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:cacheDir error:nil]];
    
    NSLog(@"----%@",tempFileList);
    return tempFileList;
    
}

-(void)changeImageColor{

    UIImage * image = [UIImage imageWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:self.jqid]];
    if (image) {
        
        CIImage * beginImage = [CIImage imageWithCGImage:image.CGImage];
        CIFilter * filter = [CIFilter filterWithName:@"CIColorControls"];
        [filter setValue:beginImage forKey:kCIInputImageKey];
        //设置饱和度
        [filter setValue:[NSNumber numberWithFloat:0.3] forKey:@"inputSaturation"];
        //得到过滤后的图片
        CIImage * outputImage = [filter outputImage];
        //转换图片，创建基于GPU的CIContext对象
        CIContext * context = [CIContext contextWithOptions:nil];
        CGImageRef cging = [context createCGImage:outputImage fromRect:[outputImage extent]];
        UIImage * newImage = [UIImage imageWithCGImage:cging];
        NSLog(@"newImage====%@",newImage);

        _mapImageView.image = newImage;
        //释放C对象
        CGImageRelease(cging);

    }else{
    
    }
 
}

-(void)returnToOriginalImage{

    UIImage * image = [UIImage imageWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:self.jqid]];
    
    if (image) {
        _mapImageView.image = image;
    }
    
}



@end
