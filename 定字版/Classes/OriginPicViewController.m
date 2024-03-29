//
//  OriginPicViewController.m
//  AppStrom
//
//  Created by 掌商 on 11-8-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OriginPicViewController.h"
#import "UIImageScale.h"
#import "myScrollView.h"
#import "browserViewController.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "DBOperate.h"
#import "FileManager.h"
#import "callSystemApp.h"
#import "alertView.h"
#import "Common.h"
#import "myUISCrollView.h"
#import "spinnerView.h"
#import "ShareWithQRCodeViewController.h"
#import "LoginViewController.h"
#import "ProductDetailBrowserViewController.h"
#import "CommentListViewController.h"
#import "ShareToBlogViewController.h"
#import "DSURLView.h"
#import "SendMsgToWeChat.h"
#import "UpdateAppAlert.h"

#define SHARE_ACTIONSHEET_ID 3001
#define WECHAT_ACTIONSHEET_ID 3002

@implementation OriginPicViewController
@synthesize originPic;
@synthesize dragger;
@synthesize picName;
@synthesize picArray;
@synthesize toolBar;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
@synthesize pageControl;
@synthesize scrollview;
@synthesize chooseIndex;
@synthesize showWhichOriginPic;
@synthesize ar_product;
@synthesize actionsheet;
@synthesize indexToPicDic;
@synthesize productId;
@synthesize titleString;
@synthesize weChatActionsheet;
@synthesize weChatAlert;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
	
    if (showWhichOriginPic == SHOW_PRODUCT_PIC){
		self.picArray = (NSMutableArray *)[DBOperate queryData:T_PIC theColumn:@"pid" theColumnValue:productId withAll:NO];
    }
    else {
		self.picArray = (NSMutableArray *)[DBOperate queryData:T_WALLPAPER theColumn:nil theColumnValue:nil  withAll:YES];
	}
	
	
	NSMutableArray *tbitmp = [[NSMutableArray alloc] initWithArray:self.toolBar.items];
	self.toolbarItems =  tbitmp;
	[tbitmp release];
	self.toolBar.tintColor = [UIColor colorWithRed:BTO_COLOR_RED green:BTO_COLOR_GREEN blue:BTO_COLOR_BLUE alpha:0];
	self.navigationController.toolbar.barStyle = self.toolBar.barStyle;
	self.navigationController.toolbar.tintColor = self.toolBar.tintColor;
    self.navigationController.toolbarHidden = YES;
	[self.navigationController.toolbar setTranslucent:YES];
	 [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController.navigationBar setTranslucent:YES];
	
	NSMutableDictionary *indextmp = [[NSMutableDictionary alloc]init];
	self.indexToPicDic = indextmp;
	[indextmp release];
	
	//[self showToolBar];
	
	//设置返回本类按钮
	UIBarButtonItem * tempButtonItem = [[ UIBarButtonItem alloc] init]; 
	tempButtonItem.title = @"返回";
	self.navigationItem.backBarButtonItem = tempButtonItem ; 
	[tempButtonItem release];
	
	
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
    
    UIPageControl *pageCtmp = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 10.0f)];
	self.pageControl = pageCtmp;
	[pageCtmp release];
	pageControl.backgroundColor = [UIColor clearColor];
	pageControl.numberOfPages = [picArray count];
	pageControl.currentPage = chooseIndex;
	pageControl.hidden = YES;
	[pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:pageControl];
    
    int yValue = (([UIScreen mainScreen].bounds.size.height - 20 - 460.0f) / 2);
    if (IOS_VERSION >= 7.0) {
        yValue = yValue + 20;
    }
	UIScrollView *scrollviewtmp = [[UIScrollView alloc]initWithFrame:CGRectMake( -5.0f, yValue, self.view.frame.size.width + 10.0f, 460.f)];
	self.scrollview = scrollviewtmp;
	[scrollviewtmp release];
	scrollview.contentSize = CGSizeMake(scrollviewtmp.frame.size.width*[picArray count], 460);
	scrollview.delegate = self;
	scrollview.pagingEnabled = YES;
	scrollview.tag = 1000;
	scrollview.showsHorizontalScrollIndicator = NO;
	scrollview.showsVerticalScrollIndicator = NO;
	[self.view addSubview:scrollview];
    
	imageviewTag = 100;
	imageviewTagtmp = 100;
	
	for (int i = 0; i < [picArray count]; i++) {
        
        myUISCrollView *scrollview1 = [[myUISCrollView alloc]initWithFrame:CGRectMake(i * self.scrollview.frame.size.width + 5.0f, 0 ,320, 460)];
		scrollview1.contentSize = CGSizeMake(320, 460);
		scrollview1.delegate = self;
		scrollview1.mydelegate = self;
		scrollview1.maximumZoomScale = 2.0;
		scrollview1.minimumZoomScale = 1.0;
		scrollview1.showsHorizontalScrollIndicator = NO;
		scrollview1.showsVerticalScrollIndicator = NO;
		scrollview1.tag = 100+i;
        [scrollview addSubview:scrollview1];

		myImageView *imageview = [[myImageView alloc]initWithFrame:CGRectMake(0.0f, 0, 320, 460) withImageId:i];
		imageview.tag = 1001;
		imageview.mydelegate = self;
		[scrollview1 addSubview:imageview];
        [imageview release];
        [scrollview1 release];
		
		NSArray *array = [picArray objectAtIndex:i];
		NSString *picDesc = [array objectAtIndex:originpic_pic_desc];
		
		if(picDesc != nil && [picDesc length] > 0){
            
            int yValue = scrollview1.frame.size.height - 60 - 44;
            if ([UIScreen mainScreen].bounds.size.height > 480) {
                yValue = yValue + 44;
            }
            
			UIScrollView *textScrollView = [[UIScrollView alloc] initWithFrame:
											CGRectMake(0, yValue, scrollview.frame.size.width, 60)];
            
			textScrollView.showsHorizontalScrollIndicator = YES;
			textScrollView.showsVerticalScrollIndicator = YES;
			textScrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
			textScrollView.tag = 108 + i;
			
			DSURLView *urlView = [[DSURLView alloc] init];
			urlView.frameWidth = 310;
			urlView.frameOriginX = 0;
			urlView.frameOriginY = 0;
			urlView.tag = 208 + i;
			urlView.sourceText = picDesc;
			urlView.delegate = self;
			urlView.FontSize = 15.0f;
			[urlView layoutURLViewWithElements:[urlView splitStringByKey:@"#" sourceString:picDesc]];
			textScrollView.contentSize = CGSizeMake(scrollview.frame.size.width, urlView.frame.size.height);
			[textScrollView addSubview:urlView];
			[scrollview1 addSubview:textScrollView];
			[textScrollView release];
		}
	}
	scrollview.contentOffset = CGPointMake(self.scrollview.frame.size.width * chooseIndex, 0.0f);
	//NSArray *wp = [picArray objectAtIndex:chooseIndex];
	NSString *s = @"";//@"组图";
	NSString *tString = [titleString stringByAppendingFormat:s];
	NSString *num = [NSString stringWithFormat:@"(%d/%lu)",chooseIndex+1,(unsigned long)[picArray count]];
	if (tString != nil && [picArray count] > 1) {
		self.title = [tString stringByAppendingFormat:num];
	}else {
		self.title = tString;
	}

	
	//[num release];
	[self showInCurrentPic:chooseIndex];
    
    [self showCustomToolbar];
}


