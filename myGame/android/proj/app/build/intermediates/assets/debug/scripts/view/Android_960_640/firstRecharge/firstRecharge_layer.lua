local firstRecharge_layer=
{
	name="firstRecharge_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=0,y=0,width=738,height=594,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/firstRecharge/first_recharge_bg.png",varname="Image_bg",callbackfunc="onPopupBgTouch",
		{
			name="Image_kuang",type=1,typeName="Image",time=0,x=278,y=220,width=395,height=108,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/firstRecharge/first_recharge_reward.png",varname="Image_kuang",
			{
				name="rewardView1",type=1,typeName="Image",time=0,x=12,y=17,width=93,height=66,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",varname="rewardView1",
				{
					name="Image_reward1",type=1,typeName="Image",time=0,x=0,y=0,width=93,height=66,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/default3.png",varname="Image_reward1"
				},
				{
					name="Image37",type=1,typeName="Image",time=0,x=0,y=57,width=93,height=23,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/firstRecharge/first_recharge_num.png"
				},
				{
					name="Text_reward1",type=4,typeName="Text",time=0,x=-15,y=54,width=128,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignCenter,colorRed=255,colorGreen=246,colorBlue=0,colorA=1,varname="Text_reward1"
				}
			},
			{
				name="rewardView2",type=1,typeName="Image",time=0,x=143,y=17,width=93,height=66,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",varname="rewardView2",
				{
					name="Image_reward2",type=1,typeName="Image",time=0,x=0,y=0,width=93,height=66,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/default3.png",varname="Image_reward2"
				},
				{
					name="Image33",type=1,typeName="Image",time=0,x=0,y=57,width=93,height=23,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/firstRecharge/first_recharge_num.png"
				},
				{
					name="Text_reward2",type=4,typeName="Text",time=0,x=-16,y=54,width=128,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignCenter,colorRed=255,colorGreen=246,colorBlue=0,colorA=1,varname="Text_reward2"
				}
			},
			{
				name="rewardView3",type=1,typeName="Image",time=0,x=278,y=17,width=93,height=66,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",varname="rewardView3",
				{
					name="Image_reward3",type=1,typeName="Image",time=0,x=0,y=0,width=93,height=66,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/default3.png",varname="Image_reward3"
				},
				{
					name="Image34",type=1,typeName="Image",time=0,x=1,y=57,width=93,height=23,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/firstRecharge/first_recharge_num.png"
				},
				{
					name="Text_reward3",type=4,typeName="Text",time=0,x=-16,y=54,width=128,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignCenter,colorRed=255,colorGreen=246,colorBlue=0,colorA=1,varname="Text_reward3"
				}
			},
			{
				name="addIamge",type=1,typeName="Image",time=0,x=115,y=41,width=18,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/+.png",varname="addIamge"
			},
			{
				name="addIamge2",type=1,typeName="Image",time=0,x=250,y=40,width=18,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/+.png",varname="addIamge2"
			},
			{
				name="Image_bouns",type=1,typeName="Image",time=0,x=-32,y=-30,width=52,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/firstRecharge/first_recharge_reward_icon.png",varname="Image_bouns"
			}
		},
		{
			name="payAmountSelect",type=0,typeName="View",time=0,x=344,y=382,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="payAmountSelect",
			{
				name="payAmountTitle",type=4,typeName="Text",time=0,x=-102,y=-11,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=230,colorGreen=215,colorBlue=251,string=[[支付额度]],varname="payAmountTitle",colorA=1
			},
			{
				name="amountSelectMc",type=1,typeName="Image",time=0,x=4,y=8,width=314,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_bg_1.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15,varname="amountSelectMc",
				{
					name="amountTxt",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignLeft,colorRed=246,colorGreen=215,colorBlue=250,string=[[0.99 usd = 12 M koin]],colorA=1,varname="amountTxt"
				}
			},
			{
				name="amountSelectBtn",type=1,typeName="Button",time=0,x=268,y=17,width=44,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_refresh_btn_2.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,varname="amountSelectBtn",callbackfunc="onRefreshGoods"
			}
		},
		{
			name="payTypeSelect",type=0,typeName="View",time=0,x=226,y=312,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="payTypeSelect",
			{
				name="payTypeTitle",type=4,typeName="Text",time=0,x=16,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=230,colorGreen=215,colorBlue=251,string=[[支付方式]],colorA=1,varname="payTypeTitle"
			},
			{
				name="typeSelectMc",type=1,typeName="Image",time=0,x=122,y=18,width=314,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_bg_1.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15,varname="typeSelectMc",
				{
					name="typeTxt",type=1,typeName="Image",time=0,x=0,y=-4,width=150,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/payType/first_recharge_12_icon.png",varname="typeTxt"
				}
			},
			{
				name="ListView50",type=0,typeName="ListView",time=0,x=469,y=54,width=170,height=272,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="ListView50",
				{
					name="Image30",type=1,typeName="Image",time=0,x=0,y=0,width=170,height=272,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/pay_more_bg.png"
				}
			},
			{
				name="typeSelectBtn",type=1,typeName="Button",time=0,x=386,y=27,width=44,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/expand_btn.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,varname="typeSelectBtn",callbackfunc="onShowTypeList"
			}
		},
		{
			name="Button36",type=1,typeName="Button",time=0,x=346,y=448,width=240,height=61,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_yellow_s.png",gridLeft=40,gridRight=40,callbackfunc="onClickPay",varname="Button36",
			{
				name="buyBtnTxt",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[购买]],colorA=1,varname="buyBtnTxt"
			}
		}
	},
	{
		name="View_tip",type=0,typeName="View",time=0,x=-58,y=-117,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="View_tip"
	}
}
return firstRecharge_layer;