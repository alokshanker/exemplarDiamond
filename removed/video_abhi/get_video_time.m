function nsec = get_video_time(mname)

lenstring = sprintf(['/nfs/baikal/tmalisie/ffmpeg/ffmpeg-0.6/ffmpeg -i' ...
                    ' %s 2>&1 | grep Duration'], mname);
[tmp,lenstring] = unix(lenstring);
commas = find(lenstring==',');
commas = commas(1);
f = strfind(lenstring,'Duration:');
lenstring = lenstring(f+10:commas-1);
seps = find(lenstring==':');
hour = sscanf(lenstring(1:seps(1)-1),'%d');
minute = sscanf(lenstring(seps(1)+1:seps(2)-1),'%d');
second = sscanf(lenstring(seps(2)+1:end),'%f');
nsec = hour*3600+minute*60+second;
end