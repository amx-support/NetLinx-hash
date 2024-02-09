//=================================================================================================
//
//	BASE64 Encode / Decode
//
//	2023/09/01 1.2  Add Decode
//	2023/02/22 1.1	MessageLength 32 -> 1024
//	2011/08/04 1.0	
//
//=================================================================================================

#IF_NOT_DEFINED __GET_BASE256__
#DEFINE __GET_BASE256__

//=================================================================================================
PROGRAM_NAME='getBASE64_inc'

//=================================================================================================
DEFINE_CONSTANT

BASE64_MESSAGE_LENGTH_MAX	= (1024)
BASE64_BINARY_LENGTH_MAX	= (8192)	// 1024 * 8
BASE64_DATA_LENGTH_MAX		= (1440)


//=================================================================================================
DEFINE_VARIABLE

CONSTANT char BASE64strBase64Encode[64] = {	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
						'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
						'0','1','2','3','4','5','6','7','8','9','+','/'}


//=================================================================================================

DEFINE_FUNCTION char[BASE64_DATA_LENGTH_MAX] getBase64(char strTEXT[BASE64_MESSAGE_LENGTH_MAX])
{
    STACK_VAR char	strEncode[BASE64_DATA_LENGTH_MAX]
    STACK_VAR char	strBinary[BASE64_BINARY_LENGTH_MAX]
    STACK_VAR char	strBinaryDiv[6]
    STACK_VAR integer	nBase64Code
    STACK_VAR integer	nLength
    STACK_VAR integer	nLoc
    
    // strText -> Binary Text
    strBinary = BASE64_getBinaryText(strText)
    
    // Div 6bit & Get Base64 1Char
    nLoc = 0
    CLEAR_BUFFER strEncode
    
    WHILE(1)
    {
	nLength = LENGTH_STRING(strBinary)
	
	nLoc++
	
	SELECT
	{
	    ACTIVE(nLength >= 6):
	    {
		strBinaryDiv = GET_BUFFER_STRING(strBinary,6)
		nBase64Code = BASE64_BTOI("'00',strBinaryDiv")
		strEncode = "strEncode,BASE64strBase64Encode[nBase64Code+1]"
	    }
	    ACTIVE(nLength == 5):
	    {
		strBinaryDiv = "strBinary,'0'"
		nBase64Code = BASE64_BTOI("'00',strBinaryDiv")
		strEncode = "strEncode,BASE64strBase64Encode[nBase64Code+1]"
		
		break
	    }
	    ACTIVE(nLength == 4):
	    {
		strBinaryDiv = "strBinary,'00'"
		nBase64Code = BASE64_BTOI("'00',strBinaryDiv")
		strEncode = "strEncode,BASE64strBase64Encode[nBase64Code+1]"
		
		break
	    }
	    ACTIVE(nLength == 3):
	    {
		strBinaryDiv = "strBinary,'000'"
		nBase64Code = BASE64_BTOI("'00',strBinaryDiv")
		strEncode = "strEncode,BASE64strBase64Encode[nBase64Code+1]"
		
		break
	    }
	    ACTIVE(nLength == 2):
	    {
		strBinaryDiv = "strBinary,'0000'"
		nBase64Code = BASE64_BTOI("'00',strBinaryDiv")
		strEncode = "strEncode,BASE64strBase64Encode[nBase64Code+1]"
		
		break
	    }
	    ACTIVE(nLength == 1):
	    {
		strBinaryDiv = "strBinary,'00000'"
		nBase64Code = BASE64_BTOI("'00',strBinaryDiv")
		strEncode = "strEncode,BASE64strBase64Encode[nBase64Code+1]"
		
		break
	    }
	    ACTIVE(1):
	    {
		nLoc--
		break
	    }
	}
    }
    
    // Padding 4 Chars
    SWITCH(nLoc % 4)
    {
	CASE 1:
	{
	    strEncode = "strEncode,'==='"
	    nLoc = nLoc + 3
	}
	CASE 2:
	{
	    strEncode = "strEncode,'=='"
	    nLoc = nLoc + 2
	}
	CASE 3:
	{
	    strEncode = "strEncode,'='"
	    nLoc = nLoc + 1
	}
    }
    
    RETURN strEncode
}

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION char[BASE64_BINARY_LENGTH_MAX] BASE64_getBinaryText(char strTEXT[BASE64_MESSAGE_LENGTH_MAX])
{
    STACK_VAR char	strReturnVal[BASE64_BINARY_LENGTH_MAX]
    STACK_VAR char	strTemp[8]
    STACK_VAR integer	i,nTextLength
    
    nTextLength = LENGTH_STRING(strTEXT)
    
    CLEAR_BUFFER strReturnVal
    
    FOR(i=1;i<=nTextLength;i++)
    {
	strTemp = "	ITOA((strTEXT[i] & $80) >> 7),ITOA((strTEXT[i] & $40) >> 6),ITOA((strTEXT[i] & $20) >> 5),ITOA((strTEXT[i] & $10) >> 4),
			ITOA((strTEXT[i] & $08) >> 3),ITOA((strTEXT[i] & $04) >> 2),ITOA((strTEXT[i] & $02) >> 1),ITOA((strTEXT[i] & $01))"
	
	strReturnVal = "strReturnVal,strTemp"
    }
    
    RETURN strReturnVal
}

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION char[BASE64_DATA_LENGTH_MAX] encodeBase64(char strTEXT[BASE64_MESSAGE_LENGTH_MAX])
{
    RETURN getBase64(strTEXT)
}

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION char[BASE64_MESSAGE_LENGTH_MAX] decodeBase64(char strTEXT[BASE64_DATA_LENGTH_MAX])
{
    STACK_VAR char	strDecode[BASE64_MESSAGE_LENGTH_MAX]
    STACK_VAR integer	nDataLength
    STACK_VAR long	lData
    STACK_VAR char	cData
    STACK_VAR integer	nCount
    STACK_VAR integer	i,j
    
    nCount = 0
    lData = 0
    
    nDataLength = LENGTH_STRING(strTEXT)
    
    FOR(i=1;i<=nDataLength;i++)
    {
	IF (strTEXT[i] <> '=')
	{
	    cData = 0
	    FOR(j=1;j<=64;j++)
	    {
		IF (strTEXT[i] == BASE64strBase64Encode[j])
		{
		    cData = TYPE_CAST(j - 1)
		    BREAK
		}
	    }
	    lData = (lData << 6) + cData
	    nCount++
	}
	ELSE
	{
	    SWITCH(nCount)
	    {
		CASE 2:
		{
		    lData = lData << 12
		    strDecode = "strDecode,(lData & $00FF0000) >> 16"
		}
		CASE 3:
		{
		    lData = lData << 6
		    strDecode = "strDecode,(lData & $00FF0000) >> 16,(lData & $0000FF00) >> 8"
		}
	    }
	    BREAK
	}
	
	IF (nCount >= 4)
	{
	    strDecode = "strDecode,(lData & $00FF0000) >> 16,(lData & $0000FF00) >> 8,lData & $000000FF"
	    
	    nCount = 0
	    lData = 0
	}
    }
    
    RETURN strDecode
}

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION integer BASE64_BTOI(char strBinary[8])
{
    STACK_VAR integer nReturnVal
    
    nReturnVal = 0
    
    IF ("strBinary[1]" == '1') nReturnVal = nReturnVal + $80
    IF ("strBinary[2]" == '1') nReturnVal = nReturnVal + $40
    IF ("strBinary[3]" == '1') nReturnVal = nReturnVal + $20
    IF ("strBinary[4]" == '1') nReturnVal = nReturnVal + $10
    IF ("strBinary[5]" == '1') nReturnVal = nReturnVal + $08
    IF ("strBinary[6]" == '1') nReturnVal = nReturnVal + $04
    IF ("strBinary[7]" == '1') nReturnVal = nReturnVal + $02
    IF ("strBinary[8]" == '1') nReturnVal = nReturnVal + $01
    
    RETURN nReturnVal
}


#END_IF