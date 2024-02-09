//=================================================================================================
//
//	SHA-256 Hash Generator
//
//	2023/02/20 1.0	
//
//=================================================================================================

#IF_NOT_DEFINED __GET_SHA256__
#DEFINE __GET_SHA256__

//=================================================================================================
PROGRAM_NAME='getSHA256_inc'

//=================================================================================================
DEFINE_CONSTANT

SHA256_INIT_A = $6a09e667
SHA256_INIT_B = $bb67ae85
SHA256_INIT_C = $3c6ef372
SHA256_INIT_D = $a54ff53a
SHA256_INIT_E = $510e527f
SHA256_INIT_F = $9b05688c
SHA256_INIT_G = $1f83d9ab
SHA256_INIT_H = $5be0cd19

SHA256_MESSAGE_LENGTH_MAX	= (1015)			// 1024 - 9 (MAX 65526)
SHA256_DATA_LENGTH_MAX		= (SHA256_MESSAGE_LENGTH_MAX + 9)	// MESSAGE + EndChar(1Byte) + Length(8Bytes)

//=================================================================================================
DEFINE_VARIABLE

CONSTANT long	sha256DataK[64] = {	$428a2f98, $71374491, $b5c0fbcf, $e9b5dba5, $3956c25b, $59f111f1, $923f82a4, $ab1c5ed5,
					$d807aa98, $12835b01, $243185be, $550c7dc3, $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174,
					$e49b69c1, $efbe4786, $0fc19dc6, $240ca1cc, $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da,
					$983e5152, $a831c66d, $b00327c8, $bf597fc7, $c6e00bf3, $d5a79147, $06ca6351, $14292967,
					$27b70a85, $2e1b2138, $4d2c6dfc, $53380d13, $650a7354, $766a0abb, $81c2c92e, $92722c85,
					$a2bfe8a1, $a81a664b, $c24b8b70, $c76c51a3, $d192e819, $d6990624, $f40e3585, $106aa070,
					$19a4c116, $1e376c08, $2748774c, $34b0bcb5, $391c0cb3, $4ed8aa4a, $5b9cca4f, $682e6ff3,
					$748f82ee, $78a5636f, $84c87814, $8cc70208, $90befffa, $a4506ceb, $bef9a3f7, $c67178f2}

//=================================================================================================

