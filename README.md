# ENGN1580-final-spectrum-challenge
Final Project for ENGN1580  

### Folder Structure
All code lives under `Code` folder.  
Under `Code`, we have scheme\_#\_<description>\_<author>. They are identical copies of the
entire standalone program. They are different strategies we have developed.  
For your own work, starta a new folder under Code. You can build upon previous
work by copying over another teammate's folder.  

### Modulation schemes
Scheme 1: ASK, one rail. Sin and Cos functions at given freq.  
Scheme 2: CDMA-like, carriers (chips/codewords) are simply +1 and -1.  
Scheme 3: CDMA-like, with Ack/Nack  

### Parameter tuning
#### Scheme 1
% [Tunable param] Carrier period. The shorter, the higher amplitude of our carriers (which decreases P_e), but shorter bit interval (which increases P_e)  
`bit_interval = 2`  
% Amplitude is scaled based on bit_interval to ensure we meet the power budget.  
`amplitude = 7.04`  
% [Tunable param] The more number of bits we send, the higher N is in our score, but also the higher P_e.  
`total bits to send = 10000`  
% [Tunable param] Carrier frequencies  
`carriers frequency = 1000` for both sin and cos.  

#### Scheme 2
`bit_interval = 1`  
`amplitude = 9.95`  
`total bits to send = 10000`  
% [Tunable param] How many packets we divide the total bitstream into. Shouldn't really affect anything. But creates more resilience to randomness in the arena.  
`total_num_packets = 8`  

#### Scheme 3
% [Tunable param] The probability of resending a bit. The higher, the more likely we resend a bit (which lowers P_e), but lower the carrier amplitude as well since we have limited power budget (which increases P_e).  
`P_resend = 0.2;`  