- (void)showToolBar{
	
	UIToolbar *myToolBar = [[UIToolbar alloc] initWithFrame:  
							CGRectMake(0.0f, self.view.frame.size.height - 44, 320.0f, 44.0f)];
	myToolBar.tintColor = [UIColor colorWithRed:BTO_COLOR_RED green:BTO_COLOR_GREEN blue:BTO_COLOR_BLUE alpha:0];
	[self.view addSubview:myToolBar];
	
	NSMutableArray *buttons=[[NSMutableArray  alloc]initWithCapacity:3];  
	[buttons  autorelease];  
	
	UIBarButtonItem   *SpaceButton1=[[UIBarButtonItem alloc]  initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:nil   action:nil];  
	[buttons addObject:SpaceButton1];  
	[SpaceButton1 release];  
	
	UIBarButtonItem   *freshButton=[[UIBarButtonItem alloc]  initWithTitle: @"分享" style: UIBarButtonItemStyleBordered target:self   action:@selector(share:)];
	[buttons addObject:freshButton];  
	[freshButton release];   
	UIBarButtonItem   *SpaceButton2=[[UIBarButtonItem alloc]  initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:nil   action:nil];  
	[buttons addObject:SpaceButton2];  
	[SpaceButton2 release];  
	
	UIBarButtonItem   *searchSelfButton=[[UIBarButtonItem alloc] initWithTitle: @"刷新" style: UIBarButtonItemStyleBordered target:self   action:@selector(reload:)];  
	[buttons addObject:searchSelfButton];  
	[searchSelfButton release];  
	
	UIBarButtonItem   *SpaceButton3=[[UIBarButtonItem alloc]  initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:nil   action:nil];  
	[buttons addObject:SpaceButton3];  
	[SpaceButton3 release]; 
	
	UIBarButtonItem   *wechatButton=[[UIBarButtonItem alloc] initWithTitle: @"微信" style: UIBarButtonItemStyleBordered target:self   action:@selector(reload:)];  
	[buttons addObject:wechatButton];  
	[wechatButton release];
	
	[myToolBar setItems:buttons animated:YES];  
	[myToolBar  sizeToFit]; 
	[myToolBar release];
	
}

