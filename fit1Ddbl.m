function [fittracex fittracey tracex tracey fitparx fitpary] = fitdblgaussian1D...
    (ODimage,imagestack,saveinig1D,fitframeno,xc,yc,dx,dy,mask,process_args)

if nargin < 10
    process_args = struct();
end

if nargin<9 || isempty(mask)
    if fitframeno == 1
        tracex=sum(ODimage(round(yc-((dy-1)/2)):round(yc+((dy-1)/2)),round(xc-((dx-1)/2)):round(xc+((dx-1)/2))),1);
        tracey=sum(ODimage(round(yc-((dy-1)/2)):round(yc+((dy-1)/2)),round(xc-((dx-1)/2)):round(xc+((dx-1)/2))),2);
    else
        tracex=sum(imagestack(round(yc-((dy-1)/2)):round(yc+((dy-1)/2)),round(xc-((dx-1)/2)):round(xc+((dx-1)/2)),fitframeno+1),1);
        tracey=sum(imagestack(round(yc-((dy-1)/2)):round(yc+((dy-1)/2)),round(xc-((dx-1)/2)):round(xc+((dx-1)/2)),fitframeno+1),2);
    end
else
    if fitframeno == 1
        tracex=sum(ODimage(round(yc-((dy-1)/2)+mask(3)):round(yc-((dy-1)/2)+mask(4)),round(xc-((dx-1)/2)):round(xc+((dx-1)/2))),1);
        tracey=sum(ODimage(round(yc-((dy-1)/2)):round(yc+((dy-1)/2)),round(xc-((dx-1)/2)+mask(1)):round(xc-((dx-1)/2)+mask(2))),2);
    else
        tracex=sum(imagestack(round(yc-((dy-1)/2)+mask(3)):round(yc-((dy-1)/2)+mask(4)),round(xc-((dx-1)/2)):round(xc+((dx-1)/2)),fitframeno+1),1);
        tracey=sum(imagestack(round(yc-((dy-1)/2)):round(yc+((dy-1)/2)),round(xc-((dx-1)/2)+mask(1)):round(xc-((dx-1)/2)+mask(2)),fitframeno+1),2);
    end
end

tracey=tracey';
p(1)=saveinig1D.nx;
p(2)=saveinig1D.wx;
p(3)=saveinig1D.xc;
p(4)=(mask(2)-mask(1))/4;
q(1)=saveinig1D.ny;
q(2)=saveinig1D.wy;
q(3)=saveinig1D.yc;
q(4)=0;
p(5)=saveinig1D.bg;
q(5)=p(4);

p(1) = max(tracex(mask(1):mask(2)));
p(2) = (mask(2)-mask(1))/10;
p(3) = (mask(1)+mask(2))/2;
p(4) = (mask(2)-mask(1))/4;
p(5) = mean(tracex([1:(mask(1)-1) (mask(2)+1):numel(tracex)]));


q(1) = max(tracey(mask(3):mask(4)));
q(2) = (mask(4)-mask(3))/10;
q(3) = (mask(3)+mask(4))/2;
q(4) = 0;
q(5) = mean(tracey([1:(mask(3)-1) (mask(4)+1):numel(tracey)]));


options = optimset('TolX',1e-8,'Display','off');

x=1:length(tracex);
y=1:length(tracey);

% plb = [0 0 max(x)*0.4 1.25*min(tracex)-0.25*max(tracex)];
% qlb = [0 0 max(y)*0.4 1.25*min(tracey)-0.25*max(tracey)];
plb = [0 0 0 0 1.25*min(tracex)-0.25*max(tracex) ];
qlb = [0 0 0 0 1.25*min(tracey)-0.25*max(tracey) ];

if isfield(process_args,'xlb')
    plb = max(plb,process_args.xlb);
%     plb = process_args.xlb;
end

if isfield(process_args,'ylb')
    qlb = max(qlb,process_args.ylb);
%     qlb = process_args.ylb;
end

% pub = [1.25*(max(tracex)-min(tracex)) max(x)/8 max(x)*0.6 mean(tracex)];
% qub = [1.25*(max(tracey)-min(tracey)) max(y)/8 max(y)*0.6 mean(tracey)];
pub = [2.5*(max(tracex)-min(tracex)) max(x) Inf max(x) mean(tracex) ];
qub = [2.5*(max(tracey)-min(tracey)) max(y) Inf .1 mean(tracey) ];

if isfield(process_args,'xub')
    pub = min(pub,process_args.xub);
%     pub = process_args.xub;
end

if isfield(process_args,'yub')
    qub = min(qub,process_args.yub);
%     qub = process_args.yub;
end

p(p < plb) = plb(p < plb);
p(p > pub) = pub(p > pub);
q(q < qlb) = qlb(q < qlb);
q(q > qub) = qub(q > qub);

