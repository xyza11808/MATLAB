%
% Basic U3 example does a PWM output and a counter input features using
% MATLAB, .NET and the UD driver.
%
% support@labjack.com
%

clc %Clear the MATLAB command window
clear %Clear MATLAB variables

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
    
    %First requests to configure the timer and counter.  These will be
    %done with and add/go/get block.
    
    %Set the timer/counter pin offset to 4, which will put the first
    %timer/counter on FIO4.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.TIMER_COUNTER_PIN_OFFSET, 4, 0, 0);
    
    %Use the 48 MHz timer clock base with divider (LJ_tc48MHZ_DIV).  Since we are using clock with divisor
    %support, Counter0 is not available.
    LJ_tc48MHZ_DIV = ljudObj.StringToConstant('LJ_tc48MHZ_DIV');
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.TIMER_CLOCK_BASE, LJ_tc48MHZ_DIV, 0, 0);
    %LJ_tc24MHZ_DIV = ljudObj.StringToConstant('LJ_tc24MHZ_DIV');
    %ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.TIMER_CLOCK_BASE, LJ_tc24MHZ_DIV, 0, 0);  %Use this line instead for hardware rev 1.20 (LJ_tc24MHZ_DIV).
    
    %Set the divisor to 48 so the actual timer clock is 1 MHz.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.TIMER_CLOCK_DIVISOR, 48, 0, 0);
    %ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.TIMER_CLOCK_DIVISOR, 24, 0, 0);  %Use this line instead for hardware rev 1.20.
    
    %Enable 1 timer.  It will use FIO4.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.NUMBER_TIMERS_ENABLED, 1, 0, 0);
    
    %Configure Timer0 as 8-bit PWM (LJ_tmPWM8).  Frequency will be 1M/256 = 3906 Hz.
    LJ_tmPWM8 = ljudObj.StringToConstant('LJ_tmPWM8');
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_TIMER_MODE, 0, LJ_tmPWM8, 0, 0);
    
    %Set the PWM duty cycle to 50%.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_TIMER_VALUE, 0, 32768, 0, 0);
    
    %Enable Counter1.  It will use FIO5 since 1 timer is enabled.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_COUNTER_ENABLE, 1, 1, 0, 0);
    
    %Execute the requests.
    ljudObj.GoOne(ljhandle);
        
    %Get all the results just to check for errors.
    [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetFirstResult(ljhandle, 0, 0, 0, 0, 0);
    
    finished = false;
    while finished == false
        try
            [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetNextResult(ljhandle, 0, 0, 0, 0, 0);
        catch e
            if(isa(e, 'NET.NetException'))
                eNet = e.ExceptionObject;
                if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
                    %If we get an error, report it.  If the error is NO_MORE_DATA_AVAILABLE we are done
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
    
    %Wait 1 second.
    pause(1);
    
    %Request a read from the counter.
    [ljerror, dblValue] = ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.GET_COUNTER, 1, 0, 0);
    
    %This should read roughly 4k counts if FIO4 is shorted to FIO5.
    disp(['Counter 1 = ' num2str(dblValue)]);
    
    %Wait 1 second.
    pause(1);
    
    %Request a read from the counter.
    [ljerror, dblValue] = ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.GET_COUNTER, 1, 0, 0);
    
    %This should read about 3906 counts more than the previous read.
    disp(['Counter 1 = ' num2str(dblValue)]);
    
    %Reset all pin assignments to factory default condition.
    ljudObj.ePut(ljhandle, LabJack.LabJackUD.IO.PIN_CONFIGURATION_RESET, 0, 0, 0);
    
    %The PWM output sets FIO4 to output, so we do a read here to set
    %it to input.
    ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.GET_DIGITAL_BIT, 4, 0, 0);
catch e
    showErrorMessage(e)
end