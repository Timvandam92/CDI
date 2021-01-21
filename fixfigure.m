function [f]=fixfigure(f,varargin)
%% Figure specs
fig_width   = 14.6600;  % cm
fig_height  =  7.0000;  % cm
fntname     = 'Roboto';
fntsize     = 8;
fntlabsize  = 9;
xxshift     = 0;
yyshift     = 0;

%% Axes specs
axwidth     = 0.6;      % Total width of (all) axes
axheight    = 0.75;     % Total height of (all) axes
fixsubplt   = 1;        % Automatically position subplot axes

%% Read specified input
if nargin>1    
    for i=1:length(varargin)
        if strcmp(varargin(i),'fig_width') || strcmp(varargin(i),'Fig_width')
            fig_width=varargin(i+1); fig_width=fig_width{1};
        elseif strcmp(varargin(i),'fig_height') || strcmp(varargin(i),'Fig_height')
            fig_height=varargin(i+1); fig_height=fig_height{1};
        elseif strcmp(varargin(i),'width') || strcmp(varargin(i),'Width')
            axwidth=varargin(i+1); axwidth=min(axwidth{1},0.9);
        elseif strcmp(varargin(i),'height') || strcmp(varargin(i),'Height')
            axheight=varargin(i+1); axheight=min(axheight{1},0.9);
        elseif strcmp(varargin(i),'fixsubplot') || strcmp(varargin(i),'Fixsubplot')
            fixsubplt=varargin(i+1); fixsubplt=fixsubplt{1};
        elseif strcmp(varargin(i),'xxshift')
            xxshift=varargin(i+1); xxshift=xxshift{1};
        elseif strcmp(varargin(i),'yyshift')
            yyshift=varargin(i+1); yyshift=yyshift{1};
        elseif strcmp(varargin(i),'fnt_size')
            fntsize=varargin(i+1); fntsize=fntsize{1};
        elseif strcmp(varargin(i),'fntname')
            fntname=varargin(i+1); fntname=fntname{1}
        end
    end
end

%% Automatically fix subplot positions? yes (1) or no (0):
if isstr(fixsubplt)
    if strncmp(fixsubplt,'y',1) || strncmp(fixsubplt,'Y',1) || strcmp('On',fixsubplt) || strcmp('on',fixsubplt)
        fixsubplt   = 1;
    else
        fixsubplt   = 0;
    end
end

%% Count number of axes -> store axes in AX
nax = 0;  % Number of axes
for i=1:length(f.Children)
    try f.Children(i).XLim;
        clsi=class(f.Children(i));
        if strcmp('matlab.graphics.illustration.ColorBar',clsi)
            continue
        end
        nax=nax+1;
        AX{nax}=f.Children(i);
    end
end

%% Set up figure correctly
f.Units             = 'centimeters';
f.Position          = [0.3000 0.3000 fig_width fig_height];
f.Renderer          = 'painters';
f.PaperPositionMode = 'Auto';
f.PaperUnits        = 'centimeters';
f.PaperSize         = [1.00*fig_width 1.00*fig_height];


%% Fix all axes of the figure
for i=1:length(AX)
    axi                 = AX{i};
    axi.FontName        = fntname;
    axi.FontSize        = fntsize;
%     axi.XLabel.FontSize = fntlabsize;
    axi.XColor          = [0 0 0];
    axi.YColor          = [0 0 0];
    clss                = class(axi);
    if strcmp('matlab.graphics.illustration.ColorBar',clss)
        continue
    end
    axi.Layer           = 'top';
    if fixsubplt == 1
        try axi.Position    = axposxy(i,:);
        catch
            axposxy         = calcaxposxy(AX,axwidth,axheight);
        end
    else
        axposxy(i,:)        = axi.Position;
    end
    axposxy(i,1)    = axposxy(i,1)+xxshift;
    axposxy(i,2)    = axposxy(i,2)+yyshift;
    axi.Position    = axposxy(i,:);
end


%% Check if figure contains subplot(s)
% function [subpltxy]=issubplt(AX)
%     subpltxy = [0, 0];
%     if length(AX)>1
%         for i=1:length(AX)
%             axi=AX{i};
%             posi=axi.Position;
%             xmin(i)=posi(1);            % min of x-position
%             xmax(i)=posi(1)+posi(2);    % max of x-position
%             ymin(i)=posi(3);            % min of y-position
%             ymax(i)=posi(3)+posi(4);    % max of y-position
%         end
%         if min(xmax)>max(xmin)
%             subpltxy(1)=1;              % subplot in x-dir
%         end
%         if min(xmax)>max(xmin)
%             subpltxy(2)=1;              % subplot in y-dir
%         end
%     end
% end


%% Calculate position of all axes to match axheight and axwidth
function [axpos_xy]=calcaxposxy(AX,axwidth,axheight)
adx = 0.20; ady = 0.20;
DX  = 0.5*(1-axwidth);
DY  = 0.5*(1-axheight);
ylb = 0;
xlb = 0;
tit = 0;
for ii=1:length(AX)
    posi=AX{ii}.Position;
    xmin(ii)=posi(1);            % min of x-position
    xmax(ii)=posi(1)+posi(3);    % max of x-position
    ymin(ii)=posi(2);            % min of y-position
    ymax(ii)=posi(2)+posi(4);    % max of y-position
    if ~isempty(AX{ii}.YLabel.String)
        ylb = 1;
    end
    if ~isempty(AX{ii}.XLabel.String)
        xlb = 1;
    end
    if ~isempty(AX{ii}.Title.String)
        tit = 1;
    end
end
xlb=xlb-0.5*tit;
xmins   = sort(unique(xmin));   nx=length(xmins);
ymins   = sort(unique(ymin));   ny=length(ymins);
if nx == 1
    adx     = 0;
    dxi     = 0;
    widthi  = axwidth;
else
    widthi  = axwidth/(nx+adx);     dxi=adx/(nx-1)*widthi;
end
if ny == 1
    ady     = 0;
    dyi     = 0;
    heighti = axheight;
else
    heighti = axheight/(ny+ady);    dyi=ady/(ny-1)*heighti;
end
for ii=1:length(AX)
    ndx=find(xmins==xmin(ii))-1;
    ndy=find(ymins==ymin(ii))-1;
    xshift  = ndx*(widthi+dxi)+0.04*axwidth*ylb;
    yshift  = ndy*(heighti+dyi)+0.1*axheight*xlb;
    axpos_xy(ii,1:4)  = [DX+xshift, DY+yshift, widthi, heighti];
end