DEFINE_FUNCTION char[64] getSHA256(char strData[])
{
    STACK_VAR char strSRC[SHA256_DATA_LENGTH_MAX]
    
    // Message Length Check
    IF (LENGTH_STRING(strDATA) >= SHA256_MESSAGE_LENGTH_MAX)
    {
	RETURN '[ERROR]'
    }    
    
    // Set Original Message
    strSRC = strDATA
    
    // Padding Message
    SHA256_paddingMessage(strSRC)
    
    // Create SHA256
    RETURN createSHA256(strSRC)
}

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION SHA256_paddingMessage(char strDATA[])
{
    STACK_VAR integer nLength
    STACK_VAR integer nPaddingLength
    STACK_VAR long lMessageBits
    STACK_VAR integer i
    
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
    
//  strData[nLength - 7] = TYPE_CAST((lMessageBits & $FF00000000000000) >> 56)
//  strData[nLength - 6] = TYPE_CAST((lMessageBits & $00FF000000000000) >> 48)
//  strData[nLength - 5] = TYPE_CAST((lMessageBits & $0000FF0000000000) >> 40)
//  strData[nLength - 4] = TYPE_CAST((lMessageBits & $000000FF00000000) >> 32)
    strData[nLength - 3] = TYPE_CAST((lMessageBits & $FF000000) >> 24)
    strData[nLength - 2] = TYPE_CAST((lMessageBits & $00FF0000) >> 16)
    strData[nLength - 1] = TYPE_CAST((lMessageBits & $0000FF00) >> 8)
    strData[nLength - 0] = TYPE_CAST( lMessageBits & $000000FF)
   
    SET_LENGTH_STRING(strDATA,nLength)
}

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION char[64] createSHA256(char strDATA[])
{
    STACK_VAR char strBuf[64]
    STACK_VAR long W[64]
    STACK_VAR long T1,T2
    STACK_VAR long lBuf[8],lBuf2[8],lBuf3[4]
    STACK_VAR integer nBlockNum
    STACK_VAR integer i,j,nLoopBlock
    
    nBlockNum = LENGTH_STRING(strDATA) / 64
    
    lBuf[1] = SHA256_INIT_A
    lBuf[2] = SHA256_INIT_B
    lBuf[3] = SHA256_INIT_C
    lBuf[4] = SHA256_INIT_D
    lBuf[5] = SHA256_INIT_E
    lBuf[6] = SHA256_INIT_F
    lBuf[7] = SHA256_INIT_G
    lBuf[8] = SHA256_INIT_H
    
    FOR(nLoopBlock=0;nLoopBlock<nBlockNum;nLoopBlock++)
    {
	strBuf = MID_STRING(strDATA,(nLoopBlock*64)+1,64)
    
	FOR(i=1;i<=16;i++)
	{
	    FOR(j=1;j<=4;j++) lBuf3[j] = GET_BUFFER_CHAR(strBuf)
	    
	    W[i] = (lBuf3[1] << 24) | (lBuf3[2] << 16) | (lBuf3[3] << 8) | lBuf3[4]
	}
	FOR(i=17;i<=64;i++)
	{
	    W[i] = SHA256_LSIGMA1(W[i-2]) + W[i-7] + SHA256_LSIGMA0(W[i-15]) + W[i-16]
	    
	}
	
	lBuf2[1] = lBuf[1]
	lBuf2[2] = lBuf[2]
	lBuf2[3] = lBuf[3]
	lBuf2[4] = lBuf[4]
	lBuf2[5] = lBuf[5]
	lBuf2[6] = lBuf[6]
	lBuf2[7] = lBuf[7]
	lBuf2[8] = lBuf[8]
	
	FOR(i=1;i<=64;i++)
	{
	    T1 = lBuf2[8] + SHA256_USIGMA1(lBuf2[5]) + SHA256_Ch(lBuf2[5],lBuf2[6],lBuf2[7]) + sha256DataK[i] + W[i]
	    T2 = SHA256_USIGMA0(lBuf2[1]) + SHA256_Maj(lBuf2[1],lBuf2[2],lBuf2[3])
	    
	    lBuf2[8] = lBuf2[7]
	    lBuf2[7] = lBuf2[6]
	    lBuf2[6] = lBuf2[5]
	    lBuf2[5] = lBuf2[4] + T1
	    lBuf2[4] = lBuf2[3]
	    lBuf2[3] = lBuf2[2]
	    lBuf2[2] = lBuf2[1]
	    lBuf2[1] = T1 + T2
	}
	
	lBuf[1] = lBuf2[1] + lBuf[1]
	lBuf[2] = lBuf2[2] + lBuf[2]
	lBuf[3] = lBuf2[3] + lBuf[3]
	lBuf[4] = lBuf2[4] + lBuf[4]
	lBuf[5] = lBuf2[5] + lBuf[5]
	lBuf[6] = lBuf2[6] + lBuf[6]
	lBuf[7] = lBuf2[7] + lBuf[7]
	lBuf[8] = lBuf2[8] + lBuf[8]
    }
    
    RETURN outputSHA256(lBuf)
}

