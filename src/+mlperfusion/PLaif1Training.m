classdef PLaif1Training < mlperfusion.AbstractPLaif 
	%% PLAIF1TRAINING does Bayesian parameter estimation on the arterial-line data and the scanner detector-array data 
    %  with equal contributions of the sum-of-squares to the cost function.  This will be the basis for training
    %  prior ranges.  
	
	%  $Revision$
 	%  was created 25-Nov-2015 
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlperfusion/src/+mlperfusion.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	 
	properties        
        F  = 0.0122
        PS = 0.0364
        S0 = 3.61e6
        a  = 2.21
        b  = 0.214
        e  = 0.0123
        g  = 0.717
        t0 = 19.3 % for wellCounts
        u0 = 47.4 % for tscCounts
        
        xLabel = 'times/s'
        yLabel = 'activity'
    end 
    
    properties (Dependent)
        baseTitle
        detailedTitle
        mapParams 
    end
    
    methods %% GET
        function bt = get.baseTitle(this)
            bt = sprintf('%s %s', class(this), str2pnum(pwd));
        end
        function dt = get.detailedTitle(this)
            dt = sprintf('%s\nF %g, PS %g, S0 %g, a %g, b %g, e %g, g %g, t0 %g, u0 %g', ...
                         this.baseTitle, ...
                         this.F, this.PS, this.S0, this.a, this.b, this.e, this.g, this.t0, this.u0);
        end
        function m  = get.mapParams(this)
            m = containers.Map;
            N = 4;
            m('F')  = struct('fixed', 0, 'min', 0.004305,                    'mean', this.F,  'max', 0.01229);
            m('PS') = struct('fixed', 0, 'min', 0.009275,                    'mean', this.PS, 'max', 0.03675);
            m('S0') = struct('fixed', 0, 'min', max(this.S0 - N*this.S0, 0), 'mean', this.S0, 'max', this.S0 + N*this.S0);
            m('a')  = struct('fixed', 0, 'min', max(this.a  - N*this.a,  0), 'mean', this.a,  'max', this.a  + N*this.a); 
            m('b')  = struct('fixed', 0, 'min', max(this.b  - N*this.b,  0), 'mean', this.b,  'max', this.b  + N*this.b);
            m('e')  = struct('fixed', 0, 'min', max(this.e  - N*this.e,  0), 'mean', this.e,  'max', this.e  + N*this.e);
            m('g')  = struct('fixed', 0, 'min', max(this.g  - N*this.g,  0), 'mean', this.g,  'max', this.g  + N*this.g);
            m('t0') = struct('fixed', 0, 'min', this.t0/2,                   'mean', this.t0, 'max', 2*this.t0);
            m('u0') = struct('fixed', 0, 'min', this.u0/2,                   'mean', this.u0, 'max', 2*this.u0);  
        end
    end
    
    methods (Static)
        function this = load(ecatFn, maskFn, dcvFn)
            import mlpet.* mlperfusion.* mlfourd.*;
            mask = MaskingNIfTId.load(maskFn);
            ecat = EcatExactHRPlus.load(ecatFn); % radioactive decay modeled by kConcentration
            ecat = ecat.masked(mask);
            ecat = ecat.volumeSummed;            
            ecat.img = ecat.img / mask.count;
            
            dcv = DCV.load(dcvFn); % radioactive decay modeled by kAif
           
            this = PLaif1Training( ...
                {dcv.times      ecat.times}, ...
                {dcv.wellCounts ecat.tscCounts'});
        end   
        function wc   = wellCounts(S0, a, b, e, g, t0, t)
            import mlperfusion.*;
            wc = S0 * PLaif1Training.kAif(a, b, e, g, t0, t);
        end 
        function tc   = tscCounts(F, PS, S0, a, b, e, g, u0, t)
            import mlperfusion.*;
            tc = S0 * PLaif1Training.kConcentration(F, PS, a, b, e, g, u0, t);
        end    
        function kA   = kAif(a, b, e, g, t0, t)
            import mlperfusion.*
            %% exp(-PLaif1Training.LAMBDA_DECAY_15O*(t - t0)) .* PLaif1Training.Heaviside(t, t0) .* ...
            kA = PLaif1Training.bolusFlowTerm(a, b, t0, t) + ...
                 PLaif1Training.bolusSteadyStateTerm(e, g, t0, t);
        end             
        function kC   = kConcentration(F, PS, a, b, e, g, u0, t)
            import mlperfusion.*;
            m      = (1 - exp(-PS/F));
            ldecay = PLaif1Training.LAMBDA_DECAY_15O;
            beta   = b + ldecay;                              % decay of AIF
            delta  = m * F /  PLaif1Training.LAMBDA + ldecay; % decay in Fick's equation
            kC     = m * F * (PLaif1Training.flowTerm(a, beta, delta, u0, t) + ...
                              PLaif1Training.steadyStateTerm(delta, e, g, ldecay, u0, t));
        end
        function this = simulateMcmc(F, PS, S0, a, b, e, g, t0, u0, t, u, mapParams)
            import mlperfusion.*;     
            wellCnts = PLaif1Training.wellCounts(      S0, a, b, e, g, t0, t);
            tscCnts  = PLaif1Training.tscCounts(F, PS, S0, a, b, e, g, u0, u);
            this     = PLaif1Training({t t}, {wellCnts tscCnts});
            this     = this.estimateParameters(mapParams) %#ok<NOPRT>
            this.plot;
        end    
    end

	methods
 		function this = PLaif1Training(varargin) 
 			%% PLAIF1TRAINING 
 			%  Usage:  this = PLaif1Training([times, tscCounts]) 
 			
 			this = this@mlperfusion.AbstractPLaif(varargin{:});
            this.expectedBestFitParams_ = ...
                [this.F this.PS this.S0 this.a this.b this.e this.g this.t0 this.u0]';
        end 
        
        function this = simulateItsMcmc(this)
            import mlperfusion.*;
            this = PLaif1Training.simulateMcmc( ...
                   this.F, this.PS, this.S0, this.a, this.b, this.e, this.g, this.t0, this.u0, this.times{1}, this.times{2}, this.mapParams);
        end
        function wc   = itsWellCounts(this)
            wc = mlperfusion.PLaif1Training.wellCounts(this.S0, this.a, this.b, this.e, this.g, this.t0, this.times{1});
        end
        function tc   = itsTscCounts(this)
            tc = mlperfusion.PLaif1Training.tscCounts(this.F, this.PS, this.S0, this.a, this.b, this.e, this.g, this.u0, this.times{2});
        end
        function ka   = itsKAif(this)
            ka = mlperfusion.PLaif1Training.kAif(this.a, this.b, this.e, this.g, this.t0, this.times{1});
        end
        function kc   = itsKConcentration(this)
            kc = mlperfusion.PLaif1Training.kConcentration(this.F, this.PS, this.a, this.b, this.e, this.g, this.u0, this.times{2});
        end
        function this = estimateParameters(this, varargin)
            ip = inputParser;
            addOptional(ip, 'mapParams', this.mapParams, @(x) isa(x, 'containers.Map'));
            parse(ip, varargin{:});
            
            [S01,this.t0] = this.estimateS0t0(this.independentData{1}, this.dependentData{1});
            [S02,this.u0] = this.estimateS0t0(this.independentData{2}, this.dependentData{2});
            this.S0 = mean([S01 S02]);
            
            this = this.runMcmc(ip.Results.mapParams, {'F' 'PS' 'S0' 'a' 'b' 'e' 'g' 't0' 'u0'});
        end
        function ed   = estimateDataFast(this, F, PS, S0, a, b, e, g, t0, u0)
            ed{1} = this.wellCounts(      S0, a, b, e, g, t0, this.times{1});
            ed{2} = this.tscCounts(F, PS, S0, a, b, e, g, u0, this.times{2});
        end
        function ps   = adjustParams(this, ps)            
            theParams = this.theParameters;
            if (ps(theParams.paramsIndices('F'))  > ps(theParams.paramsIndices('PS')))
                tmp                               = ps(theParams.paramsIndices('PS'));
                ps(theParams.paramsIndices('PS')) = ps(theParams.paramsIndices('F'));
                ps(theParams.paramsIndices('F'))  = tmp;
            end
            if (ps(theParams.paramsIndices('b')) < ps(theParams.paramsIndices('F')))
                ps(theParams.paramsIndices('b')) = ps(theParams.paramsIndices('F'));
            end
            if (ps(theParams.paramsIndices('b')) > ps(theParams.paramsIndices('g')))
                tmp                              = ps(theParams.paramsIndices('g'));
                ps(theParams.paramsIndices('g')) = ps(theParams.paramsIndices('b'));
                ps(theParams.paramsIndices('b')) = tmp;
            end
        end
        
        function plot(this, varargin)
            figure;
            max_wel   = max(this.itsWellCounts);
            max_data1 = max(this.dependentData{1});
            max_tsc   = max(this.itsTscCounts);
            max_data2 = max(this.dependentData{2});
            plot(this.independentData{1}, this.itsWellCounts   /max_wel, ...
                 this.independentData{1}, this.dependentData{1}/max_data1, ...
                 this.independentData{2}, this.itsTscCounts    /max_tsc, ...
                 this.independentData{2}, this.dependentData{2}/max_data2, varargin{:});
            legend('Bayesian well', 'data well', 'Bayesian tsc', 'data tsc');            
            title(this.detailedTitle, 'Interpreter', 'none');
            xlabel(this.xLabel);
            ylabel(sprintf('%s; rescaled by %g, %g, %g, %g', this.yLabel, max_wel, max_data1, max_tsc, max_data2));
        end
        function plotParVars(this, par, vars)
            assert(lstrfind(par, properties('mlperfusion.PLaif1Training')));
            assert(isnumeric(vars));
            switch (par)
                case 'F'
                    for v = 1:length(vars)
                        args{v} = { vars(v) this.PS this.S0 this.a  this.b  this.e  this.g  this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'PS'
                    for v = 1:length(vars)
                        args{v} = { this.F  vars(v) this.S0 this.a  this.b  this.e  this.g  this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'S0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS vars(v) this.a  this.b  this.e  this.g  this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'a'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 vars(v) this.b  this.e  this.g  this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'b'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  vars(v) this.e  this.g  this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'e'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  this.b  vars(v) this.g  this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'g'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  this.b  this.e  vars(v) this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 't0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  this.b  this.e  this.g  vars(v)  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'u0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  this.b  this.e  this.g  this.t0  vars(v) ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
            end
            this.plotParArgs(par, args, vars);
        end
    end
    
    %% PRIVATE
    
    methods (Access = 'private')
        function plotParArgs(this, par, args, vars)
            assert(lstrfind(par, properties('mlperfusion.PLaif1Training')));
            assert(iscell(args));
            assert(isnumeric(vars));
            import mlperfusion.*;
            figure
            hold on
            for v = 1:size(args,2)
                argsv = args{v};
                plot(this.independentData{1}, ...
                     PLaif1Training.wellCounts(                    argsv{3}, argsv{4}, argsv{5}, argsv{6}, argsv{7}, argsv{8}), ...
                     this.independentData{2}, ...
                     PLaif1Training.tscCounts( argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{6}, argsv{7},            argsv{9}));
            end
            title(sprintf('F %g, PS %g, S0 %g, a %g, b %g, e %g, g %g, t0 %g, u0 %g', ...
                          argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{6}, argsv{7}, argsv{8}, argsv{9}));
            legend(cellfun(@(x) sprintf('%s = %g', par, x), num2cell(vars), 'UniformOutput', false));
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

