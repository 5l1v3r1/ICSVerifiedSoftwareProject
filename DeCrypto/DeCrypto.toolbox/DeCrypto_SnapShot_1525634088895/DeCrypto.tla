------------------------------ MODULE DeCrypto ------------------------------

LOCAL INSTANCE Sequences
LOCAL INSTANCE Naturals
LOCAL INSTANCE SSWPacket

LOCAL HMACSIZE == 64
LOCAL START == "!" 
LOCAL MINMESSAGESIZE == 65
LOCAL PASSWORD == "lolpassword"
LOCAL SignedMessages == {isSSW,
                        notSSW}
                       
HMAC(str, pass) == <<"l","o","l","h","m","a","c">> \*not concerned with the inner workings of SHA2
CompareHMAC(str1, str2) == CHOOSE x \in BOOLEAN : TRUE \*since we done model SHA2 this is random
SendMessage(str) == TRUE \*sending message to another cell. Assuming this works

(*--fair algorithm DeCrypto

variables   signedMessage \in SignedMessages,
            bareMessage = <<>>,
            flag = FALSE,
            retreivedHMAC = <<>>,
            generatedHMAC = <<>>,
            result = FALSE,
            hmacsMatch = FALSE

begin

msgCheck:   if Len(signedMessage) >= MINMESSAGESIZE
                then if <<Head(signedMessage)>> = <<"!">>
                    then bareMessage := GetMessage(signedMessage);
                         retreivedHMAC := GetHMAC(signedMessage);
                    h1: generatedHMAC := HMAC(bareMessage, PASSWORD);
                    h2: hmacsMatch := CompareHMAC(retreivedHMAC, generatedHMAC);
                    h3: if hmacsMatch
                            then flag := TRUE;
                                 result := SendMessage(bareMessage);
                        end if;
                end if;
            end if;

end algorithm

*)
\* BEGIN TRANSLATION
VARIABLES signedMessage, bareMessage, flag, retreivedHMAC, generatedHMAC, 
          result, hmacsMatch, pc

vars == << signedMessage, bareMessage, flag, retreivedHMAC, generatedHMAC, 
           result, hmacsMatch, pc >>

Init == (* Global variables *)
        /\ signedMessage \in SignedMessages
        /\ bareMessage = <<>>
        /\ flag = FALSE
        /\ retreivedHMAC = <<>>
        /\ generatedHMAC = <<>>
        /\ result = FALSE
        /\ hmacsMatch = FALSE
        /\ pc = "msgCheck"

msgCheck == /\ pc = "msgCheck"
            /\ IF Len(signedMessage) >= MINMESSAGESIZE
                  THEN /\ IF <<Head(signedMessage)>> = <<"!">>
                             THEN /\ bareMessage' = GetMessage(signedMessage)
                                  /\ retreivedHMAC' = GetHMAC(signedMessage)
                                  /\ pc' = "h1"
                             ELSE /\ pc' = "Done"
                                  /\ UNCHANGED << bareMessage, retreivedHMAC >>
                  ELSE /\ pc' = "Done"
                       /\ UNCHANGED << bareMessage, retreivedHMAC >>
            /\ UNCHANGED << signedMessage, flag, generatedHMAC, result, 
                            hmacsMatch >>

h1 == /\ pc = "h1"
      /\ generatedHMAC' = HMAC(bareMessage, PASSWORD)
      /\ pc' = "h2"
      /\ UNCHANGED << signedMessage, bareMessage, flag, retreivedHMAC, result, 
                      hmacsMatch >>

h2 == /\ pc = "h2"
      /\ hmacsMatch' = CompareHMAC(retreivedHMAC, generatedHMAC)
      /\ pc' = "h3"
      /\ UNCHANGED << signedMessage, bareMessage, flag, retreivedHMAC, 
                      generatedHMAC, result >>

h3 == /\ pc = "h3"
      /\ IF hmacsMatch
            THEN /\ flag' = TRUE
                 /\ result' = SendMessage(bareMessage)
            ELSE /\ TRUE
                 /\ UNCHANGED << flag, result >>
      /\ pc' = "Done"
      /\ UNCHANGED << signedMessage, bareMessage, retreivedHMAC, generatedHMAC, 
                      hmacsMatch >>

Next == msgCheck \/ h1 \/ h2 \/ h3
           \/ (* Disjunct to prevent deadlock on termination *)
              (pc = "Done" /\ UNCHANGED vars)

Spec == /\ Init /\ [][Next]_vars
        /\ WF_vars(Next)

Termination == <>(pc = "Done")

\* END TRANSLATION

SAFETYCHECK ==
        \*/\ hmacsMatch \in BOOLEAN
        \*/\ hmacsMatch = FALSE => flag = FALSE
        /\ PASSWORD = "lolpassword"
        /\ Len(signedMessage) < MINMESSAGESIZE => flag = FALSE

LIVELINESS == 
        /\ hmacsMatch = TRUE ~> result = TRUE
=============================================================================
\* Modification History
\* Last modified Sun May 06 15:14:33 EDT 2018 by SabraouM
\* Created Sun May 06 09:03:31 EDT 2018 by SabraouM