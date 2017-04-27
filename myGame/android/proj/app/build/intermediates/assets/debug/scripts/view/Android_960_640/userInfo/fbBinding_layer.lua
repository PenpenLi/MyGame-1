local fbBinding_layer=
{
	name="fbBinding_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=16,width=570,height=420,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_small1.png",varname="Image_bg",callbackfunc="onPopupBgTouch",
		{
			name="Image3",type=1,typeName="Image",time=0,x=0,y=14,width=326,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_title1.png"
		},
		{
			name="title",type=4,typeName="Text",time=0,x=0,y=40,width=152,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="title"
		},
		{
			name="binding_btn",type=1,typeName="Button",time=0,x=0,y=40,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="res/common/common_btn_purple.png",gridLeft=40,gridRight=40,varname="binding_btn",
			{
				name="binding_name",type=4,typeName="Text",time=0,x=26,y=6,width=142,height=49,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=26,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="binding_name"
			}
		},
		{
			name="bind_tips",type=5,typeName="TextView",time=0,x=0,y=-5,width=496,height=188,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignTopLeft,colorRed=230,colorGreen=215,colorBlue=251,string=[[TextView]],varname="bind_tips",colorA=1
		}
	}
}
return fbBinding_layer;