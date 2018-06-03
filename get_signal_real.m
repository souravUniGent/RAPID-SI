function [complex_fid]=get_signal_real()

global details_para;
global data_value;

temp = strcat(path,'\*.IMA');  %initial path for loading file with .SPAR extension
[flnane1, path1] = uigetfile(temp);
ima_filename = strcat(path1,flnane1);
fd = dicom_open(ima_filename);
% advance the field to the appropriate place
% in the file
field_length = dicom_move(fd, '7FE1', '1010');

field_size = field_length / 4;

% we can use fread to read data in as floats
[fid, fid_size] = fread(fd, field_size, 'float32','ieee-le');
 
if( fid_size ~= field_size )
     fprintf('\nWarning: field size was %d and %d elements were read.', field_size, fid_size);
end

real_part = zeros(length(fid)/2, 1);
imag_part = real_part;

% sort into two columns or make complex
k = 1;
for n = 1:1:length(fid)
    if mod(n,2)
        real_part(k) = fid(n);
    else
        imag_part(k) = fid(n);
        k = k + 1;
    end
end

complex_fid = real_part + j*imag_part;
data_value.FID_FD=fftshift(fft(conj(complex_fid)));
details_para.Fs= 1200;
details_para.fres= (-(details_para.Fs)/2 + ((details_para.Fs)/(size(data_value.FID_FD,1)*1))*(0:((size(data_value.FID_FD,1)*1-1))));
details_para.t= (1:size(data_value.FID_FD,1))./details_para.Fs;
details_para.PE= 3;
details_para.RE=1;
details_para.Tf = 127776603;
details_para.ref = 4.7;
ppm = (details_para.fres)*(1E6/details_para.Tf);
details_para.ppm =  ppm;
details_para.ppm_referenced = details_para.ppm + details_para.ref ;
% plot(details_para.ppm_referenced,abs(data_value.FID_FD));