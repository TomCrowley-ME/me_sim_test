Stewart-Platform-Forward-Kinematics-Solver-master/._src                                             000777  000766  000024  00000000336 12520305664 024431  0                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                             Mac OS X            	   2   �      �                                      ATTR       �   �   F                  �   F  com.apple.quarantine q/0001;56435b72;Google\x20Chrome;E50871A0-D630-428A-ADC3-01581D83508B                                                                                                                                                                                                                                                                                                   Stewart-Platform-Forward-Kinematics-Solver-master/src/                                              000777  000766  000024  00000000000 12520305664 024264  5                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                         Stewart-Platform-Forward-Kinematics-Solver-master/src/._coordtrans.m                                000777  000766  000024  00000000336 12520305664 027042  0                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                             Mac OS X            	   2   �      �                                      ATTR       �   �   F                  �   F  com.apple.quarantine q/0001;56435b72;Google\x20Chrome;E50871A0-D630-428A-ADC3-01581D83508B                                                                                                                                                                                                                                                                                                   Stewart-Platform-Forward-Kinematics-Solver-master/src/coordtrans.m                                  000777  000766  000024  00000004406 12520305664 026627  0                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                         % Filename: coordtrans.m
% Author: Akihiko Kumagai
% Co-Author: Joe Brown, California State University, Sacramento  8/04/2006
% Description: This file contains a function to transform coordinate systems used in the forward kinematics analysis based on the Lee�s paper to those used in the CDSL Stewart platform system.
% Definitions of frames A, B, G, M, and N used in this program are given in the report: Kumagai, A and Brown, J.P �Development of a Closed Form Forward Kinematics Analysis Program for the 6-DOF CDSL Stewart Platform,� Aug. 2006.
% Descriptions of transformation matrices:
% 	TGA: translation matrix from Frame G to Frame A
% 	TMB: translation matrix from Frame M to Frame B
% 	TBA: transformation (translation + rotation) matrix from Frame B to Frame A.
% 	TGA: translation matrix from Frame G to Frame N
% Descriptions of vectors:
% rm: the vector from the origin of Frame N to that of Frame M
% pm: position vector with respect to Frame M
% TXrad, TYrad, and TZrad rotation angles are Euler angels THE6(1), THE6(2), and THE6(3), respectively. The THE6 vectors are described in the FORTRAN simulation programs for the 6-DOF Stewart platform.

function coordtrans_return=coordtrans(TXdeg,TYdeg,TZdeg,px,py,pz,XSI,YSI,XMI,YMI)
    TXrad=TXdeg*pi/180;
    TYrad=TYdeg*pi/180;
    TZrad=TZdeg*pi/180;
 
    TGA=[1,0,0,-XSI(1);
         0,1,0,-YSI(1);
         0,0,1,0;
         0,0,0,1];

    TMB=[1,0,0,-XMI(1);
         0,1,0,-YMI(1);
         0,0,1,0;
         0,0,0,1];

    TBA =[cos(TYrad)*cos(TZrad),                                 -cos(TYrad)*sin(TZrad),                                  sin(TYrad),           px;
          sin(TXrad)*sin(TYrad)*cos(TZrad)+cos(TXrad)*sin(TZrad),-sin(TXrad)*sin(TYrad)*sin(TZrad)+cos(TXrad)*cos(TZrad),-sin(TXrad)*cos(TYrad),py;
         -cos(TXrad)*sin(TYrad)*cos(TZrad)+sin(TXrad)*sin(TZrad), cos(TXrad)*sin(TYrad)*sin(TZrad)+sin(TXrad)*cos(TZrad), cos(TXrad)*cos(TYrad),pz;
          0,                                                      0,                                                      0,                    1 ];

    TGN=[1 0 0 0; 
         0 1 0 0; 
         0 0 1 111.31];
     
    TAG=inv(TGA);
    
    pm=[0;0;0;1];
    
    rm=vpa(TGN*TAG*TBA*TMB*pm);
    
    coordtrans_return=rm;

                                                                                                                                                                                                                                                          Stewart-Platform-Forward-Kinematics-Solver-master/src/._formdata.txt                                000777  000766  000024  00000000336 12621364610 027042  0                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                             Mac OS X            	   2   �      �                                      ATTR       �   �   F                  �   F  com.apple.quarantine q/0001;56435b72;Google\x20Chrome;E50871A0-D630-428A-ADC3-01581D83508B                                                                                                                                                                                                                                                                                                   Stewart-Platform-Forward-Kinematics-Solver-master/src/formdata.txt                                  000777  000766  000024  00000001460 12621364610 026624  0                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                            5.9140000e+01
   7.8000000e+01
   5.9140000e+01
  -7.8000000e+01
   3.7980000e+01
  -9.0220000e+01
  -9.7120000e+01
  -1.2220000e+01
  -9.7120000e+01
   1.2220000e+01
   3.7980000e+01
   9.0220000e+01
   8.3140000e+01
   3.0000000e+00
   8.3140000e+01
  -3.0000000e+00
  -3.8970000e+01
  -7.3500000e+01
  -4.4170000e+01
  -7.0500000e+01
  -4.4170000e+01
   7.0500000e+01
  -3.8970000e+01
   7.3500000e+01
  -1.0000000e+02
   1.0000000e+02
  -1.0000000e+02
   1.0000000e+02
  -1.0000000e+02
   1.0000000e+02
  -1.0000000e+02
   1.0000000e+02
  -1.0000000e+02
   1.0000000e+02
  -2.0000000e+02
   2.0000000e+02
   1.0000000e+02
   1.1689100e+02
   1.6210600e+02
   1.1689000e+02
   1.6210400e+02
   1.1689100e+02
   0.0000000e+00
   0.0000000e+00
  -4.0000000e+01
   0.0000000e+00
   0.0000000e+00
   0.0000000e+00
                                                                                                                                                                                                                Stewart-Platform-Forward-Kinematics-Solver-master/src/._stew.m                                      000777  000766  000024  00000000336 12621364537 025654  0                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                             Mac OS X            	   2   �      �    MATFMATL                          ATTR       �   �   F                  �   F  com.apple.quarantine q/0001;56435b72;Google\x20Chrome;E50871A0-D630-428A-ADC3-01581D83508B                                                                                                                                                                                                                                                                                                   Stewart-Platform-Forward-Kinematics-Solver-master/src/stew.m                                        000777  000766  000024  00000136051 12621364537 025443  0                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                         % Filename: stew.m
% Author: Joe Brown, California State University, Sacramento  8/04/2006
% Description: This file contains a function to carry out GUI operation of the closed form forward kinematics analysis program for the 6-DOF CDSL Stewart platform.

function stewsolve(fcn)
clc
if nargin == 0
    fcn = 'stew';
end
switch fcn

