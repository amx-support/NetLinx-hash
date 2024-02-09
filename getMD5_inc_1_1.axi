//=================================================================================================
//
//	MD5 Hash Generator
//
//	2023/02/20 1.1	FIX: Padding
//	2011/02/24 1.0
//
//=================================================================================================

#IF_NOT_DEFINED __GET_MD5__
#DEFINE __GET_MD5__

//=================================================================================================
PROGRAM_NAME='getMD5_inc'

DEFINE_CONSTANT

MD5_INIT_A	= $67452301
MD5_INIT_B	= $efcdab89
MD5_INIT_C	= $98badcfe
MD5_INIT_D	= $10325476

MD5_MESSAGE_LENGTH_MAX	= (1015)			// (1024 - 9) MAX 65526
MD5_DATA_LENGTH_MAX	= (MD5_MESSAGE_LENGTH_MAX + 9)

//=================================================================================================
DEFINE_VARIABLE

// 4294967296 * fabs(sin(i))
CONSTANT long md5DataT[64] = {	3614090360, 3905402710,  606105819, 3250441966, 4118548399, 1200080426, 2821735955, 4249261313,
				1770035416, 2336552879, 4294925233, 2304563134, 1804603682, 4254626195, 2792965006, 1236535329,
				4129170786, 3225465664,  643717713, 3921069994, 3593408605,   38016083, 3634488961, 3889429448,
				568446438, 3275163606, 4107603335, 1163531501, 2850285829, 4243563512, 1735328473, 2368359562,
				4294588738, 2272392833, 1839030562, 4259657740, 2763975236, 1272893353, 4139469664, 3200236656,
				681279174, 3936430074, 3572445317,   76029189, 3654602809, 3873151461,  530742520, 3299628645,
				4096336452, 1126891415, 2878612391, 4237533241, 1700485571, 2399980690, 4293915773, 2240044497,
				1873313359, 4264355552, 2734768916, 1309151649, 4149444226, 3174756917,  718787259, 3951481745
			    }

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION char[32] getMD5(char strDATA[])	// getMDL
{
    STACK_VAR char strSRC[MD5_DATA_LENGTH_MAX]
    
    // Message Length Check
    IF (LENGTH_STRING(strDATA) >= MD5_MESSAGE_LENGTH_MAX)
    {
	RETURN '[ERROR]'
    }    
    
    // Set Original Message
    strSRC = strDATA
    
    // Padding Message
    MD5_paddingMessage(strSRC)
    //SEND_STRING vdvMD5,strSRC		// DEBUG
    
    // Create MD5
    RETURN createMD5(strSRC)
}

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION MD5_paddingMessage(char strDATA[])
{
    STACK_VAR integer nLength
    STACK_VAR integer nPaddingLength
    STACK_VAR long lMessageBits
    
    // Message Length Check & Bit Length Check
    nLength = LENGTH_STRING(strDATA)
    lMessageBits = nLength * 8
    
    // Padding EndChar & BitSize
    nLength++
    strDATA[nLength] = $80	// End Char
    nLength = nLength + 8	// Bit Size
    
    // Padding 0x00......
    nPaddingLength = nLength % 64
    IF (nPaddingLength > 0) nLength = nLength + (64 - nPaddingLength)

    strData[nLength - 7] = TYPE_CAST((lMessageBits & $000000FF) >> 0)
    strData[nLength - 6] = TYPE_CAST((lMessageBits & $0000FF00) >> 8)
    strData[nLength - 5] = TYPE_CAST((lMessageBits & $00FF0000) >> 16)
    strData[nLength - 4] = TYPE_CAST((lMessageBits & $FF000000) >> 24)
//  strData[nLength - 3] = TYPE_CAST((lMessageBits & $000000FF00000000) >> 32)
//  strData[nLength - 2] = TYPE_CAST((lMessageBits & $0000FF0000000000) >> 40)
//  strData[nLength - 1] = TYPE_CAST((lMessageBits & $00FF000000000000) >> 48)
//  strData[nLength - 0] = TYPE_CAST((lMessageBits & $FF00000000000000) >> 56)
    
    SET_LENGTH_STRING(strDATA,nLength)
}

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION char[32] createMD5(char strDATA[])
{
    STACK_VAR char strBuf[64]
    STACK_VAR long X[16]
    STACK_VAR long lBuf[4],lBuf2[4],lBuf3[4]
    STACK_VAR integer nBlockNum
    STACK_VAR integer i,j,nLoopBlock
    
    nBlockNum = LENGTH_STRING(strDATA) / 64
    
    lBuf[1] = MD5_INIT_A
    lBuf[2] = MD5_INIT_B
    lBuf[3] = MD5_INIT_C
    lBuf[4] = MD5_INIT_D
    
    FOR(nLoopBlock=0;nLoopBlock<nBlockNum;nLoopBlock++)
    {
	strBuf = MID_STRING(strDATA,(nLoopBlock*64)+1,64)
    
	FOR(i=1;i<=16;i++)
	{
	    FOR(j=1;j<=4;j++) lBuf3[j] = GET_BUFFER_CHAR(strBuf)
	    
	    X[i] = (lBuf3[4] << 24) + (lBuf3[3] << 16) + (lBuf3[2] << 8) + lBuf3[1]
	}
	
	lBuf2[1] = lBuf[1]
	lBuf2[2] = lBuf[2]
	lBuf2[3] = lBuf[3]
	lBuf2[4] = lBuf[4]
	
	// 1 ~ 16
	MD5_FF(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[ 1],  7, md5DataT[ 1])
	MD5_FF(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[ 2], 12, md5DataT[ 2])
	MD5_FF(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[ 3], 17, md5DataT[ 3])
	MD5_FF(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[ 4], 22, md5DataT[ 4])
	MD5_FF(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[ 5],  7, md5DataT[ 5])
	MD5_FF(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[ 6], 12, md5DataT[ 6])
	MD5_FF(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[ 7], 17, md5DataT[ 7])
	MD5_FF(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[ 8], 22, md5DataT[ 8])
	MD5_FF(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[ 9],  7, md5DataT[ 9])
	MD5_FF(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[10], 12, md5DataT[10])
	MD5_FF(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[11], 17, md5DataT[11])
	MD5_FF(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[12], 22, md5DataT[12])
	MD5_FF(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[13],  7, md5DataT[13])
	MD5_FF(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[14], 12, md5DataT[14])
	MD5_FF(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[15], 17, md5DataT[15])
	MD5_FF(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[16], 22, md5DataT[16])
	
	//17-32
	MD5_GG(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[ 2],  5, md5DataT[17])
	MD5_GG(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[ 7],  9, md5DataT[18])
	MD5_GG(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[12], 14, md5DataT[19])
	MD5_GG(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[ 1], 20, md5DataT[20])
	MD5_GG(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[ 6],  5, md5DataT[21])
	MD5_GG(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[11],  9, md5DataT[22])
	MD5_GG(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[16], 14, md5DataT[23])
	MD5_GG(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[ 5], 20, md5DataT[24])
	MD5_GG(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[10],  5, md5DataT[25])
	MD5_GG(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[15],  9, md5DataT[26])
	MD5_GG(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[ 4], 14, md5DataT[27])
	MD5_GG(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[ 9], 20, md5DataT[28])
	MD5_GG(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[14],  5, md5DataT[29])
	MD5_GG(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[ 3],  9, md5DataT[30])
	MD5_GG(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[ 8], 14, md5DataT[31])
	MD5_GG(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[13], 20, md5DataT[32])
	
	//32-48
	MD5_HH(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[ 6],  4, md5DataT[33])
	MD5_HH(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[ 9], 11, md5DataT[34])
	MD5_HH(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[12], 16, md5DataT[35])
	MD5_HH(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[15], 23, md5DataT[36])
	MD5_HH(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[ 2],  4, md5DataT[37])
	MD5_HH(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[ 5], 11, md5DataT[38])
	MD5_HH(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[ 8], 16, md5DataT[39])
	MD5_HH(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[11], 23, md5DataT[40])
	MD5_HH(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[14],  4, md5DataT[41])
	MD5_HH(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[ 1], 11, md5DataT[42])
	MD5_HH(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[ 4], 16, md5DataT[43])
	MD5_HH(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[ 7], 23, md5DataT[44])
	MD5_HH(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[10],  4, md5DataT[45])
	MD5_HH(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[13], 11, md5DataT[46])
	MD5_HH(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[16], 16, md5DataT[47])
	MD5_HH(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[ 3], 23, md5DataT[48])
	
	//48-64
	MD5_II(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[ 1],  6, md5DataT[49])
	MD5_II(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[ 8], 10, md5DataT[50])
	MD5_II(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[15], 15, md5DataT[51])
	MD5_II(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[ 6], 21, md5DataT[52])
	MD5_II(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[13],  6, md5DataT[53])
	MD5_II(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[ 4], 10, md5DataT[54])
	MD5_II(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[11], 15, md5DataT[55])
	MD5_II(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[ 2], 21, md5DataT[56])
	MD5_II(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[ 9],  6, md5DataT[57])
	MD5_II(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[16], 10, md5DataT[58])
	MD5_II(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[ 7], 15, md5DataT[59])
	MD5_II(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[14], 21, md5DataT[60])
	MD5_II(lBuf[1], lBuf[2], lBuf[3], lBuf[4], X[ 5],  6, md5DataT[61])
	MD5_II(lBuf[4], lBuf[1], lBuf[2], lBuf[3], X[12], 10, md5DataT[62])
	MD5_II(lBuf[3], lBuf[4], lBuf[1], lBuf[2], X[ 3], 15, md5DataT[63])
	MD5_II(lBuf[2], lBuf[3], lBuf[4], lBuf[1], X[10], 21, md5DataT[64])
	
	lBuf[1] = lBuf[1] + lBuf2[1]
	lBuf[2] = lBuf[2] + lBuf2[2]
	lBuf[3] = lBuf[3] + lBuf2[3]
	lBuf[4] = lBuf[4] + lBuf2[4]
    }
    
    RETURN outputMD5(lBuf)
}

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION char[32] outputMD5(long lDATA[4])
{
    STACK_VAR strMD5[16][2]
    
    strMD5[ 1] = FORMAT('%02x',(lDATA[1] & $000000FF) >> 0)
    strMD5[ 2] = FORMAT('%02x',(lDATA[1] & $0000FF00) >> 8)
    strMD5[ 3] = FORMAT('%02x',(lDATA[1] & $00FF0000) >> 16)
    strMD5[ 4] = FORMAT('%02x',(lDATA[1] & $FF000000) >> 24)
    strMD5[ 5] = FORMAT('%02x',(lDATA[2] & $000000FF) >> 0)
    strMD5[ 6] = FORMAT('%02x',(lDATA[2] & $0000FF00) >> 8)
    strMD5[ 7] = FORMAT('%02x',(lDATA[2] & $00FF0000) >> 16)
    strMD5[ 8] = FORMAT('%02x',(lDATA[2] & $FF000000) >> 24)
    strMD5[ 9] = FORMAT('%02x',(lDATA[3] & $000000FF) >> 0)
    strMD5[10] = FORMAT('%02x',(lDATA[3] & $0000FF00) >> 8)
    strMD5[11] = FORMAT('%02x',(lDATA[3] & $00FF0000) >> 16)
    strMD5[12] = FORMAT('%02x',(lDATA[3] & $FF000000) >> 24)
    strMD5[13] = FORMAT('%02x',(lDATA[4] & $000000FF) >> 0)
    strMD5[14] = FORMAT('%02x',(lDATA[4] & $0000FF00) >> 8)
    strMD5[15] = FORMAT('%02x',(lDATA[4] & $00FF0000) >> 16)
    strMD5[16] = FORMAT('%02x',(lDATA[4] & $FF000000) >> 24)

    RETURN "strMD5[ 1],strMD5[ 2],strMD5[ 3],strMD5[ 4],strMD5[ 5],strMD5[ 6],strMD5[ 7],strMD5[ 8],
	    strMD5[ 9],strMD5[10],strMD5[11],strMD5[12],strMD5[13],strMD5[14],strMD5[15],strMD5[16]"
}


