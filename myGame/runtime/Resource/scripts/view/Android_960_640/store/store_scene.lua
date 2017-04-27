local store_scene=
{
	name="store_scene",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="res/store/store_bg.png",varname="bg"
	},
	{
		name="leftView",type=0,typeName="View",time=0,x=0,y=0,width=251,height=641,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="leftView",
		{
			name="storeTitleImage",type=1,typeName="Image",time=0,x=0,y=30,width=244,height=167,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/store/store_title_bg_1.png",varname="storeTitleImage"
		},
		{
			name="payTypeListView",type=0,typeName="ListView",time=0,x=0,y=209,width=100,height=429,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,stageH=0,varname="payTypeListView"
		},
		{
			name="propTypeListView",type=0,typeName="ListView",time=0,x=0,y=209,width=100,height=429,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,varname="propTypeListView"
		},
		{
			name="salerImage",type=1,typeName="Image",time=0,x=3,y=1,width=286,height=435,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="res/hall/hall_girl.png",varname="salerImage"
		},
		{
			name="lightImage_1",type=1,typeName="Image",time=0,x=52,y=68,width=28,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/store/store_title_light.png",varname="lightImage_1"
		},
		{
			name="lightImage_2",type=1,typeName="Image",time=0,x=198,y=152,width=28,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/store/store_title_light.png",varname="lightImage_2"
		}
	},
	{
		name="rightView",type=0,typeName="View",time=0,x=0,y=0,width=700,height=639,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,varname="rightView",
		{
			name="radioView",type=0,typeName="View",time=0,x=0,y=0,width=700,height=70,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="goodsTypeGroup",type=0,typeName="RadioButtonGroup",time=0,x=-20,y=0,width=601,height=70,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignCenter,varname="goodsTypeGroup",
				{
					name="typeGoodsRadiobutton",type=0,typeName="RadioButton",time=0,x=62,y=0,width=184,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/store/store_goodType_unchoose.png",file2="res/store/store_goodType_choosed.png",varname="typeGoodsRadiobutton",
					{
						name="buttonView",type=0,typeName="View",time=0,x=0,y=0,width=141,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
						{
							name="typeGoodsLabel",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[金币]],varname="typeGoodsLabel",colorA=1
						},
						{
							name="typeGoodsImage",type=1,typeName="Image",time=0,x=0,y=0,width=37,height=37,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/store/store_koin_up.png",varname="typeGoodsImage"
						}
					}
				},
				{
					name="typePropsRadiobutton",type=0,typeName="RadioButton",time=0,x=100,y=0,width=184,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/store/store_goodType_unchoose.png",file2="res/store/store_goodType_choosed.png",varname="typePropsRadiobutton",
					{
						name="buttonView",type=0,typeName="View",time=0,x=0,y=0,width=141,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
						{
							name="typePropsLabel",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[道具]],varname="typePropsLabel"
						},
						{
							name="typePropsImage",type=1,typeName="Image",time=0,x=0,y=0,width=37,height=37,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/store/store_koin_up.png",varname="typePropsImage"
						}
					}
				}
			}
		},
		{
			name="View_vip",type=0,typeName="View",time=0,x=0,y=-198,width=692,height=94,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="View_vip",
			{
				name="Image_vip_gray",type=1,typeName="Image",time=0,x=-299,y=-6,width=82,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/store/store_vip_gray.png",varname="Image_vip_gray"
			},
			{
				name="Image_vip_light",type=1,typeName="Image",time=0,x=-299,y=-6,width=82,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/store/sotre_vip_light.png",varname="Image_vip_light"
			},
			{
				name="Image_vip_num_1",type=1,typeName="Image",time=0,x=-242,y=-1,width=22,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/store/vip_num/1.png",varname="Image_vip_num_1"
			},
			{
				name="Image_vip_num_2",type=1,typeName="Image",time=0,x=-217,y=-1,width=22,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/store/vip_num/10.png",varname="Image_vip_num_2"
			},
			{
				name="Image_progress_bg",type=1,typeName="Image",time=0,x=-29,y=-2,width=340,height=19,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_progress_bg_blue.png",gridLeft=15,gridRight=15,gridTop=9,gridBottom=9,varname="Image_progress_bg",
				{
					name="Image_progress",type=1,typeName="Image",time=0,x=0,y=0,width=24,height=16,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/common/common_progress_bar_orange_big.png",gridLeft=10,gridRight=10,gridTop=8,gridBottom=8,varname="Image_progress"
				}
			},
			{
				name="Button_privilege",type=1,typeName="Button",time=0,x=501,y=17,width=176,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_purple_s.png",gridLeft=40,gridRight=40,callbackfunc="privilegeBtnClick",varname="Button_privilege",
				{
					name="Text_privilege",type=4,typeName="Text",time=0,x=-2,y=-1,width=144,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,colorA=1,varname="Text_privilege"
				}
			},
			{
				name="Text_vip_next",type=4,typeName="Text",time=0,x=-29,y=27,width=100,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=18,textAlign=kAlignCenter,colorRed=235,colorGreen=210,colorBlue=255,colorA=1,varname="Text_vip_next"
			},
			{
				name="Text_vip_process",type=4,typeName="Text",time=0,x=-29,y=0,width=100,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=14,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,colorA=1,varname="Text_vip_process"
			}
		},
		{
			name="contentView",type=0,typeName="View",time=0,x=0,y=165,width=698,height=415,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,varname="contentView",
			{
				name="propListView",type=0,typeName="ListView",time=0,x=0,y=-85,width=700,height=500,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="propListView"
			},
			{
				name="goodsListView",type=0,typeName="ListView",time=0,x=0,y=0,width=700,height=415,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,varname="goodsListView"
			},
			{
				name="noDataTipLabel",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[暂无数据]],varname="noDataTipLabel",colorA=1
			}
		},
		{
			name="moneyView",type=0,typeName="View",time=0,x=-217,y=15,width=206,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,varname="moneyView",
			{
				name="Image37",type=1,typeName="Image",time=0,x=-2,y=3,width=173,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/hall/hall_chips_bg.png"
			},
			{
				name="myMoneyLabel",type=4,typeName="Text",time=0,x=32,y=0,width=128,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=24,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[0]],varname="myMoneyLabel",colorA=1
			},
			{
				name="Image29",type=1,typeName="Image",time=0,x=0,y=0,width=31,height=29,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/common/common_gold_small.png"
			}
		},
		{
			name="vipTimeView",type=0,typeName="View",time=0,x=300,y=592,width=261,height=36,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="vipTimeView",
			{
				name="Image38",type=1,typeName="Image",time=0,x=-20,y=-1,width=310,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/store/store_daoqi_di.png",gridLeft=20,gridRight=20
			},
			{
				name="vipTimeLabel",type=4,typeName="Text",time=0,x=-13,y=-2,width=297,height=39,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignCenter,colorRed=235,colorGreen=210,colorBlue=255,string=[[Text]],colorA=1,varname="vipTimeLabel"
			}
		},
		{
			name="Button_history",type=1,typeName="Button",time=0,x=633,y=580,width=56,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/store/store_history.png",varname="Button_history"
		},
		{
			name="NoticeView",type=0,typeName="View",time=0,x=0,y=77,width=700,height=60,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,varname="NoticeView",
			{
				name="Image39",type=1,typeName="Image",time=0,x=0,y=1,width=460,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_broadcast_bg.png",
				{
					name="NoticeClip",type=1,typeName="Image",time=0,x=24,y=0,width=330,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_transparent.png",varname="NoticeClip"
				}
			}
		}
	}
}
return store_scene;