case 'stew'%this is the initial case, which is the figure set up and initialization of all the GUI elements.
    
    plotinfo.myname = mfilename;
    %--------------------------------------------------------------Main Window
    fig = figure('Position',centerfig(600,600),...
    'Resize','off',...
    'NumberTitle','off',...
    'Name','Stewart Platform Kinematics Solver',...
    'Interruptible','off',...
    'Menubar','none',...
    'Color',get(0,'DefaultUIControlBackgroundColor'));
    %------------------------------------------------------------------Axes
    plotinfo.ax = axes('Units','pixels',...
        'Position',[170 50 350 350],...
        'Visible','off');
    %-----------------------------------------------------------Entry Boxes
    %----------Base coordinates
    uicontrol(gcf,'Style','text','String','xsi','Position',[70,588,20,10]);
    uicontrol(gcf,'Style','text','String','ysi','Position',[125,586,20,12]);
    uicontrol(gcf,'Style','text','String','Base 1:','Position',[5,567,50,10]);
        plotinfo.base1x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,560,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);
        plotinfo.base1y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[110,560,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);
    uicontrol(gcf,'Style','text','String','Base 2:','Position',[5,542,50,10]);
        plotinfo.base2x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,535,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);
        plotinfo.base2y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[110,535,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);
    uicontrol(gcf,'Style','text','String','Base 3:','Position',[5,517,50,10]);
        plotinfo.base3x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,510,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);
        plotinfo.base3y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[110,510,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);
    uicontrol(gcf,'Style','text','String','Base 4:','Position',[5,492,50,10]);
        plotinfo.base4x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,485,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);
        plotinfo.base4y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[110,485,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);
    uicontrol(gcf,'Style','text','String','Base 5:','Position',[5,467,50,10]);
        plotinfo.base5x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,460,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);
        plotinfo.base5y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[110,460,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);
    uicontrol(gcf,'Style','text','String','Base 6:','Position',[5,442,50,10]);
        plotinfo.base6x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,435,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);
        plotinfo.base6y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[110,435,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' base']);

    %---------------platform coordinates
    uicontrol(gcf,'Style','text','String','xmi','Position',[270,588,20,10]);
    uicontrol(gcf,'Style','text','String','ymi','Position',[325,586,20,12]);
    uicontrol(gcf,'Style','text','String','Platform 1:','Position',[200,567,50,10]);
        plotinfo.plat1x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[255,560,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);
        plotinfo.plat1y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[310,560,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);
    uicontrol(gcf,'Style','text','String','Platform 2:','Position',[200,542,50,10]);
        plotinfo.plat2x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[255,535,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);
        plotinfo.plat2y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[310,535,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);
    uicontrol(gcf,'Style','text','String','Platform 3:','Position',[200,517,50,10]);
        plotinfo.plat3x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[255,510,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);
        plotinfo.plat3y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[310,510,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);
    uicontrol(gcf,'Style','text','String','Platform 4:','Position',[200,492,50,10]);
        plotinfo.plat4x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[255,485,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);
        plotinfo.plat4y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[310,485,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);
    uicontrol(gcf,'Style','text','String','Platform 5:','Position',[200,467,50,10]);
        plotinfo.plat5x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[255,460,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);
        plotinfo.plat5y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[310,460,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);
    uicontrol(gcf,'Style','text','String','Platform 6:','Position',[200,442,50,10]);
        plotinfo.plat6x=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[255,435,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);
        plotinfo.plat6y=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[310,435,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' plat']);

    %---------------Constraints
    uicontrol(gcf,'Style','text','String','Constraints','Position',[410,588,65,10]);
    uicontrol(gcf,'Style','text','String','min','Position',[490,588,20,10]);
    uicontrol(gcf,'Style','text','String','max','Position',[546,588,20,10]);
    uicontrol(gcf,'Style','text','String','Roll(x):','Position',[420,567,50,12]);
        plotinfo.rollmin=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[475,560,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);
        plotinfo.rollmax=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[530,560,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);
    uicontrol(gcf,'Style','text','String','Pitch(y):','Position',[420,542,50,12]);
        plotinfo.pitchmin=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[475,535,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);
        plotinfo.pitchmax=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[530,535,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);
    uicontrol(gcf,'Style','text','String','Yaw(z):','Position',[420,517,50,12]);
        plotinfo.yawmin=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[475,510,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);
        plotinfo.yawmax=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[530,510,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);
    uicontrol(gcf,'Style','text','String','X:','Position',[420,492,50,10]);
        plotinfo.pxmin=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[475,485,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);
        plotinfo.pxmax=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[530,485,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);
    uicontrol(gcf,'Style','text','String','Y:','Position',[420,467,50,10]);
        plotinfo.pymin=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[475,460,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);
        plotinfo.pymax=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[530,460,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);
    uicontrol(gcf,'Style','text','String','Z:','Position',[420,442,50,10]);
        plotinfo.pzmin=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[475,435,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);
        plotinfo.pzmax=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[530,435,50,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' constraints']);

    %-------------------Leg lengths
    uicontrol(gcf,'Style','text','String','Leg 1:','Position',[5,388,50,15]);
        plotinfo.leg1=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,385,70,20],...
        'BackgroundColor',[.8,1,1], ...
        'CallBack',[plotinfo.myname,' legs']);
    uicontrol(gcf,'Style','text','String','Leg 2:','Position',[5,362,50,15]);
        plotinfo.leg2=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,360,70,20],...
        'BackgroundColor',[.8,1,1], ...
        'CallBack',[plotinfo.myname,' legs']);
    uicontrol(gcf,'Style','text','String','Leg 3:','Position',[5,338,50,15]);
        plotinfo.leg3=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,335,70,20],...
        'BackgroundColor',[.8,1,1], ...
        'CallBack',[plotinfo.myname,' legs']);
    uicontrol(gcf,'Style','text','String','Leg 4:','Position',[5,313,50,15]);
        plotinfo.leg4=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,310,70,20],...
        'BackgroundColor',[.8,1,1], ...
        'CallBack',[plotinfo.myname,' legs']);
    uicontrol(gcf,'Style','text','String','Leg 5:','Position',[5,288,50,15]);
        plotinfo.leg5=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,285,70,20],...
        'BackgroundColor',[.8,1,1], ...
        'CallBack',[plotinfo.myname,' legs']);
    uicontrol(gcf,'Style','text','String','Leg 6:','Position',[5,263,50,15]);
        plotinfo.leg6=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,260,70,20],...
        'BackgroundColor',[.8,1,1], ...
        'CallBack',[plotinfo.myname,' legs']);
    
    %-------------------Angles and position of table                 
    uicontrol(gcf,'Style','text','String','Roll(x):','Position',[5,192,50,12]);
        plotinfo.roll=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,185,70,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' tablepos']);
    uicontrol(gcf,'Style','text','String','Pitch(y):','Position',[5,167,50,12]);
        plotinfo.pitch=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,160,70,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' tablepos']);
    uicontrol(gcf,'Style','text','String','Yaw(z):','Position',[5,142,50,12]);
        plotinfo.yaw=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,135,70,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' tablepos']);
    uicontrol(gcf,'Style','text','String','X:','Position',[5,117,50,10]);
        plotinfo.Pxval=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,110,70,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' tablepos']);
    uicontrol(gcf,'Style','text','String','Y:','Position',[5,92,50,10]);
        plotinfo.Pyval=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,85,70,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' tablepos']);
    uicontrol(gcf,'Style','text','String','Z:','Position',[5,67,50,10]);
        plotinfo.Pzval=uicontrol(gcf,'Style','edit', ...
        'String','0',...
        'Position',[55,60,70,20],...
        'BackgroundColor',[1,1,1], ...
        'CallBack',[plotinfo.myname,' tablepos']);

    %------------------------------------------------------------Quit button
    uicontrol('Style','pushbutton',...
        'Position',[540,10,45,25],...
        'String','Quit',...
        'Interruptible','off',...
        'BusyAction','cancel',...
        'Callback',[plotinfo.myname,' quit']);
    %-------------------------------------------------------save button
        plotinfo.save_me=uicontrol('Style','pushbutton',...
        'Position',[540,40,45,25],...
        'String','Save',...
        'Interruptible','off',...
        'BusyAction','cancel',...
        'Callback',[plotinfo.myname,' save_me']);
    %-------------------------------------------------------Solve Forward
    plotinfo.sol_for=uicontrol('Style','pushbutton',...
        'Position',[45,220,85,25],...
        'String','Solve Forward',...
        'Interruptible','off',...
        'BusyAction','cancel',...
        'Callback',[plotinfo.myname,' solve_for']);
    %-------------------------------------------------------Solve Inverse
    plotinfo.sol_inv=uicontrol('Style','pushbutton',...
        'Position',[45,20,85,25],...
        'String','Solve Inverse',...
        'Interruptible','off',...
        'BusyAction','cancel',...
        'Callback',[plotinfo.myname,' solve_inv']);
    %-------------------------------------------------------solution buttons
    plotinfo.prevsol=uicontrol('Style','pushbutton',...
        'Position',[290,10,25,20],...
        'String','<<',...
        'Visible','off',...
        'Interruptible','off',...
        'BusyAction','cancel',...
        'Callback',[plotinfo.myname,' prevsol']);
    plotinfo.solutions_text=uicontrol(gcf,'Style','text','String',' ','Position',[315,17,70,10],'Visible','off');
    plotinfo.nextsol=uicontrol('Style','pushbutton',...
        'Position',[380,10,25,20],...
        'String','>>',...
        'Visible','off',...
        'Interruptible','off',...
        'BusyAction','cancel',...
        'Callback',[plotinfo.myname,' nextsol']);
    %-------------------------------------------------animate select button
    plotinfo.animate_but=uicontrol(gcf,'Style','checkbox', ...
      'String','Animate?',...
      'Value',1,...
      'Position',[450,15,70,20]);
    %-------------------------------------------save data in window data area
    set(fig,'UserData',plotinfo);
    %----------------------Load data from txt file 
    load_data()
    %----------------------draw intial plot
    initial_coords=[str2num(get(plotinfo.plat1x,'String')),str2num(get(plotinfo.plat1y,'String')),111.31-str2num(get(plotinfo.Pzval,'String')),...
                    str2num(get(plotinfo.plat2x,'String')),str2num(get(plotinfo.plat2y,'String')),111.31-str2num(get(plotinfo.Pzval,'String')),...
                    str2num(get(plotinfo.plat3x,'String')),str2num(get(plotinfo.plat3y,'String')),111.31-str2num(get(plotinfo.Pzval,'String')),...
                    str2num(get(plotinfo.plat4x,'String')),str2num(get(plotinfo.plat4y,'String')),111.31-str2num(get(plotinfo.Pzval,'String')),...
                    str2num(get(plotinfo.plat5x,'String')),str2num(get(plotinfo.plat5y,'String')),111.31-str2num(get(plotinfo.Pzval,'String')),...
                    str2num(get(plotinfo.plat6x,'String')),str2num(get(plotinfo.plat6y,'String')),111.31-str2num(get(plotinfo.Pzval,'String'))];
    draw_plat(initial_coords)
    view([-45,35])
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Callbacks  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

case 'solve_for'
    plotinfo=get(gcf,'UserData');
    color_input_box(1);
    set(plotinfo.sol_for,'String','Working...');
    pause(1)
    solve_forward();    
    set(plotinfo.sol_for,'String','Solve Forward');
    
case 'solve_inv'
    plotinfo=get(gcf,'UserData');
    color_input_box(2);
    set(plotinfo.prevsol,'Visible','off')
    set(plotinfo.nextsol,'Visible','off')
    set(plotinfo.solutions_text,'Visible','off')
    set(plotinfo.sol_inv,'String','Working...');
    pause(1)
    solve_inverse();
    set(plotinfo.sol_inv,'String','Solve Inverse');

case 'prevsol'
    plotinfo=get(gcf,'UserData');
    if plotinfo.current_solution > 1
        plotinfo.current_solution=plotinfo.current_solution-1;
        set(plotinfo.roll,'String',double(plotinfo.solutions(plotinfo.current_solution,1)))%set roll/pitch/yaw fields to first solution
        set(plotinfo.pitch,'String',double(plotinfo.solutions(plotinfo.current_solution,2)))
        set(plotinfo.yaw,'String',double(plotinfo.solutions(plotinfo.current_solution,3)))
        set(plotinfo.Pxval,'String',double(plotinfo.solutions(plotinfo.current_solution,4)))
        set(plotinfo.Pyval,'String',double(plotinfo.solutions(plotinfo.current_solution,5)))
        set(plotinfo.Pzval,'String',double(plotinfo.solutions(plotinfo.current_solution,6)))
        set(plotinfo.nextsol,'Visible','on')
    end
    if plotinfo.current_solution==1
        set(plotinfo.prevsol,'Visible','off')
    end
    solve_inverse()
    set(gcf,'UserData',plotinfo);
    
case 'nextsol'
    plotinfo=get(gcf,'UserData');
    if plotinfo.current_solution < plotinfo.num_solutions
        plotinfo.current_solution=plotinfo.current_solution+1;
        set(plotinfo.roll,'String',double(plotinfo.solutions(plotinfo.current_solution,1)))%set roll/pitch/yaw fields to first solution
        set(plotinfo.pitch,'String',double(plotinfo.solutions(plotinfo.current_solution,2)))
        set(plotinfo.yaw,'String',double(plotinfo.solutions(plotinfo.current_solution,3)))
        set(plotinfo.Pxval,'String',double(plotinfo.solutions(plotinfo.current_solution,4)))
        set(plotinfo.Pyval,'String',double(plotinfo.solutions(plotinfo.current_solution,5)))
        set(plotinfo.Pzval,'String',double(plotinfo.solutions(plotinfo.current_solution,6)))
        set(plotinfo.prevsol,'Visible','on')
    end
    if plotinfo.current_solution == plotinfo.num_solutions
        set(plotinfo.nextsol,'Visible','off')
    end
    solve_inverse()
    set(gcf,'UserData',plotinfo);
        
