local RankConfig = {}

-- 第一标题分类(也用于请求php的榜单类型)
RankConfig.mainType = {
    "play",     --牌局
    "win",      --盈利
    "money",    --总金币
}

-- 第二标题分类
RankConfig.subType = {
    "friend",
    "total",
}

-- 好友排行榜,不同榜单根据不同字段排序
RankConfig.friendsType = {
    "ptotal",   --牌局
    "incMoney", --盈利
    "money",    --总金币
}

return RankConfig