local setting_layer=
{
	name="setting_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=710,height=517,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_big.png",varname="Image_bg",callbackfunc="onPopupBgTouch",
		{
			name="Image3",type=1,typeName="Image",time=0,x=0,y=-216,width=326,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_title1.png",
			{
				name="Text_title",type=4,typeName="Text",time=0,x=0,y=0,width=156,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_title",colorA=1
			}
		},
		{
			name="Image_head_bg",type=1,typeName="Image",time=0,x=0,y=-120,width=684,height=97,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/setting/setting_head_bg.png",varname="Image_head_bg",
			{
				name="Image_head_kuang",type=1,typeName="Image",time=0,x=21,y=12,width=72,height=73,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/setting/seting_head.png",varname="Image_head_kuang",
				{
					name="Image_head",type=1,typeName="Image",time=0,x=0,y=0,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_nophoto.jpg",varname="Image_head"
				}
			},
			{
				name="Text_name",type=4,typeName="Text",time=0,x=116,y=12,width=132,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_name",colorA=1
			},
			{
				name="Text_type",type=4,typeName="Text",time=0,x=320,y=12,width=132,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1,varname="Text_type"
			},
			{
				name="Text_id",type=4,typeName="Text",time=0,x=117,y=55,width=334,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_id"
			},
			{
				name="Button_switch_account",type=1,typeName="Button",time=0,x=510,y=17,width=66,height=59,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/setting/setting_change.png",varname="Button_switch_account"
			},
			{
				name="Text_switch_account",type=4,typeName="Text",time=0,x=590,y=29,width=80,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_switch_account"
			}
		},
		{
			name="View_clip",type=0,typeName="View",time=0,x=0,y=81,width=682,height=306,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="View_clip"
		}
	}
}
return setting_layer;