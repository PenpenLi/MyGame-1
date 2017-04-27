-- socketConfig.lua
-- Last modification : 2016-05-12
-- Description: a config include all socket config.

-- socket name
kSocketGaple = "gapleSocket"
kGameId = 0
kSocketHeader = "BY9"
KnetEndian = 1
kProtocalVersion = 2.0;
kProtocalVsubVer = 0

-- Socket数据包数据类型
kPacketDataType = {}
local T = kPacketDataType

kPacketDataType.BYTE = "byte"
kPacketDataType.SHORT = "short"
kPacketDataType.INT = "int"
kPacketDataType.INT64 = "ulong"
kPacketDataType.STRING = "string"
kPacketDataType.BUFFER = "buffer"

kPacketDataType.ARRAY = "array"

kPacketDataType.BINARY = "binary"

local SocketConfig = {}
local P = SocketConfig

P.CONFIG = {}
P.CONFIG.CLIENT = {}
P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER

-- CLIENT[***] = {
--     fmt = {
--         {name = "*", type = T.INT}, 
--         {name = "*", type = T.INT}, 
--         {name = "*", type = T.INT64},
--         {name = "*", type = T.INT},        
--         {name = "*", type = T.INT},
-- 		   {  
--             name = "*", type = T.ARRAY,
--             fmt = {
--                 lengthType = T.INT,
--                 {name = "*" , type = T.INT},      
--             }
--         }  
--     }
-- }
-- 
-- (***)括号内名称一致，接收到packet后会调用socketProcesserModule中对应的(***)方法
-- SERVER[(***)] = {
--     ver = 1,
--     fmt = {
--         {name = "*", type = T.INT},     
--     }
--	   callback = "(***)"
-- }

----------------------------------------------------------------
------------------------- CLIENT-SERVER ------------------------
----------------------------------------------------------------
-- 1、位置最好一一对应，保持客户端发给SERVER的在上方，SERVER回复的紧接在下方，方便查看
-- 2、命名上客户端发给SERVER一般为“CLI_”开头，SERVER回复客户端一般为“SVR_”开头
-- 3、尽量注释清楚

P.CLI_PHP                               = 0xEEEC    --通过 server 调起 php 请求

P.SVR_HALL_ERROR                        = 0x100c

P.SVR_HALL_BROADCAST_MGS                = 0x2008

P.SVR_COMMON_BROADCAST                  = 0x100A    --服务器单播，充值成功,系统消息等

P.CLI_USER_IN_BACKGROUND                = 0x010F    --用户home状态

--心跳
P.CLISVR_HEART_BEAT                     = 0x1001    --server心跳包,发和收同一个

P.CLI_LOGIN                             = 0x1002    --登录大厅
P.SVR_LOGIN_OK                          = 0x1003    --大厅登录成功
P.SVR_HALL_LOGIN_FAIL                   = 0x1004    --大厅登录失败

P.CLI_GET_ROOM                          = 0x1005    --请求分配房间
P.SVR_GET_ROOM_OK                       = 0x1006    --获取房间分配结果
P.SVR_GET_ROOM_FAIL                     = 0x1007    --获取房间分配失败(换桌)

P.CLI_LOGIN_ROOM                        = 0x0101    --登录房间
P.SVR_LOGIN_ROOM_OK                     = 0x0102    --登录房间OK
P.SVR_RE_LOGIN_ROOM_OK                  = 0x0129    --重连登录房间OK
P.SVR_LOGIN_ROOM_FAIL                   = 0x0103    --登录房间失败

P.CLI_SEAT_DOWN                         = 0x0104    --用户请求坐下
P.SVR_SELF_SEAT_DOWN_OK                 = 0x0105    --服务器回复坐下结果
P.SVR_SEAT_DOWN                         = 0x0106    --服务器广播用户坐下

P.SVR_GAME_START                        = 0x0107    --服务器广播游戏开始,前端收到这个包后，跑下注动画

P.CLI_STAND_UP                          = 0x0108    --用户请求站立
P.SVR_STAND_UP                          = 0x0109    --服务器回复玩家站起
P.SVR_OTHER_STAND_UP                    = 0x0110    --服务器广播用户站起

P.CLI_CHANGE_ROOM                       = 0x01008   --用户请求换桌

P.CLI_SET_BET                           = 0x0113    --玩家出牌
P.SVR_NEXT_BET                          = 0x0112    --服务器广播玩家出牌和下一个操作的玩家。

P.SVR_GAME_OVER                         = 0x0122    --服务器广播牌局结束，结算结果,前端自已跑一系列动画


P.CLI_LOGOUT_ROOM                       = 0x0123    --用户请求离开房间
P.SVR_KICK_OUT                          = 0x0124    --被t出房间
P.SVR_LOGOUT_ROOM_OK                    = 0x0125    --登出房间OK
P.SVR_FORCE_USER_OFFLINE                = 0x1011    --server把用户T出游戏

P.SVR_MSG                               = 0x0121    --服务器广播房间内聊天
P.SVR_OTHER_OFFLINE                     = 0x0116    --服务器广播用户掉线

P.CLI_SEND_ROOM_BROADCAST               = 0x0128    --发送房间广播
P.SVR_ROOM_BROADCAST                    = 0x0128    --房间内广播

P.CLI_SEND_ROOM_COST_PROP               = 0x010C    --玩家发送付费表情、道具
P.SVR_SEND_ROOM_COST_PROP               = 0x010D    --回复玩家发送付费道具

P.TRACE_FRIEND                          = 0x01009   --追踪好友
P.SVR_TRANCE_FRIEND_OK                  = 0x1010    --追踪好友返回

P.CLI_TABLE_SYNC                        = 0x011A    --用户请求桌面同步包
P.SVN_TABLE_SYNC                        = 0x011A    --服务器回复，桌面信息同步包。

P.CLI_GET_NO_READ_MSG                   = 0x3820    --客户端拉取未读消息
P.SVR_GET_NO_READ_MSG_RETURN            = 0x3820    --客户端拉取未读消息 返回

P.CLI_SEND_FRIEND_CHAT_MSG              = 0x3821    -- 发送好友聊天
P.SVR_SEND_FRIEND_CHAT_MSG_RETUEN       = 0x3821    -- 发送好友聊天 回复
P.SVR_REC_FRIEND_CHAT_MSG               = 0x3822

P.CLI_CHECK_FRIEND_STATUS               = 0x3824    --获取好友的在线状态
P.SVR_CHECK_FRIEND_STATUS               = 0x3824    --服务器返回好友的在线状态



P.CLI_SYNC_USERINFO                     = 0x0011E   --客户端请求更新UserInfo
P.SVR_SYNC_USERINFO                     = 0x0011E   --Server广播更新UserInfo

P.CLI_PRIVATE_CREATE                    = 0x01080   --客户端请求创建私人房
P.SVR_PRIVATE_CREATE_RESPONSE           = 0x01081   --Server回复创建私人房

P.CLI_PRIVATE_SEARCH                    = 0x01082   --客户端请求查找私人房
P.SVR_PRIVATE_SEARCH_RESPONSE           = 0x01083   --Server回复查找结果

P.CLI_PRIVATE_JOIN                      = 0x01084   --客户端请求加入私人房
P.SVR_PRIVATE_JOIN_RESPONSE             = 0x01085   --Server回复加入结果

P.CLI_PRIVATE_LIST_GET                  = 0x01086   --客户端请求获取私人房列表
P.SVR_PRIVATE_LIST_RESPONSE             = 0x01087   --Server回复私人房列表


P.SVR_MSG_SEND_RETIRE                   = 0x133     --服务器通知退休

