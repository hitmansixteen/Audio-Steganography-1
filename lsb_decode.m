function decodedText = lsb_decode(wavin, text)
    str = text{1};  
    messageLength = length(str);

    [stegoAudio, fs] = audioread(wavin);

    % Normalize audio data back to 8-bit
    stegoAudio = stegoAudio - min(stegoAudio);
    stegoAudio = stegoAudio / max(stegoAudio);
    stegoAudio = uint8(stegoAudio * 255);

    % Extract the least significant bits from the audio data
    binaryMessage = '';
    for i = 1:(messageLength * 8) % Each ASCII character is 8 bits
        binaryMessage = [binaryMessage, num2str(bitget(stegoAudio(i), 1))];
    end

    % Convert binary message to characters
    binaryMessage = reshape(binaryMessage, 8, [])'; % Reshape to 8 bits per character
    asciiValues = bin2dec(binaryMessage); % Convert binary to decimal
    decodedText = char(asciiValues)'; % Convert ASCII values to character
end
