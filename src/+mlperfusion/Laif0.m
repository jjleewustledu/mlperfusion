classdef Laif0 < mlperfusion.AbstractLaif 
	%% LAIF0   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
	properties
        showPlots = true	 
        baseTitle = 'Laif0'
        xLabel    = 'times/s'
        yLabel    = 'arbitrary'        
        
        F  = 2.104938
        S0 = 555.281677
        a  = 6.773606
        b  = 1.578004
        d  = 0.606071
        t0 = 16.50000
    end 
    
    properties (Dependent)
        map 
    end
    
    methods %% GET
        function m = get.map(this)            
            m = containers.Map;
            fL = 0.8; fH = 1.2;
            m('F')  = struct('fixed', 0, 'min', fL*this.F,  'mean', this.F,  'max', fH*this.F);
            m('S0') = struct('fixed', 1, 'min', fL*this.S0, 'mean', this.S0, 'max', fH*this.S0);
            m('a')  = struct('fixed', 0, 'min', fL*this.a,  'mean', this.a,  'max', fH*this.a); 
            m('b')  = struct('fixed', 0, 'min', fL*this.b,  'mean', this.b,  'max', fH*this.b);
            m('d')  = struct('fixed', 0, 'min', fL*this.d,  'mean', this.d,  'max', fH*this.d);
            m('t0') = struct('fixed', 1, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0); 
        end
    end
    
    methods (Static)  
        function this = run(times, magn)
            this = mlperfusion.Laif0(times, magn);
            this = this.estimateS0t0;
            this = this.estimateParameters(this.map);
        end
        
        function m    = magnetization(F, S0, a, b, d, t, t0)
            import mlperfusion.*;
            m = S0 * exp(-F * Laif0.kConcentration(a, b, d, t, t0));
            m = abs(m);
        end          
        function kC   = kConcentration(a, b, d, t, t0)
            import mlperfusion.*;
            kC = Laif0.flowTerm(a, b, d, t, t0);
            kC = abs(kC);
        end               
        function this = simulateMcmc(F, S0, a, b, d, t, t0, dsc, map)            
            import mlperfusion.*;            
            magn = Laif0.magnetization(F, S0, a, b, d, t, t0);
            this = Laif0(t, dsc);
            this = this.estimateParameters(map) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData, t, magn, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  F%g, S0 %g alpha %g, beta %g, delta %g, t0 %g', ...
                  F, S0, a, b, d, t0));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end    
    end

	methods
 		function this = Laif0(times, magn, varargin) 
 			%% LAIF0 
 			%  Usage:  this = Laif0(WholeBrainDSC_object) 
 			
 			this = this@mlperfusion.AbstractLaif(times, magn);  
            p = inputParser;
            addRequired(p, 'times', @isnumeric);
            addRequired(p, 'magn',  @isnumeric);
            parse(p, times, magn, varargin{:});
        end 
        function this = estimateParameters(this, map)
            import mlbayesian.*;
            assert(isa(map, 'containers.Map'));
            this.paramsManager = BayesianParameters(map);
            this.ensureKeyOrdering({'F' 'S0' 'a' 'b' 'd' 't0'});
            this.mcmc          = MCMC(this, this.dependentData, this.paramsManager);
            [~,~,this.mcmc]    = this.mcmc.runMcmc;
            this.F = this.finalParams('F');
            this.a = this.finalParams('a');
            this.b = this.finalParams('b');
            this.d = this.finalParams('d');
        end
        function ed   = estimateData(this)
            keys = this.paramsManager.paramsMap.keys;
            ed = this.estimateDataFast( ...
                this.finalParams(keys{1}), ...
                this.finalParams(keys{2}), ...
                this.finalParams(keys{3}), ...
                this.finalParams(keys{4}), ...
                this.finalParams(keys{5}), ...
                this.finalParams(keys{6}));
        end   
        function ed   = estimateDataFast(this, F, S0, a, b, d, t0)  
            ed = this.magnetization(F, S0, a, b, d, this.independentData, t0);
        end         
        function ps   = adjustParams(this, ps)
            manager = this.paramsManager;
            if (ps(manager.paramsIndices('d')) > ps(manager.paramsIndices('b')))
                tmp                            = ps(manager.paramsIndices('b'));
                ps(manager.paramsIndices('b')) = ps(manager.paramsIndices('d'));
                ps(manager.paramsIndices('d')) = tmp;
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

