import openmc
import openmc.deplete
import matplotlib.pyplot as plt

###############################################################################
#                      Load previous simulation results
###############################################################################

# Load geometry from statepoint
statepoint = 'statepoint.100.h5'
with openmc.StatePoint(statepoint) as sp:
    geometry = sp.summary.geometry

# Load previous depletion results
previous_results = openmc.deplete.ResultsList("depletion_results.h5")

###############################################################################
#                      Transport calculation settings
###############################################################################

# Instantiate a Settings object, set all runtime parameters
settings = openmc.Settings()
settings.batches = 100
settings.inactive = 10
settings.particles = 10000

# Create an initial uniform spatial source distribution over fissionable zones
bounds = [-0.62992, -0.62992, -1, 0.62992, 0.62992, 1]
uniform_dist = openmc.stats.Box(bounds[:3], bounds[3:], only_fissionable=True)
settings.source = openmc.source.Source(space=uniform_dist)

entropy_mesh = openmc.RegularMesh()
entropy_mesh.lower_left = [-0.39218, -0.39218, -1.e50]
entropy_mesh.upper_right = [0.39218, 0.39218, 1.e50]
entropy_mesh.dimension = [10, 10, 1]
settings.entropy_mesh = entropy_mesh

###############################################################################
#                   Initialize and run depletion calculation
###############################################################################

# Create depletion "operator"
chain_file = './chain_simple.xml'
op = openmc.deplete.Operator(geometry, settings, chain_file, previous_results)

# Perform simulation using the predictor algorithm
time_steps = [1.0, 1.0, 1.0, 1.0, 1.0]  # days
power = 174  # W/cm, for 2D simulations only (use W for 3D)
integrator = openmc.deplete.PredictorIntegrator(op, time_steps, power, timestep_units='d')
integrator.integrate()

