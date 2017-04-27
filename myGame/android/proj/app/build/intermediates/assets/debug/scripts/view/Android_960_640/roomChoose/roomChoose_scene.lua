local roomChoose_scene=
{
	name="roomChoose_scene",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="popup_bg",type=1,typeName="Image",time=0,x=0,y=0,width=-1,height=-1,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_bg.png",varname="popup_bg",callbackfunc="onPopupBgTouch"
	},
	{
		name="topNode_bg",type=1,typeName="Image",time=0,x=0,y=0,width=960,height=92,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,file="res/roomChoose/roomC_top_bg.png",gridLeft=10,gridRight=45,gridTop=45,gridBottom=45,varname="topNode_bg",
		{
			name="title_bg",type=1,typeName="Image",time=0,x=0,y=-7,width=243,height=91,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_title_bg.png",varname="title_bg",
			{
				name="title_p_icon",type=1,typeName="Image",time=0,x=-17,y=0,width=168,height=39,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_type_private.png",varname="title_p_icon"
			},
			{
				name="title_g_icon",type=1,typeName="Image",time=0,x=-15,y=0,width=181,height=59,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_type_gaple.png",varname="title_g_icon"
			},
			{
				name="title_q_icon",type=1,typeName="Image",time=0,x=-16,y=0,width=181,height=59,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_type_qiuqiu.png",varname="title_q_icon"
			},
			{
				name="Image8",type=1,typeName="Image",time=0,x=23,y=5,width=38,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="res/roomChoose/roomC_down.png"
			}
		},
		{
			name="title_btn",type=1,typeName="Button",time=0,x=0,y=0,width=243,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_blank.png",varname="title_btn",callbackfunc="onRoomTypeChangeBtnClick"
		},
		{
			name="return_btn",type=1,typeName="Button",time=0,x=23,y=-6,width=82,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/roomChoose/roomC_return.png",varname="return_btn",callbackfunc="onReturnBtnClick"
		},
		{
			name="help_btn",type=1,typeName="Button",time=0,x=109,y=-9,width=86,height=81,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/common/common_help_icon.png",varname="help_btn",callbackfunc="onHelpBtnClick"
		},
		{
			name="mall_btn",type=1,typeName="Button",time=0,x=19,y=-3,width=82,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="res/roomChoose/roomC_mall.png",varname="mall_btn",callbackfunc="onMallBtnClick",
			{
				name="DiscountBg",type=1,typeName="Image",time=0,x=38,y=-5,width=43,height=25,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common2_store_sale.png",varname="DiscountBg",
				{
					name="DiscountText",type=4,typeName="Text",time=0,x=1,y=-6,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=16,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=102,string=[[+22%]],colorA=1,varname="DiscountText"
				}
			}
		},
		{
			name="firstPayBtn",type=1,typeName="Button",time=0,x=113,y=-14,width=100,height=98,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="res/common/common_first_pay_light.png",varname="firstPayBtn",
			{
				name="Image66",type=1,typeName="Image",time=0,x=0,y=0,width=80,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_first_pay.png"
			},
			{
				name="Image42",type=1,typeName="Image",time=0,x=0,y=32,width=54,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_first_pay_word.png"
			}
		},
		{
			name="quickPayBtn",type=1,typeName="Button",time=0,x=126,y=9,width=76,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="res/common/common_quick_pay.png",varname="quickPayBtn"
		},
		{
			name="LimitTimeBtn",type=1,typeName="Button",time=0,x=239,y=-5,width=80,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="res/common/common_transparent.png",callbackfunc="onLimitTimeClick",varname="LimitTimeBtn",
			{
				name="Image48",type=1,typeName="Image",time=0,x=0,y=-10,width=56,height=54,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common2_limit_time_giftbag.png"
			},
			{
				name="Image46",type=1,typeName="Image",time=0,x=0,y=21,width=76,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common2_limit_time_giftbag_word.png"
			},
			{
				name="NumBg",type=1,typeName="Image",time=0,x=38,y=4,width=43,height=25,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common2_store_sale.png",varname="NumBg",
				{
					name="NumText",type=4,typeName="Text",time=0,x=1,y=-6,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=16,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=102,string=[[Text]],colorA=1,varname="NumText"
				}
			},
			{
				name="LimitTimeText",type=4,typeName="Text",time=0,x=0,y=37,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=18,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=102,string=[[Text]],colorA=1,varname="LimitTimeText"
			}
		}
	},
	{
		name="roomStepView",type=0,typeName="View",time=0,x=0,y=86,width=464,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,varname="roomStepView",
		{
			name="roomStepbg",type=1,typeName="Image",time=0,x=0,y=0,width=464,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/roomChoose/roomC_changeTab_bg.png",varname="roomStepbg",
			{
				name="buttonLeft",type=1,typeName="Button",time=0,x=15,y=0,width=144,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/common/common_blank.png",varname="buttonLeft",
				{
					name="buttonBg1",type=1,typeName="Image",time=0,x=0,y=0,width=144,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_step_.png",varname="buttonBg1"
				},
				{
					name="buttonName1",type=4,typeName="Text",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=225,colorGreen=194,colorBlue=251,string=[[Biasa]],colorA=1,varname="buttonName1"
				}
			},
			{
				name="buttonMiddle",type=1,typeName="Button",time=0,x=0,y=0,width=144,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_blank.png",varname="buttonMiddle",
				{
					name="buttonBg2",type=1,typeName="Image",time=0,x=0,y=0,width=144,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_step_.png",varname="buttonBg2"
				},
				{
					name="buttonName2",type=4,typeName="Text",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=225,colorGreen=194,colorBlue=251,string=[[Ahli]],colorA=1,varname="buttonName2"
				}
			},
			{
				name="buttonRight",type=1,typeName="Button",time=0,x=15,y=0,width=144,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="res/common/common_blank.png",varname="buttonRight",
				{
					name="buttonBg3",type=1,typeName="Image",time=0,x=0,y=0,width=144,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_step_.png",varname="buttonBg3"
				},
				{
					name="buttonName3",type=4,typeName="Text",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignLeft,colorRed=225,colorGreen=194,colorBlue=251,string=[[Bonus]],colorA=1,varname="buttonName3"
				}
			}
		},
		{
			name="roomStepPemula",type=1,typeName="Image",time=0,x=0,y=0,width=296,height=42,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_type.png",varname="roomStepPemula"
		}
	},
	{
		name="roomListView",type=0,typeName="ScrollView",time=0,x=0,y=73,width=860,height=486,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="roomListView",stageH=0
	},
	{
		name="roomTypeNode",type=1,typeName="Image",time=0,x=0,y=73,width=175,height=108,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/roomChoose/roomC_down_bg.png",varname="roomTypeNode",
		{
			name="typeChangeBg",type=1,typeName="Image",time=0,x=0,y=-73,width=960,height=640,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_blank.png",varname="typeChangeBg",callbackfunc="onTypeChangeBgTouch"
		},
		{
			name="roomType1",type=1,typeName="Button",time=0,x=0,y=-1,width=155,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_blank.png",varname="roomType1",
			{
				name="selected1",type=1,typeName="Image",time=0,x=0,y=0,width=160,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_step_select.png",varname="selected1"
			},
			{
				name="Text33",type=4,typeName="Text",time=0,x=0,y=0,width=158,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Gaple]],colorA=1
			}
		},
		{
			name="roomType2",type=1,typeName="Button",time=0,x=0,y=54,width=155,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_blank.png",varname="roomType2",
			{
				name="selected2",type=1,typeName="Image",time=0,x=0,y=0,width=160,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_step_select.png",varname="selected2"
			},
			{
				name="Text29",type=4,typeName="Text",time=0,x=0,y=0,width=158,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Qiu Qiu]],colorA=1
			}
		},
		{
			name="roomType3",type=1,typeName="Button",time=0,x=0,y=110,width=155,height=50,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/common/common_blank.png",varname="roomType3",
			{
				name="selected3",type=1,typeName="Image",time=0,x=0,y=0,width=160,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChoose/roomC_step_select.png",varname="selected3"
			},
			{
				name="Text32",type=4,typeName="Text",time=0,x=0,y=0,width=158,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Kamar Private]]
			}
		}
	}
}
return roomChoose_scene;