- (void) showCustomToolbar{
    
    int yValue = 0;
    if (IOS_VERSION >= 7.0) {
        yValue = [UIScreen mainScreen].bounds.size.height - 44;
    }else {
        yValue = [UIScreen mainScreen].bounds.size.height - 44 - 20;
    }
    
	UIImageView *toolBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yValue, 320, 44)];
	UIImage *image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"看原图bar" ofType:@"png"]];
	toolBarView.image = image;
	toolBarView.tag = 3005;
	toolBarView.userInteractionEnabled = YES;
	[image release];	
	[self.view addSubview:toolBarView];
	
	int buttonMargin;
	if (isShareToWechat) {
		buttonMargin = (320 - 24*4)/5;
	}else {
		buttonMargin = (320 - 24*3)/4;
	}
	int offset;
	
	UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//	[shareBtn setFrame:CGRectMake(buttonMargin, 4, 24, 24)];
    [shareBtn setFrame:CGRectMake(buttonMargin - 11, -8, 48, 48)];

	[shareBtn setImage:[UIImage imageNamed:@"分享icon.png"] forState:UIControlStateNormal];
	[shareBtn addTarget:self action:@selector(HandleShare:) forControlEvents:UIControlEventTouchUpInside];	
	
	UILabel *sharelabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonMargin, 28, 30, 14)];
	sharelabel.text = @"分享";
	sharelabel.textColor = [UIColor whiteColor];
	sharelabel.backgroundColor = [UIColor clearColor];
	sharelabel.font = [UIFont systemFontOfSize:12];
	
	[toolBarView addSubview:sharelabel];	
	[toolBarView addSubview:shareBtn];
	[sharelabel release];
	
	offset = buttonMargin*2 + 24;
	
	UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//	[commentBtn setFrame:CGRectMake(offset, 4, 24, 24)];
    [commentBtn setFrame:CGRectMake(offset - 11, -8, 48, 48)];

	[commentBtn setImage:[UIImage imageNamed:@"评论icon.png"] forState:UIControlStateNormal];
	[commentBtn addTarget:self action:@selector(HandleComment:) forControlEvents:UIControlEventTouchUpInside];
	
	UILabel *commentlabel = [[UILabel alloc] initWithFrame:CGRectMake(offset, 28, 30, 14)];
	commentlabel.text = @"评论";
	commentlabel.textColor = [UIColor whiteColor];
	commentlabel.backgroundColor = [UIColor clearColor];
	commentlabel.font = [UIFont systemFontOfSize:12];
	
	offset = buttonMargin*3 + 24*2;
	
	[toolBarView addSubview:commentlabel];	
	[toolBarView addSubview:commentBtn];
	[commentlabel release];
	
	UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//	[detailBtn setFrame:CGRectMake(offset, 4, 24, 24)];
    [detailBtn setFrame:CGRectMake(offset - 11, -8, 48, 48)];

	[detailBtn setImage:[UIImage imageNamed:@"详情icon.png"] forState:UIControlStateNormal];
	[detailBtn addTarget:self action:@selector(HandleToBrowser:) forControlEvents:UIControlEventTouchUpInside];
	
	UILabel *detaillabel = [[UILabel alloc] init];
    detaillabel.frame = CGRectMake(offset, 28, 30, 14);
	detaillabel.text = @"详情";
	detaillabel.textColor = [UIColor whiteColor];
	detaillabel.backgroundColor = [UIColor clearColor];
	detaillabel.font = [UIFont systemFontOfSize:12];
	
	[toolBarView addSubview:detaillabel];	
	[toolBarView addSubview:detailBtn];
	[detaillabel release];
	
	if (isShareToWechat) {
		
		offset = buttonMargin*4 + 24*3;
		
		UIButton *wechatbtn = [UIButton buttonWithType:UIButtonTypeCustom];
//		[wechatbtn setFrame:CGRectMake(offset, 4, 24, 24)];
        [wechatbtn setFrame:CGRectMake(offset - 11, -8, 48, 48)];

		[wechatbtn setImage:[UIImage imageNamed:@"微信icon.png"] forState:UIControlStateNormal];
		[wechatbtn addTarget:self action:@selector(HandleToWeChat:) forControlEvents:UIControlEventTouchUpInside];
		
		UILabel *wechatlabel = [[UILabel alloc] initWithFrame:CGRectMake(offset, 28, 30, 14)];
		wechatlabel.text = @"微信";
		wechatlabel.textColor = [UIColor whiteColor];
		wechatlabel.backgroundColor = [UIColor clearColor];
		wechatlabel.font = [UIFont systemFontOfSize:12];
		
		[toolBarView addSubview:wechatlabel];	
		[toolBarView addSubview:wechatbtn];
		[wechatlabel release];
		
	}
	
	[toolBarView release];
}

-(void)showInCurrentPic:(int)curPic{
	NSLog(@"showIn current %d",curPic);
	[self showOnePic:curPic];
	[self showOnePic:(curPic-1)];
	[self showOnePic:(curPic+1)];
	[self removeOnePic:(curPic-2)];
	[self removeOnePic:(curPic+2)];
}
-(void)removeOnePic:(int)picIndex{
	if ((picIndex >=0) && (picIndex < [picArray count])) {
    	UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(picIndex+100)];
    	[indexToPicDic removeObjectForKey:[NSNumber numberWithInt:picIndex]];
    	myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
    	myIV.image = nil;
	}
}
-(void)showOnePic:(int)picIndex{
		
if ((picIndex >=0) && (picIndex < [picArray count])) {
		UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(picIndex+100)];
		myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
		if(myIV.image == nil){
				
         	NSArray *wp = [picArray objectAtIndex:picIndex];
        	if (showWhichOriginPic == SHOW_PRODUCT_PIC) {
	         	[self loadpic:wp withIndex:picIndex];
        	}
    	    else {
    	    	[self loadWallPaper:wp withIndex:picIndex];
     	    }
		}
	}
}
-(void)loadWallPaper:(NSArray*)wp withIndex:(int)index{

	if (((NSString*)[wp objectAtIndex:wallpaper_pic_name]).length > 1) {
		
    	UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(index+100)];
        myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
    	UIImage *photo = [FileManager getPhoto:[wp objectAtIndex:wallpaper_pic_name]];
    	if (photo!=nil) {
			[indexToPicDic setObject:photo forKey:[NSNumber numberWithInt:index]];
    		myIV.image = [photo fillSize:CGSizeMake(scrollview.frame.size.width, scrollview.frame.size.height)];
    	}
    	else {
    		[self startIconDownload: [wp objectAtIndex:wallpaper_pic_url] forIndex:[NSIndexPath indexPathWithIndex:index]];
    	}
	}
	else {
    	[self startIconDownload: [wp objectAtIndex:wallpaper_pic_url] forIndex:[NSIndexPath indexPathWithIndex:index]];
		
    }
	
}
-(void)loadpic:(NSArray*)wp withIndex:(int)index{

	if (((NSString*)[wp objectAtIndex:originpic_pic1_name]).length > 1) {
	
    	UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(index+100)];
        myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
    	UIImage *photo = [FileManager getPhoto:[wp objectAtIndex:originpic_pic1_name]];
		//NSLog(@"%d,%d",scrollview.frame.size.width,scrollview.frame.size.height);
    	if (photo!=nil) {
			[indexToPicDic setObject:photo forKey:[NSNumber numberWithInt:index]];
			if(myIV.image.size.width == scrollview.frame.size.width && myIV.image.size.height == scrollview.frame.size.height){
				
			}else{
				myIV.image = [photo fillSize:CGSizeMake(scrollview.frame.size.width, scrollview.frame.size.height)];
			}
    	}
    	else {
    		[self startIconDownload: [wp objectAtIndex:originpic_pic1_url] forIndex:[NSIndexPath indexPathWithIndex:index]];
    	}
     }
   else {
    	[self startIconDownload: [wp objectAtIndex:originpic_pic1_url] forIndex:[NSIndexPath indexPathWithIndex:index]];
	
    }
}


- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index
{
	[spinnerView startSpinner:self.view];
	NSLog(@"imgurl %@",index);
	//NSLog(@"startload index %@",index);
	
    if (imageURL != nil && imageURL.length > 1) 
    {
		if ([imageDownloadsInProgress count]>= MAXICONDOWNLOADINGNUM) {
			imageDownLoadInWaitingObject *one = [[imageDownLoadInWaitingObject alloc]init:imageURL withIndexPath:index withImageType:CUSTOMER_PHOTO];
			[imageDownloadsInWaiting addObject:one];
			[one release];
			return;
		}
		if ([imageDownloadsInProgress objectForKey:index]==nil) {
			IconDownLoader *iconDownloader = [[IconDownLoader alloc] init];
			iconDownloader.downloadURL = imageURL;
			iconDownloader.indexPathInTableView = index;
			iconDownloader.imageType = CUSTOMER_PHOTO;
			iconDownloader.delegate = self;
			[imageDownloadsInProgress setObject:iconDownloader forKey:index];
			
			[iconDownloader startDownload];
			[iconDownloader release];   
		}
       
    }
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type
{
	[spinnerView stopSpinner];
    IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width>2.0){ 
			NSString *photoname = [callSystemApp getCurrentTime];
			if([FileManager savePhoto:photoname withImage:iconDownloader.cardIcon])
			{
				NSArray *one = [picArray objectAtIndex:[indexPath indexAtPosition:0]]; 
				//NSLog(@"one %@ %d",one,category_id);
				if (showWhichOriginPic == SHOW_PRODUCT_PIC){
					NSNumber *value = [one objectAtIndex:originpic_id];
					[FileManager removeFile:[one objectAtIndex:originpic_pic1_name]];
					[DBOperate updateData:T_PIC tableColumn:@"pic1_name" columnValue:photoname conditionColumn:@"id" conditionColumnValue:value];
				    self.picArray = (NSMutableArray *)[DBOperate queryData:T_PIC theColumn:@"pid" theColumnValue:productId withAll:NO];
				}
				else {
					NSNumber *value = [one objectAtIndex:wallpaper_id];
					[FileManager removeFile:[one objectAtIndex:wallpaper_pic_name]];
					[DBOperate updateData:T_WALLPAPER tableColumn:@"pic_name" columnValue:photoname conditionColumn:@"id" conditionColumnValue:value];
					self.picArray = (NSMutableArray *)[DBOperate queryData:T_WALLPAPER theColumn:nil theColumnValue:nil  withAll:YES];
				}
				

			}
			
			UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(scrollview.frame.size.width, scrollview.frame.size.height)];
			NSUInteger index;
			[indexPath getIndexes:&index];
			NSLog(@"index...................... %lu",(unsigned long)index);
			UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(index+100)];
			[indexToPicDic setObject:iconDownloader.cardIcon forKey:[NSNumber numberWithInt:index]];
			myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
			myIV.image = photo;
		}
		[imageDownloadsInProgress removeObjectForKey:indexPath];
		if ([imageDownloadsInWaiting count]>0) {
			imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
			[self startIconDownload:one.imageURL forIndex:one.indexPath];
			[imageDownloadsInWaiting removeObjectAtIndex:0];
		}
		
    }
}


- (void)viewWillAppear:(BOOL)animated{
	self.navigationController.toolbarHidden = YES;
	self.navigationController.navigationBarHidden = NO;
	[self.navigationController.navigationBar setTranslucent:YES];
//	[self.navigationController.toolbarHidden setTranslucent:YES];
	
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
	self.navigationController.toolbarHidden = YES;
}
//- (void)viewWillDisappear:(BOOL)animated{
//	 [self.navigationController.navigationBar setTranslucent:NO];
//	self.navigationController.toolbarHidden = YES;
//}
-(IBAction)HandleToBrowser:(id)sender{
	ProductDetailBrowserViewController *browser = [[ProductDetailBrowserViewController alloc]init];
	
	NSLog(@"product_desc:%@",[ar_product objectAtIndex:product_desc]);
	[self.navigationController pushViewController:browser animated:YES];
	if (showWhichOriginPic == SHOW_PRODUCT_PIC) {
		//[browser loadHtmlString:[ar_product objectAtIndex:product_desc]];
        if (IOS_VERSION >= 7.0) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1* NSEC_PER_SEC));
            
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [browser performSelector:@selector(loadHtmlString:) withObject:[ar_product objectAtIndex:product_desc]];
                
            });
        }else {
            [browser loadHtmlString:[ar_product objectAtIndex:product_desc]];
        }
	}
	else {
		NSArray *wp = [picArray objectAtIndex:pageControl.currentPage];
		
	}
	[browser release];
}
-(IBAction)HandleComment:(id)sender{
//	UIImage *photo = [indexToPicDic objectForKey:[NSNumber numberWithInt:pageControl.currentPage]];
//	if (photo == nil) {
//		[alertView showAlert:@"无法保存到本地相册"];
//	}
//	else {
//		UIImageWriteToSavedPhotosAlbum(photo, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//        [alertView showAlert:@"保存成功"];
//	}
	
	CommentListViewController *commentList = [[CommentListViewController alloc] init];
	commentList.productUrl = [ar_product objectAtIndex:product_url];
	commentList.productID = productId;
	commentList.moduleTitle = titleString;
	commentList.moduleType = product_module;
	[self.navigationController pushViewController:commentList animated:YES];
	[commentList release];
}

-(IBAction)HandleToWeChat:(id)sender{
	
	if(![WXApi isWXAppInstalled]){
		NSString *wechaturl = @"http://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8";
		UpdateAppAlert *alert =  [[UpdateAppAlert alloc]
								  initWithContent:nil content:@"使用微信可以方便、免费的与好友分享图片、新闻" 
								  leftbtn:@"取消" rightbtn:@"下载微信" url:wechaturl onViewController:self.navigationController];
		self.weChatAlert = alert;
		[weChatAlert showAlert];
		[alert release];
	}else {		
		NSArray *actionSheetMenu = [NSArray arrayWithObjects:@"去微信分享给好友",nil];
		manageActionSheet *actionsheet1 = [[manageActionSheet alloc]initActionSheetWithStrings:actionSheetMenu];
		actionsheet1.manageDeleage = self;
		actionsheet1.actionID = WECHAT_ACTIONSHEET_ID;
        
        AppStromAppDelegate *appDelegate = (AppStromAppDelegate *)[UIApplication sharedApplication].delegate;
        actionsheet1.block = ^{
            UIImageView *imageView = (UIImageView *)[appDelegate.window viewWithTag:88888];
            if (imageView) {
                [imageView removeFromSuperview];
            }
            NSLog(@"-----");
        };
        
		self.weChatActionsheet = actionsheet1;
		[actionsheet1 release];
		[weChatActionsheet showActionSheet:self.navigationController.navigationBar];		
	}
	
}

