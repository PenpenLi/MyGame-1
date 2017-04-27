local rankItemLayer=
{
	name="rankItemLayer",type=0,typeName="View",time=0,x=0,y=0,width=550,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,stageW=0,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=550,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="game/rank/frame_blank.png",varname="bg",
		{
			name="rankImage",type=1,typeName="Image",time=0,x=2,y=2,width=92,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="game/rank/1.png",varname="rankImage"
		},
		{
			name="headImage",type=1,typeName="Image",time=0,x=120,y=2,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="game/common/headframe.png",varname="headImage"
		},
		{
			name="nameText",type=4,typeName="Text",time=0,x=45,y=0,width=100,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=0,colorGreen=0,colorBlue=0,string=[[Text]],colorA=1,varname="nameText"
		},
		{
			name="maxscoreText",type=4,typeName="Text",time=0,x=7,y=0,width=100,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=24,textAlign=kAlignRight,colorRed=0,colorGreen=0,colorBlue=0,string=[[Text]],colorA=1,varname="maxscoreText"
		}
	}
}
return rankItemLayer;