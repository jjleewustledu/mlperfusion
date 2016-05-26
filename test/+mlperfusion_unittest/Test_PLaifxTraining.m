classdef Test_PLaifxTraining < matlab.unittest.TestCase 
	%% TEST_PLAIFXTRAINING  

	%  Usage:  >> results = run(mlperfusion_unittest.Test_PLaifxTraining)
 	%          >> result  = run(mlperfusion_unittest.Test_PLaifxTraining, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 

	properties       
        testFolder   = fullfile(getenv('UNITTESTS'), 'cvl/np755_Bayesian/mm01-007_p7267_2008jun16/bayesian_pet')
        ecatFilename = fullfile(getenv('UNITTESTS'), 'cvl/np755_Bayesian/mm01-007_p7267_2008jun16/bayesian_pet/p7267ho1.nii.gz')
        maskFilename = fullfile(getenv('UNITTESTS'), 'cvl/np755_Bayesian/mm01-007_p7267_2008jun16/bayesian_pet/aparc_a2009s+aseg_mask_on_p7267ho1_sumt.nii.gz')
        dcvFilename  = fullfile(getenv('UNITTESTS'), 'cvl/np755_Bayesian/mm01-007_p7267_2008jun16/bayesian_pet/p7267ho1.dcv')
        test_plots   = true
        test_mcmc    = true
 	end 

    properties (Dependent)       
        F  
        PS
        S0
        a 
        b  
        e  
        g 
        n  
        p
        t0 
        t1
        u0
        u1
        times
    end
    
    methods %% GET/SET
        function x = get.F(this)
            x = this.testObj.F;
        end
        function x = get.PS(this)
            x = this.testObj.PS;
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
        function x = get.e(this)
            x = this.testObj.e;
        end
        function x = get.g(this)
            x = this.testObj.g;
        end
        function x = get.n(this)
            x = this.testObj.n;
        end
        function x = get.p(this)
            x = this.testObj.p;
        end
        function x = get.t0(this)
            x = this.testObj.t0;
        end
        function x = get.u0(this)
            x = this.testObj.u0;
        end
        function x = get.t1(this)
            x = this.testObj.t1;
        end
        function x = get.u1(this)
            x = this.testObj.u1;
        end
        function t = get.times(this)
            t = this.testObj.times;
        end
    end
    
	methods (Test)
        
        %% TESTS WITH PLOTTING
        
 		function test_plotFs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            F_ = [0.6 0.8 1 1.2 1.4] * this.F;
            for idx = 1:length(F_)
                plot(this.times, ...
                     mlperfusion.PLaif0.tscCounts( ...
                         F_(idx), this.PS, this.S0, this.a, this.b, this.t0, this.times));
            end
            title(sprintf('F VAR, PS %g, S0 %g, a %g, b %g, t0 %g', ...
                                  this.PS, this.S0, this.a, this.b, this.t0));
            legend(cellfun(@(x) sprintf('F = %g', x), num2cell(F_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('activity/Bq');
        end 
 		function test_plotPSs(this)
            if (~this.test_plots); return; end
            figure
            hold on
            PS_ = [0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8] * this.PS;
            for idx = 1:length(PS_)
                plot(this.times, ...
                     mlperfusion.PLaif0.tscCounts( ...
                         this.F, PS_(idx), this.S0, this.a, this.b, this.t0, this.times));
            end
            title(sprintf('F %g, PS VAR, S0 %g, a %g, b %g, t0 %g', ...
                         this.F,           this.S0, this.a, this.b, this.t0));
            legend(cellfun(@(x) sprintf('PS = %g', x), num2cell(PS_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('activity/Bq');
        end 
 		function test_plotS0s(this)
            if (~this.test_plots); return; end
            figure
            hold on
            S0_ = [0.25 0.5 1 2 4] * this.S0;
            for idx = 1:length(S0_)
                plot(this.times, ...
                     mlperfusion.PLaif0.tscCounts( ...
                         this.F, this.PS, S0_(idx), this.a, this.b, this.t0, this.times));
            end
            title(sprintf('F %g, PS %g, S0 VAR, a %g, b %g, t0 %g', ...
                         this.F, this.PS,           this.a, this.b, this.t0));
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
                     mlperfusion.PLaif0.tscCounts( ...
                         this.F, this.PS, this.S0, a_(idx), this.b, this.t0, this.times));
            end
            title(sprintf('F %g, PS %g, S0 %g, a VAR, b %g, t0 %g', ...
                         this.F, this.PS, this.S0,          this.b, this.t0));
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
                     mlperfusion.PLaif0.tscCounts( ...
                         this.F, this.PS, this.S0, this.a, b_(idx), this.t0, this.times));
            end
            title(sprintf('F %g, PS %g, S0 %g, a %g, b VAR, t0 %g', ...
                         this.F, this.PS, this.S0, this.a,          this.t0));
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
                     mlperfusion.PLaif1.tscCounts( ...
                         this.F, this.PS, this.S0, this.a, this.b, e_(idx), this.g, this.t0, this.times));
            end
            title(sprintf('F %g, PS %g, S0 %g, a %g, b %g, e VAR, g %g, t0 %g', ...
                         this.F, this.PS< this.S0, this.a, this.b,          this.g, this.t0));
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
                     mlperfusion.PLaif1.tscCounts( ...
                         this.F, this.PS, this.S0, this.a, this.b,  this.e, g_(idx), this.t0, this.times));
            end
            title(sprintf('F %g, PS %g, S0 %g, a %g, b %g, e %g, g VAR, t0 %g', ...
                         this.F, this.PS, this.S0, this.a, this.b,  this.e,          this.t0));
            legend(cellfun(@(x) sprintf('g = %g', x), num2cell(g_), 'UniformOutput', false));
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
                     mlperfusion.PLaif0.tscCounts( ...
                         this.F, this.PS, this.S0, this.a, this.b, t0_(idx), this.times));
            end
            title(sprintf('F %g, PS %g, S0 %g, a %g, b %g, t0 VAR', ...
                         this.F, this.PS, this.S0, this.a, this.b));
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
                     mlperfusion.PLaif2.tscCounts( ...
                         this.F, this.PS, this.S0, this.a, this.b, this.e, this.g, this.n, this.t0, t1_(idx), this.times));
            end
            title(sprintf('F %g, PS %g, S0 %g, a %g, b %g, e %g, g %g, n %g, t0 %g, t1 VAR', ...
                         this.F, this.PS, this.S0, this.a, this.b, this.e, this.g, this.n, this.t0));
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
                     mlperfusion.PLaif0.kAif( ...
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
                     mlperfusion.PLaif0.kAif( ...
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
                     mlperfusion.PLaif1.kAif( ...
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
                     mlperfusion.PLaif1.kAif( ...
                         this.a, this.b, this.e, g_(idx), this.t0, this.times));
            end
            title(sprintf('a %g, b %g, e %g, g VAR, t0 %g', ...
                         this.a, this.b, this.e,          this.t0));
            legend(cellfun(@(x) sprintf('g = %g', x), num2cell(g_), 'UniformOutput', false));
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
                     mlperfusion.PLaif0.kAif( ...
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
                     mlperfusion.PLaif2.kAif( ...
                         this.a, this.b, this.e, this.g, this.n, this.t0, t1_(idx), this.times));
            end
            title(sprintf('a %g, b %g, e %g, g %g, n %g, t0 %g, t1 VAR', ...
                         this.a, this.b, this.e, this.g, this.n, this.t0));
            legend(cellfun(@(x) sprintf('t1 = %g', x), num2cell(t1_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('kConcentration_{AIF}/arbitrary');
        end 
        
        %% MCMC TESTS
        
        function test_simulateMcmc1(this)
            %% TEST_SIMULATEMCMC1 constructs for mlperfusion.PLaif1 a parameter map, the corresponding test-case tscCounts, 
            %  then runs PLaif1's MCMC to fit the test-case tscCounts.  This is a test of PLaif1's ability to fit 
            %  a synthetic tscCounts created directly from it's own tscCounts model.   
            
            if (~this.test_mcmc); return; end
            pmap = containers.Map;
            fL = 0.85; fH = 1.15;
            pmap('F')  = struct('fixed', 0, 'min', fL*this.F,  'mean', this.F,  'max', fH*this.F);
            pmap('PS') = struct('fixed', 0, 'min', fL*this.PS, 'mean', this.PS, 'max', fH*this.PS);
            pmap('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            pmap('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            pmap('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            pmap('e')  = struct('fixed', 0, 'min', fL*this.e,  'mean', this.e,  'max', fH*this.e);
            pmap('g')  = struct('fixed', 0, 'min', fL*this.g,  'mean', this.g,  'max', fH*this.g);
            pmap('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0); 
            pmap('u0') = struct('fixed', 0, 'min', fL*this.u0, 'mean', this.u0, 'max', fH*this.u0);            
            
            import mlperfusion.*;
            o = PLaif1Training.simulateMcmc( ...
                this.F, this.PS, this.S0, this.a, this.b, this.e, this.g, this.t0, this.u0, this.times{1}, this.times{2}, pmap);
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.05);
        end
        
        function test_PLaif1Training(this)
            %% TEST_PLAIF1TRAINING invokes PLaif1Training on experimental data; best-fit parameters
            %  must match expected values to relative tolerance of 0.1.
            
            if (~this.test_mcmc); return; end
            o = mlperfusion.PLaif1Training.load(this.ecatFilename, this.maskFilename, this.dcvFilename);
            o = o.estimateParameters;
            o.plot;
            this.verifyEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.1);
        end
        function test_plot(this)
            o = mlperfusion.PLaif1Training.load(this.ecatFilename, this.maskFilename, this.dcvFilename);
            o.plot;
            %this.verifyEqual(o.bestFitParams, o.expectedBestFitParams);
        end
        
        function test_PLaiffTraining(this)
            %% TEST_PLAIFFTRAINING invokes PLaiffTraining on experimental data; best-fit parameters
            %  must match expected values to relative tolerance of 0.1.
            
            if (~this.test_mcmc); return; end            
            o = mlperfusion.PLaiffTraining.load(this.ecatFilename, this.maskFilename, this.dcvFilename);
            o = o.estimateParameters;
            o.plot;
            this.assertEqual(o.bestFitParams, o.expectedBestFitParams, 'RelTol', 0.1);
        end
 	end 

 	methods (TestClassSetup) 
        function this = pLaifxTrainingSetup(this)
        end
 	end 

 	methods (TestClassTeardown) 
    end 
    
 	methods 
 		function this = Test_PLaifxTraining
            this = this@matlab.unittest.TestCase;
 		end 
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

