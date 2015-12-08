classdef BayesianDCV0 < mlperfusion.AbstractPLaif
	%% BAYESIANDCV0  

	%  $Revision$
 	%  was created 23-Nov-2015 19:43:07
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/src/+mlperfusion.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
	properties
        baseTitle = 'BayesianDCV0'
        xLabel    = 'times/s'
        yLabel    = 'arbitrary'        

        S0 = 8.40e6
        a  = 1.19
        b  = 0.193
        t0 = 21.5
    end 
    
    properties (Dependent)
        map 
    end
    
    methods %% GET
        function m = get.map(this)
            m = containers.Map;
            N = 10;
            m('S0') = struct('fixed', 0, 'min', max(this.S0 - N*this.S0, 0), 'mean', this.S0, 'max', this.S0 + N*this.S0);
            m('a')  = struct('fixed', 0, 'min', max(this.a  - N*this.a,  0), 'mean', this.a,  'max', this.a  + N*this.a); 
            m('b')  = struct('fixed', 0, 'min', max(this.b  - N*this.b,  0), 'mean', this.b,  'max', this.b  + N*this.b);
            m('t0') = struct('fixed', 0, 'min',     this.t0 - N*this.t0,     'mean', this.t0, 'max', this.t0 + N*this.t0); 
        end
    end
    
    methods (Static)
        function this = load(ucdcvFn)
            import mlpet.* mlperfusion.*;
            ucdcv = UncorrectedDCV.load(ucdcvFn);
            this  = BayesianDCV0(ucdcv.times, ucdcv.wellCounts);
        end
        function this = runBayesianDCV(times, wellcnts)
            this = mlperfusion.BayesianDCV0(times, wellcnts);
            this = this.estimateParameters(this.map);
        end        
        function m    = wellCounts(S0, a, b, t0, t)
            import mlperfusion.*;
            m = S0 * BayesianDCV0.kConcentration(a, b, t0, t) .* exp(-BayesianDCV0.LAMBDA_DECAY*(t - t0)) .* BayesianDCV0.Heaviside(t, t0);
        end         
        function kC   = kConcentration(a, b, t0, t)
            import mlperfusion.*;
            kC = BayesianDCV0.bolusFlowTerm(a, b, t0, t);
            kC = abs(kC);
        end
        function kA   = kAif(a, b, t0, t)
            import mlperfusion.*
            kA = BayesianDCV0.bolusFlowTerm(a, b, t0, t);
            kA = abs(kA);
        end
        function this = simulateMcmc(S0, a, b, t0, t, wellcnts0, map)
            import mlperfusion.*;            
            this = BayesianDCV0(t, wellcnts0);
            this = this.estimateParameters(map) %#ok<NOPRT>
            
            figure;
            plot(t, this.estimateData, t, BayesianDCV0.wellCounts(S0, a, b, t0, t), 'o');
            legend('Bayesian estimate', 'simulated data');
            title(sprintf('simulateMcmc expected:  S0 %g, alpha %g, beta %g, t0 %g', ...
                          S0, a, b, t0));
            xlabel('time/s');
            ylabel('activity/Bq');
        end    
    end

	methods 		  
 		function this = BayesianDCV0(varargin)
 			%% BAYESIANDCV0
 			%  Usage:  this = BayesianDCV0()

 			this = this@mlperfusion.AbstractPLaif(varargin{:});
        end        
        
        function this = simulateItsMcmc(this)
            import mlperfusion.*;
            wellcnts0 = BayesianDCV0.wellCounts(  this.S0, this.a, this.b, this.t0, this.times); 
            this      = BayesianDCV0.simulateMcmc(this.S0, this.a, this.b, this.t0, this.times, wellcnts0, this.map);
        end
        function ka   = itsKAif(this)
            ka = mlperfusion.BayesianDCV0.kAif(this.a, this.b, this.t0, this.times);
        end
        function m    = itsWellCounts(this)
            m = mlperfusion.BayesianDCV0.wellCounts(this.S0, this.a, this.b, this.t0, this.times);
        end        
        function kc   = itsKConcentration(this)
            kc = mlperfusion.PLaif0.kConcentration(this.a, this.b, this.t0, this.times);
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
            this.ensureKeyOrdering({'S0' 'a' 'b' 't0'});
            this.theStrategy       = MCMC(this, this.dependentData, this.paramsManager);
            [~,~,this.theStrategy] = this.theStrategy.runMcmc;
            this.S0 = this.finalParams('S0');
            this.a  = this.finalParams('a');
            this.b  = this.finalParams('b');
            this.t0 = this.finalParams('t0');
        end
        function ed   = estimateData(this)
            keys = this.paramsManager.paramsMap.keys;
            ed = this.estimateDataFast( ...
                this.finalParams(keys{1}), ...
                this.finalParams(keys{2}), ...
                this.finalParams(keys{3}), ...
                this.finalParams(keys{4}));
        end   
        function ed   = estimateDataFast(this, S0, a, b, t0)
            ed = this.wellCounts(S0, a, b, t0, this.times);
        end         
        function        plotInitialData(this)
            figure;
            max_b  = max(this.itsWellCounts);
            max_dd = max(this.dependentData);
            plot(this.times, this.itsWellCounts/max_b, ...
                 this.times, this.dependentData/max_dd);
            title(sprintf('BayesianDCV0.plotInitialData:  %s', str2pnum(pwd)), 'Interpreter', 'none');
            legend('Bayesian activity', 'activity from data');
            xlabel('time/s');
            ylabel(sprintf('arbitrary; rescaled by %g, %g', max_b, max_dd));
        end
        function        plotProduct(this)
            figure;
            plot(this.times, this.itsWellCounts, this.times, this.dependentData, 'o');
            legend('Bayesian activity', 'activity from data');
            title(sprintf('BayesianDCV0.plotProduct:  S0 %g, a %g, b %g, t0 %g', ...
                this.S0, this.a, this.b, this.t0), 'Interpreter', 'none');
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end        
        function        plotParVars(this, par, vars)
            assert(lstrfind(par, properties('mlperfusion.BayesianDCV0')));
            assert(isnumeric(vars));
            switch (par)
                case 'S0'
                    for v = 1:length(vars)
                        args{v} = { vars(v) this.a  this.b  this.t0  this.times }; end
                case 'a'
                    for v = 1:length(vars)
                        args{v} = { this.S0 vars(v) this.b  this.t0  this.times }; end
                case 'b'
                    for v = 1:length(vars)
                        args{v} = { this.S0 this.a  vars(v) this.t0  this.times }; end
                case 't0'
                    for v = 1:length(vars)
                        args{v} = { this.S0 this.a  this.b  vars(v)  this.times }; end
            end
            this.plotParArgs(par, args, vars);
        end
 	end 

    %% PRIVATE
    
    methods (Access = 'private')
        function plotParArgs(this, par, args, vars)
            assert(lstrfind(par, properties('mlperfusion.BayesianDCV0')));
            assert(iscell(args));
            assert(isnumeric(vars));
            import mlperfusion.*;
            figure
            hold on
            for v = 1:size(args,2)
                argsv = args{v};
                plot(this.times, BayesianDCV0.wellCounts(argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}));
            end
            title(sprintf('S0 %g, a %g, b %g, t0 %g', ...
                          argsv{1}, argsv{2}, argsv{3}, argsv{4}));
            legend(cellfun(@(x) sprintf('%s = %g', par, x), num2cell(vars), 'UniformOutput', false));
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

