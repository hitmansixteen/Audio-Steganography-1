clc;
clear;

function audio_steg_gui
    % Create a figure window for the GUI
    fig = uifigure('Position', [100, 100, 800, 600], 'Name', 'Audio Steganography');
    
    % Input Section (Transmitter side)
    uilabel(fig, 'Text', 'Transmitter (Steganography Sender)', 'Position', [20, 550, 200, 22], 'FontWeight', 'bold');
    
    uilabel(fig, 'Text', 'Enter Secret Text Here:', 'Position', [20, 510, 150, 22]);
    messageField = uitextarea(fig, 'Position', [180, 500, 250, 30]);

    % Generate Random Text Button
    uibutton(fig, 'Text', 'Generate Random', 'Position', [440, 500, 120, 30], 'ButtonPushedFcn', @(btn, event) generateRandomText());
    
    uibutton(fig, 'Text', 'Select Audio file', 'Position', [20, 460, 150, 30], 'ButtonPushedFcn', @(btn, event) selectAudio());
    uibutton(fig, 'Text', 'Embed', 'Position', [180, 460, 100, 30], 'ButtonPushedFcn', @(btn, event) encodeAudio(messageField.Value));
    uibutton(fig, 'Text', 'Save Stego Audio', 'Position', [290, 460, 120, 30], 'ButtonPushedFcn', @(btn, event) saveStegoAudio());
    
     % Parameters for encoding
    uilabel(fig, 'Text', 'Input Parameters', 'Position', [20, 420, 150, 22], 'FontWeight', 'bold');
    
    % Technique Selector Field
    uilabel(fig, 'Text', 'Select Steganography Technique:', 'Position', [20, 390, 200, 22]);
    techniqueSelector = uidropdown(fig, 'Position', [220, 390, 150, 30], 'Items', {'DSSS', 'Echo', 'Phase', 'LSB'});
    
    
    % Output Parameters
    uilabel(fig, 'Text', 'Output Parameters', 'Position', [400, 420, 150, 22], 'FontWeight', 'bold');
    uilabel(fig, 'Text', 'Capacity:', 'Position', [400, 390, 100, 22]);
    capacityLabel = uilabel(fig, 'Position', [500, 390, 100, 22], 'Text', '---');
    
    uilabel(fig, 'Text', 'PSNR:', 'Position', [400, 360, 100, 22]);
    psnrLabel = uilabel(fig, 'Position', [500, 360, 100, 22], 'Text', '---');
    
    uilabel(fig, 'Text', 'MSE:', 'Position', [400, 330, 100, 22]);
    mseLabel = uilabel(fig, 'Position', [500, 330, 100, 22], 'Text', '---');
    
    uilabel(fig, 'Text', 'SNR:', 'Position', [400, 300, 100, 22]);
    snrLabel = uilabel(fig, 'Position', [500, 300, 100, 22], 'Text', '---');
    
    % Spectrograms
    ax1 = uiaxes(fig, 'Position', [20, 150, 350, 150]);
    ax2 = uiaxes(fig, 'Position', [400, 150, 350, 150]);
    
    % Receiver Section
    uilabel(fig, 'Text', 'Receiver (Steganography Receiver)', 'Position', [20, 100, 200, 22], 'FontWeight', 'bold');
    
    uibutton(fig, 'Text', 'Select Stego file', 'Position', [20, 60, 150, 30], 'ButtonPushedFcn', @(btn, event) selectStegoFile());
    uibutton(fig, 'Text', 'Extract', 'Position', [180, 60, 100, 30], 'ButtonPushedFcn', @(btn, event) decodeAudio());
    uibutton(fig, 'Text', 'Save Secret Text', 'Position', [290, 60, 120, 30], 'ButtonPushedFcn', @(btn, event) saveSecretText());
    
    uilabel(fig, 'Text', 'Recovered Secret Text:', 'Position', [20, 20, 150, 22]);
    decodedLabel = uilabel(fig, 'Position', [180, 20, 250, 22], 'Text', '---');



    % Global variables to store audio paths and results
    global audioFile encodedFile decodedMessage;

    % Create Play Buttons for Original Audio
    uibutton(fig, 'Text', 'Play Original Audio', 'Position', [420, 460, 150, 30], 'ButtonPushedFcn', @(btn, event) playAudio(audioFile));
    
    % Create Play Buttons for Stego Audio
    uibutton(fig, 'Text', 'Play Stego Audio', 'Position', [420, 60, 150, 30],'ButtonPushedFcn', @(btn, event) playAudio(encodedFile));

    % Function to generate a random alphanumeric string
    function generateRandomText()
        characters = ['A':'Z', 'a':'z', '0':'9'];  % Alphanumeric characters
        randomString = characters(randi(numel(characters), [1, 10]));  % Generate random string of length 10
        messageField.Value = randomString;  % Set the value in the message field
    end

    % Function to play audio
    function playAudio(filePath)
        if isempty(filePath)
            uialert(fig, 'Please select an audio file first!', 'No Audio Selected');
            return;
        end
        
        % Use the sound function to play the audio file
        [y, Fs] = audioread(filePath);
        sound(y, Fs);
    end

    % Function to select original audio
    function selectAudio()
        [file, path] = uigetfile('*.wav', 'Select an audio file');
        if isequal(file, 0)
            disp('User selected Cancel');
        else
            audioFile = fullfile(path, file);
            disp(['User selected ', audioFile]);
            [y, Fs] = audioread(audioFile);
            plotSpectrogram(ax1, y, Fs, 'Original Audio');
        end
    end

    % Function to select stego file
    function selectStegoFile()
        [file, path] = uigetfile('*.wav', 'Select a stego file');
        if isequal(file, 0)
            disp('User selected Cancel');
        else
            encodedFile = fullfile(path, file);
            disp(['User selected ', encodedFile]);
            [y, Fs] = audioread(encodedFile);
            plotSpectrogram(ax2, y, Fs, 'Stego Audio');
        end
    end

    % Function to save stego audio
    function saveStegoAudio()
        [file, path] = uiputfile('*.wav', 'Save Stego Audio As');
        if isequal(file, 0)
            disp('User selected Cancel');
        else
            stegoFilePath = fullfile(path, file);
            copyfile(encodedFile, stegoFilePath);
            disp(['Stego audio saved to ', stegoFilePath]);
        end
    end

    % Function to save secret text
    function saveSecretText()
        [file, path] = uiputfile('*.txt', 'Save Secret Text As');
        if isequal(file, 0)
            disp('User selected Cancel');
        else
            textFilePath = fullfile(path, file);
            fid = fopen(textFilePath, 'w');
            fprintf(fid, '%s', decodedMessage);
            fclose(fid);
            disp(['Secret text saved to ', textFilePath]);
        end
    end

    % Function to encode audio
    function encodeAudio(message)
        if isempty(audioFile)
            uialert(fig, 'Please select an audio file first!', 'No Audio Selected');
            return;
        end
        
        % Convert message to string if it's a cell array
        if iscell(message)
            message = strjoin(message, '');
        end
        
        % Validate message
        if isempty(message)
            uialert(fig, 'Please enter a message to encode!', 'No Message');
            return;
        end
        
        %try
            % Get the selected technique
            selectedTechnique = techniqueSelector.Value;  % Assuming techniqueSelector is your dropdown
            
            % Check which technique is selected and call the appropriate function
            if strcmp(selectedTechnique, 'DSSS')
                encodedFile = dsss_encode(audioFile, message); % Call the DSSS encoding function
            elseif strcmp(selectedTechnique, 'Echo')
                encodedFile = echo_encode(audioFile, message); % Call the Echo encoding function
            elseif strcmp(selectedTechnique, 'Phase')
                encodedFile = phase_encode(audioFile, message); % Call the Phase encoding function
            elseif strcmp(selectedTechnique, 'LSB')
                encodedFile = lsb_encode(audioFile, message);
                
            else
                uialert(fig, 'Invalid technique selected!', 'Error');
                return;
            end
       
            % Plot spectrogram of encoded audio
            [y, Fs] = audioread(encodedFile);
            plotSpectrogram(ax2, y, Fs, 'Stego Audio');
        
            % Calculate and display metrics
            [mse, psnr, snr, capacity] = calculateMetrics(audioFile, encodedFile);
            mseLabel.Text = num2str(mse);
            psnrLabel.Text = num2str(psnr);
            snrLabel.Text = num2str(snr);
            capacityLabel.Text = num2str(capacity);
        
            uialert(fig, 'Message successfully encoded.', 'Success', 'Icon', 'success');
        %catch ME
            %uialert(fig, ['Encoding failed: ' ME.message], 'Error', 'Icon', 'error');
        %end
    end



    % Function to decode audio
    function decodeAudio()
        if isempty(encodedFile)
            uialert(fig, 'Please select a stego audio file first!', 'No Audio Selected');
            return;
        end
        
        % Retrieve the selected technique from the dropdown (or any other UI element)
        technique = techniqueSelector.Value; % Assuming you have a dropdown named techniqueSelector
    
        try
            switch technique
                case 'DSSS'
                    msg = messageField.Value;
                    decodedMessage = dsss_decode(encodedFile, msg);
                case 'Echo'
                    decodedMessage = echo_decode(encodedFile);
                case 'Phase'
                    decodedMessage = phase_decode(encodedFile);
                case 'LSB'
                    msg = messageField.Value;
                    decodedMessage = lsb_decode(encodedFile, msg);
     
            
                otherwise
                    uialert(fig, 'Invalid technique selected!', 'Error', 'Icon', 'error');
                    return;
            end
            
            decodedLabel.Text = decodedMessage;
            uialert(fig, 'Message successfully decoded.', 'Success', 'Icon', 'success');
        catch ME
            uialert(fig, ['Decoding failed: ' ME.message], 'Error', 'Icon', 'error');
        end
    end


    % Function to plot spectrogram (Fixed version)
    function plotSpectrogram(ax, y, Fs, titleText)
        window = hamming(256);
        noverlap = 250;
        nfft = 256;
        
        % Clear the axis
        cla(ax);
        
        % Calculate spectrogram
        [s, f, t] = spectrogram(y, window, noverlap, nfft, Fs);
        
        % Plot using surface
        surf(ax, t, f, 10*log10(abs(s)), 'EdgeColor', 'none');
        view(ax, 0, 90);
        
        % Set axis properties
        title(ax, titleText);
        xlabel(ax, 'Time (s)');
        ylabel(ax, 'Frequency (Hz)');
        colorbar(ax);
        
        % Adjust colormap and axis settings
        colormap(ax, 'jet');
        axis(ax, 'tight');
    end

    % Function to calculate metrics
    function [mse, psnr, snr, capacity] = calculateMetrics(originalFile, encodedFile)
        [origAudio, Fs] = audioread(originalFile);
        [encodedAudio, ~] = audioread(encodedFile);
        
        % Ensure both signals have the same length
        minLength = min(length(origAudio), length(encodedAudio));
        origAudio = origAudio(1:minLength);
        encodedAudio = encodedAudio(1:minLength);
        
        % Calculate MSE
        mse = mean((origAudio - encodedAudio).^2);
        
        % Calculate PSNR
        maxVal = max(abs(origAudio));
        psnr = 20 * log10(maxVal / sqrt(mse));
        
        % Calculate SNR
        signalPower = mean(origAudio.^2);
        noisePower = mean((origAudio - encodedAudio).^2);
        snr = 10 * log10(signalPower / noisePower);
        
        % Calculate capacity (in bits)
        capacity = length(encodedAudio) * 16;  % Assuming 16 bits per sample
    end
end


audio_steg_gui();