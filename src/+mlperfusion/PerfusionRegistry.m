classdef PerfusionRegistry < mlpatterns.Singleton
	%% PERFUSIONREGISTRY  

	%  $Revision$
 	%  was created 23-Dec-2015 15:31:24
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/src/+mlperfusion.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64. 	

	properties 		
        sessionRegexp = '\S*(?<mnum>mm0\d-\d+)_(?<pnum>p\d+)\S*'
        sessionNamePattern = 'mm0*_p*'
 	end

    properties (Dependent)
        subjectsDir
        testSubjectPath
    end    
    
    methods %% GET
        function x = get.subjectsDir(~)
            x = fullfile(getenv('NP755'), '');
        end
        function x = get.testSubjectPath(~)
            x = fullfile(getenv('MLUNIT_TEST_PATH'), 'cvl', 'np755', 'mm01-020_p7377_2009feb5', '');
        end
    end
    
    methods (Static)
        function this = instance(qualifier)
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            persistent uniqueInstance
            
            if (exist('qualifier','var') && ischar(qualifier))
                if (strcmp(qualifier, 'initialize'))
                    uniqueInstance = [];
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlperfusion.PerfusionRegistry();
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end  

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

