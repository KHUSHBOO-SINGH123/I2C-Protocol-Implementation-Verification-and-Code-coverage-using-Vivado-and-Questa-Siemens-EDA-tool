# I2C-Protocol-Implementation-Verification-and-Code-coverage-using-Vivado-and-Questa-Siemens-EDA-tool

The aim of this project is to transfer the data between the FPGA and any sensor.So we need to design a protocol which would help us to set up a unscathed link between the FPGA and the humidity sensor. There are a variety of protocols like UART USB CAN AMBA but in our project we are using the I2C protocol

I2C Protocol is Inter Integrated Circuit Protocol, it’s have onlytwo wire which is used to synchronous serial inter system communication.
Firstly, I2Cprotocol introduced by Phillip Semiconductorin1982.
Initially It had transmission frequency100KHz with7-bit Address. In1992,afast mode of transmission has developed which have 400 KHz with 10-Bit address nowadays this technology also uses.
AdditionalmodesavailableinI2C

	fast-modeplus,1MHz

	high-speedmode,3.4MHz

	ultra-fastmode,5MHz

As per the block diagram mentioned in the Fig 2.1 there are two components of I2C Protocol
1.	Master

2.	Slave

There can be one or more Master and one or more Slave, but at me only one Master can communicate without one Slave. By available data the I2Cdevicescancommunicate on 100kHz or 400kHz. I2C requires only two buses for communication between two system.
That’s are

1.	SDA–Serial Data Access Line–Master/ Controller and Slave/Peripheral communicate data frames over this line
2.	SCL–Serial Clock Line–Provides synchronization in transmission between Master/Controller and Slave/Peripheral


![image](https://github.com/user-attachments/assets/6736bd21-7ff0-4a06-a286-24a4b6dc2fec)

PROTOCOL:

Start Condition:

Any Master/Controller device which is connected to SDA and SCL lines, if it needs to state the communication it will do so by pulling the down the SDA line from logic High to Logic low signifying the start of communication. If multiples Masters are demanding to pull down the SDA line at the same time, the one which first does so will be able to lock the SDA and SCL lines until they stop the lock by Stop bit.

Address Frame:

Once the communication starts, be it read/write, the first frame transmitted will be 7 - bit address frame indicating the address of the Slave with which the Master wants to communicate followed by the Read/Write Bit indicating the Read/Write operation.
The next frame in the protocol is NACK/ACK bit. These are acknowledgement bits common to both address and data frames sent by the receiver to the transmitter acknowledge goinga successful reception of corresponding address frame or data frame.

Data Frames:

After sending the address frame over SDA line and receiving the corresponding acknowledgement bit, the Master will send the data to slave in case of write operation and slave will send the data to master in case of read operation. How many numbers of Data frames will be communicated per message is arbitrary and will only depend on case by case.

Stop condition:

The controller can show the extinction or end of communication by increasing the SDAline high when SCL line is High. i.e., 0 to 1 transition on SDA when 0 to 1 transition on SCL will indicate a Stop Condition.


![image](https://github.com/user-attachments/assets/81a40c75-7046-45bd-ada3-63c8a4345cbe)

FSM used : - 

![image](https://github.com/user-attachments/assets/64b68c6c-f2bb-4f96-93ac-7a1b11eaca31)

Results (First through VIVADO tool) :- 

SIMULATIONRESULTS
SimulationWaveforms:

•	Module 1 processes the clock of 200KHz from which a 10KHz is generated later which is our SCL line.
•	Module 2 is the master read slave register I2C controller, in which master processes the address of the slave register and later processes the data when the slave acknowledges it using state machine model.
•	Third is the top modules is instantiate the above sub modules.

![image](https://github.com/user-attachments/assets/8bc7e91a-004f-49a6-bb9e-402bb4264b14)
![image](https://github.com/user-attachments/assets/f66a9a75-b820-4e14-8631-748f9bfcd1b1)

Start Bit 
![image](https://github.com/user-attachments/assets/97ecbf9c-a0fd-4ed6-a548-86ec1a3ee304)

Simulation 
![image](https://github.com/user-attachments/assets/4de735db-9141-4a1e-8cf6-b9a4c2b8d652)

Result ( Using QuestaSim tool)
1. Start bit
![image](https://github.com/user-attachments/assets/ee1b5111-ba20-4ad6-b5f3-d9e9d557be76)

2. Data out at 475ns to 595ns
![image](https://github.com/user-attachments/assets/ceef7f84-e721-45ce-a2a8-e4fedadaaea5)

3. Stop bit at 605 ns
![image](https://github.com/user-attachments/assets/534cd3df-76dc-460a-a464-cf1479a9b07a)

4. Overall Result
![image](https://github.com/user-attachments/assets/ddabccf6-35fd-493f-8432-0366083fec5f)

![image](https://github.com/user-attachments/assets/4d9c8e43-9aa4-42dc-8718-c25d6ad8ce59)

