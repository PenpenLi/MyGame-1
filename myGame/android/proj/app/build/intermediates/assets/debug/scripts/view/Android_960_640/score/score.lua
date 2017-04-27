local score=
{
	name="score",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="Bg",type=1,typeName="Image",time=0,x=0,y=0,width=570,height=420,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_small1.png",varname="Bg",callbackfunc="onPopupBgTouch",
		{
			name="Image3",type=1,typeName="Image",time=0,x=0,y=-158,width=326,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_pop_bg_title.png",gridLeft=150,gridRight=150,gridTop=35,gridBottom=35
		},
		{
			name="Title",type=4,typeName="Text",time=0,x=0,y=-159,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1,varname="Title"
		},
		{
			name="Tip",type=5,typeName="TextView",time=0,x=0,y=-67,width=460,height=49,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignTopLeft,colorRed=250,colorGreen=230,colorBlue=255,colorA=1,varname="Tip"
		},
		{
			name="Image6",type=1,typeName="Image",time=0,x=0,y=32,width=538,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/star_bg.png"
		},
		{
			name="CommitBtn",type=1,typeName="Button",time=0,x=0,y=137,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_btn_yellow.png",gridLeft=50,gridRight=50,gridTop=35,gridBottom=34,varname="CommitBtn",callbackfunc="onCommitClick",
			{
				name="BtnText",type=4,typeName="Text",time=0,x=0,y=0,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="BtnText"
			}
		}
	}
}
return score;