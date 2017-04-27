local friend_chat_msg_item_l_view=
{
	name="friend_chat_msg_item_l_view",type=0,typeName="View",time=0,x=0,y=0,width=450,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="player_head",type=1,typeName="Image",time=0,x=20,y=4,width=65,height=65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_nophoto.jpg",varname="player_head"
	},
	{
		name="msg_bg",type=1,typeName="Image",time=0,x=92,y=8,width=313,height=53,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_chat_white_bg.png",gridLeft=26,gridRight=26,gridTop=35,gridBottom=16,varname="msg_bg",
		{
			name="chat_msg",type=5,typeName="TextView",time=0,x=18,y=0,width=270,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[dsfssfggeradasdfsdf]],colorA=1,varname="chat_msg"
		},
		{
			name="exp_node",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="exp_node"
		}
	}
}
return friend_chat_msg_item_l_view;