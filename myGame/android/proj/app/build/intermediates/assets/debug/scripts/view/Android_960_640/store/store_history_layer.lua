local store_history_layer=
{
	name="store_history_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image_touch",type=1,typeName="Image",time=0,x=0,y=0,width=-1,height=-1,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",varname="Image_touch",callbackfunc="onBgTouch"
	},
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=710,height=517,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_pop_bg.png",varname="Image_bg",callbackfunc="onPopupBgTouch",
		{
			name="Image3",type=1,typeName="Image",time=0,x=181,y=3,width=326,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_pop_bg_title.png",gridLeft=150,gridRight=150,gridTop=35,gridBottom=35
		},
		{
			name="Text_title",type=4,typeName="Text",time=0,x=264,y=23,width=162,height=37,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_title"
		},
		{
			name="ListView_history",type=0,typeName="ListView",time=0,x=29,y=105,width=654,height=373,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="ListView_history"
		},
		{
			name="Text_noData",type=4,typeName="Text",time=0,x=205,y=235,width=280,height=78,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="Text_noData"
		}
	}
}
return store_history_layer;