P.CLI_PLAYER_STATUS_GET                 = 0x1088    --客户端查询用户状态
P.SVR_PLAYER_STATUS_RESPONSE            = 0x1089    --Server回复查询用户状态 --0:离线, 1:大厅, 2:接龙普通房, 3:接龙私人房, 4:99普通房, 5:99私人房

P.CLI_SIDECHIPS_SETBET                  = 0x0220    -- 用户下注 边注玩法
P.SVR_SIDECHIPS_SETBET_RETURN           = 0x0221    -- SERVER回复下注结果 边注玩法
P.CLI_SIDECHIPS_CANCLE                  = 0x0222    -- 用户取消下注  边注玩法
P.SVR_SIDECHIPS_CANCLE_RETURN           = 0x0223    -- SERVER回复取消下注结果  边注玩法
P.SVR_SIDECHIPS_RESULT                  = 0x0224    -- SERVER回复开奖结果  边注玩法




-----------------------99玩法 start--------------------------------
P.CLI_LOGIN_ROOM_QIUQIU                 = 0x0201    --登录房间  这个接口和接龙的内容一样，统一在一起,由server判断登录的是什么房间,返回不同的结果
P.SVR_LOGIN_ROOM_QIUQIU_OK              = 0x0202    --登录房间OK
P.SVR_LOGIN_ROOM_QIUQIU_FAIL            = 0x0203    --登录房间失败

P.CLI_SEAT_DOWN_QIUQIU                  = 0x0204    --用户请求坐下
P.SVR_SELF_SEAT_DOWN_QIUQIU_OK          = 0x0205    --服务器回复坐下结果
P.SVR_SEAT_DOWN_QIUQIU                  = 0x0206    --服务器广播用户坐下

P.SVR_GAME_START_QIUQIU                 = 0x0207    --服务器广播游戏开始,前端收到这个包后，跑下注动画

P.CLI_STAND_UP_QIUQIU                   = 0x0208    --用户请求站立
P.SVR_STAND_UP_QIUQIU                   = 0x0209    --服务器回复玩家站起
P.SVR_OTHER_STAND_UP_QIUQIU             = 0x0210    --服务器广播用户站起

P.CLI_SEND_TIP_TO_GIRL                  = 0x020A    --玩家打赏小费
P.SVR_SEND_TIP_TO_GIRL                  = 0x020B    --回复玩家打赏小费

P.CLI_SEND_ROOM_QIUQIU_COST_PROP        = 0x020C    --玩家发送付费表情、道具  这个接口和接龙的内容一样，统一在一起,由server判断,返回不同的结果（即：发送为同一个接口，返回接口不同）
P.SVR_SEND_ROOM_QIUQIU_COST_PROP        = 0x020D    --回复玩家发送付费道具

P.SVN_AUTO_ADD_MIN_CHIPS                = 0x020E    --自动买入筹码服务器通知


P.SVR_NEXT_BET_QIUQIU                   = 0x0212    --服务器广播下一个操作的玩家。若轮到自己时，玩家加注拉到自已的携带值时，前端要显示ALLIN字样

P.CLI_SET_BET_QIUQIU                    = 0x0213    --玩家发送操作
P.SVR_SET_BET_QIUQIU                    = 0x0214    --服务器回复玩家操作结果,若跟注或加注成功，前端要自已去更新携带金币数
P.SVR_BET_QIUQIU                        = 0x0215    --服务器广播玩家操作.若是加注或跟注，前端要自已去判断是否属于AllIn操作

P.SVR_OTHER_OFFLINE_QIUQIU              = 0x0216    --服务器广播用户掉线

P.SVR_CONFIRM_CARDS_STAGE               = 0x0217    --服务器通知用户进行切牌操作,进行牌型确认

--用户发送切牌,最后切牌倒计时时，前端才需要发送此包，第一二张牌表示一组，第三四张牌表示一组。
P.CLI_SEND_CHANGE_CARDS                 = 0x0218    

P.SVR_BACK_CHANGE_CARDS                 = 0x0219    --服务器回复请求切牌,回复成功后，前端才需要交换牌顺序，并自已计算两组点数值

P.CLI_TABLE_SYNC_QIUQIU                 = 0x021A    --用户请求桌面同步包

P.SVN_TABLE_SYNC_QIUQIU                 = 0x021B    --服务器回复，桌面信息同步包。

P.SVR_RECEIVE_FOURTH_CARD               = 0x0320    --服务器发第四张牌,同样跑轮流发牌动画，server已经完成最大牌值组合

P.SVR_GAME_OVER_QIUQIU                  = 0x0322    --服务器广播牌局结束，结算结果,前端自已跑一系列动画

P.CLI_LOGOUT_ROOM_QIUQIU                = 0x0323    --用户请求离开99房间

P.SVR_KICK_OUT_QIUQIU                   = 0x0324    --被t出房间   使用 0x0124 

P.SVR_LOGOUT_ROOM_OK_QIUQIU             = 0x0325    --登出房间OK

P.CLI_CONFIRM_CARD_MODE                 = 0x0326    --用户确认牌型

P.SVR_BOARDCAST_CONFIRM_CARD            = 0x0327    --广播用户确认切牌结果


-----------------------99玩法 end--------------------------------


P.CLI_ROOM_STATUS_GET                   = 0x1090    -- 客户端通过tid查询房间类型（玩法，接龙 99 。。。）
P.SVR_ROOM_STATUS_GET                   = 0x1091    -- server返回查询结果

----------------------------------------------------------------
------------------------- 客户端请求  --------------------------
----------------------------------------------------------------

CLIENT[P.CLI_PHP] = {
    ver = 1,
    fmt = {
        {name = "id", type = T.INT}, -- http请求id
        {name = "isCompress", type = T.INT}, -- 返回数据压缩标识(=0:不压缩, =1:压缩)
        {name = "httpType", type = T.BYTE}, -- http请求类型(=1:Get请求, =2:Post请求)
        {name = "url", type = T.STRING}, -- http请求url
        {name = "params", type = T.STRING}, -- http请求params
    }
}

CLIENT[P.CLI_CHANGE_ROOM] = {
    ver = 1,
    fmt = {
        {name = "roomLevel", type = T.INT},   --桌子等级
        {name = "userLevel", type = T.INT}, --用户等级
        {name = "userMoney", type = T.INT64},--用户钱
        {name = "tid", type = T.INT},        --原来的桌子id
        {name = "serverVersion", type = T.INT} --服务器版本
    }
}

CLIENT[P.CLI_SEND_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "info", type = T.STRING} -- 发送内容
    }
}

CLIENT[P.CLI_LOGIN] = {
    ver = 1,
    fmt = {
        {name = "uid",      type = T.INT},
        {name = "userType", type = T.INT}, --移动：0，PC：1
        {name = "channel",   type = T.INT}, --DID
        {name = "clientVersion",   type = T.INT},
        {name = "serverVersion",   type = T.INT},
        {name = "userLevel",   type = T.INT},
        {name = "userMoney",   type = T.INT64},
        {name = "vipLevel",   type = T.INT}
    }
}

CLIENT[P.CLI_GET_ROOM] = {
    ver = 1,
    fmt = {
        {name = "roomLevel",      type = T.INT},
        {name = "userLevel", type = T.INT},
        {name = "userChips",   type = T.INT64}
    }
}

CLIENT[P.TRACE_FRIEND]={
    ver=1,
    fmt={
        {name="uid",type = T.INT}
    }
}

CLIENT[P.CLI_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},   --用户ID
        {name = "tid", type = T.INT},   --桌子ID
        {name = "channel",type = T.INT}, --渠道ID
        {name = "ver",type = T.INT},     --版本号
        {name = "vip",type = T.INT},         --vip等级
        {name = "mtkey", type = T.STRING}, --需要验证的key
        {name = "name", type = T.STRING}, --用户名字
        {name = "userInfo", type = T.STRING} --用户基本信息
    }
}

