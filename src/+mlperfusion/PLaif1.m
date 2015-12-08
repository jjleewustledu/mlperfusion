classdef PLaif1 < mlperfusion.AbstractPLaif 
	%% PLaif1   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
	properties
        baseTitle = 'PLaif1'
        xLabel    = 'times/s'
        yLabel    = 'arbitrary'        
        
        F  = 0.00752
        PS = 0.0257
        S0 = 7.50e6
        a  = 0.92
        b  = 0.168
        e  = 0.000993
        g  = 0.0680
        t0 = 50.5
    end 
    
    properties (Dependent)
        map 
    end
    
    methods %% GET
        function m = get.map(this)
            m = containers.Map;
            N = 5;
            m('F')  = struct('fixed', 0, 'min', 0.004305,                    'mean', this.F,  'max', 0.01229);
            m('PS') = struct('fixed', 0, 'min', 0.009275,                    'mean', this.PS, 'max', 0.03675);
            m('S0') = struct('fixed', 0, 'min', max(this.S0 - N*this.S0, 0), 'mean', this.S0, 'max', this.S0 + N*this.S0);
            m('a')  = struct('fixed', 0, 'min', max(this.a  - N*this.a,  0), 'mean', this.a,  'max', this.a  + N*this.a); 
            m('b')  = struct('fixed', 0, 'min', max(this.b  - N*this.b,  0), 'mean', this.b,  'max', this.b  + N*this.b);
            m('e')  = struct('fixed', 0, 'min', max(this.e  - N*this.e,  0), 'mean', this.e,  'max', this.e  + N*this.e);
            m('g')  = struct('fixed', 0, 'min', max(this.g  - N*this.g,  0), 'mean', this.g,  'max', this.g  + N*this.g);
            m('t0') = struct('fixed', 0, 'min',     this.t0 - N*this.t0,     'mean', this.t0, 'max', this.t0 + N*this.t0); 
        end
    end
    
    methods (Static)
        function this = load(ecatFn, maskFn)
            import mlpet.* mlperfusion.* mlfourd.*;
            mask = MaskingNIfTId.load(maskFn);
            ecat = EcatExactHRPlus.load(ecatFn);
            ecat = ecat.masked(mask);
            ecat = ecat.volumeSummed;
            
            ecat.img = ecat.img / mask.count;
           
            this = PLaif1(ecat.times, ecat.tscCounts);
        end
        function this = runPLaif(times, becq)
            this = mlperfusion.PLaif1(times, becq);
            this = this.estimateParameters(this.map);
        end        
        function m    = tscCounts(F, PS, S0, a, b, e, g, t0, t)
            import mlperfusion.*;
            m = S0 * PLaif1.kConcentration(F, PS, a, b, e, g, t0, t);
        end          
        function kC   = kConcentration(F, PS, a, b, e, g, t0, t)
            import mlperfusion.*;
            psfTerm = (1 - exp(-PS/F));
            delta   = psfTerm * F / AbstractPLaif.LAMBDA; %  + AbstractPLaif.LAMBDA_DECAY -  AbstractPLaif.LAMBDA_DECAY for non-decaying gamma-variate bolus
            kC      = psfTerm * F * (PLaif1.flowTerm(a, b, delta, t0, t) + e * PLaif1.steadyStateTerm(delta, g, t0, t));
            kC      = abs(kC);
        end
        function kA   = kAif(a, b, e, g, t0, t)
            import mlperfusion.*
            kA = exp(-AbstractPLaif.LAMBDA_DECAY*(t - t0)) .* AbstractPLaif.Heaviside(t, t0) .* ...
                 (PLaif1.bolusFlowTerm(a, b, t0, t) + e * PLaif1.bolusSteadyStateTerm(g, t0, t));
            kA = abs(kA);
        end
        function this = simulateMcmc(F, PS, S0, a, b, e, g, t0, t, becq, map)
            import mlperfusion.*;            
            this = PLaif1(t, becq);
            this = this.estimateParameters(map) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData, t, PLaif1.tscCounts(F, PS, S0, a, b, e, g, t0, t), 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  F%g, PS %g, S0 %g, alpha %g, beta %g, eps %g, gamma %g, t0 %g', ...
                  F, PS, S0, a, b, e, g, t0));
            xlabel('time/s');
            ylabel('activity/Bq');
        end    
    end

	methods
 		function this = PLaif1(varargin) 
 			%% PLaif1 
 			%  Usage:  this = PLaif1([times, tscCounts]) 
 			
 			this = this@mlperfusion.AbstractPLaif(varargin{:});
            this.expectedBestFitParams_ = ...
                [this.F this.PS this.S0 this.a this.b this.e this.g this.t0]';
        end 
        
        function this = simulateItsMcmc(this)
            import mlperfusion.*;
            becq = PLaif1.tscCounts( ...
                   this.F, this.PS, this.S0, this.a, this.b, this.e, this.g, this.t0, this.times); 
            this = PLaif1.simulateMcmc( ...
                   this.F, this.PS, this.S0, this.a, this.b, this.e, this.g, this.t0, this.times, becq, this.map);
        end
        function ka   = itsKAif(this)
            ka = mlperfusion.PLaif1.kAif(this.a, this.b, this.e, this.g, this.t0, this.times);
        end
        function m    = itsTscCounts(this)
            m = mlperfusion.PLaif1.tscCounts(this.F, this.PS, this.S0, this.a, this.b, this.e, this.g, this.t0, this.times);
        end
        function kc   = itsKConcentration(this)
            kc = mlperfusion.PLaif1.kConcentration(this.F, this.PS, this.a, this.b, this.e, this.g, this.t0, this.times);
        end
        function this = estimateAll(this)
            this = this.estimateParameters;
        end
        function this = estimateParameters(this, varargin)
            ip = inputParser;
            addOptional(ip, 'map', this.map, @(x) isa(x, 'containers.Map'));
            parse(ip, varargin{:});
            
            import mlbayesian.*;            
            this                   = this.estimateS0t0;
            this.paramsManager     = McmcParameters(ip.Results.map);
            this.ensureKeyOrdering({'F' 'PS' 'S0' 'a' 'b' 'e' 'g' 't0'});
            this.theStrategy       = MCMC(this, this.dependentData, this.paramsManager);
            [~,~,this.theStrategy] = this.theStrategy.runMcmc;
            this.F  = this.finalParams('F');
            this.PS = this.finalParams('PS');
            this.S0 = this.finalParams('S0');
            this.a  = this.finalParams('a');
            this.b  = this.finalParams('b');
            this.e  = this.finalParams('e');
            this.g  = this.finalParams('g');
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
                this.finalParams(keys{6}), ...
                this.finalParams(keys{7}), ...
                this.finalParams(keys{8}));
        end   
        function ed   = estimateDataFast(this, F, PS, S0, a, b, e, g, t0)
            ed = this.tscCounts(F, PS, S0, a, b, e, g, t0, this.times);
        end         
        function        plotInitialData(this)
            figure;
            max_b  = max(this.itsTscCounts);
            max_dd = max(this.dependentData);
            plot(this.times, this.itsTscCounts/max_b, ...
                 this.times, this.dependentData/max_dd);
            title(sprintf('PLaif1.plotInitialData:  %s', str2pnum(pwd)), 'Interpreter', 'none');
            legend('Bayesian activity', 'activity from data');
            xlabel('time/s');
            ylabel(sprintf('arbitrary; rescaled by %g, %g', max_b, max_dd));
        end
        function        plotProduct(this)
            figure;
            plot(this.times, this.itsTscCounts, this.times, this.dependentData, 'o');
            legend('Bayesian activity', 'activity from data');
            title(sprintf('PLaif1.plotProduct:  F %g, PS %g, S0 %g, a %g, b %g, e %g, g %g, t0 %g', ...
                this.F, this.PS, this.S0, this.a, this.b, this.e, this.g, this.t0), 'Interpreter', 'none');
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end        
        function        plotParVars(this, par, vars)
            assert(lstrfind(par, properties('mlperfusion.PLaif1')));
            assert(isnumeric(vars));
            switch (par)
                case 'F'
                    for v = 1:length(vars)
                        args{v} = { vars(v) this.PS this.S0 this.a  this.b  this.e  this.g  this.t0  this.times }; end
                case 'PS'
                    for v = 1:length(vars)
                        args{v} = { this.F  vars(v) this.S0 this.a  this.b  this.e  this.g  this.t0  this.times }; end
                case 'S0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS vars(v) this.a  this.b  this.e  this.g  this.t0  this.times }; end
                case 'a'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 vars(v) this.b  this.e  this.g  this.t0  this.times }; end
                case 'b'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  vars(v) this.e  this.g  this.t0  this.times }; end
                case 'e'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  this.b  vars(v) this.g  this.t0  this.times }; end
                case 'g'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  this.b  this.e  vars(v) this.t0  this.times }; end
                case 't0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  this.b  this.e  this.g  vars(v)  this.times }; end
            end
            this.plotParArgs(par, args, vars);
        end
    end
    
    %% PRIVATE
    
    methods (Access = 'private')
        function plotParArgs(this, par, args, vars)
            assert(lstrfind(par, properties('mlperfusion.PLaif1')));
            assert(iscell(args));
            assert(isnumeric(vars));
            import mlperfusion.*;
            figure
            hold on
            for v = 1:size(args,2)
                argsv = args{v};
                plot(this.times, PLaif1.tscCounts(argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{6}, argsv{7}));
            end
            title(sprintf('F %g, PS %g, S0 %g, a %g, b %g, e %g, g %g, t0 %g', ...
                          argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{6}, argsv{7}, argsv{8}));
            legend(cellfun(@(x) sprintf('%s = %g', par, x), num2cell(vars), 'UniformOutput', false));
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

