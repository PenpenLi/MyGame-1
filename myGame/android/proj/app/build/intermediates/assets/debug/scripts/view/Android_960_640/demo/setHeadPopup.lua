local setHeadPopup=
{
	name="setHeadPopup",type=0,typeName="View",time=0,x=0,y=0,width=480,height=320,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="bgSetHead",type=1,typeName="Image",time=0,x=0,y=0,width=750,height=550,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="game/backgroud/bg0.png",varname="bgSetHead",
		{
			name="imagePerson",type=1,typeName="Image",time=0,x=81,y=-30,width=229,height=289,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="game/person/run1.png",varname="imagePerson",
			{
				name="imageHead",type=1,typeName="Image",time=0,x=78,y=2,width=93,height=102,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="game/common/headframe.png",varname="imageHead"
			}
		},
		{
			name="btnTakePhoto",type=1,typeName="Button",time=0,x=39,y=-133,width=360,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="game/button/takePhoto.png",varname="btnTakePhoto"
		},
		{
			name="btnOpenAlbm",type=1,typeName="Button",time=0,x=39,y=-13,width=360,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="game/button/openAlbum.png",varname="btnOpenAlbm"
		},
		{
			name="btnCancel",type=1,typeName="Button",time=0,x=274,y=78,width=126,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="game/button/cancel.png",varname="btnCancel"
		},
		{
			name="btnOk",type=1,typeName="Button",time=0,x=214,y=80,width=167,height=65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,file="game/button/submit.png",varname="btnOk"
		},
		{
			name="imageEdit",type=1,typeName="Image",time=0,x=-79,y=97,width=40,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="game/common/editButton.png",varname="imageEdit"
		},
		{
			name="editTextName",type=6,typeName="EditText",time=0,x=-166,y=54,width=296,height=117,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontName="微软雅黑",fontSize=24,textAlign=kAlignCenter,colorRed=0,colorGreen=0,colorBlue=0,colorA=1,varname="editTextName",string=[[Fool]],
			{
				name="imageLine",type=1,typeName="Image",time=0,x=-6,y=21,width=150,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="game/common/line.png",varname="imageLine"
			}
		}
	}
}
return setHeadPopup;