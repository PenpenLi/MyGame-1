local error_layer=
{
	name="error_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="Image8",type=1,typeName="Image",time=0,x=376,y=274,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="res/common/common_bg.png"
	},
	{
		name="Image2",type=1,typeName="Image",time=0,x=254,y=0,width=502,height=640,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_girl.png"
	},
	{
		name="error_tips_bg",type=1,typeName="Image",time=0,x=631,y=16,width=271,height=169,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/room/gaple/roomG_chat_bg.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15,effect={shader="mirror",mirrorType=1},varname="error_tips_bg",
		{
			name="error_tips",type=5,typeName="TextView",time=0,x=0,y=0,width=198,height=115,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[不好意思出了点意外]],colorA=1,varname="error_tips"
		}
	},
	{
		name="error_repair_btn",type=1,typeName="Button",time=0,x=736,y=517,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_purple.png",varname="error_repair_btn",
		{
			name="Text7",type=4,typeName="Text",time=0,x=0,y=-5,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Ok]],colorA=1
		}
	},
	{
		name="errorLabel",type=5,typeName="TextView",time=0,x=0,y=0,width=395,height=477,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[TextView]],colorA=1,varname="errorLabel"
	}
}
return error_layer;