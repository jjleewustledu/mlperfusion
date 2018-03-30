classdef Test_HO15Data < matlab.unittest.TestCase
	%% TEST_HO15DATA 

	%  Usage:  >> results = run(mlperfusion_unittest.Test_HO15Data)
 	%          >> result  = run(mlperfusion_unittest.Test_HO15Data, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 12-Jan-2016 23:32:16
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/test/+mlperfusion_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		registry
 		testObj
    end
    
    properties (Dependent)
        moyamoyaSessionPath
        glutSessionPath
        ppgSessionPath
    end
    
    methods %% GET
        function g = get.moyamoyaSessionPath(this)
            g = fullfile(getenv('MLUNIT_TEST_PATH'), 'cvl', 'np755', 'mm01-020_p7377_2009feb5', '');
        end
        function g = get.glutSessionPath(this)
            g = fullfile(getenv('MLUNIT_TEST_PATH'), 'Arbelaez', 'GluT', 'p7991_JJL', '');
        end
        function g = get.ppgSessionPath(this)
            g = fullfile(getenv('MLUNIT_TEST_PATH'), 'raichle', 'PPGdata', 'idaif', 'p8089', '');
        end
    end

	methods (Test)
		function test_ho15DataMoyamoya(this)
 			import mlperfusion.*;
            obj = HO15Data( ...
                      mlderdeyn.MoyamoyaStudy(this.moyamoyaSessionPath));
            
 			this.verifyEqual(obj.dcvFqfilename, '');
 			this.verifyInstanceOf(obj.dcv, 'mlpet.DCV');
 			this.verifyEqual(obj.dcv.times, []);
 			this.verifyEqual(obj.dcv.tscCounts', []);            
            
 			this.verifyEqual(obj.ecatFqfilename, '');
 			this.verifyInstanceOf(obj.ecat, 'mlfourd.ImagingContext');
 			this.verifyEqual(obj.ecat, []);
 			this.verifyEqual(obj.ecat, []);
            
 			this.verifyInstanceOf(obj.petAtlas, 'mlfourd.ImagingContext');
 			this.verifyEqual(obj.petAtlas, []);
 			this.verifyEqual(obj.petAtlas, []);  
            
 			this.verifyEqual(obj.maskFqfilename, '');
 			this.verifyInstanceOf(obj.mask, 'mlfourd.ImagingContext');
 			this.verifyEqual(obj.mask, []);
 			this.verifyEqual(obj.mask, []);          
 		end
		function test_ho15DataGluT(this)
 			import mlperfusion.*;
 			this.assumeEqual(1,1);
 			this.verifyEqual(1,1);
 			this.assertEqual(1,1);
 		end
		function test_ho15DataPPG(this)
 			import mlperfusion.*;
 			this.assumeEqual(1,1);
 			this.verifyEqual(1,1);
 			this.assertEqual(1,1);
 		end
	end

 	methods (TestClassSetup)
		function setupHO15Data(this)
            this.registry = mlfourd.UnittestRegistry.instance('initialize');
 			this.testObj_ = mlperfusion.HO15Data(this.registry.sessionPath);
 		end
	end

 	methods (TestMethodSetup)
		function setupHO15DataTest(this)
 			this.testObj = this.testObj_;
 		end
	end

	properties (Access = 'private')
 		testObj_
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

