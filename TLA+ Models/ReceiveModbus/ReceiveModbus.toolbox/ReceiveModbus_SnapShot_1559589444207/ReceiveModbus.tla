------------------------------ MODULE ReceiveModbus ------------------------------

EXTENDS Sequences,
        Naturals,
        Modbus,
        TLC,
        ASCII
        
LOCAL INSTANCE Hex
    WITH natValue <- 0, hexValue <- <<0>> 

LOCAL Range(T) == { T[x] : x \in DOMAIN T }


MessagesToSerialPort == \*these are in ASCII but they are converted to decimal before being used below. See StrTupleToNumTuple in ASCII.tla
    { StrTupleToNumTuple(<<":","J","G","P","9","4","3","2","J","3","9","J","G","W","I","R","W">>),
      StrTupleToNumTuple(<<":","1","1","0","3","0","0","6","B","0","0","0","3","7","E","\r","\n">>),
      StrTupleToNumTuple(<<":","1","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","1","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","R","L","1","0","3","0","0","6","B","0","0","0","3","7","E","C","G","L","F">>),
      StrTupleToNumTuple(<<":","1","1","0","3","0","0","6","B","0","0","0",":","1","1","0","3","0","0","6","B","0","0","0","3","7","E","\r","\n">>), \*this one starts a new modbus packet half way through the message
      <<>>,<<1>>,<<2>>,<<3>>,<<4>>,<<5>>,<<6>>,<<7>>,<<8>>,<<9>>,<<10>>,<<11>>,<<12>>,<<13>>, \* all possible values
      <<14>>,<<15>>,<<16>>,<<17>>,<<18>>,<<19>>,<<20>>,<<21>>,<<22>>,<<23>>,<<24>>,<<25>>,   \*that could come across the serial line
      <<26>>,<<27>>,<<28>>,<<29>>,<<30>>,<<31>>,<<32>>,<<33>>,<<34>>,<<35>>,<<36>>,<<37>>,<<38>>,<<39>>,<<40>>,<<41>>,
      <<42>>,<<43>>,<<44>>,<<45>>,<<46>>,<<47>>,<<48>>,<<49>>,<<50>>,<<51>>,<<52>>,<<53>>,<<54>>,<<55>>,<<56>>,<<57>>,
      <<58>>,<<59>>,<<60>>,<<61>>,<<62>>,<<63>>,<<64>>,<<65>>,<<66>>,<<67>>,<<68>>,<<69>>,<<70>>,<<71>>,<<72>>,<<73>>,
      <<74>>,<<75>>,<<76>>,<<77>>,<<78>>,<<79>>,<<80>>,<<81>>,<<82>>,<<83>>,<<84>>,<<85>>,<<86>>,<<87>>,<<88>>,<<89>>,
      <<90>>,<<91>>,<<92>>,<<93>>,<<94>>,<<95>>,<<96>>,<<97>>,<<98>>,<<99>>,<<100>>,<<101>>,<<102>>,<<103>>,<<104>>,<<105>>,
      <<106>>,<<107>>,<<108>>,<<109>>,<<110>>,<<111>>,<<112>>,<<113>>,<<114>>,<<115>>,<<116>>,<<117>>,<<118>>,<<119>>,<<120>>,<<121>>,
      <<122>>,<<123>>,<<124>>,<<125>>,<<126>>,<<127>>,<<128>>,<<129>>,<<130>>,<<131>>,<<132>>,<<133>>,<<134>>,<<135>>,<<136>>,<<137>>,
      <<138>>,<<139>>,<<140>>,<<141>>,<<142>>,<<143>>,<<144>>,<<145>>,<<146>>,<<147>>,<<148>>,<<149>>,<<150>>,<<151>>,<<152>>,<<153>>,
      <<154>>,<<155>>,<<156>>,<<157>>,<<158>>,<<159>>,<<160>>,<<161>>,<<162>>,<<163>>,<<164>>,<<165>>,<<166>>,<<167>>,<<168>>,<<169>>,
      <<170>>,<<171>>,<<172>>,<<173>>,<<174>>,<<175>>,<<176>>,<<177>>,<<178>>,<<179>>,<<180>>,<<181>>,<<182>>,<<183>>,<<184>>,<<185>>,
      <<186>>,<<187>>,<<188>>,<<189>>,<<190>>,<<191>>,<<192>>,<<193>>,<<194>>,<<195>>,<<196>>,<<197>>,<<198>>,<<199>>,<<200>>,<<201>>,
      <<202>>,<<203>>,<<204>>,<<205>>,<<206>>,<<207>>,<<208>>,<<209>>,<<210>>,<<211>>,<<212>>,<<213>>,<<214>>,<<215>>,<<216>>,<<217>>,
      <<218>>,<<219>>,<<220>>,<<221>>,<<222>>,<<223>>,<<224>>,<<225>>,<<226>>,<<227>>,<<228>>,<<229>>,<<230>>,<<231>>,<<232>>,<<233>>,
      <<234>>,<<235>>,<<236>>,<<237>>,<<238>>,<<239>>,<<240>>,<<241>>,<<242>>,<<243>>,<<244>>,<<245>>,<<246>>,<<247>>,<<248>>,<<249>>,
      <<250>>,<<251>>,<<252>>,<<253>>,<<254>>,<<255>>
      }



