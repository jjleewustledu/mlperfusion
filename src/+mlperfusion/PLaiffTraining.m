classdef PLaiffTraining < mlperfusion.AbstractPLaif 
	%% PLAIFFTRAINING does Bayesian parameter estimation on the arterial-line data and the scanner detector-array data 
    %  with equal contributions of the sum-of-squares to the cost function.  This will be the basis for training
    %  prior ranges.  

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
	properties        
        F  = 0.0121
        PS = 0.0352
        R0 = 4.88e6
        S0 = 3.71e6
        a  = 0.936
        b  = 0.202
        p  = 0.712
        t0 = 21.6 % for wellCounts
        u0 = 44.9 % for tscCounts
        
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
            dt = sprintf('%s\nF %g, PS %g, R0 %g, S0 %g, a %g, b %g, p %g, t0 %g, u0 %g', ...
                         this.baseTitle, ...
                         this.F, this.PS, this.R0, this.S0, this.a, this.b, this.p, this.t0, this.u0);
        end
        function m  = get.mapParams(this)
            m = containers.Map;
            N = 5;
            m('F')  = struct('fixed', 0, 'min', 0.004305,                    'mean', this.F,  'max', 0.01229);
            m('PS') = struct('fixed', 0, 'min', 0.009275,                    'mean', this.PS, 'max', 0.03675);
            m('R0') = struct('fixed', 0, 'min', this.R0/2,                   'mean', this.R0, 'max', 2*this.R0);
            m('S0') = struct('fixed', 0, 'min', this.S0/2,                   'mean', this.S0, 'max', 2*this.S0);
            m('a')  = struct('fixed', 0, 'min', max(this.a  - N*this.a,  0), 'mean', this.a,  'max', this.a  + N*this.a); 
            m('b')  = struct('fixed', 0, 'min', max(this.b  - N*this.b,  0), 'mean', this.b,  'max', this.b  + N*this.b);
            m('p')  = struct('fixed', 0, 'min', 0,                           'mean', this.p,  'max', 3);
            m('t0') = struct('fixed', 0, 'min', this.t0/2,                   'mean', this.t0, 'max', 2*this.t0);
            m('u0') = struct('fixed', 0, 'min', this.u0/2,                   'mean', this.u0, 'max', 2*this.u0);  
        end
    end
    
    methods (Static)
        function this = load(ecatFn, maskFn, dcvFn)
            import mlpet.* mlperfusion.* mlfourd.*;
            mask = MaskingNIfTId.load(maskFn);
            ecat = mlsiemens.EcatExactHRPlus.load(ecatFn); % radioactive decay modeled by kConcentration
            ecat = ecat.masked(mask);
            ecat = ecat.volumeSummed;            
            ecat.img = ecat.img / mask.count;
            
            dcv = DCV.load(dcvFn); % radioactive decay modeled by kAif
           
            this = PLaiffTraining( ...
                {dcv.times      ecat.times}, ...
                {dcv.wellCounts ecat.tscCounts'});
        end   
        function wc   = wellCounts(R0, a, b, p, t0, t)
            import mlperfusion.*;
            wc = R0 * PLaiffTraining.kAif(a, b, p, t0, t);
        end 
        function tc   = tscCounts(F, PS, S0, a, b, p, u0, t)
            import mlperfusion.*;
            tc = S0 * PLaiffTraining.kConcentration(F, PS, a, b, p, u0, t);
        end    
        function kA   = kAif(a, b, p, t0, t)
            import mlperfusion.*
            kA = PLaiffTraining.bolusFlowFractal(a, b, p, t0, t);
        end             
        function kC   = kConcentration(F, PS, a, b, p, u0, t)
            import mlperfusion.*;
            m      = (1 - exp(-PS/F));
            ldecay = PLaiffTraining.LAMBDA_DECAY_15O;
            delta  = m * F /  PLaiffTraining.LAMBDA + ldecay; % decay in Fick's equation
            kC     = m * F * (PLaiffTraining.flowFractal(a, b, delta, ldecay, p, u0, t));
        end
        function this = simulateMcmc(F, PS, R0, S0, a, b, p, t0, u0, t, u, mapParams)
            import mlperfusion.*;     
            wellCnts = PLaiffTraining.wellCounts(      R0, a, b, p, t0, t);
            tscCnts  = PLaiffTraining.tscCounts(F, PS, S0, a, b, p, u0, u);
            this     = PLaiffTraining({t t}, {wellCnts tscCnts});
            this     = this.estimateParameters(mapParams) %#ok<NOPRT>
            this.plot;
        end    
    end

	methods
 		function this = PLaiffTraining(varargin) 
 			%% PLAIFFTRAINING 
 			%  Usage:  this = PLaiffTraining([times, tscCounts]) 
 			
 			this = this@mlperfusion.AbstractPLaif(varargin{:});
            this.keysArgs_ = ...
                {this.F this.PS this.R0 this.S0 this.a this.b this.p this.t0 this.u0};
        end 
        
        function this = simulateItsMcmc(this)
            import mlperfusion.*;
            this = PLaiffTraining.simulateMcmc( ...
                   this.F, this.PS, this.S0, this.a, this.b, this.p, this.t0, this.u0, this.times{1}, this.times{2}, this.mapParams);
        end
        function wc   = itsWellCounts(this)
            wc = mlperfusion.PLaiffTraining.wellCounts(this.R0, this.a, this.b, this.p, this.t0, this.times{1});
        end
        function tc   = itsTscCounts(this)
            tc = mlperfusion.PLaiffTraining.tscCounts(this.F, this.PS, this.S0, this.a, this.b, this.p, this.u0, this.times{2});
        end
        function ka   = itsKAif(this)
            ka = mlperfusion.PLaiffTraining.kAif(this.a, this.b, this.p, this.t0, this.times{1});
        end
        function kc   = itsKConcentration(this)
            kc = mlperfusion.PLaiffTraining.kConcentration(this.F, this.PS, this.a, this.b, this.p, this.u0, this.times{2});
        end
        function this = estimateParameters(this, varargin)
            ip = inputParser;
            addOptional(ip, 'mapParams', this.mapParams, @(x) isa(x, 'containers.Map'));
            parse(ip, varargin{:});
            
            [this.R0,this.t0] = this.estimateS0t0(this.independentData{1}, this.dependentData{1});
            [this.S0,this.u0] = this.estimateS0t0(this.independentData{2}, this.dependentData{2});
            
            this = this.runMcmc(ip.Results.mapParams, 'keysToVerify', {'F' 'PS' 'R0' 'S0' 'a' 'b' 'p' 't0' 'u0'});
        end
        function ed   = estimateDataFast(this, F, PS, R0, S0, a, b, p, t0, u0)
            ed{1} = this.wellCounts(      R0, a, b, p, t0, this.times{1});
            ed{2} = this.tscCounts(F, PS, S0, a, b, p, u0, this.times{2});
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
            assert(lstrfind(par, properties('mlperfusion.PLaiffTraining')));
            assert(isnumeric(vars));
            switch (par)
                case 'F'
                    for v = 1:length(vars)
                        args{v} = { vars(v) this.PS this.S0 this.a  this.b  this.p  this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'PS'
                    for v = 1:length(vars)
                        args{v} = { this.F  vars(v) this.S0 this.a  this.b  this.p  this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'S0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS vars(v) this.a  this.b  this.p  this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'a'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 vars(v) this.b  this.p  this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'b'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  vars(v) this.p  this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'p'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  this.b  vars(v) this.t0  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 't0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  this.b  this.p  vars(v)  this.u0 ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
                case 'u0'
                    for v = 1:length(vars)
                        args{v} = { this.F  this.PS this.S0 this.a  this.b  this.p  this.t0  vars(v) ...
                                    this.independentData{1} this.independentData{2} }; 
                    end
            end
            this.plotParArgs(par, args, vars);
        end
    end
    
    %% PRIVATE
    
    methods (Access = 'private')
        function plotParArgs(this, par, args, vars)
            assert(lstrfind(par, properties('mlperfusion.PLaiffTraining')));
            assert(iscell(args));
            assert(isnumeric(vars));
            import mlperfusion.*;
            figure
            hold on
            for v = 1:size(args,2)
                argsv = args{v};
                plot(this.independentData{1}, ...
                     PLaiffTraining.wellCounts(                    argsv{3}, argsv{4}, argsv{5}, argsv{6}, argsv{7}), ...
                     this.independentData{2}, ...
                     PLaiffTraining.tscCounts( argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{6},            argsv{8}));
            end
            title(sprintf('F %g, PS %g, S0 %g, a %g, b %g, p %g, t0 %g, u0 %g', ...
                          argsv{1}, argsv{2}, argsv{3}, argsv{4}, argsv{5}, argsv{6}, argsv{7}, argsv{8}));
            legend(cellfun(@(x) sprintf('%s = %g', par, x), num2cell(vars), 'UniformOutput', false));
            xlabel(this.xLabel);
            ylabel(this.yLabel);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

