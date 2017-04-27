local StoreConfig = {}

-- 支付类型 --

-- 谷歌支付(12)
StoreConfig.IN_APP_BILLING    = 12
--印尼-ZingMobile支付（147）
StoreConfig.ZING_MOBILE_XL   	= 147
--coda-IndosatXL(SDK)(pmode=269)
StoreConfig.CODA_INDOSAT   	= 269
--MimoPay(205)
StoreConfig.MIMO_PAY   		= 205
--indomog(46)
StoreConfig.INDOMOG   		= 46

-- APPSTORY
StoreConfig.IN_APP_PURCHASE   = 200

-- 支付类型 end --


-- 支付类型名称
StoreConfig.payTypeName = {
	[StoreConfig.IN_APP_BILLING] = "Google wallet",
	[StoreConfig.ZING_MOBILE_XL] = "",
	[StoreConfig.CODA_INDOSAT] = "",
	[StoreConfig.MIMO_PAY] = "TELKOMSEL",
	[StoreConfig.INDOMOG] = "MOGPlay",
	-- [StoreConfig.IN_APP_PURCHASE] = "in_app_purchase",
}

-- 支付类型图片
StoreConfig.payTypeIcon = {
	[StoreConfig.IN_APP_BILLING] = "store_paytype_12_icon",
	[StoreConfig.ZING_MOBILE_XL] = "store_paytype_147_icon",
	[StoreConfig.CODA_INDOSAT] = "store_paytype_269_icon",
	[StoreConfig.MIMO_PAY] = "store_paytype_205_icon",
	[StoreConfig.INDOMOG] = "store_paytype_46_icon",
	-- [StoreConfig.IN_APP_PURCHASE] = "store_paytype_200_icon",
}

-- 商品类型名称
StoreConfig.goodsTypeName = {
	"金币",
	"道具",
	"购买记录",
}

return StoreConfig