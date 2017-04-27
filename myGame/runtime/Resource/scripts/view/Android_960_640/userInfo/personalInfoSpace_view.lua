local personalInfoSpace_view=
{
	name="personalInfoSpace_view",type=0,typeName="View",time=0,x=0,y=0,width=960,height=640,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="Text_signature_key",type=4,typeName="Text",time=0,x=24,y=9,width=120,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Signature:]],varname="Text_signature_key",colorA=1
	},
	{
		name="Image5",type=1,typeName="Image",time=0,x=20,y=58,width=480,height=2,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/userInfo/userInfo_divider_horizontal.png"
	},
	{
		name="Text_news_key",type=4,typeName="Text",time=0,x=24,y=77,width=132,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=22,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Last saying:]],colorA=1,varname="Text_news_key"
	},
	{
		name="Text7",type=4,typeName="Text",time=0,x=164,y=82,width=100,height=27,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=16,textAlign=kAlignLeft,colorRed=199,colorGreen=127,colorBlue=241,string=[[XXXX-XX-XX]],colorA=1,varname="Text_news_date"
	},
	{
		name="Button10",type=1,typeName="Button",time=0,x=380,y=232,width=127,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_yellow_btn.png",varname="Button_publish",callbackfunc="onBtnPublishClick",
		{
			name="Text18",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[Publish]],colorA=1
		}
	},
	{
		name="Button11",type=1,typeName="Button",time=0,x=465,y=133,width=44,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/userInfo/userInfo_btn_thumbUp.png",varname="Button_thump_up",callbackfunc="onButtonThumpUpClick"
	},
	{
		name="Text12",type=4,typeName="Text",time=0,x=460,y=180,width=54,height=21,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=14,textAlign=kAlignCenter,colorRed=199,colorGreen=127,colorBlue=241,string=[[000000]],colorA=1,varname="Text_thumpUp_num"
	},
	{
		name="Button13",type=1,typeName="Button",time=0,x=483,y=73,width=28,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/userInfo/userInfo_delete_say.png",varname="Button_delete",callbackfunc="onBtnDeleteClick"
	},
	{
		name="Image_subview13",type=1,typeName="Image",time=0,x=0,y=0,width=490,height=220,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15
	},
	{
		name="Button15",type=1,typeName="Button",time=0,x=23,y=176,width=117,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/common/common_blank.png",varname="Button_see_all",callbackfunc="onBtnSeeAllClick",
		{
			name="Text17",type=4,typeName="Text",time=0,x=0,y=0,width=100,height=23,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=16,textAlign=kAlignLeft,colorRed=199,colorGreen=127,colorBlue=241,string=[[See all: 10]],colorA=1
		}
	},
	{
		name="Image17",type=1,typeName="Image",time=0,x=485,y=12,width=26,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="res/userInfo/userInfo_edit_sign.png",varname="Image_edit_sign"
	},
	{
		name="TextView17",type=5,typeName="TextView",time=0,x=22,y=120,width=403,height=49,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=18,textAlign=kAlignTopLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[Good Day!]],colorA=1,varname="Text_news_content"
	},
	{
		name="EditTextView17",type=7,typeName="EditTextView",time=0,x=144,y=15,width=370,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,colorA=1,varname="Edit_signature"
	}
}
return personalInfoSpace_view;