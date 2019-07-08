function bank = editBank(bank)
% This function lets one edit the selected image points in the frames
% The only input is the bank containing the video frames and the
% coordinates of the image points
vframes=cell2mat(bank.keys);
fe=figure('name','edit');

for i=vframes
    fbank=bank(i);
    pc=fbank('pc');
    image=fbank('image');
    labels=pc.keys;
    
    
    imshow(image);hold on;
    impoints=[];
    for j=1:length(labels)
        l=char(labels(j));
        img=pc(l); p1=impoint(gca,img(1),img(2));
        impoints=[impoints,p1];
    end
    while true
        w=waitforbuttonpress;
        if w==1 && fe.CurrentCharacter=='n'
             for j=1:length(labels)
                l=char(labels(j));
                movp=impoints(j);
                pc(l)=getPosition(movp);
             end
            break
        end
    end
        
end

close(fe);
end