- (void) actionSheetAppear:(int)actionID actionSheet:(UIActionSheet *)actionSheet{
    
    if (actionID == WECHAT_ACTIONSHEET_ID) {
        
        NSLog(@"actionSheet.frame.size.height = %f",actionSheet.frame.size.height);
        
        int imageH = [UIScreen mainScreen].bounds.size.height - 20.0f - actionSheet.frame.size.height;
        int imageViewW = 320 * imageH/480;
        int imageViewX = (320 - imageViewW)/2;
        UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(pageControl.currentPage + 100)];
        myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
        
        UIImage *image = [myIV.image fillSize:CGSizeMake(160, 240)];
        //		UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, 20, imageViewW, imageH)];
        //写成固定的了。。。。
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, [UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.height - 100)];
        
        imageview.tag = 88888;
        imageview.image = image;
        
        AppStromAppDelegate *appDelegate = (AppStromAppDelegate *)[UIApplication sharedApplication].delegate;
        
        //		UIWindow *window = [UIApplication sharedApplication].keyWindow;
        //		if (!window)
        //		{
        //			window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        //		}
        [appDelegate.window addSubview:imageview];
        [imageview release];
    }
    
//	if (actionID == WECHAT_ACTIONSHEET_ID) {
//		int imageH = [UIScreen mainScreen].bounds.size.height - 20.0f - actionSheet.frame.size.height;
//		int imageViewW = 320 * imageH/480;
//		int imageViewX = (320 - imageViewW)/2;
//		UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(pageControl.currentPage + 100)];
//		myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
//		UIImage *image = [myIV.image fillSize:CGSizeMake(160, 240)];
//		UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, 20, imageViewW, imageH)];
//		imageview.image = image;
//		UIWindow *window = [UIApplication sharedApplication].keyWindow;
//		if (!window)
//		{
//			window = [[UIApplication sharedApplication].windows objectAtIndex:0];
//		}
//		[window addSubview:imageview];
//		[imageview release];
//	}	
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo; 
{
	if (!error) 
		NSLog(@"Image written to photo album");
	else
		NSLog(@"Error writing to photo album: %@", [error localizedDescription]);
}

