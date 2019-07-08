function [img_points]=selectImagePoints(bank,noise, fp)

image=bank('image');
cnoise=[noise,noise]+[1,1];
angle=linspace(0,2*pi,50);
x=cnoise(1)+noise*cos(angle); y=cnoise(2)+noise*sin(angle);
imshow(image);
hold on;
plot(x,y,'r');

selected=bank('selected');
tags=bank('tags');

pc=containers.Map;
img_points=[];
imp=[];
for i=1:length(selected)
    segment_name=tags(i);
    mess=strcat("Adding imgage point of ", segment_name);
    htext=text(0,50,mess,'Color','white');
    point=ginput(1);
    p1=impoint(gca,point(1),point(2));
    imp=[imp,p1];
    pc(char(segment_name))=point;
    pause(0.2);
    delete(htext);
end
htext=text(0,50,"Proceed to fine tune the points. Press 'n' to continue.",'Color','white');
while true
    w=waitforbuttonpress;
    
    if w==1 && fp.CurrentCharacter=='n'
        
        for i=1:length(imp)
            img_points=[img_points;getPosition(imp(i)),1];   
        
        end
                break
    end
end

bank('pc')=pc;
end