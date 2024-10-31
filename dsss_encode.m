function outputPath = dsss_encode(audioFile, message)
    [audioData, fs] = audioread(audioFile);

    stegoSignal = dsss_enc(audioData, message);
    
    % Generate a temporary file path for the output encoded file
    outputPath = [tempname '.wav'];
    audiowrite(outputPath, stegoSignal, fs);
end

    

function out = dsss_enc(signal, text, L_min)
    %DSSS_ENC is the function to hide data in audio using "conventional"
    %   Direct Sequence Spread Spectrum technique in time domain. 
    %
    %   INPUTS VARIABLES
    %       signal : Cover signal
    %       text   : Message to hide
    %       L_min  : Minimum segment length
    %
    %   OUTPUTS VARIABLES
    %       out    : Stego signal
    
    if nargin < 3
        L_min = 8*1024;  %Setting a minimum value for segment length
    end
    
    
    [s.len, s.ch] = size(signal);
    bit = getBits(text);             %char -> binary sequence
    L2  = floor(s.len/length(bit));  %Length of segments
    L   = max(L_min, L2);            %Keeping length of segments big enough
    nframe = floor(s.len/L);
    N = nframe - mod(nframe, 8);     %Number of segments (for 8 bits)
    
    if (length(bit) > N)
        warning('Message is too long, is being cropped...');
        bits = bit(1:N);
    else
        bits = [bit, num2str(zeros(N-length(bit), 1))'];
    end
    
    %Note: Choose r = prng('password', L) to use a pseudo random sequence
    r = ones(L,1);
    %r = prng('password', L);                %Generating pseudo random sequence
    pr = reshape(r * ones(1,N), N*L, 1);  %Extending size of r up to N*L
    alpha = 0.005;                          %Embedding strength
    
    %%%%%%%%%%%%%%%%%%%%%%% EMBEDDING MESSAGE... %%%%%%%%%%%%%%%%%%%%%%%%
    [mix, datasig] = mixer(L, bits, -1, 1, 256);
    out = signal;
    stego = signal(1:N*L,1) + alpha * mix.*pr;     %Using first channel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    out(:,1) = [stego; signal(N*L+1:s.len,1)];     %Adding rest of signal
    
end
    
    function out = prng( key, L )
        pass = sum(double(key).*(1:length(key)));
        rand('seed', pass);
        out = 2*(rand(L, 1)>0.5)-1;
    end

    function bin_seq = getBits(text)
    matrix  = dec2bin(uint8(text),8);
    bin_seq = reshape(matrix', 1, 8*length(text));
    end

    function [ w_sig, m_sig ] = mixer( L, bits, lower, upper, K )
    %MIXER is to create a mixer signal to spread smoothed data easier.
    %
    %   INPUTS VARIABLES
    %       L     : Length of segment
    %       bits  : Binary sequence (1xm char)
    %       K     : Length to be smoothed
    %       upper : Upper bound of mixer signal
    %       lower : Lower bound of mixer signal
    %
    %   OUTPUTS VARIABLES
    %       m_sig : Mixer signal to spread data
    %       w_sig : Smoothed mixer signal
    %
    
    if (nargin < 4)
        lower = 0;
        upper = 1;
    end
    
    if (nargin < 5) || (2*K > L)
	    K = floor(L/4) - mod(floor(L/4), 4);
    else
        K = K - mod(K, 4);                       %Divisibility by 4
    end
    
    N = length(bits);                            %Number of segments
    encbit = str2num(reshape(bits, N, 1))';      %char -> double
    m_sig  = reshape(ones(L,1)*encbit, N*L, 1);  %Mixer signal
    c      = conv(m_sig, hann(K));            %Hann windowing
    wnorm  = c(K/2+1:end-K/2+1) / max(abs(c));   %Normalization
    w_sig  = wnorm * (upper-lower)+lower;        %Adjusting bounds
    m_sig  = m_sig * (upper-lower)+lower;        %Adjusting bounds
    
end

