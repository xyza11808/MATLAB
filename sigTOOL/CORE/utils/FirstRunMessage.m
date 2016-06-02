function FirstRunMessage(fhandle)
% FirstRunMessage generates the sigTOOL Welcome message
%
% Example:
% To invoke this function type sigTOOL('firstrun') at the MATLAB prompt
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 05/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
%

% Revisions:
%   Not documented
%


C=javax.swing.ImageIcon(fullfile(scGetBaseFolder(),'CORE','icons','sigTOOL Welcome.gif'));
h=jcontrol(fhandle, 'javax.swing.JButton',...
    'Icon',C,...
    'Position',[0.5 0.5 0.0001 0.0001]);
set(h, 'Units', 'pixels')
pos=get(h,'Position');
set(h, 'Position', [pos(1)-300 pos(2)-200 600 400]);
set(h, 'Units', 'normalized');
b=jcontrol(h, 'javax.swing.JButton',...
    'Position', [0.8 0.025 .2 .1],...
    'Label','Next>>',...
    'MouseClickedCallback', @NextAction1);
uiwait();

    function NextAction1(hObject, EventData) %#ok<*INUSD>
        h.setIcon([]);
        uiresume();
        txt=sprintf('sigTOOL is supplied without warranty, without even the implied warranty of fitness for a particular purpose\n');
        txt=sprintf('%s\nsigTOOL is open-source software and is supplied under the GNU General Public Licence (GPL).\n',txt);
        txt=sprintf('%sThis is version %3.2f of sigTOOL.',txt,scVersion('nodisplay'));
        txt=sprintf('%s To ensure you have the latest version visit the sigTOOL web site.\nYou can also post feedback and subscribe to an RSS feed from this site to be informed of sigTOOL updates.\n',txt);
        txt=sprintf('%s\n%s', txt, repmat('-',1,30));
        txt=sprintf('%s\nYou can also register and post feedback direct to sigtool@kcl.ac.uk through the sigTOOL GUI Help menu\nTo register now, click the button below (N.B. requires that your MATLAB installation is setup for internet use)', txt);
        txt=sprintf('%s\n\nAlso see the website for details of plans for sigTOOL 1.00 [support for ImageJ, GPGPU processing, HDF5 support etc].', txt);
        sc=javax.swing.JScrollPane();
        tfield=javax.swing.JTextArea(txt);
        sc.setViewportView(tfield);
        tscroll=jcontrol(h, sc,...
            'Position', [0.05 0.16 0.9 0.8]);
        tfield.setLineWrap(true);
        tfield.setWrapStyleWord(true);
        button=jcontrol(h,javax.swing.JButton,...
            'Position', [0.3 .05 .2 .1],...
            'Label', 'sigTOOL website',...
            'MouseClickedCallback', 'web(''http://sigtool.sourceforge.net'',''-browser'')');
        button3=jcontrol(h,javax.swing.JButton,...
            'Position', [0.55 .05 .2 .1],...
            'Label', 'Register Now',...
            'MouseClickedCallback', 'scRegister');
        button2=jcontrol(h,javax.swing.JButton,...
            'Position', [0.05 .05 .2 .1],...
            'Label', 'View licence',...
            'MouseClickedCallback', 'web(''http://www.gnu.org/copyleft/gpl.html'',''-browser'')');
        set(b,'Position', [0.8 0.05 .2 .1],...
            'MouseClickedCallback', {@NextAction2, tfield, button, button2, button3});
        return
    end



    function NextAction2(hObject, EventData, tfield, button, button2, button3) %#ok<*INUSL>
        delete(button3);
        delete(button2);
        ezy=which('EzyFit');
        fa=which('fastica');
        ic=which('Icasso');
        mm=which('mmread');
        txt=sprintf('sigTOOL makes use of some third-party software packages that are not included in this distribution.\nThese are not essential, but some sigTOOL functionality will be missing in their absence.\n');
        if ~isempty(ezy) && ~isempty(fa) && ~isempty(ic) && ~isempty(mm)
            txt=sprintf('%sAll of these appear to be installed', txt);
        else
            txt=sprintf('%s\nMISSING SOFTWARE\nThe following, optional, packages are not installed or are not presently on the MATLAB path:\n',txt);
            if isempty(ezy)
                txt=sprintf('%sEzyFit curve fitting by Frederic Moisy\n',txt);
            end
            if isempty(fa)
                txt=sprintf('%sFastICA independent components analysis by Hugo Gävert, Jarmo Hurri, Jaakko Särelä, and Aapo Hyvärinen\n',txt);
            end
            if isempty(ic)
                txt=sprintf('%sIcasso ICA analysis by Johan Himberg\n',txt);
            end
            if isempty(mm)
                txt=sprintf('%sMmread for multi-media file support by Micah Richert\n',txt);
            end
            txt=sprintf('%s\nTo install them, follow the steps in the Installing sigTOOL PDF',txt);
        end
        tfield.setText(txt);
        set(button, 'Label', 'View PDF',...
            'MouseClickedCallback', sprintf('open(''%s'')', [scGetBaseFolder 'Installing sigTOOL.PDF']));
        set(b,'MouseClickedCallback', {@NextAction3, tfield, button});
        return
    end


    function NextAction3(hObject, EventData, tfield, button)
        txt=sprintf('Further development of sigTOOL depends on it being used - and our ability to show that its is being used.\n\nIf you use sigTOOL, please register as a user and cite it by including a reference to the sigTOOL paper. Please also cite any third-party software accessed via sigTOOL e.g.\n');
        txt=sprintf('%s\n"Spikes were detected and sorted using Wave_clus (Quiroga et al., 2004) running in sigTOOL (Lidierth, 2009)"\n\n',txt);
        txt=sprintf('%sM. Lidierth (2009). sigTOOL: a MATLAB-based environment for sharing laboratory-developed software to analyze biological signals. Journal of Neuroscience Methods 178, 188-196.\n\n',txt);
        txt=sprintf('%sR.Q.Quiroga, Z. Nadasdy & Y. Ben-Shaul (2004). Unsupervised spike detection and sorting with wavelets and superparamagnetic clustering,Neural Computation, 16, 1661-1687.',txt);
        tfield.setText(txt);
        tfield.setForeground(java.awt.Color.BLUE);
        set(button, 'Label', 'Download paper',...
            'MouseClickedCallback', 'web(''http://dx.doi.org/10.1016/j.jneumeth.2008.11.004'',''-browser'')');
        set(b,'Label', 'Finish',...
            'MouseClickedCallback', @Finish);
        return
    end

    function Finish(hObject, EventData)
        uiresume();
        delete(h);
        return
    end




return
end