(*--fair algorithm ReceiveModbus
\* IPC calls
\*macro send(dest, msg) begin
\*        sentBuffer := sentBuffer \o msg;
\*end macro;

variables   rxBuf = <<>>,
            rx = FALSE,
            rxReg = <<>>,
            incomingMessages \in MessagesToSerialPort,
            incByte = <<>>,
            msg = <<>>,
            msgid = <<>>,
            guid = <<0>>,
            last2 = <<0,0>>,
            sentBuffer = <<>> \*this is what is passed to the application. Only valid modbus here plz
    

    
begin

trustnet_in1:   while Len(incomingMessages) > 0 do
                    if Len(incomingMessages) > 1 then
                        ti1: msg := Head(incomingMessages);                \*pop off message from 
                        ti2: incomingMessages := Tail(incomingMessages);   \*list of test messages
                    else
                        ti3: msg := incomingMessages;
                        ti4: incomingMessages := <<>>;
                    end if;
                start:  while Len(msg) > 0 do                 \*while there are bytes left in the message

                inc:    if Len(msg) > 1 then                    \*pop off head of message
                            incByte :=  <<Head(msg)>>;
                            msg := Tail(msg);
                        else
                            incByte := <<msg[1]>>;
                            msg := <<>>;
                        end if;
                        
                        rxReg := incByte;    
                        
                        receive:    \* a ":" character indicates the start of a new message
                        if rxReg = StrTupleToNumTuple(<<":">>)
                                then rxBuf := <<>>;
                        end if;
                         
                        \*if the buffer is full then there is NO WAY it could be valid modbus
                        if Len(rxBuf) = MAXMODBUSSIZE then
             buffull:       rxBuf := <<>>;
                            rxReg := <<>>;
                            incByte := <<>>;
                            last2 := <<0,0>>;
                            goto start;
                        end if;
    
                        r0: last2 := Tail(last2 \o rxReg); \*update last2
                        r1: rxBuf := rxBuf \o rxReg; \* put the contents of the register into the buffer
                        
                        \*empty the register
                        r2: rxReg := <<>>;
                        
            check:     \*if we get the end of the modbus "\r\n" then ship it
                        if NumTupleToStrTuple(last2) = <<"\r","\n">> then \*convert back to ASCII before checking for end of packet
                            check0: msgid := <<guid[1]>> \o <<"t","n","i">>;
                            check1: guid[1] := guid[1] + 1;
                            check2: sentBuffer := sentBuffer \o [id|->msgid, text|->rxBuf, source|->"trustnet_in"];
                            check3: sentBuffer := sentBuffer \o [id|->msgid, text|->rxBuf];
                            \*check2: send("messagecheck", [id|->msgid, text|->rxBuf, source|->"trustnet_in"]);
                            \*check3: send("sign", [id|->msgid, text|->rxBuf]);
                            
                            check4: rxBuf := <<>>;
                            rxReg := <<>>;
                            incByte := <<>>;
                            last2 := <<0,0>>;
                        end if;
                end while;
            end while;
end algorithm
*)

\* BEGIN TRANSLATION
VARIABLES rxBuf, rx, rxReg, incomingMessages, incByte, msg, msgid, guid, 
          last2, sentBuffer, pc

