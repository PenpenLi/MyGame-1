local roomChat_pop=
{
	name="roomChat_pop",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="popup_bg",type=1,typeName="Image",time=0,x=0,y=72,width=517,height=574,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,file="res/roomChat/roomChat_pop_bg.png",callbackfunc="onPopupBgTouch",varname="popup_bg",
		{
			name="left_btn_view",type=0,typeName="View",time=0,x=13,y=13,width=94,height=473,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="left_btn_view",
			{
				name="face",type=1,typeName="Button",time=0,x=2,y=6,width=94,height=108,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",callbackfunc="onFaceBtnClick",varname=face,
				{
					name="face_unSelect",type=1,typeName="Image",time=0,x=-4,y=-2,width=91,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChat/roomChat_face_unSelected.png",varname="face_unSelect"
				},
				{
					name="face_select",type=1,typeName="Image",time=0,x=0,y=0,width=94,height=118,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChat/roomChat_face_selected.png",varname="face_select"
				}
			},
			{
				name="chat",type=1,typeName="Button",time=0,x=2,y=114,width=94,height=121,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",varname="chat",callbackfunc="onChatBrnClick",
				{
					name="chat_unSelect",type=1,typeName="Image",time=0,x=-1,y=1,width=91,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChat/roomChat_chat_unSelected.png",varname="chat_unSelect"
				},
				{
					name="chat_select",type=1,typeName="Image",time=0,x=0,y=0,width=94,height=132,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChat/roomChat_chat_selected.png",varname="chat_select"
				}
			},
			{
				name="friend",type=1,typeName="Button",time=0,x=2,y=237,width=94,height=121,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",varname="friend",callbackfunc="onFriendBrnClick",
				{
					name="friend_unSelect",type=1,typeName="Image",time=0,x=1,y=1,width=91,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChat/roomChat_friend_unSelected.png",varname="friend_unSelect"
				},
				{
					name="friend_select",type=1,typeName="Image",time=0,x=-2,y=0,width=95,height=132,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChat/roomChat_friend_selected.png",varname="friend_select"
				}
			},
			{
				name="record",type=1,typeName="Button",time=0,x=2,y=360,width=94,height=108,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",varname="record",callbackfunc="onRecoedBtnClick",
				{
					name="record_unSelect",type=1,typeName="Image",time=0,x=4,y=3,width=91,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChat/roomChat_record_unSelected.png",varname="record_unSelect"
				},
				{
					name="record_select",type=1,typeName="Image",time=0,x=-1,y=0,width=99,height=118,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/roomChat/roomChat_record_selected.png",varname="record_select"
				}
			},
			{
				name="newFriend_msg_tips",type=1,typeName="Image",time=0,x=60,y=263,width=24,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_red_point.png",gridLeft=12,gridRight=12,gridTop=12,gridBottom=12,varname="newFriend_msg_tips"
			}
		},
		{
			name="face_view",type=0,typeName="View",time=0,x=104,y=17,width=400,height=464,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="face_view",
			{
				name="exp_list_view",type=0,typeName="ScrollView",time=0,x=0,y=73,width=400,height=390,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="exp_list_view"
			},
			{
				name="exp_view_mask",type=1,typeName="Image",time=0,x=0,y=73,width=400,height=394,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/roomChat/exp_view_mask.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,varname="exp_view_mask",
				{
					name="not_vip_tips",type=5,typeName="TextView",time=0,x=0,y=-60,width=382,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignCenter,colorRed=250,colorGreen=230,colorBlue=255,string=[[您不是VIP会员，无法使用该表情]],colorA=1,varname="not_vip_tips"
				},
				{
					name="become_vip_btn",type=1,typeName="Button",time=0,x=0,y=20,width=172,height=61,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_btn_yellow_s2.png",varname="become_vip_btn",callbackfunc="onBecomeVipBtnClick",
					{
						name="become_vip_text",type=4,typeName="Text",time=0,x=0,y=-5,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=26,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[成为VIP]],colorA=1,varname="become_vip_text"
					}
				}
			},
			{
				name="Image26",type=1,typeName="Image",time=0,x=0,y=0,width=400,height=73,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/roomChat/roomChat_top_shade.png",
				{
					name="exp_btn",type=1,typeName="Button",time=0,x=35,y=10,width=56,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/roomChat/roomChat_exp_default_selected.png",varname="exp_btn",callbackfunc="onExpBtnClick"
				},
				{
					name="punakawan_btn",type=1,typeName="Button",time=0,x=182,y=4,width=48,height=63,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/roomChat/roomChat_exp_punakawan_selected.png",varname="punakawan_btn",callbackfunc="onPunakawanBtnClick"
				},
				{
					name="Button_vip",type=1,typeName="Button",time=0,x=312,y=9,width=72,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/roomChat/roomChat_vipBt_selected.png",varname="Button_vip",callbackfunc="onVipClick"
				},
				{
					name="top_arrow_pun",type=1,typeName="Image",time=0,x=6,y=70,width=21,height=15,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/roomChat/roomChat_top_arrow.png",varname="top_arrow_pun"
				},
				{
					name="top_arrow_exp",type=1,typeName="Image",time=0,x=-137,y=70,width=21,height=15,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/roomChat/roomChat_top_arrow.png",varname="top_arrow_exp"
				},
				{
					name="top_arrow_vip",type=1,typeName="Image",time=0,x=337,y=72,width=21,height=15,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/roomChat/roomChat_top_arrow.png",varname="top_arrow_vip"
				}
			}
		},
		{
			name="normal_chat_list",type=0,typeName="ScrollView",time=0,x=104,y=20,width=400,height=462,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,stageH=0,varname="normal_chat_list"
		},
		{
			name="record_chat_list",type=0,typeName="ScrollView",time=0,x=104,y=20,width=400,height=462,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,stageH=0,varname="record_chat_list"
		},
		{
			name="bottom_view",type=0,typeName="View",time=0,x=13,y=482,width=490,height=75,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="bottom_view",
			{
				name="op_type_btn",type=1,typeName="Button",time=0,x=9,y=9,width=58,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",varname="op_type_btn",callbackfunc="onOpTypeBtnClick",
				{
					name="horn_icon",type=1,typeName="Image",time=0,x=0,y=0,width=58,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_horn_icon.png",varname="horn_icon"
				},
				{
					name="chat_icon",type=1,typeName="Image",time=0,x=1,y=2,width=50,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/common_chat_icon.png",varname="chat_icon"
				}
			},
			{
				name="input_bg",type=1,typeName="Image",time=0,x=76,y=12,width=240,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_password_bg.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15,varname="input_bg",
				{
					name="msg",type=7,typeName="EditTextView",time=0,x=0,y=0,width=230,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignLeft,colorRed=171,colorGreen=95,colorBlue=236,colorA=1,varname="msg",callbackfunc="onMsgTouch"
				}
			},
			{
				name="send_btn",type=1,typeName="Button",time=0,x=321,y=12,width=172,height=61,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_btn_yellow_s2.png",varname="send_btn",callbackfunc="onSendBtnClick",
				{
					name="Text24",type=4,typeName="Text",time=0,x=0,y=-5,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=26,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Kirim]],colorA=1
				}
			},
			{
				name="tips_view",type=0,typeName="View",time=0,x=14,y=-44,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,varname="tips_view",
				{
					name="tips_bg",type=1,typeName="Image",time=0,x=0,y=4,width=245,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_tip.png",gridLeft=33,gridRight=10,gridTop=10,gridBottom=25,varname="tips_bg"
				}
			}
		}
	}
}
return roomChat_pop;