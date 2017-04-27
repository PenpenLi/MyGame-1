local roomChoose_item=
{
	name="roomChoose_item",type=0,typeName="View",time=0,x=0,y=0,width=406,height=162,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="roomStep",type=1,typeName="Button",time=0,x=0,y=0,width=406,height=162,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_step_1.png",varname="roomStep",
		{
			name="minOrMax",type=4,typeName="Text",time=0,x=166,y=43,width=200,height=25,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignLeft,colorRed=239,colorGreen=224,colorBlue=251,string=[[最小/最大携带 1M/5M]],varname="minOrMax",colorA=1
		},
		{
			name="Image4",type=1,typeName="Image",time=0,x=172,y=85,width=48,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/roomChoose/roomC_onlineNum_icon.png"
		},
		{
			name="onlineNum",type=4,typeName="Text",time=0,x=221,y=87,width=100,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=239,colorGreen=224,colorBlue=251,string=[[--]],varname="onlineNum",colorA=1
		},
		{
			name="betsIon",type=1,typeName="Image",time=0,x=43,y=69,width=86,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/roomChoose/roomC_bet.png",varname="betsIon"
		},
		{
			name="betsNode",type=0,typeName="View",time=0,x=85,y=35,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="betsNode"
		},
		{
			name="clock_icon",type=1,typeName="Image",time=0,x=35,y=-5,width=64,height=61,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="res/roomChoose/roomC_clock_icon.png",varname="clock_icon"
		}
	}
}
return roomChoose_item;