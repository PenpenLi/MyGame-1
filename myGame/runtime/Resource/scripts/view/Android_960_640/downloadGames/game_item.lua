local game_item=
{
	name="game_item",type=0,typeName="View",time=0,x=0,y=0,width=658,height=121,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="Image_item2",type=1,typeName="Image",time=0,x=5,y=0,width=649,height=113,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/bankrupt_other_bg.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15,visible=1,
		{
			name="img_icon",type=1,typeName="Image",time=0,x=15,y=29,width=100,height=54,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/default3.png",varname="img_icon"
		},
		{
			name="text_desc",type=5,typeName="TextView",time=0,x=131,y=8,width=348,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=250,colorGreen=230,colorBlue=255,string=[[TextView]],colorA=1,varname="text_desc"
		},
		{
			name="btn_exchange",type=1,typeName="Button",time=0,x=503,y=8,width=131,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_yellow_s.png",gridLeft=40,gridRight=40,varname="btn_exchange",callbackfunc="onBtnExchangeClick",
			{
				name="btn_exchange_text",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[兑换222]],colorA=1,varname="btn_exchange_text"
			}
		},
		{
			name="btn_download",type=1,typeName="Button",time=0,x=503,y=60,width=131,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_purple_s.png",gridLeft=40,gridRight=40,varname="btn_download",callbackfunc="onBtnDownloadClick",
			{
				name="btn_download_text",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[下载2222]],colorA=1,varname="btn_download_text"
			}
		}
	}
}
return game_item;