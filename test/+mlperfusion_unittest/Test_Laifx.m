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
        F  = 2.239176
        S0 = 555.281677
        a  = 5.886588
        b  = 1.335361
        d  = 0.489088
        e  = 0.984358
        g  = 0.116832
        n  = 0.1
        t0 = 16.50000
        t1 = 33
        
        testFolder   = '/Users/jjlee/Local/src/mlcvl/mlperfusion/test/+mlperfusion_unittest'
        dscFilename  = '/Volumes/InnominateHD2/Local/test/np755/mm01-007_p7267_2008jun16/perfusion_4dfp/ep2d_default_mcf.nii.gz'
        maskFilename = '/Volumes/InnominateHD2/Local/test/np755/mm01-007_p7267_2008jun16/perfusion_4dfp/perfMask.nii.gz'
 	end 

    properties (Dependent)
        expectedBestFitParams0
        expectedBestFitParams1
        expectedBestFitParams2
        times
    end
    
    methods %% GET/SET
        function e = get.expectedBestFitParams0(this)
            e = [this.F this.S0 this.a this.b this.d this.t0]';
        end
        function e = get.expectedBestFitParams1(this)
            e = [this.F this.S0 this.a this.b this.d this.e this.g this.t0]';
        end
        function e = get.expectedBestFitParams2(this)
            e = [this.F this.S0 this.a this.b this.d this.e this.g this.n this.t0 this.t1]';
        end
        function t = get.times(this)
            t = this.wbDsc.times;
        end
    end
    
	methods (Test) 
 		function test_plotFs(this)
            figure
            hold on
            F_ = [0.25 0.5 1 2 3 4];
            for idx = 1:length(F_)
                plot(this.times, ...
                     mlperfusion.Laif.magnetization0( ...
                         this.S0, F_(idx), this.a, this.b, this.d, this.times, this.t0));
            end
            title(sprintf('S0 %g, F VAR, a %g, b %g, d %g, t0 %g', ...
                         this.S0,          this.a, this.b, this.d, this.t0));
            legend(cellfun(@(x) sprintf('F = %g', x), num2cell(F_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetizatin/arbitrary');
        end 
 		function test_plotS0s(this)
            figure
            hold on
            S0_ = [400 500 600 700];
            for idx = 1:length(S0_)
                plot(this.times, ...
                     mlperfusion.Laif.magnetization0( ...
                         S0_(idx), this.F, this.a, this.b, this.d, this.times, this.t0));
            end
            title(sprintf('S0 VAR, F %g, a %g, b %g, d %g, t0 %g', ...
                                   this.F, this.a, this.b, this.d, this.t0));
            legend(cellfun(@(x) sprintf('S0 = %g', x), num2cell(S0_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetizatin/arbitrary');
        end 
 		function test_plotAs(this)
            figure
            hold on
            a_ = [1 2 4 8 16 32];
            for idx = 1:length(a_)
                plot(this.times, ...
                     mlperfusion.Laif.magnetization0( ...
                         this.S0, this.F, a_(idx), this.b, this.d, this.times, this.t0));
            end
            title(sprintf('S0 %g, F %g, a VAR, b %g, d %g, t0 %g', ...
                         this.S0, this.F,          this.b, this.d, this.t0));
            legend(cellfun(@(x) sprintf('a = %g', x), num2cell(a_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetizatin/arbitrary');
        end 
 		function test_plotBs(this)
            figure
            hold on
            b_ = [0.125 0.25 0.5 1 2 4 8];
            for idx = 1:length(b_)
                plot(this.times, ...
                     mlperfusion.Laif.magnetization0( ...
                         this.S0, this.F, this.a, b_(idx), this.d, this.times, this.t0));
            end
            title(sprintf('S0 %g, F %g, a %g, b VAR, d %g, t0 %g', ...
                         this.S0, this.F, this.a,          this.d, this.t0));
            legend(cellfun(@(x) sprintf('b = %g', x), num2cell(b_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetizatin/arbitrary');
        end 
 		function test_plotDs(this)
            figure
            hold on
            d_ = [0.125 0.25 0.5 1 2 4 8];
            for idx = 1:length(d_)
                plot(this.times, ...
                     mlperfusion.Laif.magnetization0( ...
                         this.S0, this.F, this.a, this.b, d_(idx), this.times, this.t0));
            end
            title(sprintf('S0 %g, F %g, a %g, b %g, d VAR, t0 %g', ...
                         this.S0, this.F, this.a, this.b,          this.t0));
            legend(cellfun(@(x) sprintf('d = %g', x), num2cell(d_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetizatin/arbitrary');
        end 
 		function test_plotT0s(this)
            figure
            hold on
            t0_ = [1 2 4 8 16 32 64];
            for idx = 1:length(t0_)
                plot(this.times, ...
                     mlperfusion.Laif.magnetization0( ...
                         this.S0, this.F, this.a, this.b, this.d, this.times, t0_(idx)));
            end
            title(sprintf('S0 %g, F %g, a %g, b %g, d %g, t0 VAR', ...
                         this.S0, this.F, this.a, this.b, this.d));
            legend(cellfun(@(x) sprintf('t0 = %g', x), num2cell(t0_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end 
 		function test_plotEs(this)
            figure
            hold on
            e_ = [0.5 0.6 0.7 0.8 0.9 0.95 0.98];
            for idx = 1:length(e_)
                plot(this.times, ...
                     mlperfusion.Laif.magnetization1( ...
                         this.S0, this.F, e_(idx), this.a, this.b, this.d, this.g, this.times, this.t0));
            end
            title(sprintf('S0 %g, F %g, e VAR, a %g, b %g, d %g, g %g, t0 %g', ...
                         this.S0, this.F,          this.a, this.b, this.d, this.g, this.t0));
            legend(cellfun(@(x) sprintf('e = %g', x), num2cell(e_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end 
 		function test_plotGs(this)
            figure
            hold on
            g_ = [0.0125 0.05 0.125 0.25 0.5 1];
            for idx = 1:length(g_)
                plot(this.times, ...
                     mlperfusion.Laif.magnetization1( ...
                         this.S0, this.F, this.e, this.a, this.b, this.d, g_(idx), this.times, this.t0));
            end
            title(sprintf('S0 %g, F %g, e %g, a %g, b %g, d %g, g VAR, t0 %g', ...
                         this.S0, this.F, this.e, this.a, this.b, this.d,           this.t0));
            legend(cellfun(@(x) sprintf('g = %g', x), num2cell(g_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end 
 		function test_plotT1s(this)
            figure
            hold on
            t1_ = [4 8 12 16 24 32 64];
            for idx = 1:length(t1_)
                plot(this.times, ...
                     mlperfusion.Laif.magnetization2( ...
                         this.S0, this.F, this.e, this.a, this.b, this.d, this.g, this.times, this.t0, t1_(idx), this.n));
            end
            title(sprintf('S0 %g, F %g, e %g, a %g, b %g, d %g, g %g, t0 %g, t1 VAR, n %g', ...
                         this.S0, this.F, this.e, this.a, this.b, this.d, this.g,             this.t0,           this.n));
            legend(cellfun(@(x) sprintf('t1 = %g', x), num2cell(t1_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end 
 		function test_plotNs(this)
            figure
            hold on
            n_ = [0.01 0.05 0.1 0.2 0.4 0.8 1];
            for idx = 1:length(n_)
                plot(this.times, ...
                     mlperfusion.Laif.magnetization2( ...
                         this.S0, this.F, this.e, this.a, this.b, this.d, this.g, this.times, this.t0, this.t1, n_(idx)));
            end
            title(sprintf('S0 %g, F %g, e %g, a %g, b %g, d %g, g %g, t0 %g, t1 %g, n VAR', ...
                         this.S0, this.F, this.e, this.a, this.b, this.d, this.g,             this.t0, this.t1));
            legend(cellfun(@(x) sprintf('n = %g', x), num2cell(n_), 'UniformOutput', false));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end 
        
        function test_simulateMcmc0(this)
            import mlperfusion.*;
            map = containers.Map;
            fL = 0.8; fH = 1.2;
            map('F')  = struct('fixed', 0, 'min', fL*this.F,  'mean', this.F,  'max', fH*this.F);
            map('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            map('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            map('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            map('d')  = struct('fixed', 0, 'min', fL*this.d,  'mean', this.d,  'max', fH*this.d);
            map('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0); 
            this.testMagn = Laif0.magnetization(this.F, this.S0, this.a, this.b, this.d, this.times, this.t0); 
            assert(~any(isnan(    this.testMagn)));
            assert(~any(~isfinite(this.testMagn)));
            this.testObj  = Laif0.simulateMcmc( this.F, this.S0, this.a, this.b, this.d, this.times, this.t0, this.testMagn, map);
            this.assertEqual(this.testObj.bestFitParams, this.expectedBestFitParams0, 'RelTol', 0.05);
        end
        function test_simulateMcmc1(this)
            import mlperfusion.*;
            map = containers.Map;
            fL = 0.8; fH = 1.2;
            map('F')  = struct('fixed', 0, 'min', fL*this.F,  'mean', this.F,  'max', fH*this.F);
            map('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            map('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            map('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            map('d')  = struct('fixed', 0, 'min', fL*this.d,  'mean', this.d,  'max', fH*this.d);
            map('e')  = struct('fixed', 0, 'min', fL*this.e,  'mean', this.e,  'max', fH*this.e);
            map('g')  = struct('fixed', 0, 'min', fL*this.g,  'mean', this.g,  'max', fH*this.g);
            map('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0); 
            this.testMagn = Laif1.magnetization(this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.times, this.t0); 
            assert(~any(isnan(    this.testMagn)));
            assert(~any(~isfinite(this.testMagn)));
            this.testObj  = Laif1.simulateMcmc( this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.times, this.t0, this.testMagn, map);
            this.assertEqual(this.testObj.bestFitParams, this.expectedBestFitParams1, 'RelTol', 0.05);
        end
        function test_simulateMcmc2(this)
            import mlperfusion.*;
            map = containers.Map; 
            fL = 0.8; fH = 1.2;           
            map('F')  = struct('fixed', 0, 'min', fL*this.F,  'mean', this.F,  'max', fH*this.F);
            map('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            map('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            map('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            map('d')  = struct('fixed', 0, 'min', fL*this.d,  'mean', this.d,  'max', fH*this.d);
            map('e')  = struct('fixed', 0, 'min', fL*this.e,  'mean', this.e,  'max', fH*this.e);
            map('g')  = struct('fixed', 0, 'min', fL*this.g,  'mean', this.g,  'max', fH*this.g);
            map('n')  = struct('fixed', 0, 'min', fL*this.n,  'mean', this.n,  'max', fH*this.n); 
            map('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0); 
            map('t1') = struct('fixed', 0, 'min', fL*this.t1, 'mean', this.t1, 'max', fH*this.t1); 
            this.testMagn = Laif2.magnetization(this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.n, this.times, this.t0, this.t1); 
            assert(~any(isnan(    this.testMagn)));
            assert(~any(~isfinite(this.testMagn)));
            this.testObj  = Laif2.simulateMcmc( this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.n, this.times, this.t0, this.t1, this.testMagn, map);
            this.assertEqual(this.testObj.bestFitParams, this.expectedBestFitParams2, 'RelTol', 0.05);
        end
        
        function test_Laif0(this)
            this.testObj = mlperfusion.Laif0.run(this.wbDsc.times, this.wbDsc.magnetization);
            o = this.testObj;
            
            figure;
            plot(o.independentData, o.estimateData, this.wbDsc.times, this.wbDsc.magnetization, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('Laif0:  F %g,bS0 %g, alpha %g, beta %g, delta %g, t0 %g', ...
                  o.F, o.S0, o.a, o.b, o.d, o.t0));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end
        function test_Laif1(this)
            this.testObj = mlperfusion.Laif1.run(this.wbDsc.times, this.wbDsc.magnetization);
            o = this.testObj;
            
            figure;
            plot(o.independentData, o.estimateData, this.wbDsc.times, this.wbDsc.magnetization, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('Laif1:  F %g, S0 %g, alpha %g, beta %g, delta %g, eps %g, gamma %g, t0 %g', ...
                  o.F, o.S0, o.a, o.b, o.d, o.e, o.g, o.t0));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end
        function test_Laif2(this)
            this.testObj = mlperfusion.Laif2.run(this.wbDsc.times, this.wbDsc.magnetization);
            o = this.testObj;
            
            figure;
            plot(o.independentData, o.estimateData, this.wbDsc.times, this.wbDsc.magnetization, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('Laif1:  F %g, S0 %g, alpha %g, beta %g, delta %g, eps %g, gamma %g, nu %g, t0 %g, t1 %g', ...
                  o.F, o.S0, o.a, o.b, o.d, o.e, o.g, o.n, o.t0, o.t1));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
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

