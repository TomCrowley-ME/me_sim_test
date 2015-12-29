% MontecarloGeneric
%  uses mc = CreateMontecarloGenergic( InitScript_s, ErrorFn_s, mc_all, name, varargin )

% (Source published under the MIT License, see readme.txt for rationale)
% 
% Copyright (c) 2011 Ian M. Garcia
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
% 
% (http://www.opensource.org/licenses/mit-license.php)

for imc = 1:length(mc.mc_all)
    clearSim;
    
    monteCarloSeed_i=mc.seeds_i(mc.mc_all(imc));    
    eval(mc.InitScript_s);
    fprintf('****************** SIM %d of %d for %.0f secs ************\n',imc,length(mc.mc_all),simulation.end_t);
    if mc.mc_all(imc)==1
        % no error
    elseif mc.mc_all(imc)==2
        % remove mass misalignments
        vehicle.mass = removeMassMisalignments( vehicle.mass );
    else
        RandStream.setDefaultStream( RandStream.create('mt19937ar','seed',monteCarloSeed_i) );
        vehicle = feval( mc.ErrorFn_s, vehicle );
    end
    if mc.useAccel_b
        tic
        so=sim( mc.Model_s,'SimulationMode', 'accelerator');
        toc
        extractSimulationOutput
    else
        tic
        sim( mc.Model_s );
        toc
    end
    
    nameMontecarlo=[mc.name num2str(mc.mc_all(imc))];
    fprintf('Saved %s\n',[nameMontecarlo '.mat']);
    saveMontecarlo
end
