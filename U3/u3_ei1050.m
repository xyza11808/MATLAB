%
% Demonstrates talking to a EI-1050 probes using MATLAB, .NET and the UD
% driver.
%
% support@labjack.com
%

clc %Clear the MATLAB command window
clear %Clear the MATLAB variables

ljasm = NET.addAssembly('LJUDDotNet'); %Make the UD .NET assembly visible in MATLAB
ljudObj = LabJack.LabJackUD.LJUD;

try
    %Read and display the UD version.
    disp(['UD Driver Version = ' num2str(ljudObj.GetDriverVersion())])
    
    %Open the first found LabJack U3.
    [ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.U3, LabJack.LabJackUD.CONNECTION.USB, '0', true, 0);
    
    %Start by using the pin_configuration_reset IOType so that all
    %pin assignments are in the factory default condition.
    ljudObj.ePut(ljhandle, LabJack.LabJackUD.IO.PIN_CONFIGURATION_RESET, 0, 0, 0);
    
    %Set the Data line to FIO4, which is the default anyway.
    ljudObj.ePut(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.SHT_DATA_CHANNEL, 4, 0);
    
    %Set the Clock line to FIO5, which is the default anyway.
    ljudObj.ePut(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.SHT_CLOCK_CHANNEL, 5, 0);
    
    %Set FIO6 to output-high to provide power to the EI-1050.
    ljudObj.ePut(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 6, 1, 0);
    
    %Connections for probe:
    %	Red (Power)         FIO6
    %	Black (Ground)      GND
    %	Green (Data)        FIO4
    %	White (Clock)       FIO5
    %	Brown (Enable)      FIO6
    
    %Now, an add/go/get block to get the temp & humidity at the same time.
    %Request a temperature reading from the EI-1050.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.SHT_GET_READING, LabJack.LabJackUD.CHANNEL.SHT_TEMP, 0, 0, 0);
    
    %Request a humidity reading from the EI-1050.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.SHT_GET_READING, LabJack.LabJackUD.CHANNEL.SHT_RH, 0, 0, 0);
    
    %Execute the requests.  Will take about 0.5 seconds with a USB high-high
    %or Ethernet connection, and about 1.5 seconds with a normal USB connection.
    ljudObj.GoOne(ljhandle);
    
    %Get the temperature reading.
    [ljerror, dblValue] = ljudObj.GetResult(ljhandle, LabJack.LabJackUD.IO.SHT_GET_READING, LabJack.LabJackUD.CHANNEL.SHT_TEMP, 0);
    disp(['Temp Probe A = ' num2str(dblValue) ' deg K']);
    disp(['Temp Probe A = ' num2str((dblValue-273.15)) ' deg C']);
    disp(['Temp Probe A = ' num2str((((dblValue-273.15)*1.8)+32)) ' deg F']);
    
    %Get the humidity reading.
    [ljuderror, dblValue] = ljudObj.GetResult(ljhandle, LabJack.LabJackUD.IO.SHT_GET_READING, LabJack.LabJackUD.CHANNEL.SHT_RH, 0);
    disp(['RH Probe A = ' num2str(dblValue) ' percent']);
catch e
    showErrorMessage(e)
end