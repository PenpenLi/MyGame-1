local my_view=
{
	name="my_view",type=0,typeName="View",time=0,x=0,y=0,width=675,height=430,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="middleBtn_bg",type=1,typeName="Image",time=0,x=13,y=9,width=486,height=53,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/gift/btn_titile_bg.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,varname="middleBtn_bg",
		{
			name="all_btn",type=1,typeName="Button",time=0,x=7,y=1,width=108,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/common/common_blank.png",varname="all_btn",callbackfunc="onAllBtnClick",
			{
				name="all_btn_bg",type=1,typeName="Image",time=0,x=-38,y=0,width=108,height=42,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/gift/gift_btn_new.png",gridLeft=25,gridRight=25,gridTop=18,gridBottom=18,varname="all_btn_bg"
			},
			{
				name="all_btn_text",type=4,typeName="Text",time=0,x=0,y=-2,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=16,textAlign=kAlignCenter,colorRed=101,colorGreen=42,colorBlue=186,string=[[All]],colorA=1,varname="all_btn_text"
			}
		},
		{
			name="self_buy_btn",type=1,typeName="Button",time=0,x=128,y=1,width=108,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/common/common_blank.png",varname="self_buy_btn",callbackfunc="onSelfBuyBtnClick",
			{
				name="self_buy_bg",type=1,typeName="Image",time=0,x=-38,y=0,width=108,height=42,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/gift/gift_btn_new.png",gridLeft=25,gridRight=25,gridTop=18,gridBottom=18,varname="self_buy_bg"
			},
			{
				name="self_buy_text",type=4,typeName="Text",time=0,x=0,y=-2,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=16,textAlign=kAlignCenter,colorRed=101,colorGreen=42,colorBlue=186,string=[[Beli Sendiri]],colorA=1,varname="self_buy_text"
			}
		},
		{
			name="friends_send_btn",type=1,typeName="Button",time=0,x=60,y=1,width=108,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_blank.png",varname="friends_send_btn",callbackfunc="onFriendsSendBtnClick",
			{
				name="friend_send_bg",type=1,typeName="Image",time=0,x=-4,y=0,width=108,height=42,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/gift/gift_btn_new.png",gridLeft=25,gridRight=25,gridTop=18,gridBottom=18,varname="friend_send_bg"
			},
			{
				name="friend_send_text",type=4,typeName="Text",time=0,x=0,y=-2,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=16,textAlign=kAlignCenter,colorRed=101,colorGreen=42,colorBlue=186,string=[[Dari Teman]],colorA=1,varname="friend_send_text"
			}
		},
		{
			name="system_send_btn",type=1,typeName="Button",time=0,x=8,y=1,width=108,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="res/common/common_blank.png",varname="system_send_btn",callbackfunc="onSystemSendBtnClick",
			{
				name="system_send_bg",type=1,typeName="Image",time=0,x=-4,y=0,width=108,height=42,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/gift/gift_btn_new.png",gridLeft=25,gridRight=25,gridTop=18,gridBottom=18,varname="system_send_bg"
			},
			{
				name="system_send_text",type=4,typeName="Text",time=0,x=0,y=-2,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=16,textAlign=kAlignCenter,colorRed=101,colorGreen=42,colorBlue=186,string=[[Dari Sistem]],colorA=1,varname="system_send_text"
			}
		}
	},
	{
		name="gift_scroll_view",type=0,typeName="ScrollView",time=0,x=-77,y=65,width=490,height=341,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,varname="gift_scroll_view",stageH=0
	},
	{
		name="noGift_tips",type=4,typeName="Text",time=0,x=-75,y=190,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=30,textAlign=kAlignCenter,colorRed=230,colorGreen=215,colorBlue=251,string=[[Belum ada hadiah]],varname="noGift_tips",colorA=1
	},
	{
		name="Image18",type=1,typeName="Image",time=0,x=0,y=394,width=511,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/gift/mygift_tips_bg.png",gridLeft=5,gridRight=5,gridTop=5,gridBottom=5
	},
	{
		name="tips",type=4,typeName="Text",time=0,x=-76,y=11,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=18,textAlign=kAlignCenter,colorRed=230,colorGreen=215,colorBlue=251,string=[[Klik pilih untuk memajang hadiah di meja]],varname="tips",colorA=1
	}
}
return my_view;