local lottery=
{
	name="lottery",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Bg",type=1,typeName="Image",time=0,x=0,y=0,width=696,height=594,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/lottery/lottery_bg.png",callbackfunc="onPopupBgTouch",varname="Bg",
		{
			name="LotteryButton",type=1,typeName="Button",time=0,x=0,y=75,width=390,height=128,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/lottery/lottery_btn1.png",varname="LotteryButton",callbackfunc="OnLotteryClick",
			{
				name="Image6",type=1,typeName="Image",time=0,x=0,y=24,width=166,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/lottery/lottery_num_bg.png"
			},
			{
				name="Num",type=4,typeName="Text",time=0,x=0,y=24,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=18,textAlign=kAlignCenter,colorRed=120,colorGreen=55,colorBlue=0,string=[[Text]],colorA=1,varname="Num"
			}
		},
		{
			name="CloseButton",type=1,typeName="Button",time=0,x=627,y=93,width=51,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_pop_close.png",varname="CloseButton",callbackfunc="OnCloseClick"
		},
		{
			name="Select",type=1,typeName="Image",time=0,x=-2,y=-58,width=122,height=122,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/lottery/lottery_select.png",varname="Select"
		}
	}
}
return lottery;