// Operate Function -------------------------------------------------------------------------------
DEFINE_FUNCTION long MD5_rotateLSHIFT(long x, long n)
{
    RETURN (x << n) | (x >> (32 - n)) 
}
DEFINE_FUNCTION long MD5_F(long x, long y, long z)
{
    RETURN ((x) & (y)) | ((~x) & (z))
}
DEFINE_FUNCTION MD5_FF(long a, long b, long c, long d, long x, long s, long ac)
{
    a = a + MD5_F(b,c,d) + x + ac
    a = MD5_rotateLSHIFT(a,s)
    a = a + b
}
DEFINE_FUNCTION long MD5_G(long x, long y, long z)
{
    RETURN ((x) & (z)) | ((y) & (~z))
}
DEFINE_FUNCTION MD5_GG(long a, long b, long c, long d, long x, long s, long ac)
{
    a = a + MD5_G(b,c,d) + x + ac
    a = MD5_rotateLSHIFT(a,s)
    a = a + b
}
DEFINE_FUNCTION long MD5_H(long x, long y, long z)
{
    RETURN (x) ^ (y) ^ (z)
}
DEFINE_FUNCTION MD5_HH(long a, long b, long c, long d, long x, long s, long ac)
{
    a = a + MD5_H(b,c,d) + x + ac
    a = MD5_rotateLSHIFT(a,s)
    a = a + b
}
DEFINE_FUNCTION long MD5_I(long x, long y, long z)
{
    RETURN (y) ^ ((x) | (~z))
}
DEFINE_FUNCTION MD5_II(long a, long b, long c, long d, long x, long s, long ac)
{
    a = a + MD5_I(b,c,d) + x + ac
    a = MD5_rotateLSHIFT(a,s)
    a = a + b
}


#END_IF