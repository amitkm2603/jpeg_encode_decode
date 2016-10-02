function Qx=quality(quality_factor,Q)
if quality_factor >= 50
    scaling_factor = (100-quality_factor)/50;
else
    scaling_factor = (50/quality_factor);
end

if quality_factor == 0
    scaling_factor = 0;
end

if scaling_factor == 0 
    Qx = Q; % no quantization
else % if qf is not 100
    Qx = round( Q*scaling_factor );
end
% Qx = uint8(Qx);
end