case 'base'
    %disp('base')
case 'plat'
    %disp('plat')
case 'legs'
    color_input_box(1)
    %disp('legs')
case 'constraints'
    %disp('constraints')
case 'tablepos'
    color_input_box(2)
    %disp('tablepos')
case 'save_me'
    save_data()  
case 'quit'
   disp('quit')
   fig = gcf;
   quit_reply = questdlg('Are you sure you want to quit?');
   if strcmp(quit_reply,'Yes')
      save_data()
      close(fig);
   end    
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    FUNCTIONS    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function pos = centerfig(width,height)
        screen_s = get(0,'ScreenSize');
        pos = [screen_s(3)/2 - width/2, screen_s(4)/2 - height/2, width, height];


    function save_data()
        plotinfo=get(gcf,'UserData'); %load form data into plotinfo 
        base=[str2num(get(plotinfo.base1x,'String')) %save all the info for save to file
              str2num(get(plotinfo.base1y,'String'))
              str2num(get(plotinfo.base2x,'String')) 
              str2num(get(plotinfo.base2y,'String'))
              str2num(get(plotinfo.base3x,'String')) 
              str2num(get(plotinfo.base3y,'String'))
              str2num(get(plotinfo.base4x,'String')) 
              str2num(get(plotinfo.base4y,'String'))
              str2num(get(plotinfo.base5x,'String')) 
              str2num(get(plotinfo.base5y,'String'))
              str2num(get(plotinfo.base6x,'String')) 
              str2num(get(plotinfo.base6y,'String'))];
        plat=[str2num(get(plotinfo.plat1x,'String')) 
              str2num(get(plotinfo.plat1y,'String'))
              str2num(get(plotinfo.plat2x,'String')) 
              str2num(get(plotinfo.plat2y,'String'))
              str2num(get(plotinfo.plat3x,'String')) 
              str2num(get(plotinfo.plat3y,'String'))
              str2num(get(plotinfo.plat4x,'String')) 
              str2num(get(plotinfo.plat4y,'String'))
              str2num(get(plotinfo.plat5x,'String')) 
              str2num(get(plotinfo.plat5y,'String'))
              str2num(get(plotinfo.plat6x,'String')) 
              str2num(get(plotinfo.plat6y,'String'))];
        cnst=[str2num(get(plotinfo.rollmin,'String')) 
              str2num(get(plotinfo.rollmax,'String'))
              str2num(get(plotinfo.pitchmin,'String')) 
              str2num(get(plotinfo.pitchmax,'String'))
              str2num(get(plotinfo.yawmin,'String')) 
              str2num(get(plotinfo.yawmax,'String'))
              str2num(get(plotinfo.pxmin,'String')) 
              str2num(get(plotinfo.pxmax,'String'))
              str2num(get(plotinfo.pymin,'String')) 
              str2num(get(plotinfo.pymax,'String'))
              str2num(get(plotinfo.pzmin,'String')) 
              str2num(get(plotinfo.pzmax,'String'))];
        legs=[str2num(get(plotinfo.leg1,'String'))
              str2num(get(plotinfo.leg2,'String'))
              str2num(get(plotinfo.leg3,'String'))
              str2num(get(plotinfo.leg4,'String'))
              str2num(get(plotinfo.leg5,'String'))
              str2num(get(plotinfo.leg6,'String'))];
        outs=[str2num(get(plotinfo.roll,'String'))
              str2num(get(plotinfo.pitch,'String'))
              str2num(get(plotinfo.yaw,'String'))
              str2num(get(plotinfo.Pxval,'String'))
              str2num(get(plotinfo.Pyval,'String'))
              str2num(get(plotinfo.Pzval,'String'))];
        save formdata.txt base plat cnst legs outs -ascii;%write all this to the file


    function load_data()
         load formdata.txt
         plotinfo=get(gcf,'UserData');
            set(plotinfo.base1x,'String',formdata(1))
            set(plotinfo.base1y,'String',formdata(2))
            set(plotinfo.base2x,'String',formdata(3))
            set(plotinfo.base2y,'String',formdata(4))
            set(plotinfo.base3x,'String',formdata(5))
            set(plotinfo.base3y,'String',formdata(6))
            set(plotinfo.base4x,'String',formdata(7))
            set(plotinfo.base4y,'String',formdata(8))
            set(plotinfo.base5x,'String',formdata(9))
            set(plotinfo.base5y,'String',formdata(10))
            set(plotinfo.base6x,'String',formdata(11))
            set(plotinfo.base6y,'String',formdata(12))
            set(plotinfo.plat1x,'String',formdata(13))
            set(plotinfo.plat1y,'String',formdata(14))
            set(plotinfo.plat2x,'String',formdata(15))
            set(plotinfo.plat2y,'String',formdata(16))
            set(plotinfo.plat3x,'String',formdata(17))
            set(plotinfo.plat3y,'String',formdata(18))
            set(plotinfo.plat4x,'String',formdata(19))
            set(plotinfo.plat4y,'String',formdata(20))
            set(plotinfo.plat5x,'String',formdata(21))
            set(plotinfo.plat5y,'String',formdata(22))
            set(plotinfo.plat6x,'String',formdata(23))
            set(plotinfo.plat6y,'String',formdata(24))
            set(plotinfo.rollmin,'String',formdata(25))
            set(plotinfo.rollmax,'String',formdata(26))
            set(plotinfo.pitchmin,'String',formdata(27))
            set(plotinfo.pitchmax,'String',formdata(28))
            set(plotinfo.yawmin,'String',formdata(29))
            set(plotinfo.yawmax,'String',formdata(30))
            set(plotinfo.pxmin,'String',formdata(31))
            set(plotinfo.pxmax,'String',formdata(32))
            set(plotinfo.pymin,'String',formdata(33))
            set(plotinfo.pymax,'String',formdata(34))
            set(plotinfo.pzmin,'String',formdata(35))
            set(plotinfo.pzmax,'String',formdata(36))
            set(plotinfo.leg1,'String',formdata(37))
            set(plotinfo.leg2,'String',formdata(38))
            set(plotinfo.leg3,'String',formdata(39))
            set(plotinfo.leg4,'String',formdata(40))
            set(plotinfo.leg5,'String',formdata(41))
            set(plotinfo.leg6,'String',formdata(42))
            set(plotinfo.roll,'String',formdata(43))
            set(plotinfo.pitch,'String',formdata(44))
            set(plotinfo.yaw,'String',formdata(45))
            set(plotinfo.Pxval,'String',formdata(46))
            set(plotinfo.Pyval,'String',formdata(47))
            set(plotinfo.Pzval,'String',formdata(48))


    function draw_plat(plat_coords)
        cla
        hold on
        axis vis3d
        plotinfo=get(gcf,'UserData');
            a1=[str2num(get(plotinfo.base1x,'String')); str2num(get(plotinfo.base1y,'String')); 0; 1];
            a2=[str2num(get(plotinfo.base2x,'String')); str2num(get(plotinfo.base2y,'String')); 0; 1];
            a3=[str2num(get(plotinfo.base3x,'String')); str2num(get(plotinfo.base3y,'String')); 0; 1];
            a4=[str2num(get(plotinfo.base4x,'String')); str2num(get(plotinfo.base4y,'String')); 0; 1];
            a5=[str2num(get(plotinfo.base5x,'String')); str2num(get(plotinfo.base5y,'String')); 0; 1];
            a6=[str2num(get(plotinfo.base6x,'String')); str2num(get(plotinfo.base6y,'String')); 0; 1];

            b1=[plat_coords(1); plat_coords(2); plat_coords(3); 1];
            b2=[plat_coords(4); plat_coords(5); plat_coords(6); 1];
            b3=[plat_coords(7); plat_coords(8); plat_coords(9); 1];
            b4=[plat_coords(10); plat_coords(11); plat_coords(12); 1];
            b5=[plat_coords(13); plat_coords(14); plat_coords(15); 1];
            b6=[plat_coords(16); plat_coords(17); plat_coords(18); 1];
            line_size=3;
            %neutral point
                plot3([0 0],[0 0],[0 111.31],'-ob','MarkerSize',3,'linewidth',line_size)
            %base
                plot3([a2(1) a3(1)],[a2(2) a3(2)],[0 0],'-b','MarkerSize',6,'linewidth',line_size);
                plot3([a4(1) a5(1)],[a4(2) a5(2)],[0 0],'-b','MarkerSize',6,'linewidth',line_size);
                plot3([a6(1) a1(1)],[a6(2) a1(2)],[0 0],'-b','MarkerSize',6,'linewidth',line_size);
            %legs
