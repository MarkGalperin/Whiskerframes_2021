tpath = "C:\Users\kklec\Desktop\Hartmann\KS0355B_25mar17\KS0355B_Num46_03-25-17-1.tif";

oimg = loadtiff(tpath);

outputVideo = VideoWriter('out');
open(outputVideo);

for ii = 1:length(oimg)
   img = oimg(:,:,ii);
   writeVideo(outputVideo,img)
end

close(outputVideo);
