//=================================================================================================
//
//	CRC32 Hash Generator
//
//	2024/11/29 1.0
//
//=================================================================================================

#IF_NOT_DEFINED __GET_CRC32__
#DEFINE __GET_CRC32__

//=================================================================================================
PROGRAM_NAME='getCRC32_inc'

DEFINE_CONSTANT

//=================================================================================================
DEFINE_VARIABLE

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION char[8] getCRC32(char strDATA[])
{
    STACK_VAR long	lCRC
    STACK_VAR integer	i,j
    STACK_VAR integer	nLength
    STACK_VAR integer	lData
    STACK_VAR char	strRet[8]
    
    nLength = LENGTH_ARRAY(strDATA)
    
    lCRC = $FFFFFFFF
    
    FOR(i=1;i<=nLength;i++)
    {
	lData = TYPE_CAST(strDATA[i])
	lCRC = lCRC ^ (lData << 24)
	
	FOR(j=0;j<8;j++)
	{
	    IF ((lCRC & $80000000) <> 0) lCRC = (lCRC << 1) ^ $04C11DB7
	    ELSE lCRC = (lCRC << 1)
	}
    }
    
    LCRC = $FFFFFFFF ^ lCRC
    
    strRet = "FORMAT('%02x',lCRC & $FF),FORMAT('%02x',(lCRC & $FF00) >> 8),FORMAT('%02x',(lCRC & $FF0000) >> 16),FORMAT('%02x',(lCRC & $FF000000) >> 24)"
    
    RETURN strRet
}

DEFINE_FUNCTION char[8] getCRC32B(char strDATA[])
{
    STACK_VAR long	lCRC
    STACK_VAR integer	i,j
    STACK_VAR integer	nLength
    STACK_VAR integer	lData
    STACK_VAR char	strRet[8]
    
    nLength = LENGTH_ARRAY(strDATA)
    
    lCRC = $FFFFFFFF
    
    FOR(i=1;i<=nLength;i++)
    {
	lData = TYPE_CAST(strDATA[i])
	lCRC = lCRC ^ lData
	
	FOR(j=0;j<8;j++)
	{
	    IF ((lCRC & $1) <> 0) lCRC = (lCRC >> 1) ^ $EDB88320
	    ELSE lCRC = lCRC >> 1
	}
    }
    
    lCRC = $FFFFFFFF ^ lCRC
    
    strRet = FORMAT('%08x',lCRC)
    
    RETURN strRet
}

/*
var crc uint32 = 0xffffffff
	for _, c := range in {
		crc = crc ^ (uint32)(c)
		for i := 0; i < 8; i++ {
			if crc & 0x1 != 0 {
				crc = (crc >> 1) ^ 0xEDB88320
			} else {
				crc = (crc >> 1)
			}
		}Å@
	}
	return 0xffffffff ^ crc

*/



#END_IF