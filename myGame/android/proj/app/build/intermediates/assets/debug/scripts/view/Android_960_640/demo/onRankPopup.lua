local onRankPopup=
{
	name="onRankPopup",type=0,typeName="View",time=0,x=0,y=0,width=960,height=600,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=800,height=600,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="game/backgroud/bg0.png",varname="bg",callbackfunc="onPopupBgTouch",
		{
			name="RadioButtonGroup",type=0,typeName="RadioButtonGroup",time=0,x=2,y=100,width=553,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,varname="RadioButtonGroup",
			{
				name="gentleRadioButton",type=0,typeName="RadioButton",time=0,x=0,y=0,width=276,height=68,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="game/button/gentle.png",file2="game/button/gentleMode.png",varname="gentleRadioButton"
			},
			{
				name="crazyRadioButton",type=0,typeName="RadioButton",time=0,x=0,y=0,width=276,height=68,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="game/button/crazy.png",file2="game/button/crazyMode.png",varname="crazyRadioButton"
			}
		},
		{
			name="ListView",type=0,typeName="ListView",time=0,x=3,y=48,width=554,height=315,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="ListView"
		},
		{
			name="ImageHead",type=1,typeName="Image",time=0,x=709,y=92,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="game/backgroud/bgMyrank.png",varname="ImageHead",
			{
				name="myRankTextView",type=5,typeName="TextView",time=0,x=-1,y=-1,width=63,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=40,textAlign=kAlignCenter,colorRed=0,colorGreen=0,colorBlue=0,colorA=1,varname="myRankTextView"
			}
		}
	}
}
return onRankPopup;