%               plotinfo.p1=plot3([a1(1) b1(1)],[a1(2) b1(2)],[a1(3) b1(3)],'-.k','MarkerSize',6,'linewidth',line_size,'EraseMode','none');
                plotinfo.p1=plot3([a1(1) b1(1)],[a1(2) b1(2)],[a1(3) b1(3)],'-.k','MarkerSize',6,'linewidth',line_size);
                plotinfo.p2=plot3([a2(1) b2(1)],[a2(2) b2(2)],[a2(3) b2(3)],'-k','MarkerSize',6,'linewidth',line_size);
                plotinfo.p3=plot3([a3(1) b3(1)],[a3(2) b3(2)],[a3(3) b3(3)],'-k','MarkerSize',6,'linewidth',line_size);
                plotinfo.p4=plot3([a4(1) b4(1)],[a4(2) b4(2)],[a4(3) b4(3)],'-k','MarkerSize',6,'linewidth',line_size);
                plotinfo.p5=plot3([a5(1) b5(1)],[a5(2) b5(2)],[a5(3) b5(3)],'-k','MarkerSize',6,'linewidth',line_size);
                plotinfo.p6=plot3([a6(1) b6(1)],[a6(2) b6(2)],[a6(3) b6(3)],'-k','MarkerSize',6,'linewidth',line_size);
            %platform
                plotinfo.p7=plot3([b1(1) b2(1)],[b1(2) b2(2)],[b1(3) b2(3)],'-r','MarkerSize',6,'linewidth',line_size);
                plotinfo.p8=plot3([b2(1) b3(1)],[b2(2) b3(2)],[b2(3) b3(3)],'-r','MarkerSize',6,'linewidth',line_size);
                plotinfo.p9=plot3([b3(1) b4(1)],[b3(2) b4(2)],[b3(3) b4(3)],'-r','MarkerSize',6,'linewidth',line_size);
                plotinfo.p10=plot3([b4(1) b5(1)],[b4(2) b5(2)],[b4(3) b5(3)],'-r','MarkerSize',6,'linewidth',line_size);
                plotinfo.p11=plot3([b5(1) b6(1)],[b5(2) b6(2)],[b5(3) b6(3)],'-r','MarkerSize',6,'linewidth',line_size);
                plotinfo.p12=plot3([b6(1) b1(1)],[b6(2) b1(2)],[b6(3) b1(3)],'-r','MarkerSize',6,'linewidth',line_size);
            rotate3d
            set(gcf,'UserData',plotinfo)



    function anim_plat(plat_coords)
        plotinfo=get(gcf,'UserData');
        p1xold=get(plotinfo.p1,'XData');
        p2xold=get(plotinfo.p2,'XData');
        p3xold=get(plotinfo.p3,'XData');
        p4xold=get(plotinfo.p4,'XData');
        p5xold=get(plotinfo.p5,'XData');
        p6xold=get(plotinfo.p6,'XData');
        p7xold=get(plotinfo.p7,'XData');
        p8xold=get(plotinfo.p8,'XData');
        p9xold=get(plotinfo.p9,'XData');
        p10xold=get(plotinfo.p10,'XData');
        p11xold=get(plotinfo.p11,'XData');
        p12xold=get(plotinfo.p12,'XData');

        p1yold=get(plotinfo.p1,'YData');
        p2yold=get(plotinfo.p2,'YData');
        p3yold=get(plotinfo.p3,'YData');
        p4yold=get(plotinfo.p4,'YData');
        p5yold=get(plotinfo.p5,'YData');
        p6yold=get(plotinfo.p6,'YData');
        p7yold=get(plotinfo.p7,'YData');
        p8yold=get(plotinfo.p8,'YData');
        p9yold=get(plotinfo.p9,'YData');
        p10yold=get(plotinfo.p10,'YData');
        p11yold=get(plotinfo.p11,'YData');
        p12yold=get(plotinfo.p12,'YData');

        p1zold=get(plotinfo.p1,'ZData');
        p2zold=get(plotinfo.p2,'ZData');
        p3zold=get(plotinfo.p3,'ZData');
        p4zold=get(plotinfo.p4,'ZData');
        p5zold=get(plotinfo.p5,'ZData');
        p6zold=get(plotinfo.p6,'ZData');
        p7zold=get(plotinfo.p7,'ZData');
        p8zold=get(plotinfo.p8,'ZData');
        p9zold=get(plotinfo.p9,'ZData');
        p10zold=get(plotinfo.p10,'ZData');
        p11zold=get(plotinfo.p11,'ZData');
        p12zold=get(plotinfo.p12,'ZData');
        n=40;
        for i=1:n
            drawnow
            xp1 =[p1xold(1) (p1xold(2)+(plat_coords(1)-p1xold(2))/n*i)];
            yp1 =[p1yold(1) (p1yold(2)+(plat_coords(2)-p1yold(2))/n*i)];
            zp1 =[p1zold(1) (p1zold(2)+(plat_coords(3)-p1zold(2))/n*i)];
            xp2 =[p2xold(1) (p2xold(2)+(plat_coords(4)-p2xold(2))/n*i)];
            yp2 =[p2yold(1) (p2yold(2)+(plat_coords(5)-p2yold(2))/n*i)];
            zp2 =[p2zold(1) (p2zold(2)+(plat_coords(6)-p2zold(2))/n*i)];
            xp3 =[p3xold(1) (p3xold(2)+(plat_coords(7)-p3xold(2))/n*i)];
            yp3 =[p3yold(1) (p3yold(2)+(plat_coords(8)-p3yold(2))/n*i)];
            zp3 =[p3zold(1) (p3zold(2)+(plat_coords(9)-p3zold(2))/n*i)];
            xp4 =[p4xold(1) (p4xold(2)+(plat_coords(10)-p4xold(2))/n*i)];
            yp4 =[p4yold(1) (p4yold(2)+(plat_coords(11)-p4yold(2))/n*i)];
            zp4 =[p4zold(1) (p4zold(2)+(plat_coords(12)-p4zold(2))/n*i)];
            xp5 =[p5xold(1) (p5xold(2)+(plat_coords(13)-p5xold(2))/n*i)];
            yp5 =[p5yold(1) (p5yold(2)+(plat_coords(14)-p5yold(2))/n*i)];
            zp5 =[p5zold(1) (p5zold(2)+(plat_coords(15)-p5zold(2))/n*i)];
            xp6 =[p6xold(1) (p6xold(2)+(plat_coords(16)-p6xold(2))/n*i)];
            yp6 =[p6yold(1) (p6yold(2)+(plat_coords(17)-p6yold(2))/n*i)];
            zp6 =[p6zold(1) (p6zold(2)+(plat_coords(18)-p6zold(2))/n*i)];

            xp7 =[(p7xold(1)+(plat_coords(1)-p7xold(1))/n*i) (p7xold(2)+(plat_coords(4)-p7xold(2))/n*i)];
            yp7 =[(p7yold(1)+(plat_coords(2)-p7yold(1))/n*i) (p7yold(2)+(plat_coords(5)-p7yold(2))/n*i)];
            zp7 =[(p7zold(1)+(plat_coords(3)-p7zold(1))/n*i) (p7zold(2)+(plat_coords(6)-p7zold(2))/n*i)];
            xp8 =[(p8xold(1)+(plat_coords(4)-p8xold(1))/n*i) (p8xold(2)+(plat_coords(7)-p8xold(2))/n*i)];
            yp8 =[(p8yold(1)+(plat_coords(5)-p8yold(1))/n*i) (p8yold(2)+(plat_coords(8)-p8yold(2))/n*i)];
            zp8 =[(p8zold(1)+(plat_coords(6)-p8zold(1))/n*i) (p8zold(2)+(plat_coords(9)-p8zold(2))/n*i)];
            xp9 =[(p9xold(1)+(plat_coords(7)-p9xold(1))/n*i) (p9xold(2)+(plat_coords(10)-p9xold(2))/n*i)];
            yp9 =[(p9yold(1)+(plat_coords(8)-p9yold(1))/n*i) (p9yold(2)+(plat_coords(11)-p9yold(2))/n*i)];
            zp9 =[(p9zold(1)+(plat_coords(9)-p9zold(1))/n*i) (p9zold(2)+(plat_coords(12)-p9zold(2))/n*i)];
            xp10=[(p10xold(1)+(plat_coords(10)-p10xold(1))/n*i) (p10xold(2)+(plat_coords(13)-p10xold(2))/n*i)];
            yp10=[(p10yold(1)+(plat_coords(11)-p10yold(1))/n*i) (p10yold(2)+(plat_coords(14)-p10yold(2))/n*i)];
            zp10=[(p10zold(1)+(plat_coords(12)-p10zold(1))/n*i) (p10zold(2)+(plat_coords(15)-p10zold(2))/n*i)];
            xp11=[(p11xold(1)+(plat_coords(13)-p11xold(1))/n*i) (p11xold(2)+(plat_coords(16)-p11xold(2))/n*i)];
            yp11=[(p11yold(1)+(plat_coords(14)-p11yold(1))/n*i) (p11yold(2)+(plat_coords(17)-p11yold(2))/n*i)];
            zp11=[(p11zold(1)+(plat_coords(15)-p11zold(1))/n*i) (p11zold(2)+(plat_coords(18)-p11zold(2))/n*i)];
            xp12=[(p12xold(1)+(plat_coords(16)-p12xold(1))/n*i) (p12xold(2)+(plat_coords(1)-p12xold(2))/n*i)];
            yp12=[(p12yold(1)+(plat_coords(17)-p12yold(1))/n*i) (p12yold(2)+(plat_coords(2)-p12yold(2))/n*i)];
            zp12=[(p12zold(1)+(plat_coords(18)-p12zold(1))/n*i) (p12zold(2)+(plat_coords(3)-p12zold(2))/n*i)];

            set(plotinfo.p1,'XData',xp1,'YData',yp1,'ZData',zp1)
            set(plotinfo.p2,'XData',xp2,'YData',yp2,'ZData',zp2)
            set(plotinfo.p3,'XData',xp3,'YData',yp3,'ZData',zp3)
            set(plotinfo.p4,'XData',xp4,'YData',yp4,'ZData',zp4)
            set(plotinfo.p5,'XData',xp5,'YData',yp5,'ZData',zp5)
            set(plotinfo.p6,'XData',xp6,'YData',yp6,'ZData',zp6)
            set(plotinfo.p7,'XData',xp7,'YData',yp7,'ZData',zp7)
            set(plotinfo.p8,'XData',xp8,'YData',yp8,'ZData',zp8)
            set(plotinfo.p9,'XData',xp9,'YData',yp9,'ZData',zp9)
            set(plotinfo.p10,'XData',xp10,'YData',yp10,'ZData',zp10)
            set(plotinfo.p11,'XData',xp11,'YData',yp11,'ZData',zp11)
            set(plotinfo.p12,'XData',xp12,'YData',yp12,'ZData',zp12)
        end
            set(gcf,'UserData',plotinfo) 





    function platpos=save_plat_position()
        plotinfo=get(gcf,'UserData');
            old_plat_coord=[str2num(get(plotinfo.plat1x,'String'));
                            str2num(get(plotinfo.plat1y,'String'));
                            str2num(get(plotinfo.plat2x,'String'));
                            str2num(get(plotinfo.plat2y,'String'));
                            str2num(get(plotinfo.plat3x,'String'));
                            str2num(get(plotinfo.plat3y,'String'));
                            str2num(get(plotinfo.plat4x,'String'));
                            str2num(get(plotinfo.plat4y,'String'));
                            str2num(get(plotinfo.plat5x,'String'));
                            str2num(get(plotinfo.plat5y,'String'));
                            str2num(get(plotinfo.plat6x,'String'));
                            str2num(get(plotinfo.plat6y,'String'))];
        platpos=old_plat_coord;


    function color_input_box(BOX_IN)
        plotinfo=get(gcf,'UserData');
        if BOX_IN==1
            set(plotinfo.leg1,'BackgroundColor',[.8,1,1])
            set(plotinfo.leg2,'BackgroundColor',[.8,1,1])
            set(plotinfo.leg3,'BackgroundColor',[.8,1,1])
            set(plotinfo.leg4,'BackgroundColor',[.8,1,1])
            set(plotinfo.leg5,'BackgroundColor',[.8,1,1])
            set(plotinfo.leg6,'BackgroundColor',[.8,1,1])
            set(plotinfo.roll,'BackgroundColor',[1,1,1])
            set(plotinfo.pitch,'BackgroundColor',[1,1,1])
            set(plotinfo.yaw,'BackgroundColor',[1,1,1])
            set(plotinfo.Pxval,'BackgroundColor',[1,1,1])
            set(plotinfo.Pyval,'BackgroundColor',[1,1,1])
            set(plotinfo.Pzval,'BackgroundColor',[1,1,1])
        elseif BOX_IN==2
            set(plotinfo.leg1,'BackgroundColor',[1,1,1])
            set(plotinfo.leg2,'BackgroundColor',[1,1,1])
            set(plotinfo.leg3,'BackgroundColor',[1,1,1])
            set(plotinfo.leg4,'BackgroundColor',[1,1,1])
            set(plotinfo.leg5,'BackgroundColor',[1,1,1])
            set(plotinfo.leg6,'BackgroundColor',[1,1,1])
            set(plotinfo.roll,'BackgroundColor',[.8,1,1])
            set(plotinfo.pitch,'BackgroundColor',[.8,1,1])
            set(plotinfo.yaw,'BackgroundColor',[.8,1,1])
            set(plotinfo.Pxval,'BackgroundColor',[.8,1,1])
            set(plotinfo.Pyval,'BackgroundColor',[.8,1,1])
            set(plotinfo.Pzval,'BackgroundColor',[.8,1,1])
        end

    function solve_forward()
            plotinfo=get(gcf,'UserData');
            L1=str2num(get(plotinfo.leg1,'String'));
            L2=str2num(get(plotinfo.leg2,'String'));
            L3=str2num(get(plotinfo.leg3,'String'));
            L4=str2num(get(plotinfo.leg4,'String'));
            L5=str2num(get(plotinfo.leg5,'String'));
            L6=str2num(get(plotinfo.leg6,'String'));
            xsi=[str2num(get(plotinfo.base1x,'String')),...
                 str2num(get(plotinfo.base2x,'String')),...
                 str2num(get(plotinfo.base3x,'String')),...
                 str2num(get(plotinfo.base4x,'String')),...
                 str2num(get(plotinfo.base5x,'String')),...
                 str2num(get(plotinfo.base6x,'String'))];
            ysi=[str2num(get(plotinfo.base1y,'String')),...
                 str2num(get(plotinfo.base2y,'String')),...
                 str2num(get(plotinfo.base3y,'String')),...
                 str2num(get(plotinfo.base4y,'String')),...
                 str2num(get(plotinfo.base5y,'String')),...
                 str2num(get(plotinfo.base6y,'String'))];
            xmi=[str2num(get(plotinfo.plat1x,'String')),...
                 str2num(get(plotinfo.plat2x,'String')),...
                 str2num(get(plotinfo.plat3x,'String')),...
                 str2num(get(plotinfo.plat4x,'String')),...
                 str2num(get(plotinfo.plat5x,'String')),...
                 str2num(get(plotinfo.plat6x,'String'))];
            ymi=[str2num(get(plotinfo.plat1y,'String')),...
                 str2num(get(plotinfo.plat2y,'String')),...
                 str2num(get(plotinfo.plat3y,'String')),...
                 str2num(get(plotinfo.plat4y,'String')),...
                 str2num(get(plotinfo.plat5y,'String')),...
                 str2num(get(plotinfo.plat6y,'String'))];
            rollmin=str2num(get(plotinfo.rollmin,'String'));
            rollmax=str2num(get(plotinfo.rollmax,'String'));
            pitchmin=str2num(get(plotinfo.pitchmin,'String'));
            pitchmax=str2num(get(plotinfo.pitchmax,'String'));
            yawmin=str2num(get(plotinfo.yawmin,'String'));
            yawmax=str2num(get(plotinfo.yawmax,'String'));
            pxmin=str2num(get(plotinfo.pxmin,'String'));
            pxmax=str2num(get(plotinfo.pxmax,'String'));
            pymin=str2num(get(plotinfo.pymin,'String'));
            pymax=str2num(get(plotinfo.pymax,'String'));
            pzmin=str2num(get(plotinfo.pzmin,'String'));
            pzmax=str2num(get(plotinfo.pzmax,'String'));

            forward_solution=stew_forward(L1,L2,L3,L4,L5,L6,xsi,ysi,xmi,ymi,rollmin,rollmax,pitchmin,pitchmax,yawmin,yawmax,pxmin,pxmax,pymin,pymax,pzmin,pzmax);%this is an external function

            plotinfo.num_solutions=size(forward_solution,1);

            for i=size(forward_solution,1):-1:1
                plotinfo.solutions(i,:)=forward_solution(i,:);
            end
            set(plotinfo.roll,'String',double(plotinfo.solutions(1,1)))%set roll/pitch/yaw fields to first solution
            set(plotinfo.pitch,'String',double(plotinfo.solutions(1,2)))
            set(plotinfo.yaw,'String',double(plotinfo.solutions(1,3)))
            set(plotinfo.Pxval,'String',double(plotinfo.solutions(1,4)))
            set(plotinfo.Pyval,'String',double(plotinfo.solutions(1,5)))
            set(plotinfo.Pzval,'String',double(plotinfo.solutions(1,6)))

            if plotinfo.num_solutions==1
                set(plotinfo.prevsol,'Visible','off')
                set(plotinfo.nextsol,'Visible','off')
                set(plotinfo.solutions_text,'Visible','off')
            else
                set(plotinfo.prevsol,'Visible','off')
                set(plotinfo.nextsol,'Visible','on')
                solutions_text=[num2str(plotinfo.num_solutions),' Solutions',];
                set(plotinfo.solutions_text,'String',solutions_text,'Visible','on')
            end
            plotinfo.current_solution=1;
            set(gcf,'UserData',plotinfo);  %save changed values to data area 
            solve_inverse() 

    function solve_inverse()
            plotinfo=get(gcf,'UserData');
            xsi=[str2num(get(plotinfo.base1x,'String')),...
                 str2num(get(plotinfo.base2x,'String')),...
                 str2num(get(plotinfo.base3x,'String')),...
                 str2num(get(plotinfo.base4x,'String')),...
                 str2num(get(plotinfo.base5x,'String')),...
                 str2num(get(plotinfo.base6x,'String'))];
            ysi=[str2num(get(plotinfo.base1y,'String')),...
                 str2num(get(plotinfo.base2y,'String')),...
                 str2num(get(plotinfo.base3y,'String')),...
                 str2num(get(plotinfo.base4y,'String')),...
                 str2num(get(plotinfo.base5y,'String')),...
                 str2num(get(plotinfo.base6y,'String'))];
            xmi=[str2num(get(plotinfo.plat1x,'String')),...
                 str2num(get(plotinfo.plat2x,'String')),...
                 str2num(get(plotinfo.plat3x,'String')),...
                 str2num(get(plotinfo.plat4x,'String')),...
                 str2num(get(plotinfo.plat5x,'String')),...
                 str2num(get(plotinfo.plat6x,'String'))];
            ymi=[str2num(get(plotinfo.plat1y,'String')),...
                 str2num(get(plotinfo.plat2y,'String')),...
                 str2num(get(plotinfo.plat3y,'String')),...
                 str2num(get(plotinfo.plat4y,'String')),...
                 str2num(get(plotinfo.plat5y,'String')),...
                 str2num(get(plotinfo.plat6y,'String'))];
             roll=str2num(get(plotinfo.roll,'String'));
             pitch=str2num(get(plotinfo.pitch,'String'));
             yaw=str2num(get(plotinfo.yaw,'String'));
             px=str2num(get(plotinfo.Pxval,'String'));
             py=str2num(get(plotinfo.Pyval,'String'));
             pz=str2num(get(plotinfo.Pzval,'String'));

             inverse_solution=stew_inverse(xsi,ysi,xmi,ymi,roll,pitch,yaw,px,py,pz);

             set(plotinfo.leg1,'String',double(inverse_solution(1)));
             set(plotinfo.leg2,'String',double(inverse_solution(2)));
             set(plotinfo.leg3,'String',double(inverse_solution(3)));
             set(plotinfo.leg4,'String',double(inverse_solution(4)));
             set(plotinfo.leg5,'String',double(inverse_solution(5)));
             set(plotinfo.leg6,'String',double(inverse_solution(6)));

             plat_coords=inverse_solution(25:42);
             anim_state=get(plotinfo.animate_but,'Value');
             if anim_state==0
                draw_plat(plat_coords)
             elseif anim_state==1
                anim_plat(plat_coords)
             end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Stewart-Platform-Forward-Kinematics-Solver-master/src/._stew_inverse.m                              000777  000766  000024  00000000336 12621366603 027403  0                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                             Mac OS X            	   2   �      �                                      ATTR       �   �   F                  �   F  com.apple.quarantine q/0001;56435b72;Google\x20Chrome;E50871A0-D630-428A-ADC3-01581D83508B                                                                                                                                                                                                                                                                                                   Stewart-Platform-Forward-Kinematics-Solver-master/src/stew_inverse.m                                000777  000766  000024  00000012353 12621366603 027170  0                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                         % Filename: stew_inverse.m