CLIENT[P.CLI_SEAT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.BYTE},   -- 座位ID
        {name = "autoSit", type = T.BYTE}    --自动坐下
    }
}

CLIENT[P.CLI_STAND_UP] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.BYTE}   -- 座位ID
    }
}

CLIENT[P.CLI_SET_BET] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},   --用户ID
        {name = "opType", type = T.BYTE},   --出牌方式 0过,=1出牌
        {name = "card", type = T.BYTE},   --牌
        {name = "cardPos", type = T.BYTE}   --出牌位置  =1 head, =2 tail
    }
}

CLIENT[P.CLI_SEND_ROOM_COST_PROP] = {
    ver = 1,
    fmt = {
        {name = "money", type = T.INT64},
        {name = "type", type = T.BYTE},
        {name = "id", type = T.INT},
        {name = "targetSeatId", type = T.BYTE},
        {name = "num", type = T.BYTE}, --道具数量
    }
}

CLIENT[P.CLI_LOGOUT_ROOM] = nil

CLIENT[P.CLI_USER_IN_BACKGROUND]=nil

CLIENT[P.CLI_TABLE_SYNC]=nil

CLIENT[P.CLI_CHECK_FRIEND_STATUS] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {  
            name = "uidList", type = T.ARRAY,
            fmt = {
                lengthType = T.INT,
                {name = "fuid" , type = T.INT},   --好友uid       
            }
        }            
    }
}

CLIENT[P.CLI_SYNC_USERINFO] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},    --用户ID
        {name = "userInfo", type = T.STRING} --用户基本信息
    }
}

CLIENT[P.CLI_SEND_FRIEND_CHAT_MSG] = {
    ver = 1,
    fmt = {
        {name = "self_uid", type = T.INT},
        {name = "target_uid", type = T.INT},
        {name = "msg", type = T.STRING},
        {name = "send_id", type = T.INT},
        {name = "msg_type", type = T.BYTE},
    }
}

CLIENT[P.CLI_GET_NO_READ_MSG] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},         --用户id
    }
}

CLIENT[P.CLI_PRIVATE_CREATE] = {
    ver = 1,
    fmt = {
        {name = "roomAntes", type = T.INT64},         --底注
        {name = "needKey", type = T.BYTE},            --是否需要密码=0不需要，=1需要
        {name = "roomName", type = T.STRING},         --房间名
        {name = "roomPassword", type = T.STRING},     --密码
    }
}

CLIENT[P.CLI_PRIVATE_SEARCH] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.BYTE},               --查找类型，预留
        {name = "tid", type = T.INT},                 --房间tid
    }
}

CLIENT[P.CLI_PRIVATE_JOIN] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},                 --房间tid
        {name = "roomPassword", type = T.STRING},     --密码
    }
}

CLIENT[P.CLI_PRIVATE_LIST_GET] = {
    ver = 1,
    fmt = {
        {name = "flag", type = T.BYTE},                 --是否隐藏已满房间=0不隐藏，=1隐藏
        {name = "totalNum", type = T.SHORT},            --总数量
        {name = "refreshNum", type = T.SHORT},          --需要刷新的房间数量
        {  
            name = "tidList", type = T.ARRAY,           --房间id数组
            fmt = {
                lengthType = T.INT,
                {name = "tid" , type = T.INT},   --好友uid       
            }
        }
    }
}

CLIENT[P.CLI_SIDECHIPS_SETBET] = {
    ver = 1,
    fmt = {
        {name = "cardType", type = T.BYTE},         --下注牌型  1,SIX DEVILS  2,DEAD HAND  3,SMALL  4,TWIN  5,死路
        {name = "sideBet", type = T.INT64}          --下注金额
    }
}

CLIENT[P.CLI_SIDECHIPS_CANCLE] = {
    ver = 1,
    fmt = {
        {name = "cardType", type = T.BYTE}         --下注牌型
    }
}

CLIENT[P.CLI_PLAYER_STATUS_GET] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}         --用户ID
    }
}

-----------------------99玩法 start--------------------------------

CLIENT[P.CLI_LOGIN_ROOM_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},   --用户ID
        {name = "tid", type = T.INT},   --桌子ID
        {channel = "channel",type = T.INT}, --渠道ID
        {version = "ver",type = T.INT},     --版本号
        {vip = "vip",type = T.INT},         --vip等级
        {name = "mtkey", type = T.STRING}, --需要验证的key
        {name = "name", type = T.STRING}, --用户名字
        {name = "userInfo", type = T.STRING} --用户基本信息
    }
}

CLIENT[P.CLI_SEAT_DOWN_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.BYTE},   -- 座位ID
        {name = "ante", type = T.INT64},    -- 携带金额      
        {name = "autoBuyin", type = T.BYTE}, --自动买入
        {name = "autoSit", type = T.BYTE}    --自动坐下
    }
}

CLIENT[P.CLI_STAND_UP_QIUQIU] = nil

CLIENT[P.CLI_SEND_TIP_TO_GIRL] = {
    ver = 1,
    fmt = {
        {name = "money", type = T.INT64}            
    }
}

CLIENT[P.CLI_SEND_ROOM_QIUQIU_COST_PROP] = {
    ver = 1,
    fmt = {
        {name = "money", type = T.INT64},
        {name = "type", type = T.BYTE},
        {name = "id", type = T.INT},
        {name = "targetSeatId", type = T.BYTE},
    }
}

CLIENT[P.CLI_SET_BET_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "userOperatingType", type = T.BYTE},   --1：看牌，2：跟注/加注，3：弃牌
        {name = "ante", type = T.INT64}            --下注金额  跟注加注时此字段才有效
    }
}

CLIENT[P.CLI_SEND_CHANGE_CARDS] = {
    ver = 1,
    fmt = {
        {name = "card1", type = T.BYTE},
        {name = "card2", type = T.BYTE},
        {name = "card3", type = T.BYTE},
        {name = "card4", type = T.BYTE}
    }
}

CLIENT[P.CLI_TABLE_SYNC_QIUQIU] = nil

CLIENT[P.CLI_LOGOUT_ROOM_QIUQIU] = nil

CLIENT[P.CLI_CONFIRM_CARD_MODE] = nil


-----------------------99玩法 end--------------------------------

CLIENT[P.CLI_ROOM_STATUS_GET] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT}           --table id
    }
}


-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------

SERVER[P.CLI_PHP] = {
    ver = 1,
    fmt = {
        {name = "id", type = T.INT}, -- http请求id
        {name = "serverCode", type = T.BYTE}, -- server的错误码(请求结果,=0成功, !=0请求失败)
        {name = "responseCode", type = T.SHORT}, -- http请求响应码
        {name = "data", type = T.BINARY}, -- http返回body数据 / server失败后的errMsg
    },
    callback = "SVR_PHP_BACK"
}

SERVER[P.CLISVR_HEART_BEAT] = {
    ver = 1,
    fmt = {},
    callback = "CLISVR_HEART_BEAT"
}

