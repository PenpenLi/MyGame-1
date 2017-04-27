local exitPopup=
{
	name="exitPopup",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="exitPopupBg",type=1,typeName="Image",time=0,x=0,y=0,width=480,height=320,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="game/backgroud/bg5.png",varname="exitPopupBg",
		{
			name="pigImg",type=1,typeName="Image",time=0,x=23,y=81,width=200,height=200,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="game/common/pig.png",varname="pigImg"
		},
		{
			name="cancelBut",type=1,typeName="Button",time=0,x=250,y=37,width=221,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="game/button/cancel2.png",varname="cancelBut"
		},
		{
			name="leaveBtn",type=1,typeName="Button",time=0,x=250,y=184,width=160,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="game/button/exit.png",varname="leaveBtn"
		},
		{
			name="btnCrazy",type=1,typeName="Button",time=0,x=42,y=54,width=260,height=80,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="88fd3d5d98e7d3910c00edb494f3f815",varname="btnCrazy"
		},
		{
			name="btnGentle",type=1,typeName="Button",time=0,x=187,y=189,width=260,height=80,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="game/button/gentle.png",varname="btnGentle"
		}
	}
}
return exitPopup;