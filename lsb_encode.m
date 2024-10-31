function stego_audio = lsb_encode(audioFileName, message)
    % Read the audio file
    [audioData, fs] = audioread(audioFileName);

    % Normalize audio data between 0 and 255 (8-bit for simplicity)
    audioData = audioData - min(audioData);
    audioData = audioData / max(audioData);
    audioData = uint8(audioData * 255); % Convert to 8-bit audio data

    % Convert the message to ASCII values
    asciiValues = double(message);
    
    % Convert ASCII values to binary
    binaryMessage = dec2bin(asciiValues, 8)'; % Transpose to get column vector
    binaryMessage = binaryMessage(:)'; % Convert matrix to a row vector

    % Check if the message can fit into the audio
    numSamples = length(audioData);
    if length(binaryMessage) > numSamples
        error('Message is too long to fit in the audio.');
    end

    % Embed the message in the least significant bit of the audio samples
    for i = 1:length(binaryMessage)
        % Set the LSB of the audio sample to the message bit
        audioData(i) = bitset(audioData(i), 1, str2double(binaryMessage(i)));
    end
    
    [filepath, name, ext] = fileparts(audioFileName);
    outputFileName = fullfile(filepath, [name '_stego' ext]);
    audiowrite(outputFileName, double(audioData)/255, fs); % Normalize back to [0, 1]
    
    stego_audio = outputFileName;
    
end