classdef BayesianDCV1 < mlperfusion.AbstractPLaif
	%% BayesianDCV1  

	%  $Revision$
 	%  was created 23-Nov-2015 19:43:07
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/src/+mlperfusion.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
	properties
        baseTitle = 'BayesianDCV1'
        xLabel    = 'times/s'
        yLabel    = 'arbitrary'        

        S0 = 3.38e6
        a  = 2.09
        b  = 0.195
        e  = 0.0194
        g  = 0.0328
        t0 = 18.3
    end 
    
    properties (Dependent)
        mapParams 
    end
    
    methods %% GET
        function m = get.mapParams(this)
            m = containers.Map;
            N = 10;
            m('S0') = struct('fixed', 0, 'min', max(this.S0 - N*this.S0, 0), 'mean', this.S0, 'max', this.S0 + N*this.S0);
            m('a')  = struct('fixed', 0, 'min', max(this.a  - N*this.a,  0), 'mean', this.a,  'max', this.a  + N*this.a); 
            m('b')  = struct('fixed', 0, 'min', max(this.b  - N*this.b,  0), 'mean', this.b,  'max', this.b  + N*this.b);
            m('e')  = struct('fixed', 0, 'min', max(this.e  - N*this.e,  0), 'mean', this.e,  'max', this.e  + N*this.e);
            m('g')  = struct('fixed', 0, 'min', max(this.g  - N*this.g,  0), 'mean', this.g,  'max', this.g  + N*this.g);
            m('t0') = struct('fixed', 0, 'min',     this.t0 - N*this.t0,     'mean', this.t0, 'max', this.t0 + N*this.t0); 
        end
    end
    
    methods (Static)
        function this = load(ucdcvFn)
            import mlpet.* mlperfusion.*;
            ucdcv = UncorrectedDCV.load(ucdcvFn);
            this  = BayesianDCV1(ucdcv.times, ucdcv.wellCounts);
        end
        function this = runBayesianDCV(times, wellcnts)
            this = mlperfusion.BayesianDCV1(times, wellcnts);
            this = this.estimateParameters(this.mapParams);
        end        
        function m    = wellCounts(S0, a, b, e, g, t0, t)
            import mlperfusion.*;
            m = S0 * BayesianDCV1.kAif(a, b, e, g, t0, t) .* exp(-BayesianDCV1.LAMBDA_DECAY_15O*(t - t0)) .* BayesianDCV1.Heaviside(t, t0);
        end         
        function kC   = kConcentration(a, b, e, g, t0, t)
            import mlperfusion.*;
            kC = BayesianDCV1.bolusFlowTerm(a, b, t0, t) + e * BayesianDCV1.bolusSteadyStateTerm(g, t0, t);
            kC = abs(kC);
        end
        function kA   = kAif(a, b, e, g, t0, t)
            import mlperfusion.*
            kA = BayesianDCV1.bolusFlowTerm(a, b, t0, t) + e * BayesianDCV1.bolusSteadyStateTerm(g, t0, t);
            kA = abs(kA);
        end
        function this = simulateMcmc(S0, a, b, e, g, t0, t, wellcnts0, mapParams)
            import mlperfusion.*;            
            this = BayesianDCV1(t, wellcnts0);
            this = this.estimateParameters(mapParams) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData, t, BayesianDCV1.wellCounts(S0, a, b, e, g, t0, t), 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  S0 %g, alpha %g, beta %g, eps %g, gamma %g, t0 %g', ...
                          S0, a, b, e, g, t0));
            xlabel('time/s');
            ylabel('activity/Bq');
        end    
    end

	methods 		  
 		function this = BayesianDCV1(varargin)
 			%% BayesianDCV1
 			%  Usage:  this = BayesianDCV1()

 			this = this@mlperfusion.AbstractPLaif(varargin{:});
        end        
        
        function this = simulateItsMcmc(this)
            import mlperfusion.*;
            wellcnts0 = BayesianDCV1.wellCounts(  this.S0, this.a, this.b, this.e, this.g, this.t0, this.times); 
            this      = BayesianDCV1.simulateMcmc(this.S0, this.a, this.b, this.e, this.g, this.t0, this.times, wellcnts0, this.mapParams);
        end
        function ka   = itsKAif(this)
            ka = mlperfusion.BayesianDCV1.kAif(this.a, this.b, this.e, this.g, this.t0, this.times);
        end
        function m    = itsWellCounts(this)
            m = mlperfusion.BayesianDCV1.wellCounts(this.S0, this.a, this.b, this.e, this.g, this.t0, this.times);
        end        
        function kc   = itsKConcentration(this)
            kc = mlperfusion.PLaif0.kConcentration(this.a, this.b, this.e, this.g, this.t0, this.times);
        end
        function this = estimateParameters(this, varargin)
            ip = inputParser;
            addOptional(ip, 'mapParams', this.mapParams, @(x) isa(x, 'containers.Map'));
            parse(ip, varargin{:});
            
            import mlbayesian.*;
            [this.S0,this.t0]      = this.estimateS0t0(this.independentData, this.dependentData);
            this.theParameters     = McmcParameters(ip.Results.mapParams);
            this.ensureKeyOrdering({'S0' 'a' 'b' 'e' 'g' 't0'});
            this.theStrategy       = MCMC(this, this.dependentData, this.theParameters);
            [~,~,this.theStrategy] = this.theStrategy.runMcmc;
            this.S0 = this.finalParams('S0');
            this.a  = this.finalParams('a');
            this.b  = this.finalParams('b');
            this.e  = this.finalParams('e');
            this.g  = this.finalParams('g');
            this.t0 = this.finalParams('t0');
        end
        function ed   = estimateData(this)
            keys = this.theParameters.paramsMap.keys;
            ed = this.estimateDataFast( ...
                this.finalParams(keys{1}), ...
                this.finalParams(keys{2}), ...
                this.finalParams(keys{3}), ...
                this.finalParams(keys{4}), ...
                this.finalParams(keys{5}), ...
                this.finalParams(keys{6}));
        end   
        function ed   = estimateDataFast(this, S0, a, b, e, g, t0)
            ed = this.wellCounts(S0, a, b, e, g, t0, this.times);
        end         
        function        plotInitialData(this)
            figure;
            max_b  = max(this.itsWellCounts);
            max_dd = max(this.dependentData);
            plot(this.times, this.itsWellCounts/max_b, ...
                 this.times, this.dependentData/max_dd);
            title(sprintf('BayesianDCV1.plotInitialData:  %s', str2pnum(pwd)), 'Interpreter', 'none');
            legend('Bayesian activity', 'activity from data');
            xlabel('time/s');
            ylabel(sprintf('arbitrary; rescaled by %g, %g', max_b, max_dd));
        end
        function        plot(this, varargin)
            figure;
            plot(this.times, this.itsWellCounts, this.times, this.dependentData, 'o', varargin{:});
            legend('Bayesian activity', 'activity from data');
            title(sprintf('BayesianDCV1.plotProduct:  S0 %g, a %g, b %g, e %g, g %g, t0 %g', ...
                this.S0, this.a, this.b, this.e, this.g, this.t0), 'Interpreter', 'none');
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end        
        function        plotParVars(this, par, vars)
            assert(lstrfind(par, properties('mlperfusion.BayesianDCV1')));
            assert(isnumeric(vars));
            switch (par)
                case 'S0'
                    for v = 1:length(vars)
                        args{v} = { vars(v) this.a  this.b  this.e  this.g  this.t0  this.times }; end
                case 'a'
                    for v = 1:length(vars)
                        args{v} = { this.S0 vars(v) this.b  this.e  this.g  this.t0  this.times }; end
                case 'b'
                    for v = 1:length(vars)
                        args{v} = { this.S0 this.a  vars(v) this.e  this.g  this.t0  this.times }; end
                case 'e'
                    for v = 1:length(vars)
                        args{v} = { this.S0 this.a  this.b  vars(v) this.g  this.t0  this.times }; end
                case 'g'
                    for v = 1:length(vars)
                        args{v} = { this.S0 this.a  this.b  this.e  vars(v) this.t0  this.times }; end
                case 't0'
                    for v = 1:length(vars)
                        args{v} = { this.S0 this.a  this.b  this.e  this.g  vars(v)  this.times }; end
            end
            this.plotParArgs(par, args, vars);
        end
 	end 

    %% PRIVATE
    
    methods (Access = 'private')
        function plotParArgs(this, par, args, vars)
            assert(lstrfind(par, properties('mlperfusion.BayesianDCV1')));
            assert(iscell(args));
            assert(isnumeric(vars));
            import mlperfusion.*;
            figure
            hold on
            for v = 1:size(args,2)
                argsv = args{v};
                plot(this.times, BayesianDCV1.wellCounts(argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{6}, argsv{7}));
            end
            title(sprintf('S0 %g, a %g, b %g, e %g, g %g, t0 %g', ...
                          argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{6}));
            legend(cellfun(@(x) sprintf('%s = %g', par, x), num2cell(vars), 'UniformOutput', false));
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

