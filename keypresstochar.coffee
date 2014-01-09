root = exports ? this

mapKeyPressToActualCharacter = root.mapKeyPressToActualCharacter = (isShiftKey, characterCode) ->
    if ( characterCode == 27 || characterCode == 8 || characterCode == 9 || characterCode == 20 || characterCode == 16 || characterCode == 17 || characterCode == 91 || characterCode == 13 || characterCode == 92 || characterCode == 18 )
        return false
    if (typeof isShiftKey != "boolean" || typeof characterCode != "number")
        return false
    characterMap = {}
    characterMap[192] = "~";
    characterMap[49] = "!";
    characterMap[50] = "@";
    characterMap[51] = "#";
    characterMap[52] = "$";
    characterMap[53] = "%";
    characterMap[54] = "^";
    characterMap[55] = "&";
    characterMap[56] = "*";
    characterMap[57] = "(";
    characterMap[48] = ")";
    characterMap[109] = "_";
    characterMap[107] = "+";
    characterMap[219] = "{";
    characterMap[221] = "}";
    characterMap[220] = "|";
    characterMap[59] = ":";
    characterMap[222] = "\"";
    characterMap[188] = "<";
    characterMap[190] = ">";
    characterMap[191] = "?";
    characterMap[32] = " ";
    
    lcm = {}
    lcm[192] = '`'
    lcm[186] = ';'
    lcm[189] = '-'
    lcm[187] = '='
    lcm[222] = "'"
    lcm[191] = '/'
    lcm[219] = '['
    lcm[221] = ']'
    lcm[220] = '\\'
    lcm[188] = ','
    lcm[190] = '.'
    
    character = ""
    if (isShiftKey)
        if ( characterCode >= 65 && characterCode <= 90 )
            character = String.fromCharCode(characterCode)
        else if characterMap[characterCode]?
            character = characterMap[characterCode]
        else
            character = String.fromCharCode(characterCode)
    else
        if ( characterCode >= 65 && characterCode <= 90 )
            character = String.fromCharCode(characterCode).toLowerCase()
        else if lcm[characterCode]?
            character = lcm[characterCode]
        else
            character = String.fromCharCode(characterCode)
    return character
