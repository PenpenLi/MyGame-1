local limit_time_event_layer=
{
	name="limit_time_event_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,stageW=0,stageH=0,
	{
		name="Image_bg",type=1,typeName="Image",time=0,x=4,y=12,width=710,height=517,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_popup_bg_big.png",varname="Image_bg",callbackfunc="onPopupBgTouch",
		{
			name="Image_tab",type=1,typeName="Image",time=0,x=158,y=20,width=367,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_tab_bg.png",gridLeft=30,gridRight=30,varname="Image_tab",
			{
				name="RadioButtonGroup",type=0,typeName="RadioButtonGroup",time=0,x=13,y=10,width=342,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="RadioButtonGroup",
				{
					name="RadioButton_l",type=0,typeName="RadioButton",time=0,x=-16,y=-8,width=179,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",file2="res/common/common_tab_l.png",varname="RadioButton_l",
					{
						name="persion_text",type=4,typeName="Text",time=0,x=21,y=10,width=140,height=35,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[个人]],varname="persion_text",colorA=1
					},
					{
						name="persion_event_redPoint",type=1,typeName="Image",time=0,x=4,y=-5,width=24,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="res/common/common_red_point.png",gridLeft=12,gridRight=12,gridTop=12,gridBottom=12,varname="persion_event_redPoint"
					}
				},
				{
					name="RadioButton_r",type=0,typeName="RadioButton",time=0,x=175,y=-9,width=179,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",file2="res/common/common_tab_r.png",varname="RadioButton_r",
					{
						name="fullService_text",type=4,typeName="Text",time=0,x=16,y=9,width=143,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[全服]],varname="fullService_text",colorA=1
					},
					{
						name="fullService_Event_redPoint",type=1,typeName="Image",time=0,x=12,y=-5,width=24,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="res/common/common_red_point.png",gridLeft=12,gridRight=12,gridTop=12,gridBottom=12,varname="fullService_Event_redPoint"
					}
				}
			}
		},
		{
			name="persion_event_view",type=0,typeName="View",time=0,x=0,y=90,width=680,height=400,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,varname="persion_event_view",
			{
				name="progressBg",type=1,typeName="Image",time=0,x=68,y=-90,width=374,height=19,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_progress_bg_blue.png",gridLeft=15,gridRight=15,gridTop=9,gridBottom=9,varname="progressBg",
				{
					name="progressBarImage",type=1,typeName="Image",time=0,x=-5,y=1,width=48,height=23,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/common/common_progress_bar_orange_1.png",gridLeft=20,gridRight=20,gridTop=10,gridBottom=10,varname="progressBarImage"
				}
			},
			{
				name="timeGroup47",type=1,typeName="Image",time=0,x=221,y=14,width=250,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/limitTimeEvent/lTEvent_time_bg.png",gridLeft=30,gridRight=30,gridTop=16,gridBottom=16,
				{
					name="limitTimeTxt",type=4,typeName="Text",time=0,x=0,y=0,width=200,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=18,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1,varname="limitTimeTxt"
				}
			},
			{
				name="countGroup16",type=1,typeName="Image",time=0,x=485,y=13,width=180,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/limitTimeEvent/lTEvent_time_bg.png",gridLeft=30,gridRight=30,gridTop=16,gridBottom=16,
				{
					name="gameCountTxt",type=4,typeName="Text",time=0,x=0,y=0,width=201,height=39,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=18,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1,varname="gameCountTxt"
				}
			},
			{
				name="paperContainerLeft",type=1,typeName="Image",time=0,x=6,y=8,width=196,height=386,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_transparent.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
				{
					name="paperContainer",type=1,typeName="Image",time=0,x=0,y=0,width=175,height=94,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/default3.png",varname="paperContainer"
				}
			},
			{
				name="prize_1",type=1,typeName="Button",time=0,x=275,y=67,width=86,height=86,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/limitTimeEvent/lTEvent_reward_bg.png",varname="prize_1",
				{
					name="Image_prop_icon",type=1,typeName="Image",time=0,x=0,y=0,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_coin_102.png"
				},
				{
					name="darkBg",type=1,typeName="Image",time=0,x=0,y=0,width=82,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/limitTimeEvent/lTEvent_rewar_bg_get.png"
				},
				{
					name="nameGroup",type=1,typeName="Image",time=0,x=-6,y=70,width=102,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/limitTimeEvent/lTEvent_rewardName_bg.png",
					{
						name="prizeNameTxt",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=215,colorBlue=0,string=[[Text]],colorA=1
					}
				},
				{
					name="hasGetIamge",type=1,typeName="Image",time=0,x=0,y=0,width=52,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/limitTimeEvent/lTEvent_reward_geted.png"
				},
				{
					name="targetCountTxt",type=4,typeName="Text",time=0,x=0,y=64,width=76,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=220,colorGreen=190,colorBlue=255,string=[[Text]],colorA=1
				}
			},
			{
				name="prize_2",type=1,typeName="Button",time=0,x=425,y=68,width=86,height=86,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/limitTimeEvent/lTEvent_reward_bg.png",varname="prize_2",
				{
					name="Image_prop_icon",type=1,typeName="Image",time=0,x=0,y=0,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_coin_102.png"
				},
				{
					name="darkBg",type=1,typeName="Image",time=0,x=0,y=0,width=82,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/limitTimeEvent/lTEvent_rewar_bg_get.png"
				},
				{
					name="nameGroup",type=1,typeName="Image",time=0,x=-6,y=70,width=102,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/limitTimeEvent/lTEvent_rewardName_bg.png",
					{
						name="prizeNameTxt",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=215,colorBlue=0,string=[[Text]],colorA=1
					}
				},
				{
					name="hasGetIamge",type=1,typeName="Image",time=0,x=0,y=0,width=52,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/limitTimeEvent/lTEvent_reward_geted.png"
				},
				{
					name="targetCountTxt",type=4,typeName="Text",time=0,x=0,y=64,width=76,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=220,colorGreen=190,colorBlue=255,string=[[Text]],colorA=1
				}
			},
			{
				name="prize_3",type=1,typeName="Button",time=0,x=582,y=67,width=86,height=86,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/limitTimeEvent/lTEvent_reward_bg.png",varname="prize_3",
				{
					name="Image_prop_icon",type=1,typeName="Image",time=0,x=0,y=0,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_coin_102.png"
				},
				{
					name="darkBg",type=1,typeName="Image",time=0,x=0,y=0,width=82,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/limitTimeEvent/lTEvent_rewar_bg_get.png"
				},
				{
					name="nameGroup",type=1,typeName="Image",time=0,x=-6,y=70,width=102,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/limitTimeEvent/lTEvent_rewardName_bg.png",
					{
						name="prizeNameTxt",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=215,colorBlue=0,string=[[Text]],colorA=1
					}
				},
				{
					name="hasGetIamge",type=1,typeName="Image",time=0,x=0,y=0,width=52,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/limitTimeEvent/lTEvent_reward_geted.png"
				},
				{
					name="targetCountTxt",type=4,typeName="Text",time=0,x=0,y=64,width=76,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=220,colorGreen=190,colorBlue=255,string=[[Text]],colorA=1
				}
			},
			{
				name="ScrollView46",type=0,typeName="ScrollView",time=0,x=224,y=203,width=444,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="ruleScrollView"
			},
			{
				name="personalRuleTxt",type=5,typeName="TextView",time=0,x=106,y=61,width=441,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=18,textAlign=kAlignTopLeft,colorRed=220,colorGreen=190,colorBlue=255,string=[[活动规则]],colorA=1,varname="personalRuleTxt"
			},
			{
				name="splitLineIamge22",type=1,typeName="Image",time=0,x=199,y=10,width=10,height=320,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/limitTimeEvent/lTEvent_right_content_bg.png",gridLeft=8,gridRight=1
			},
			{
				name="playBtn",type=1,typeName="Button",time=0,x=324,y=323,width=232,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_yellow.png",gridLeft=50,gridRight=50,gridTop=35,gridBottom=34,varname="playBtn",
				{
					name="playBtnTxt",type=4,typeName="Text",time=0,x=0,y=0,width=215,height=54,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],varname="playBtnTxt",colorA=1
				}
			}
		},
		{
			name="fullService_event_view",type=0,typeName="View",time=0,x=0,y=90,width=680,height=400,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,varname="fullService_event_view"
		}
	}
}
return limit_time_event_layer;