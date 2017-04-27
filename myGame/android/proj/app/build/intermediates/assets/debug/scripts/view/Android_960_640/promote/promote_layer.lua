local promote_layer=
{
	name="promote_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=710,height=517,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_pop_bg.png",varname="Image_bg",callbackfunc="onPopupBgTouch",
		{
			name="Image3",type=1,typeName="Image",time=0,x=0,y=-217,width=326,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_pop_bg_title.png",gridLeft=150,gridRight=150,gridTop=35,gridBottom=35,
			{
				name="Text_title",type=4,typeName="Text",time=0,x=0,y=0,width=162,height=37,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_title"
			}
		},
		{
			name="Image_info",type=1,typeName="Image",time=0,x=0,y=-1,width=660,height=310,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_blank.png",varname="Image_info"
		},
		{
			name="btn_go",type=1,typeName="Button",time=0,x=0,y=193,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_btn_yellow.png",gridLeft=50,gridRight=50,gridTop=35,gridBottom=34,varname="btn_go",callbackfunc="btn_go_click",
			{
				name="btn_go_text",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=41,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[测试文本啊测试]],colorA=1,varname="btn_go_text"
			}
		}
	}
}
return promote_layer;