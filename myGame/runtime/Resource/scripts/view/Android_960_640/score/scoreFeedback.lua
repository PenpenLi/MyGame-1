local scoreFeedback=
{
	name="scoreFeedback",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Bg",type=1,typeName="Image",time=0,x=0,y=0,width=556,height=398,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_no_title_bg.png",gridLeft=30,gridRight=30,gridTop=30,gridBottom=30,varname="Bg",callbackfunc="onPopupBgTouch",
		{
			name="Image6",type=1,typeName="Image",time=0,x=0,y=-5,width=463,height=181,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/scoreFeedback.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15
		},
		{
			name="CommitBtn",type=1,typeName="Button",time=0,x=0,y=135,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_btn_yellow.png",gridLeft=50,gridRight=50,gridTop=35,gridBottom=34,varname="CommitBtn",callbackfunc="onCommitClick",
			{
				name="BtnText",type=4,typeName="Text",time=0,x=0,y=0,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="BtnText"
			}
		},
		{
			name="Desc",type=5,typeName="TextView",time=0,x=-18,y=-127,width=423,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignTopLeft,colorRed=250,colorGreen=230,colorBlue=255,string=[[TextView]],colorA=1,varname="Desc"
		},
		{
			name="Opiniont",type=7,typeName="EditTextView",time=0,x=0,y=-3,width=416,height=142,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignTopLeft,colorRed=171,colorGreen=95,colorBlue=236,colorA=1,varname="Opiniont"
		}
	}
}
return scoreFeedback;