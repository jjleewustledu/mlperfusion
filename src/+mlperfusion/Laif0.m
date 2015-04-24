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
            m('F')  = struct('fixed', 0, 'min', this.priorLow(this.F),  'mean', this.F,  'max', this.priorHigh(this.F));
            m('S0') = struct('fixed', 1, 'min', this.priorLow(this.S0), 'mean', this.S0, 'max', this.priorHigh(this.S0));
            m('a')  = struct('fixed', 0, 'min', this.priorLow(this.a),  'mean', this.a,  'max', this.priorHigh(this.a)); 
            m('b')  = struct('fixed', 0, 'min', this.priorLow(this.b),  'mean', this.b,  'max', this.priorHigh(this.b));
            m('d')  = struct('fixed', 0, 'min', this.priorLow(this.d),  'mean', this.d,  'max', this.priorHigh(this.d));
            m('t0') = struct('fixed', 1, 'min', this.priorLow(this.t0), 'mean', this.t0, 'max', this.priorHigh(this.t0)); 
        end
    end
    
    methods (Static)  
        function this = runLaif(times, magn)
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
        function kA   = kAif(a, b, t, t0)
            import mlperfusion.*
            kA = Laif0.bolusFlowTerm(a, b, t, t0);
            kA = abs(kA);
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
 		function this = Laif0(varargin) 
 			%% LAIF0 
 			%  Usage:  this = Laif0([times, magnetization]) 
 			
 			this = this@mlperfusion.AbstractLaif(varargin{:});
            this.expectedBestFitParams_ = ...
                [this.F this.S0 this.a this.b this.d this.t0]';
        end 
        function ka   = itsKAif(this)
            ka = mlperfusion.Laif0.kAif(this.a, this.b, this.times, this.t0);
        end
        function m    = itsMagnetization(this)
            m = mlperfusion.Laif0.magnetization(this.F, this.S0, this.a, this.b, this.d, this.times, this.t0);
        end
        function kc   = itsKConcentration(this)
            kc = mlperfusion.Laif0.kConcentration(this.a, this.b, this.d, this.times, this.t0);
        end
        function this = estimateParameters(this, varargin)
            ip = inputParser;
            addOptional(ip, 'map', this.map, @(x) isa(x, 'containers.Map'));
            parse(ip, varargin{:});
            
            import mlbayesian.*;
            this.paramsManager = BayesianParameters(ip.Results.map);
            this.ensureKeyOrdering({'F' 'S0' 'a' 'b' 'd' 't0'});
            this.mcmc          = MCMC(this, this.dependentData, this.paramsManager);
            [~,~,this.mcmc]    = this.mcmc.runMcmc;
            this.F = this.finalParams('F');
            this.S0 = this.finalParams('S0');
            this.a = this.finalParams('a');
            this.b = this.finalParams('b');
            this.d = this.finalParams('d');
            this.t0 = this.finalParams('t0');
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

