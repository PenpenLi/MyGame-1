local share_to_fb_layer=
{
	name="share_to_fb_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,stageW=0,
	{
		name="Image2",type=1,typeName="Image",time=0,x=0,y=0,width=710,height=517,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_pop_bg.png",
		{
			name="ButtonClose",type=1,typeName="Button",time=0,x=626,y=15,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_pop_close.png",callbackfunc="onBgTouch",varname="ButtonClose"
		},
		{
			name="View6",type=0,typeName="View",time=0,x=83,y=160,width=525,height=231,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="View_container"
		},
		{
			name="EditTextView10",type=7,typeName="EditTextView",time=0,x=102,y=108,width=476,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Input your words]],colorA=1,varname="EditTextView_caption"
		},
		{
			name="Image11",type=1,typeName="Image",time=0,x=81,y=98,width=531,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/chat/chat_change_btn_bg.png",gridLeft=50,gridRight=50
		},
		{
			name="Button12",type=1,typeName="Button",time=0,x=240,y=417,width=218,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/gift/gift_btn_2.png",gridLeft=25,gridRight=25,gridTop=18,gridBottom=18,varname="Button_share",callbackfunc="onBtnShareClicked",
			{
				name="Text13",type=4,typeName="Text",time=0,x=8,y=10,width=204,height=39,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Share To Facebook]],colorA=1
			}
		},
		{
			name="TextTitle",type=4,typeName="Text",time=0,x=266,y=28,width=204,height=43,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Share To Facebook]],colorA=1
		}
	}
}
return share_to_fb_layer;