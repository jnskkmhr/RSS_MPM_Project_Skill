Research Questions 

T1: Streaming MPM, adaptive particle activation/sleeping numerical benchmark
* Does it scale with terrain size ?
    * It will be terrain size vs physics wallclock time / VRAM / GPU usage
    * I am not sure how to quantify terrain size. For object to traverse 10m on fixed terrain, you need to simulate particles in this size, so obviously this is more expensive than streaming MPM. Like, should we use travel distance as x axis or particle numbers spawened as x axis? 
    * Also, what's the list of ablations ? Is it going to be like:
    ```
    |  | sleeping | streaming  |
    ----------------------------
    |  |   N/A    |    N/A     |
    |  |   strain |    N/A     |
    |  |   region |    N/A     |
    |  |   N/A    | fixed pool |
    |  |   strain | cache      |

    or should we just merge strain + region and just say sleepign Yes 
    |  | sleeping | streaming  |
    ----------------------------
    |  |   N/A    |    N/A     |
    |  |   Yes    |    N/A     |
    |  |   N/A    | fixed pool |
    |  |   N/A    | cache      |
    |  |   Yes    | fixed pool |
    |  |   Yes    | cache      |
    ```
* Does it scale with num_envs ? 
    * for each environment, how should we configure terrain ? We should test with small environment ? Or large environment ? 
    * should we say like for locomotion training like 10mx10m, ours fit on xx GPUs while full fits a few GPU? 
    * thing is terrain size is coupled into this benchmark value so.... 
* Does it preserve terrain history ? 
    * This is simply just compare full (sleep N/A, streaming N/A) and cache (sleep either N/A or Yes, streaming cache)
    * Do with box and G1 (lemniscate trajectory)
* Look at box benchmark done using IsaacLab-T1: /home/jkamohara/isaac/worktrees/IsaacLab-T1/logs/t1
    * for numerical benchmarking, we can do same thing, but with unified mpm code /home/jkamohara/isaac/worktrees/mpm-unification/IsaacLab/source/isaaclab_tasks/isaaclab_tasks/contrib/velocity_mpm/config/g1_29dof (this is g1 tho)
    * for lemniscate, use /home/jkamohara/isaac/worktrees/mpm-unification/IsaacLab/source/isaaclab_tasks/isaaclab_tasks/contrib/velocity_mpm/config/g1_29dof and just command velocity to be lemniscate open loop trajectory or apply PD controller to decide vx and wz.

T2: Cross embodiment and multi task transfer 
* Does mpm train multiple embodiments (manipulator, quadrupedal, and humanoid)
* Train multiple tasks ?  (manipulation, walking, object pushing)

T3, 4 (fix proposed) When does explicit particle representation shine compared to reduced order approach / mujoco compliance ? This is policy level benchmarking
* Rougher terrain generalization ?
    * success rate
    * tracking ability
* Walking robustness to very soft terrain?
    * pitch is ROM/Mujoco cannot simulate these type of terrains
    * Snow / Powdery / sticky terrain
    * See success rate, stability (pelvis jerk, joint smoothness)
* Rich terrain interactions
    * loco-manipulation 
    * policy needs to learn how to inject correct force to fight against soil resistance

T4: Does neural surrogate replace MPM ? (Previous T5)
* Throughput and memory comparison
* Simulation accuracy using elementary object benchmark 
* Robot sim2sim and sim2real 
