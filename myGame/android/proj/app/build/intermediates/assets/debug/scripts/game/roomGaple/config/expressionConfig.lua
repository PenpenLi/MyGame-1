--
-- Author: tony
-- Date: 2014-08-08 10:39:19
--

local ExpressionConfig = class()

function ExpressionConfig:ctor()
    self.config_ = {}

    local d3 = 1 / 3
    self:addConfig_(1,    2,    -5,    0)
    self:addConfig_(2,    2,    4,    8)
    self:addConfig_(3,    2,    10,    6)
    self:addConfig_(4,    2,    -5,    8)
    self:addConfig_(5,    4,    6,    6)
    self:addConfig_(6,    2,    0,    4)
    self:addConfig_(7,    3,    0,    2)
    self:addConfig_(8,    3,    0,    2)
    self:addConfig_(9,    3,    0,    4)
    self:addConfig_(10,    4,    0,    6)
    self:addConfig_(11,    2,    8,    0)
    self:addConfig_(12,    2,    0,    0)
    self:addConfig_(13,    2,    2,    6)
    self:addConfig_(14,    4,    -4,    4)
    self:addConfig_(15,    2,    1,    2)
    self:addConfig_(16,    2,    1,    4)
    self:addConfig_(17,    2,    1,    10)
    self:addConfig_(18,    2,    11,    10)
    self:addConfig_(19,    2,    -2,    6)
    self:addConfig_(20,    2,    14,    4)
    self:addConfig_(22,    2,    6,    0)
    self:addConfig_(21,    2,    4,    4)
    self:addConfig_(23,    11,    0,    0)
    self:addConfig_(24,    4,    0,    0)
    self:addConfig_(25,    2,    0,    0)
    self:addConfig_(26,    2,    12,    2)
    self:addConfig_(27,    3,    0,    0)

    self:addConfig_(101,    14,    0,    0)
    self:addConfig_(102,    4,    0,    0)
    self:addConfig_(103,    2,    0,    0)
    self:addConfig_(104,    7,    0,    0)
    self:addConfig_(105,    14,    0,    0)
    self:addConfig_(106,    4,    0,    0)
    self:addConfig_(107,    10,    0,    0)
    self:addConfig_(108,    10,    0,    0)
    self:addConfig_(109,    12,    0,    0)
    self:addConfig_(110,    12,    0,    0)
    self:addConfig_(111,    14,    0,    0)
    self:addConfig_(112,    17,    0,    0)
    self:addConfig_(113,    12,    0,    0)
    self:addConfig_(114,    4,    0,    0)
    self:addConfig_(115,    7,    0,    0)
    self:addConfig_(116,    13,    0,    0)
    self:addConfig_(117,    4,    0,    0)
    self:addConfig_(118,    4,    0,    0)

    self:addConfig_(201,    10,    0,    0)
    self:addConfig_(202,    10,    0,    0)
    self:addConfig_(203,    10,    0,    0)
    self:addConfig_(204,    10,    0,    0)
    self:addConfig_(205,    19,    0,    0)
    self:addConfig_(206,    10,    0,    0)
    self:addConfig_(207,    10,    0,    0)
    self:addConfig_(208,    10,    0,    0)
    self:addConfig_(209,    8,    0,    0)
    self:addConfig_(210,    10,    0,    0)
end

local ExpressionToSign = {
    [1] = "( $$ _ $$ )",
    [2] = "((❤.❤))",
    [3] = "( $ _ $ )",
    [4] = "( ^___^ )Y",
    [5] = "((Y(^_ ^)Y))",
    [6] = "(．Q．)",
    [7] = "((^_ ^))",
    [8] = "(((m -_-)m",
    [9] = "(((>_ ^)Y))",
    [10] = "(^_^)∠※",
    [11] = "(′▽′)Ψ",
    [12] = "ㄟ(‧‧) (‧‧)ㄟ",
    [13] = "( >O< )",
    [14] = "p( ^ O ^ )q",
    [15] = "(((m -_-)m!!!",
    [16] = "hi",
    [17] = "((o(^_ ^)o))",
    [18] = "OK",
    [19] = "Thanks!",
    [20] = "Go Go Go!",
    [21] = "Bye！",
    [22] = "(⊙o⊙)!!!",
    [23] = "^_^|||",
    [24] = "(*^＠^*)",
    [25] = "(dx___xb)",
    [26] = "( -___- )b",
    [27] = "⊙﹏⊙‖∣°",


    [101] = "HI！",
    [102] = "(○^～^○)",
    [103] = "(☆＿☆)",
    [104] = "(*@ο@*)",
    [105] = "(⊙o⊙)",
    [106] = "(x___x)",
    [107] = "(>＿<)}}",
    [108] = "?o?",
    [109] = "@_@",
    [110] = "(*^‧^*)",
    [111] = "(❤^‧^❤)",
    [112] = "‘（*∩_∩*）′",
    [113] = "(b_d)",
    [114] = "*@_@*",
    [115] = "(^_^)∠※∠※",
    [116] = "@_@||||",
    [117] = "(*^﹏^*)",
    [118] = "╭( T □ T )╮",

    [201] = "Waow!!",
    [202] = "Hebat lol",
    [203] = "Jadi malu",
    [204] = "Tenang  saja~",
    [205] = "Segitu doang?",
    [206] = "Tidaaak!",
    [207] = "Kasian dehlo~",
    [208] = "Sudah kuduga",
    [209] = "Tampar aku mas..",
    [210] = "Aku ga bisa dlginiin",
}

function ExpressionConfig:getSignById(id)
    return ExpressionToSign[id] and ExpressionToSign[id] or "la la la"
end

function ExpressionConfig:getIdBySign(sign)
    local id = 1
    if sign then
        for i, v in pairs(ExpressionToSign) do
            if tostring(v) == tostring(sign) then
                id = i
            end
        end
    end
    return id
end

function ExpressionConfig:getConfig(id)
    return self.config_[id]
end

function ExpressionConfig:addConfig_(id, frameNum, adjustX, adjustY)
    local config = {}
    config.id = id
    config.frameNum = frameNum
    config.adjustX = adjustX
    config.adjustY = adjustY
    self.config_[id] = config
end

return ExpressionConfig