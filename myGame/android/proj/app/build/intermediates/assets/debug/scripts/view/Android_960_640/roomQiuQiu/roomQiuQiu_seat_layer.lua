local roomQiuQiu_seat_layer=
{
	name="roomQiuQiu_seat_layer",type=0,typeName="View",time=0,x=0,y=0,width=187,height=166,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="baseNode",type=0,typeName="View",time=0,x=0,y=0,width=187,height=166,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="baseNode",
		{
			name="imageNode",type=0,typeName="View",time=0,x=0,y=0,width=87,height=87,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="imageNode",
			{
				name="headImage",type=1,typeName="Image",time=0,x=0,y=0,width=87,height=87,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_nophoto.jpg",varname="headImage"
			}
		},
		{
			name="View_vip",type=0,typeName="View",time=0,x=50,y=39,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="View_vip"
		},
		{
			name="bgButton",type=1,typeName="Button",time=0,x=0,y=0,width=93,height=93,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_transparent.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,varname="bgButton",callbackfunc="onBgButtonClick"
		},
		{
			name="sitdownImage",type=1,typeName="Image",time=0,x=0,y=0,width=88,height=88,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/room/qiuqiu/qiuqiu_sitdown_icon.png",varname="sitdownImage"
		},
		{
			name="infoNode",type=1,typeName="Image",time=0,x=0,y=0,width=142,height=54,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="res/room/qiuqiu/qiuqiu_status_bg.png",varname="infoNode",
			{
				name="AddGoldBtn",type=1,typeName="Button",time=0,x=-3,y=26,width=150,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_transparent.png",varname="AddGoldBtn",callbackfunc="OnAddGoldClick",
				{
					name="AddImage",type=1,typeName="Image",time=0,x=2,y=2,width=22,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="res/common/add_gold.png",varname="AddImage"
				}
			},
			{
				name="stateLabel",type=4,typeName="Text",time=0,x=-2,y=0,width=142,height=25,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=20,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Domin]],colorA=1,varname="stateLabel"
			},
			{
				name="moneyLabel",type=4,typeName="Text",time=0,x=52,y=26,width=80,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=209,colorBlue=0,string=[[0]],colorA=1,varname="moneyLabel"
			},
			{
				name="gold_icon",type=1,typeName="Image",time=0,x=12,y=24,width=31,height=29,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_gold_small.png",varname="gold_icon"
			}
		},
		{
			name="giftButton",type=1,typeName="Button",time=0,x=50,y=17,width=38,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_gift_icon.png",varname="giftButton",
			{
				name="giftCenter_node",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="giftCenter_node"
			}
		},
		{
			name="gift_btn_big",type=1,typeName="Button",time=0,x=50,y=17,width=50,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_blank.png",varname="gift_btn_big"
		},
		{
			name="small_poker_node",type=0,typeName="View",time=0,x=-45,y=-20,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="small_poker_node"
		},
		{
			name="poker_node",type=0,typeName="View",time=0,x=149,y=424,width=100,height=100,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,varname="poker_node"
		},
		{
			name="winBorderView",type=0,typeName="View",time=0,x=0,y=0,width=139,height=182,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,varname="winBorderView",
			{
				name="borderImage",type=1,typeName="Image",time=0,x=0,y=0,width=93,height=94,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/room/qiuqiu/qiuqiu_seat_win_border.png"
			},
			{
				name="starImage1",type=1,typeName="Image",time=0,x=27,y=-37,width=37,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/room/qiuqiu/qiuqiu_you_win_flash.png",varname="starImage1"
			},
			{
				name="starImage2",type=1,typeName="Image",time=0,x=-31,y=26,width=37,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/room/qiuqiu/qiuqiu_you_win_flash.png",varname="starImage2"
			},
			{
				name="winnerText",type=1,typeName="Image",time=0,x=0,y=72,width=150,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/room/qiuqiu/qiuqiu_seat_win_winner.png",varname="winnerText"
			}
		},
		{
			name="seatCenter_node",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="seatCenter_node"
		},
		{
			name="chatBubble_node_right",type=0,typeName="View",time=0,x=75,y=65,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="chatBubble_node_right"
		},
		{
			name="chatBubble_node_left",type=0,typeName="View",time=0,x=115,y=65,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="chatBubble_node_left"
		}
	},
	{
		name="seatId",type=4,typeName="Text",time=0,x=28,y=-14,width=100,height=100,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[-1]],colorA=1,varname="seatId"
	}
}
return roomQiuQiu_seat_layer;