if any(isnan(p)) || any(isnan(q))
    
end

pfit = lsqcurvefit(@g1D,p,x,tracex,plb,pub,options);
qfit = lsqcurvefit(@g1D,q,y,tracey,qlb,qub,options);
% if pfit(1)*pfit(2)<15
%     p(3) = 200;
%     pfit = lsqcurvefit(@g1D,p,x,tracex,plb,pub,options);
% end
% if pfit(1)*pfit(2)<15
%     p(3) = 100;
%     pfit = lsqcurvefit(@g1D,p,x,tracex,plb,pub,options);
% end
% [pfit pfval pexitflag]=fminsearch(@(v) fitg1D(v,tracex),p,options);
% [qfit qfval qexitflag]=fminsearch(@(v) fitg1D(v,tracey),q,options);

if fitg1D([pfit(1) pfit(2) pfit(3) 0 pfit(5)],tracex)<fitg1D(pfit,tracex) || fitg1D([2*pfit(1) pfit(2) pfit(3) 0 pfit(5)],tracex)<fitg1D(pfit,tracex)
    [pfit pfval pexitflag]=fminsearch(@(v) fitg1D(v,tracex),[pfit(1) pfit(2) pfit(3) 0 pfit(5)],options);
elseif fitg1D([2*pfit(1) pfit(2) pfit(3)+pfit(4)/2 0 pfit(5)],tracex)<fitg1D(pfit,tracex) || fitg1D([pfit(1) pfit(2) pfit(3)+pfit(4)/2 0 pfit(5)],tracex)<fitg1D(pfit,tracex)
    [pfit pfval pexitflag]=fminsearch(@(v) fitg1D(v,tracex),[pfit(1) pfit(2) pfit(3)+pfit(4)/2 0 pfit(5)],options);
elseif fitg1D([2*pfit(1) pfit(2) pfit(3)-pfit(4)/2 0 pfit(5)],tracex)<fitg1D(pfit,tracex) || fitg1D([pfit(1) pfit(2) pfit(3)-pfit(4)/2 0 pfit(5)],tracex)<fitg1D(pfit,tracex)
    [pfit pfval pexitflag]=fminsearch(@(v) fitg1D(v,tracex),[pfit(1) pfit(2) pfit(3)-pfit(4)/2 0 pfit(5)],options);
end

fittracex=pfit(1)*exp(-(x-(pfit(3)+pfit(4)/2)).^2/2/pfit(2)^2)/2+pfit(1)*exp(-(x-(pfit(3)-pfit(4)/2)).^2/2/pfit(2)^2)/2+pfit(5);
fittracey=qfit(1)*exp(-(y-(qfit(3)+qfit(4)/2)).^2/2/qfit(2)^2)/2+qfit(1)*exp(-(y-(qfit(3)-qfit(4)/2)).^2/2/qfit(2)^2)/2+qfit(5);
fitparx.name='nx';
fitparx.fitval=pfit(1);
fitparx.inival=p(1);
fitparx(2).name='wx';
fitparx(2).fitval=pfit(2);
fitparx(2).inival=p(2);
fitparx(3).name='xc';
fitparx(3).fitval=pfit(3);
fitparx(3).inival=p(3);
fitparx(4).name='sepx';
fitparx(4).fitval=pfit(4);
fitparx(4).inival=p(4);
fitparx(5).name='bgx';
fitparx(5).fitval=pfit(5);
fitparx(5).inival=p(5);

fitpary.name='ny';
fitpary.fitval=qfit(1);
fitpary.inival=q(1);
fitpary(2).name='wy';
fitpary(2).fitval=qfit(2);
fitpary(2).inival=q(2);
fitpary(3).name='yc';
fitpary(3).fitval=qfit(3);
fitpary(3).inival=q(3);
fitpary(4).name='sepy';
fitpary(4).fitval=qfit(4);
fitpary(4).inival=q(4);
fitpary(5).name='bgy';
fitpary(5).fitval=qfit(5);
fitpary(5).inival=q(5);


function f = fitg1D(v,u)
x=1:length(u);
g1D = v(1)*exp(-(x-(v(3)+v(4)/2)).^2/2/(v(2)^2))/2+v(1)*exp(-(x-(v(3)-v(4)/2)).^2/2/(v(2)^2))/2+v(5);
f=sum((u-g1D).^2);

% figure(3)
% plot(x,u)
% hold on
% plot(x,g1D,'r--')
% hold off

function f = g1D(v,x)
f = v(1)*exp(-(x-(v(3)+v(4)/2)).^2/2/(v(2)^2))/2+v(1)*exp(-(x-(v(3)-v(4)/2)).^2/2/(v(2)^2))/2+v(5);

