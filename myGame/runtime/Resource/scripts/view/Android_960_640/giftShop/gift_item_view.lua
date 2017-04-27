local gift_item_view=
{
	name="gift_item_view",type=0,typeName="View",time=0,x=0,y=0,width=118,height=118,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="gift_btn",type=1,typeName="Button",time=0,x=0,y=0,width=110,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/gift/gift_bg.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,varname="gift_btn",callbackfunc="onGiftBtnClick",
		{
			name="gift_view",type=0,typeName="View",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,varname="gift_view"
		},
		{
			name="gift_icon",type=1,typeName="Image",time=0,x=0,y=9,width=88,height=47,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/default3.png",varname="gift_icon"
		},
		{
			name="Image6",type=1,typeName="Image",time=0,x=0,y=-41,width=104,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/gift/gift_title.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10
		},
		{
			name="gift_desc",type=4,typeName="Text",time=0,x=15,y=6,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=16,textAlign=kAlignLeft,colorRed=230,colorGreen=215,colorBlue=251,string=[[1000 (3天)]],varname="gift_desc",colorA=1
		},
		{
			name="gift_selected",type=1,typeName="Image",time=0,x=0,y=-1,width=110,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/lottery/lottery_select.png",varname="gift_selected"
		}
	}
}
return gift_item_view;