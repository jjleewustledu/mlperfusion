classdef Test_BayesianDCVx < matlab.unittest.TestCase 
	%% TEST_BAYESIANDCVX  

	%  Usage:  >> results = run(mlperfusion_unittest.Test_BayesianDCVx)
 	%          >> result  = run(mlperfusion_unittest.Test_BayesianDCVx, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 

	properties 
        model       = 1
        testMagn
 		testObj        
        testFolder  = '/Volumes/InnominateHD3/Local/test/cvl/np755_Bayesian/mm01-007_p7267_2008jun16/bayesian_pet'
        dcvFilename = '/Volumes/InnominateHD3/Local/test/cvl/np755_Bayesian/mm01-007_p7267_2008jun16/bayesian_pet/p7267ho1.dcv'
        test_plots  = true
        test_mcmc   = true
 	end 

    properties (Dependent) 
        S0
        a 
        b  
        e  
        g 
        n  
        t0 
        t1
        times
    end
    
    methods %% GET/SET
        function x = get.S0(this)
            x = this.testObj.S0;
        end
        function x = get.a(this)
            x = this.testObj.a;
        end
        function x = get.b(this)
            x = this.testObj.b;
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
            t = this.dcv.times;
        end
    end
    
	methods (Test)
        
        %% TESTS WITH PLOTTING
        
 		function test_plotS0s(this)
            if (~this.test_plots); return; end
            figure
            hold on
            S0_ = [0.25 0.5 1 2 4] * this.S0;
            for idx = 1:length(S0_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV0.wellCounts( ...
                         S0_(idx), this.a, this.b, this.t0, this.times));
            end
            title(sprintf('S0 VAR, a %g, b %g, t0 %g', ...
                                   this.a, this.b, this.t0));
            legend(cellfun(@(x) sprintf('S0 = %g', x), num2cell(S0_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('activity/Bq');
        end 
 		function test_plotAs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            a_ = [0.25 0.5 1 2 4] * this.a;
            for idx = 1:length(a_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV0.wellCounts( ...
                         this.S0, a_(idx), this.b, this.t0, this.times));
            end
            title(sprintf('S0 %g, a VAR, b %g, t0 %g', ...
                         this.S0,          this.b, this.t0));
            legend(cellfun(@(x) sprintf('a = %g', x), num2cell(a_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('activity/Bq');
        end 
 		function test_plotBs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            b_ = [0.25 0.5 1 2 4] * this.b;
            for idx = 1:length(b_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV0.wellCounts( ...
                         this.S0, this.a, b_(idx), this.t0, this.times));
            end
            title(sprintf('S0 %g, a %g, b VAR, t0 %g', ...
                         this.S0, this.a,          this.t0));
            legend(cellfun(@(x) sprintf('b = %g', x), num2cell(b_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('activity/Bq');
        end 
 		function test_plotEs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            e_ = [0.25 0.5 1 2 4] * this.e;
            for idx = 1:length(e_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV1.wellCounts( ...
                         this.S0, this.a, this.b, e_(idx), this.g, this.t0, this.times));
            end
            title(sprintf('S0 %g, a %g, b %g, e VAR, g %g, t0 %g', ...
                         this.S0, this.a, this.b,          this.g, this.t0));
            legend(cellfun(@(x) sprintf('e = %g', x), num2cell(e_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('activity/Bq');
        end 
 		function test_plotGs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            g_ = [0.25 0.5 1 2 4] * this.g;
            for idx = 1:length(g_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV1.wellCounts( ...
                         this.S0, this.a, this.b,  this.e, g_(idx), this.t0, this.times));
            end
            title(sprintf('S0 %g, a %g, b %g, e %g, g VAR, t0 %g', ...
                         this.S0, this.a, this.b,  this.e,          this.t0));
            legend(cellfun(@(x) sprintf('g = %g', x), num2cell(g_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('activity/Bq');
        end 
 		function test_plotNs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            n_ = [0.25 0.5 1 2 4] * this.n;
            for idx = 1:length(n_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV2.wellCounts( ...
                         this.S0, this.a, this.b,  this.e, this.g, n_(idx), this.t0, this.t1, this.times));
            end
            title(sprintf('S0 %g, a %g, b %g, e %g, g %g, n VAR, t0 %g, t1 %g', ...
                         this.S0, this.a, this.b,  this.e, this.g,          this.t0, this.t1));
            legend(cellfun(@(x) sprintf('n = %g', x), num2cell(n_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('activity/Bq');
        end
 		function test_plotT0s(this)
            if (~this.test_plots); return; end
            figure
            hold on
            tspan = this.times(end) - this.times(1);
            t0_ = [ -0.5 -0.3 -0.1 -0.05 -0.02 0 0.02 0.05 0.1 0.3 0.5 ]*tspan + this.t0;
            for idx = 1:length(t0_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV0.wellCounts( ...
                         this.S0, this.a, this.b, t0_(idx), this.times));
            end
            title(sprintf('S0 %g, a %g, b %g, t0 VAR', ...
                         this.S0, this.a, this.b));
            legend(cellfun(@(x) sprintf('t0 = %g', x), num2cell(t0_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('activity/Bq');
        end 
 		function test_plotT1s(this)
            if (~this.test_plots); return; end
            figure
            hold on
            t1_ = [ -50 -20 -10 -4 -2 0 2 4 10 20 50] + this.t1;
            for idx = 1:length(t1_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV2.wellCounts( ...
                         this.S0, this.a, this.b, this.e, this.g, this.n, this.t0, t1_(idx), this.times));
            end
            title(sprintf('S0 %g, a %g, b %g, e %g, g %g, n %g, t0 %g, t1 VAR', ...
                         this.S0, this.a, this.b, this.e, this.g, this.n, this.t0));
            legend(cellfun(@(x) sprintf('t1 = %g', x), num2cell(t1_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('activity/Bq');
        end  
        
 		function test_plotBolusAs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            a_ = [0.25 0.5 1 2 4] * this.a;
            for idx = 1:length(a_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV0.kAif( ...
                         a_(idx), this.b, this.t0, this.times));
            end
            title(sprintf('a VAR, b %g, t0 %g', ...
                                  this.b, this.t0));
            legend(cellfun(@(x) sprintf('a = %g', x), num2cell(a_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
 		function test_plotBolusBs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            b_ = [0.25 0.5 1 2 4] * this.b;
            for idx = 1:length(b_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV0.kAif( ...
                         this.a, b_(idx), this.t0, this.times));
            end
            title(sprintf('a %g, b VAR, t0 %g', ...
                         this.a,          this.t0));
            legend(cellfun(@(x) sprintf('b = %g', x), num2cell(b_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
 		function test_plotBolusEs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            e_ = [0.25 0.5 1 2 4] * this.e;
            for idx = 1:length(e_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV1.kAif( ...
                         this.a, this.b, e_(idx), this.g, this.t0, this.times));
            end
            title(sprintf('a %g, b %g, e VAR, g %g, t0 %g', ...
                         this.a, this.b,          this.g, this.t0));
            legend(cellfun(@(x) sprintf('e = %g', x), num2cell(e_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
 		function test_plotBolusGs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            g_ = [0.25 0.5 1 2 4] * this.g;
            for idx = 1:length(g_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV1.kAif( ...
                         this.a, this.b, this.e, g_(idx), this.t0, this.times));
            end
            title(sprintf('a %g, b %g, e %g, g VAR, t0 %g', ...
                         this.a, this.b, this.e,          this.t0));
            legend(cellfun(@(x) sprintf('g = %g', x), num2cell(g_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
 		function test_plotBolusNs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            n_ = [0.25 0.5 1 2 4] * this.n;
            for idx = 1:length(n_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV2.kAif( ...
                         this.a, this.b, this.e, this.g, n_(idx), this.t0, this.t1, this.times));
            end
            title(sprintf('a %g, b %g, e %g, g %g, n VAR, t0 %g, t1 %g', ...
                         this.a, this.b, this.e, this.g,          this.t0, this.t1));
            legend(cellfun(@(x) sprintf('n = %g', x), num2cell(n_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
 		function test_plotBolusT0s(this)
            if (~this.test_plots); return; end
            figure
            hold on            
            tspan = this.times(end) - this.times(1);
            t0_ = [ -0.5 -0.3 -0.1 -0.05 -0.02 0 0.02 0.05 0.1 0.3 0.5 ]*tspan + this.t0;
            for idx = 1:length(t0_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV0.kAif( ...
                         this.a, this.b, t0_(idx), this.times));
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
            t1_ = [ -50 -20 -10 -4 -2 0 2 4 10 20 50] + this.t1;
            for idx = 1:length(t1_)
                plot(this.times, ...
                     mlperfusion.BayesianDCV2.kAif( ...
                         this.a, this.b, this.e, this.g, this.n, this.t0, t1_(idx), this.times));
            end
            title(sprintf('a %g, b %g, e %g, g %g, n %g, t0 %g, t1 VAR', ...
                         this.a, this.b, this.e, this.g, this.n, this.t0));
            legend(cellfun(@(x) sprintf('t1 = %g', x), num2cell(t1_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
        
        %% MCMC TESTS
        
        function test_simulateMcmc0(this)
            %% TEST_SIMULATEMCMC0 constructs for mlperfusion.BayesianDCV0 a parameter map, the corresponding test-case wellCounts, 
            %  then runs BayesianDCV0's MCMC to fit the test-case wellCounts.  This is a test of BayesianDCV0's ability to fit 
            %  a synthetic wellCounts created directly from it's own wellCounts model.   
            
            if (~this.test_mcmc); return; end
            import mlperfusion.*;
            aMap = containers.Map;
            fL = 0.5; fH = 1.5;
            aMap('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            aMap('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            aMap('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            aMap('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0);            
            this.testMagn = BayesianDCV0.wellCounts(this.S0, this.a, this.b, this.t0, this.times); 
            assert(~any(isnan(    this.testMagn)));
            assert(~any(~isfinite(this.testMagn)));
            
            o = BayesianDCV0.simulateMcmc(this.S0, this.a, this.b, this.t0, this.times, this.testMagn, aMap);
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.05);
        end
        function test_simulateMcmc1(this)
            %% TEST_SIMULATEMCMC1 constructs for mlperfusion.BayesianDCV1 a parameter map, the corresponding test-case wellCounts, 
            %  then runs BayesianDCV1's MCMC to fit the test-case wellCounts.  This is a test of BayesianDCV1's ability to fit 
            %  a synthetic wellCounts created directly from it's own wellCounts model.   
            
            if (~this.test_mcmc); return; end
            import mlperfusion.*;
            aMap = containers.Map;
            fL = 0.85; fH = 1.15;
            aMap('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            aMap('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            aMap('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            aMap('e')  = struct('fixed', 0, 'min', fL*this.e,  'mean', this.e,  'max', fH*this.e);
            aMap('g')  = struct('fixed', 0, 'min', fL*this.g,  'mean', this.g,  'max', fH*this.g);
            aMap('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0);            
            this.testMagn = BayesianDCV1.wellCounts(this.S0, this.a, this.b, this.e, this.g, this.t0, this.times); 
            assert(~any(isnan(    this.testMagn)));
            assert(~any(~isfinite(this.testMagn)));
            
            o = BayesianDCV1.simulateMcmc(this.S0, this.a, this.b, this.e, this.g, this.t0, this.times, this.testMagn, aMap);
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.05);
        end
        function test_simulateMcmc2(this)
            %% TEST_SIMULATEMCMC2 constructs for mlperfusion.BayesianDCV2 a parameter map, the corresponding test-case wellCounts, 
            %  then runs BayesianDCV2's MCMC to fit the test-case wellCounts.  This is a test of BayesianDCV2's ability to fit 
            %  a synthetic wellCounts created directly from it's own wellCounts model.   
            
            if (~this.test_mcmc); return; end
            import mlperfusion.*;
            aMap = containers.Map; 
            fL = 0.85; fH = 1.15;  
            aMap('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            aMap('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            aMap('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            aMap('e')  = struct('fixed', 0, 'min', fL*this.e,  'mean', this.e,  'max', fH*this.e);
            aMap('g')  = struct('fixed', 0, 'min', fL*this.g,  'mean', this.g,  'max', fH*this.g);
            aMap('n')  = struct('fixed', 0, 'min', fL*this.n,  'mean', this.n,  'max', fH*this.n); 
            aMap('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0); 
            aMap('t1') = struct('fixed', 0, 'min', fL*this.t1, 'mean', this.t1, 'max', fH*this.t1);            
            this.testMagn = BayesianDCV2.wellCounts(this.S0, this.a, this.b, this.e, this.g, this.n, this.t0, this.times, this.t1); 
            assert(~any(isnan(    this.testMagn)));
            assert(~any(~isfinite(this.testMagn)));
            
            o = BayesianDCV2.simulateMcmc(this.S0, this.a, this.b, this.e, this.g, this.n, this.t0, this.t1, this.times, this.testMagn, aMap);
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.05);
        end
        
        function test_BayesianDCV0(this)
            %% TEST_PLAIF0 invokes BayesianDCV0.runBayesianDCV on experimental data from this.dscFilenme; best-fit parameters
            %  must match expected values to relative tolerance of 0.1.
            
            if (~this.test_mcmc); return; end
            this.testObj = mlperfusion.BayesianDCV0.runBayesianDCV(this.dcv.times, this.dcv.wellCounts');
            o = this.testObj;
            
            figure;
            plot(o.independentData, o.estimateData, this.dcv.times, this.dcv.wellCounts, 'o');
            legend('Bayesian estimate', this.dcv.fileprefix);
            title(sprintf('BayesianDCV0:  S0 %g, alpha %g, beta %g, t0 %g', ...
                  o.S0, o.a, o.b, o.t0));
            xlabel('time/s');
            ylabel('activity/Bq');
            
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.1);
        end
        function test_BayesianDCV1(this)
            %% TEST_LAIF2 invokes BayesianDCV1.runBayesianDCV on experimental data from this.dscFilenme; best-fit parameters
            %  must match expected values to relative tolerance of 0.1.
            
            if (~this.test_mcmc); return; end
            this.testObj = mlperfusion.BayesianDCV1.runBayesianDCV(this.dcv.times, this.dcv.wellCounts);
            o = this.testObj;
            
            figure;
            plot(o.independentData, o.estimateData, this.dcv.times, this.dcv.wellCounts, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('BayesianDCV1:  S0 %g, alpha %g, beta %g, eps %g, gamma %g, t0 %g', ...
                  o.S0, o.a, o.b, o.e, o.g, o.t0));
            xlabel('time/s');
            ylabel('activity/Bq');
            
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.1);
        end
        function test_BayesianDCV2(this)
            %% TEST_LAIF2 invokes BayesianDCV2.runBayesianDCV on experimental data from this.dscFilenme; best-fit parameters
            %  must match expected values to relative tolerance of 0.1.
            
            if (~this.test_mcmc); return; end
            this.testObj = mlperfusion.BayesianDCV2.runBayesianDCV(this.dcv.times, this.dcv.wellCounts);
            o = this.testObj;
            
            figure;
            plot(o.independentData, o.estimateData, this.dcv.times, this.dcv.wellCounts, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('BayesianDCV1:  S0 %g, alpha %g, beta %g, eps %g, gamma %g, nu %g, t0 %g, t1 %g', ...
                  o.S0, o.a, o.b, o.e, o.g, o.n, o.t0, o.t1));
            xlabel('time/s');
            ylabel('activity/Bq');
            
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.05);
        end
 	end 

 	methods (TestClassSetup) 
 	end 

 	methods (TestClassTeardown) 
    end 
    
 	methods 
 		function this = Test_BayesianDCVx
            this = this@matlab.unittest.TestCase;
            this = this.buildDcv;
            switch (this.model)
                case 0
                    this.testObj = mlperfusion.BayesianDCV0;
                case 1
                    this.testObj = mlperfusion.BayesianDCV1;
                case 2
                    this.testObj = mlperfusion.BayesianDCV2;
                otherwise
                    error('mlperfusion_unittest:unsupportedSwitchCase', 'ctor.model->%s', this.model);
            end
 		end 
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
        dcv
    end
    
    methods (Access = 'private')
        function this = buildDcv(this)
            this.dcv = mlpet.DCV.load(this.dcvFilename);
            
            figure;
            plot(this.dcv.times, this.dcv.wellCounts);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