SERVER[P.SVR_LOGIN_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tableId", type = T.INT},   --房间ID
        {name = "tableLevel", type = T.INT},        --房间等级
        {name = "baseAnte", type = T.INT64},          --底注 
        {name = "fee", type = T.INT64},               --台费
        {name = "tableStatus", type = T.BYTE}, --桌子当前状态  0停止, =1游戏中   
        {name = "maxSeatCnt", type = T.BYTE}, -- 总的座位数量
        {name = "money", type = T.INT64},

        -- 房间用户列表
        {
            name = "playerList", type = T.ARRAY,
            lengthType = T.BYTE,              -- 当房间人数
            fmt = {
                {name = "uid", type = T.INT},   --用户ID
                {name = "money", type = T.INT64},   --用户金币数
                {name = "seatId", type = T.BYTE},    --座位ID
                {name = "userStatus",type = T.BYTE},  --用户状态机 0未参加游戏, 1游戏中
                {
                    name = "cards", type = T.ARRAY,
                    lengthType = T.BYTE,       --桌子上的牌数
                    fmt = {
                        {name = "cardValue", type = T.BYTE, depends=function(ctx, row) return ctx.tableStatus == 1 end},   --牌的点数
                    }
                },
                {name = "userInfo", type = T.STRING},  --用户信息
            }
        },

        -- 桌子上牌的列表
        {
            name = "tableCardList", type = T.ARRAY,
            lengthType = T.BYTE,       --桌子上的牌数
            fmt = {
                {name = "cardValue", type = T.BYTE, depends=function(ctx, row) return ctx.tableStatus == 1 end},   --牌的点数
            }
        },
        {name = "firstOutCardValue",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --第一张出的牌点数      
        {name = "dealerSeatId",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --庄家座位ID          
        {name = "curOpSeatId",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --当前操作座位ID          
        {name = "opTime",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --操作时间          
        {name = "headCardValue",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end}, --第一张牌的点数
        {name = "tailCardValue",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end}, --最后一张牌的点数
        {name = "moneyPool",type = T.INT64 , depends=function(ctx) return ctx.tableStatus == 1 end}, --奖池金币数
        {name = "ownerUid", type = T.INT}, -- 房主id
        {name = "roomName", type = T.STRING},
    },
    callback = "SVR_LOGIN_ROOM_OK"
}

SERVER[P.SVR_RE_LOGIN_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tableId", type = T.INT},   --房间ID
        {name = "tableLevel", type = T.INT},        --房间等级
        {name = "baseAnte", type = T.INT64},          --底注 
        {name = "fee", type = T.INT64},               --台费
        {name = "tableStatus", type = T.BYTE}, --桌子当前状态  0停止, =1游戏中   
        {name = "maxSeatCnt", type = T.BYTE}, -- 总的座位数量
        {name = "money", type = T.INT64},
        
        -- 房间用户列表
        {
            name = "playerList", type = T.ARRAY,
            lengthType = T.BYTE,              -- 当房间人数
            fmt = {
                {name = "uid", type = T.INT},   --用户ID
                {name = "money", type = T.INT64},   --用户金币数
                {name = "seatId", type = T.BYTE},    --座位ID
                {name = "userStatus",type = T.BYTE},  --用户状态机 0未参加游戏, 1游戏中
                {
                    name = "cards", type = T.ARRAY,
                    lengthType = T.BYTE,       --桌子上的牌数
                    fmt = {
                        {name = "cardValue", type = T.BYTE, depends=function(ctx, row) return ctx.tableStatus == 1 end},   --牌的点数
                    }
                },
                {name = "userInfo", type = T.STRING},  --用户信息
            }
        },

        -- 桌子上牌的列表
        {
            name = "tableCardList", type = T.ARRAY,
            lengthType = T.BYTE,       --桌子上的牌数
            fmt = {
                {name = "cardValue", type = T.BYTE, depends=function(ctx, row) return ctx.tableStatus == 1 end},   --牌的点数
            }
        },
        {name = "firstOutCardValue",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --第一张出的牌点数      
        {name = "dealerSeatId",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --庄家座位ID          
        {name = "curOpSeatId",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --当前操作座位ID          
        {name = "opTime",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --操作时间          
        {name = "headCardValue",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end}, --第一张牌的点数
        {name = "tailCardValue",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end}, --最后一张牌的点数
        {name = "moneyPool",type = T.INT64 , depends=function(ctx) return ctx.tableStatus == 1 end}, --奖池金币数
        {name = "ownerUid", type = T.INT},
        {name = "roomName", type = T.STRING},
        -- 边注玩法信息
        {
            name = "sideChipsList", type = T.ARRAY,
            lengthType = T.BYTE,       --桌子上的牌数
            fmt = {
                {name = "cardType", type = T.BYTE},   --牌的点数
                {name = "sideChip",type = T.INT64},
            }
        },
    },
    callback = "SVR_RE_LOGIN_ROOM_OK"
}

SERVER[P.SVR_LOGIN_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.INT}
    },
    callback = "SVR_LOGIN_ROOM_FAIL"
}

SERVER[P.SVR_SELF_SEAT_DOWN_OK] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},  --1：表示成功，0：表示失败
        {name = "errorCode", type = T.INT,depends=function(ctx) return ctx.ret ~= 1 end}     
    },
    callback = "SVR_SELF_SEAT_DOWN_OK"
}

SERVER[P.SVR_SEAT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},       --坐下用户ID
        {name = "seatId", type = T.BYTE},   --座位ID    
        {name = "money", type = T.INT64},   --金币数
        {name = "userInfo", type = T.STRING},        
        {name = "tableStatus", type = T.BYTE}
    },
    callback = "SVR_SEAT_DOWN"
}

SERVER[P.SVR_GAME_START] = {
    ver = 1,
    fmt = {
        {name = "dealerSeatId", type = T.BYTE},        --庄家座位Id
        {name = "opTime", type = T.BYTE},             --操作时间
        {name = "moneyPool", type = T.INT64},         --奖池金币数
        {
            name = "playerCradList", type = T.ARRAY,
            lengthType = T.BYTE,
            fmt = {
                {name = "seatId", type = T.BYTE}, 
                {
                    name = "cards", type = T.ARRAY, 
                    lengthType = T.BYTE,
                    fmt = {
                        {name = "card",type = T.BYTE}   --扑克牌数值          
                    }
                }
            }
        },
    },
    callback = "SVR_GAME_START"
}

SERVER[P.SVR_STAND_UP] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},   --1：成功， 0：失败
        {name = "loseMoney", type = T.INT64},
        {name = "money", type = T.INT64}    --用户当前金币数
    },
    callback = "SVR_STAND_UP"
}

SERVER[P.SVR_OTHER_STAND_UP] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},   --站起用户ID
        {name = "seatId", type = T.BYTE},
        {name = "escapeMoney", type = T.INT64},  -- 逃跑扣除金币数
        {name = "moneyPool", type = T.INT64}     -- 奖池金币数      
    },
    callback = "SVR_OTHER_STAND_UP"
}

-- P.SVR_DEAL                       = 0x0111    --发牌
-- SERVER[P.SVR_DEAL] = {
--     ver = 1,
--     fmt = {
--         {  
--             name = "cards", type = T.ARRAY,
--             lengthType = T.BYTE,
--             fmt = {
--                 { name = "card" , type = T.BYTE},   --扑克牌数值          
--             }
--         }
--     }
-- }


SERVER[P.SVR_NEXT_BET] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},   --玩家ID
        {name = "opType", type = T.BYTE},    --出牌方式  =0过,=1出牌
        {name = "card", type = T.BYTE},         --牌点数
        {name = "cardPos", type = T.BYTE},         --出牌位置 =1 head, =2 tail
        {name = "nextUid", type = T.INT},            --下一个操作的玩家ID  =0,结束
        {name = "opTime", type = T.BYTE},            --倒计时用
        {name = "headCardValue", type = T.BYTE},     --第一张牌的点数
        {name = "tailCardValue", type = T.BYTE},     --最后一张牌的点数
        {name = "passMoney",type = T.INT64 , depends=function(ctx) return ctx.opType == 0 end}, --过费 =0 不用付过费
        {name = "payMoneyUid",type = T.INT , depends=function(ctx) return ctx.opType == 0 end}, --支付过费方ID
        {name = "getMoneyUid",type = T.INT , depends=function(ctx) return ctx.opType == 0 end}, --获得过费方ID
    },
    callback = "SVR_NEXT_BET"
}


SERVER[P.SVR_OTHER_OFFLINE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "seatId", type = T.BYTE}      
    }
}

