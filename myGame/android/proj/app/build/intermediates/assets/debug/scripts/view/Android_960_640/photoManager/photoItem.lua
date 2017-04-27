local photoItem=
{
	name="photoItem",type=0,typeName="View",time=0,x=0,y=0,width=190,height=290,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="Photo",type=1,typeName="Image",time=0,x=0,y=-5,width=155,height=155,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_nophoto.jpg",varname="Photo"
	},
	{
		name="Image8",type=1,typeName="Image",time=0,x=-43,y=-116,width=40,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_bg_1.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15
	},
	{
		name="UploadBtn",type=1,typeName="Button",time=0,x=0,y=105,width=131,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_btn_yellow_s.png",gridLeft=40,gridRight=40,varname="UploadBtn",
		{
			name="Text1",type=4,typeName="Text",time=0,x=0,y=-3,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[上传]],varname="Text1"
		}
	},
	{
		name="CheckBoxGroup",type=0,typeName="CheckBoxGroup",time=0,x=-42,y=-116,width=48,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="CheckBoxGroup",
		{
			name="CheckBox",type=0,typeName="CheckBox",time=0,x=0,y=0,width=40,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_transparent.png",file2="res/common/common_big_check.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15,varname="CheckBox"
		}
	},
	{
		name="Text",type=5,typeName="TextView",time=0,x=33,y=-115,width=90,height=55,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=18,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[TextView]],colorA=1,varname="Text"
	}
}
return photoItem;