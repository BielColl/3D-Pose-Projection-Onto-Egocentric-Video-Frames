function response=RTcontrolDial(vframe,up,low)
    if nargin==0
        vframe=100;
        up=vframe; low=vframe+50;
    end
    d=dialog('Position',[10,400,350,300],'Name', 'Control', 'WindowStyle', 'normal');
    
    %Translations
    txt=uicontrol('Parent',d, 'Style', 'text',...
        'Position',[20,250,65,40], 'String','Translations');
    %x
    xtext=uicontrol('Parent',d, 'Style', 'text',...
        'Position',[20,230,30,30], 'String','X:');
    xp = uicontrol('Parent',d,...
        'Position',[50,240,30,30],'String','+');
    xn = uicontrol('Parent',d,...
        'Position',[80,240,30,30],'String','-');
    %y
    
    ytext=uicontrol('Parent',d, 'Style', 'text',...
        'Position',[110,230,30,30], 'String','Y:');
    yp = uicontrol('Parent',d,...
        'Position',[140,240,30,30],'String','+');
    yn = uicontrol('Parent',d,...
        'Position',[170,240,30,30],'String','-');
    
    %z
    ztext=uicontrol('Parent',d, 'Style', 'text',...
        'Position',[20,190,30,30], 'String','Z:');
    zp = uicontrol('Parent',d,...
        'Position',[50,200,30,30],'String','+');
    zn = uicontrol('Parent',d,...
        'Position',[80,200,30,30],'String','-');
    
    %value
    tedit=uicontrol('Parent',d,'Style','edit','Position',[250,245,50,20],'String','5');
    tetext=uicontrol('Parent',d,'Style','text','Position',[245,270,40,15],'String','In mm:');
    

    %Rotations
    txt=uicontrol('Parent',d, 'Style', 'text',...
        'Position',[20,150,55,40], 'String','Rotations');
    %x
    xtext=uicontrol('Parent',d, 'Style', 'text',...
        'Position',[20,130,30,30], 'String','X:');
    rxp = uicontrol('Parent',d,...
        'Position',[50,140,30,30],'String','+');
    rxn = uicontrol('Parent',d,...
        'Position',[80,140,30,30],'String','-');
    %y
    
    ytext=uicontrol('Parent',d, 'Style', 'text',...
        'Position',[110,130,30,30], 'String','Y:');
    ryp = uicontrol('Parent',d,...
        'Position',[140,140,30,30],'String','+');
    ryn = uicontrol('Parent',d,...
        'Position',[170,140,30,30],'String','-');
    
    %z
    ztext=uicontrol('Parent',d, 'Style', 'text',...
        'Position',[20,90,30,30], 'String','Z:');
    rzp = uicontrol('Parent',d,...
        'Position',[50,100,30,30],'String','+');
    rzn = uicontrol('Parent',d,...
        'Position',[80,100,30,30],'String','-');
    
    %value
    redit=uicontrol('Parent',d,'Style','edit','Position',[250,145,50,20],'String','1');
    tetext=uicontrol('Parent',d,'Style','text','Position',[245,170,30,15],'String','In º :');
    %Ok 
    
    ok=uicontrol('Parent',d,'Position',[300,45,40,30],'String','Ok','CallBack',@okresp);
    
    %reset
    reset=uicontrol('Parent',d','Position',[300,15,40,30],'String','Reset','Callback',@resetresp);
    
    %move frames
    ftext=uicontrol('Parent',d,'Position',[20,60,75,30],'Style','text','String','Change frame:');
    fmm=uicontrol('Parent',d,'Position',[80,45,30,30],'String','<<','CallBack',@frameresp);
    fm=uicontrol('Parent',d,'Position',[110,45,30,30],'String','<','CallBack',@frameresp);
    fp=uicontrol('Parent',d,'Position',[140,45,30,30],'String','>','CallBack',@frameresp);
    fpp=uicontrol('Parent',d,'Position',[170,45,30,30],'String','>>','CallBack',@frameresp);
    
    %select frame
    fsel=uicontrol('Parent',d,'Position',[80,25,50,20],'Style','edit','String',num2str(vframe));
    selbut=uicontrol('Parent',d,'Position',[130,25,30,20],'String','Go','CallBack',@framesel);
    
    %preview
    ptext=uicontrol('Parent',d,'Position',[20,8,45,15],'Style','text','String','Preview');
    plow=uicontrol('Parent',d,'Position',[80,8,50,15],'Style','edit','String',num2str(low));
    pskip=uicontrol('Parent',d,'Position',[130,8,20,15],'Style','edit','String',num2str(2));
    pup=uicontrol('Parent',d,'Position',[150,8,50,15],'Style','edit','String',num2str(up));
    pbut=uicontrol('Parent',d,'Position',[200,6,50,20],'String','Show','CallBack',@preview);
    translations=[xp,xn,yp,yn,zp,zn];
    tnames={'txp','txn','typ','tyn','tzp','tzn'};
    rotations=[rxp,rxn,ryp,ryn,rzp,rzn];
    rnames={'rxp','rxn','ryp','ryn','rzp','rzn'};
    
    for i=1:length(translations)
        translations(i).Callback= @tres;
    end
    
    for i=1:length(rotations)
        rotations(i).Callback= @rres;
    end
    
    
    
    function s=getvarname(var)
        s=inputname(var);
    end
    function tres(src,event)
        idx=find(translations==src);
        val=tedit.String;
        response=strcat(string(tnames(idx)),"_",val);
        close(d);
    end
    function rres(src,event)
        idx=find(rotations==src);
        val=redit.String;
        response=strcat(string(rnames(idx)),"_",val);
        close(d);
    end
    function okresp(src,event)
        response="exit";
        close(d);
    end
    
    function frameresp(src,event)
        a=src.String;
        if length(a)==2
            if a(1)=='<'
                response="fmmf";
            else
                response="fppf";
            end
                
        else
            if a(1)=='<'
                response="fmff";
            else
                response="fpff";
            end
            
        end
        close(d)
    end
    
    function framesel(src,event)
        frame=fsel.String;
        response=strcat("sel",frame);
        close(d);
    end
    function resetresp(src,event)
        response="reset";
        close(d);
    end
    function preview(src,event)
        up=pup.String; low=plow.String; skip=pskip.String;
        response=string(strcat('p_',low,'_',skip,'_',up));
        close(d);
    end
        
    uiwait(d);
end