- (void)getChoosedIndex:(int)actionID chooseIndex:(int)index{
	if (actionID == SHARE_ACTIONSHEET_ID) {
		NSString *linktitle;
		NSString *linkurl;
		if (showWhichOriginPic == SHOW_PRODUCT_PIC) {
			linkurl = [ar_product objectAtIndex:product_url];
			linktitle = [ar_product objectAtIndex:product_desc];
			
		}
		else {
			NSArray *wp = [picArray objectAtIndex:pageControl.currentPage];
			linkurl = [wp objectAtIndex:wallpaper_pic_url];
			linktitle = [wp objectAtIndex:wallpaper_title];
		}
		
		NSString *param = [NSString stringWithString:SHARE_CONTENT];
		
		NSString *param1 = [NSString stringWithFormat:@"[%@]  %@",linktitle,linkurl];
		param1 = [param stringByAppendingString:param1];
		param = [Common URLEncodedString:param1];
		
		switch (index) {
			case 0:
			{
				[callSystemApp sendMessageTo:@"" inUIViewController:self withContent:param1];
				break;
			}
			case 1:
			{////收件人，cc：抄送  subject：主题   body：内容
				[callSystemApp sendEmail:@"" cc:@"" subject:SHARE_CONTENT body:param1];
				break;
			}
			case 2:
			{
				//		    browserViewController *browser = [[browserViewController alloc]init];
				//			browser.isHideToolbar = NO;
				//			[self.navigationController pushViewController:browser animated:YES];
				//			browser.linkurl = linkurl;
				//			browser.linktitle = linktitle;
				//			[browser loadURL:[NSString stringWithFormat:SHARE_TO_SINA,param]];	
				//			browser.isFirstLoad = NO;
				//			[browser release];
				
				NSArray *weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType" theColumnValue:SINA withAll:NO];
				NSArray *array = nil;
				
				if(weiboArray != nil && [weiboArray count] > 0){
					array = [weiboArray objectAtIndex:0];
					int oauthTime = [[array objectAtIndex:weibo_oauth_time] intValue];
					int expiredTime = [[array objectAtIndex:weibo_expires_time] intValue];
					NSString *type = [array objectAtIndex:weibo_type];
					NSDate *todayDate = [NSDate date]; 
					NSLog(@"Date:%@",todayDate);
					NSTimeInterval inter = [todayDate timeIntervalSince1970]; 
					int time = inter;
					NSLog(@"current time:%d",time);
					NSLog(@"expiresTime:%d",expiredTime);
					NSLog(@"time - oauthTime:%d",time - oauthTime);
					if(expiredTime - (time - oauthTime) <= 0){
						[DBOperate deleteData:T_WEIBO_USERINFO tableColumn:@"weiboType" columnValue:type];
						weiboArray = nil;
					}
				}
				
				if (weiboArray != nil && [weiboArray count] > 0) {
					array = [weiboArray objectAtIndex:0];
					NSString *accessToken = [array objectAtIndex:weibo_access_token];
					double expiresTime = [[array objectAtIndex:weibo_expires_time] doubleValue];
					NSString *weibo_uid = [array objectAtIndex:weibo_user_id];
                    
                    //微博分享采用新的接口，使用SinaWeibo类
                    SinaWeibo *weibo = [[SinaWeibo alloc] initWithAppKey:SinaAppKey appSecret:SinaAppSecret appRedirectURI:redirectUrl andDelegate:nil];
                    weibo.userID = weibo_uid;
                    weibo.accessToken = accessToken;
                    weibo.expirationDate = [NSDate dateWithTimeIntervalSince1970:expiresTime];
                    
//					WBEngine *wbengine = [[WBEngine alloc] initWithAppKey:SinaAppKey appSecret:SinaAppSecret];
//					wbengine.accessToken = accessToken;
//					wbengine.userID = weibo_uid; 
//					wbengine.expireTime = expiresTime;
					//已经绑定了微博账号，调用新浪微博分享界面
					ShareToBlogViewController *share = [[ShareToBlogViewController alloc] init];
					UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(pageControl.currentPage + 100)];
					myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
					UIImage *img = myIV.image;
					share.shareImage = img;
					share.checkBoxSelected =YES;
					NSString *content = [ar_product objectAtIndex:product_name];
					NSString *param = [NSString stringWithString:SHARE_CONTENT];
					NSString *param1 = [NSString stringWithFormat:@"[%@]  %@",content,[ar_product objectAtIndex:product_url]];
					param1 = [param stringByAppendingString:param1];
					share.defaultContent = param1;
//					share.engine = wbengine;
                    share.sinaWeibo = weibo;
                    [weibo release];
					share.weiBoType = 0;
					[self.navigationController pushViewController:share animated:YES];
					[share release];
					
				}else {
					LoginViewController *login = [[LoginViewController alloc] init];
					login.delegate = self;
					[self.navigationController pushViewController:login animated:YES];
					[login release];
				}
				break;
			}
			case 3:
			{
				//			browserViewController *browser = [[browserViewController alloc]init];
				//			browser.isHideToolbar = NO;
				//			[self.navigationController pushViewController:browser animated:YES];
				//			browser.linkurl = linkurl;
				//			[browser loadURL:[NSString stringWithFormat:SHARE_TO_QQ,param]];	
				//			browser.linktitle = linktitle;
				//			browser.isFirstLoad = NO;
				//			[browser release];
				
				NSArray *weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType" theColumnValue:TENCENT withAll:NO];
				NSArray *array = nil;
				
				if(weiboArray != nil && [weiboArray count] > 0){
					int expiredTime = [[array objectAtIndex:weibo_expires_time] intValue];
					NSDate *todayDate = [NSDate date]; 
					NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:expiredTime];
					NSLog(@"todayDate:%@",todayDate);
					NSLog(@"expirationDate:%@",expirationDate);
					if([todayDate compare:expirationDate] == NSOrderedSame){
						[DBOperate deleteData:T_WEIBO_USERINFO tableColumn:@"weiboType" columnValue:TENCENT];
						weiboArray = nil;
					}else {
						NSLog(@"not expired");
					}
				}
				
				if (weiboArray != nil && [weiboArray count] > 0) {
					array = [weiboArray objectAtIndex:0];
					NSString *accessToken = [array objectAtIndex:weibo_access_token];
					NSString *openid = [array objectAtIndex:weibo_open_id];
					NSString *username = [array objectAtIndex:weibo_user_name];
					
					ShareToBlogViewController *share = [[ShareToBlogViewController alloc] init];
					UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(pageControl.currentPage + 100)];
					myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
					UIImage *img = myIV.image;
					share.shareImage = img;
					share.checkBoxSelected =YES;
					share.qAccessToken = accessToken;
					share.qOpenid = openid;
					share.qWeiboUserName = username;
					NSString *content = [ar_product objectAtIndex:product_name];
					NSString *param = [NSString stringWithString:SHARE_CONTENT];
					NSString *param1 = [NSString stringWithFormat:@"[%@]  %@",content,[ar_product objectAtIndex:product_url]];
					param1 = [param stringByAppendingString:param1];
					share.defaultContent = param1;
					share.weiBoType = 1;
					[self.navigationController pushViewController:share animated:YES];
					[share release];
				}else{	
					LoginViewController *login = [[LoginViewController alloc] init];
					login.delegate = self;
					[self.navigationController pushViewController:login animated:YES];
					[login release];
				}
				break;
			}
			case 4:			
			{
				ShareWithQRCodeViewController *share = [[ShareWithQRCodeViewController alloc]init];
				share.linkurl = [ar_product objectAtIndex:product_url];
				share.linktitle = self.titleString;
				[self.navigationController pushViewController:share animated:YES];
				[share release];
				break;
			}
			default:
				break;
		}
	}else if (actionID == WECHAT_ACTIONSHEET_ID) {
		NSLog(@"wechatshare");
		switch (index) {
			case 0:
			{
				UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(pageControl.currentPage + 100)];
				UIScrollView *textScrollView = (UIScrollView *)[scrollview viewWithTag:(pageControl.currentPage + 108)];
				DSURLView *urlView = (DSURLView *)[textScrollView viewWithTag:(pageControl.currentPage + 208)];
				
				myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
				UIImage *img = myIV.image;
				NSString *newsTitle = [ar_product objectAtIndex:product_name];
				//NSString *newsDesc = urlView.sourceText;
                NSString *newsDesc = [ar_product objectAtIndex:product_desc];
				NSString *url = [ar_product objectAtIndex:product_url];
				url = [url stringByAppendingFormat:@"&isFromWeixin=1"];
				
				SendMsgToWeChat *sendMsg = [[SendMsgToWeChat alloc] init];	
				if (app_wechat_share_type == app_to_wechat) {
					[sendMsg sendNewsContent:newsTitle newsDescription:newsDesc newsImage:[img fillSize:CGSizeMake(114, 114)]newUrl:url];
				}else if (app_wechat_share_type == wechat_to_app) {
					[sendMsg RespNewsContent:newsTitle newsDescription:newsDesc newsImage:[img fillSize:CGSizeMake(114, 114)]newUrl:url];
				}			
				[sendMsg release];
				break;
			}
			default:
				break;
		}
	}
	
}

