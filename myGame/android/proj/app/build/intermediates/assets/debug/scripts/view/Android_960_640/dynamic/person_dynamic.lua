local person_dynamic=
{
	name="person_dynamic",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=570,height=420,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_small1.png",varname="Image_bg",callbackfunc="onPopupBgTouch",
		{
			name="Image8",type=1,typeName="Image",time=0,x=0,y=-159,width=326,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_title1.png",
			{
				name="Text_title",type=4,typeName="Text",time=0,x=0,y=0,width=314,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1,varname="Text_title"
			}
		},
		{
			name="ScrollView_dynamic",type=0,typeName="ScrollView",time=0,x=0,y=34,width=516,height=237,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="ScrollView_dynamic"
		},
		{
			name="text_total_dynamics",type=4,typeName="Text",time=0,x=16,y=-96,width=100,height=29,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=16,textAlign=kAlignLeft,colorRed=199,colorGreen=127,colorBlue=241,string=[[全部动态：8条]],colorA=1,varname="text_total_dynamics"
		},
		{
			name="Image11",type=1,typeName="Image",time=0,x=16,y=364,width=540,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/dynamic_tips_bg.png",gridLeft=5,gridRight=5,gridTop=5,gridBottom=5
		},
		{
			name="text_tips",type=4,typeName="Text",time=0,x=0,y=170,width=100,height=29,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=16,textAlign=kAlignCenter,colorRed=199,colorGreen=127,colorBlue=241,string=[[即将开放]],colorA=1,varname="text_tips"
		},
		{
			name="text_no_dynamic",type=4,typeName="Text",time=0,x=0,y=13,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[没有动态哦！]],colorA=1,varname="text_no_dynamic"
		}
	}
}
return person_dynamic;