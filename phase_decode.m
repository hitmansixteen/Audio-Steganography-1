% Decoding function (modified to work with GUI)
function decodedMessage = phase_decode(audioLocation)
    % Read encoded audio
    [audioData, ~] = audioread(audioLocation);
    
    textLength = 800; % 100 characters * 8 bits
    blockLength = 2 * int32(2^ceil(log2(2 * textLength)));
    blockMid = blockLength/2;
    
    % Extract phase information
    if size(audioData, 2) == 1
        code = audioData(1:blockLength);
    else
        code = audioData(1:blockLength, 1);
    end
    
    % Get phases and convert to binary
    codePhases = angle(fft(code));
    codePhases = codePhases(blockMid-textLength+1:blockMid);
    codeInBinary = double(codePhases < 0);
    
    % Convert binary to characters
    decodedMessage = '';
    powers = 2.^(7:-1:0)';
    
    for i = 1:8:length(codeInBinary)
        if i+7 <= length(codeInBinary)
            binGroup = codeInBinary(i:i+7);
            decValue = sum(binGroup .* powers);
            if decValue > 0 && decValue <= 127
                decodedMessage = [decodedMessage char(decValue)];
            end
        end
    end
    
    % Remove padding
    decodedMessage = strrep(decodedMessage, '~', '');
end