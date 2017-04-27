local logout_layer=
{
	name="logout_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=710,height=517,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_big.png",varname="Image_bg",
		{
			name="Image_title",type=1,typeName="Image",time=0,x=116,y=3,width=480,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_title2.png",varname="Image_title",
			{
				name="Text_title",type=4,typeName="Text",time=0,x=75,y=23,width=339,height=37,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_title",colorA=1
			}
		},
		{
			name="Text_tip",type=4,typeName="Text",time=0,x=32,y=99,width=640,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignCenter,colorRed=250,colorGreen=230,colorBlue=255,string=[[Text]],colorA=1,varname="Text_tip"
		},
		{
			name="Image_left",type=1,typeName="Image",time=0,x=26,y=129,width=336,height=274,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/setting/setting_logout_kuang.png",varname="Image_left",
			{
				name="Text_left_title",type=4,typeName="Text",time=0,x=54,y=17,width=222,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1,varname="Text_left_title"
			},
			{
				name="Text_left_goto",type=4,typeName="Text",time=0,x=63,y=206,width=205,height=51,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignCenter,colorRed=255,colorGreen=200,colorBlue=75,string=[[Text]],varname="Text_left_goto",colorA=1
			},
			{
				name="TextView_left_content",type=5,typeName="TextView",time=0,x=41,y=84,width=253,height=91,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignCenter,colorRed=250,colorGreen=230,colorBlue=255,string=[[TextView]],colorA=1,varname="TextView_left_content"
			},
			{
				name="Image_left_item",type=1,typeName="Image",time=0,x=87,y=80,width=156,height=112,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/setting/setting_gold.png",varname="Image_left_item"
			}
		},
		{
			name="Image_right",type=1,typeName="Image",time=0,x=354,y=129,width=336,height=274,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/setting/setting_logout_kuang.png",varname="Image_right",
			{
				name="Image_right_item",type=1,typeName="Image",time=0,x=82,y=81,width=156,height=112,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/setting/setting_gold.png",varname="Image_right_item"
			},
			{
				name="Text_right_title",type=4,typeName="Text",time=0,x=57,y=16,width=215,height=37,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_right_title",colorA=1
			},
			{
				name="Text_right_goto",type=4,typeName="Text",time=0,x=44,y=206,width=249,height=49,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignCenter,colorRed=255,colorGreen=200,colorBlue=75,string=[[Text]],varname="Text_right_goto",colorA=1
			},
			{
				name="TextView_right_content",type=5,typeName="TextView",time=0,x=41,y=84,width=253,height=91,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[TextView]],colorA=1,varname="TextView_right_content"
			}
		},
		{
			name="Button_cancel",type=1,typeName="Button",time=0,x=373,y=409,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_yellow.png",gridLeft=50,gridRight=50,gridTop=35,gridBottom=34,varname="Button_cancel",
			{
				name="Text_cancel",type=4,typeName="Text",time=0,x=28,y=18,width=143,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_cancel"
			}
		},
		{
			name="Button_sure",type=1,typeName="Button",time=0,x=152,y=412,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_purple.png",varname="Button_sure",
			{
				name="Text_sure",type=4,typeName="Text",time=0,x=25,y=15,width=137,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1,varname="Text_sure"
			}
		}
	}
}
return logout_layer;