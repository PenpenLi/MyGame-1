local register_reward_pop_layer=
{
	name="register_reward_pop_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=0,x=0,y=0,width=760,height=518,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,callbackfunc="onPopupBgTouch",varname="bg",file="res/common/common2_register.png",
		{
			name="Image41",type=1,typeName="Image",time=0,x=221,y=173,width=475,height=238,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/loginReward/login_reward_item_panel.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
		},
		{
			name="Text_info",type=4,typeName="Text",time=0,x=78,y=129,width=100,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignCenter,colorRed=201,colorGreen=149,colorBlue=254,string=[[Text]],varname="Text_info",colorA=1
		},
		{
			name="CloseBtn",type=1,typeName="Button",time=0,x=681,y=107,width=51,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_close_btn.png",varname="CloseBtn",callbackfunc="onCloseBtnClick"
		},
		{
			name="itembg_vip",type=1,typeName="Image",time=0,x=61,y=15,width=120,height=170,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/loginReward/login_reward_item_bg.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,varname="itembg_vip",
			{
				name="light",type=1,typeName="Image",time=0,x=0,y=0,width=108,height=158,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/loginReward/login_reward_light_big.png",varname="light"
			},
			{
				name="dayLabel",type=4,typeName="Text",time=0,x=0,y=4,width=118,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1
			},
			{
				name="image",type=1,typeName="Image",time=0,x=15,y=24,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_coin_104.png"
			},
			{
				name="star",type=1,typeName="Image",time=0,x=0,y=0,width=100,height=105,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/loginReward/login_reward_start.png",varname="star"
			},
			{
				name="moneyLabel",type=4,typeName="Text",time=0,x=0,y=68,width=114,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignCenter,colorRed=255,colorGreen=200,colorBlue=75,string=[[Text]],colorA=1
			},
			{
				name="Image_shader",type=1,typeName="Image",time=0,x=0,y=0,width=2,height=2,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="res/common/common_rounded_rect_10.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,varname="Image_shader",
				{
					name="gettedImage",type=1,typeName="Image",time=0,x=0,y=0,width=110,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/loginReward/login_reward_text_gettd.png"
				}
			},
			{
				name="Button_vip",type=1,typeName="Button",time=0,x=-7,y=169,width=131,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_yellow_s.png",gridLeft=40,gridRight=40,varname="Button_vip",callbackfunc="onVipClick",
				{
					name="Text_vip",type=4,typeName="Text",time=0,x=21,y=10,width=89,height=29,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1,varname="Text_vip"
				}
			}
		},
		{
			name="itembg3",type=1,typeName="Image",time=0,x=539,y=18,width=120,height=170,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/loginReward/login_reward_item_bg.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,varname="itembg3",
			{
				name="dayLabel",type=4,typeName="Text",time=0,x=7,y=4,width=112,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1
			},
			{
				name="image",type=1,typeName="Image",time=0,x=10,y=44,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_coin_107.png"
			},
			{
				name="moneyLabel",type=4,typeName="Text",time=0,x=0,y=68,width=113,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignCenter,colorRed=255,colorGreen=200,colorBlue=75,string=[[Text]],colorA=1
			},
			{
				name="shader",type=1,typeName="Image",time=0,x=0,y=0,width=2,height=2,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="res/common/common_rounded_rect_10.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
				{
					name="gettedImage",type=1,typeName="Image",time=0,x=0,y=0,width=110,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/loginReward/login_reward_text_gettd.png"
				}
			}
		},
		{
			name="itembg2",type=1,typeName="Image",time=0,x=399,y=18,width=120,height=170,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/loginReward/login_reward_item_bg.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,varname="itembg2",
			{
				name="dayLabel",type=4,typeName="Text",time=0,x=8,y=4,width=112,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1
			},
			{
				name="image",type=1,typeName="Image",time=0,x=9,y=41,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_coin_105.png"
			},
			{
				name="moneyLabel",type=4,typeName="Text",time=0,x=0,y=68,width=113,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignCenter,colorRed=255,colorGreen=200,colorBlue=75,string=[[Text]],colorA=1
			},
			{
				name="shader",type=1,typeName="Image",time=0,x=0,y=0,width=2,height=2,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="res/common/common_rounded_rect_10.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
				{
					name="gettedImage",type=1,typeName="Image",time=0,x=0,y=0,width=110,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/loginReward/login_reward_text_gettd.png"
				}
			}
		},
		{
			name="itembg1",type=1,typeName="Image",time=0,x=259,y=18,width=120,height=170,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/loginReward/login_reward_item_bg.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,varname="itembg1",
			{
				name="dayLabel",type=4,typeName="Text",time=0,x=4,y=4,width=112,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1
			},
			{
				name="image",type=1,typeName="Image",time=0,x=10,y=32,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_coin_104.png"
			},
			{
				name="moneyLabel",type=4,typeName="Text",time=0,x=0,y=68,width=113,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignCenter,colorRed=255,colorGreen=200,colorBlue=75,string=[[Text]],colorA=1
			},
			{
				name="shader",type=1,typeName="Image",time=0,x=0,y=0,width=2,height=2,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="res/common/common_rounded_rect_10.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
				{
					name="gettedImage",type=1,typeName="Image",time=0,x=0,y=0,width=110,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/loginReward/login_reward_text_gettd.png"
				}
			}
		},
		{
			name="playButton",type=1,typeName="Button",time=0,x=0,y=192,width=192,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_btn_yellow.png",gridLeft=50,gridRight=50,gridTop=35,gridBottom=34,varname="playButton",callbackfunc="onPlayButtonClick",
			{
				name="playLabel",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[马上玩牌]],colorA=1,varname="playLabel"
			}
		}
	}
}
return register_reward_pop_layer;