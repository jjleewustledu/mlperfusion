classdef Test_PLaifAlignmentDirector < matlab.unittest.TestCase
	%% TEST_PLAIFALIGNMENTDIRECTOR 

	%  Usage:  >> results = run(mlperfusion_unittest.Test_PLaifAlignmentDirector)
 	%          >> result  = run(mlperfusion_unittest.Test_PLaifAlignmentDirector, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 23-Dec-2015 14:57:19
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/test/+mlperfusion_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		registry
 	end

    properties (Dependent)
        sessionPath
        urlAllAligned
        urlT1Aligned
        urlHoAligned
        urlOoAligned
        urlOcAligned
        urlTrAligned
    end
    
    methods % GET
        function g = get.sessionPath(this)
            g = this.registry.testSubjectPath;
        end
        function g = get.urlAllAligned(this)
            g = fullfile(this.sessionPath, 'quality', '');
        end
    end
    
	methods (Test)
 		function test_afun(this)
 			import mlperfusion.*;
 			this.assumeEqual(1,1);
 			this.verifyEqual(1,1);
 			this.assertEqual(1,1);
 		end
        function test_createAllAligned(this)
 			import mlperfusion.*;
            pad = PLaifAlignmentDirector.createAllAligned(this.sessionPath);
            this.verifyClass(pad, 'mlperfusion.PLaifAlignmentDirector');
            this.verifyEqual(web(this.urlAllAligned), 0);
        end
 	end

 	methods (TestClassSetup)
 		function setupPLaifAlignmentDirector(this)
 			import mlperfusion.*;
            this.registry = PerfusionRegistry.instance;
 		end
 	end

 	methods (TestMethodSetup)
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

