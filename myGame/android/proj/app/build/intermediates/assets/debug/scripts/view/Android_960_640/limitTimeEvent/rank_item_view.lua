local rank_item_view=
{
	name="rank_item_view",type=0,typeName="View",time=0,x=0,y=0,width=60,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="headButton",type=1,typeName="Button",time=0,x=0,y=5,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_transparent.png",varname="headButton",callbackfunc="onHeadButtonClick",
		{
			name="headImage",type=1,typeName="Image",time=0,x=0,y=0,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_nophoto.jpg",varname="headImage"
		},
		{
			name="Vipk",type=1,typeName="Image",time=0,x=0,y=0,width=80,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/hall/hall_playerhead_bg.png",varname="Vipk"
		}
	},
	{
		name="cur_num",type=4,typeName="Text",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=16,textAlign=kAlignCenter,colorRed=188,colorGreen=190,colorBlue=255,string=[[100]],varname="cur_num",colorA=1
	}
}
return rank_item_view;