% Author: Joe Brown, California State University, Sacramento
% Description: This file contains a function to find the inverse kinematics
% solution for a Stewart platform.
% Definitions of frames A, B, G, M, and N used in this program are given in the report: Kumagai, A and Brown, J.P Development of a Closed Form Forward Kinematics Analysis Program for the 6-DOF CDSL Stewart Platform, Aug. 2006.
% Inputs: 
%         xsi - x coordinates of base connection points
%         ysi - y coordinates of base connection points
%         xmi - x coordinates of platform connection points
%         ymi - y coordinates of platform connection points
% Note: See the FORTRAN program hard-init.f for full-definitions of xsi, ysi, xmi, ymi.
%         roll - x rotation angle in degrees
%         pitch - y rotation angle in degrees
%         yaw - z rotation angle in degrees
% Note: In this program, x(roll), y(pitch), and z(yaw) rotation angles are Euler angels THE6(1), THE6(2), and THE6(3), respectively. The THE6 vectors are described in the FORTRAN simulation programs for the 6-DOF Stewart platform.
% For definitions of parameters px, py, pz, and vectors ai (i=1,..,6), and bi (i=1,..,6), see the following technical paper: Lee, T.Y, and Shim J.K., Algebraic Elimination-Based Real-Time Forward Kinematics of the 6-6 Stewart Platform with Planar Base and Platform,� Proceedings of the IEEE International Conference on Robotics and Automation, Seoul, Korea, May 21-26 2001, pp. 1301-1306.
% Outputs: 
%         Legs[6] - Leg lengths for legs 1 through 6
%         platcoords[18] - x,y, and z coordinates for the platform with respect to Frame N
%         animcoords[18] - x,y, and z coordinates for the platform with a
%           different z translation to make it look accurate when
%           animating or drawing.

