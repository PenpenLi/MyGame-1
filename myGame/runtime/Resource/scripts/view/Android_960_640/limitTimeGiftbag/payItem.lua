local payItem=
{
	name="payItem",type=0,typeName="View",time=0,x=0,y=0,width=170,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="PayBg",type=1,typeName="Image",time=0,x=0,y=0,width=168,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/common/pay_select.png"
	},
	{
		name="PayIcon",type=1,typeName="Image",time=0,x=8,y=-6,width=150,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,varname="PayIcon",file="res/payType/first_recharge_12_icon.png"
	},
	{
		name="Image5",type=1,typeName="Image",time=0,x=0,y=21,width=150,height=2,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="res/store/store_history_line_2.png"
	}
}
return payItem;