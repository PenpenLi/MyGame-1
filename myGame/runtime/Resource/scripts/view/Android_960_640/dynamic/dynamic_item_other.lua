local dynamic_item_other=
{
	name="dynamic_item_other",type=0,typeName="View",time=0,x=0,y=0,width=516,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=516,height=94,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/dynamic_item_bg.png",gridLeft=16,gridRight=16,gridTop=16,gridBottom=16,varname="Image_bg",
		{
			name="text_time",type=4,typeName="Text",time=0,x=8,y=5,width=100,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignLeft,colorRed=250,colorGreen=230,colorBlue=255,string=[[10月1日]],colorA=1,varname="text_time"
		},
		{
			name="text_dynamic",type=5,typeName="TextView",time=0,x=8,y=42,width=415,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignTopLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[44444444444444444444444444444444441111111144456445454545848547484854]],colorA=1,varname="text_dynamic"
		},
		{
			name="Image8",type=1,typeName="Image",time=0,x=8,y=36,width=419,height=3,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/store/store_history_line_2.png"
		},
		{
			name="btn_like",type=1,typeName="Button",time=0,x=450,y=19,width=44,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/dynamic_like_btn.png",varname="btn_like",callbackfunc="onBtnLikeClick"
		},
		{
			name="text_like_times",type=4,typeName="Text",time=0,x=440,y=61,width=70,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=16,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[52345]],varname="text_like_times",colorA=1
		}
	}
}
return dynamic_item_other;