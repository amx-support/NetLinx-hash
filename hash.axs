PROGRAM_NAME='hash'
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/05/2006  AT: 09:00:25        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)

INCLUDE 'getMD5_inc_1_1.AXI'
INCLUDE 'getSHA256_inc_1_0.AXI'
INCLUDE 'getBASE64_inc_1_2.AXI'

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvTP	= 10001:1:0

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE char strMD5[32]
VOLATILE char strSHA256[64]
VOLATILE char strBASE64Encode[8192]
VOLATILE char strBASE64Decode[1024]

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT [dvTP]
{
    STRING:
    {
	IF (FIND_STRING(DATA.TEXT,'AKB-',1))
	{
	    REMOVE_STRING(DATA.TEXT,'AKB-',1)
	    
	    strMD5 = getMD5(DATA.TEXT)
	    strSHA256 = getSHA256(DATA.TEXT)
	    strBASE64Encode = encodeBASE64(DATA.TEXT)
	    strBASE64Decode = decodeBASE64(DATA.TEXT)
	    
	    SEND_COMMAND dvTP,"'^UTF-11,0,',DATA.TEXT"
	    SEND_COMMAND dvTP,"'^TXT-1,0,',strMD5"
	    SEND_COMMAND dvTP,"'^TXT-2,0,',strSHA256"
	    SEND_COMMAND dvTP,"'^TXT-3,0,',strBASE64Encode"
	    SEND_COMMAND dvTP,"'^TXT-4,0,',strBASE64Decode"
	}
    }
}

BUTTON_EVENT [dvTP,11]
{
    PUSH:
    {
	TO[BUTTON.INPUT]
	
	SEND_COMMAND dvTP,'^AKB'
    }
}


(*****************************************************************)
(*                                                               *)
(*                      !!!! WARNING !!!!                        *)
(*                                                               *)
(* Due to differences in the underlying architecture of the      *)
(* X-Series masters, changing variables in the DEFINE_PROGRAM    *)
(* section of code can negatively impact program performance.    *)
(*                                                               *)
(* See “Differences in DEFINE_PROGRAM Program Execution” section *)
(* of the NX-Series Controllers WebConsole & Programming Guide   *)
(* for additional and alternate coding methodologies.            *)
(*****************************************************************)

DEFINE_PROGRAM

(*****************************************************************)
(*                       END OF PROGRAM                          *)
(*                                                               *)
(*         !!!  DO NOT PUT ANY CODE BELOW THIS COMMENT  !!!      *)
(*                                                               *)
(*****************************************************************)


