Phase 0: The "Geometric Baseline"

    Goal: Verify the Damper-Based Coupling and UKF logic in a perfect environment.

    Implementation: * Truth Data: Use the exact x,y,z and velocity U from your simulation engine.

        Error: Zero noise.

        Tire Stiffness: Start with the "Ground Truth" value.

    Outcome: The estimator should converge to the exact parameters instantly. If not, the issue is in the model equations (DH parameters or damper logic).

Phase 1: Stochastic & Systematic Noise (The "Bias" Phase)

    Goal: Test robustness to the slow-varying nature of GPS (Atmosphere/Clock).

    Implementation: * The Sampling Strategy: For each Monte Carlo clip, sample a Constant Bias b∼N(0,σbias2​) (where σbias​≈2–5 m). Keep this fixed for the duration of the 30–60s clip.

        Superimposed Noise: Add high-frequency white noise n∼N(0,σwhite2​) at each time step (e.g., 10 Hz).

        Velocity (U): Add a smaller, independent white noise (≈0.05 m/s) to the velocity vector.

    Outcome: Your estimator must "learn" to ignore the constant position offset and focus on the change in motion to find Cα​.

Phase 2: Urban Logic & Rejection (The "Multipath" Phase)

    Goal: Stress-test the Innovation Filtering and Data Rejection.

    Implementation:

        The Step Error: In the middle of a maneuver, inject a Step Bias (e.g., a sudden +15 m shift in y) to simulate a satellite signal bouncing off a building.

        Code-Phase Divergence: If you use Phase data, make the Phase move in the opposite direction of the Pseudorange for 2 seconds.

        Satellite Outage: Drop the GNSS signal entirely for 5 seconds (simulating a bridge/tunnel).

    Outcome: The UKF should "freeze" the tire stiffness estimate during the outage and reject the "Step Bias" as a physically impossible maneuver for a heavy vehicle.