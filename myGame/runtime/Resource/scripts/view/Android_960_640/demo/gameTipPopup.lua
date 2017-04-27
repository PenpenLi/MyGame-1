local gameTipPopup=
{
	name="gameTipPopup",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="tipImageBg",type=1,typeName="Image",time=0,x=0,y=0,width=750,height=550,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="game/backgroud/bg0.png",varname="tipImageBg",
		{
			name="tip",type=5,typeName="TextView",time=0,x=79,y=39,width=264,height=426,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[TextView]],colorA=1,varname="tip"
		},
		{
			name="imageTip",type=1,typeName="Image",time=0,x=320,y=124,width=407,height=310,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="game/gestures/tipLittle.png",varname="imageTip"
		}
	}
}
return gameTipPopup;