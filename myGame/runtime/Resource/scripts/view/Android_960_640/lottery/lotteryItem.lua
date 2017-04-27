local lotteryItem=
{
	name="lotteryItem",type=0,typeName="View",time=0,x=0,y=0,width=110,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
	{
		name="PrizeIcon",type=1,typeName="Image",time=0,x=0,y=-2,width=77,height=41,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/default3.png",varname="PrizeIcon"
	},
	{
		name="PrizeNameBg",type=1,typeName="Image",time=0,x=-1,y=41,width=104,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/lottery/lottery_name_bg.png",varname="PrizeNameBg"
	},
	{
		name="PrizeName",type=4,typeName="Text",time=0,x=0,y=41,width=1,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=18,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Text]],colorA=1,varname="PrizeName"
	}
}
return lotteryItem;