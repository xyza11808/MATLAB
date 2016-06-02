%
% Basic command/response example using MATLAB, .NET and the UD driver.
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

    %First some configuration commands.  These will be done with the ePut
    %function which combines the add/go/get into a single call.
    
    %Configure FIO0-FIO3 as analog, all else as digital.  That means we
    %will start from channel 0 and update all 16 flexible bits.  We will
    %pass a value of b0000000000001111 or d15.
    %Note that for the last parameter we are forcing the value to an int32
    %to ensure MATLAB converts the parameters correctly and uses the proper
    %function overload.
    %ljudObj.ePut(ljhandle, LabJack.LabJackUD.IO.PUT_ANALOG_ENABLE_PORT, 0, 15, 16);
    ljudObj.ePut(ljhandle, LabJack.LabJackUD.IO.PUT_ANALOG_ENABLE_PORT, 0, 15, int32(16));
    
    %Static	LabJack.LabJackUD.LJUDERROR RetVal	ePut	(int32 scalar handle, LabJack.LabJackUD.IO IOType, int32 scalar channel, double scalar val, int32 scalar x1)
    
    %Set the timer/counter pin offset to 7, which will put the first
    %timer/counter on FIO7.
    ljudObj.ePut(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.TIMER_COUNTER_PIN_OFFSET, 7, 0);
    
    %Enable Counter1 (FIO7).
    ljudObj.ePut(ljhandle, LabJack.LabJackUD.IO.PUT_COUNTER_ENABLE, 1, 1, 0);
    
    %The following commands will use the add-go-get method to group
    %multiple requests into a single low-level function.
    
    %Request a single-ended reading from AIN0.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.GET_AIN, 0, 0, 0, 0);
    
    %Request a single-ended reading from AIN1.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.GET_AIN, 1, 0, 0, 0);
    
    %Request a reading from AIN2 using the Special range.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.GET_AIN_DIFF, 2, 0, 32, 0);
    
    %Set DAC0 to 3.5 volts.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DAC, 0, 3.5, 0, 0);
    
    %Set digital output FIO4 to output-high.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_DIGITAL_BIT, 4, 1, 0, 0);
    
    %Read digital input FIO5.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.GET_DIGITAL_BIT, 5, 0, 0, 0);
    
    %Read digital inputs FIO5 through FIO6.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.GET_DIGITAL_PORT, 5, 0, 2, 0);
    
    %Request the value of Counter1 (FIO7).
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.GET_COUNTER, 1, 0, 0, 0);
    
    requestedExit = false;
    while requestedExit == false
        %Execute the requests.
        ljudObj.GoOne(ljhandle);
        
        %Get all the results.  The input measurement results are stored.  All other
        %results are for configuration or output requests so we are just checking
        %whether there was an error.
        [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetFirstResult(ljhandle, 0, 0, 0, 0, 0);

        finished = false;
        while finished == false
            switch ioType
                case int32(LabJack.LabJackUD.IO.GET_AIN)
                    switch int32(channel)
                        case 0
                            value0 = dblValue;
                        case 1
                            value1 = dblValue;
                    end
                case int32(LabJack.LabJackUD.IO.GET_AIN_DIFF)
                    value2 = dblValue;
                case int32(LabJack.LabJackUD.IO.GET_DIGITAL_BIT)
                    valueDIBit = dblValue;
                case int32(LabJack.LabJackUD.IO.GET_DIGITAL_PORT)
                    valueDIPort = dblValue;
                case int32(LabJack.LabJackUD.IO.GET_COUNTER)
                    valueCounter = dblValue;
            end
            
            try
                [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetNextResult(ljhandle, 0, 0, 0, 0, 0);
            catch e
                if(isa(e, 'NET.NetException'))
                    eNet = e.ExceptionObject;
                    if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
                        if(eNet.LJUDError == LabJack.LabJackUD.LJUDERROR.NO_MORE_DATA_AVAILABLE)
                            finished = true;
                        end
                    end
                end
                %Report non NO_MORE_DATA_AVAILABLE error.
                if(finished == false)
                    throw(e)
                end
            end
        end
        disp(['AIN0 = ' num2str(value0)])
        disp(['AIN1 = ' num2str(value1)])
        disp(['AIN2 = ' num2str(value2)])
        disp(['FIO5 = ' num2str(valueDIBit)])
        disp(['FIO5-FIO6 = ' num2str(valueDIPort)]) %Will read 3 (binary 11) if both lines are pulled-high as normal.
        disp(['Counter1 (FIO7) = ' num2str(valueCounter)]) %Will read 3 (binary 11) if both lines are pulled-high as normal.
        
        str = input('Press Enter to go again or (q) and then Enter to quit ','s');
        if(str == 'q')
            requestedExit = true;
        end
    end
catch e
    showErrorMessage(e)
end