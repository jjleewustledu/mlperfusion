classdef Test_PLaifAlignmentBuilder < matlab.unittest.TestCase
	%% TEST_PLAIFALIGNMENTBUILDER 

	%  Usage:  >> results = run(mlperfusion_unittest.Test_PLaifAlignmentBuilder)
 	%          >> result  = run(mlperfusion_unittest.Test_PLaifAlignmentBuilder, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 23-Dec-2015 16:24:44
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/test/+mlperfusion_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		registry
 		testObj
 	end

	methods (Test)
 		function test_afun(this)
 			import mlperfusion.*;
 			this.assumeEqual(1,1);
 			this.verifyEqual(1,1);
 			this.assertEqual(1,1);
 		end
 	end

 	methods (TestClassSetup)
 		function setupPLaifAlignmentBuilder(this)
 			import mlperfusion.*;
 			this.testObj = PLaifAlignmentBuilder;
 		end
 	end

 	methods (TestMethodSetup)
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

