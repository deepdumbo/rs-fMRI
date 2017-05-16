%% ThePlot:
function [] = ThePlot(subject,mov,fdPower,fdJenk,dvars,ts_compartment,key_compartment,movThr,fdPowerThr,fdJenkThr)

	% This function plots a series of movement traces over top of a plot of timeseries as
	% as in Power (2016), called 'ThePlot'
	% It will overlay dashed horizontal lines on the movement parameter traces and fdPower traces
	% according to movThr and fdPowerThr, respectively
	%
	% ------
	% INPUTS
	% ------
	% subject			- a string identifying the subject being plotted.
	% 					Note, this is just for naming the output .png file
	% mov 				- a matrix containing movement parameters extracted from SPM8's realignment
	% fdPower			- a vector containing Power's framewise displacement (see GetFDPower.m)
	% fdJenk			- a vector containing Jenkinson's framewise displacement (see GetFDJenk.m)
	% dvars 			- a vector containg dvars (see GetDVARS.m)
	% 
	% ts_compartment 	- a numVols x numVoxels timeseries matrix compartmentalised by
	% 					grey/white/csf (see GetTSCompartment.m)
	% key_compartment 	- a vector denoting which compartment a voxel belongs to (see GetTSCompartment.m)
	% 
	% movThr 			- cut off for movement parameters. default = 2
	% 					Note, only for visualisation
	% fdPowerThr 		- cut off for fdPower trace. default = 0.2
	% fdJenkThr 		- cut off for fdJenk trace. default = 0.25
	% -------
	% OUTPUTS
	% -------
	% A pretty plot...
	%
	% Linden Parkes, Brain & Mental Health Laboratory, 2016
	% ------------------------------------------------------------------------------	

	if nargin < 8
		movThr = 2;
	end

	if nargin < 9
		fdPowerThr = 0.2;
	end

	if nargin < 10
		fdJenkThr = 0.25;
	end

    numVols = size(ts_compartment,1);

	% ------------------------------------------------------------------------------
	% Plot
	% ------------------------------------------------------------------------------
    h1 = figure('color','w','name',['ThePlot: ',subject]); box('on'); hold on;
	
	set(h1,'PaperType','A4', ...
	         'paperOrientation', 'portrait', ...
	         'paperunits','CENTIMETERS', ...
	         'PaperPosition',[.63, .63, 19.72, 28.41]);

	h2 = suptitle(['ThePlot: ',subject]);
    pos = get(h2,'Position');
    set(h2,'Position',[pos(1)*1, pos(2)*0.5, pos(3)*1]);

	% ------------------------------------------------------------------------------
	% Movement: translation
	% ------------------------------------------------------------------------------
	sp1 = subplot(6,2,1);
    pos1 = get(sp1,'Position');
	plot(mov(:,1));
	hold on
	plot(mov(:,2),'g');
	plot(mov(:,3),'r');
	title('translation','fontweight','bold')
	ylabel('mm')
	legend({'x','y','z'},'Orientation','horizontal','Location','best')
	legend('boxoff')
	xlim([1 numVols])
    set(sp1,'XTickLabel','');

	% overlay threshold line
	if any(max(abs(mov(:,1:3))) > movThr)
		line([0 numVols],[movThr movThr],'LineStyle','--','Color','k')
		line([0 numVols],[-movThr -movThr],'LineStyle','--','Color','k')
		ylim([-movThr-1 movThr+1])
	end
	
	% ------------------------------------------------------------------------------
	% Movement: rotation
	% ------------------------------------------------------------------------------
	% First convert to mm using Power's approach
	mov(:,4:6) = 50*pi/180*mov(:,4:6);

	sp2 = subplot(6,2,3);
    pos2 = get(sp2,'Position');
	plot(mov(:,4));
	hold on
	plot(mov(:,5),'g');
	plot(mov(:,6),'r');
	title('rotation','fontweight','bold');
	ylabel('mm')
	legend({'pitch','roll','yaw'},'Orientation','horizontal','Location','best')
	legend('boxoff')
	xlim([1 numVols])
    set(sp2,'XTickLabel','');

	% overlay threshold line
	if any(max(abs(mov(:,4:6))) > movThr)
		line([0 numVols],[movThr movThr],'LineStyle','--','Color','k')
		line([0 numVols],[-movThr -movThr],'LineStyle','--','Color','k')
		ylim([-movThr-1 movThr+1])
	end

	% ------------------------------------------------------------------------------
	% FD Power
	% ------------------------------------------------------------------------------
	sp3 = subplot(6,2,5);
    pos3 = get(sp3,'Position');
	plot(fdPower)
	hold on
	title('fdPower','fontweight','bold')
	ylabel('mm')
	xlim([1 numVols])
	ylim([0 max(fdPower)+(max(fdPower)*.10)])
    set(sp3,'XTickLabel','');

	% overlay threshold line
	if max(fdPower) > fdPowerThr
		line([0 numVols],[fdPowerThr fdPowerThr],'LineStyle','--','Color','k')
	end

	% ------------------------------------------------------------------------------
	% FD Jenk
	% ------------------------------------------------------------------------------
	str = 'fdJenk. ';
	% Compute cut offs for exclusions
		fdJenk_m = mean(fdJenk);
		fdJenkPerc = MyRound(sum(fdJenk > fdJenkThr)/numVols*100);
		fdJenkThrPerc = MyRound(numVols * 0.20);
		
		if fdJenk_m > 0.2 | fdJenkPerc > fdJenkThrPerc
			str1 = ['Mean: ',num2str(MyRound(fdJenk_m)),'mm, '];
			str2 = ['Spikes: ',num2str(fdJenkPerc),'%'];
		else
			str1 = '';
			str2 = '';
		end		

	sp4 = subplot(6,2,7);
    pos4 = get(sp4,'Position');
	plot(fdJenk)
	hold on
	title([str,str1,str2],'fontweight','bold')
	ylabel('mm')
	xlim([1 numVols])
	ylim([0 max(fdJenk)+(max(fdJenk)*.10)])
    set(sp4,'XTickLabel','');

	% overlay threshold line
	if max(fdJenk) > fdJenkThr
		line([0 numVols],[fdJenkThr fdJenkThr],'LineStyle','--','Color','k')
	end

	% ------------------------------------------------------------------------------
	% DVARS
	% ------------------------------------------------------------------------------
	sp5 = subplot(6,2,9);
    pos5 = get(sp5,'Position');
	plot(dvars)
	title('dvars','fontweight','bold')
	ylabel('rms signal change')
	xlim([1 numVols])
	ylim([0 max(dvars)+(max(dvars)*.10)])
    set(sp5,'XTickLabel','');

	% ------------------------------------------------------------------------------
	% Time series
	% ------------------------------------------------------------------------------
	sp6 = subplot(6,2,11);
    pos6 = get(sp6,'Position');
	imagesc(ts_compartment')
	colormap(gray)
	caxis([0 1])
	title('Time Series','fontweight','bold')
	ylabel('Voxels')
	xlabel('time (volumes)')
	colorbar

	sp7 = subplot(6,2,12);
    pos7 = get(sp7,'Position');
	imagesc(key_compartment')
    set(sp7,'YTickLabel','','XTickLabel','','TickLength',[0,0]);

    % ------------------------------------------------------------------------------
    % Sizing
    % ------------------------------------------------------------------------------
	% [left bottom width height]
    set(sp1,'Position',[pos1(1)*.7, pos1(2)*1.02 pos1(3)*2.5, pos1(4)*1]);
    set(sp2,'Position',[pos2(1)*.7, pos2(2)*1.035, pos2(3)*2.5, pos2(4)*1]);
    set(sp3,'Position',[pos3(1)*.7, pos3(2)*1.05, pos3(3)*2.5, pos3(4)*1]);
    set(sp4,'Position',[pos4(1)*.7, pos4(2)*1.08, pos4(3)*2.5, pos4(4)*1]);
    set(sp5,'Position',[pos5(1)*.7, pos5(2)*1.125, pos5(3)*2.5, pos5(4)*1]);
    
    set(sp6,'Position',[pos6(1)*.7, pos6(2)*0.35, pos6(3)*2.5, pos6(4)*2]);
    set(sp7,'Position',[pos7(1)*.09, pos7(2)*0.35, pos7(3)*.1, pos7(4)*2]);

end