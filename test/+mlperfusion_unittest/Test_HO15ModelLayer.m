classdef Test_HO15ModelLayer < matlab.unittest.TestCase
	%% TEST_HO15MODELLAYER 

	%  Usage:  >> results = run(mlperfusion_unittest.Test_HO15ModelLayer)
 	%          >> result  = run(mlperfusion_unittest.Test_HO15ModelLayer, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 12-Jan-2016 19:07:42
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/test/+mlperfusion_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		registry
        studyReg
 		testObj
        tol = 0.05
 	end

	methods (Test)
		function test_estimateAutoradiography(this)
 			import mlperfusion.*;
            m = PLaif1TrainingModel;
            d = HO15Data(this.studyReg);
 			this.testObj.estimateAutoradiography(m, d);
            this.verifyEqual( ...
                this.testObj.bestFitParams, [], 'RelTol', this.tol);
            
            this.testObj.plot;
 		end
	end

 	methods (TestClassSetup)
		function setupHO15ModelModelLayer(this)
            this.registry = mlfourd.UnittestRegistry.instance('initialize');
            this.studyReg = ;
 		end
	end

 	methods (TestMethodSetup)
		function setupHO15ModelLayerTest(this)
 			import mlperfusion.*;
 			this.testObj = HO15ModelLayer.instance('initialize');
 		end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

