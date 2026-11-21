function IndoorActivityBounds(area)
    if area = "bedroom" then return [[6, 6, 244, 244], [6, 6, 244, 244], [6, 6, 244, 244]]
    if area = "playroom" then return [[6, 6, 244, 244], [6, 6, 244, 244], [6, 6, 244, 186]]
    if area = "bonusroom" then return [[6, 6, 244, 244], [6, 6, 244, 244], [6, 6, 244, 244]]
    if area = "parentsroom" then return [[6, 6, 244, 244], [6, 6, 244, 244], [6, 6, 244, 244]]
    return []
end function

function IndoorSittingBounds()
    return [[54, 14, 164, 321], [299, 13, 173, 323], [551, 16, 174, 319], [803, 14, 161, 322]]
end function
