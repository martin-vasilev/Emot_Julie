global const Visual sent Monitor el Audio; 

% Blackbox toolkit testing:
%s= serial('COM11');
%set(s, 'BaudRate', 115200, 'DataBits', 8, 'StopBits', 1, 'Parity', 'none')
%fopen(s);
%fprintf(s, 'RR');
%fprintf(s,'FF');

%const.ntrials=10; % TEMPORARY!!! Use only for testing

HideCursor;

% Calibrate the eye tracker
EyelinkDoTrackerSetup(el);

% Trial presentation loop:
for i=1:const.ntrials
%%  stimuli set-up:
    
    trialEnd= false; 
	item= design.item(i);
    cond= design.cond(i);
    frame= design.frame(i);
	
	% conditions:
    if cond> 3
        sentenceString= sent(item).frame1; % practice
    end
    
    if cond==1
        target= sent(item).negative; % negative
        switch frame
            case 1
                sentenceString= sent(item).frame1;
            case 2
                sentenceString= sent(item).frame2;
            case 3
                sentenceString= sent(item).frame3;
        end
        sentenceString= strrep(sentenceString, 'TW', target);  
    end
    
    if cond==2
        target= sent(item).neutral; % neutral
        
       switch frame
            case 1
                sentenceString= sent(item).frame1;
            case 2
                sentenceString= sent(item).frame2;
            case 3
                sentenceString= sent(item).frame3;
        end
        sentenceString= strrep(sentenceString, 'TW', target); 
    end
    
    if cond==3
        target= sent(item).positive; % positive
        
        switch frame
            case 1
                sentenceString= sent(item).frame1;
            case 2
                sentenceString= sent(item).frame2;
            case 3
                sentenceString= sent(item).frame3;
        end
        sentenceString= strrep(sentenceString, 'TW', target); 
    end
    
    
    %% drift check:
    
    EyelinkDoDriftCorrection(el);
    
    %% Eyelink & Screen trial set-up:
	stimuliOn= false;
    
    while ~stimuliOn
        if item> const.Maxtrials % if practice
            Eyelink('Message', ['TRIALID ' 'P' num2str(cond) 'I' num2str(item) 'D0']);
			% print trial ID on tracker screen:
            Eyelink('command', ['record_status_message ' [ num2str(i) ':' 'P' num2str(cond) 'I' num2str(item) 'D0']]);
        else
			Eyelink('Message', ['TRIALID ' 'E' num2str(cond) 'I' num2str(item) 'D0']);
			% print trial ID on tracker screen:
			Eyelink('command', ['record_status_message ' [num2str(i) ':' 'E' num2str(cond) 'I' num2str(item)]]); 
        end

% 		if cond<9
%             Eyelink('Message', ['SOUND ONSET DELAY: ' num2str(design.delay(i))]);
%             Eyelink('Message', ['CRITICAL REGION 1 @ ' num2str(Bnds(2)) ' ' num2str(Bnds(2+1))]);
% 			Eyelink('Message', ['CRITICAL REGION 2 @ ' num2str(Bnds(4)) ' ' num2str(Bnds(4+1))]);
% 			Eyelink('Message', ['CRITICAL REGION 3 @ ' num2str(Bnds(6)) ' ' num2str(Bnds(6+1))]);
% 			Eyelink('Message', ['CRITICAL REGION 4 @ ' num2str(Bnds(8)) ' ' num2str(Bnds(8+1))]);
% 			Eyelink('Message', ['CRITICAL REGION 5 @ ' num2str(Bnds(10)) ' ' num2str(Bnds(10+1))]);
%         end
        
        % print text stimuli to edf:
        stim2edf(sentenceString);
        
        % prepare Screens:
        Screen('FillRect', Monitor.buffer(1), Visual.FGC, [Visual.offsetX Visual.resY/2- Visual.GazeBoxSize/2 Visual.offsetX+Visual.GazeBoxSize ...
            Visual.resY/2+ Visual.GazeBoxSize]) % gazebox
        gazeBnds_x= [Visual.offsetX Visual.offsetX+Visual.GazeBoxSize];
		gazeBnds_y= [Visual.resY/2- Visual.GazeBoxSize/2 Visual.resY/2+ Visual.GazeBoxSize];
        
        
        Screen('FillRect', Monitor.buffer(2), Visual.BGC);
        Screen('DrawText', Monitor.buffer(2), sentenceString, Visual.sentPos(1), Visual.sentPos(2), Visual.FGC); % sentence
        
        if const.checkPPL
			lngth= length(sentenceString)*Visual.Pix_per_Letter;
            Screen('FrameRect', Monitor.buffer(2), Visual.FGC, [Visual.offsetX Visual.resY/2- Visual.GazeBoxSize/2 ...
                Visual.offsetX+lngth Visual.resY/2+ Visual.GazeBoxSize])
        end
        
        % Print stimuli to Eyelink monitor:
        % draw gaze box on tracker monitor:
        imageArray= Screen('GetImage', Monitor.buffer(2), [0 0 1920 1080]);
