addpath /home/jake/trunk-jpl/bin/ /home/jake/trunk-jpl/lib/

% Load the model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

markov_sequences = load('data/future_markov_sequences.mat');
posterior = load('data/posterior.mat').posterior;
posterior = transpose(posterior);


% Load the prior params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Frontal melt rate 
p0 = posterior(1,:);
% Minimum melt rate param
p1 = posterior(2,:);
% Ice temperature offset
p2 = posterior(3,:);
% Calving stress
p3 = posterior(4,:);
% Min calving stress ratio
p4 = posterior(5,:);

p0 = p0(i)
p1 = p1(i)
p2 = p2(i)
p3 = p3(i)
p4 = p4(i)

j = round(p2 + 10) + 1;
load(strcat('data/models/model_', int2str(j), '.mat'));
ts = markov_sequences.ts;
sequence = markov_sequences.markov_sequences(i,:);

% Surface runoff extended into the future by extending runoff
surface_runoff = load('data/surface_runoff_extended.mat').surface_runoff;
runoff_ts = surface_runoff.ts;
qs = surface_runoff.surface_runoff;
% Normalize runoff
qs = qs / max(qs);
  
cd(strcat('results/', int2str(i)));

md.groundingline.migration = 'SubelementMigration';
md.groundingline.friction_interpolation = 'SubelementFriction2';
md.groundingline.melt_interpolation = 'SubelementMelt2';

md.timestepping.time_step = 0.005;
md.timestepping.start_time = 2007;
md.timestepping.final_time = 2050;
md.settings.output_frequency = 10;


% Set run parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

m_max = p0;
m_min = p0*p1;
qs = zeros(md.mesh.numberofvertices + 1, size(runoff_ts,2)) + qs;
md.frontalforcings.meltingrate = (sqrt((m_max-m_min)^2 * qs) + m_min);
md.frontalforcings.meltingrate(end,:) = runoff_ts;

% Ice temperature
B0 = paterson(md.initialization.temperature);
md.initialization.temperature = min(md.initialization.temperature + p2, 273.15);
B1 = paterson(md.initialization.temperature);
md.materials.rheology_B = B1; 


% Time variable calving stress
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sigma_max = p3 * (paterson(273.15) ./ B0);
sigma_min = sigma_max*p4;
sigma_max(end+1) = 0;
sigma_min(end+1) = 0;
indicator = zeros(md.mesh.numberofvertices + 1, size(ts,2)) + sequence;
size(indicator)
md.calving.stress_threshold_floatingice = indicator.*(sigma_max - sigma_min) + sigma_min;
size(md.calving.stress_threshold_floatingice)
md.calving.stress_threshold_floatingice(end,:) = ts;
md.calving.stress_threshold_groundedice = md.calving.stress_threshold_floatingice;


% Solve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

md.miscellaneous.name = ['param_', num2str(i)];
md.transient.isthermal = 0;
md.transient.requested_outputs={'default', 'IceVolume', 'CalvingCalvingrate', 'IceVolumeAboveFloatation','IceVolumeAboveFloatationScaled','GroundedArea','FloatingArea','GroundedAreaScaled','FloatingAreaScaled','IceMass'};

md.cluster=generic('name',oshostname, 'np', 3);
md=solve(md,'Transient','runtimename',false);
save(strcat('results_',  int2str(i), '.mat'), 'md', '-v7.3')
