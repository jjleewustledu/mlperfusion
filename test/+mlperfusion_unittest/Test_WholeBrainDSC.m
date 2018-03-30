classdef Test_WholeBrainDSC < matlab.unittest.TestCase 
	%% TEST_WHOLEBRAINDSC  

	%  Usage:  >> results = run(mlperfusion_unittest.Test_WholeBrainDSC)
 	%          >> result  = run(mlperfusion_unittest.Test_WholeBrainDSC, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 

	properties 
        testObj
        unittest_home = fullfile(getenv('UNITTESTS'), 'cvl/np755/mm01-007_p7267_2008jun16/perfusion_4dfp', '')
        dsc
        mask
        timeInts = 0:1:119
 	end 

	methods (Test) 
        function test_ctor(this)
            this.assertEqual(this.testObj.fqfilename, fullfile(this.unittest_home, 'ep2d_default_mcf.nii.gz'));
            this.assertEqual(this.testObj.length, 120);
            this.assertEqual(this.testObj.scanDuration, 178.5);
        end
        function test_times(this)
            this.assertEqual(this.testObj.times(4),     4.5);
            this.assertEqual(this.testObj.times(119), 177);
            this.assertEqual(this.testObj.times(120), 178.5);
        end
        function test_timeInterpolants(this)
            this.assertEqual(this.testObj.timeInterpolants(120), 119);
        end
        function test_conc(this)
            this.assertEqual(double(this.testObj.conc(4)),  0.003996235087416, 'RelTol', 1e-5);
            this.assertEqual(double(this.testObj.conc(19)), 0.464113571787175, 'RelTol', 1e-5);
            this.assertEqual(double(this.testObj.conc(20)), 0.315481932337763, 'RelTol', 1e-5);
        end
        function test_concInterpolants(this)
            this.assertEqual(double(this.testObj.concInterpolants(120)), 0.069716504046929, 'RelTol', 1e-5);
        end
        function test_header(this)
            this.assertEqual(this.testObj.header.descrip(1:end-21), ...
                'NIfTI.load read /Volumes/InnominateHD2/Local/test/np755/mm01-007_p7267_2008jun16/perfusion_4dfp/ep2d_default_mcf.nii.gz on');
            this.assertEqual(this.testObj.header.pixdim, [1.71875 1.71875 6.5 1.5]);    
            this.assertEqual(this.testObj.header.datatype, 16);
            this.assertEqual(this.testObj.header.entropy, 0.0746969465676674, 'RelTol', 1e-10);
            this.assertEqual(this.testObj.header.fileprefix, 'ep2d_default_mcf');
            this.assertEqual(this.testObj.header.fqfilename, fullfile(this.unittest_home, 'ep2d_default_mcf.nii.gz'));
            this.assertEqual(this.testObj.header.size, [128 128 13 120]);
        end
        function test_magnetization(this)
            figure
            plot(this.testObj.times, this.testObj.itsMagnetization);
            title('\int_{V_{mask}} dx^3 mask(x) M(x,t_{native}) / V_{mask}');
        end
        function test_kConcentration(this)
            figure
            plot(this.testObj.times, this.testObj.itsKConcentration);
            title('k C(t_{native})');
        end
 	end 

 	methods (TestClassSetup) 
 		function setupWholeBrainDSC(this)             
            cd(this.unittest_home);
            this.testObj = mlperfusion.WholeBrainDSC( ...
                fullfile(this.unittest_home, 'ep2d_default_mcf.nii.gz'), ...
                fullfile(this.unittest_home, 'perfMask.nii.gz'), ...
                this.timeInts);
 		end 
 	end 

 	methods (TestClassTeardown) 
    end 
    
    methods 
        function this = Test_WholeBrainDSC            
            import mlfourd.*;
            this.dsc  = NIfTI.load(fullfile(this.unittest_home, 'ep2d_default_mcf.nii.gz'));
            this.mask = NIfTI.load(fullfile(this.unittest_home, 'perfMask.nii.gz')); 
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 

