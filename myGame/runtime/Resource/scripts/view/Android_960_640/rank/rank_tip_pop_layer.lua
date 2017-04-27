local rank_tip_pop_layer=
{
	name="rank_tip_pop_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=570,height=420,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_small1.png",varname="bg",callbackfunc="onPopupBgTouch",
		{
			name="titleBg",type=1,typeName="Image",time=0,x=0,y=11,width=375,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_title1.png",
			{
				name="titleLabel",type=4,typeName="Text",time=0,x=0,y=0,width=194,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[温馨提示]],colorA=1,varname="titleLabel"
			}
		},
		{
			name="closeButton",type=1,typeName="Button",time=0,x=22,y=21,width=51,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="res/common/common_close_btn.png",varname="closeButton",callbackfunc="onCloseButtonClick"
		},
		{
			name="tipContentLabel",type=5,typeName="TextView",time=0,x=0,y=108,width=522,height=214,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,colorA=1,varname="tipContentLabel"
		},
		{
			name="playButton",type=1,typeName="Button",time=0,x=2,y=322,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_btn_yellow.png",gridLeft=50,gridRight=50,gridTop=35,gridBottom=34,varname="playButton",callbackfunc="onPlayButtonClick",
			{
				name="playBtnLabel",type=4,typeName="Text",time=0,x=0,y=2,width=155,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[马上玩牌]],varname="playBtnLabel"
			}
		}
	}
}
return rank_tip_pop_layer;