SERVER[P.SVR_MSG] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.BYTE}, -- 聊天类型，目前无区分，默认为0；/*0--字符，1--表情*/
        {name = "strChat", type = T.STRING} --聊天内容
    }
}


SERVER[P.SVR_GAME_OVER] = {
    ver = 1,
    fmt = {
        {name = "tableStatus", type = T.BYTE},
        {name = "endType", type = T.BYTE},        -- =1正常,=2死路,=3其他玩家逃离
        {name = "cardType", type = T.BYTE},       -- 标识对应的倍数
        {name = "dealerSeatId", type = T.BYTE},
        {name = "winnerUid", type = T.INT},
        {name = "exp_win", type = T.SHORT},
        {name = "exp_lose", type = T.SHORT},
        {   
            name = "playerList", type = T.ARRAY,
            lengthType = T.BYTE,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "seatId", type = T.BYTE},
                {name = "name", type = T.STRING},
                {name = "money", type = T.INT64},
                {name = "turnMoney", type = T.INT64},
                {
                    name = "cards", type = T.ARRAY, 
                    lengthType = T.BYTE,
                    fmt = {
                        {name = "card",type = T.BYTE}   --扑克牌数值          
                    }
                },
            }
        },
        {
            name = "escapeList", type = T.ARRAY,
            lengthType = T.BYTE,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "seatId", type = T.BYTE},
                {name = "name", type = T.STRING},
                {name = "turnMoney", type = T.INT64}
            }
        },
        {name = "countDown", type = T.BYTE}  -- 下局开始倒计时时间
    },
    callback = "SVR_GAME_OVER"
}



SERVER[P.SVR_LOGIN_OK] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},           --table id
        {name = "roomLevel", type = T.INT}
    },
    callback = "SVR_LOGIN_OK"
}


SERVER[P.SVR_HALL_LOGIN_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.INT}
    },
    callback = "SVR_HALL_LOGIN_FAIL"
}

SERVER[P.SVR_GET_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT} --桌子ID
    },
    callback = "SVR_GET_ROOM_OK",
}

SERVER[P.SVR_GET_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.INT} --桌子ID
    },
    callback = "SVR_GET_ROOM_FAIL",
}

SERVER[P.SVR_TRANCE_FRIEND_OK]={
    ver=1,
    fmt={
        {name="uid",type = T.INT},
        {name="state",type = T.BYTE},       -- 1离线状态  2在大厅  3在房间围观  4在房间玩牌
        {name = "tableId", type = T.INT},
        {name = "tableLevel", type = T.INT}
    },
    callback = "SVR_TRANCE_FRIEND_OK"
}


SERVER[P.SVR_LOGOUT_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "money", type = T.INT64}
    },
    callback = "SVR_LOGOUT_ROOM_OK"
}


-- SERVER[P.SVR_KICK_OUT] = nil
SERVER[P.SVR_KICK_OUT] = {
    ver = 1,
    fmt = {},
    callback = "SVR_KICK_OUT",
}

SERVER[P.SVR_MSG_SEND_RETIRE] = {
    ver = 1,
    fmt = {},
    callback = "SVR_MSG_SEND_RETIRE",
}


SERVER[P.SVR_FORCE_USER_OFFLINE] = {
    ver = 1,
    fmt = {
        {name = "errorCode",type = T.INT}
    },
    callback = "SVR_FORCE_USER_OFFLINE"
}

SERVER[P.SVR_SEND_ROOM_COST_PROP] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},          --结果，1成功 0失败
        {name = "errorCode", type = T.INT},        --失败错误码
        {name = "count", type = T.INT64},        --道具金额
        {name = "anteMoney", type = T.INT64},       --剩余携带
        {name = "totalMoney", type = T.INT64},     --剩余总金币
        {name = "type", type = T.BYTE},           --类型
        {name = "id", type = T.INT},               --id
        {name = "targetSeatId", type = T.BYTE},               --id
        {name = "num", type = T.BYTE}         --数量
    },
    callback = "SVR_SEND_ROOM_COST_PROP"
}

SERVER[P.SVN_TABLE_SYNC]={
    ver = 1,
    fmt = {
        {name = "tableId", type = T.INT},   --房间ID
        {name = "tableLevel", type = T.INT},        --房间等级
        {name = "baseAnte", type = T.INT64},          --底注 
        {name = "fee", type = T.INT64},               --台费
        {name = "tableStatus", type = T.BYTE}, --桌子当前状态  0停止, =1游戏中   
        {name = "maxSeatCnt", type = T.BYTE}, -- 总的座位数量
        {name = "money", type = T.INT64},

        -- 房间用户列表
        {
            name = "playerList", type = T.ARRAY,
            lengthType = T.BYTE,              -- 当房间人数
            fmt = {
                {name = "uid", type = T.INT},   --用户ID
                {name = "money", type = T.INT64},   --用户金币数
                {name = "seatId", type = T.BYTE},    --座位ID
                {name = "userStatus",type = T.BYTE},  --用户状态机 0未参加游戏, 1游戏中
                {
                    name = "cards", type = T.ARRAY,
                    lengthType = T.BYTE,       --桌子上的牌数
                    fmt = {
                        {name = "cardValue", type = T.BYTE, depends=function(ctx, row) return ctx.tableStatus == 1 end},   --牌的点数
                    }
                },
                {name = "userInfo", type = T.STRING},  --用户信息
            }
        },

        -- 桌子上牌的列表
        {
            name = "tableCardList", type = T.ARRAY,
            lengthType = T.BYTE,       --桌子上的牌数
            fmt = {
                {name = "cardValue", type = T.BYTE, depends=function(ctx, row) return ctx.tableStatus == 1 end},   --牌的点数
            }
        },
        {name = "firstOutCardValue",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --第一张出的牌点数      
        {name = "dealerSeatId",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --庄家座位ID          
        {name = "curOpSeatId",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --当前操作座位ID          
        {name = "opTime",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end},  --操作时间          
        {name = "headCardValue",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end}, --第一张牌的点数
        {name = "tailCardValue",type = T.BYTE , depends=function(ctx) return ctx.tableStatus == 1 end}, --最后一张牌的点数
        {name = "moneyPool",type = T.INT64 , depends=function(ctx) return ctx.tableStatus == 1 end}, --奖池金币数
        {name = "ownerUid", type = T.INT},
        {name = "roomName", type = T.STRING},
        -- 边注玩法信息
        {
            name = "sideChipsList", type = T.ARRAY,
            lengthType = T.BYTE,       --桌子上的牌数
            fmt = {
                {name = "cardType", type = T.BYTE},   --牌的点数
                {name = "sideChip",type = T.INT64},
            }
        },
    },
    callback = "SVN_TABLE_SYNC"
}



-- P.SVR_ONLINE                     = 0x0311    --服务器返回客户端各等级场在线人数
-- SERVER[P.SVR_ONLINE] = {
--     ver = 1,
--     fmt = {
--         {  
--             name = "levelOnlines", type = T.ARRAY,
--             lengthType = T.INT,
--             fmt = {
--                 {name = "level", type = T.INT},   --等级场ID
--                 {name = "userCount", type = T.INT} --在线人数
--             }
--         }
--     }
-- }


-- P.SVR_LOGIN_ROOM                 = 0x6001    --服务器广播用户登陆房间
-- SERVER[P.SVR_LOGIN_ROOM] = {
--     ver = 1,
--     fmt = {
--         {name = "uid", type = T.INI},
--         {name = "userInfo", type = T.STRING},
--         {name = "anteMoney", type = T.INT64},
--         {name = "winTimes", type = T.INT},
--         {name = "loseTimes", type = T.INT}
--     }   
-- }

-- P.SVR_LOGOUT_ROOM                = 0x6002    --服务器广播用户登出房间
-- SERVER[P.SVR_LOGOUT_ROOM] = {
--     ver = 1,
--     fmt = {
--         {name = "uid", type = T.INT}     
--     }
-- }









-- P.SVR_CAN_OTHER_CARD             = 0x6009    --服务器广播可以开始获取第三张牌
-- SERVER[P.SVR_CAN_OTHER_CARD] = {
--     ver = 1,
--     fmt = {
--         {name = "seatId", type = T.INT}       
--     }
-- }

-- P.SVR_SHOW_CARD                  = 0x6011    --服务器广播用户亮牌
-- SERVER[P.SVR_SHOW_CARD] = {
--     ver = 1,
--     fmt = {
--         {name = "seatId", type = T.INT},
--         {  
--             name = "cards", type = T.ARRAY,
--             lengthType = T.INT,
--             fmt = {
--                 {type = T.BYTE},   --扑克牌数值          
--             }
--         }        
--     }
-- }

SERVER[P.SVR_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "info", type = T.STRING}
    },
    callback = "SVR_ROOM_BROADCAST"
}

SERVER[P.SVR_COMMON_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "mtype", type = T.SHORT},
        {name = "info", type = T.STRING}
    },
    callback = "SVR_COMMON_BROADCAST",
}


