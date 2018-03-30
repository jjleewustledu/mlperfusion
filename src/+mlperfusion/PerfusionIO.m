classdef PerfusionIO < mlio.AbstractIO 
	%% PERFUSIONIO is a concrete class for filesystem I/O of ASCII/Unicode text; 
    %  it specifically parses log files from Josh Shimony's perfusion_4dfp package
    %
	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.3.0.532 (R2014a) 
 	%  $Id$ 
 	 
    properties (Constant)
        FILETYPE     =   'perfusion_4dfp log'
        FILETYPE_EXT =   '.log'
        PARAM_NAMES  = { 'S0' 'CBF' 't0' 'alpha' 'beta' 'delta' 'gamma' 'eps' }
    end
    
    properties (Dependent)
        contents
        descrip
        header
        
        S0
        CBF
        t0
        alpha
        beta
        delta
        gamma
        eps
    end
    
    methods %% SET/GET
        function c     = get.contents(this)
            assert(~isempty(this.contents_));
            c = this.contents_;
        end
        function d     = get.descrip(this)
            d = sprintf('%s read %s on %s', class(this), this.fqfilename, datestr(now));
        end
        function h     = get.header(this)
            h = [this.contents{1} ' ' this.contents{2}];
        end
        
        function this  = set.S0(this, x)
            assert(isnumeric(x));
            this.S0_ = x;
        end
        function x     = get.S0(this)
            assert(~isempty(this.S0_));
            x = this.S0_;
        end
        function this  = set.CBF(this, x)
            assert(isnumeric(x));
            this.CBF_ = x;
        end
        function x     = get.CBF(this)
            assert(~isempty(this.CBF_));
            x = this.CBF_;
        end
        function this  = set.t0(this, x)
            assert(isnumeric(x));
            this.t0_ = x;
        end
        function x     = get.t0(this)
            assert(~isempty(this.t0_));
            x = this.t0_;
        end
        function this  = set.alpha(this, x)
            assert(isnumeric(x));
            this.alpha_ = x;
        end
        function x     = get.alpha(this)
            assert(~isempty(this.alpha_));
            x = this.alpha_;
        end
        function this  = set.beta(this, x)
            assert(isnumeric(x));
            this.beta_ = x;
        end
        function x     = get.beta(this)
            assert(~isempty(this.beta_));
            x = this.beta_;
        end
        function this  = set.delta(this, x)
            assert(isnumeric(x));
            this.delta_ = x;
        end
        function x     = get.delta(this)
            assert(~isempty(this.delta_));
            x = this.delta_;
        end
        function this  = set.gamma(this, x)
            assert(isnumeric(x));
            this.gamma_ = x;
        end
        function x     = get.gamma(this)
            assert(~isempty(this.gamma_));
            x = this.gamma_;
        end
        function this  = set.eps(this, x)
            assert(isnumeric(x));
            this.eps_ = x;
        end
        function x     = get.eps(this)
            assert(~isempty(this.eps_));
            x = this.eps_;
        end
    end
    
	methods (Static)
        function this = load(fn) 
            this = mlperfusion.PerfusionIO(fn);
        end
        function ca  = textfileToCell(fqfn, eol)  %#ok<INUSD>
            if (~exist('eol','var'))
                fget = @fgetl;
            else
                fget = @fgets;
            end
            ca = {[]};
            try
                fid = fopen(fqfn);
                i   = 1;
                while 1
                    tline = fget(fid);
                    if ~ischar(tline), break, end
                    ca{i} = tline;
                    i     = i + 1;
                end
                fclose(fid);
                assert(~isempty(ca) && ~isempty(ca{1}))
            catch ME
                fprintf('mlperfusion.PerfusionIO.textfileToCell:  exception thrown while reading \n\t%s\n\tME.identifier->%s', fqfn, ME.identifier);
            end
        end
    end
    
    methods
        function this = PerfusionIO(fn)
            import mlperfusion.*;
            assert(lexist(fn, 'file'));
            [pth, fp, fext] = fileparts(fn); 
            if (strcmp(PerfusionIO.FILETYPE_EXT, fext) || ...
                isempty(fext))
                this = this.loadText(fn); 
                this.fqfilename = fullfile(pth, [fp fext]);
                this = this.lookForPars;
                return 
            end
            error('mlperfusion:unsupportedParam', 'PerfusionIO.load does not support file-extension .%s', fext);
        end
        function ch   = char(this)
            ch = strjoin(this.contents, '\n');
        end
        function        save(~)
        end
    end
    
    %% PROTECTED
    
    properties (Access = 'protected')
        contents_
        parRegexp1_ = 'par\s+\d+\s+=\s+(?<par>\d+.\d+)\s+\(\s+\d+.\d+\)\s+';
        parRegexp2_ = '\s+min\s+\d+.\d+\s+max\s+\d+.\d+\s+\w+';
                
        S0_
        CBF_
        t0_
        alpha_
        beta_
        delta_
        gamma_
        eps_
    end
    
    methods (Access = 'protected')
        function this         = lookForPars(this)
            [first,last] = this.contentLinesWithPars;
            for c = first:last
                line = this.contents{c};
                this = this.lookForPar(line, 'S0');
                this = this.lookForPar(line, 'CBF');
                this = this.lookForPar(line, 't0');
                this = this.lookForPar(line, 'alpha');
                this = this.lookForPar(line, 'beta');
                this = this.lookForPar(line, 'delta');
                this = this.lookForPar(line, 'gamma');
                this = this.lookForPar(line, 'eps');
            end
        end
        function [first,last] = contentLinesWithPars(this)
            first = -1; last = -1;
            for c = 1:length(this.contents)
                line = this.contents{c};
                if (length(line) > 10)
                    if (strcmp('par', line(1:3)) && first < 0)
                        first = c; 
                    end
                    if (strcmp('logprob = ', line(1:10)))
                        last = c - 1; 
                        break
                    end
                end
            end
            assert(first > 0 && last > 0 && first < last);
        end
        function this         = lookForPar(this, line, parName)
            if (lstrfind(line, parName))
                this.(parName) = this.parValue(line, parName); end
        end
        function d            = parValue(this, line, parName)
            assert(ischar(line));
            rgxnames = regexp(line, this.parRegexp(parName), 'names');
            d = str2double(rgxnames.par);
        end
        function r            = parRegexp(this, parName)
            assert(lstrfind(parName, this.PARAM_NAMES));
            r = [this.parRegexp1_ parName this.parRegexp2_];
        end
        function this         = loadText(this, fn)
            import mlperfusion.*;
            this.contents_ = PerfusionIO.textfileToCell(fn);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

