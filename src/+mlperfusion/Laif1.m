classdef Laif1 < mlperfusion.AbstractLaif
	%% LAIF1   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
	properties
        showPlots = true	 
        baseTitle = 'Laif1'
        xLabel    = 'times/s'
        yLabel    = 'arbitrary'
        
        F  = 2.239176
        S0 = 555.281677
        a  = 5.886588
        b  = 1.335361
        d  = 0.489088
        e  = 0.984358
        g  = 0.116832
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
            m('e')  = struct('fixed', 0, 'min', this.priorLow(this.e),  'mean', this.e,  'max', 1);
            m('g')  = struct('fixed', 0, 'min', this.priorLow(this.g),  'mean', this.g,  'max', this.priorHigh(this.g));
            m('t0') = struct('fixed', 1, 'min', this.priorLow(this.t0), 'mean', this.t0, 'max', this.priorHigh(this.t0)); 
        end
    end
    
    methods (Static) 
        function this = runLaif(times, magn)
            this = mlperfusion.Laif1(times, magn);
            this = this.estimateS0t0;
            this = this.estimateParameters(this.map);
        end
                  
        function m    = magnetization(F, S0, a, b, d, e, g, t, t0)
            import mlperfusion.*;
            m = S0 * exp(-F * Laif1.kConcentration(e, a, b, d, g, t, t0));
            m = abs(m);
        end 
        function kC   = kConcentration(e, a, b, d, g, t, t0)
            import mlperfusion.*;
            kC =      e  * Laif1.flowTerm(a, b, d, t, t0) + ...
                 (1 - e) * Laif1.steadyStateTerm(d, g, t, t0);
            kC = abs(kC);
        end          
        function this = simulateMcmc(F, S0, a, b, d, e, g, t, t0, dsc, map)
            
            import mlperfusion.*;            
            magn = Laif1.magnetization(F, S0, a, b, d, e, g, t, t0);
            this = Laif1(t, dsc);
            this = this.estimateParameters(map) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData, t, magn, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  F %g, S0 %g, alpha %g, beta %g, delta %g, eps %g, gamma %g, t0 %g', ...
                  F, S0, a, b, d, e, g, t0));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end   
    end

	methods        
 		function this = Laif1(varargin) 
 			%% LAIF1 
 			%  Usage:  this = Laif1([times, magnetization]) 
 			
 			this = this@mlperfusion.AbstractLaif(varargin{:});  
            this.expectedBestFitParams_ = ...
                [this.F this.S0 this.a this.b this.d this.e this.g this.t0]';
        end 
        function this = estimateParameters(this, varargin)
            ip = inputParser;
            addOptional(ip, 'map', this.map, @(x) isa(x, 'containers.Map'));
            parse(ip, varargin{:});
            
            import mlbayesian.*;
            this.paramsManager = BayesianParameters(p.Results.map);
            this.ensureKeyOrdering({'F' 'S0' 'a' 'b' 'd' 'e' 'g' 't0'});
            this.mcmc          = MCMC(this, this.dependentData, this.paramsManager);
            [~,~,this.mcmc]    = this.mcmc.runMcmc;
            this.F = this.finalParams('F');
            this.a = this.finalParams('a');
            this.b = this.finalParams('b');
            this.d = this.finalParams('d');
            this.e = this.finalParams('e');
            this.g = this.finalParams('g');
        end
        function ed = estimateData(this)            
            keys = this.paramsManager.paramsMap.keys;
            ed = this.estimateDataFast( ...
                this.finalParams(keys{1}), ...
                this.finalParams(keys{2}), ...
                this.finalParams(keys{3}), ...
                this.finalParams(keys{4}), ...
                this.finalParams(keys{5}), ...
                this.finalParams(keys{6}), ...
                this.finalParams(keys{7}), ...
                this.finalParams(keys{8}));
        end
        function ed = estimateDataFast(this, F, S0, a, b, d, e, g, t0)
            ed = this.magnetization(F, S0, a, b, d, e, g, this.independentData, t0);
        end
        function ps   = adjustParams(this, ps)            
            manager = this.paramsManager;
            if (ps(manager.paramsIndices('d')) > ps(manager.paramsIndices('b')))
                tmp                            = ps(manager.paramsIndices('b'));
                ps(manager.paramsIndices('b')) = ps(manager.paramsIndices('d'));
                ps(manager.paramsIndices('d')) = tmp;
            end
            if (ps(manager.paramsIndices('e')) > 1)
                ps(manager.paramsIndices('e')) = 1;
            end
            if (ps(manager.paramsIndices('e')) < eps)
                ps(manager.paramsIndices('e')) = eps;
            end
            if (ps(manager.paramsIndices('g')) == ps(manager.paramsIndices('d')))
                ps(manager.paramsIndices('g')) = ps(manager.paramsIndices('g')) + eps;
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