SERVER[P.SVR_HALL_ERROR] = {
    ver = 1,
    fmt = {
        {name = "errorCode1", type = T.INT},
        {name = "errorCode2", type = T.INT}
    },
    callback = "SVR_HALL_ERROR"
}


SERVER[P.SVR_HALL_BROADCAST_MGS] = {
    ver = 1,
    fmt = {
        {name = "info", type = T.STRING}
    },
    callback = "SVR_HALL_BROADCAST_MGS"
}

SERVER[P.SVR_CHECK_FRIEND_STATUS] = {
    ver = 1,
    fmt = {
        {name = "mid", type = T.INT},
        {  
            name = "statusList", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "status", type = T.BYTE}, -- 0 -- 离线  1 -- 大厅   2 -- 房间
                {name = "tid", type = T.INT}     
            }    
        }   
    },
    callback = "SVR_CHECK_FRIEND_STATUS"  
}

SERVER[P.SVR_SYNC_USERINFO] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},--用户ID
        {name = "info", type = T.STRING} --用户基本信息
    },
    callback = "SVR_SYNC_USERINFO"
}

SERVER[P.SVR_SEND_FRIEND_CHAT_MSG_RETUEN] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT}, -- =0成功,=1对方已掉线,=2错误
        {name = "msg_id", type = T.INT},
        {name = "time", type = T.INT},
        {name = "send_id", type = T.INT},
        {name = "msg_type", type = T.BYTE}, 
    },
    callback = "SVR_SEND_FRIEND_CHAT_MSG_RETUEN"  
}


SERVER[P.SVR_REC_FRIEND_CHAT_MSG] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},         -- 1：成功，0：失败
        {name = "msg_json", type = T.STRING}, 
    },
    callback = "SVR_REC_FRIEND_CHAT_MSG"
}
--[[
@@@msg_json  begin, json格式  
send_uid
recv_uid
msg_id
time
msg
@@@msg_json  end  

--]]

SERVER[P.SVR_GET_NO_READ_MSG_RETURN] = {
    ver = 1,
    fmt = {
        {name = "total_num", type = T.INT},         --未读信息总数
        {
            name = "msgs", type = T.ARRAY,
            lengthType = T.INT,             --
            fmt = {{name = "msg_json", type = T.STRING}}
        }
    },
    callback = "SVR_GET_NO_READ_MSG_RETURN"
}

SERVER[P.SVR_PRIVATE_CREATE_RESPONSE] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},         --操作结果，=1成功，=0失败
        {name = "tid", type = T.INT}           --成功返回tid，失败返回错误码
    },
    callback = "SVR_PRIVATE_CREATE_RESPONSE"
}

SERVER[P.SVR_PRIVATE_SEARCH_RESPONSE] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},            --操作结果，=1成功，=0失败
        {name = "tid", type = T.INT},             --房间tid，用于进入房间
        {name = "ownerUid", type = T.INT},        --房主uid
        {name = "roomAntes", type = T.INT64},     --底注
        {name = "roomPople", type = T.BYTE},      --人数
        {name = "roomPassword", type = T.BYTE},   --是否需要密码
        {name = "roomName", type = T.STRING},     --房间名
    },
    callback = "SVR_PRIVATE_SEARCH_RESPONSE"
}

SERVER[P.SVR_PRIVATE_JOIN_RESPONSE] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},         --操作结果，=1成功，=0失败
        {name = "tid", type = T.INT},          --成功返回tid，失败返回错误码
    },
    callback = "SVR_PRIVATE_JOIN_RESPONSE"
}

SERVER[P.SVR_PRIVATE_LIST_RESPONSE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {
            name = "list", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "tid", type = T.INT},             --房间tid，用于进入房间
                {name = "ownerUid", type = T.INT},        --房主uid
                {name = "roomAntes", type = T.INT64},     --底注
                {name = "roomPople", type = T.BYTE},      --人数
                {name = "roomPassword", type = T.BYTE},   --是否需要密码
                {name = "roomName", type = T.STRING},     --房间名
            }
        }
    }
}

SERVER[P.SVR_SIDECHIPS_SETBET_RETURN] = {
    ver = 1,
    fmt = {
        {name = "result", type = T.INT},            --结果 0成功 其他 失败
        {name = "cardType", type = T.BYTE},         --下注牌型
        {name = "sideBet", type = T.INT64},         --下注金额
    }
}

SERVER[P.SVR_SIDECHIPS_CANCLE_RETURN] = {
    ver = 1,
    fmt = {
        {name = "mid", type = T.INT},
        {
            name = "cardTypeList", type = T.ARRAY,
            lengthType = T.BYTE,
            fmt = {
                {name = "cardType" , type = T.BYTE},   --下注牌型 
                {name = "sideBet" , type = T.INT64}    --下注金额
            }
        }
    }
}

SERVER[P.SVR_SIDECHIPS_RESULT] = {
    ver = 1,
    fmt = {
        {name = "mid", type = T.INT},  
        {
            name = "cardTypeList", type = T.ARRAY,
            lengthType = T.BYTE,
            fmt = {
                {name = "cardType" , type = T.BYTE},   --下注牌型    
                {name = "winMoney" , type = T.INT64}   --获奖金额  
            }
        },
        {
            name = "cards", type = T.ARRAY,
            lengthType = T.BYTE,       --桌子上的牌数
            fmt = {
                {name = "cardValue", type = T.BYTE},   --牌的点数
            }
        }
    }
}

SERVER[P.SVR_PLAYER_STATUS_RESPONSE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},         --用户ID
        {name = "tid", type = T.INT},         --桌子ID
        {name = "tableType", type = T.BYTE},         --桌子类型
    },
    callback = "SVR_PLAYER_STATUS_RESPONSE"
}

-----------------------99玩法 start--------------------------------