vars == << rxBuf, rx, rxReg, incomingMessages, incByte, msg, msgid, guid, 
           last2, sentBuffer, pc >>

Init == (* Global variables *)
        /\ rxBuf = <<>>
        /\ rx = FALSE
        /\ rxReg = <<>>
        /\ incomingMessages \in MessagesToSerialPort
        /\ incByte = <<>>
        /\ msg = <<>>
        /\ msgid = <<>>
        /\ guid = <<0>>
        /\ last2 = <<0,0>>
        /\ sentBuffer = <<>>
        /\ pc = "trustnet_in1"

trustnet_in1 == /\ pc = "trustnet_in1"
                /\ IF Len(incomingMessages) > 0
                      THEN /\ IF Len(incomingMessages) > 1
                                 THEN /\ pc' = "ti1"
                                 ELSE /\ pc' = "ti3"
                      ELSE /\ pc' = "Done"
                /\ UNCHANGED << rxBuf, rx, rxReg, incomingMessages, incByte, 
                                msg, msgid, guid, last2, sentBuffer >>

start == /\ pc = "start"
         /\ IF Len(msg) > 0
               THEN /\ pc' = "inc"
               ELSE /\ pc' = "trustnet_in1"
         /\ UNCHANGED << rxBuf, rx, rxReg, incomingMessages, incByte, msg, 
                         msgid, guid, last2, sentBuffer >>

inc == /\ pc = "inc"
       /\ IF Len(msg) > 1
             THEN /\ incByte' = <<Head(msg)>>
                  /\ msg' = Tail(msg)
             ELSE /\ incByte' = <<msg[1]>>
                  /\ msg' = <<>>
       /\ rxReg' = incByte'
       /\ pc' = "receive"
       /\ UNCHANGED << rxBuf, rx, incomingMessages, msgid, guid, last2, 
                       sentBuffer >>

