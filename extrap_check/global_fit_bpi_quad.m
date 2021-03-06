xmax = 0.07;

x_phys = eps_phi^2;

for ib=1:nboot+1
	ba_w0(ib,:) = a_w0(:);
end

for ic=1:1;
	 
	GF = bBpi;
    
    %------- Global fit, bootstrap by bootstrap -------------------------------
    clear bx1 bx2 by1 by2 ey1 ey2;
    
	% coarse
    ibeta=1; nmass1=length(iic); %nmass_24cubed_gf;
	im=1;
    for ind=iic;
        bx1(im,:) = squeeze(beps(:,ind)).^2;
        by1(im,:) = squeeze(GF(:,ind));
        ey1(im)   = std(squeeze(by1(im,2:nboot+1)));
        basqr_1   = ba_w0(:,ind).^2;
		im=im+1;
	end
	
	% medium
	ibeta=2; nmass2=length(iim); 
	im=1;
    for ind=iim;
        bx2(im,:) = squeeze(beps(:,ind)).^2;
        by2(im,:) = squeeze(GF(:,ind));
        ey2(im)   = std(squeeze(by2(im,2:nboot+1)));
		basqr_2   = ba_w0(:,ind).^2;
		im=im+1;
	end
	
	
	% fine
	ibeta=3; nmass3=length(iif); 
	im=1;
    for ind=iif;
        bx3(im,:) = squeeze(beps(:,ind)).^2;
        by3(im,:) = squeeze(GF(:,ind));
        ey3(im)   = std(squeeze(by3(im,2:nboot+1)));
		basqr_3   = ba_w0(:,ind).^2;
		im=im+1;
	end
	
    %----- now fit bootstrap by bootstrap
    
    fprintf('\n *** Quadratic extrapolation to the physical point ***');
	fprintf('\n y = A*mpi^2 + Q*mpi^4 + B + C*a^2 ');
    
    clear bA bB bC bQ;
    clear asqr_1 asqr_2 x1 x2 y1 y2;
    
    
    for iboot=1:nboot+1
        asqr_1 = squeeze(basqr_1(iboot));
        asqr_2 = squeeze(basqr_2(iboot));
		asqr_3 = squeeze(basqr_3(iboot));
		
        x1  = squeeze(bx1(:,iboot));
        x2  = squeeze(bx2(:,iboot));
		x3  = squeeze(bx3(:,iboot));
        y1  = squeeze(by1(:,iboot));
        y2  = squeeze(by2(:,iboot));
		y3  = squeeze(by3(:,iboot));

		b = my_global_fit_same_slope_threelat_quad(asqr_1, x1, y1, ey1, asqr_2, x2, y2, ey2,  asqr_3, x3, y3, ey3) ;
        
		bB(iboot) = b(1) ; % intercept
		bA(iboot) = b(2) ; % slope
		bQ(iboot) = b(3) ; % quaddratic in mpi^2
		bC(iboot) = b(4) ; % a^2 coeff
		
		bgfq(:,iboot) = b(:);
		
		by_extrap(iboot) = bB(iboot) + x_phys*bA(iboot) + (x_phys^2) *bQ(iboot);
		
    end
    
    casqr_1 = basqr_1(1);
    casqr_2 = basqr_2(1);
	casqr_3 = basqr_3(1);
    cA = bA(1);
    cB = bB(1);
    cC = bC(1);
	cQ = bQ(1);
    eA = std(bA(2:nboot+1));
    eB = std(bB(2:nboot+1));
    eC = std(bC(2:nboot+1));
	eQ = std(bQ(2:nboot+1));
    
    fprintf('\n A = %7.6f +/- %7.6f ', cA, eA);
	fprintf('\n Q = %7.6f +/- %7.6f ', cQ, eQ);
    fprintf('\n B = %7.6f +/- %7.6f ', cB, eB);
    fprintf('\n C = %7.6f +/- %7.6f ', cC, eC);
    	
	xlab='$\epsilon_\pi^2$';
	ylab=['$B_\pi$'];
		
	clf;
	axes('FontSize',15);
	hold on; box on;
	
	xi=0;
	xf=xmax;
	cy_extrap = by_extrap(1);
	ey_extrap = std(by_extrap(2:nboot+1));
	
	fprintf('\n Extrapolated value = %7.6f +/- %7.6f ', cy_extrap, ey_extrap);
	
	cx1=squeeze(bx1(:,1));
	cx2=squeeze(bx2(:,1));
	cx3=squeeze(bx3(:,1));
	
	cy1 = squeeze(by1(:,1));
	cy2 = squeeze(by2(:,1));
	cy3 = squeeze(by3(:,1));
	clear ey1 ey2 ey3
	for i=1:nmass1
		ey1(i) = std(squeeze(by1(i,2:nboot+1)));
	end;
	for i=1:nmass2
		ey2(i) = std(squeeze(by2(i,2:nboot+1)));
	end;
	for i=1:nmass3
		ey3(i) = std(squeeze(by3(i,2:nboot+1)));
	end;
	
	xmin=0;
	if ic==1
		ymin=-0.032;
		ymax=-0.014;
	end
	
	if ic==2
		ymin=-0.11;
		ymax=-0.05;
	end
	
	
	if ic==3
		ymin=-0.085;
		ymax=-0.02;
	end
	
	if ic==4
		ymin=0.012;
		ymax=0.02;
	end
	
	if ic==5
		ymin=0.0;
		ymax=0.002;
	end
	
	
	ymin=0.3;
	
	ymax=0.75;
	
	symbol='bs';
	
	
	Plot_results_tex(cx1, cy1, ey1, xlab, ylab, 'rs', 'r', ymin, ymax, xmin, xmax);
	Plot_results_tex(cx2, cy2, ey2, xlab, ylab, 'rd', 'r', ymin, ymax, xmin, xmax);
	Plot_results_tex(cx3, cy3, ey3, xlab, ylab, 'ro', 'r', ymin, ymax, xmin, xmax);
	
	Plot_results_tex(x_phys, cy_extrap, ey_extrap, xlab, ylab, 'kx', 'k', ymin, ymax, xmin, xmax);
	
	delta = (xf-xi)/1000;
	iix=xi:delta:xf;
	yplot_1 = cQ*iix.^2 +cA*iix+cB+casqr_1*cC;
	yplot_2 = cQ*iix.^2 +cA*iix+cB+casqr_2*cC;
	yplot_3 = cQ*iix.^2 +cA*iix+cB+casqr_3*cC;
	yplot_e = cQ*iix.^2 +cA*iix+cB;
	
	
	plot(iix, yplot_1, 'r--');
	plot(iix, yplot_2, 'r--');
	plot(iix, yplot_3, 'r--');
	plot(iix, yplot_e, 'k-');
	
	
	myprintplot(['Bpi_' num2str(ic) '_fit' ]);
	    
end