function inv_return=stew_inverse(xsi,ysi,xmi,ymi,roll,pitch,yaw,px,py,pz)
%    digits(15)                           %digit accuracy specification
    a1=[xsi(1);ysi(1);0;1];              
    a2=[xsi(2);ysi(2);0;1];              
    a3=[xsi(3);ysi(3);0;1];              
    a4=[xsi(4);ysi(4);0;1];              
    a5=[xsi(5);ysi(5);0;1];
    a6=[xsi(6);ysi(6);0;1]; 

    TXrad=roll*pi/180;                  %convert the roll angle to radians
    TYrad=pitch*pi/180;                 %convert the pitch angle to radians
    TZrad=yaw*pi/180;                   %convert the yaw angle to radians

        %T is the transformation (translation + rotation) matrix from Frame B to Frame N.
    T =[cos(TYrad)*cos(TZrad),                                 -cos(TYrad)*sin(TZrad),                                  sin(TYrad),           px;
        sin(TXrad)*sin(TYrad)*cos(TZrad)+cos(TXrad)*sin(TZrad),-sin(TXrad)*sin(TYrad)*sin(TZrad)+cos(TXrad)*cos(TZrad),-sin(TXrad)*cos(TYrad),py;
       -cos(TXrad)*sin(TYrad)*cos(TZrad)+sin(TXrad)*sin(TZrad), cos(TXrad)*sin(TYrad)*sin(TZrad)+sin(TXrad)*cos(TZrad), cos(TXrad)*cos(TYrad),pz-111.31;
        0,                                                      0,                                                      0,                    1 ];
        
        %Ta is the transformation matrix that rotates and translates the
        %platform to the correct orientation for animation.
    Ta =[cos(TYrad)*cos(TZrad),                                 -cos(TYrad)*sin(TZrad),                                  sin(TYrad),           px;
         sin(TXrad)*sin(TYrad)*cos(TZrad)+cos(TXrad)*sin(TZrad),-sin(TXrad)*sin(TYrad)*sin(TZrad)+cos(TXrad)*cos(TZrad),-sin(TXrad)*cos(TYrad),py;
        -cos(TXrad)*sin(TYrad)*cos(TZrad)+sin(TXrad)*sin(TZrad), cos(TXrad)*sin(TYrad)*sin(TZrad)+sin(TXrad)*cos(TZrad), cos(TXrad)*cos(TYrad),111.31-pz;
         0,                                                      0,                                                      0,                    1 ];
    
    b1=T*[xmi(1);ymi(1);0;1];   %b# is the coordinates that will be used for calculation
    b2=T*[xmi(2);ymi(2);0;1];
    b3=T*[xmi(3);ymi(3);0;1];
    b4=T*[xmi(4);ymi(4);0;1];
    b5=T*[xmi(5);ymi(5);0;1];
    b6=T*[xmi(6);ymi(6);0;1];

    b1t=Ta*[xmi(1);ymi(1);0;1]; %b#t are the coordinates that will be animated
    b2t=Ta*[xmi(2);ymi(2);0;1];
    b3t=Ta*[xmi(3);ymi(3);0;1];
    b4t=Ta*[xmi(4);ymi(4);0;1];
    b5t=Ta*[xmi(5);ymi(5);0;1];
    b6t=Ta*[xmi(6);ymi(6);0;1];

    L1=sqrt((abs(a1(1)-b1(1)))^2+(abs(a1(2)-b1(2)))^2+(abs(a1(3)-b1(3)))^2); %L=sqrt((ax-bx)^2+(ay-by)^2+(az-bz)^2)
    L2=sqrt((abs(a2(1)-b2(1)))^2+(abs(a2(2)-b2(2)))^2+(abs(a2(3)-b2(3)))^2);
    L3=sqrt((abs(a3(1)-b3(1)))^2+(abs(a3(2)-b3(2)))^2+(abs(a3(3)-b3(3)))^2);
    L4=sqrt((abs(a4(1)-b4(1)))^2+(abs(a4(2)-b4(2)))^2+(abs(a4(3)-b4(3)))^2);
    L5=sqrt((abs(a5(1)-b5(1)))^2+(abs(a5(2)-b5(2)))^2+(abs(a5(3)-b5(3)))^2);
    L6=sqrt((abs(a6(1)-b6(1)))^2+(abs(a6(2)-b6(2)))^2+(abs(a6(3)-b6(3)))^2);

    Legs=[L1,L2,L3,L4,L5,L6];   %leg value return
    platcoords=[b1(1),b1(2),b1(3),b2(1),b2(2),b2(3),b3(1),b3(2),b3(3),b4(1),b4(2),b4(3),b5(1),b5(2),b5(3),b6(1),b6(2),b6(3)]; %plat position return
    animcoords=[b1t(1),b1t(2),b1t(3),b2t(1),b2t(2),b2t(3),b3t(1),b3t(2),b3t(3),b4t(1),b4t(2),b4t(3),b5t(1),b5t(2),b5t(3),b6t(1),b6t(2),b6t(3)]; %plat position return for animation
    inv_return=[Legs,platcoords,animcoords]; %return

                                                                                                                                                                                                                                                                                     Stewart-Platform-Forward-Kinematics-Solver-master/src/._stew_forward.m                              000777  000766  000024  00000000336 12621365261 027373  0                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                             Mac OS X            	   2   �      �    MATFMATL                          ATTR       �   �   F                  �   F  com.apple.quarantine q/0001;56435b72;Google\x20Chrome;E50871A0-D630-428A-ADC3-01581D83508B                                                                                                                                                                                                                                                                                                   Stewart-Platform-Forward-Kinematics-Solver-master/src/stew_forward.m                                000777  000766  000024  00000046427 12621365261 027171  0                                                                                                    ustar 00jimkaidy                        staff                           000000  000000                                                                                                                                                                         % Filename: stew_forward.m
