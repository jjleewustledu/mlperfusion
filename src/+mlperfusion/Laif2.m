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
        
        F  = 2.024300
        S0 = 555.281677
        a  = 5.037182
        b  = 1.201236
        d  = 0.435770
        e  = 0.985232
        g  = 0.126983
        n  = 0.118039
        t0 = 16.50000
        t1 = 32.968789
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
            m('e')  = struct('fixed', 0, 'min', fL*this.e,  'mean', this.e,  'max', 1);
            m('g')  = struct('fixed', 0, 'min', fL*this.g,  'mean', this.g,  'max', fH*this.g);
            m('n')  = struct('fixed', 0, 'min', fL*this.n,  'mean', this.n,  'max', fH*this.n);
            m('t0') = struct('fixed', 1, 'min', fL*this.t0, 'mean', this.t0, 'max', fH*this.t0); 
            m('t1') = struct('fixed', 0, 'min', fL*this.t1, 'mean', this.t1, 'max', fH*this.t1); 
        end
    end
    
    methods (Static) 
        function this = run(times, magn)
            this = mlperfusion.Laif2(times, magn);
            this = this.estimateS0t0;
            this = this.estimateParameters(this.map);
        end
                  
        function m    = magnetization(F, S0, a, b, d, e, g, n, t, t0, t1)
            import mlperfusion.*;
            m = S0 * exp(-F * Laif2.kConcentration(e, a, b, d, g, n, t, t0, t1));
            m = abs(m);
        end 
        function kC   = kConcentration(e, a, b, d, g, n, t, t0, t1)
            import mlperfusion.*;
            kC =      e  * Laif2.flowTerm(a, b, d, t, t0) + ...
                      n  * Laif2.flowTerm(a, b, d, t, t1) + ...
                 (1 - e) * Laif2.steadyStateTerm(d, g, t, t0);
            kC = abs(kC);
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
 		function this = Laif2(times, magn, varargin) 
 			%% LAIF2 
 			%  Usage:  this = Laif2(WholeBrainDSC_object) 
 			
 			this = this@mlperfusion.AbstractLaif(times, magn, varargin{:});  
            p = inputParser;
            addRequired(p, 'times', @isnumeric);
            addRequired(p, 'magn',  @isnumeric);
            parse(p, times, magn, varargin{:});
        end 
        function this = estimateParameters(this, map)
            import mlbayesian.*;
            assert(isa(map, 'containers.Map'));
            this.paramsManager = BayesianParameters(map);
            this.ensureKeyOrdering({'F' 'S0' 'a' 'b' 'd' 'e' 'g' 'n' 't0' 't1'});
            this.mcmc          = MCMC(this, this.dependentData, this.paramsManager);
            [~,~,this.mcmc]    = this.mcmc.runMcmc;
            this.F = this.finalParams('F');
            this.a = this.finalParams('a');
            this.b = this.finalParams('b');
            this.d = this.finalParams('d');
            this.e = this.finalParams('e');
            this.g = this.finalParams('g');
            this.g = this.finalParams('n');
            this.g = this.finalParams('t1');
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
            ed = this.magnetization(F, S0, a, b, d, e, g, n, this.independentData, t0, t1);
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

