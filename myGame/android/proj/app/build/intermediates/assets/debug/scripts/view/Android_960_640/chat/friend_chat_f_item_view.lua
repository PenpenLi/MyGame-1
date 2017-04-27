local friend_chat_f_item_view=
{
	name="friend_chat_f_item_view",type=0,typeName="View",time=0,x=0,y=0,width=230,height=86,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="friend_bg",type=1,typeName="Image",time=0,x=0,y=0,width=227,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/chat/chat_player_chat_bg.png",varname="friend_bg"
	},
	{
		name="View8",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,
		{
			name="feirnd_head",type=1,typeName="Image",time=0,x=15,y=0,width=65,height=65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/common/common_nophoto.jpg",varname="feirnd_head"
		}
	},
	{
		name="online_status",type=4,typeName="Text",time=0,x=85,y=49,width=32,height=16,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=16,textAlign=kAlignLeft,colorRed=105,colorGreen=185,colorBlue=255,string=[[Text]],colorA=1,varname="online_status"
	},
	{
		name="friend_name",type=4,typeName="Text",time=0,x=85,y=14,width=100,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[walalalala]],colorA=1,varname="friend_name"
	},
	{
		name="new_msg",type=1,typeName="Image",time=0,x=60,y=14,width=24,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_red_point.png",gridLeft=12,gridRight=12,gridTop=12,gridBottom=12,varname="new_msg"
	},
	{
		name="sex_icon",type=1,typeName="Image",time=0,x=56,y=53,width=20,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_man_icon.png",varname="sex_icon"
	}
}
return friend_chat_f_item_view;