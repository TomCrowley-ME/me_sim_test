h=get(0,'Children');
% h=gcf;
for i=1:length(h)
  if isempty(strfind(h(i).Name,'Phase Plane'))
    ax=findobj(h(i),'Type','axes');
    for k=1:length(ax)
        axes(ax(k))
        xl=xlim;
        yl=ylim+[eps -eps];
        ybox=yl([1 2 2 1]);
        %% pre-egc firing
        if exist('egc_on','var')
          xbox=[xl([1 1]) egc_on([1 1])*dt];
          p=patch(xbox,ybox,[180 180 180]/255,'EdgeColor','none','FaceAlpha', 0.2);
          uistack(p,'bottom');uistack(p,'up');
        end
        %% pre-takeoff
        if exist('takeoff','var')
          if exist('egc_on','var')
            xbox=[egc_on([1 1]) takeoff([1 1])]*dt;
          else
            xbox=[xl([1 1]) takeoff([1 1])*dt];
          end
          p=patch(xbox,ybox,'m','EdgeColor','none','FaceAlpha', 0.2);
          uistack(p,'bottom');
        end
        %% takeoff
        if exist('end_takeoff','var')
          if exist('takeoff','var')
            xbox=[takeoff([1 1]) end_takeoff([1 1])]*dt;
          elseif exist('egc_on','var')
            xbox=[egc_on([1 1]) end_takeoff([1 1])]*dt;
          else
            xbox=[xl([1 1]) end_takeoff([1 1])*dt];
          end
          p=patch(xbox,ybox,'b','EdgeColor','none','FaceAlpha', 0.2);
          uistack(p,'bottom');
        end
        %% hover
        if exist('descent','var')
          if exist('end_takeoff','var')
            xbox=[end_takeoff([1 1]) descent([1 1])]*dt;
          elseif exist('takeoff','var')
            xbox=[takeoff([1 1]) descent([1 1])]*dt;
          elseif exist('egc_on','var')
            xbox=[egc_on([1 1]) descent([1 1])]*dt;
          else
            xbox=[xl([1 1]) descent([1 1])*dt];
          end
          p=patch(xbox,ybox,[150 150 150]/255,'EdgeColor','none','FaceAlpha', 0.3);
          uistack(p,'bottom');
        end
        %% descent
        if exist('egc_off','var')
          if exist('descent','var')
            xbox=[descent([1 1]) egc_off([1 1])]*dt;
          elseif exist('end_hover','var')
            xbox=[end_hover([1 1]) egc_off([1 1])]*dt;
          elseif exist('end_takeoff','var')
            xbox=[end_takeoff([1 1]) egc_off([1 1])]*dt;
          elseif exist('takeoff','var')
            xbox=[takeoff([1 1]) egc_off([1 1])]*dt;
          elseif exist('egc_on','var')
            xbox=[egc_on([1 1]) egc_off([1 1])]*dt;
          else
            xbox=[xl([1 1]) egc_off([1 1])*dt];
          end
          p=patch(xbox,ybox,'c','EdgeColor','none','FaceAlpha', 0.2);
          uistack(p,'bottom');
        end
        %% egc-off to landed
        if exist('landed','var')
          if exist('egc_off','var')
            xbox=[egc_off([1 1]) landed([1 1])]*dt;
          elseif exist('descent','var')
            xbox=[descent([1 1]) landed([1 1])]*dt;
          elseif exist('end_hover','var')
            xbox=[end_hover([1 1]) landed([1 1])]*dt;
          elseif exist('egc_off','var')
            xbox=[egc_off([1 1]) landed([1 1])]*dt;
          else
            xbox=[landed([1 1])*dt xl([2 2])];
          end
          p=patch(xbox,ybox,'g','EdgeColor','none','FaceAlpha', 0.2);
          uistack(p,'bottom');
        end
        last=max(landed,egc_off);
        xbox=[last([1 1])*dt xl([2 2])];
        p=patch(xbox,ybox,'y','EdgeColor','none','FaceAlpha', 0.2);
        uistack(p,'bottom');
    end
  end
end
