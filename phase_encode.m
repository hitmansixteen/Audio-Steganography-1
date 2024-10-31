% Encoding function (modified to work with GUI)
function outputPath = phase_encode(pathToAudio, stringToEncode)
    % Read audio file
    [audioData1, rate] = audioread(pathToAudio);
    
    % Pad message with '~' to ensure uniform length
    stringToEncode = pad(stringToEncode, 100, 'right', '~');
    
    % Calculate text length and chunk size
    textLength = 8 * length(stringToEncode);
    chunkSize = int32(2 * 2^ceil(log2(2 * textLength)));
    numberOfChunks = int32(ceil(size(audioData1, 1) / chunkSize));
    
    % Copy and resize audio data
    audioData = audioData1;
    if size(audioData1, 2) == 1
        audioData(numberOfChunks * chunkSize, 1) = 0;
        audioData = audioData';
    else
        audioData(numberOfChunks * chunkSize, size(audioData, 2)) = 0;
        audioData = audioData';
    end
    
    % Reshape audio into chunks
    chunks = reshape(audioData(1, :), chunkSize, [])';
    
    % Apply FFT
    chunks = fft(chunks, [], 2);
    magnitudes = abs(chunks);
    phases = angle(chunks);
    phaseDiff = diff(phases, 1, 1);
    
    % Convert message to binary
    textInBinary = [];
    for i = 1:length(stringToEncode)
        binStr = dec2bin(uint8(stringToEncode(i)), 8);
        textInBinary = [textInBinary str2num(binStr')'];
    end
    
    % Convert binary to phase differences
    textInPi = double(textInBinary);
    textInPi(textInPi == 0) = -1;
    textInPi = textInPi * -pi/2;
    
    % Find middle of chunk
    midChunk = chunkSize/2;
    
    % Embed message in phase differences
    phases(1, midChunk-textLength+1:midChunk) = textInPi;
    phases(1, midChunk+2:midChunk+1+textLength) = -fliplr(textInPi);
    
    % Recompute phase matrix
    for i = 2:size(phases, 1)
        phases(i, :) = phases(i-1, :) + phaseDiff(i-1, :);
    end
    
    % Apply inverse Fourier transform
    chunks = magnitudes .* exp(1j * phases);
    chunks = real(ifft(chunks, [], 2));
    
    % Reconstruct audio data
    audioData(1, :) = reshape(chunks', 1, []);
    
    % Save encoded audio
    outputPath = [tempname '.wav'];
    audiowrite(outputPath, audioData', rate);
end