SERVER[P.SVR_LOGIN_ROOM_QIUQIU_OK] = {
    ver = 1,
    fmt = {
        {name = "tableId", type = T.INT},   --房间ID
        {name = "tableLevel", type = T.INT},        --房间等级
        {name = "tableStatus", type = T.BYTE}, --桌子当前状态

        {name = "dealerSeatId", type = T.BYTE},   --庄家座位ID
        
        {name = "baseAnte", type = T.INT64},       --房间底注
        {name = "totalAnte", type = T.INT64},       --桌子上总筹码数
        
        {name = "curDealSeatId", type = T.BYTE},   --当前操作用户座位ID  结合下一个字段，重连用，-1无效
        {name = "userOperatingTime", type = T.BYTE}, -- 当前操作等待时间  跑倒计时用，0表示没有倒计时
        {name = "quickCall", type = T.INT64},       --重连用,快速跟注值，自己在位置上才有用
        {name = "nMinAnte", type = T.INT64},        --重连用,最小加注
        {name = "nMaxAnte", type = T.INT64},        --重连用,最大加注

        {name = "roundTime", type = T.BYTE}, -- 每轮操作时间
        {name = "maxSeatCnt", type = T.BYTE}, -- 总的座位数量

        {name = "minAnte", type = T.INT64}, --最小携带
        {name = "maxAnte", type = T.INT64}, --最大携带
        {name = "defaultAnte", type = T.INT64}, --默认携带

        --房间用户列表
        {
            name = "playerList", type = T.ARRAY,
            lengthType = T.INT,             --房间人数
            fmt = {
                {name = "uid", type = T.INT},   --用户ID
                {name = "seatId", type = T.BYTE},    --座位ID
                {name = "userStatus",type = T.BYTE},  --用户状态机
                {name = "onlineStatus",type = T.BYTE},  --网络状态
                {name = "hasConfirmCards",type = T.BYTE},   --是否已经确认牌型,只有在桌子状态为【确认点数组合状态】时才有效
                {name = "userInfo", type = T.STRING},  --用户信息
                {name = "anteMoney", type = T.INT64},  --携带金币数
                {name = "nCurAnte", type = T.INT64},   --玩家总下注金币数
                {name = "nWinTimes", type = T.INT},     --赢次数
                {name = "nLoseTimes", type = T.INT},    --输次数
                {name = "isOutCard", type = T.BYTE}, -- 1 亮牌  0 不亮牌
                {name = "specialCardsType", type = T.BYTE},  --特殊牌型标志

                {name = "cardsCount", type = T.BYTE},
                {name = "card1",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end} ,  --扑克牌数值          
                {name = "card2",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end} ,  --扑克牌数值          
                {name = "card3",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end} ,  --扑克牌数值          
                {name = "card4",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end} 
                
            }
        }
    },
    callback = "SVR_LOGIN_ROOM_QIUQIU_OK"
}

SERVER[P.SVR_LOGIN_ROOM_QIUQIU_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.INT}
    },
    callback = "SVR_LOGIN_ROOM_QIUQIU_FAIL"
}

SERVER[P.SVR_SELF_SEAT_DOWN_QIUQIU_OK] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},  --1：表示成功，0：表示失败
        {name = "errorCode", type = T.INT,depends=function(ctx) return ctx.ret ~= 1 end}     
    },
    callback = "SVR_SELF_SEAT_DOWN_QIUQIU_OK"
}


SERVER[P.SVR_SEAT_DOWN_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},       --坐下用户ID
        {name = "seatId", type = T.BYTE},   --座位ID
        {name = "anteMoney", type = T.INT64}, -- 携带
        {name = "money", type = T.INT64}, --总钱数含携带     
        {name = "userInfo", type = T.STRING},        
        {name = "winTimes", type = T.INT},
        {name = "loseTimes", type = T.INT}
    },
    callback = "SVR_SEAT_DOWN_QIUQIU"
}

SERVER[P.SVR_GAME_START_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "dealerSeatId", type = T.BYTE},        --庄家座位Id
        {name = "blinds", type = T.INT64},             --盲注，第一轮
        {name = "nTotalAnte", type = T.INT64},         --桌上金币总数,第一轮下注后奖池金币数

        -- {name = "dealerOperatingTime", type = T.BYTE}, --庄家选择时间
        -- {name = "dealerMinAnte", type = T.INT64},      --庄家加注最小值,非庄家此值无意义
        -- {name = "dealerMaxAnte", type = T.INT64},      --庄家加注最大值,0：不可以加注，非庄家此值无意义

        {
            name = "anteMoneyList", type = T.ARRAY,
            lengthType = T.BYTE,
            fmt = {
                {name = "seatId", type = T.BYTE},  
                {name = "anteMoney", type = T.INT64} --用户携带
            }
        },

        {
            name = "cards", type = T.ARRAY,     --自已的手牌数，围观的玩家此值为0
            lengthType = T.BYTE,
            fmt = {
                {name = "card",type = T.BYTE}   --扑克牌数值          
            }
        }
    },
    callback = "SVR_GAME_START_QIUQIU"
}

SERVER[P.SVR_STAND_UP_QIUQIU] = {
    ver = 1,
    fmt = {
        -- {name = "ret", type = T.BYTE},   --1：成功， 0：失败
        -- {name = "seatId", type = T.BYTE},
        {name = "money", type = T.INT64}    --用户当前金币数
    },
    callback = "SVR_STAND_UP_QIUQIU"
}

SERVER[P.SVR_SEND_TIP_TO_GIRL] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},          --结果，1成功 0失败
        {name = "errorCode", type = T.INT},        --失败错误码
        {name = "count", type = T.INT64},        --打赏金额
        {name = "anteMoney", type = T.INT64},       --打赏后剩余携带
        {name = "totalMoney", type = T.INT64}      --打赏后剩余总金币
    },
    callback = "SVR_SEND_TIP_TO_GIRL"
}

SERVER[P.SVR_SEND_ROOM_QIUQIU_COST_PROP] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},          --结果，1成功 0失败
        {name = "errorCode", type = T.INT},        --失败错误码
        {name = "count", type = T.INT64},        --道具金额
        {name = "anteMoney", type = T.INT64},       --剩余携带
        {name = "totalMoney", type = T.INT64},     --剩余总金币
        {name = "type", type = T.BYTE},           --类型
        {name = "id", type = T.INT},               --id
        {name = "targetSeatId", type = T.BYTE},               --id
        {name = "num", type = T.BYTE} --数量
    },
    callback = "SVR_SEND_ROOM_QIUQIU_COST_PROP"
}

SERVER[P.SVN_AUTO_ADD_MIN_CHIPS]={
    ver=1,
    fmt={
        {name="haveChips",type = T.INT64}--携带金币数目
    },
    callback = "SVN_AUTO_ADD_MIN_CHIPS"
}

SERVER[P.SVR_OTHER_STAND_UP_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},   --站起用户ID
        {name = "seatId", type = T.BYTE}           
    },
    callback = "SVR_OTHER_STAND_UP_QIUQIU"
}

SERVER[P.SVR_NEXT_BET_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.BYTE},   --非自已ID，不显示看牌加注等按钮
        {name = "userOperatingTime", type = T.BYTE},    --倒计时用
        {name = "nMinAnte", type = T.INT64},         --加注最小值
        {name = "nMaxAnte", type = T.INT64},         --加注最大值,为0表示不可以加注
        {name = "quickCall", type = T.INT64}            --跟注值。若是看牌，此值无意义，传0
    },
    callback = "SVR_NEXT_BET_QIUQIU"
}

SERVER[P.SVR_SET_BET_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "userOperatingType", type = T.BYTE},    --1: 看牌，2: 弃牌，3: 跟注, 4: 加注
        {name = "ret", type = T.BYTE},          --结果,1成功0失败
        {name = "anteMoney", type = T.INT64},   --剩余携带金币
        {name = "errorCode", type = T.INT}
    },
    callback = "SVR_SET_BET_QIUQIU"
}

SERVER[P.SVR_BET_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.BYTE},
        {name = "userOperatingType", type = T.BYTE},    --1：看牌，2：跟注/加注，3：弃牌
        {name = "curAnte", type = T.INT64},         --当前下注金额,跟注加注时此字段才有效
        {name = "anteMoney", type = T.INT64},      -- 剩余携带
        {name = "nTotalAnte", type = T.INT64}         --桌上金币总数,即操作后的奖池总金币数
    },
    callback = "SVR_BET_QIUQIU"
}