#pragma mark -
#pragma mark LoginViewController delegate

-(void)loginSuccess:(NSString*)withLoginType{
	NSString *linkurl = [ar_product objectAtIndex:product_url];
	NSString *linktitle = [ar_product objectAtIndex:product_name];
	if ([withLoginType isEqualToString:SINA]) {
		NSArray *weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType" theColumnValue:SINA withAll:NO];
		NSArray *array = nil;
		if (weiboArray != nil && [weiboArray count] > 0) {
			array = [weiboArray objectAtIndex:0];
			NSString *accessToken = [array objectAtIndex:weibo_access_token];
			double expiresTime = [[array objectAtIndex:weibo_expires_time] doubleValue];
			NSString *weibo_uid = [array objectAtIndex:weibo_user_id];
            
            //微博分享采用新的接口，使用SinaWeibo类
            SinaWeibo *weibo = [[SinaWeibo alloc] initWithAppKey:SinaAppKey appSecret:SinaAppSecret appRedirectURI:redirectUrl andDelegate:nil];
            weibo.userID = weibo_uid;
            weibo.accessToken = accessToken;
            weibo.expirationDate = [NSDate dateWithTimeIntervalSince1970:expiresTime];
            
//			WBEngine *wbengine = [[WBEngine alloc] initWithAppKey:SinaAppKey appSecret:SinaAppSecret];
//			wbengine.accessToken = accessToken;
//			wbengine.userID = weibo_uid; 
//			wbengine.expireTime = expiresTime;
			//已经绑定了微博账号，调用新浪微博分享界面
			ShareToBlogViewController *share = [[ShareToBlogViewController alloc] init];
			UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(pageControl.currentPage + 100)];
			myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
			UIImage *img = myIV.image;
			share.shareImage = img;
			share.checkBoxSelected =YES;
			NSString *content = linktitle;
			NSString *param = [NSString stringWithString:SHARE_CONTENT];
			NSString *param1 = [NSString stringWithFormat:@"[%@]  %@",content,linkurl];
			param1 = [param stringByAppendingString:param1];
			share.defaultContent = param1;
//			share.engine = wbengine;
            share.sinaWeibo = weibo;
            [weibo release];
			share.weiBoType = 0;
			[self.navigationController pushViewController:share animated:YES];
//			[wbengine release];
			[share release];
		}
	}else if ([withLoginType isEqualToString:TENCENT]) {
		NSArray *weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType" theColumnValue:TENCENT withAll:NO];
		NSArray *array = nil;
		if (weiboArray != nil && [weiboArray count] > 0) {
			array = [weiboArray objectAtIndex:0];
			NSString *accessToken = [array objectAtIndex:weibo_access_token];
			NSString *openid = [array objectAtIndex:weibo_open_id];
			NSString *username = [array objectAtIndex:weibo_user_name];
			
			ShareToBlogViewController *share = [[ShareToBlogViewController alloc] init];
			UIScrollView *subscroll = (UIScrollView *)[scrollview viewWithTag:(pageControl.currentPage + 100)];
			myImageView *myIV = (myImageView *)[subscroll viewWithTag:1001];
			UIImage *img = myIV.image;
			share.shareImage = img;
			share.checkBoxSelected =YES;
			share.qAccessToken = accessToken;
			share.qOpenid = openid;
			share.qWeiboUserName = username;
			NSString *content = linktitle;
			NSString *param = [NSString stringWithString:SHARE_CONTENT];
			NSString *param1 = [NSString stringWithFormat:@"[%@]  %@",content,linkurl];
			param1 = [param stringByAppendingString:param1];
			share.defaultContent = param1;
			share.weiBoType = 1;
			[self.navigationController pushViewController:share animated:YES];
			[share release];
		}
	}
}


-(IBAction)HandleShare:(id)sender{
	NSArray *actionSheetMenu = [NSArray arrayWithObjects:@"分享给手机用户",@"分享给邮箱联系人",@"分享到新浪微博",@"分享到腾讯微博",@"二维码分享",nil];
	manageActionSheet *actionsheet1 = [[manageActionSheet alloc]initActionSheetWithStrings:actionSheetMenu];
	actionsheet1.manageDeleage = self;
	actionsheet1.actionID = SHARE_ACTIONSHEET_ID;
	self.actionsheet = actionsheet1;
	[actionsheet1 release];
	[actionsheet showActionSheet:self.navigationController.navigationBar];	
	
}
/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"%s", _cmd);
    
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2)
    {
        //NSLog(@"double click");
        
        CGFloat zs = self.zoomScale;
        zs = (zs == 1.0) ? 2.0 : 1.0;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];            
        self.zoomScale = zs;    
        [UIView commitAnimations];
    }
}*/
-(void)touchOnce{

	BOOL navBarState = [self.navigationController isNavigationBarHidden];
	[self.navigationController setNavigationBarHidden:!navBarState animated:YES];
//    [self.navigationController setToolbarHidden:!navBarState animated:YES];
	UIImageView *toolview = (UIImageView *)[self.view viewWithTag:3005];
	[toolview setHidden:!navBarState];
	for (int i = 0; i < [picArray count];i++ ) {
		UIScrollView *sc = (UIScrollView *)[self.view viewWithTag:108 + i];
		[sc setHidden:!navBarState];
	}

}
- (void)imageViewTouchesEnd:(int)picId{

/*	BOOL navBarState = [self.navigationController isNavigationBarHidden];
	[self.navigationController setNavigationBarHidden:!navBarState animated:YES];
    [self.navigationController setToolbarHidden:!navBarState animated:YES];*/
}
/*- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView{
	NSLog(@"scroll");
	if (aScrollView.tag == 1000) {
		CGPoint offset = aScrollView.contentOffset;
		int x = offset.x;
		int width = aScrollView.frame.size.width;
		
		int xx = x / width;
		int yy = x % width;
		if (yy > aScrollView.frame.size.width/2) {
			xx++;
		}
		NSLog(@"yy %d ",xx);
		CGPoint p = CGPointMake(xx*aScrollView.frame.size.width, offset.y);
		[aScrollView setContentOffset:p animated:YES];
		imageviewTagtmp =imageviewTag+offset.x / aScrollView.frame.size.width;
		
	}
	
}*/
- (void) pageTurn: (UIPageControl *) aPageControl
{
	NSLog(@"come to pageturn");
	int whichPage = aPageControl.currentPage;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	scrollview.contentOffset = CGPointMake(self.view.frame.size.width * whichPage, 0.0f);
	[UIView commitAnimations];
	
}
- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
	
	
	if(aScrollView.tag == 1000){
		CGPoint offset = aScrollView.contentOffset;
        NSLog(@"offset = %f",offset.x);
        
		pageControl.currentPage = offset.x / self.view.frame.size.width;
		//
		NSString *s = @"";//@"组图";
		NSString *tString = [titleString stringByAppendingFormat:s];
		NSString *num = [NSString stringWithFormat:@"(%d/%lu)",pageControl.currentPage + 1,(unsigned long)[picArray count]];
		if (tString != nil && [picArray count] > 1) {
			self.title = [tString stringByAppendingFormat:num];
		}else {
			self.title = tString;
		}
		
		//[self performSelector:@selector(showInCurrentPic:) withObject:pageControl.currentPage afterDelay:0.1];
		[self showInCurrentPic:pageControl.currentPage];
	}
	//wallpaper *wp = [picArray objectAtIndex:pageControl.currentPage];
	//[self startIconDownload:wp.pic forIndex:[NSIndexPath indexPathWithIndex:pageControl.currentPage]];

}

