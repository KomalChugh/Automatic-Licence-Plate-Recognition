function [outputArg1,outputArg2,outputArgtemp] = untitled2(plateBW)
outputArgtemp=plateBW;
plateBW=imresize(plateBW,[519 1315]);
[m,n]= size(plateBW);
arr= zeros(m,n,15);
plateBW2= imcomplement(plateBW);
plateBW3= bwareafilt(plateBW2,[500 50000]);
se=strel('disk',1);
plateBW3= imerode(plateBW3,se);
BW3= plateBW3;

stats = [regionprops(BW3); regionprops(not(BW3))];
% show the image and draw the detected rectangles on it
%imshow(plateBW3); 
%hold on;
current_index=1;
for i = 1:numel(stats)
    aspect_ratio = stats(i).BoundingBox(1, 3) / stats(i).BoundingBox(1, 4);
    area= stats(i).BoundingBox(1, 3)*stats(i).BoundingBox(1, 4);
    left= stats(i).BoundingBox(1,1) + 0.5;
    top= stats(i).BoundingBox(1,2) + 0.5;
    width= stats(i).BoundingBox(1,3);
    height= stats(i).BoundingBox(1,4);
    if (aspect_ratio<0.95 && aspect_ratio>0 && area>100 && area<1000000 && width>20 && height>80) 
        whitecount=0;
        totalcount=0;
        for j= left:left+width-1
            for k=top:top+height-1
                if (BW3(k,j)==1)
                    whitecount=whitecount+1;
                end
                totalcount=totalcount+1;
            end
        end
        pixelratio= whitecount/totalcount;
        if (pixelratio>0.1)
            temp= zeros(m,n);
            for j= left:left+width-1
                for k=top:top+height-1
                    if (BW3(k,j)==1)
                        temp(k,j)=1;
                    end
                end
            end
            arr(:,:,current_index)= temp;
            current_index=current_index+1;
            %   rectangle('Position', stats(i).BoundingBox, ...
            %      'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
        end
    end
end
plateBW4=zeros(m,n);
for i=1:15
    plateBW4=plateBW4+arr(:,:,i);
end
%plateBW4= platetemp;
%imshow(plateBW4);
%imshow(arr(:,:,5));
se3=strel('disk',1);
plateBW4= imerode(plateBW4,se3);
plateBW4= imresize(plateBW4,[1038 2630]);

ocrResult= ocr(plateBW4,'CharacterSet', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789','TextLayout', 'Line');
results=ocrResult;
highConfidenceIdx= results.CharacterConfidences > 0.5;

recognizedText= ocrResult.Text(highConfidenceIdx);
outputArg1 = plateBW4;
outputArg2 = recognizedText;
end

