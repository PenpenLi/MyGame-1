local roomQiuQiu_buyin_layer=
{
	name="roomQiuQiu_buyin_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=710,height=517,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_big.png",varname="bg",callbackfunc="onPopupBgTouch",
		{
			name="titleBg",type=1,typeName="Image",time=0,x=0,y=5,width=382,height=77,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_pop_bg_title.png",gridLeft=150,gridRight=150,gridTop=35,gridBottom=35,
			{
				name="titleLabel",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=28,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[买入金币]],colorA=1,varname="titleLabel"
			}
		},
		{
			name="subbg",type=1,typeName="Image",time=0,x=0,y=47,width=698,height=352,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_bg_2.png",gridLeft=8,gridRight=8,gridTop=20,gridBottom=20
		},
		{
			name="buyinMoneyBg",type=1,typeName="Image",time=0,x=0,y=156,width=315,height=49,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_bg_1.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15,
			{
				name="buyinMoneyLabel",type=4,typeName="Text",time=0,x=37,y=5,width=252,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=246,colorBlue=0,string=[[0]],colorA=1,varname="buyinMoneyLabel"
			}
		},
		{
			name="minBuyinMoney",type=4,typeName="Text",time=0,x=44,y=189,width=124,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=246,colorBlue=0,string=[[O]],colorA=1,varname="minBuyinMoney"
		},
		{
			name="minBuyinLabel",type=4,typeName="Text",time=0,x=43,y=223,width=163,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignLeft,colorRed=211,colorGreen=234,colorBlue=255,string=[[最小买入]],varname="minBuyinLabel",colorA=1
		},
		{
			name="addButton",type=1,typeName="Button",time=0,x=55,y=264,width=50,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="res/room/qiuqiu/raiseSlider/room_buyin_add_up_bg.png",file2="db33077c294a2ca607a0409c0d5d6a86",varname="addButton",callbackfunc="onAddButtonClick"
		},
		{
			name="deleteButton",type=1,typeName="Button",time=0,x=51,y=263,width=50,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/room/qiuqiu/raiseSlider/room_buyin_sub_up_bg.png",file2="8e9e4f3077a113293195475443d59ee0",varname="deleteButton",callbackfunc="onDeleteButtonClick"
		},
		{
			name="sliderBg",type=1,typeName="Image",time=0,x=1,y=278,width=450,height=21,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_progress_bg_blue.png",gridLeft=15,gridRight=15,gridTop=9,gridBottom=9,varname="sliderBg",
			{
				name="sliderProgress",type=1,typeName="Image",time=0,x=0,y=0,width=48,height=23,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_progress_bar_orange_1.png",gridLeft=20,gridRight=20,gridTop=10,gridBottom=10,varname="sliderProgress"
			},
			{
				name="thumbImage",type=1,typeName="Image",time=0,x=0,y=0,width=109,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/room/qiuqiu/raiseSlider/room_raise_slider_thumb.png",varname="thumbImage",callbackfunc="onThumbTouch_"
			}
		},
		{
			name="maxBuyinMoney",type=4,typeName="Text",time=0,x=568,y=189,width=100,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignRight,colorRed=255,colorGreen=246,colorBlue=0,string=[[0]],varname="maxBuyinMoney",colorA=1
		},
		{
			name="maxBuyinLabel",type=4,typeName="Text",time=0,x=507,y=223,width=163,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignRight,colorRed=211,colorGreen=234,colorBlue=255,string=[[最大买入]],varname="maxBuyinLabel",colorA=1
		},
		{
			name="buyinButton",type=1,typeName="Button",time=0,x=0,y=402,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_btn_yellow.png",gridLeft=50,gridRight=50,gridTop=35,gridBottom=34,varname="buyinButton",callbackfunc="onBuyinButtonClick",
			{
				name="buyinLabel",type=4,typeName="Text",time=0,x=4,y=3,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[买入坐下]],varname="buyinLabel",colorA=1
			}
		},
		{
			name="outoBuyinLabel",type=4,typeName="Text",time=0,x=263,y=352,width=321,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignLeft,colorRed=211,colorGreen=234,colorBlue=255,string=[[金币不足时自动买入]],varname="outoBuyinLabel",colorA=1
		},
		{
			name="checkButton",type=1,typeName="Button",time=0,x=205,y=344,width=48,height=49,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_bg_1.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15,varname="checkButton",callbackfunc="onCheckButtonClick",
			{
				name="checkImage",type=1,typeName="Image",time=0,x=1,y=1,width=32,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_check_big.png",varname="checkImage"
			}
		}
	}
}
return roomQiuQiu_buyin_layer;