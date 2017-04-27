local gameTip=
{
	name="gameTip",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="tipimage",type=1,typeName="Image",time=0,x=80,y=0,width=300,height=300,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="game/exitPopupBg.png",varname="tipimage",
		{
			name="tip",type=5,typeName="TextView",time=0,x=18,y=20,width=262,height=256,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignTopLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[TextView]],colorA=1,varname="tip"
		},
		{
			name="bar",type=1,typeName="Image",time=0,x=232,y=202,width=64,height=93,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="game/low1_80_100.png",varname="bar"
		}
	}
}
return gameTip;