SERVER[P.SVR_OTHER_OFFLINE_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "seatId", type = T.BYTE}      
    },
    callback = "SVR_OTHER_OFFLINE_QIUQIU"
}

SERVER[P.SVR_CONFIRM_CARDS_STAGE] = {
    ver = 1,
    fmt = {
        {name = "userOperatingTime", type = T.BYTE}     --切牌时间,前端用于倒计时，超过该时间将比牌
    },
    callback = "SVR_CONFIRM_CARDS_STAGE"
}

SERVER[P.SVR_BACK_CHANGE_CARDS] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},  --1：表示成功，0：表示失败
        {name = "specialCardsType", type = T.BYTE} --特殊牌型
    },
    callback = "SVR_BACK_CHANGE_CARDS"
}

SERVER[P.SVN_TABLE_SYNC_QIUQIU]={
    ver = 1,
    fmt = {
        {name = "tableId", type = T.INT},   --房间ID
        {name = "tableLevel", type = T.INT},        --房间等级
        {name = "tableStatus", type = T.BYTE}, --桌子当前状态

        {name = "dealerSeatId", type = T.BYTE},   --庄家座位ID
        
        {name = "baseAnte", type = T.INT64},       --房间底注
        {name = "totalAnte", type = T.INT64},       --桌子上总筹码数
        
        {name = "curDealSeatId", type = T.BYTE},   --当前操作用户座位ID  结合下一个字段，重连用，-1无效
        {name = "userOperatingTime", type = T.BYTE}, -- 当前操作等待时间  跑倒计时用，0表示没有倒计时
        {name = "quickCall", type = T.INT64},       --重连用,快速跟注值，自己在位置上才有用
        {name = "nMinAnte", type = T.INT64},        --重连用,最小加注
        {name = "nMaxAnte", type = T.INT64},        --重连用,最大加注

        {name = "roundTime", type = T.BYTE}, -- 每轮操作时间
        {name = "maxSeatCnt", type = T.BYTE}, -- 总的座位数量

        {name = "minAnte", type = T.INT64}, --最小携带
        {name = "maxAnte", type = T.INT64}, --最大携带
        {name = "defaultAnte", type = T.INT64}, --默认携带

        --房间用户列表
        {
            name = "playerList", type = T.ARRAY,
            lengthType = T.INT,             --房间人数
            fmt = {
                {name = "uid", type = T.INT},   --用户ID
                {name = "seatId", type = T.BYTE},    --座位ID
                {name = "userStatus",type = T.BYTE},  --用户状态机
                {name = "onlineStatus",type = T.BYTE},  --网络状态
                {name = "hasConfirmCards",type = T.BYTE},   --是否已经确认牌型,只有在桌子状态为【确认点数组合状态】时才有效
                {name = "userInfo", type = T.STRING},  --用户信息
                {name = "anteMoney", type = T.INT64},  --携带金币数
                {name = "nCurAnte", type = T.INT64},   --玩家总下注金币数
                {name = "nWinTimes", type = T.INT},     --赢次数
                {name = "nLoseTimes", type = T.INT},    --输次数
                {name = "isOutCard", type = T.BYTE}, -- 1 亮牌  0 不亮牌
                {name = "specialCardsType", type = T.BYTE},  --特殊牌型标志

                {name = "cardsCount", type = T.BYTE},
                {name = "card1",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end} ,  --扑克牌数值          
                {name = "card2",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end} ,  --扑克牌数值          
                {name = "card3",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end} ,  --扑克牌数值          
                {name = "card4",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end} 
                
            }
        }
    },
    callback = "SVN_TABLE_SYNC_QIUQIU"
}

SERVER[P.SVR_RECEIVE_FOURTH_CARD] = {
    ver = 1,
    fmt = {
        --要第四张牌的用户，即是没有弃牌的用户
        {
            name = "seatIds", type = T.ARRAY,     
            lengthType = T.BYTE,
            fmt = {
                {name = "seatId",type = T.BYTE}   --座位          
            }
        },

        {
            name = "cards", type = T.ARRAY,     --手牌数，围观用户此值为0
            lengthType = T.BYTE,
            fmt = {
                {name = "card",type = T.BYTE}   --扑克牌数值          
            }
        },

        {name = "specialCardsType", type = T.BYTE}  --特殊牌类型

        -- {name = "curDealSeatId", type = T.BYTE},  --当前操作者座位
        -- {name = "userOperatingTime", type = T.BYTE} --当前操作者时间
    },
    callback = "SVR_RECEIVE_FOURTH_CARD"
}

SERVER[P.SVR_GAME_OVER_QIUQIU] = {
    ver = 1,
    fmt = {
        {
            name = "playerList", type = T.ARRAY,
            lengthType = T.BYTE,
            fmt = {
                {name = "uid", type = T.INT},
                {name = "seatId", type = T.BYTE},
                {name = "anteMoney", type = T.INT64}, -- 携带金币数         
                {name = "turnMoney", type = T.INT64}, -- 金币变化         
                {name = "totalMoney", type = T.INT64},   --总金币数
                {name = "getExp", type = T.INT},        --增加经验
                {name = "isOutCard", type = T.BYTE}, -- 1 亮牌  0 不亮牌,弃牌的人不显示他的牌
                {name = "specialCardsType", type = T.BYTE},  --特殊牌型
                {name = "cardsCount", type = T.BYTE},
                {name = "card1",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end} ,  --扑克牌数值          
                {name = "card2",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end} ,  --扑克牌数值          
                {name = "card3",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end} ,  --扑克牌数值          
                {name = "card4",type = T.BYTE , depends=function(ctx, row) return row.isOutCard == 1 end}   --扑克牌数值          

            }
        },

        --奖池分配
        {
            name = "bonusList", type = T.ARRAY,
            lengthType = T.BYTE,
            fmt = {
                {name = "moneyPool", type = T.INT64},

                {name = "playersCount", type = T.BYTE},

                {name = "seatId1",type = T.BYTE},        
                {name = "money1",type = T.INT64},

                {name = "seatId2",type = T.BYTE},        
                {name = "money2",type = T.INT64},

                {name = "seatId3",type = T.BYTE},        
                {name = "money3",type = T.INT64},

                {name = "seatId4",type = T.BYTE},    
                {name = "money4",type = T.INT64},

                {name = "seatId5",type = T.BYTE},        
                {name = "money5",type = T.INT64},

                {name = "seatId6",type = T.BYTE},        
                {name = "money6",type = T.INT64},

                {name = "seatId7",type = T.BYTE},        
                {name = "money7",type = T.INT64},

                -- {  
                --     name = "players", type = T.ARRAY,
                --     lengthType = T.BYTE,
                --     fmt = {
                --         {name = "seatId",type = T.BYTE},        
                --         {name = "money",type = T.INT64}         
                --     }
                -- }
            }
        }
    },
    callback = "SVR_GAME_OVER_QIUQIU"
}

SERVER[P.SVR_KICK_OUT_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}
    },
    callback = "SVR_KICK_OUT_QIUQIU"
}

SERVER[P.SVR_LOGOUT_ROOM_OK_QIUQIU] = {
    ver = 1,
    fmt = {
        {name = "money", type = T.INT64}
    },
    callback = "SVR_LOGOUT_ROOM_OK_QIUQIU"
}

SERVER[P.SVR_BOARDCAST_CONFIRM_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId",type = T.BYTE}
    },
    callback = "SVR_BOARDCAST_CONFIRM_CARD"
}

-----------------------99玩法 end--------------------------------

SERVER[P.SVR_ROOM_STATUS_GET] = {
    ver = 1,
    fmt = {
        {name = "roomPlayType", type = T.BYTE}
    },
    callback = "SVR_ROOM_STATUS_GET"
}


return SocketConfig


