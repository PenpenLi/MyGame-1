local dynamic_item_my=
{
	name="dynamic_item_my",type=0,typeName="View",time=0,x=0,y=0,width=516,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=516,height=94,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/dynamic_item_bg.png",gridLeft=16,gridRight=16,gridTop=16,gridBottom=16,varname="Image_bg",
		{
			name="text_time",type=4,typeName="Text",time=0,x=8,y=5,width=100,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignLeft,colorRed=250,colorGreen=230,colorBlue=255,string=[[10月1日]],varname="text_time",colorA=1
		},
		{
			name="text_dynamic",type=5,typeName="TextView",time=0,x=8,y=42,width=415,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignTopLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[我的动态啊！]],colorA=1,varname="text_dynamic"
		},
		{
			name="Image8",type=1,typeName="Image",time=0,x=8,y=36,width=419,height=3,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/store/store_history_line_2.png"
		},
		{
			name="img_like",type=1,typeName="Image",time=0,x=143,y=7,width=24,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/dynamic_like_icon.png",varname="img_like",
			{
				name="text_like_times",type=4,typeName="Text",time=0,x=34,y=1,width=58,height=23,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=15,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[111]],varname="text_like_times"
			}
		},
		{
			name="btn_delete",type=1,typeName="Button",time=0,x=450,y=25,width=44,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/dynamic_delete.png",varname="btn_delete",callbackfunc="onBtnDeleteClick"
		}
	}
}
return dynamic_item_my;