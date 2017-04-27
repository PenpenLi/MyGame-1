local share_layer=
{
	name="share_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=725,height=430,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_small.png",varname="Image_bg",callbackfunc="onPopupBgTouch",
		{
			name="Image4",type=1,typeName="Image",time=0,x=199,y=12,width=326,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_pop_bg_title.png",gridLeft=150,gridRight=150,gridTop=35,gridBottom=35,
			{
				name="Text_title",type=4,typeName="Text",time=0,x=85,y=19,width=161,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_title"
			}
		},
		{
			name="TextView_content",type=5,typeName="TextView",time=0,x=51,y=143,width=634,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[TextView]],colorA=1,varname="TextView_content"
		},
		{
			name="Button_share",type=1,typeName="Button",time=0,x=259,y=300,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_purple.png",varname="Button_share",callbackfunc="bt_share_click",
			{
				name="Text_bt_share",type=4,typeName="Text",time=0,x=26,y=15,width=146,height=37,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_bt_share"
			}
		}
	}
}
return share_layer;