receive == /\ pc = "receive"
           /\ IF rxReg = StrTupleToNumTuple(<<":">>)
                 THEN /\ rxBuf' = <<>>
                 ELSE /\ TRUE
                      /\ rxBuf' = rxBuf
           /\ IF Len(rxBuf') = MAXMODBUSSIZE
                 THEN /\ pc' = "buffull"
                 ELSE /\ pc' = "r0"
           /\ UNCHANGED << rx, rxReg, incomingMessages, incByte, msg, msgid, 
                           guid, last2, sentBuffer >>

buffull == /\ pc = "buffull"
           /\ rxBuf' = <<>>
           /\ rxReg' = <<>>
           /\ incByte' = <<>>
           /\ last2' = <<0,0>>
           /\ pc' = "start"
           /\ UNCHANGED << rx, incomingMessages, msg, msgid, guid, sentBuffer >>

r0 == /\ pc = "r0"
      /\ last2' = Tail(last2 \o rxReg)
      /\ pc' = "r1"
      /\ UNCHANGED << rxBuf, rx, rxReg, incomingMessages, incByte, msg, msgid, 
                      guid, sentBuffer >>

r1 == /\ pc = "r1"
      /\ rxBuf' = rxBuf \o rxReg
      /\ pc' = "r2"
      /\ UNCHANGED << rx, rxReg, incomingMessages, incByte, msg, msgid, guid, 
                      last2, sentBuffer >>

r2 == /\ pc = "r2"
      /\ rxReg' = <<>>
      /\ pc' = "check"
      /\ UNCHANGED << rxBuf, rx, incomingMessages, incByte, msg, msgid, guid, 
                      last2, sentBuffer >>

check == /\ pc = "check"
         /\ IF NumTupleToStrTuple(last2) = <<"\r","\n">>
               THEN /\ pc' = "check0"
               ELSE /\ pc' = "start"
         /\ UNCHANGED << rxBuf, rx, rxReg, incomingMessages, incByte, msg, 
                         msgid, guid, last2, sentBuffer >>

check0 == /\ pc = "check0"
          /\ msgid' = <<guid[1]>> \o <<"t","n","i">>
          /\ pc' = "check1"
          /\ UNCHANGED << rxBuf, rx, rxReg, incomingMessages, incByte, msg, 
                          guid, last2, sentBuffer >>

check1 == /\ pc = "check1"
          /\ guid' = [guid EXCEPT ![1] = guid[1] + 1]
          /\ pc' = "check2"
          /\ UNCHANGED << rxBuf, rx, rxReg, incomingMessages, incByte, msg, 
                          msgid, last2, sentBuffer >>

check2 == /\ pc = "check2"
          /\ sentBuffer' = sentBuffer \o [id|->msgid, text|->rxBuf, source|->"trustnet_in"]
          /\ pc' = "check3"
          /\ UNCHANGED << rxBuf, rx, rxReg, incomingMessages, incByte, msg, 
                          msgid, guid, last2 >>

check3 == /\ pc = "check3"
          /\ sentBuffer' = sentBuffer \o [id|->msgid, text|->rxBuf]
          /\ pc' = "check4"
          /\ UNCHANGED << rxBuf, rx, rxReg, incomingMessages, incByte, msg, 
                          msgid, guid, last2 >>

check4 == /\ pc = "check4"
          /\ rxBuf' = <<>>
          /\ rxReg' = <<>>
          /\ incByte' = <<>>
          /\ last2' = <<0,0>>
          /\ pc' = "start"
          /\ UNCHANGED << rx, incomingMessages, msg, msgid, guid, sentBuffer >>

ti1 == /\ pc = "ti1"
       /\ msg' = Head(incomingMessages)
       /\ pc' = "ti2"
       /\ UNCHANGED << rxBuf, rx, rxReg, incomingMessages, incByte, msgid, 
                       guid, last2, sentBuffer >>

ti2 == /\ pc = "ti2"
       /\ incomingMessages' = Tail(incomingMessages)
       /\ pc' = "start"
       /\ UNCHANGED << rxBuf, rx, rxReg, incByte, msg, msgid, guid, last2, 
                       sentBuffer >>

ti3 == /\ pc = "ti3"
       /\ msg' = incomingMessages
       /\ pc' = "ti4"
       /\ UNCHANGED << rxBuf, rx, rxReg, incomingMessages, incByte, msgid, 
                       guid, last2, sentBuffer >>

ti4 == /\ pc = "ti4"
       /\ incomingMessages' = <<>>
       /\ pc' = "start"
       /\ UNCHANGED << rxBuf, rx, rxReg, incByte, msg, msgid, guid, last2, 
                       sentBuffer >>

Next == trustnet_in1 \/ start \/ inc \/ receive \/ buffull \/ r0 \/ r1
           \/ r2 \/ check \/ check0 \/ check1 \/ check2 \/ check3 \/ check4
           \/ ti1 \/ ti2 \/ ti3 \/ ti4
           \/ (* Disjunct to prevent deadlock on termination *)
              (pc = "Done" /\ UNCHANGED vars)

Spec == /\ Init /\ [][Next]_vars
        /\ WF_vars(Next)

Termination == <>(pc = "Done")

\* END TRANSLATION

SAFETYCHECK ==
    \*receive buffer never overflows
    /\ Len(rxBuf) <= MAXMODBUSSIZE 
    \*sending buffer never overflows
    /\ \A x \in Range(sentBuffer) : Len(x.text) > MAXMODBUSSIZE
    \*last2 buffer always less than 2
    /\ Len(last2) < 2
    \*only well-formed modbus gets forwarded
    /\ \A x \in Range(sentBuffer) : IsWellformedModbus(NumTupleToStrTuple(x.text))
    \*each message that is forwarded has a unique message id
    /\ \A x \in Range(sentBuffer) : Len({y \in Range(sentBuffer) : x.id = y.id}) = 1

LIVELINESS ==
    \* if the message is well-formed then it gets sent
    /\ IsWellformedModbus(NumTupleToStrTuple(msg)) ~> \E x \in Range(sentBuffer) : x.text = msg
    \* all messages are processed
    /\ <>[](incomingMessages = <<>>)
    \*last2 buffer gets reset after each well-formed message
    /\ NumTupleToStrTuple(last2) = <<"\r","\n">> ~> last2 = <<0,0>>

=============================================================================
\* Modification History
\* Last modified Mon Jun 03 15:16:54 EDT 2019 by mssabr01
\* Last modified Mon May 14 12:52:02 EDT 2018 by SabraouM
\* Created Sat May 05 11:36:54 EDT 2018 by SabraouM
