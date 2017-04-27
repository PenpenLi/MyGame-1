local victoryPopup=
{
	name="victoryPopup",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bgVictory",type=1,typeName="Image",time=0,x=0,y=0,width=480,height=320,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="game/backgroud/bg0.png",varname="bgVictory",
		{
			name="tvWin",type=5,typeName="TextView",time=0,x=17,y=17,width=267,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=0,colorGreen=0,colorBlue=0,string=[[TextView]],varname="tvWin",colorA=1
		},
		{
			name="pigSwf",type=0,typeName="Swf",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,swfFrame=1,swfKeep=1,swfRepeat=-1,swfDelay=0,swfAuto=1,swfAutoClean=1,swfInfoLua="qnRes/qnSwfRes/swf/pig_swf_info",swfPinLua="qnRes/qnSwfRes/swf/pig_swf_pin",varname="pigSwf"
		}
	}
}
return victoryPopup;