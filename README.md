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
Scheme 3: CDMA-like, with source coding

### Parameter tuning
#### Scheme 1
bit_interval = 2;         % Carrier period
amplitude = 7.04;         % Scaler on how much energy to use
total bits to send = 10000
carriers frequency = 1000 for both sin and cos.

#### Scheme 2
bit_interval = 1;
amplitude = 9.95;
total bits to send = 10000

#### Scheme 3
