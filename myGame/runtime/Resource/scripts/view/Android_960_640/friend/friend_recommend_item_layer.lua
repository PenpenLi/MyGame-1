local friend_recommend_item_layer=
{
	name="friend_recommend_item_layer",type=0,typeName="View",time=0,x=0,y=0,width=179,height=273,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=179,height=273,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/friend/friend_recommend_bg.png",varname="bg",
		{
			name="nameLabel",type=4,typeName="Text",time=0,x=64,y=28,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Domin]],colorA=1,varname="nameLabel"
		},
		{
			name="headImage",type=1,typeName="Image",time=0,x=0,y=0,width=135,height=135,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_nophoto.jpg",varname="headImage",callbackfunc="onDetailButtonClick"
		},
		{
			name="goldImage",type=1,typeName="Image",time=0,x=25,y=224,width=31,height=29,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_gold_small.png"
		},
		{
			name="moneyLabel",type=4,typeName="Text",time=0,x=63,y=225,width=100,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=230,colorBlue=0,string=[[0]],varname="moneyLabel",colorA=1
		},
		{
			name="addButton",type=1,typeName="Button",time=0,x=0,y=-54,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="res/common/common_btn_yellow.png",gridLeft=50,gridRight=50,gridTop=35,gridBottom=34,varname="addButton",callbackfunc="onAddButtonClick",
			{
				name="addLabel",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[添加]],varname="addLabel",colorA=1
			}
		},
		{
			name="SexIcon",type=1,typeName="Image",time=0,x=25,y=24,width=30,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_sex_woman_icon.png",varname="SexIcon"
		}
	},
	{
		name="View_vip",type=0,typeName="View",time=0,x=45,y=69,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="View_vip"
	}
}
return friend_recommend_item_layer;