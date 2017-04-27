local photoManager=
{
	name="photoManager",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image3",type=1,typeName="Image",time=0,x=0,y=0,width=570,height=420,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_small1.png",callbackfunc="onPopupBgTouch",varname="Image3",
		{
			name="Image6",type=1,typeName="Image",time=0,x=0,y=-160,width=326,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_title1.png"
		},
		{
			name="Image7",type=1,typeName="Image",time=0,x=0,y=35,width=538,height=290,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/photoManager/photo_bg.png"
		},
		{
			name="Title",type=4,typeName="Text",time=0,x=0,y=-162,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[相册管理]],colorA=1,varname="Title"
		},
		{
			name="tips",type=5,typeName="TextView",time=0,x=0,y=25,width=530,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=12,textAlign=kAlignCenter,colorRed=195,colorGreen=150,colorBlue=255,string=[[TextView]],varname="tips",colorA=1
		},
		{
			name="PhotoListView",type=0,typeName="ListView",time=0,x=0,y=35,width=540,height=290,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="PhotoListView"
		}
	}
}
return photoManager;