//-------------------------------------------------------------------------------------------------
DEFINE_FUNCTION char[64] outputSHA256(long lDATA[8])
{
    STACK_VAR strSHA256[32][2]
    
    strSHA256[ 1] = FORMAT('%02x',(lDATA[1] & $FF000000) >> 24)
    strSHA256[ 2] = FORMAT('%02x',(lDATA[1] & $00FF0000) >> 16)
    strSHA256[ 3] = FORMAT('%02x',(lDATA[1] & $0000FF00) >> 8)
    strSHA256[ 4] = FORMAT('%02x',(lDATA[1] & $000000FF) >> 0)
    strSHA256[ 5] = FORMAT('%02x',(lDATA[2] & $FF000000) >> 24)
    strSHA256[ 6] = FORMAT('%02x',(lDATA[2] & $00FF0000) >> 16)
    strSHA256[ 7] = FORMAT('%02x',(lDATA[2] & $0000FF00) >> 8)
    strSHA256[ 8] = FORMAT('%02x',(lDATA[2] & $000000FF) >> 0)
    strSHA256[ 9] = FORMAT('%02x',(lDATA[3] & $FF000000) >> 24)
    strSHA256[10] = FORMAT('%02x',(lDATA[3] & $00FF0000) >> 16)
    strSHA256[11] = FORMAT('%02x',(lDATA[3] & $0000FF00) >> 8)
    strSHA256[12] = FORMAT('%02x',(lDATA[3] & $000000FF) >> 0)
    strSHA256[13] = FORMAT('%02x',(lDATA[4] & $FF000000) >> 24)
    strSHA256[14] = FORMAT('%02x',(lDATA[4] & $00FF0000) >> 16)
    strSHA256[15] = FORMAT('%02x',(lDATA[4] & $0000FF00) >> 8)
    strSHA256[16] = FORMAT('%02x',(lDATA[4] & $000000FF) >> 0)
    strSHA256[17] = FORMAT('%02x',(lDATA[5] & $FF000000) >> 24)
    strSHA256[18] = FORMAT('%02x',(lDATA[5] & $00FF0000) >> 16)
    strSHA256[19] = FORMAT('%02x',(lDATA[5] & $0000FF00) >> 8)
    strSHA256[20] = FORMAT('%02x',(lDATA[5] & $000000FF) >> 0)
    strSHA256[21] = FORMAT('%02x',(lDATA[6] & $FF000000) >> 24)
    strSHA256[22] = FORMAT('%02x',(lDATA[6] & $00FF0000) >> 16)
    strSHA256[23] = FORMAT('%02x',(lDATA[6] & $0000FF00) >> 8)
    strSHA256[24] = FORMAT('%02x',(lDATA[6] & $000000FF) >> 0)
    strSHA256[25] = FORMAT('%02x',(lDATA[7] & $FF000000) >> 24)
    strSHA256[26] = FORMAT('%02x',(lDATA[7] & $00FF0000) >> 16)
    strSHA256[27] = FORMAT('%02x',(lDATA[7] & $0000FF00) >> 8)
    strSHA256[28] = FORMAT('%02x',(lDATA[7] & $000000FF) >> 0)
    strSHA256[29] = FORMAT('%02x',(lDATA[8] & $FF000000) >> 24)
    strSHA256[30] = FORMAT('%02x',(lDATA[8] & $00FF0000) >> 16)
    strSHA256[31] = FORMAT('%02x',(lDATA[8] & $0000FF00) >> 8)
    strSHA256[32] = FORMAT('%02x',(lDATA[8] & $000000FF) >> 0)

    RETURN "strSHA256[ 1],strSHA256[ 2],strSHA256[ 3],strSHA256[ 4],strSHA256[ 5],strSHA256[ 6],strSHA256[ 7],strSHA256[ 8],
	    strSHA256[ 9],strSHA256[10],strSHA256[11],strSHA256[12],strSHA256[13],strSHA256[14],strSHA256[15],strSHA256[16],
	    strSHA256[17],strSHA256[18],strSHA256[19],strSHA256[20],strSHA256[21],strSHA256[22],strSHA256[23],strSHA256[24],
	    strSHA256[25],strSHA256[26],strSHA256[27],strSHA256[28],strSHA256[29],strSHA256[30],strSHA256[31],strSHA256[32]"
}

// Operate Function -------------------------------------------------------------------------------
DEFINE_FUNCTION long SHA256_ROTR(long x, long n)
{
    RETURN (x >> n) | (x << (32 - n)) 
}
DEFINE_FUNCTION long SHA256_Ch(long x, long y, long z)
{
    RETURN (x & y) ^ (~x & z)
}
DEFINE_FUNCTION long SHA256_Maj(long x, long y, long z)
{
    RETURN (x & y) ^ (x & z) ^ (y & z)
}
DEFINE_FUNCTION long SHA256_USIGMA0(long x)
{
    RETURN SHA256_ROTR(x,2) ^ SHA256_ROTR(x,13) ^ SHA256_ROTR(x,22)
}
DEFINE_FUNCTION long SHA256_USIGMA1(long x)
{
    RETURN SHA256_ROTR(x,6) ^ SHA256_ROTR(x,11) ^ SHA256_ROTR(x,25)
}
DEFINE_FUNCTION long SHA256_LSIGMA0(long x)
{
    RETURN SHA256_ROTR(x,7) ^ SHA256_ROTR(x,18) ^ (x >> 3)
}
DEFINE_FUNCTION long SHA256_LSIGMA1(long x)
{
    RETURN SHA256_ROTR(x,17) ^ SHA256_ROTR(x,19) ^ (x >> 10)
}


#END_IF