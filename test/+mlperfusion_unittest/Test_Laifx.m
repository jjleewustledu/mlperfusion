classdef Test_Laifx < matlab.unittest.TestCase 
	%% TEST_LAIFX  

	%  Usage:  >> results = run(mlperfusion_unittest.Test_Laifx)
 	%          >> result  = run(mlperfusion_unittest.Test_Laifx, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 

	properties 
        testMagn
 		testObj        
        testFolder   = '/Volumes/SeagateBP3/cvl/np755/mm01-007_p7267_2008jun16/bayesian_pet'
        dscFilename  = '/Volumes/SeagateBP3/cvl/np755/mm01-007_p7267_2008jun16/bayesian_pet/ep2d_default_mcf.nii.gz'
        maskFilename = '/Volumes/SeagateBP3/cvl/np755/mm01-007_p7267_2008jun16/bayesian_pet/ep2d_mask.nii.gz'
        test_plots   = true
        test_mcmc    = true
 	end 

    properties (Dependent)       
        F  
        S0
        a 
        b  
        d  
        e  
        g 
        n  
        t0 
        t1
        times
    end
    
    methods %% GET/SET
        function x = get.F(this)
            x = this.testObj.F;
        end
        function x = get.S0(this)
            x = this.testObj.S0;
        end
        function x = get.a(this)
            x = this.testObj.a;
        end
        function x = get.b(this)
            x = this.testObj.b;
        end
        function x = get.d(this)
            x = this.testObj.d;
        end
        function x = get.e(this)
            x = this.testObj.e;
        end
        function x = get.g(this)
            x = this.testObj.g;
        end
        function x = get.n(this)
            x = this.testObj.n;
        end
        function x = get.t0(this)
            x = this.testObj.t0;
        end
        function x = get.t1(this)
            x = this.testObj.t1;
        end
        function t = get.times(this)
            t = this.wbDsc.times;
        end
    end
    
	methods (Test)
        
        %% TESTS WITH PLOTTING
        
 		function test_plotFs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            F_ = [0.25 0.5 1 2 3 4];
            for idx = 1:length(F_)
                plot(this.times, ...
                     mlperfusion.Laif0.magnetization( ...
                         F_(idx), this.S0, this.a, this.b, this.d, this.times, this.t0));
            end
            title(sprintf('F VAR, S0 %g, a %g, b %g, d %g, t0 %g', ...
                                  this.S0, this.a, this.b, this.d,             this.t0));
            legend(cellfun(@(x) sprintf('F = %g', x), num2cell(F_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetizatin/arbitrary');
        end 
 		function test_plotS0s(this)
            if (~this.test_plots); return; end
            figure
            hold on
            S0_ = [400 500 600 700];
            for idx = 1:length(S0_)
                plot(this.times, ...
                     mlperfusion.Laif0.magnetization( ...
                         this.F, S0_(idx), this.a, this.b, this.d, this.times, this.t0));
            end
            title(sprintf('F %g, S0 VAR, a %g, b %g, d %g, t0 %g', ...
                         this.F,           this.a, this.b, this.d,             this.t0));
            legend(cellfun(@(x) sprintf('S0 = %g', x), num2cell(S0_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetizatin/arbitrary');
        end 
 		function test_plotAs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            a_ = [0.125 0.25 0.5 1 2 4 8];
            for idx = 1:length(a_)
                plot(this.times, ...
                     mlperfusion.Laif0.magnetization( ...
                         this.F, this.S0, a_(idx), this.b, this.d, this.times, this.t0));
            end
            title(sprintf('F %g, S0 %g, a VAR, b %g, d %g, t0 %g', ...
                         this.F, this.S0,          this.b, this.d,             this.t0));
            legend(cellfun(@(x) sprintf('a = %g', x), num2cell(a_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetizatin/arbitrary');
        end 
 		function test_plotBs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            b_ = [0.125 0.25 0.5 1 2 4 8];
            for idx = 1:length(b_)
                plot(this.times, ...
                     mlperfusion.Laif0.magnetization( ...
                         this.F, this.S0, this.a, b_(idx), this.d, this.times, this.t0));
            end
            title(sprintf('F %g, S0 %g, a %g, b VAR, d %g, t0 %g', ...
                         this.F, this.S0, this.a,          this.d,             this.t0));
            legend(cellfun(@(x) sprintf('b = %g', x), num2cell(b_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetizatin/arbitrary');
        end 
 		function test_plotDs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            d_ = [0.0125 0.125 0.25 0.5 1 2];
            for idx = 1:length(d_)
                plot(this.times, ...
                     mlperfusion.Laif0.magnetization( ...
                         this.F, this.S0, this.a, this.b, d_(idx), this.times, this.t0));
            end
            title(sprintf('S0 %g, F %g, a %g, b %g, d VAR, t0 %g', ...
                         this.F, this.S0, this.a, this.b,                      this.t0));
            legend(cellfun(@(x) sprintf('d = %g', x), num2cell(d_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetizatin/arbitrary');
        end 
 		function test_plotEs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            e_ = [0.5 0.6 0.7 0.8 0.9 0.95 0.98];
            for idx = 1:length(e_)
                plot(this.times, ...
                     mlperfusion.Laif1.magnetization( ...
                         this.F, this.S0, this.a, this.b, this.d, e_(idx), this.g, this.times, this.t0));
            end
            title(sprintf('F %g, S0 %g, a %g, b %g, d %g, e VAR, g %g, t0 %g', ...
                         this.F, this.S0, this.a, this.b, this.d,          this.g,             this.t0));
            legend(cellfun(@(x) sprintf('e = %g', x), num2cell(e_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end 
 		function test_plotGs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            g_ = [0.0125 0.05 0.125 0.25 0.5 1];
            for idx = 1:length(g_)
                plot(this.times, ...
                     mlperfusion.Laif1.magnetization( ...
                         this.F, this.S0, this.a, this.b, this.d, this.e, g_(idx), this.times, this.t0));
            end
            title(sprintf('F %g, S0 %g, a %g, b %g, d %g, e %g, g VAR, t0 %g', ...
                         this.F, this.S0, this.a, this.b, this.d, this.e,                      this.t0));
            legend(cellfun(@(x) sprintf('g = %g', x), num2cell(g_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end 
 		function test_plotNs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            n_ = [0.01 0.05 0.1 0.2 0.4 0.8 1];
            for idx = 1:length(n_)
                plot(this.times, ...
                     mlperfusion.Laif2.magnetization( ...
                         this.F, this.S0, this.a, this.b, this.d, this.e, this.g, n_(idx), this.times, this.t0, this.t1));
            end
            title(sprintf('F %g, S0 %g, a %g, b %g, d %g, e %g, g %g, n VAR, t0 %g, t1 %g', ...
                         this.F, this.S0, this.a, this.b, this.d, this.e, this.g,                      this.t0, this.t1));
            legend(cellfun(@(x) sprintf('n = %g', x), num2cell(n_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end
 		function test_plotT0s(this)
            if (~this.test_plots); return; end
            figure
            hold on
            t0_ = [1 2 4 8 16 32 64];
            for idx = 1:length(t0_)
                plot(this.times, ...
                     mlperfusion.Laif0.magnetization( ...
                         this.F, this.S0, this.a, this.b, this.d, this.times, t0_(idx)));
            end
            title(sprintf('F %g, S0 %g, a %g, b %g, d %g, t0 VAR', ...
                         this.F, this.S0, this.a, this.b, this.d));
            legend(cellfun(@(x) sprintf('t0 = %g', x), num2cell(t0_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end 
 		function test_plotT1s(this)
            if (~this.test_plots); return; end
            figure
            hold on
            t1_ = [4 8 12 16 24 32 64];
            for idx = 1:length(t1_)
                plot(this.times, ...
                     mlperfusion.Laif2.magnetization( ...
                         this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.n, this.times, this.t0, t1_(idx)));
            end
            title(sprintf('F %g, S0 %g, a %g, b %g, d %g, e %g, g %g, n %g, t0 %g, t1 VAR', ...
                         this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.n,             this.t0));
            legend(cellfun(@(x) sprintf('t1 = %g', x), num2cell(t1_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end  
        
 		function test_plotBolusAs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            a_ = [0.125 0.25 0.5 1 2 4 8];
            for idx = 1:length(a_)
                plot(this.times, ...
                     mlperfusion.Laif0.kAif( ...
                         a_(idx), this.b, this.times, this.t0));
            end
            title(sprintf('a VAR, b %g, t0 %g', ...
                                  this.b,             this.t0));
            legend(cellfun(@(x) sprintf('a = %g', x), num2cell(a_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
 		function test_plotBolusBs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            b_ = [0.125 0.25 0.5 1 2 4 8];
            for idx = 1:length(b_)
                plot(this.times, ...
                     mlperfusion.Laif0.kAif( ...
                         this.a, b_(idx), this.times, this.t0));
            end
            title(sprintf('a %g, b VAR, t0 %g', ...
                         this.a,                      this.t0));
            legend(cellfun(@(x) sprintf('b = %g', x), num2cell(b_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
 		function test_plotBolusEs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            e_ = [0.5 0.6 0.7 0.8 0.9 0.95 0.98];
            for idx = 1:length(e_)
                plot(this.times, ...
                     mlperfusion.Laif1.kAif( ...
                         this.a, this.b, e_(idx), this.g, this.times, this.t0));
            end
            title(sprintf('a %g, b %g, e VAR, g %g, t0 %g', ...
                         this.a, this.b,          this.g,             this.t0));
            legend(cellfun(@(x) sprintf('e = %g', x), num2cell(e_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
 		function test_plotBolusGs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            g_ = [0.0125 0.05 0.125 0.25 0.5 1];
            for idx = 1:length(g_)
                plot(this.times, ...
                     mlperfusion.Laif1.kAif( ...
                         this.a, this.b, this.e, g_(idx), this.times, this.t0));
            end
            title(sprintf('a %g, b %g, e %g, g VAR, t0 %g', ...
                         this.a, this.b, this.e,                      this.t0));
            legend(cellfun(@(x) sprintf('g = %g', x), num2cell(g_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
 		function test_plotBolusNs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            n_ = [0.01 0.05 0.1 0.2 0.4 0.8 1];
            for idx = 1:length(n_)
                plot(this.times, ...
                     mlperfusion.Laif2.kAif( ...
                         this.a, this.b, this.e, this.g, n_(idx), this.times, this.t0, this.t1));
            end
            title(sprintf('a %g, b %g, e %g, g %g, n VAR, t0 %g, t1 %g', ...
                         this.a, this.b, this.e, this.g,                      this.t0, this.t1));
            legend(cellfun(@(x) sprintf('n = %g', x), num2cell(n_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
 		function test_plotBolusT0s(this)
            if (~this.test_plots); return; end
            figure
            hold on
            t0_ = [1 2 4 8 16 32 64];
            for idx = 1:length(t0_)
                plot(this.times, ...
                     mlperfusion.Laif0.kAif( ...
                         this.a, this.b, this.times, t0_(idx)));
            end
            title(sprintf('a %g, b %g, t0 VAR', ...
                         this.a, this.b));
            legend(cellfun(@(x) sprintf('t0 = %g', x), num2cell(t0_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
 		function test_plotBolusT1s(this)
            if (~this.test_plots); return; end
            figure
            hold on
            t1_ = [4 8 12 16 24 32 64];
            for idx = 1:length(t1_)
                plot(this.times, ...
                     mlperfusion.Laif2.kAif( ...
                         this.a, this.b, this.e, this.g, this.n, this.times, this.t0, t1_(idx)));
            end
            title(sprintf('a %g, b %g, e %g, g %g, n %g, t0 %g, t1 VAR', ...
                         this.a, this.b, this.e, this.g, this.n,             this.t0));
            legend(cellfun(@(x) sprintf('t1 = %g', x), num2cell(t1_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
        
        %% MCMC TESTS
        
        function test_simulateMcmc0(this)
            %% TEST_SIMULATEMCMC0 constructs for mlperfusion.Laif0 a parameter map, the corresponding test-case magnetization, 
            %  then runs Laif0's MCMC to fit the test-case magnetization.  This is a test of Laif0's ability to fit 
            %  a synthetic magnetization created directly from it's own magnetization model.   
            
            if (~this.test_mcmc); return; end
            import mlperfusion.*;
            this.testObj = Laif0;
            aMap = containers.Map;
            fL = 0.85; fH = 1.15;
            aMap('F')  = struct('fixed', 0, 'min', fL*this.F,  'mean', this.F,  'max', fH*this.F);
            aMap('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            aMap('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            aMap('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            aMap('d')  = struct('fixed', 0, 'min', fL*this.d,  'mean', this.d,  'max', fH*this.d);
            aMap('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0);            
            this.testMagn = Laif0.magnetization(this.F, this.S0, this.a, this.b, this.d, this.times, this.t0); 
            assert(~any(isnan(    this.testMagn)));
            assert(~any(~isfinite(this.testMagn)));
            
            o = Laif0.simulateMcmc(this.F, this.S0, this.a, this.b, this.d, this.times, this.t0, this.testMagn, aMap);
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.05);
        end
        function test_simulateMcmc1(this)
            %% TEST_SIMULATEMCMC1 constructs for mlperfusion.Laif1 a parameter map, the corresponding test-case magnetization, 
            %  then runs Laif1's MCMC to fit the test-case magnetization.  This is a test of Laif1's ability to fit 
            %  a synthetic magnetization created directly from it's own magnetization model.   
            
            if (~this.test_mcmc); return; end
            import mlperfusion.*;
            this.testObj = Laif1;
            aMap = containers.Map;
            fL = 0.85; fH = 1.15;
            aMap('F')  = struct('fixed', 0, 'min', fL*this.F,  'mean', this.F,  'max', fH*this.F);
            aMap('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            aMap('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            aMap('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            aMap('d')  = struct('fixed', 0, 'min', fL*this.d,  'mean', this.d,  'max', fH*this.d);
            aMap('e')  = struct('fixed', 0, 'min', fL*this.e,  'mean', this.e,  'max', fH*this.e);
            aMap('g')  = struct('fixed', 0, 'min', fL*this.g,  'mean', this.g,  'max', fH*this.g);
            aMap('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0);            
            this.testMagn = Laif1.magnetization(this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.times, this.t0); 
            assert(~any(isnan(    this.testMagn)));
            assert(~any(~isfinite(this.testMagn)));
            
            o = Laif1.simulateMcmc(this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.times, this.t0, this.testMagn, aMap);
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.05);
        end
        function test_simulateMcmc2(this)
            %% TEST_SIMULATEMCMC2 constructs for mlperfusion.Laif2 a parameter map, the corresponding test-case magnetization, 
            %  then runs Laif2's MCMC to fit the test-case magnetization.  This is a test of Laif2's ability to fit 
            %  a synthetic magnetization created directly from it's own magnetization model.   
            
            if (~this.test_mcmc); return; end
            import mlperfusion.*;
            this.testObj = Laif2;
            aMap = containers.Map; 
            fL = 0.85; fH = 1.15;  
            aMap('F')  = struct('fixed', 0, 'min', fL*this.F,  'mean', this.F,  'max', fH*this.F);
            aMap('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            aMap('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            aMap('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            aMap('d')  = struct('fixed', 0, 'min', fL*this.d,  'mean', this.d,  'max', fH*this.d);
            aMap('e')  = struct('fixed', 0, 'min', fL*this.e,  'mean', this.e,  'max', fH*this.e);
            aMap('g')  = struct('fixed', 0, 'min', fL*this.g,  'mean', this.g,  'max', fH*this.g);
            aMap('n')  = struct('fixed', 0, 'min', fL*this.n,  'mean', this.n,  'max', fH*this.n); 
            aMap('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0); 
            aMap('t1') = struct('fixed', 0, 'min', fL*this.t1, 'mean', this.t1, 'max', fH*this.t1);            
            this.testMagn = Laif2.magnetization(this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.n, this.times, this.t0, this.t1); 
            assert(~any(isnan(    this.testMagn)));
            assert(~any(~isfinite(this.testMagn)));
            
            o = Laif2.simulateMcmc(this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.n, this.times, this.t0, this.t1, this.testMagn, aMap);
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.05);
        end
        
        function test_Laif0(this)
            %% TEST_LAIF0 invokes Laif0.runLaif on experimental data from this.dscFilenme; best-fit parameters
            %  must match expected values to relative tolerance of 0.1.
            
            if (~this.test_mcmc); return; end
            this.testObj = mlperfusion.Laif0.runLaif(this.wbDsc.times, this.wbDsc.itsMagnetization);
            o = this.testObj;
            
            figure;
            plot(o.independentData, o.estimateData, this.wbDsc.times, this.wbDsc.itsMagnetization, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('Laif0:  F %g,bS0 %g, alpha %g, beta %g, delta %g, t0 %g', ...
                  o.F, o.S0, o.a, o.b, o.d, o.t0));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
            
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.1);
        end
        function test_Laif1(this)
            %% TEST_LAIF2 invokes Laif1.runLaif on experimental data from this.dscFilenme; best-fit parameters
            %  must match expected values to relative tolerance of 0.1.
            
            if (~this.test_mcmc); return; end
            this.testObj = mlperfusion.Laif1.runLaif(this.wbDsc.times, this.wbDsc.itsMagnetization);
            o = this.testObj;
            
            figure;
            plot(o.independentData, o.estimateData, this.wbDsc.times, this.wbDsc.itsMagnetization, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('Laif1:  F %g, S0 %g, alpha %g, beta %g, delta %g, eps %g, gamma %g, t0 %g', ...
                  o.F, o.S0, o.a, o.b, o.d, o.e, o.g, o.t0));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
            
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.1);
        end
        function test_Laif2(this)
            %% TEST_LAIF2 invokes Laif2.runLaif on experimental data from this.dscFilenme; best-fit parameters
            %  must match expected values to relative tolerance of 0.1.
            
            if (~this.test_mcmc); return; end
            this.testObj = mlperfusion.Laif2.runLaif(this.wbDsc.times, this.wbDsc.itsMagnetization);
            o = this.testObj;
            
            figure;
            plot(o.independentData, o.estimateData, this.wbDsc.times, this.wbDsc.itsMagnetization, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('Laif1:  F %g, S0 %g, alpha %g, beta %g, delta %g, eps %g, gamma %g, nu %g, t0 %g, t1 %g', ...
                  o.F, o.S0, o.a, o.b, o.d, o.e, o.g, o.n, o.t0, o.t1));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
            
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.05);
        end
 	end 

 	methods (TestClassSetup) 
 	end 

 	methods (TestClassTeardown) 
    end 
    
 	methods 
 		function this = Test_Laifx
            this = this@matlab.unittest.TestCase;
            this = this.buildDsc;
            this.testObj = mlperfusion.Laif2;
 		end 
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
        wbDsc
    end
    
    methods (Access = 'private')
        function this = buildDsc(this)
            import mlfourd.*;
            this.wbDsc = mlperfusion.WholeBrainDSC( ...
                       this.dscFilename, ...
                       this.maskFilename);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

