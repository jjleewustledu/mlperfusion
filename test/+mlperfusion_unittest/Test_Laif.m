classdef Test_Laif < matlab.unittest.TestCase 
	%% TEST_LAIF  

	%  Usage:  >> results = run(mlperfusion_unittest.Test_Laif)
 	%          >> result  = run(mlperfusion_unittest.Test_Laif, 'test_dt')
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
        F  = 1.885
        S0 = 589.488
        e  = 0.8
        a  = 6.031
        b  = 1.866
        d  = 0.725
        g  = 0.1
        t0 = 8.152
        t1 = 2*8.152
        n  = 0.2
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
            e = [this.F this.S0 this.a this.b this.d this.e this.t0 this.t1]';
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
            this.testMagn = Laif.magnetization0(this.S0, this.F, this.a, this.b, this.d, this.times, this.t0); 
            this.testObj  = Laif.simulateMcmc0( this.S0, this.F, this.a, this.b, this.d, this.times, this.t0, this.testMagn, map);
            this.assertEqual(this.testObj.bestFitParams, this.expectedBestFitParams0, 'RelTol', 0.05);
        end
        function test_simulateMcmc1(this)
            import mlperfusion.*;
            map = containers.Map;
            fL = 0.8; fH = 1.2;
            map('F')  = struct('fixed', 0, 'min', fL*this.F,  'mean', this.F,  'max', fH*this.F);
            map('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            map('e')  = struct('fixed', 0, 'min', fL*this.e,  'mean', this.e,  'max', fH*this.e);
            map('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            map('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            map('d')  = struct('fixed', 0, 'min', fL*this.d,  'mean', this.d,  'max', fH*this.d);
            map('g')  = struct('fixed', 0, 'min', fL*this.g,  'mean', this.g,  'max', fH*this.g);
            map('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0); 
            this.testMagn = Laif.magnetization1(this.S0, this.F, this.e, this.a, this.b, this.d, this.g, this.times, this.t0); 
            this.testObj  = Laif.simulateMcmc1( this.S0, this.F, this.e, this.a, this.b, this.d, this.g, this.times, this.t0, this.testMagn, map);
            this.assertEqual(this.testObj.bestFitParams, this.expectedBestFitParams1, 'RelTol', 0.05);
        end
        function test_simulateMcmc2(this)
            import mlperfusion.*;
            map = containers.Map; 
            fL = 0.8; fH = 1.2;           
            map('F')  = struct('fixed', 0, 'min', fL*this.F,  'mean', this.F,  'max', fH*this.F);
            map('S0') = struct('fixed', 0, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            map('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            map('b')  = struct('fixed', 0, 'min', fL*this.d,  'mean', this.b,  'max', fH*this.b);
            map('d')  = struct('fixed', 0, 'min', fL*this.d,  'mean', this.d,  'max', fH*this.b);
            map('t0') = struct('fixed', 0, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0); 
            map('t1') = struct('fixed', 0, 'min', fL*this.t1, 'mean', this.t1, 'max', fH*this.t1); 
            this.testMagn = Laif.magnetization2(this.S0, this.F, this.a, this.b, this.d, this.e, this.times, this.t0, this.t1); 
            this.testObj  = Laif.simulateMcmc2( this.S0, this.F, this.a, this.b, this.d, this.e, this.times, this.t0, this.t1, this.testMagn, map);
            this.assertEqual(this.testObj.bestFitParams, this.expectedBestFitParams2, 'RelTol', 0.05);
        end
 	end 

 	methods (TestClassSetup) 
 	end 

 	methods (TestClassTeardown) 
    end 
    
 	methods 
 		function this = Test_Laif
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