% Author: Joe Brown, California State University, Sacramento  8/04/2006
% Description: This file contains a function to generate a closed form solution 
%              for the forward kinematics of a planar base/platform Stewart platform.
% Note: The forward kinematics analysis of this program is based on the following technical paper: Lee, T.Y, and Shim J.K., �Algebraic Elimination-Based Real-Time Forward Kinematics of the 6-6 Stewart Platform with Planar Base and Platform,� Proceedings of the IEEE International Conference on Robotics and Automation, Seoul, Korea, May 21-26 2001, pp. 1301-1306. 
%See this technical paper for definitions of the following varialbles:
%c1,c2,c3, px, py, pz ai (i=1,..,6), and bi (i=1,..,6). 
%All equation numbers mentioned in this program are also those of the same technical paper.
% Inputs: 
%         L1->L6 - Leg Lengths
%         xsi - x coordinates of base connection points
%         ysi - y coordinates of base connection points
%         xmi - x coordinates of platform connection points
%         ymi - y coordinates of platform connection points
% Note: See the FORTRAN program �hard-init.f� for full-definitions of xsi, ysi, xmi, ymi.
%         rollmin/rollmax - minimum/maximum x rotation angle in degrees
%         pitchmin/pitchmax - minimum/maximum y rotation angle in degrees
%         yawmin/yawmax - minimum/maximum z rotation angle in degrees
% Note: In this program, x(roll), y(pitch), and z(yaw) rotation angles are Euler angels THE6(1), THE6(2), and THE6(3), respectively. The THE6 vectors are described in the FORTRAN simulation programs for the 6-DOF Stewart platform. 
%         pxmin/pxmax - minimum/maximum px
%         pymin/pymax - minimum/maximum py
%         pzmin/pzmax - minimum/maximum pz
%         legmin/legmax - minimum/maximum leg lengths
% Outputs: 
%         Solutions - 6 x N matrix where N is the number of solutions
%             Solutions(1,N) is x rotation angle in degrees
%             Solutions(2,N) is y rotation angle in degrees
%             Solutions(3,N) is z rotation angle in degrees
%             Solutions(4,N) is the x component of the position vector rm
%             Solutions(5,N) is the y component of the position vector rm
%             Solutions(6,N) is the z component of the position vector rm
% Note: The rm is the vector from the origin of Frame N to that of Fram M.
% Definitions of frames A, B, G, M, and N used in this program are given in the report: Kumagai, A and Brown, J.P �Development of a Closed Form Forward Kinematics Analysis Program for the 6-DOF CDSL Stewart Platform,� Aug. 2006.             
function solutions = stew_forward(L1,L2,L3,L4,L5,L6,xsi,ysi,xmi,ymi,rollmin,rollmax,pitchmin,pitchmax,yawmin,yawmax,pxmin,pxmax,pymin,pymax,pzmin,pzmax,legmin,legmax)
%    digits(15) 
    
    legmin=106;                             %leg min/max are defined here, but for a general case they would be defined in the GUI
    legmax=167;
    
    syms c1 c2 c3                           %set initial symbolic variables

    I=[1 0 0;                               %identity matrix
       0 1 0;
       0 0 1];                              
    C=[0 -c3 c2;                            %used to build rotation matrix(equation 4)
       c3 0 -c1;
      -c2 c1 0];                            
  
    R=(I-C)^-1*(I+C);                       %Rotation matrix(equation 3)
    D=(1+c1^2+c2^2+c3^2);                   %Denominator common to many parts of the program.

    Ta=[1 0 0 -xsi(1);                      %translation matrix from Frame G to Fram A.
        0 1 0 -ysi(1);
        0 0 1 0      ;
        0 0 0 1      ];

    Tb=[1 0 0 -xmi(1);                      %translation matrix from Fram M to Fram B.
        0 1 0 -ymi(1);  
        0 0 1 0      ;
        0 0 0 1      ];

    a1=Ta*[xsi(1);ysi(1);0;1];              
    a2=Ta*[xsi(2);ysi(2);0;1];              
    a3=Ta*[xsi(3);ysi(3);0;1];              
    a4=Ta*[xsi(4);ysi(4);0;1];              
    a5=Ta*[xsi(5);ysi(5);0;1];
    a6=Ta*[xsi(6);ysi(6);0;1]; 

    b1=Tb*[xmi(1);ymi(1);0;1];
    b2=Tb*[xmi(2);ymi(2);0;1];
    b3=Tb*[xmi(3);ymi(3);0;1];
    b4=Tb*[xmi(4);ymi(4);0;1];
    b5=Tb*[xmi(5);ymi(5);0;1];
    b6=Tb*[xmi(6);ymi(6);0;1];

    F2=-a2(1:3).'*R*b2(1:3)+(a2(1:3).'*a2(1:3)+b2(1:3).'*b2(1:3)-L2^2+L1^2)/2;    %F equations as described by equation 14
    F3=-a3(1:3).'*R*b3(1:3)+(a3(1:3).'*a3(1:3)+b3(1:3).'*b3(1:3)-L3^2+L1^2)/2;
    F4=-a4(1:3).'*R*b4(1:3)+(a4(1:3).'*a4(1:3)+b4(1:3).'*b4(1:3)-L4^2+L1^2)/2;
    F5=-a5(1:3).'*R*b5(1:3)+(a5(1:3).'*a5(1:3)+b5(1:3).'*b5(1:3)-L5^2+L1^2)/2;
    F6=-a6(1:3).'*R*b6(1:3)+(a6(1:3).'*a6(1:3)+b6(1:3).'*b6(1:3)-L6^2+L1^2)/2;

    %---------------------------------------------------------------------Phi1
    M=[-a2(1) -a2(2) b2(1) b2(2) F2;        %equation 13
       -a3(1) -a3(2) b3(1) b3(2) F3;
       -a4(1) -a4(2) b4(1) b4(2) F4;   
       -a5(1) -a5(2) b5(1) b5(2) F5;
       -a6(1) -a6(2) b6(1) b6(2) F6];

    Phi1=det(M)*D;                          %Phi1=g1 + g2*c3 + g3*c3^2 + g4*c1^2 + g5*c1*c2 + g6*c2^2=0
    
        %note: subs can do multiple substitutions in the form
        %subs(expression,{old1,old2},{new1,new2})
        %but its performance sometimes erratic.  Hence the nested routines.
        %Also, there are cleaner ways to find g1->g6 and T1->T33,  but
        %substituting in 1's and 0's provides a very fast way to find these
        %values
    
    g1=subs(subs(subs(Phi1,c1,0),c2,0),c3,0);                           %c1/c2/c3=0 to get g1
    g2=subs(subs(subs(subs(Phi1,c2,0),c1,0),c3^2,0)-g1,c3,1);           %c1/c2/c3^2=0, subtract g1 and set c3=1 to get g2
    g3=subs(simplify((subs(subs(Phi1,c1,0),c2,0)-g1)/c3)-g2,c3,1);      %c1/c2=0, subtract g1, divide by c3, subtract g2 and set c3=1 to get g3
    g4=subs(subs(Phi1,{c2,c3},{0,0})-g1,c1,1);                          %c2/c3=0, subtract c1, set c1=1 to get g4
    g5=subs(subs(subs(subs(Phi1,c2^2,0),c1^2,0),c3,0)-g1,{c1,c2},{1,1});%c2^2/c1^2/c3=0, subtract g1 and set c1/c2=1 to get g5
    g6=subs(subs(subs(Phi1,c1,0),c3,0)-g1,c2^2,1);                      %c1/c3=0, subtract g1 and set c2^2=1 to get g6

    %---------------------------------------------------------------------Phi2
    syms ct                                 %ct is a temporary symbolic reference that is used to get the T values.

    Mp=[-a2(1)     -a2(2)       b2(1)       b2(2)     F2;               %equation 18
        -a3(1)     -a3(2)       b3(1)       b3(2)     F3;
        -a4(1)     -a4(2)       b4(1)       b4(2)     F4;
        -a5(1)     -a5(2)       b5(1)       b5(2)     F5;
        (c1-c2*c3) (c2+c1*c3) (-c1-c2*c3) (-c2+c1*c3) 0 ];

    Phi2=det(Mp)*D;                         %Phi2=T1*c1 + T2*c2 + T30*c1^3 + T31*c1^2*c2 + T32*c1*c2^2 + T33*c2^3

    T1=subs(collect(subs(subs(Phi2,c1^3,0),c2,0),c1),c1,1);             %c1^3/c2=0, collect c1's and set c1=1 to get T1
    T2=subs(collect(subs(subs(Phi2,c2^3,0),c1,0),c1),c2,1);             %c2^3/c1=0, collect c1's and set c2=1 to get T2
    T30=subs(subs(subs(subs(subs(Phi2,c1^3,ct),c1,0),c2,0),ct,c1^3),c1,1);  %c1^3=ct, set c1/c2=0, set ct=c1^2 again and set c1=1 to get T30
    T31=subs(subs(subs(subs(subs(subs(subs(subs(subs(subs(expand(subs(subs(Phi2,c3^2,0))-T2*c2),c1^3,0),c3^3,0),c2^2,0),c3^2,0)),c2^3,0),c1^2,ct),c1,0),ct,1),c2,1);    %c3^2=0, subtract T3*c2, set c1^3/c3^3/c2^2/c3^2/c2^3=0, set c1^2 to ct, set c1=0, set ct=1 and c2=1 to get T32...phew    T32=subs(subs(subs(subs(subs(subs(subs(subs(Phi2,c2^2,ct),c2,0),c1^2,0),c1^3,0)-expand(T1*c1),c3^2,0),c3^3,0),ct,1),c1,1);  %c2^2=ct, set c2/c1^2/c1^3=0, subtract T1*c1, set c3^2=0, set ct/c1=1 to get T31
    T32=subs(subs(subs(subs(subs(subs(subs(subs(Phi2,c2^2,ct),c2,0),c1^2,0),c1^3,0)-expand(T1*c1),c3^2,0),c3^3,0),ct,1),c1,1);  %c2^2=ct, set c2/c1^2/c1^3=0, subtract T1*c1, set c3^2/c3^3=0, set ct/c1=1 to get T32
    T33=subs(subs(subs(subs(subs(subs(Phi2,c1,0),c3^3,0),c3^2,0),c2^3,ct),c2,0),ct,1);  %c1/c3^3/c3^2=0, set c2^3=ct, set c2=0 and set ct=1 to get T33

    %-----------------------------------------------------------------Phi3/4/5
    syms Px Py Pz Qx Qy Qz E                %symbolic variables for Px/Py/Pz/Qx/Qy/Qz/E

    P=[Px Py Pz];
    Q=[Qx Qy Qz];

    M3a=[-a2(1) -a2(2) b2(1) b2(2);         %equation 23
         -a3(1) -a3(2) b3(1) b3(2);
         -a4(1) -a4(2) b4(1) b4(2);
         -a5(1) -a5(2) b5(1) b5(2)];
    M3b=[-F2;
         -F3;
         -F4;
         -F5];

    M3=inv(M3a)*M3b;                       %solution to equation 23

    Px=M3(1);
    Py=M3(2);
    Qx=M3(3);
    Qy=M3(4);

    e9=(I-C)*P.'-(I+C)*Q.';                 %equation 9
    e10=e9(1);                              %equation 10
    e11=e9(2);                              %equation 11
    e12=e9(3);                              %equation 12

    qz10=collect(solve(e10,Qz),Pz);         %Solve equation 10 for Pz.
    qz11=collect(solve(e11,Qz),Pz);         %Solve equation 11 for Pz.
    qz12=collect(solve(e12,Qz),Pz);         %Solve equation 12 for Pz.

    pz1=factor(eval(solve(qz11-qz12,Pz)));  %Equate eq11 and eq12 through pz, so eq11-eq12=0, equation 25 
    pz2=factor(eval(solve(qz10-qz12,Pz)));  %Equate eq10 and eq12 through pz, so eq10-eq12=0, equation 26

    N1=pz1*c1*D;                            %Numerator of pz1
    D1=c1*D;                                %denominator of pz1
    N2=pz2*c2*D;                            %numerator of pz2
    D2=c2*D;                                %denominator of pz2

    pz3=simplify((N1-N2)/(D1-D2));          %pz3 is generated with N1,N2,D1,D2.

    M4a=[g4  g5  g6  0   0 ;                %equation 31 M4a*M4=M4b
         0   g4  g5  g6  0 ;
         0   0   g4  g5  g6;
         T30 T31 T32 T33 0;
         0   T30 T31 T32 T33];

    M4b=[c1^2*g1+c1^2*g2*c3+c1^2*g3*c3^2   ;%equation 31
         c1*c2*g1+c1*c2*g2*c3+c1*c2*g3*c3^2;
         c2^2*g1+c2^2*g2*c3+c2^2*g3*c3^2   ;
         T1*c1^2+T2*c1*c2                  ;
         T1*c1*c2+T2*c2^2                  ];
    M4=vpa(inv(M4a)*(-M4b));                %solution to equation 31

    [M4num(1:5),M4den(1:5)]=numden(simplify(M4(1:5)));  %break up the solution M4 into numerator and denominator
    M4e(1:5)=M4num(1:5)/E;                              %replace the denominator with E, this is to speed calculation.

    Phi=[simplify((Px^2+Py^2+pz1^2-L1^2)*D^2*c1^2)     ;     %Phi3/4/5=PX^2 + PY^2 + PZ^2 - L1^2=0
         simplify((Px^2+Py^2+pz2^2-L1^2)*D^2*c2^2)     ;     %other values were added to remove denominators
         simplify((Px^2+Py^2+pz3^2-L1^2)*D^2*(c1-c2)^2)];    
        
        %format for the algsubs function is algsubs(old=new,expression).
        %Since algsubs is a Maple command, it only accepts string input, so
        %to get the old=new string expression, I concat the old with the
        %new lower order expression via ['old', '=' char(new)].  So the
        %format of the maple command is now:
        %maple('algsubs',['old', '=' char(new)],expression,'exact'). The
        %'exact' on the end forces maple to not try and swap 'old' and
        %'new' if for some reason it cannot replace the old expression.
    for k=1:2                               %this routine substitutes the high order expressions in Phi3/4/5 for the 
        for j=1:3                           %low order expressions found in M4
            Phi(j)=maple('algsubs',['c1^4',     '=' char(M4e(1))],simplify(Phi(j)),'exact');
            Phi(j)=maple('algsubs',['c1^3*c2',  '=' char(M4e(2))],simplify(Phi(j)),'exact');
            Phi(j)=maple('algsubs',['c1^2*c2^2','=' char(M4e(3))],simplify(Phi(j)),'exact');
            Phi(j)=maple('algsubs',['c1*c2^3',  '=' char(M4e(4))],simplify(Phi(j)),'exact');
            Phi(j)=maple('algsubs',['c2^4',     '=' char(M4e(5))],simplify(Phi(j)),'exact');
        end
    end

    Phi3=simplify(subs(Phi(1),E,M4den(2))); %replace E with the actual denominator found earlier.
    Phi4=simplify(subs(Phi(2),E,M4den(2))); %I used M4den(2) because at low digit accuracy the first
    Phi5=simplify(subs(Phi(3),E,M4den(2))); %value M4den(1) will drift slightly

    E=M4den(2);                             %replace E with denominator of M4
    [W,Wd]=numden([Phi3 Phi4 Phi5]);        %since Phi3/4/5 are equal to 0, we can discard the denominators, assuming they never equal 0

    W11=subs(subs(W(1),c1,0),c2,0);         %W's are used in the final polynomial, W*3 is found last because it uses the previous W's
    W12=subs((subs(W(1),c2,0)-W11),c1,1);
    W14=subs((subs(W(1),c1,0)-W11),c2,1);
    W13=subs(subs(W(1),c1,1),c2,1)-W11-W12-W14;

    W21=subs(subs(W(2),c1,0),c2,0);
    W22=subs((subs(W(2),c2,0)-W21),c1,1);
    W24=subs((subs(W(2),c1,0)-W21),c2,1);
    W23=subs(subs(W(2),c1,1),c2,1)-W21-W22-W24;

    W31=subs(subs(W(3),c1,0),c2,0);
    W32=subs((subs(W(3),c2,0)-W31),c1,1);
    W34=subs((subs(W(3),c1,0)-W31),c2,1);
    W33=subs(subs(W(3),c1,1),c2,1)-W31-W32-W34;

    S=[(g1+g2*c3+g3*c3^2)   g4        g5          g6     ;%equation 36
       W11/E^3              W12/E^3   W13/E^3     W14/E^3;
       W21/E^3              W22/E^3   W23/E^3     W24/E^3;
       W31/E^3              W32/E^3   W33/E^3     W34/E^3];
    Sd=factor(det(S));                      %this is the final polynomial
    c3sol=solve(Sd);                        %solve for c3

    for i=size(c3sol,1):-1:1                %for each value in c3sol
        if isreal(c3sol(i))==0              %if the value isn't real
            c3sol(i)=[];                    %delete that row
        end
    end


    Sp=[S(1,2) S(1,3) S(1,4);               %Rearange matrix S to solve for c1^2,c1*c2, and c2^2
        S(2,2) S(2,3) S(2,4);
        S(3,2) S(3,3) S(3,4)];
    Spx=[-S(1,1);-S(2,1);-S(3,1)];
    Sol=inv(Sp)*Spx;                        %Sol(1)=c1^2, Sol(2)=c1*c2 and Sol(3)=c2^2

    Sm=[];                                  %create an empty matrix

    C_tol=10^-30;  %tolerance for cases when c1,c2,c3 are close to 0

    for i=1:size(c3sol,1)                                           %for each value of c3
        c1sol=sqrt(subs(Sol(1),c3,c3sol(i)));                       %substitute c3(i) into Sol(1) to get c1
        c1c2=subs(Sol(2),c3,c3sol(i));                              %substitute c3(i) into Sol(2) to get c2*
        c2sol=sqrt(subs(Sol(3),c3,c3sol(i)));                       %substitute c3(i) into Sol(3) to get c2
        if (isreal(c1sol)~=0) && (isreal(c2sol)~=0)                 %if c1 and c2 are real
            if double(c1sol) > C_tol                                %and if c1 is bigger than the tolerance value
                c2sol=c1c2/c1sol;                                   %c2=c1*c2/c1
                pxsol=subs(Px,{c1,c2,c3},{c1sol,c2sol,c3sol(i)});   %sub c1/c2/c3 into Px to get px value
                pysol=subs(Py,{c1,c2,c3},{c1sol,c2sol,c3sol(i)});   %sub c1/c2/c3 into Py to get py value
                pzsol=subs(pz1,{c1,c2,c3},{c1sol,c2sol,c3sol(i)});  %sub c1/c2/c3 into Pz to get pz value
                Sm=[Sm;c1sol c2sol c3sol(i) pxsol pysol pzsol];     %add values to solution matrix
                Sm=[Sm;-c1sol -c2sol c3sol(i) pxsol pysol -pzsol];  %add negative case values to matrix
            else
                if double(c2sol) > C_tol                            %if c2 is bigger than the tolerance
                    pxsol=subs(Px,{c1,c2,c3},{0,c2sol,c3sol(i)});   %sub c1/c2/c3 into Px to get px value
                    pysol=subs(Py,{c1,c2,c3},{0,c2sol,c3sol(i)});   %sub c1/c2/c3 into Py to get py value
                    pzsol=subs(pz2,{c1,c2,c3},{0,c2sol,c3sol(i)});  %sub c1/c2/c3 into pz2 to get pz value
                    Sm=[Sm;0 c2sol c3sol(i) pxsol pysol pzsol];     %add values to solution matrix
                    Sm=[Sm;0 -c2sol c3sol(i) pxsol pysol -pzsol];   %add negative case values to matrix
                else
                    if c3sol(i) < C_tol                             %if c3 is below tolerance
                        c3sol(i)=0;                                 %make c3=0
                    end
                    pxsol=subs(Px,{c1,c2,c3},{c1sol,0,c3sol(i)});   %sub c1/c2/c3 into Px to get px value
                    pysol=subs(Py,{c1,c2,c3},{c1sol,0,c3sol(i)});   %sub c1/c2/c3 into Py to get py value
                    pzsol=sqrt(L1^2-pxsol^2-pysol^2);               %using px and py, get pz
                    Sm=[Sm;c1sol 0 c3sol(i) pxsol pysol pzsol];     %add values to solution matrix
                end
            end
        end
    end

    for i=1:size(Sm,1)                                          %foreach value of c1
        Rsolve=subs(subs(subs(R,c1,Sm(i,1)),c2,Sm(i,2)),c3,Sm(i,3)); %substitute c1/c2/c3 into Rotation matrix
        Rsolve=double(Rsolve);                                  %convert symbolic matrix to numerical
        Sm(i,1)=vpa(-atan2(Rsolve(2,3),Rsolve(3,3))*180/pi);    %replace c1/c2/c3 with X degree in the solution matrix
        Sm(i,2)=vpa(asin(Rsolve(1,3))*180/pi);                  %replace c1/c2/c3 with Y degree in the solution matrix
        Sm(i,3)=vpa(-atan2(Rsolve(1,2),Rsolve(1,1))*180/pi);    %replace c1/c2/c3 with Z degree in the solution matrix
    end

    for i=1:size(Sm,1)              %for each solution
        trans_coords=coordtrans(Sm(i,1),Sm(i,2),Sm(i,3),Sm(i,4),Sm(i,5),Sm(i,6),xsi,ysi,xmi,ymi); %transform the coordinates from those used in the forward kinematics analysis based on the Lee�s paper to those of the CDSL system
        Sm(i,4)=trans_coords(1);    %add the x component of the position vector rm
        Sm(i,5)=trans_coords(2);    %add the y component of the position vector rm
        Sm(i,6)=trans_coords(3);    %add the z component of the position vector rm
    end

    for i=size(Sm,1):-1:1           %foreach solution
        if rollmin  > double(Sm(i,1)) || double(Sm(i,1)) > rollmax  ||...   %if values are not within min/max
           pitchmin > double(Sm(i,2)) || double(Sm(i,2)) > pitchmax ||...
           yawmin   > double(Sm(i,3)) || double(Sm(i,3)) > yawmax   ||...
           pxmin    > double(Sm(i,4)) || double(Sm(i,4)) > pxmax    ||...
           pymin    > double(Sm(i,5)) || double(Sm(i,5)) > pymax    ||...
           pzmin    > double(Sm(i,6)) || double(Sm(i,6)) > pzmax
                Sm(i,:)=[];         %delete that solution
        end
    end

    for i=size(Sm,1):-1:1           %for each solution
        leg_length=stew_inverse(xsi,ysi,xmi,ymi,Sm(i,1),Sm(i,2),Sm(i,3),Sm(i,4),Sm(i,5),Sm(i,6));%get leg length of solutions from inverse kinematics
        if double(leg_length(1)) < legmin || double(leg_length(1)) > legmax || abs(double(leg_length(1))-L1) > 0.5 ||...    %if the legs are too short, too long, or not the same as the input
           double(leg_length(2)) < legmin || double(leg_length(2)) > legmax || abs(double(leg_length(2))-L2) > 0.5 ||...
           double(leg_length(3)) < legmin || double(leg_length(3)) > legmax || abs(double(leg_length(3))-L3) > 0.5 ||...
           double(leg_length(4)) < legmin || double(leg_length(4)) > legmax || abs(double(leg_length(4))-L4) > 0.5 ||...
           double(leg_length(5)) < legmin || double(leg_length(5)) > legmax || abs(double(leg_length(5))-L5) > 0.5 ||...
           double(leg_length(6)) < legmin || double(leg_length(6)) > legmax || abs(double(leg_length(6))-L6) > 0.5
                Sm(i,:)=[]; %delete that solution.
        end
    end


    solutions=Sm   %return the value

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         