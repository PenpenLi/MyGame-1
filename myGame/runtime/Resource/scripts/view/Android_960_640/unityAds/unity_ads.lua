local unity_ads=
{
	name="unity_ads",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=570,height=420,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_small1.png",varname="Image_bg",callbackfunc="onPopupBgTouch",
		{
			name="Image8",type=1,typeName="Image",time=0,x=-5,y=-159,width=418,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_title2.png",
			{
				name="Text_title",type=4,typeName="Text",time=0,x=3,y=1,width=314,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1,varname="Text_title"
			}
		},
		{
			name="btn_video",type=1,typeName="Button",time=0,x=348,y=160,width=198,height=158,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/unityAds/video_btn_bg.png",varname="btn_video",callbackfunc="onBtnVideoClick",
			{
				name="Image11",type=1,typeName="Image",time=0,x=32,y=18,width=116,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/unityAds/video_btn_1.png"
			},
			{
				name="Image12",type=1,typeName="Image",time=0,x=32,y=18,width=116,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/unityAds/video_btn_2.png"
			},
			{
				name="img_loading",type=1,typeName="Image",time=0,x=5,y=4,width=176,height=137,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_transparent_blank.png",varname="img_loading",callbackfunc="onImgLoadingClick",
				{
					name="text_loading",type=5,typeName="TextView",time=0,x=17,y=19,width=148,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=16,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[视频准备中，请稍后开始观看]],colorA=1,varname="text_loading"
				}
			}
		},
		{
			name="Image13",type=1,typeName="Image",time=0,x=-113,y=-53,width=262,height=524,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/unityAds/video_woman.png"
		},
		{
			name="text_desc",type=5,typeName="TextView",time=0,x=131,y=162,width=206,height=155,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignTopLeft,colorRed=250,colorGreen=230,colorBlue=255,colorA=1,string=[[1~10次]],varname="text_desc"
		},
		{
			name="text_reward",type=5,typeName="TextView",time=0,x=353,y=312,width=178,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignTop,colorRed=255,colorGreen=246,colorBlue=0,string=[[10M koin]],colorA=1,varname="text_reward"
		}
	}
}
return unity_ads;