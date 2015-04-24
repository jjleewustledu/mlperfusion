classdef Laif2 < mlperfusion.AbstractLaif
	%% LAIF2   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
	properties
        showPlots = true	 
        baseTitle = 'Laif2'
        xLabel    = 'times/s'
        yLabel    = 'arbitrary'
        
        F  = 2.248191 % set to expected best-fit
        S0 = 555.281677
        a  = 4.155459
        b  = 1.023300
        d  = 0.423558
        e  = 0.987518
        g  = 0.136305
        n  = 0.124036
        t0 = 16.50000
        t1 = 33.189811
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
            m('n')  = struct('fixed', 0, 'min', this.priorLow(this.n),  'mean', this.n,  'max', this.priorHigh(this.n));
            m('t0') = struct('fixed', 1, 'min', this.priorLow(this.t0), 'mean', this.t0, 'max', this.priorHigh(this.t0)); 
            m('t1') = struct('fixed', 0, 'min', this.priorLow(this.t1), 'mean', this.t1, 'max', this.priorHigh(this.t1)); 
        end
    end
    
    methods (Static) 
        function this = runLaif(times, magn)
            this = mlperfusion.Laif2(times, magn);
            this = this.estimateS0t0;
            this = this.estimateParameters(this.map);
        end
                  
        function m    = magnetization(F, S0, a, b, d, e, g, n, t, t0, t1)
            import mlperfusion.*;
            m = S0 * exp(-F * Laif2.kConcentration(a, b, d, e, g, n, t, t0, t1));
            m = abs(m);
        end 
        function kC   = kConcentration(a, b, d, e, g, n, t, t0, t1)
            import mlperfusion.*;
            kC = (1 - n) * e  * Laif2.flowTerm(a, b, d, t, t0) + ...
                      n  * e  * Laif2.flowTerm(a, b, d, t, t1) + ...
                      (1 - e) * Laif2.steadyStateTerm(d, g, t, t0);
            kC = abs(kC);
        end     
        function kA   = kAif(a, b, e, g, n, t, t0, t1)
            import mlperfusion.*
            kA = (1 - n) * e  * Laif1.bolusFlowTerm(a, b, t, t0) + ...
                      n  * e  * Laif2.bolusFlowTerm(a, b, t, t1) + ...
                      (1 - e) * Laif1.bolusSteadyStateTerm(g, t, t0);
            kA = abs(kA);
        end      
        function this = simulateMcmc(F, S0, a, b, d, e, g, n, t, t0, t1, dsc, map)
            
            import mlperfusion.*;            
            magn = Laif2.magnetization(F, S0, a, b, d, e, g, n, t, t0, t1);
            this = Laif2(t, dsc);
            this = this.estimateParameters(map) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData, t, magn, 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  F %g, S0 %g, alpha %g, beta %g, delta %g, eps %g, gamma %g, nu %g, t0 %g, t1 %g', ...
                  F, S0, a, b, d, e, g, n, t0, t1));
            xlabel('time/s');
            ylabel('magnetization/arbitrary');
        end   
    end

	methods        
 		function this = Laif2(varargin) 
 			%% LAIF2 
 			%  Usage:  this = Laif2([times, magnetization]) 
 			
 			this = this@mlperfusion.AbstractLaif(varargin{:});            
            this.expectedBestFitParams_ = ...
                [this.F this.S0 this.a this.b this.d this.e this.g this.n this.t0 this.t1]';
        end 
        function m    = itsMagnetization(this)
            m = mlperfusion.Laif2.magnetization(this.F, this.S0, this.a, this.b, this.d, this.e, this.g, this.n, this.times, this.t0, this.t1);
        end
        function kc   = itsKConcentration(this)
            kc = mlperfusion.Laif2.kConcentration(this.a, this.b, this.d, this.e, this.g, this.n, this.times, this.t0, this.t1);
        end
        function ka   = itsKAif(this)
            ka = mlperfusion.Laif2.kAif(this.a, this.b, this.e, this.g, this.n, this.times, this.t0, this.t1);
        end
        function this = estimateParameters(this, varargin)
            ip = inputParser;
            addOptional(ip, 'map', this.map, @(x) isa(x, 'containers.Map'));
            parse(ip, varargin{:});
            
            import mlbayesian.*;
            this.paramsManager = BayesianParameters(varargin{:});
            this.ensureKeyOrdering({'F' 'S0' 'a' 'b' 'd' 'e' 'g' 'n' 't0' 't1'});
            this.mcmc          = MCMC(this, this.dependentData, this.paramsManager);
            [~,~,this.mcmc]    = this.mcmc.runMcmc;
            this.F = this.finalParams('F');
            this.S0 = this.finalParams('S0');
            this.a = this.finalParams('a');
            this.b = this.finalParams('b');
            this.d = this.finalParams('d');
            this.e = this.finalParams('e');
            this.g = this.finalParams('g');
            this.n = this.finalParams('n');
            this.t0 = this.finalParams('t0');
            this.t1 = this.finalParams('t1');
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
                this.finalParams(keys{8}), ...
                this.finalParams(keys{9}), ...
                this.finalParams(keys{10}));
        end
        function ed = estimateDataFast(this, F, S0, a, b, d, e, g, n, t0, t1)
            ed = this.magnetization(F, S0, a, b, d, e, g, n, this.times, t0, t1);
        end
        function ps   = adjustParams(this, ps)            
            manager = this.paramsManager;
            if (ps(manager.paramsIndices('d')) > ps(manager.paramsIndices('b')))
                tmp                            = ps(manager.paramsIndices('b'));
                ps(manager.paramsIndices('b')) = ps(manager.paramsIndices('d'));
                ps(manager.paramsIndices('d')) = tmp;
            end
%             if (ps(manager.paramsIndices('e')) > 1)
%                 ps(manager.paramsIndices('e')) = 1;
%             end
%             if (ps(manager.paramsIndices('e')) < eps)
%                 ps(manager.paramsIndices('e')) = eps;
%             end
            if (ps(manager.paramsIndices('g')) == ps(manager.paramsIndices('d')))
                ps(manager.paramsIndices('g')) = ps(manager.paramsIndices('g')) + eps;
            end
            if (ps(manager.paramsIndices('t0')) > ps(manager.paramsIndices('t1')))                
                tmp                             = ps(manager.paramsIndices('t1'));
                ps(manager.paramsIndices('t1')) = ps(manager.paramsIndices('t0'));
                ps(manager.paramsIndices('t0')) = tmp;
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

