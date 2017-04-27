local room_freeChip_pop_layer=
{
	name="room_freeChip_pop_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="popup_bg",type=1,typeName="Image",time=0,x=0,y=60,width=305,height=327,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,file="res/freeGold/freeGold_room_bg.png",gridLeft=45,gridRight=155,gridTop=45,gridBottom=45,varname="popup_bg",callbackfunc="onPopupBgTouch",
		{
			name="daily_task",type=1,typeName="Button",time=0,x=2,y=20,width=277,height=89,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/freeGold/freeGold_room_di.png",varname="daily_task",callbackfunc="onDailyTaskBtnClick",
			{
				name="dailyTask_icon",type=1,typeName="Image",time=0,x=0,y=0,width=89,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/hall/hall_task_btn.png",varname="dailyTask_icon"
			},
			{
				name="dailyTask_redPoint",type=1,typeName="Image",time=0,x=0,y=0,width=24,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_red_point.png",gridLeft=12,gridRight=12,gridTop=12,gridBottom=12,varname="dailyTask_redPoint"
			},
			{
				name="Text13",type=4,typeName="Text",time=0,x=90,y=10,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=254,colorGreen=254,colorBlue=254,string=[[Tugas Harian]],colorA=1
			},
			{
				name="dailyTask_desc",type=4,typeName="Text",time=0,x=90,y=50,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=250,colorGreen=230,colorBlue=255,string=[[Cek]],colorA=1,varname="dailyTask_desc"
			}
		},
		{
			name="onLine_box",type=1,typeName="Button",time=0,x=2,y=110,width=277,height=89,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/freeGold/freeGold_room_di.png",varname="onLine_box",callbackfunc="onOnLineBoxClick",
			{
				name="box_normal",type=1,typeName="Image",time=0,x=11,y=0,width=68,height=56,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/room/gaple/count_down_box_normal.png",varname="box_normal"
			},
			{
				name="box_reward",type=1,typeName="Image",time=0,x=8,y=-6,width=83,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/room/gaple/count_down_box_reward.png",varname="box_reward"
			},
			{
				name="box_finished",type=1,typeName="Image",time=0,x=10,y=4,width=81,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/room/gaple/count_down_box_finished.png",varname="box_finished"
			},
			{
				name="onLineBox_redPoint",type=1,typeName="Image",time=0,x=0,y=0,width=24,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_red_point.png",gridLeft=12,gridRight=12,gridTop=12,gridBottom=12,varname="onLineBox_redPoint"
			},
			{
				name="Text14",type=4,typeName="Text",time=0,x=90,y=10,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=254,colorGreen=254,colorBlue=254,string=[[Kotak Chip]],colorA=1
			},
			{
				name="onLineBox_time",type=4,typeName="Text",time=0,x=90,y=50,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=250,colorGreen=230,colorBlue=255,string=[[10:10 +50,5000]],colorA=1,varname="onLineBox_time"
			}
		},
		{
			name="level_up",type=1,typeName="Button",time=0,x=2,y=200,width=277,height=89,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="res/freeGold/freeGold_room_di.png",varname="level_up",callbackfunc="onLevelUpBtnClick",
			{
				name="levelUp_icon",type=1,typeName="Image",time=0,x=0,y=0,width=89,height=69,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/freeGold/freeGold_upgrade.png",varname="levelUp_icon"
			},
			{
				name="levelUp_redPoint",type=1,typeName="Image",time=0,x=0,y=0,width=24,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_red_point.png",gridLeft=12,gridRight=12,gridTop=12,gridBottom=12,varname="levelUp_redPoint"
			},
			{
				name="Text16",type=4,typeName="Text",time=0,x=90,y=10,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=24,textAlign=kAlignLeft,colorRed=254,colorGreen=254,colorBlue=254,string=[[Hadiah]],colorA=1
			},
			{
				name="mextLevel",type=5,typeName="TextView",time=0,x=88,y=38,width=179,height=45,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignLeft,colorRed=250,colorGreen=230,colorBlue=255,string=[[Bonus Naik Lv 3000K Koin]],colorA=1,varname="mextLevel",callbackfunc="onLevelUpTextTouch"
			}
		}
	}
}
return room_freeChip_pop_layer;