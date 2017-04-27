local world_chat_item_view=
{
	name="world_chat_item_view",type=0,typeName="View",time=0,x=0,y=0,width=680,height=85,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="name",type=4,typeName="Text",time=0,x=35,y=3,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[ZZZZ]],colorA=1,varname="name"
	},
	{
		name="time",type=4,typeName="Text",time=0,x=255,y=6,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignLeft,colorRed=170,colorGreen=145,colorBlue=230,string=[[12/9 12:02]],colorA=1,varname="time"
	},
	{
		name="msg_bg",type=1,typeName="Image",time=0,x=0,y=25,width=649,height=59,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/chat/chat_message_bg.png",gridTop=25,gridBottom=25,varname="msg_bg",
		{
			name="msg",type=5,typeName="TextView",time=0,x=19,y=17,width=610,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=250,colorGreen=230,colorBlue=255,colorA=1,varname="msg"
		}
	}
}
return world_chat_item_view;