%         if cond==3
%             B= eval(['boundary' num2str(soundPos)]);
%             imageArray(:, B-5:B+5)= 179;
%         end
        
        imwrite(imageArray, 'disp.bmp');
        
        Eyelink('Command', 'set_idle_mode');
        Eyelink('Command', 'clear_screen 0');
        status= Eyelink('ImageTransfer', 'disp.bmp', 0, 0, 0, 0,0, 0, 16);
        
        %% Present Gaze-box:
        stimuliOn= gazeBox(stimuliOn, gazeBnds_x, gazeBnds_y);
        
    end
    
    %% Present text stimuli:
    
    Screen('CopyWindow', Monitor.buffer(2), Monitor.window);
    Screen('Flip', Monitor.window);
	trialStart= GetSecs;
    
    while ~trialEnd
        trialTime= GetSecs- trialStart;
        [x,y,buttons] = GetMouse(Monitor.window);
        trialEnd= buttons(1); %KbCheck; 
        
        % use this for gaze-contingent manipulations:
        %evt= Eyelink('NewestFloatSample');
        %xpos = evt.gx(2);

        
        if const.seeEye % for testing only (enable code above)
            Screen('FillRect', Monitor.window, Visual.BGC);
            Screen('DrawText', Monitor.window, sentenceString, Visual.sentPos(1), Visual.sentPos(2), Visual.FGC); % sentence
            Screen('DrawDots', Monitor.window, [xpos, 540], 10, [0 0 0], [],2);
            Screen('Flip', Monitor.window);
        end
        
        % end trial automatically if no response by participant
        if trialTime> const.TrialTimeout 
             trialEnd= true;
             %tracker.log('TRIAL ABORTED')
 			 Screen('FillRect', Monitor.window, Visual.BGC); % clear subject screen
             Screen('Flip', Monitor.window);
        end
        
     end
    
    Screen('FillRect', Monitor.window, Visual.BGC); % clear subject screen
    Screen('Flip', Monitor.window);
    Eyelink('command', 'clear_screen 0'); % clear tracker screen	
	
	% end of trial messages:
    Eyelink('Message', 'ENDBUTTON 5');
    Eyelink('Message', 'DISPLAY OFF');
    Eyelink('Message', 'TRIAL_RESULT 5');
    Eyelink('Message', 'TRIAL OK');

    Eyelink('StopRecording');
    
    
     %% Questioms:
     if strcmp(sent(item).ans1, '')==0
         switch frame
             case 1
                 quest= sent(item).quest1;
                 corr_ans= sent(item).ans1;
             case 2
                 quest= sent(item).quest2;
                 corr_ans= sent(item).ans2;
             case 3
                 quest= sent(item).quest3;
                 corr_ans= sent(item).ans3;
         end
         
         answer= Question(quest, corr_ans, item, cond);
     end
    
    
end