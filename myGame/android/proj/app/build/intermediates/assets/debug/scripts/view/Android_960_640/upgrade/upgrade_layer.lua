local upgrade_layer=
{
	name="upgrade_layer",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="swf_level_up",type=0,typeName="Swf",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,swfFrame=1,swfKeep=1,swfRepeat=1,swfDelay=0,swfAuto=0,swfAutoClean=1,swfInfoLua="qnRes/qnSwfRes/swf/upgrade_swf_info",swfPinLua="qnRes/qnSwfRes/swf/upgrade_swf_pin",varname="swf_level_up",callbackfunc="onSwfLeveUpClick"
	},
	{
		name="gold_bg",type=1,typeName="Image",time=0,x=0,y=76,width=173,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/hall/hall_chips_bg.png",varname="gold_bg",
		{
			name="gold",type=1,typeName="Image",time=0,x=2,y=-1,width=33,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="res/common/common_gold_big.png"
		},
		{
			name="text_reward",type=4,typeName="Text",time=0,x=17,y=0,width=100,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=28,textAlign=kAlignCenter,colorRed=255,colorGreen=200,colorBlue=0,string=[[+18000]],colorA=1,varname="text_reward"
		},
		{
			name="text_level_up",type=4,typeName="Text",time=0,x=0,y=43,width=100,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=28,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[您升级为Lv.10啦！]],colorA=1,varname="text_level_up"
		}
	}
}
return upgrade_layer;