/*- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
	if (aScrollView.tag == 1000) {
		CGPoint offset = aScrollView.contentOffset;
		int x = offset.x;
		int width = aScrollView.frame.size.width;
		
		int xx = x / width;
		int yy = x % width;
		if (yy > aScrollView.frame.size.width/2) {
			xx++;
		}
		CGPoint p = CGPointMake(xx*aScrollView.frame.size.width, offset.y);
		[aScrollView setContentOffset:p animated:YES];
		//float x = offset.x / aScrollView.frame.size.width; 
		//aScrollView.contentOffset = offset.x%aScrollView.frame.size.width>aScrollView.frame.size.width?
		imageviewTagtmp =imageviewTag+offset.x / aScrollView.frame.size.width;

	}
}*/
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
   	if (scrollView.tag == 1000) {
		return nil;
	}
	UIImageView *imageview = (UIImageView *)[scrollView viewWithTag:1001];
	return imageview;
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
	NSLog(@"scele %f",scale);
	if (scrollView.tag != 1000) {
		UIImage *photo = [indexToPicDic objectForKey:[NSNumber numberWithInt:(scrollView.tag-100)]];
		float pwidth = scrollView.frame.size.width*scale;
		float pheigth = scrollView.frame.size.height*scale;
  
	/*	float pwidth = photo.size.width;
		float pheigth = photo.size.height;
		if (scrollView.frame.size.width*scale<pwidth) {
			pwidth = scrollView.frame.size.width*scale;
		}
		else {
			pwidth = scrollView.frame.size.width;
		}

		if (scrollView.frame.size.height*scale<pheigth) {
			pheigth = scrollView.frame.size.height*scale;
		}
		else {
			pheigth = scrollView.frame.size.height;
		}



		UIImageView *imageview = (UIImageView*)view;
		float vwidth = scrollView.frame.size.width;
		float vheight = scrollView.frame.size.height;
		if(pwidth>vwidth)
		{
			vwidth = pwidth;
		}
		if (pheigth>vheight) {
			vheight = pheigth;
		}*/
		UIImageView *imageview = (UIImageView*)view;
		scrollView.contentSize = CGSizeMake(pwidth,pheigth);// dragger.frame.size;
		imageview.frame =CGRectMake(0, 0, pwidth, pheigth);// CGSizeMake(self.frame.size.width*2,self.frame.size.height*2);
		//NSArray *wp = [picArray objectAtIndex:pageControl.currentPage];

	/*	if (showWhichOriginPic == SHOW_PRODUCT_PIC) {
			photo = [FileManager getPhoto:[wp objectAtIndex:originpic_pic1_name]];
		}
		else {
			photo = [FileManager getPhoto:[wp objectAtIndex:wallpaper_pic_name]];
		}
		*/
		imageview.image= [photo fillSize:CGSizeMake(pwidth, pheigth)];
		
	}
	
}
-(IBAction)turnBack:(id)sender{

	[self dismissModalViewControllerAnimated:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark DSURLViewDelegate method

- (void)urlWasClicked:(DSURLView *)urlView urlString:(NSString *)urlString {
	if (urlString.length > 1) {
		[callSystemApp makeCall:urlString];
	}
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.titleString = nil;
	self.picArray = nil;
	self.indexToPicDic = nil;
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.pageControl = nil;
	for (UIView *innerview in [self.scrollview subviews]){
		[innerview removeFromSuperview];
	}
    self.scrollview = nil;
	self.toolBar = nil;
	self.weChatActionsheet = nil;
	self.weChatAlert = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.titleString = nil;
	self.picArray = nil;
	self.originPic = nil;
	self.dragger = nil;
	self.picName = nil;
	self.toolBar = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress=nil;
	self.imageDownloadsInWaiting=nil;
	self.pageControl = nil;
	for (UIView *innerview in [self.scrollview subviews]){
		
			for (UIView *iinner in [innerview subviews]){
				[iinner removeFromSuperview];
			}
		
		[innerview removeFromSuperview];
	}
	
	self.scrollview = nil;
	self.ar_product = nil;
	self.actionsheet = nil;
	self.indexToPicDic = nil;
	self.productId = nil;
	self.weChatActionsheet = nil;
	self.weChatAlert = nil;
    [super dealloc];
}


@end
