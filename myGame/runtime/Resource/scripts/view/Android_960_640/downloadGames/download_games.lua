local download_games=
{
	name="download_games",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=710,height=517,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_big.png",varname="Image_bg",callbackfunc="onPopupBgTouch",
		{
			name="Image8",type=1,typeName="Image",time=0,x=0,y=-217,width=480,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_title2.png",
			{
				name="Text_title",type=4,typeName="Text",time=0,x=1,y=0,width=314,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=28,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1,varname="Text_title"
			}
		},
		{
			name="ScrollView_games",type=0,typeName="ScrollView",time=0,x=0,y=72,width=658,height=304,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="ScrollView_games"
		},
		{
			name="text_no_games",type=4,typeName="Text",time=0,x=0,y=3,width=120,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[没有游戏哦]],colorA=1,varname="text_no_games"
		},
		{
			name="text_info",type=5,typeName="TextView",time=0,x=27,y=100,width=655,height=67,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignTopLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[前往谷歌]],colorA=1,varname="text_info"
		}
	}
}
return download_games;