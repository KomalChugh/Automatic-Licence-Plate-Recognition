image= 'sample28';

rgbimg= imread([image '.jpg']);
rgbimg= imresize(rgbimg, [1305,2320]);
[initrow,intitcol]= size(rgbimg);
greyimg= rgb2gray(rgbimg);
B= imgaussfilt(greyimg,2.5);
fun = @(x) x(1,1)*-1 + x(1,2)*-2 + x(1,3)*-1 + x(3,1)*1 + x(3,2)*2 + x(3,3)*1;
BW= edge(B,'sobel',[],'vertical');
%imshowpair(rgbimg,BW,'montage');
se= strel('rectangle',[8,32]);
afterClosing = imclose(BW,se);
checkcount=0;
BW2= afterClosing;
%imshow(BW2);
stats = [regionprops(BW2); regionprops(not(BW2))];
%imshow(rgbimg); 
%hold on;
for i = 1:numel(stats)
    aspect_ratio = stats(i).BoundingBox(1, 3) / stats(i).BoundingBox(1, 4);
    area= stats(i).BoundingBox(1, 3)*stats(i).BoundingBox(1, 4);
    left= stats(i).BoundingBox(1,1) + 0.5;
    top= stats(i).BoundingBox(1,2) + 0.5;
    width= stats(i).BoundingBox(1,3);
    height= stats(i).BoundingBox(1,4);
                %rectangle('Position', stats(i).BoundingBox, ...
               % 'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
    if (aspect_ratio>2.5 && aspect_ratio<8 && area>5000 && area<500000 && top>initrow/5)
        checkcount= checkcount+1;
        whitecount=0;
        totalcount=0;
        for j= left:left+width-2
            for k=top:top+height-2
                if (BW2(k,j)==1)
                    whitecount=whitecount+1;
                end
                totalcount=totalcount+1;
            end
        end
        pixelratio= whitecount/totalcount;
        if (pixelratio>0.1)
            plate= imcrop(greyimg,[left,top,width,height]);
            T = adaptthresh(plate,0.65);
            plateBW= imbinarize(plate,T);
             [a,b,c]= untitled2(plateBW);
             tf= isempty(b);
             if (tf==1)
                 continue;
             end
             startIndex= regexp(b,'\w');
             startIndex2= regexp(b,'\d');
             [indexrow,indexcol]=size(startIndex);
             [indexrow2,indexcol2]=size(startIndex2);
            %rectangle('Position', stats(i).BoundingBox, ...
             % 'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
             if (indexcol>7 && indexcol<12 && indexcol2>4 && indexcol2<7)
                  break;
             end
        end
    end
end
figure;
imshowpair(rgbimg,a,'montage');
text(0,0,b,'BackgroundColor',[1 1 1],'FontSize',50);
fid = fopen('result.txt','wt');
fprintf(fid, [b '\n']);
fclose(fid);