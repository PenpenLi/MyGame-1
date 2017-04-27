local get_reward=
{
	name="get_reward",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=556,height=297,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_no_title_bg.png",gridLeft=30,gridRight=30,gridTop=30,gridBottom=30,varname="Image_bg",callbackfunc="onPopupBgTouch",
		{
			name="text_info",type=4,typeName="Text",time=0,x=0,y=-96,width=120,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[输入新游戏内的数字账号ID]],colorA=1,varname="text_info"
		},
		{
			name="Image9",type=1,typeName="Image",time=0,x=104,y=100,width=347,height=49,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_bg_1.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15
		},
		{
			name="EditText_id",type=6,typeName="EditText",time=0,x=115,y=107,width=325,height=41,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[256879]],colorA=1,varname="EditText_id"
		},
		{
			name="btn_get_reward",type=1,typeName="Button",time=0,x=182,y=188,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_yellow.png",gridLeft=50,gridRight=50,gridTop=35,gridBottom=34,varname="btn_get_reward",callbackfunc="onBtnGetRewardClick",
			{
				name="btn_get_reward_text",type=4,typeName="Text",time=0,x=6,y=-1,width=180,height=72,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="btn_get_reward_text"
			}
		}
	}
}
return get_reward;